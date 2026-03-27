##############################################################################
# Step 4 — IVB Diagnostic: Applied Illustration (RDD-Trade)
#
# Applies the IVB decomposition (IVB = CE + RE) to the RDD-Trade paper data.
# Problematic covariate: CA_GDP (current account deficit as % of GDP).
#
# Three analyses:
#   1. CA_GDP only (single covariate, clean FWL identity)
#   2. All covariates (multi-covariate FWL identity)
#   3. Marginal CA_GDP (practical: add CA_GDP to existing specification)
#
# Dependencies: synthdid, data.table, fixest, targets
# Data source: RDD-Trade targets store
##############################################################################

library(synthdid)
library(data.table)
library(fixest)
library(tidyverse)
library(targets)

set.seed(42)

# --- Paths ---
rdd_trade_dir <- "/Users/manoelgaldino/Documents/DCP/Papers/RDD Trade/red_trade"
targets_store <- file.path(rdd_trade_dir, "_targets")
output_dir    <- "scripts"

# --- Source RDD-Trade helper functions ---
# cov_matrix() and other data prep functions
source(file.path(rdd_trade_dir, "scripts/functions.R"))

##############################################################################
# 1. Load and prepare data (reproduces simple_fit() data pipeline)
##############################################################################

cat("=== Loading RDD-Trade data ===\n")
synth_data <- tar_read("synth_data", store = targets_store)

time_treatment <- 2008
time_end       <- 2016

# Filter and create treatment indicator
data_prep <- synth_data %>%
  dplyr::filter(year < time_end) %>%
  mutate(treatment = ifelse(iso3c == "BRA" & year > time_treatment, 1, 0))

# Sort: controls first (alphabetical), then treated (BRA) last
data_prep <- data_prep %>%
  mutate(.unit_treated = as.integer(iso3c == "BRA")) %>%
  arrange(.unit_treated, iso3c, year) %>%
  dplyr::select(-.unit_treated)

# Create covariate array (all covariates)
X_all <- cov_matrix(data_prep)

# Identify covariate names and CA_GDP index
cov_cols <- data_prep %>%
  dplyr::select(year, iso3c, gpi, perc_trade_with_us, perc_trade_with_china,
                pci_cur, exachange_rate, distance_us, us_power_gap, hog_left,
                CA_GDP, govdef_GDP,
                any_of(c("inst_parliamentary", "inst_military_exec",
                         "us_trade_agreement"))) %>%
  dplyr::select(-year, -iso3c) %>%
  colnames()

ca_idx <- which(cov_cols == "CA_GDP")
stopifnot("Covariate count mismatch between cov_cols and X_all" =
            length(cov_cols) == dim(X_all)[3])
stopifnot("CA_GDP not found in covariate list" =
            length(ca_idx) == 1 && ca_idx > 0)
cat("Covariate names:", paste(cov_cols, collapse = ", "), "\n")
cat("CA_GDP is covariate index:", ca_idx, "of", length(cov_cols), "\n")

# Create covariate subsets
X_ca_only <- X_all[, , ca_idx, drop = FALSE]  # N x T x 1
X_no_ca   <- X_all[, , -ca_idx, drop = FALSE] # N x T x (K-1)

# Create panel matrices for synthdid
data_panel <- data_prep %>%
  mutate(treatment = as.integer(treatment),
         year = as.integer(year),
         iso3c = as.factor(iso3c),
         Y = abs_distance_china) %>%
  dplyr::select(iso3c, year, Y, treatment) %>%
  as.data.frame()

setup <- panel.matrices(data_panel)
Y  <- setup$Y
N0 <- setup$N0
T0 <- setup$T0
N  <- nrow(Y)
TT <- ncol(Y)
N1 <- N - N0
T1 <- TT - T0

cat(sprintf("Panel: N=%d (N0=%d, N1=%d), T=%d (T0=%d, T1=%d)\n",
            N, N0, N1, TT, T0, T1))
cat(sprintf("Treated unit: %s\n",
            rownames(Y)[N0 + 1]))

##############################################################################
# 2. Pre-diagnostic: R² of CA_GDP ~ unit FE + time FE
##############################################################################

cat("\n=== Pre-diagnostic: R² of CA_GDP ===\n")

# Extract CA_GDP as vector (long format)
ca_vec <- as.vector(t(X_all[, , ca_idx]))
dt_prediag <- data.table(
  CA_GDP = ca_vec,
  unit   = factor(rep(seq_len(N), each = TT)),
  time   = factor(rep(seq_len(TT), times = N))
)

fe_fit <- feols(CA_GDP ~ 1 | unit + time, data = dt_prediag)
r2_ca  <- fixest::r2(fe_fit, type = "ar2")

cat(sprintf("R² (adjusted) of CA_GDP ~ unit FE + time FE: %.4f\n", r2_ca))
if (r2_ca > 0.90) {
  cat("  -> High R²: RE expected to be SMALL (Proposition 2)\n")
} else {
  cat("  -> Moderate/low R²: RE may be SUBSTANTIAL\n")
}

##############################################################################
# 3. Helper: IVB decomposition function
##############################################################################

ivb_decompose <- function(Y, N0, T0, X_short = NULL, X_long,
                          label = "Analysis") {
  N  <- nrow(Y)
  TT <- ncol(Y)
  N1 <- N - N0
  T1 <- TT - T0

  cat(sprintf("\n=== %s ===\n", label))

  # (a) Short model
  if (is.null(X_short)) {
    fit_short <- synthdid_estimate(Y, N0, T0)
  } else {
    fit_short <- synthdid_estimate(Y, N0, T0, X = X_short)
  }
  tau_short    <- as.numeric(fit_short)
  w_short      <- attr(fit_short, "weights")
  omega_short  <- w_short$omega
  lambda_short <- w_short$lambda

  # (b) Long model (with Z, weights re-optimized)
  fit_long  <- synthdid_estimate(Y, N0, T0, X = X_long)
  tau_long  <- as.numeric(fit_long)
  w_long    <- attr(fit_long, "weights")
  beta_long <- as.numeric(w_long$beta)

  # (c) Hybrid model (with Z, weights fixed from short)
  fit_hybrid <- synthdid_estimate(
    Y, N0, T0, X = X_long,
    weights      = list(omega = omega_short, lambda = lambda_short),
    update.omega = FALSE, update.lambda = FALSE
  )
  tau_hybrid  <- as.numeric(fit_hybrid)
  w_hybrid    <- attr(fit_hybrid, "weights")
  beta_hybrid <- as.numeric(w_hybrid$beta)

  # --- Decomposition ---
  IVB <- tau_long - tau_short
  CE  <- tau_hybrid - tau_short
  RE  <- tau_long - tau_hybrid

  # --- FWL-like identity (CE = -Σ β_h,k × τ_Z,k) ---
  omega_ext  <- c(-omega_short, rep(1 / N1, N1))
  lambda_ext <- c(-lambda_short, rep(1 / T1, T1))

  K <- dim(X_long)[3]
  # Extract covariate-specific SDiD double-differences
  # Only meaningful when X_short is NULL (no-covariate baseline)
  tau_Z_vec <- numeric(K)
  for (k in seq_len(K)) {
    tau_Z_vec[k] <- as.numeric(t(omega_ext) %*% X_long[, , k] %*% lambda_ext)
  }

  CE_fwl <- -sum(beta_hybrid * tau_Z_vec)

  # --- Weight comparison ---
  omega_long  <- w_long$omega
  lambda_long <- w_long$lambda
  max_d_omega  <- max(abs(omega_long - omega_short))
  max_d_lambda <- max(abs(lambda_long - lambda_short))

  # --- Print results ---
  cat(sprintf("  tau_short  = %.6f\n", tau_short))
  cat(sprintf("  tau_long   = %.6f\n", tau_long))
  cat(sprintf("  tau_hybrid = %.6f\n", tau_hybrid))
  cat(sprintf("  IVB = %.6f\n", IVB))
  ce_share <- if (abs(IVB) > 1e-12) 100 * CE / IVB else NA_real_
  re_share <- if (abs(IVB) > 1e-12) 100 * RE / IVB else NA_real_
  cat(sprintf("  CE  = %.6f (%.1f%% of IVB)\n", CE, ce_share))
  cat(sprintf("  RE  = %.6f (%.1f%% of IVB)\n", RE, re_share))

  # FWL check only valid when short model has no covariates
  if (is.null(X_short)) {
    fwl_err <- abs(CE - CE_fwl)
    cat(sprintf("  CE (FWL)   = %.6f  (error = %.2e)  %s\n",
                CE_fwl, fwl_err, ifelse(fwl_err < 1e-8, "PASS", "CHECK")))
  } else {
    cat("  CE (FWL): not applicable (short model has covariates)\n")
  }

  decomp_err <- abs(IVB - CE - RE)
  cat(sprintf("  Decomp check: |IVB - CE - RE| = %.2e  %s\n",
              decomp_err, ifelse(decomp_err < 1e-8, "PASS", "FAIL")))
  cat(sprintf("  Weight change: max|delta_omega| = %.6f, max|delta_lambda| = %.6f\n",
              max_d_omega, max_d_lambda))

  # --- Return results ---
  list(
    tau_short   = tau_short,
    tau_long    = tau_long,
    tau_hybrid  = tau_hybrid,
    IVB         = IVB,
    CE          = CE,
    RE          = RE,
    CE_fwl      = CE_fwl,
    beta_h      = beta_hybrid,
    tau_Z       = tau_Z_vec,
    max_d_omega = max_d_omega,
    max_d_lambda = max_d_lambda,
    has_fwl     = is.null(X_short)
  )
}

##############################################################################
# 4. Analysis 1: CA_GDP only (single covariate, clean FWL)
##############################################################################

res1 <- ivb_decompose(
  Y, N0, T0,
  X_short = NULL,
  X_long  = X_ca_only,
  label   = "Analysis 1: CA_GDP only"
)

cat(sprintf("\n  Interpretation:\n"))
cat(sprintf("    beta_h (CA_GDP -> Y) = %.6f\n", res1$beta_h))
cat(sprintf("    tau_Z  (D -> CA_GDP) = %.6f\n", res1$tau_Z))
if (res1$beta_h * res1$tau_Z > 0) {
  cat("    Sign: beta_h * tau_Z > 0 => including CA_GDP REDUCES tau_hat\n")
} else {
  cat("    Sign: beta_h * tau_Z < 0 => including CA_GDP INCREASES tau_hat\n")
}

##############################################################################
# 5. Analysis 2: All covariates (multi-covariate FWL)
##############################################################################

res2 <- ivb_decompose(
  Y, N0, T0,
  X_short = NULL,
  X_long  = X_all,
  label   = "Analysis 2: All covariates"
)

# Per-covariate CE contributions
cat("\n  Per-covariate CE contributions:\n")
for (k in seq_along(cov_cols)) {
  contrib_k <- -res2$beta_h[k] * res2$tau_Z[k]
  cat(sprintf("    %-25s: beta_h = %8.5f, tau_Z = %8.5f, CE_k = %8.5f\n",
              cov_cols[k], res2$beta_h[k], res2$tau_Z[k], contrib_k))
}
cat(sprintf("    %-25s: %36s %8.5f\n", "SUM (= CE)", "", res2$CE))

##############################################################################
# 6. Analysis 3: Marginal CA_GDP (practical question)
##############################################################################

# Sanity check: tau_short must be identical in Analyses 1 and 2 (same Y, N0, T0, no covariates)
stopifnot("tau_short differs between Analysis 1 and 2" =
            abs(res1$tau_short - res2$tau_short) < 1e-10)

res3 <- ivb_decompose(
  Y, N0, T0,
  X_short = X_no_ca,
  X_long  = X_all,
  label   = "Analysis 3: Marginal CA_GDP"
)

##############################################################################
# 7. Summary table
##############################################################################

cat("\n\n========== SUMMARY TABLE ==========\n\n")
cat(sprintf("%-30s %12s %12s %12s\n",
            "", "CA_GDP only", "All covs", "Marginal"))
cat(sprintf("%-30s %12s %12s %12s\n",
            "", "(Analysis 1)", "(Analysis 2)", "(Analysis 3)"))
cat(paste(rep("-", 66), collapse = ""), "\n")
cat(sprintf("%-30s %12.4f %12.4f %12.4f\n",
            "tau_short", res1$tau_short, res2$tau_short, res3$tau_short))
cat(sprintf("%-30s %12.4f %12.4f %12.4f\n",
            "tau_long", res1$tau_long, res2$tau_long, res3$tau_long))
cat(sprintf("%-30s %12.4f %12.4f %12.4f\n",
            "tau_hybrid", res1$tau_hybrid, res2$tau_hybrid, res3$tau_hybrid))
cat(paste(rep("-", 66), collapse = ""), "\n")
cat(sprintf("%-30s %12.4f %12.4f %12.4f\n",
            "IVB", res1$IVB, res2$IVB, res3$IVB))
cat(sprintf("%-30s %12.4f %12.4f %12.4f\n",
            "CE", res1$CE, res2$CE, res3$CE))
cat(sprintf("%-30s %12.4f %12.4f %12.4f\n",
            "RE", res1$RE, res2$RE, res3$RE))
safe_share <- function(x, y) if (abs(y) > 1e-12) 100 * x / y else NA_real_
cat(sprintf("%-30s %11.1f%% %11.1f%% %11.1f%%\n",
            "CE share",
            safe_share(res1$CE, res1$IVB),
            safe_share(res2$CE, res2$IVB),
            safe_share(res3$CE, res3$IVB)))
cat(paste(rep("-", 66), collapse = ""), "\n")
cat(sprintf("%-30s %12.4f %12.4f %12s\n",
            "beta_h (CA_GDP)", res1$beta_h[1], res2$beta_h[ca_idx], "--"))
cat(sprintf("%-30s %12.4f %12.4f %12s\n",
            "tau_Z (CA_GDP)", res1$tau_Z[1], res2$tau_Z[ca_idx], "--"))
cat(sprintf("%-30s %12.6f %12.6f %12.6f\n",
            "max|delta_omega|",
            res1$max_d_omega, res2$max_d_omega, res3$max_d_omega))
cat(sprintf("%-30s %12.6f %12.6f %12.6f\n",
            "max|delta_lambda|",
            res1$max_d_lambda, res2$max_d_lambda, res3$max_d_lambda))
cat(sprintf("\nR2 of CA_GDP ~ unit FE + time FE: %.4f\n", r2_ca))

##############################################################################
# 8. Save results
##############################################################################

results_dt <- data.table(
  analysis   = c("CA_GDP_only", "all_covariates", "marginal_CA_GDP"),
  tau_short  = c(res1$tau_short, res2$tau_short, res3$tau_short),
  tau_long   = c(res1$tau_long, res2$tau_long, res3$tau_long),
  tau_hybrid = c(res1$tau_hybrid, res2$tau_hybrid, res3$tau_hybrid),
  IVB        = c(res1$IVB, res2$IVB, res3$IVB),
  CE         = c(res1$CE, res2$CE, res3$CE),
  RE         = c(res1$RE, res2$RE, res3$RE),
  CE_share   = c(safe_share(res1$CE, res1$IVB) / 100,
                 safe_share(res2$CE, res2$IVB) / 100,
                 safe_share(res3$CE, res3$IVB) / 100),
  max_d_omega  = c(res1$max_d_omega, res2$max_d_omega, res3$max_d_omega),
  max_d_lambda = c(res1$max_d_lambda, res2$max_d_lambda, res3$max_d_lambda),
  R2_CA_GDP  = r2_ca
)

fwrite(results_dt, file.path(output_dir, "step4_rdd_trade_results.csv"))
cat("\nResults saved to scripts/step4_rdd_trade_results.csv\n")

# Per-covariate contributions (Analysis 2)
contrib_dt <- data.table(
  covariate = cov_cols,
  beta_h    = res2$beta_h,
  tau_Z     = res2$tau_Z,
  CE_k      = -res2$beta_h * res2$tau_Z
)
fwrite(contrib_dt, file.path(output_dir, "step4_per_covariate_contributions.csv"))
cat("Per-covariate contributions saved to scripts/step4_per_covariate_contributions.csv\n")

##############################################################################
# 9. Session info
##############################################################################

writeLines(capture.output(sessionInfo()),
           file.path(output_dir, "step4_rdd_trade_sessioninfo.txt"))
cat("Session info saved.\n")
