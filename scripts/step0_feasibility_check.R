# =============================================================================
# Step 0 — Feasibility check: hybrid estimator for SDiD
# =============================================================================
# Goal: Verify that the IVB decomposition IVB = CE + RE is computationally
# feasible for SDiD by constructing the hybrid estimator.
#
# The hybrid estimator uses weights (omega, lambda) from the no-Z model but
# includes Z in the regression. synthdid_estimate() supports this natively
# via the `weights` parameter with update.omega = FALSE, update.lambda = FALSE.
#
# Decomposition:
#   IVB = tau_long - tau_short
#   CE  = tau_hybrid - tau_short   (coefficient effect: same weights, Z added)
#   RE  = tau_long - tau_hybrid    (reweighting effect: weight re-optimization)
#   IVB = CE + RE                  (must hold exactly by construction)
#
# Checks:
#   [1] Decomposition identity: IVB = CE + RE (algebraic, always holds)
#   [2] SDiD FWL-like identity: CE = -beta_h * tau_Z (structural, from source)
#   [3] Full-panel WLS FWL: CE_wls = -theta_wls * pi_wls (tautological for WLS)
#   [4] WLS vs synthdid comparison (may differ — beta estimated differently)
#   [5] RE != 0 (weights changed by including Z)
#   [6] TWFE benchmark (SDiD weights): RE = 0 (OLS weights fixed)
#   [7] TWFE benchmark (uniform weights): RE = 0 + comparison with SDiD IVB
#
# Date: 2026-03-25
# Project: IVB-SDiD Extension (feature/ivb-sdid-factor-models)
# Run from project root (setwd to IVB-paper/ or worktree root)
# =============================================================================

library(synthdid)
library(fixest)
library(data.table)

set.seed(42)

# ---- 1. DGP: simple panel with treatment D and covariate Z ----
# Z is caused by D (post-treatment channel) and by Y_lag (collider channel).
# Z also affects Y (delta != 0), so including/excluding Z changes the estimate.

N  <- 40        # total units
N0 <- 30        # control units
N1 <- N - N0    # treated units
TT <- 20        # total periods
T0 <- 15        # pre-treatment periods
T1 <- TT - T0   # post-treatment periods

# Structural parameters
beta     <- 1.0   # D -> Y (true ATT)
delta    <- 0.5   # Z -> Y (makes Z relevant in the outcome equation)
gamma_D  <- 0.8   # D -> Z (post-treatment channel)
gamma_Yl <- 0.3   # Y_{t-1} -> Z (collider channel)

# Fixed effects
mu_i <- rnorm(N, 0, 1)       # unit FE
xi_t <- rnorm(TT, 0, 0.5)    # time FE

# Treatment indicator: units (N0+1):N treated after period T0
D <- matrix(0, nrow = N, ncol = TT)
D[(N0 + 1):N, (T0 + 1):TT] <- 1

# Generate Y and Z forward in time (Z depends on Y_lag, vectorized over units)
Y <- matrix(0, nrow = N, ncol = TT)
Z <- matrix(0, nrow = N, ncol = TT)

nu  <- rnorm(N)
eps <- rnorm(N)
Z[, 1] <- gamma_D * D[, 1] + 0.3 * mu_i + nu
Y[, 1] <- beta * D[, 1] + delta * Z[, 1] + mu_i + xi_t[1] + eps

for (t in 2:TT) {
  nu  <- rnorm(N)
  eps <- rnorm(N)
  Z[, t] <- gamma_D * D[, t] + gamma_Yl * Y[, t - 1] + 0.3 * mu_i + nu
  Y[, t] <- beta * D[, t] + delta * Z[, t] + mu_i + xi_t[t] + eps
}

# Label rows/cols for synthdid
rownames(Y) <- paste0("u", sprintf("%02d", 1:N))
colnames(Y) <- paste0("t", sprintf("%02d", 1:TT))
rownames(Z) <- rownames(Y)
colnames(Z) <- colnames(Y)

# Covariate array: N x T x 1 (synthdid format)
Z_array <- array(Z, dim = c(N, TT, 1))

# DGP sanity check
cat("\n=== DGP sanity check ===\n")
cat("  Y range: [", round(min(Y), 2), ",", round(max(Y), 2), "]\n")
cat("  Z range: [", round(min(Z), 2), ",", round(max(Z), 2), "]\n")
cat("  D mean (post, treated):", round(mean(D[(N0+1):N, (T0+1):TT]), 2), "\n")
cat("  N =", N, " (N0 =", N0, ", N1 =", N1, ")\n")
cat("  T =", TT, " (T0 =", T0, ", T1 =", T1, ")\n")

# ---- 2. tau_short: SDiD without Z ----
cat("\n=== tau_short (SDiD without Z) ===\n")
fit_short <- synthdid_estimate(Y, N0, T0)
tau_short <- as.numeric(fit_short)
cat("tau_short =", round(tau_short, 4), "\n")

w_short      <- attr(fit_short, "weights")
omega_short  <- w_short$omega    # length N0
lambda_short <- w_short$lambda   # length T0
cat("omega_short: len =", length(omega_short),
    ", sum =", round(sum(omega_short), 6), "\n")
cat("lambda_short: len =", length(lambda_short),
    ", sum =", round(sum(lambda_short), 6), "\n")

# ---- 3. tau_long: SDiD with Z (weights re-optimized) ----
cat("\n=== tau_long (SDiD with Z, weights re-optimized) ===\n")
fit_long <- synthdid_estimate(Y, N0, T0, X = Z_array)
tau_long <- as.numeric(fit_long)
cat("tau_long =", round(tau_long, 4), "\n")

w_long      <- attr(fit_long, "weights")
omega_long  <- w_long$omega
lambda_long <- w_long$lambda
beta_long   <- as.numeric(w_long$beta)
cat("beta_long (coef of Z, collapsed form) =", round(beta_long, 6), "\n")

# ---- 4. tau_hybrid: SDiD with Z, weights FIXED from no-Z model ----
# This is the key: synthdid_estimate accepts pre-computed weights.
# With update.omega = FALSE and update.lambda = FALSE, only the
# regression step (tau, beta) is estimated via gradient descent on
# the collapsed form. Weights are held fixed.
cat("\n=== tau_hybrid (SDiD with Z, weights fixed from no-Z) ===\n")
fit_hybrid <- synthdid_estimate(
  Y, N0, T0, X = Z_array,
  weights       = list(omega = omega_short, lambda = lambda_short),
  update.omega  = FALSE,
  update.lambda = FALSE
)
tau_hybrid <- as.numeric(fit_hybrid)
cat("tau_hybrid =", round(tau_hybrid, 4), "\n")

w_hybrid     <- attr(fit_hybrid, "weights")
beta_hybrid  <- as.numeric(w_hybrid$beta)
cat("beta_hybrid (coef of Z, collapsed form) =", round(beta_hybrid, 6), "\n")

# ---- 5. Decomposition: IVB = CE + RE ----
cat("\n=== Decomposition: IVB = CE + RE ===\n")
IVB <- tau_long - tau_short
CE  <- tau_hybrid - tau_short
RE  <- tau_long - tau_hybrid

cat("IVB = tau_long - tau_short   =", round(IVB, 6), "\n")
cat("CE  = tau_hybrid - tau_short =", round(CE, 6), "\n")
cat("RE  = tau_long - tau_hybrid  =", round(RE, 6), "\n")
cat("CE + RE                      =", round(CE + RE, 6), "\n")
decomp_err <- abs(IVB - CE - RE)
cat("Decomposition error          =", format(decomp_err, digits = 12), "\n")

# ---- 6. SDiD FWL-like identity: CE = -beta_h * tau_Z ----
# From the synthdid source code, the final estimate is:
#   estimate = t(c(-omega, 1/N1, ...)) %*% (Y - Z*beta) %*% c(-lambda, 1/T1, ...)
# Therefore, with fixed weights:
#   CE = tau_hybrid - tau_short
#      = -beta_h * (omega_ext' %*% Z %*% lambda_ext)
#      = -beta_h * tau_Z
# where tau_Z is the SDiD "treatment effect" on Z (double-difference of Z).
cat("\n=== SDiD FWL-like identity: CE = -beta_h * tau_Z ===\n")

omega_ext  <- c(-omega_short, rep(1 / N1, N1))
lambda_ext <- c(-lambda_short, rep(1 / T1, T1))
tau_Z      <- as.numeric(t(omega_ext) %*% Z %*% lambda_ext)

CE_sdid_fwl <- -beta_hybrid * tau_Z

cat("beta_hybrid (Z->Y, collapsed)     =", round(beta_hybrid, 6), "\n")
cat("tau_Z (SDiD double-diff of Z)      =", round(tau_Z, 6), "\n")
cat("CE (direct: tau_hybrid - tau_short) =", round(CE, 6), "\n")
cat("CE (SDiD FWL: -beta_h * tau_Z)     =", round(CE_sdid_fwl, 6), "\n")
sdid_fwl_err <- abs(CE - CE_sdid_fwl)
cat("SDiD FWL error                      =", format(sdid_fwl_err, digits = 12), "\n")

# ---- 7. Weight comparison (short vs long) ----
cat("\n=== Weight comparison ===\n")
cat("max |omega_long - omega_short|  =",
    round(max(abs(omega_long - omega_short)), 6), "\n")
cat("max |lambda_long - lambda_short| =",
    round(max(abs(lambda_long - lambda_short)), 6), "\n")

# ---- 8. Full-panel WLS cross-check (feols) ----
# NOTE: synthdid estimates beta on the collapsed form (N0+1 x T0+1).
# The WLS below estimates beta on the full panel (N x T) via feols.
# These are different optimization problems, so tau_hybrid(synthdid) may
# differ from tau_wls(feols). A discrepancy is INFORMATIVE, not an error.
cat("\n=== Full-panel WLS cross-check ===\n")
cat("NOTE: synthdid estimates beta on collapsed form, WLS on full panel.\n")
cat("Discrepancy is expected and informative.\n\n")

omega_full  <- c(omega_short, rep(1 / N1, N1))
lambda_full <- c(lambda_short, rep(1 / T1, T1))
W <- outer(omega_full, lambda_full)   # N x TT weight matrix

# Flatten to long format
dt <- data.table(
  Y    = as.vector(t(Y)),
  D    = as.vector(t(D)),
  Z    = as.vector(t(Z)),
  w    = as.vector(t(W)),
  unit = factor(rep(1:N, each = TT)),
  time = factor(rep(1:TT, times = N))
)

# WLS long: Y ~ D + Z | unit + time (feols, absorbed FE)
fit_wls_long  <- feols(Y ~ D + Z | unit + time, data = dt, weights = ~w,
                       vcov = "iid")
tau_wls_long  <- coef(fit_wls_long)["D"]
theta_wls     <- coef(fit_wls_long)["Z"]

# WLS short: Y ~ D | unit + time (same weights, no Z)
fit_wls_short <- feols(Y ~ D | unit + time, data = dt, weights = ~w,
                       vcov = "iid")
tau_wls_short <- coef(fit_wls_short)["D"]

CE_wls   <- unname(tau_wls_long - tau_wls_short)
wls_diff <- abs(tau_hybrid - tau_wls_long)

cat("tau_hybrid (synthdid, collapsed beta) =", round(tau_hybrid, 6), "\n")
cat("tau_wls_long (full-panel feols)       =", round(unname(tau_wls_long), 6), "\n")
cat("Difference                            =", format(wls_diff, digits = 10), "\n\n")

cat("beta_hybrid (collapsed) =", round(beta_hybrid, 6), "\n")
cat("theta_wls (full panel)  =", round(unname(theta_wls), 6), "\n")
cat("Beta difference         =", format(abs(beta_hybrid - theta_wls), digits = 10), "\n")

# ---- 9. Full-panel WLS FWL identity (tautological for any WLS) ----
cat("\n=== WLS FWL identity: CE_wls = -theta_wls * pi_wls ===\n")
cat("NOTE: This is a mathematical identity for WLS (always holds).\n")
cat("It validates the code, not the SDiD decomposition.\n\n")

fit_aux    <- feols(Z ~ D | unit + time, data = dt, weights = ~w,
                    vcov = "iid")
pi_wls     <- coef(fit_aux)["D"]
CE_wls_fwl <- unname(-theta_wls * pi_wls)

cat("theta_wls (Z->Y, full panel) =", round(unname(theta_wls), 6), "\n")
cat("pi_wls (D->Z, full panel)    =", round(unname(pi_wls), 6), "\n")
cat("CE_wls (direct)              =", round(CE_wls, 6), "\n")
cat("CE_wls (FWL: -theta * pi)    =", round(CE_wls_fwl, 6), "\n")
wls_fwl_err <- abs(CE_wls - CE_wls_fwl)
cat("WLS FWL error                =", format(wls_fwl_err, digits = 12), "\n")

# ---- 10. TWFE benchmark (SDiD weights) ----
# With SDiD weights, the feols in sections 8-9 IS a weighted TWFE.
# In TWFE, weights are fixed (OLS), so RE = 0 by construction.
# Reuse fit_wls_long/short/aux — same models, no need to re-estimate.
cat("\n=== TWFE benchmark with SDiD weights (RE = 0 expected) ===\n")

tau_twfe_long  <- tau_wls_long
tau_twfe_short <- tau_wls_short
theta_twfe     <- theta_wls
pi_twfe        <- pi_wls

IVB_twfe    <- CE_wls           # In TWFE, IVB = CE (no RE)
CE_twfe_fwl <- CE_wls_fwl       # FWL identity from section 9

cat("tau_twfe_short =", round(unname(tau_twfe_short), 6), "\n")
cat("tau_twfe_long  =", round(unname(tau_twfe_long), 6), "\n")
cat("IVB_twfe       =", round(IVB_twfe, 6), "\n")
cat("CE_twfe (FWL)  =", round(CE_twfe_fwl, 6), "\n")
cat("RE_twfe        =", round(IVB_twfe - CE_twfe_fwl, 10),
    " (should be ~0)\n")

# ---- 10b. TWFE benchmark (uniform weights) ----
# Standard TWFE without SDiD reweighting. Isolates the effect of
# SDiD's adaptive weights on the IVB by comparing IVB_sdid vs IVB_twfe_unif.
cat("\n=== TWFE benchmark with uniform weights ===\n")

twfe_unif_long  <- feols(Y ~ D + Z | unit + time, data = dt, vcov = "iid")
twfe_unif_short <- feols(Y ~ D | unit + time, data = dt, vcov = "iid")
twfe_unif_aux   <- feols(Z ~ D | unit + time, data = dt, vcov = "iid")

tau_twfe_u_long  <- coef(twfe_unif_long)["D"]
tau_twfe_u_short <- coef(twfe_unif_short)["D"]
theta_twfe_u     <- coef(twfe_unif_long)["Z"]
pi_twfe_u        <- coef(twfe_unif_aux)["D"]

IVB_twfe_u    <- unname(tau_twfe_u_long - tau_twfe_u_short)
CE_twfe_u_fwl <- unname(-theta_twfe_u * pi_twfe_u)

cat("tau_twfe_u_short =", round(unname(tau_twfe_u_short), 6), "\n")
cat("tau_twfe_u_long  =", round(unname(tau_twfe_u_long), 6), "\n")
cat("IVB_twfe_u       =", round(IVB_twfe_u, 6), "\n")
cat("CE_twfe_u (FWL)  =", round(CE_twfe_u_fwl, 6), "\n")
cat("RE_twfe_u        =", round(IVB_twfe_u - CE_twfe_u_fwl, 10),
    " (should be ~0)\n\n")
cat("Comparison: IVB_sdid =", round(IVB, 4),
    " vs IVB_twfe_unif =", round(IVB_twfe_u, 4), "\n")

# ---- 11. Summary ----
cat("\n", paste(rep("=", 60), collapse = ""), "\n")
cat("FEASIBILITY CHECK SUMMARY\n")
cat(paste(rep("=", 60), collapse = ""), "\n\n")

cat("True beta   =", beta, "\n")
cat("tau_short   =", round(tau_short, 4), "\n")
cat("tau_long    =", round(tau_long, 4), "\n")
cat("tau_hybrid  =", round(tau_hybrid, 4), "\n\n")

cat("IVB =", round(IVB, 4), "\n")
if (abs(IVB) > 1e-10) {
  cat("  CE =", round(CE, 4),
      sprintf(" (%.1f%% of IVB)\n", CE / IVB * 100))
  cat("  RE =", round(RE, 4),
      sprintf(" (%.1f%% of IVB)\n", RE / IVB * 100))
} else {
  cat("  CE =", round(CE, 4), "\n")
  cat("  RE =", round(RE, 4), "\n")
}

cat("\nSDiD FWL components:\n")
cat("  beta_h  =", round(beta_hybrid, 4), " (Z->Y from collapsed form)\n")
cat("  tau_Z   =", round(tau_Z, 4), " (SDiD double-diff of Z)\n")
cat("  -beta_h * tau_Z =", round(CE_sdid_fwl, 4), "\n")

cat("\nChecks:\n")
cat("  [1] Decomposition identity (IVB = CE + RE):     ",
    ifelse(decomp_err < 1e-8, "PASS", "FAIL"), "\n")
cat("  [2] SDiD FWL-like (CE = -beta_h * tau_Z):       ",
    ifelse(sdid_fwl_err < 1e-8, "PASS", "FAIL"), "\n")
cat("  [3] WLS FWL (CE_wls = -theta * pi, tautological):",
    ifelse(wls_fwl_err < 1e-6, "PASS", "FAIL"), "\n")
cat("  [4] WLS vs synthdid hybrid (may differ):         ",
    ifelse(wls_diff < 1e-4, "MATCH", sprintf("DIFFER by %.6f", wls_diff)),
    "\n")
cat("      -> ",
    ifelse(wls_diff < 1e-4,
           "SDiD regression step equivalent to full-panel WLS.",
           "Collapsed-form beta differs from full-panel — see notes/discussion."),
    "\n")
cat("  [5] RE != 0 (weights changed):                   ",
    ifelse(abs(RE) > 1e-6, "PASS (RE non-zero)", "NOTE: RE ~ 0"), "\n")
cat("  [6] TWFE RE = 0 (SDiD weights):                   ",
    ifelse(abs(IVB_twfe - CE_twfe_fwl) < 1e-6, "PASS", "FAIL"), "\n")
cat("  [7] TWFE RE = 0 (uniform weights):                ",
    ifelse(abs(IVB_twfe_u - CE_twfe_u_fwl) < 1e-6, "PASS", "FAIL"), "\n")

cat("\n", paste(rep("=", 60), collapse = ""), "\n")

# ---- 12. Save results ----
results <- data.table(
  estimator = c("SDiD", "TWFE_sdid_w", "TWFE_unif_w"),
  tau_short = c(tau_short, unname(tau_twfe_short), unname(tau_twfe_u_short)),
  tau_long  = c(tau_long, unname(tau_twfe_long), unname(tau_twfe_u_long)),
  tau_hybrid = c(tau_hybrid, NA, NA),
  IVB  = c(IVB, IVB_twfe, IVB_twfe_u),
  CE   = c(CE, IVB_twfe, IVB_twfe_u),
  RE   = c(RE, 0, 0),
  beta_h  = c(beta_hybrid, unname(theta_twfe), unname(theta_twfe_u)),
  tau_Z   = c(tau_Z, unname(pi_twfe), unname(pi_twfe_u)),
  CE_fwl  = c(CE_sdid_fwl, CE_twfe_fwl, CE_twfe_u_fwl)
)
fwrite(results, "scripts/step0_feasibility_results.csv")
cat("Results saved to scripts/step0_feasibility_results.csv\n")

writeLines(capture.output(sessionInfo()),
           "scripts/step0_feasibility_sessioninfo.txt")
cat("sessionInfo saved to scripts/step0_feasibility_sessioninfo.txt\n")
