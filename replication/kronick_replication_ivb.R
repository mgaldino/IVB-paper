options(scipen = 999)

suppressPackageStartupMessages({
  library(dplyr)
  library(fixest)
  library(haven)
  library(readr)
  library(tidyr)
})

replication_dir <- if (dir.exists("replication")) "replication" else "."
zip_path <- file.path(replication_dir, "replicationdata_dk_tojcr_v2.zip")
extract_dir <- file.path(replication_dir, "candidate_papers", "kronick_2020")
data_path <- file.path(
  extract_dir,
  "ReplicationData_DK_toJCR_v2",
  "analysis_data",
  "MuniMstr_R.dta"
)

if (!file.exists(data_path)) {
  if (!file.exists(zip_path)) {
    stop("Arquivo de replicação não encontrado em: ", zip_path, call. = FALSE)
  }
  utils::unzip(zip_path, exdir = extract_dir)
}

spec_output_path <- file.path(replication_dir, "kronick_specification_estimates.csv")
ivb_output_path <- file.path(replication_dir, "kronick_ivb_diagnostics.csv")
validation_output_path <- file.path(replication_dir, "kronick_validation_checks.csv")
summary_output_path <- file.path(replication_dir, "kronick_sample_summary.csv")

build_fe_formula <- function(lhs, rhs_terms, fe_terms) {
  rhs <- if (length(rhs_terms) > 0) {
    paste(rhs_terms, collapse = " + ")
  } else {
    "1"
  }

  if (length(fe_terms) > 0) {
    stats::as.formula(
      paste0(lhs, " ~ ", rhs, " | ", paste(fe_terms, collapse = " + "))
    )
  } else {
    stats::as.formula(paste0(lhs, " ~ ", rhs))
  }
}

estimate_spec <- function(data, spec_id, spec_label, rhs_terms) {
  model <- feols(
    fml = build_fe_formula(
      lhs = "hrate_combo",
      rhs_terms = rhs_terms,
      fe_terms = c("ci_mun", "year")
    ),
    data = data,
    vcov = ~ci_mun
  )

  coef_table <- summary(model)$coeftable
  treat_row <- coef_table["treat_panam_sucre", ]
  estimate <- unname(stats::coef(model)[["treat_panam_sucre"]])
  std_error <- unname(treat_row["Std. Error"])

  dplyr::tibble(
    spec_id = spec_id,
    spec_label = spec_label,
    estimate = estimate,
    std_error = std_error,
    statistic = unname(treat_row["t value"]),
    p_value = unname(treat_row["Pr(>|t|)"]),
    conf_low = estimate - stats::qnorm(0.975) * std_error,
    conf_high = estimate + stats::qnorm(0.975) * std_error,
    n_obs = stats::nobs(model),
    formula_rhs = paste(rhs_terms, collapse = " + ")
  )
}

compute_ivb_against_safe <- function(data, control_var, control_label) {
  safe_terms <- c("treat_panam_sucre", "i(year, pob_1990)")
  sample_data <- data |>
    dplyr::filter(
      stats::complete.cases(
        dplyr::select(
          data,
          dplyr::all_of(c(
            "hrate_combo", "treat_panam_sucre", "year",
            "ci_mun", "pob_1990", control_var
          ))
        )
      )
    )

  safe_model <- feols(
    fml = build_fe_formula(
      lhs = "hrate_combo",
      rhs_terms = safe_terms,
      fe_terms = c("ci_mun", "year")
    ),
    data = sample_data,
    vcov = ~ci_mun
  )

  long_model <- feols(
    fml = build_fe_formula(
      lhs = "hrate_combo",
      rhs_terms = c(safe_terms, control_var),
      fe_terms = c("ci_mun", "year")
    ),
    data = sample_data,
    vcov = ~ci_mun
  )

  aux_model <- feols(
    fml = build_fe_formula(
      lhs = control_var,
      rhs_terms = safe_terms,
      fe_terms = c("ci_mun", "year")
    ),
    data = sample_data,
    vcov = ~ci_mun
  )

  beta_short <- unname(stats::coef(safe_model)[["treat_panam_sucre"]])
  beta_long <- unname(stats::coef(long_model)[["treat_panam_sucre"]])
  theta <- unname(stats::coef(long_model)[[control_var]])
  pi_coef <- unname(stats::coef(aux_model)[["treat_panam_sucre"]])

  dplyr::tibble(
    control_var = control_var,
    control_label = control_label,
    beta_safe = beta_short,
    beta_long = beta_long,
    theta = theta,
    pi = pi_coef,
    ivb_formula = -theta * pi_coef,
    ivb_direct = beta_long - beta_short,
    check = (-theta * pi_coef) - (beta_long - beta_short),
    aux_n_obs = stats::nobs(aux_model),
    long_n_obs = stats::nobs(long_model)
  )
}

dt <- haven::read_dta(data_path) |>
  dplyr::mutate(
    ci_mun = as.integer(ci_mun),
    year = as.integer(year),
    expected_treat = as.integer(panam_sucre == 1 & year >= 1989),
    treat_match = expected_treat == treat_panam_sucre
  )

format_check_value <- function(x) {
  if (is.logical(x)) {
    ifelse(isTRUE(x), "TRUE", "FALSE")
  } else {
    as.character(x)
  }
}

core_vars <- c(
  "ci_mun", "year", "panam_sucre", "treat_panam_sucre", "pob_cgr",
  "ln_pob", "pob_1990", "hrate_combo", "pol_local", "alc_oficialista"
)

panel_summary <- dplyr::tibble(
  n_obs = nrow(dt),
  n_municipios = dplyr::n_distinct(dt$ci_mun),
  n_treated = dplyr::n_distinct(dt$ci_mun[dt$panam_sucre == 1]),
  n_control = dplyr::n_distinct(dt$ci_mun[dt$panam_sucre == 0]),
  year_min = min(dt$year, na.rm = TRUE),
  year_max = max(dt$year, na.rm = TRUE),
  treat_share_obs = mean(dt$panam_sucre == 1, na.rm = TRUE)
)

varying_status <- dt |>
  dplyr::group_by(ci_mun) |>
  dplyr::summarise(
    panam_values = dplyr::n_distinct(panam_sucre),
    .groups = "drop"
  )

validation_checks <- dplyr::tribble(
  ~check, ~value, ~status,
  "Duplicatas município-ano", sum(duplicated(dplyr::select(dt, ci_mun, year))), "OK",
  "Mínimo de população interpolada", min(dt$pob_cgr, na.rm = TRUE), "OK",
  "Valores ausentes nas variáveis centrais", sum(!stats::complete.cases(dplyr::select(dt, dplyr::all_of(core_vars)))), "OK",
  "Tratamento coincide com panam_sucre x pós-1989", all(dt$treat_match), ifelse(all(dt$treat_match), "OK", "FALHA"),
  "Municípios com status panam_sucre variável no tempo", sum(varying_status$panam_values > 1), "OK"
) |>
  dplyr::mutate(
    value = vapply(value, format_check_value, character(1)),
    status = dplyr::case_when(
      check == "Duplicatas município-ano" & value != "0" ~ "FALHA",
      check == "Mínimo de população interpolada" & as.numeric(value) <= 0 ~ "FALHA",
      check == "Valores ausentes nas variáveis centrais" & value != "0" ~ "ALERTA",
      TRUE ~ status
    )
  )

specs <- dplyr::bind_rows(
  estimate_spec(
    data = dt,
    spec_id = "omit",
    spec_label = "Sem ajuste adicional",
    rhs_terms = c("treat_panam_sucre")
  ),
  estimate_spec(
    data = dt,
    spec_id = "safe",
    spec_label = "Bloco safe: ano x população de 1990",
    rhs_terms = c("treat_panam_sucre", "i(year, pob_1990)")
  ),
  estimate_spec(
    data = dt,
    spec_id = "safe_ln_pob",
    spec_label = "Safe + log da população municipal",
    rhs_terms = c("treat_panam_sucre", "ln_pob", "i(year, pob_1990)")
  ),
  estimate_spec(
    data = dt,
    spec_id = "safe_pol_local",
    spec_label = "Safe + polícia municipal",
    rhs_terms = c("treat_panam_sucre", "pol_local", "i(year, pob_1990)")
  ),
  estimate_spec(
    data = dt,
    spec_id = "safe_alc_oficialista",
    spec_label = "Safe + prefeito governista",
    rhs_terms = c("treat_panam_sucre", "alc_oficialista", "i(year, pob_1990)")
  ),
  estimate_spec(
    data = dt,
    spec_id = "safe_ln_pob_pol_local",
    spec_label = "Safe + log da população + polícia municipal",
    rhs_terms = c("treat_panam_sucre", "ln_pob", "pol_local", "i(year, pob_1990)")
  ),
  estimate_spec(
    data = dt,
    spec_id = "safe_all_controls",
    spec_label = "Safe + log da população + polícia + prefeito",
    rhs_terms = c(
      "treat_panam_sucre", "ln_pob", "pol_local",
      "alc_oficialista", "i(year, pob_1990)"
    )
  )
) |>
  dplyr::mutate(
    published_benchmark = dplyr::case_when(
      spec_id == "omit" ~ 16,
      spec_id == "safe_ln_pob" ~ 6.8,
      TRUE ~ NA_real_
    ),
    benchmark_gap = estimate - published_benchmark
  )

beta_omit <- specs$estimate[specs$spec_id == "omit"]
beta_safe <- specs$estimate[specs$spec_id == "safe"]

specs <- specs |>
  dplyr::mutate(
    delta_vs_safe = estimate - beta_safe,
    delta_vs_omit = estimate - beta_omit
  )

ivb_diagnostics <- dplyr::bind_rows(
  compute_ivb_against_safe(
    data = dt,
    control_var = "ln_pob",
    control_label = "Log da população municipal"
  ),
  compute_ivb_against_safe(
    data = dt,
    control_var = "pol_local",
    control_label = "Presença de polícia municipal"
  ),
  compute_ivb_against_safe(
    data = dt,
    control_var = "alc_oficialista",
    control_label = "Prefeito governista"
  )
) |>
  dplyr::mutate(
    ovb_safe = beta_omit - beta_safe,
    abs_ivb_direct = abs(ivb_direct)
  )

readr::write_csv(specs, spec_output_path)
readr::write_csv(ivb_diagnostics, ivb_output_path)
readr::write_csv(validation_checks, validation_output_path)
readr::write_csv(panel_summary, summary_output_path)

cat("Resultados salvos em:\n")
cat(" -", spec_output_path, "\n")
cat(" -", ivb_output_path, "\n")
cat(" -", validation_output_path, "\n")
cat(" -", summary_output_path, "\n")
