#### Replication of Claassen (2020) AJPS — Table 1 Models 1.1 & 1.2
#### + IVB (Included Variable Bias) decomposition
####
#### Model 1.1 (pooled OLS):
####   Libdem_VD ~ Libdem_m1 + Libdem_m2 + SupDem_m1 + controls
####
#### Model 1.2 (pooled OLS, democracies/autocracies split):
####   Libdem_VD ~ Libdem_m1 + Libdem_m2 + SupDem_democ_m1 + SupDem_autoc_m1 + controls

library(fixest)
library(dplyr)

# Source IVB utilities
source("ivb_utils.R")

# ── 1. Load data ─────────────────────────────────────────────────────────────

dat <- read.delim(
  "candidate_papers/claassen_2020/Support_democracy_ajps_correct.tab",
  stringsAsFactors = FALSE
)

cat("Dimensions:", nrow(dat), "x", ncol(dat), "\n")
cat("Countries:", length(unique(dat$Country)), "\n")
cat("Years:", range(dat$Year), "\n")

# ── 2. Replicate Model 1.1 — Pooled OLS (Table 1, column 1) ─────────────────
# Original uses plm::lag on the fly. The dataset has pre-computed lags:
#   Libdem_m1, Libdem_m2, SupDem_m1, lnGDP_imp_m1, GDP_imp_grth_m1,
#   Libdem_regUN_m1, Pr_Muslim, Res_cp_WDI_di_m1

# Note: Claassen's code uses plm::lag(Pr_Muslim, 1) but Pr_Muslim is
# time-invariant (1990 value), so lag = same value. We use Pr_Muslim directly.

mod1_ols <- feols(
  Libdem_VD ~ Libdem_m1 + Libdem_m2 + SupDem_m1 +
    lnGDP_imp_m1 + GDP_imp_grth_m1 + Libdem_regUN_m1 +
    Pr_Muslim + Res_cp_WDI_di_m1,
  data = dat, vcov = "iid"
)

cat("\n=== Model 1.1: Pooled OLS (replication) ===\n")
cat("N =", mod1_ols$nobs, "\n")
print(summary(mod1_ols))

# Reference values from Table 1, Model 1.1:
# Democracy_{t-1}: 1.141*  Democracy_{t-2}: -0.163*  Support_{t-1}: 0.267*

# ── 3. Replicate Model 1.1 with FE ──────────────────────────────────────────
# Dynamic FE (Eq. 2) — same specification + country FE
# Note: Pr_Muslim is time-invariant → absorbed by FE

mod1_fe <- feols(
  Libdem_VD ~ Libdem_m1 + Libdem_m2 + SupDem_m1 +
    lnGDP_imp_m1 + GDP_imp_grth_m1 + Libdem_regUN_m1 +
    Res_cp_WDI_di_m1 | Country,
  data = dat, vcov = "iid"
)

cat("\n=== Model 1.1 with Country FE (dynamic FE) ===\n")
cat("N =", mod1_fe$nobs, "\n")
print(summary(mod1_fe))

# ── 4. IVB decomposition — Pooled OLS ───────────────────────────────────────
# Treatment: SupDem_m1
# Candidate colliders: each control variable, one at a time
# Short model = without candidate collider z
# Long model = with candidate collider z
# Identity: beta_long - beta_short = -theta * pi

cat("\n\n", strrep("=", 70), "\n")
cat("IVB DECOMPOSITION — POOLED OLS\n")
cat(strrep("=", 70), "\n")

# Full set of controls in the original model
all_controls <- c("lnGDP_imp_m1", "GDP_imp_grth_m1", "Libdem_regUN_m1",
                   "Pr_Muslim", "Res_cp_WDI_di_m1")

# LDV terms (always in w — these are part of the ADL structure, not "controls")
ldv_terms <- c("Libdem_m1", "Libdem_m2")

# For each control, treat it as a potential collider z
# Short model: y ~ d + ldv + remaining_controls
# Long model: y ~ d + ldv + remaining_controls + z

ivb_ols_results <- list()

for (z_var in all_controls) {
  w_vars <- c(ldv_terms, setdiff(all_controls, z_var))

  res <- compute_ivb_multi(
    data = dat,
    y = "Libdem_VD",
    d_vars = "SupDem_m1",
    z = z_var,
    w = w_vars,
    fe = character(),  # no FE for pooled OLS
    vcov = "iid"
  )

  ivb_ols_results[[z_var]] <- res

  cat("\n--- Collider candidate: ", z_var, " ---\n")
  cat("N =", res$sample_n, "\n")
  cat("theta (coef of z in long model):", round(res$theta, 6), "\n")
  num_cols <- setdiff(names(res$results), "term")
  tmp <- res$results
  tmp[num_cols] <- lapply(tmp[num_cols], round, 6)
  print(tmp)
}

# Summary table
cat("\n\n=== SUMMARY: IVB on Support_{t-1} by candidate collider (Pooled OLS) ===\n")
summary_ols <- do.call(rbind, lapply(names(ivb_ols_results), function(z_var) {
  r <- ivb_ols_results[[z_var]]$results
  data.frame(
    collider = z_var,
    beta_short = r$beta_short,
    beta_long = r$beta_long,
    theta = r$theta,
    pi = r$pi,
    ivb = r$ivb_formula,
    check = r$diff_check,
    stringsAsFactors = FALSE
  )
}))
num_cols <- setdiff(names(summary_ols), "collider")
summary_ols[num_cols] <- lapply(summary_ols[num_cols], round, 6)
print(summary_ols)

# ── 5. IVB decomposition — Country FE ──────────────────────────────────────
# Same exercise but with Country FE
# Note: Pr_Muslim is time-invariant → absorbed by Country FE → excluded

cat("\n\n", strrep("=", 70), "\n")
cat("IVB DECOMPOSITION — COUNTRY FE\n")
cat(strrep("=", 70), "\n")

fe_controls <- c("lnGDP_imp_m1", "GDP_imp_grth_m1", "Libdem_regUN_m1",
                  "Res_cp_WDI_di_m1")

ivb_fe_results <- list()

for (z_var in fe_controls) {
  w_vars <- c(ldv_terms, setdiff(fe_controls, z_var))

  res <- compute_ivb_multi(
    data = dat,
    y = "Libdem_VD",
    d_vars = "SupDem_m1",
    z = z_var,
    w = w_vars,
    fe = "Country",
    vcov = "iid"
  )

  ivb_fe_results[[z_var]] <- res

  cat("\n--- Collider candidate: ", z_var, " ---\n")
  cat("N =", res$sample_n, "\n")
  cat("theta (coef of z in long model):", round(res$theta, 6), "\n")
  num_cols <- setdiff(names(res$results), "term")
  tmp <- res$results
  tmp[num_cols] <- lapply(tmp[num_cols], round, 6)
  print(tmp)
}

# Summary table
cat("\n\n=== SUMMARY: IVB on Support_{t-1} by candidate collider (Country FE) ===\n")
summary_fe <- do.call(rbind, lapply(names(ivb_fe_results), function(z_var) {
  r <- ivb_fe_results[[z_var]]$results
  data.frame(
    collider = z_var,
    beta_short = r$beta_short,
    beta_long = r$beta_long,
    theta = r$theta,
    pi = r$pi,
    ivb = r$ivb_formula,
    check = r$diff_check,
    stringsAsFactors = FALSE
  )
}))
num_cols <- setdiff(names(summary_fe), "collider")
summary_fe[num_cols] <- lapply(summary_fe[num_cols], round, 6)
print(summary_fe)

cat("\n\nDone.\n")
