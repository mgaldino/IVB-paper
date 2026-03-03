# Calibração de thresholds do protocolo IVB (regra 2+1).
# Uso:
#   Rscript ivb_risk_protocol/R/01_calibrate_thresholds.R
#
# Entrada:
#   ivb_risk_protocol/data_processed/protocol_features.csv
#
# Saídas:
#   ivb_risk_protocol/outputs/threshold_candidates.csv
#   ivb_risk_protocol/outputs/threshold_selected.csv

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(tidyr)
})

in_file <- "ivb_risk_protocol/data_processed/protocol_features.csv"
out_candidates <- "ivb_risk_protocol/outputs/threshold_candidates.csv"
out_selected <- "ivb_risk_protocol/outputs/threshold_selected.csv"

if (!file.exists(in_file)) {
  stop(sprintf("Arquivo não encontrado: %s", in_file))
}

raw_df <- readr::read_csv(in_file, show_col_types = FALSE)

required_cols <- c("scenario_id", "unsafe_true", "r_deriv", "q95_gain", "s_tail")
missing_cols <- setdiff(required_cols, names(raw_df))
if (length(missing_cols) > 0) {
  stop(sprintf(
    "Colunas obrigatórias ausentes: %s",
    paste(missing_cols, collapse = ", ")
  ))
}

df <- raw_df %>%
  dplyr::select(
    scenario_id,
    unsafe_true,
    r_deriv,
    q95_gain,
    s_tail
  ) %>%
  dplyr::mutate(
    unsafe_true = as.integer(unsafe_true)
  )

if (any(!df$unsafe_true %in% c(0L, 1L))) {
  stop("A coluna unsafe_true deve conter apenas 0/1.")
}

if (nrow(df) == 0) {
  stop("Arquivo de features está vazio.")
}

if (any(is.na(df))) {
  stop("Há valores NA nas colunas obrigatórias.")
}

if (any(df$r_deriv < 0 | df$q95_gain < 0 | df$s_tail < 0)) {
  stop("Métricas devem ser não negativas: r_deriv, q95_gain, s_tail.")
}

target_sensitivity <- 0.85

q_grid <- seq(0.50, 0.99, by = 0.02)
t1_vals <- unique(as.numeric(stats::quantile(df$r_deriv, probs = q_grid, na.rm = TRUE)))
t2_vals <- unique(as.numeric(stats::quantile(df$q95_gain, probs = q_grid, na.rm = TRUE)))
t3_vals <- unique(as.numeric(stats::quantile(df$s_tail, probs = q_grid, na.rm = TRUE)))

grid <- tidyr::expand_grid(
  t1 = t1_vals,
  t2 = t2_vals,
  t3 = t3_vals
)

eval_one <- function(t1, t2, t3, data) {
  pred_unsafe <- as.integer(
    data$r_deriv > t1 |
      data$q95_gain > t2 |
      data$s_tail > t3
  )

  tp <- sum(pred_unsafe == 1L & data$unsafe_true == 1L)
  fn <- sum(pred_unsafe == 0L & data$unsafe_true == 1L)
  tn <- sum(pred_unsafe == 0L & data$unsafe_true == 0L)
  fp <- sum(pred_unsafe == 1L & data$unsafe_true == 0L)

  sens <- if ((tp + fn) > 0) tp / (tp + fn) else NA_real_
  spec <- if ((tn + fp) > 0) tn / (tn + fp) else NA_real_
  bal_acc <- mean(c(sens, spec), na.rm = TRUE)

  c(
    sensitivity = sens,
    specificity = spec,
    balanced_accuracy = bal_acc,
    tp = tp,
    fn = fn,
    tn = tn,
    fp = fp
  )
}

res <- apply(grid, 1, function(x) eval_one(x[["t1"]], x[["t2"]], x[["t3"]], df))
res <- as.data.frame(t(res))

out <- dplyr::bind_cols(grid, res) %>%
  dplyr::mutate(
    sensitivity = as.numeric(sensitivity),
    specificity = as.numeric(specificity),
    balanced_accuracy = as.numeric(balanced_accuracy),
    tp = as.integer(tp),
    fn = as.integer(fn),
    tn = as.integer(tn),
    fp = as.integer(fp),
    target_sensitivity = target_sensitivity,
    passes_power = sensitivity >= target_sensitivity
  ) %>%
  dplyr::arrange(
    dplyr::desc(passes_power),
    dplyr::desc(specificity),
    dplyr::desc(balanced_accuracy),
    dplyr::desc(sensitivity)
  )

readr::write_csv(out, out_candidates)

selected <- out %>%
  dplyr::filter(passes_power) %>%
  dplyr::slice_head(n = 1)

if (nrow(selected) == 0) {
  selected <- out %>% dplyr::slice_head(n = 1)
}

readr::write_csv(selected, out_selected)

cat(sprintf("Candidatos salvos em: %s\n", out_candidates))
cat(sprintf("Threshold selecionado salvo em: %s\n", out_selected))
cat("Resumo do threshold selecionado:\n")
print(selected)
