options(scipen = 999)

suppressPackageStartupMessages({
  library(dplyr)
  library(fixest)
  library(readr)
})

replication_dir <- if (dir.exists("replication")) "replication" else "."
data_dir <- file.path(replication_dir, "candidate_papers", "jensen_2025")
els_path <- file.path(data_dir, "analysis_data_ELS.tab")

if (!file.exists(els_path)) {
  stop(
    "Arquivo não encontrado: ", els_path,
    ". Baixe os arquivos do Dataverse para replication/candidate_papers/jensen_2025/.",
    call. = FALSE
  )
}

results_path <- file.path(replication_dir, "jensen_table1_replication.csv")
extension_path <- file.path(replication_dir, "jensen_extension_results.csv")
validation_path <- file.path(replication_dir, "jensen_validation_checks.csv")
sample_path <- file.path(replication_dir, "jensen_sample_summary.csv")

els <- readr::read_tsv(els_path, show_col_types = FALSE) |>
  dplyr::mutate(STU_ID = as.factor(STU_ID))

core_vars <- c(
  "STU_ID", "PostPeriod", "voted", "treatment_level_at_t2",
  "restr_treatment_level_at_t2", "eligible_voter_2004",
  "non_hs_grad_2004", "voted_in_PREPERIOD",
  "weights_notvc", "weights_tvc"
)

sample_summary <- dplyr::tibble(
  n_obs_raw = nrow(els),
  n_students_raw = dplyr::n_distinct(els$STU_ID),
  n_obs_analysis_filter = sum(
    els$eligible_voter_2004 == 1 & els$non_hs_grad_2004 != 1,
    na.rm = TRUE
  ),
  n_students_analysis_filter = dplyr::n_distinct(
    els$STU_ID[els$eligible_voter_2004 == 1 & els$non_hs_grad_2004 != 1]
  ),
  post_share = mean(els$PostPeriod == 1, na.rm = TRUE)
)

format_check_value <- function(x) {
  if (is.logical(x)) {
    ifelse(isTRUE(x), "TRUE", "FALSE")
  } else {
    as.character(x)
  }
}

validation_values <- list(
  list(
    check = "Duplicatas id-período",
    value = format_check_value(sum(duplicated(dplyr::select(els, STU_ID, PostPeriod))))
  ),
  list(
    check = "PostPeriod assume apenas 0/1",
    value = format_check_value(all(stats::na.omit(unique(els$PostPeriod)) %in% c(0, 1)))
  ),
  list(
    check = "eligible_voter_2004 assume apenas 0/1",
    value = format_check_value(all(stats::na.omit(unique(els$eligible_voter_2004)) %in% c(0, 1)))
  ),
  list(
    check = "treatment_level_at_t2 assume apenas 0/1/NA",
    value = format_check_value(all(stats::na.omit(unique(els$treatment_level_at_t2)) %in% c(0, 1)))
  ),
  list(
    check = "restr_treatment_level_at_t2 assume apenas 0/1/NA",
    value = format_check_value(all(stats::na.omit(unique(els$restr_treatment_level_at_t2)) %in% c(0, 1)))
  ),
  list(
    check = "Valores ausentes nas variáveis centrais",
    value = format_check_value(sum(!stats::complete.cases(dplyr::select(els, dplyr::all_of(core_vars)))))
  )
)

validation_checks <- dplyr::bind_rows(validation_values) |>
  dplyr::mutate(
    status = dplyr::case_when(
      check == "Valores ausentes nas variáveis centrais" ~ "ALERTA",
      value %in% c("0", "TRUE") ~ "OK",
      TRUE ~ "FALHA"
    )
  )

analysis_sample <- els |>
  dplyr::filter(eligible_voter_2004 == 1, non_hs_grad_2004 != 1)

matched_sample <- analysis_sample |>
  dplyr::filter(!is.na(treatment_level_at_t2))

xx_vars <- grep("^xx_", names(analysis_sample), value = TRUE)
tvc_vars <- c(
  xx_vars, "i(lives_with_par_mod)", "F2D15A_", "F2D15B_", "F2D15C_",
  "F2D15D_", "F2D15E_", "F2D15F_", "F2D15G_", "became_parent_", "paidwork"
)
dyn_vars <- c(
  "PostPeriod:factor(rr_dyn_ses)",
  "PostPeriod:factor(rr_dyn_cog)",
  "PostPeriod:factor(m_race)",
  "PostPeriod:factor(m_sex)"
)

build_formula <- function(treat_var, include_vh = TRUE, include_tvc = FALSE, include_dyn = FALSE) {
  rhs_terms <- c("PostPeriod", paste0("PostPeriod:", treat_var))

  if (include_vh) {
    rhs_terms <- c(rhs_terms, "PostPeriod:voted_in_PREPERIOD")
  }
  if (include_tvc) {
    rhs_terms <- c(rhs_terms, tvc_vars)
  }
  if (include_dyn) {
    rhs_terms <- c(rhs_terms, dyn_vars)
  }

  stats::as.formula(
    paste0("voted ~ ", paste(rhs_terms, collapse = " + "), " | STU_ID")
  )
}

extract_treat_row <- function(model) {
  coef_name <- grep(
    "PostPeriod:(treatment_level_at_t2|restr_treatment_level_at_t2)$",
    names(stats::coef(model)),
    value = TRUE
  )[1]

  coef_table <- summary(model)$coeftable
  dplyr::tibble(
    coef_name = coef_name,
    estimate = unname(stats::coef(model)[[coef_name]]),
    std_error = sqrt(stats::vcov(model)[coef_name, coef_name]),
    statistic = unname(coef_table[coef_name, "t value"]),
    p_value = unname(coef_table[coef_name, "Pr(>|t|)"]),
    conf_low = estimate - stats::qnorm(0.975) * std_error,
    conf_high = estimate + stats::qnorm(0.975) * std_error,
    n_obs = stats::nobs(model)
  )
}

estimate_model <- function(model_id,
                           panel,
                           spec_label,
                           model,
                           published_estimate = NA_real_) {
  out <- extract_treat_row(model)

  out |>
    dplyr::mutate(
      model_id = model_id,
      panel = panel,
      spec_label = spec_label,
      published_estimate = published_estimate,
      benchmark_gap = estimate - published_estimate,
      .before = 1
    )
}

m1 <- feols(
  build_formula("treatment_level_at_t2", include_vh = TRUE, include_tvc = FALSE, include_dyn = FALSE),
  data = analysis_sample,
  vcov = ~STU_ID
)

m2 <- feols(
  build_formula("treatment_level_at_t2", include_vh = TRUE, include_tvc = TRUE, include_dyn = FALSE),
  data = analysis_sample,
  vcov = ~STU_ID
)

m3 <- feols(
  build_formula("treatment_level_at_t2", include_vh = TRUE, include_tvc = TRUE, include_dyn = TRUE),
  data = analysis_sample,
  vcov = ~STU_ID
)

m4 <- feols(
  build_formula("restr_treatment_level_at_t2", include_vh = TRUE, include_tvc = FALSE, include_dyn = FALSE),
  data = analysis_sample,
  vcov = ~STU_ID
)

m5 <- feols(
  build_formula("restr_treatment_level_at_t2", include_vh = TRUE, include_tvc = TRUE, include_dyn = FALSE),
  data = analysis_sample,
  vcov = ~STU_ID
)

m6 <- feols(
  build_formula("restr_treatment_level_at_t2", include_vh = TRUE, include_tvc = TRUE, include_dyn = TRUE),
  data = analysis_sample,
  vcov = ~STU_ID
)

m7 <- feols(
  voted ~ PostPeriod + PostPeriod:treatment_level_at_t2 | STU_ID,
  data = matched_sample,
  weights = ~weights_notvc,
  vcov = ~STU_ID
)

m8 <- feols(
  build_formula("treatment_level_at_t2", include_vh = TRUE, include_tvc = TRUE, include_dyn = FALSE),
  data = matched_sample,
  weights = ~weights_tvc,
  vcov = ~STU_ID
)

m_safe_full <- feols(
  build_formula("treatment_level_at_t2", include_vh = TRUE, include_tvc = FALSE, include_dyn = TRUE),
  data = analysis_sample,
  vcov = ~STU_ID
)

m_safe_restricted <- feols(
  build_formula("restr_treatment_level_at_t2", include_vh = TRUE, include_tvc = FALSE, include_dyn = TRUE),
  data = analysis_sample,
  vcov = ~STU_ID
)

table1_results <- dplyr::bind_rows(
  estimate_model("m1", "Full sample", "Tabela 1, modelo 1", m1, 0.137),
  estimate_model("m2", "Full sample", "Tabela 1, modelo 2", m2, 0.130),
  estimate_model("m3", "Full sample", "Tabela 1, modelo 3", m3, 0.107),
  estimate_model("m4", "Restricted control group", "Tabela 1, modelo 4", m4, 0.096),
  estimate_model("m5", "Restricted control group", "Tabela 1, modelo 5", m5, 0.106),
  estimate_model("m6", "Restricted control group", "Tabela 1, modelo 6", m6, 0.089),
  estimate_model("m7", "Matched", "Tabela 1, modelo 7", m7, 0.116),
  estimate_model("m8", "Matched", "Tabela 1, modelo 8", m8, 0.101)
)

extension_results <- dplyr::bind_rows(
  estimate_model("m1", "Full sample", "Base com prior voting x tempo", m1),
  estimate_model("m2", "Full sample", "Base + time-varying controls", m2),
  estimate_model("m_safe_full", "Full sample", "Base + covariáveis pré-tratamento x tempo", m_safe_full),
  estimate_model("m3", "Full sample", "Base + TVC + covariáveis pré-tratamento x tempo", m3),
  estimate_model("m4", "Restricted control group", "Base com prior voting x tempo", m4),
  estimate_model("m5", "Restricted control group", "Base + time-varying controls", m5),
  estimate_model("m_safe_restricted", "Restricted control group", "Base + covariáveis pré-tratamento x tempo", m_safe_restricted),
  estimate_model("m6", "Restricted control group", "Base + TVC + covariáveis pré-tratamento x tempo", m6)
) |>
  dplyr::group_by(panel) |>
  dplyr::mutate(
    base_estimate = estimate[model_id %in% c("m1", "m4")][1],
    safe_dyn_estimate = estimate[grepl("safe", model_id)][1],
    full_estimate = estimate[model_id %in% c("m3", "m6")][1],
    delta_vs_base = estimate - base_estimate,
    delta_vs_safe_dyn = estimate - safe_dyn_estimate,
    delta_vs_full = estimate - full_estimate
  ) |>
  dplyr::ungroup()

readr::write_csv(table1_results, results_path)
readr::write_csv(extension_results, extension_path)
readr::write_csv(validation_checks, validation_path)
readr::write_csv(sample_summary, sample_path)

cat("Resultados salvos em:\n")
cat(" -", results_path, "\n")
cat(" -", extension_path, "\n")
cat(" -", validation_path, "\n")
cat(" -", sample_path, "\n")
