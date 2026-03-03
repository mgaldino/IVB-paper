# Template de features para calibração do protocolo IVB.
# Uso:
#   Rscript ivb_risk_protocol/R/00_make_features_template.R

suppressPackageStartupMessages({
  library(readr)
})

out_file <- "ivb_risk_protocol/data_processed/protocol_features.csv"

template <- data.frame(
  scenario_id = character(),
  unsafe_true = integer(),
  r_deriv = numeric(),
  q95_gain = numeric(),
  s_tail = numeric(),
  stringsAsFactors = FALSE
)

readr::write_csv(template, out_file)
cat(sprintf("Template criado em: %s\n", out_file))
