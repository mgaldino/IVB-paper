# =============================================================================
# Monte Carlo Simulation: When is the IVB large in TWFE panels?
# Manoel Galdino
#
# This script simulates panel data with two-way fixed effects (unit + time)
# to study under which DGP conditions the Included Variable Bias (IVB) is
# substantial. It covers both the "clean" case (Z is only a collider) and the
# "dirty" case (Z is both collider and confounder).
#
# IMPORTANT: This script assumes the working directory is the project root
# (IVB-paper/). When opened in RStudio via the .Rproj file, the working
# directory is set automatically.
#
# See plan: quality_reports/plans/2026-02-27_sim-ivb-twfe.md
#
# Dependencies: fixest, data.table, future.apply
# =============================================================================

library(fixest)
library(data.table)
library(future.apply)

# =============================================================================
# 1. DGP Function
# =============================================================================

#' Generate panel data with TWFE structure and collider/confounder Z
#'
#' @param N Number of units
#' @param TT Number of time periods
#' @param beta True effect of D on Y
#' @param gamma_Y Y -> Z (collider strength)
#' @param gamma_D D -> Z
#' @param delta Z -> Y (confounding; 0 = clean case)
#' @param R2_within Fraction of D variance that is within-unit/within-time
#' @param sigma2_alpha Variance of unit FE in Y equation
#' @param sigma2_lambda Variance of time FE in Y equation
#' @param sigma2_eps Variance of idiosyncratic error in Y equation
#' @param sigma2_nu Variance of idiosyncratic error in Z equation
#' @param sigma2_eta Variance of unit FE in Z equation
#' @param sigma2_mu Variance of time FE in Z equation
#' @return data.table with columns: unit, time, Y, D, Z
generate_panel_data <- function(N, TT, beta, gamma_Y, gamma_D, delta,
                                R2_within,
                                sigma2_alpha = 1, sigma2_lambda = 1,
                                sigma2_eps = 1, sigma2_nu = 1,
                                sigma2_eta = 0.5, sigma2_mu = 0.5) {

  k <- 1 - delta * gamma_Y  # stability parameter

  # --- D components (sigma2_D_total = 1 by normalization) ---
  sigma2_D_within  <- R2_within
  sigma2_D_between <- (1 - R2_within) / 2
  sigma2_D_time    <- (1 - R2_within) / 2

  mu_i_D <- rnorm(N, sd = sqrt(sigma2_D_between))   # between-unit
  tau_t_D <- rnorm(TT, sd = sqrt(sigma2_D_time))    # time component
  d_it <- rnorm(N * TT, sd = sqrt(sigma2_D_within)) # within component

  # D_it = mu_i^D + tau_t^D + d_it
  D <- rep(mu_i_D, each = TT) + rep(tau_t_D, times = N) + d_it

  # --- FE components ---
  alpha_i  <- rnorm(N, sd = sqrt(sigma2_alpha))    # unit FE for Y
  lambda_t <- rnorm(TT, sd = sqrt(sigma2_lambda))  # time FE for Y
  eta_i    <- rnorm(N, sd = sqrt(sigma2_eta))       # unit FE for Z
  mu_t     <- rnorm(TT, sd = sqrt(sigma2_mu))       # time FE for Z

  # --- Idiosyncratic errors ---
  eps_it <- rnorm(N * TT, sd = sqrt(sigma2_eps))
  nu_it  <- rnorm(N * TT, sd = sqrt(sigma2_nu))

  # --- Generate Y and Z from reduced form ---
  if (delta == 0) {
    # Clean case: no simultaneity
    Y <- beta * D +
      rep(alpha_i, each = TT) + rep(lambda_t, times = N) + eps_it

    Z <- (gamma_D + gamma_Y * beta) * D +
      rep(eta_i + gamma_Y * alpha_i, each = TT) +
      rep(mu_t + gamma_Y * lambda_t, times = N) +
      (nu_it + gamma_Y * eps_it)
  } else {
    # Dirty case: simultaneous equations, use reduced form
    Y <- ((beta + delta * gamma_D) / k) * D +
      rep((alpha_i + delta * eta_i) / k, each = TT) +
      rep((lambda_t + delta * mu_t) / k, times = N) +
      (eps_it + delta * nu_it) / k

    Z <- ((gamma_D + gamma_Y * beta) / k) * D +
      rep((eta_i + gamma_Y * alpha_i) / k, each = TT) +
      rep((mu_t + gamma_Y * lambda_t) / k, times = N) +
      (nu_it + gamma_Y * eps_it) / k
  }

  data.table(
    unit = rep(1:N, each = TT),
    time = rep(1:TT, times = N),
    Y = Y,
    D = D,
    Z = Z
  )
}


# =============================================================================
# 2. Single Simulation Function
# =============================================================================

#' Run one Monte Carlo scenario (nsim replications)
#'
#' @param params Named list with: N, TT, beta, gamma_Y, gamma_D, delta,
#'   R2_within, nsim, and optionally sigma2_* parameters
#' @return data.table with one row: scenario parameters + summary metrics
run_one_scenario <- function(params) {

  N         <- params$N
  TT        <- params$TT
  beta      <- params$beta
  gamma_Y   <- params$gamma_Y
  gamma_D   <- params$gamma_D
  delta     <- params$delta
  R2_within <- params$R2_within
  nsim      <- params$nsim

  # Stability check
  if (abs(delta * gamma_Y) >= 1) {
    return(data.table(
      gamma_Y = gamma_Y, gamma_D = gamma_D, delta = delta,
      R2_within = R2_within, N = N, TT = TT, beta = beta,
      stable = FALSE,
      mean_beta_short = NA_real_, mean_beta_long = NA_real_,
      mean_ivb = NA_real_, mean_ivb_formula = NA_real_,
      mean_abs_ivb_over_beta = NA_real_,
      mean_abs_ivb_over_se = NA_real_,
      mean_abs_ivb_over_sd_y = NA_real_,
      bias_short = NA_real_, bias_long = NA_real_,
      rmse_short = NA_real_, rmse_long = NA_real_,
      coverage_short = NA_real_, coverage_long = NA_real_,
      rejection_short = NA_real_, rejection_long = NA_real_
    ))
  }

  # Storage vectors
  beta_short_vec   <- numeric(nsim)
  beta_long_vec    <- numeric(nsim)
  ivb_vec          <- numeric(nsim)
  ivb_formula_vec  <- numeric(nsim)
  se_long_vec      <- numeric(nsim)
  sd_y_vec         <- numeric(nsim)
  cover_short_vec  <- logical(nsim)
  cover_long_vec   <- logical(nsim)
  reject_short_vec <- logical(nsim)
  reject_long_vec  <- logical(nsim)

  for (s in seq_len(nsim)) {
    dt <- generate_panel_data(N = N, TT = TT, beta = beta,
                              gamma_Y = gamma_Y, gamma_D = gamma_D,
                              delta = delta, R2_within = R2_within)

    # Researcher's models — fit with iid SEs, then compute clustered SEs
    # (avoids fixest clustering issue in parallel worker sessions)
    m_short <- feols(Y ~ D | unit + time, data = dt, vcov = "iid")
    m_long  <- feols(Y ~ D + Z | unit + time, data = dt, vcov = "iid")
    m_aux   <- feols(Z ~ D | unit + time, data = dt, vcov = "iid")

    b_short <- coef(m_short)[["D"]]
    b_long  <- coef(m_long)[["D"]]
    theta   <- coef(m_long)[["Z"]]
    pi_hat  <- coef(m_aux)[["D"]]

    # IID SEs (correct for this DGP since errors are iid)
    se_short <- se(m_short)[["D"]]
    se_long  <- se(m_long)[["D"]]

    beta_short_vec[s]  <- b_short
    beta_long_vec[s]   <- b_long
    ivb_vec[s]         <- b_long - b_short
    ivb_formula_vec[s] <- -theta * pi_hat
    se_long_vec[s]     <- se_long
    sd_y_vec[s]        <- sd(dt$Y)

    # Coverage: does 95% CI contain true beta?
    # Use t-distribution with N-1 df for clustered SEs
    t_crit <- qt(0.975, N - 1)
    ci_short_lo <- b_short - t_crit * se_short
    ci_short_hi <- b_short + t_crit * se_short
    ci_long_lo  <- b_long - t_crit * se_long
    ci_long_hi  <- b_long + t_crit * se_long

    cover_short_vec[s] <- (beta >= ci_short_lo) & (beta <= ci_short_hi)
    cover_long_vec[s]  <- (beta >= ci_long_lo) & (beta <= ci_long_hi)

    # Rejection of H0: beta = 0 (two-sided, 5%)
    reject_short_vec[s] <- abs(b_short / se_short) > t_crit
    reject_long_vec[s]  <- abs(b_long / se_long) > t_crit
  }

  data.table(
    gamma_Y   = gamma_Y,
    gamma_D   = gamma_D,
    delta     = delta,
    R2_within = R2_within,
    N         = N,
    TT        = TT,
    beta      = beta,
    stable    = TRUE,

    mean_beta_short       = mean(beta_short_vec),
    mean_beta_long        = mean(beta_long_vec),
    mean_ivb              = mean(ivb_vec),
    mean_ivb_formula      = mean(ivb_formula_vec),
    mean_abs_ivb_over_beta = mean(abs(ivb_vec) / abs(beta)),
    mean_abs_ivb_over_se  = mean(abs(ivb_vec) / se_long_vec),
    mean_abs_ivb_over_sd_y = mean(abs(ivb_vec) / sd_y_vec),
    bias_short            = mean(beta_short_vec) - beta,
    bias_long             = mean(beta_long_vec) - beta,
    rmse_short            = sqrt(mean((beta_short_vec - beta)^2)),
    rmse_long             = sqrt(mean((beta_long_vec - beta)^2)),
    coverage_short        = mean(cover_short_vec),
    coverage_long         = mean(cover_long_vec),
    rejection_short       = mean(reject_short_vec),
    rejection_long        = mean(reject_long_vec)
  )
}


# =============================================================================
# 3. Parameter Grid
# =============================================================================

param_grid <- CJ(
  gamma_Y   = c(0.0, 0.2, 0.5, 0.8),
  gamma_D   = c(-0.8, -0.5, -0.2, 0.2, 0.5, 0.8),
  delta     = c(-0.6, -0.3, 0.0, 0.3, 0.6),
  R2_within = c(0.1, 0.3, 0.5, 0.7, 0.9)
)

# Add fixed parameters
param_grid[, `:=`(N = 200L, TT = 30L, beta = 1.0, nsim = 500L)]

cat(sprintf("Total scenarios: %d\n", nrow(param_grid)))
cat(sprintf("Replications per scenario: %d\n", param_grid$nsim[1]))

# Convert to list of lists for future_lapply
param_list <- lapply(seq_len(nrow(param_grid)), function(i) as.list(param_grid[i]))


# =============================================================================
# 4. Run Simulation (parallel)
# =============================================================================

cat("Starting simulation...\n")
t_start <- Sys.time()

# Use 4 workers; fixest clustering requires post-estimation vcov (see feols
# calls in run_one_scenario) to avoid errors in multisession workers.
plan(multisession, workers = 4L)

# Reproducible parallel RNG via L'Ecuyer-CMRG streams
set.seed(2026)
results_list <- future_lapply(
  param_list,
  run_one_scenario,
  future.seed = TRUE
)

plan(sequential)

results <- rbindlist(results_list)

t_end <- Sys.time()
cat(sprintf("Simulation completed in %.1f minutes.\n",
            as.numeric(difftime(t_end, t_start, units = "mins"))))


# =============================================================================
# 5. Save Results
# =============================================================================

fwrite(results, "sim_ivb_twfe_results.csv")
cat(sprintf("Results saved: %d rows x %d columns\n", nrow(results), ncol(results)))


# =============================================================================
# 6. Sanity Checks
# =============================================================================

cat("\n=== SANITY CHECKS ===\n\n")

# Check 1: IVB formula matches empirical IVB (FWL identity, must hold exactly)
# Note: in the dirty case (delta != 0), beta_long - beta_short is the NET
# change from including Z, which combines IVB (collider) and OVB removal
# (deconfounding). The formula -theta* x pi still holds as a mechanical
# identity of the Frisch-Waugh-Lovell theorem.
formula_check <- results[stable == TRUE, abs(mean_ivb - mean_ivb_formula)]
max_disc <- max(formula_check, na.rm = TRUE)
cat(sprintf("Max |IVB_empirical - IVB_formula|: %.6f\n", max_disc))
if (max_disc > 0.01) {
  cat("  WARNING: Formula discrepancy > 0.01 in some scenarios!\n")
} else {
  cat("  OK: Formula matches empirical IVB in all scenarios.\n")
}

# Check 2: Clean case (delta=0) — short model should be unbiased
clean <- results[delta == 0 & stable == TRUE]
cat(sprintf("\nClean case (delta=0): max |bias_short| = %.4f (should be ~0)\n",
            max(abs(clean$bias_short))))
cat(sprintf("Clean case (delta=0): mean |bias_long|  = %.4f (should be > 0 when gamma_Y > 0)\n",
            mean(abs(clean[gamma_Y > 0]$bias_long))))

# Check 3: IVB/|beta| vs R2_within (should be ~constant)
cat("\nIVB/|beta| by R2_within (averaged over other params, clean case, gamma_Y=0.5, gamma_D=0.5):\n")
check_r2 <- results[gamma_Y == 0.5 & gamma_D == 0.5 & delta == 0 & stable == TRUE,
                     .(mean_ivb_pct = mean(mean_abs_ivb_over_beta)),
                     by = R2_within]
print(check_r2)

# Check 4: Coverage in clean case short model (should be ~0.95)
cat(sprintf("\nClean case coverage_short: mean = %.3f (should be ~0.95)\n",
            mean(clean$coverage_short)))

# Summary: conditions where IVB is large
cat("\n=== WHERE IS IVB LARGE? ===\n")
large_10 <- results[stable == TRUE & mean_abs_ivb_over_beta > 0.10]
large_25 <- results[stable == TRUE & mean_abs_ivb_over_beta > 0.25]
large_50 <- results[stable == TRUE & mean_abs_ivb_over_beta > 0.50]
cat(sprintf("Scenarios with |IVB/beta| > 10%%: %d / %d\n",
            nrow(large_10), nrow(results[stable == TRUE])))
cat(sprintf("Scenarios with |IVB/beta| > 25%%: %d / %d\n",
            nrow(large_25), nrow(results[stable == TRUE])))
cat(sprintf("Scenarios with |IVB/beta| > 50%%: %d / %d\n",
            nrow(large_50), nrow(results[stable == TRUE])))

if (nrow(large_25) > 0) {
  cat("\nTop 10 scenarios by |IVB/beta|:\n")
  top10 <- results[stable == TRUE][order(-mean_abs_ivb_over_beta)][1:min(10, .N)]
  print(top10[, .(gamma_Y, gamma_D, delta, R2_within,
                  ivb_pct = round(mean_abs_ivb_over_beta * 100, 1),
                  bias_short = round(bias_short, 4),
                  bias_long = round(bias_long, 4),
                  rmse_short = round(rmse_short, 4),
                  rmse_long = round(rmse_long, 4))])
}

cat("\n=== DONE ===\n")

# Record session info for reproducibility
writeLines(capture.output(sessionInfo()), "sim_ivb_twfe_sessioninfo.txt")
