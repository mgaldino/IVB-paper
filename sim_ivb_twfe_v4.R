# =============================================================================
# Monte Carlo Simulation v4: Why is the IVB small?
# Between/within decomposition of causal channels
#
# Manoel Galdino
#
# Four mechanisms explaining why IVB tends to be small in empirical TWFE:
#   A) D->Z channel is primarily between (absorbed by unit FE)
#   B) Y->Z channel is primarily between (theta* shrinks after FE)
#   C) Binary D with staggered adoption (few switchers -> large SE)
#   D) Measurement error in Z (attenuates theta*)
#
# See plan: quality_reports/plans/2026-02-28_sim-ivb-twfe-v4.md
#
# Dependencies: fixest, data.table, future.apply
# =============================================================================

library(fixest)
library(data.table)
library(future.apply)

# =============================================================================
# 1. DGP Functions
# =============================================================================

#' Generate panel data — Mechanism A: between/within decomposition of D->Z
#'
#' Z_it = gamma_D_btw * mu_i^D + gamma_D_wth * (D_it - mu_i^D)
#'        + gamma_Y * Y_it + eta_i + mu_t + nu_it
#'
#' After TWFE: pi = gamma_D_wth + gamma_Y * beta
#'
#' @param N Number of units
#' @param TT Number of time periods
#' @param beta True effect of D on Y
#' @param gamma_D_btw D->Z between channel (absorbed by unit FE)
#' @param gamma_D_wth D->Z within channel (survives TWFE)
#' @param gamma_Y Y->Z collider strength
#' @param R2_within Fraction of D variance that is within
#' @param sigma2_eps Variance of eps in Y equation
#' @param sigma2_nu Variance of nu in Z equation
#' @return data.table with columns: unit, time, Y, D, Z
generate_panel_data_mechA <- function(N, TT, beta,
                                      gamma_D_btw, gamma_D_wth, gamma_Y,
                                      R2_within,
                                      sigma2_eps = 1, sigma2_nu = 1) {

  # --- D components (total variance ~ 1) ---
  sigma2_D_within  <- R2_within
  sigma2_D_between <- (1 - R2_within) / 2
  sigma2_D_time    <- (1 - R2_within) / 2

  mu_i_D <- rnorm(N, sd = sqrt(sigma2_D_between))
  tau_t_D <- rnorm(TT, sd = sqrt(sigma2_D_time))
  d_it <- rnorm(N * TT, sd = sqrt(sigma2_D_within))

  D <- rep(mu_i_D, each = TT) + rep(tau_t_D, times = N) + d_it

  # Unit-level mean of D (for between/within decomposition)
  mu_i_D_expanded <- rep(mu_i_D, each = TT)

  # --- FE components ---
  alpha_i  <- rnorm(N, sd = 1)     # unit FE for Y
  lambda_t <- rnorm(TT, sd = 1)    # time FE for Y
  eta_i    <- rnorm(N, sd = 0.5)   # unit FE for Z
  mu_t     <- rnorm(TT, sd = 0.5)  # time FE for Z

  # --- Errors ---
  eps_it <- rnorm(N * TT, sd = sqrt(sigma2_eps))
  nu_it  <- rnorm(N * TT, sd = sqrt(sigma2_nu))

  # --- Y equation (clean case, delta=0) ---
  Y <- beta * D +
    rep(alpha_i, each = TT) + rep(lambda_t, times = N) + eps_it

  # --- Z equation with between/within decomposition ---
  Z <- gamma_D_btw * mu_i_D_expanded +
    gamma_D_wth * (D - mu_i_D_expanded) +
    gamma_Y * Y +
    rep(eta_i, each = TT) + rep(mu_t, times = N) + nu_it

  data.table(
    unit = rep(1:N, each = TT),
    time = rep(1:TT, times = N),
    Y = Y, D = D, Z = Z
  )
}


#' Generate panel data — Mechanism B: between/within decomposition of Y->Z
#'
#' Z_it = gamma_D * D_it + gamma_Y_btw * bar(Y_i) + gamma_Y_wth * (Y_it - bar(Y_i))
#'        + eta_i + mu_t + nu_it
#'
#' After TWFE: theta* depends on gamma_Y_wth only
generate_panel_data_mechB <- function(N, TT, beta,
                                      gamma_D, gamma_Y_btw, gamma_Y_wth,
                                      R2_within,
                                      sigma2_eps = 1, sigma2_nu = 1) {

  # --- D components ---
  sigma2_D_within  <- R2_within
  sigma2_D_between <- (1 - R2_within) / 2
  sigma2_D_time    <- (1 - R2_within) / 2

  mu_i_D <- rnorm(N, sd = sqrt(sigma2_D_between))
  tau_t_D <- rnorm(TT, sd = sqrt(sigma2_D_time))
  d_it <- rnorm(N * TT, sd = sqrt(sigma2_D_within))

  D <- rep(mu_i_D, each = TT) + rep(tau_t_D, times = N) + d_it

  # --- FE components ---
  alpha_i  <- rnorm(N, sd = 1)
  lambda_t <- rnorm(TT, sd = 1)
  eta_i    <- rnorm(N, sd = 0.5)
  mu_t     <- rnorm(TT, sd = 0.5)

  # --- Errors ---
  eps_it <- rnorm(N * TT, sd = sqrt(sigma2_eps))
  nu_it  <- rnorm(N * TT, sd = sqrt(sigma2_nu))

  # --- Y equation ---
  Y <- beta * D +
    rep(alpha_i, each = TT) + rep(lambda_t, times = N) + eps_it

  # --- Unit-level mean of Y ---
  # bar(Y_i) is the sample mean of Y for each unit. It is time-invariant by

  # construction, so gamma_Y_btw * bar(Y_i) is exactly absorbed by unit FE.
  # NOTE: The within-deviation (Y - bar(Y_i)) differs from TWFE-demeaned Y
  # by O(1/T) terms (because bar(Y_i) subtracts unit means but not time means).
  # With T=30 this approximation is very accurate. The prediction "theta*
  # depends on gamma_Y_wth only" holds to a good finite-sample approximation
  # that improves as T grows.
  dt_tmp <- data.table(unit = rep(1:N, each = TT), Y = Y)
  Y_bar_i <- dt_tmp[, .(Y_bar = mean(Y)), by = unit]$Y_bar
  Y_bar_expanded <- rep(Y_bar_i, each = TT)

  # --- Z equation with between/within decomposition of Y->Z ---
  Z <- gamma_D * D +
    gamma_Y_btw * Y_bar_expanded +
    gamma_Y_wth * (Y - Y_bar_expanded) +
    rep(eta_i, each = TT) + rep(mu_t, times = N) + nu_it

  data.table(
    unit = rep(1:N, each = TT),
    time = rep(1:TT, times = N),
    Y = Y, D = D, Z = Z
  )
}


#' Generate panel data — Mechanism C: Binary D with staggered adoption
#'
#' D_it = 1(t >= T_i*) for switchers; D=0 for never-treated; D=1 for always-treated
generate_panel_data_mechC <- function(N, TT, beta,
                                      gamma_D, gamma_Y,
                                      prob_switch,
                                      sigma2_eps = 1, sigma2_nu = 1) {

  # --- Unit types ---
  # prob_switch fraction are switchers; rest split between never/always-treated
  prob_never  <- (1 - prob_switch) / 2
  prob_always <- (1 - prob_switch) / 2

  unit_type <- sample(c("never", "switcher", "always"), N, replace = TRUE,
                      prob = c(prob_never, prob_switch, prob_always))

  # --- D: binary treatment ---
  D <- numeric(N * TT)
  for (i in 1:N) {
    idx <- ((i - 1) * TT + 1):(i * TT)
    if (unit_type[i] == "never") {
      D[idx] <- 0
    } else if (unit_type[i] == "always") {
      D[idx] <- 1
    } else {
      # Switch at random time in {2, ..., TT}
      t_star <- sample(2:TT, 1)
      D[idx] <- ifelse(1:TT >= t_star, 1, 0)
    }
  }

  # --- FE components ---
  alpha_i  <- rnorm(N, sd = 1)
  lambda_t <- rnorm(TT, sd = 1)
  eta_i    <- rnorm(N, sd = 0.5)
  mu_t     <- rnorm(TT, sd = 0.5)

  # --- Errors ---
  eps_it <- rnorm(N * TT, sd = sqrt(sigma2_eps))
  nu_it  <- rnorm(N * TT, sd = sqrt(sigma2_nu))

  # --- Y and Z equations (clean case) ---
  Y <- beta * D +
    rep(alpha_i, each = TT) + rep(lambda_t, times = N) + eps_it

  Z <- (gamma_D + gamma_Y * beta) * D +
    rep(eta_i + gamma_Y * alpha_i, each = TT) +
    rep(mu_t + gamma_Y * lambda_t, times = N) +
    (nu_it + gamma_Y * eps_it)

  data.table(
    unit = rep(1:N, each = TT),
    time = rep(1:TT, times = N),
    Y = Y, D = D, Z = Z
  )
}


#' Generate panel data — Mechanism D: Measurement error in Z
#'
#' Z_obs = Z_true + measurement_error
generate_panel_data_mechD <- function(N, TT, beta,
                                      gamma_D, gamma_Y,
                                      sigma2_me,
                                      R2_within = 0.5,
                                      sigma2_eps = 1, sigma2_nu = 1) {

  # --- D components ---
  sigma2_D_within  <- R2_within
  sigma2_D_between <- (1 - R2_within) / 2
  sigma2_D_time    <- (1 - R2_within) / 2

  mu_i_D <- rnorm(N, sd = sqrt(sigma2_D_between))
  tau_t_D <- rnorm(TT, sd = sqrt(sigma2_D_time))
  d_it <- rnorm(N * TT, sd = sqrt(sigma2_D_within))

  D <- rep(mu_i_D, each = TT) + rep(tau_t_D, times = N) + d_it

  # --- FE components ---
  alpha_i  <- rnorm(N, sd = 1)
  lambda_t <- rnorm(TT, sd = 1)
  eta_i    <- rnorm(N, sd = 0.5)
  mu_t     <- rnorm(TT, sd = 0.5)

  # --- Errors ---
  eps_it <- rnorm(N * TT, sd = sqrt(sigma2_eps))
  nu_it  <- rnorm(N * TT, sd = sqrt(sigma2_nu))

  # --- Y equation ---
  Y <- beta * D +
    rep(alpha_i, each = TT) + rep(lambda_t, times = N) + eps_it

  # --- Z true ---
  Z_true <- (gamma_D + gamma_Y * beta) * D +
    rep(eta_i + gamma_Y * alpha_i, each = TT) +
    rep(mu_t + gamma_Y * lambda_t, times = N) +
    (nu_it + gamma_Y * eps_it)

  # --- Z observed = Z_true + measurement error ---
  me <- rnorm(N * TT, sd = sqrt(sigma2_me))
  Z_obs <- Z_true + me

  data.table(
    unit = rep(1:N, each = TT),
    time = rep(1:TT, times = N),
    Y = Y, D = D, Z = Z_obs
  )
}


# =============================================================================
# 2. Scenario Runner (shared across mechanisms)
# =============================================================================

#' Estimate IVB metrics from a panel dataset
#'
#' Fits short, long, and auxiliary models; returns key metrics.
estimate_ivb_metrics <- function(dt, beta) {
  # iid SEs are correct here because DGP errors (eps, nu) are iid by construction.
  # In empirical applications with panel data, clustering would typically be needed.
  m_short <- feols(Y ~ D | unit + time, data = dt, vcov = "iid")
  m_long  <- feols(Y ~ D + Z | unit + time, data = dt, vcov = "iid")
  m_aux   <- feols(Z ~ D | unit + time, data = dt, vcov = "iid")

  b_short <- coef(m_short)[["D"]]
  b_long  <- coef(m_long)[["D"]]
  theta   <- coef(m_long)[["Z"]]
  pi_hat  <- coef(m_aux)[["D"]]

  se_short <- se(m_short)[["D"]]
  se_long  <- se(m_long)[["D"]]

  # Use t(N-1) df for CIs, consistent with v1. This is slightly conservative
  # vs residual df (N*T-N-T-K ~ 5769), yielding t=1.972 vs 1.960.
  t_crit <- qt(0.975, length(unique(dt$unit)) - 1)
  cover_short <- (beta >= b_short - t_crit * se_short) &
                 (beta <= b_short + t_crit * se_short)
  cover_long  <- (beta >= b_long - t_crit * se_long) &
                 (beta <= b_long + t_crit * se_long)

  list(
    b_short = b_short, b_long = b_long,
    theta = theta, pi_hat = pi_hat,
    ivb = b_long - b_short,
    ivb_formula = -theta * pi_hat,
    se_short = se_short, se_long = se_long,
    sd_y = sd(dt$Y),
    cover_short = cover_short, cover_long = cover_long
  )
}


#' Aggregate nsim replications into summary metrics
aggregate_metrics <- function(reps, beta) {
  data.table(
    mean_beta_short       = mean(sapply(reps, `[[`, "b_short")),
    mean_beta_long        = mean(sapply(reps, `[[`, "b_long")),
    mean_ivb              = mean(sapply(reps, `[[`, "ivb")),
    mean_ivb_formula      = mean(sapply(reps, `[[`, "ivb_formula")),
    mean_theta            = mean(sapply(reps, `[[`, "theta")),
    mean_pi               = mean(sapply(reps, `[[`, "pi_hat")),
    mean_abs_ivb_over_beta = mean(abs(sapply(reps, `[[`, "ivb")) / abs(beta)),
    mean_abs_ivb_over_se  = mean(abs(sapply(reps, `[[`, "ivb")) /
                                 sapply(reps, `[[`, "se_long")),
    mean_se_short         = mean(sapply(reps, `[[`, "se_short")),
    mean_se_long          = mean(sapply(reps, `[[`, "se_long")),
    bias_short            = mean(sapply(reps, `[[`, "b_short")) - beta,
    bias_long             = mean(sapply(reps, `[[`, "b_long")) - beta,
    rmse_short            = sqrt(mean((sapply(reps, `[[`, "b_short") - beta)^2)),
    rmse_long             = sqrt(mean((sapply(reps, `[[`, "b_long") - beta)^2)),
    coverage_short        = mean(sapply(reps, `[[`, "cover_short")),
    coverage_long         = mean(sapply(reps, `[[`, "cover_long"))
  )
}


# =============================================================================
# 3. Mechanism A: Between/within D->Z
# =============================================================================

run_scenario_A <- function(params) {
  nsim <- params$nsim
  beta <- params$beta
  reps <- vector("list", nsim)

  for (s in seq_len(nsim)) {
    dt <- generate_panel_data_mechA(
      N = params$N, TT = params$TT, beta = beta,
      gamma_D_btw = params$gamma_D_btw,
      gamma_D_wth = params$gamma_D_wth,
      gamma_Y = params$gamma_Y,
      R2_within = params$R2_within
    )
    reps[[s]] <- estimate_ivb_metrics(dt, beta)
  }

  out <- aggregate_metrics(reps, beta)
  out[, `:=`(
    mechanism   = "A",
    gamma_D_btw = params$gamma_D_btw,
    gamma_D_wth = params$gamma_D_wth,
    gamma_Y     = params$gamma_Y,
    R2_within   = params$R2_within,
    N           = params$N,
    TT          = params$TT,
    beta        = beta
  )]
  out
}


# =============================================================================
# 4. Mechanism B: Between/within Y->Z
# =============================================================================

run_scenario_B <- function(params) {
  nsim <- params$nsim
  beta <- params$beta
  reps <- vector("list", nsim)

  for (s in seq_len(nsim)) {
    dt <- generate_panel_data_mechB(
      N = params$N, TT = params$TT, beta = beta,
      gamma_D = params$gamma_D,
      gamma_Y_btw = params$gamma_Y_btw,
      gamma_Y_wth = params$gamma_Y_wth,
      R2_within = params$R2_within
    )
    reps[[s]] <- estimate_ivb_metrics(dt, beta)
  }

  out <- aggregate_metrics(reps, beta)
  out[, `:=`(
    mechanism   = "B",
    gamma_D     = params$gamma_D,
    gamma_Y_btw = params$gamma_Y_btw,
    gamma_Y_wth = params$gamma_Y_wth,
    R2_within   = params$R2_within,
    N           = params$N,
    TT          = params$TT,
    beta        = beta
  )]
  out
}


# =============================================================================
# 5. Mechanism C: Binary D with staggered adoption
# =============================================================================

run_scenario_C <- function(params) {
  nsim <- params$nsim
  beta <- params$beta
  reps <- vector("list", nsim)

  for (s in seq_len(nsim)) {
    dt <- generate_panel_data_mechC(
      N = params$N, TT = params$TT, beta = beta,
      gamma_D = params$gamma_D,
      gamma_Y = params$gamma_Y,
      prob_switch = params$prob_switch
    )
    reps[[s]] <- estimate_ivb_metrics(dt, beta)
  }

  out <- aggregate_metrics(reps, beta)
  out[, `:=`(
    mechanism   = "C",
    gamma_D     = params$gamma_D,
    gamma_Y     = params$gamma_Y,
    prob_switch = params$prob_switch,
    N           = params$N,
    TT          = params$TT,
    beta        = beta
  )]
  out
}


# =============================================================================
# 6. Mechanism D: Measurement error in Z
# =============================================================================

run_scenario_D <- function(params) {
  nsim <- params$nsim
  beta <- params$beta
  reps <- vector("list", nsim)

  for (s in seq_len(nsim)) {
    dt <- generate_panel_data_mechD(
      N = params$N, TT = params$TT, beta = beta,
      gamma_D = params$gamma_D,
      gamma_Y = params$gamma_Y,
      sigma2_me = params$sigma2_me
    )
    reps[[s]] <- estimate_ivb_metrics(dt, beta)
  }

  out <- aggregate_metrics(reps, beta)
  out[, `:=`(
    mechanism = "D",
    gamma_D   = params$gamma_D,
    gamma_Y   = params$gamma_Y,
    sigma2_me = params$sigma2_me,
    N         = params$N,
    TT        = params$TT,
    beta      = beta
  )]
  out
}


# =============================================================================
# 7. Parameter Grids
# =============================================================================

N_fix  <- 200L
TT_fix <- 30L
beta_fix <- 1.0
nsim_fix <- 500L

# --- Grid A: 4 x 3 x 3 x 3 = 108 scenarios ---
grid_A <- CJ(
  gamma_D_btw = c(0.0, 0.3, 0.6, 0.9),
  gamma_D_wth = c(0.0, 0.2, 0.5),
  gamma_Y     = c(0.0, 0.3, 0.6),
  R2_within   = c(0.1, 0.5, 0.9)
)
grid_A[, `:=`(N = N_fix, TT = TT_fix, beta = beta_fix, nsim = nsim_fix)]

# --- Grid B: 2 x 4 x 3 x 3 = 72 scenarios ---
grid_B <- CJ(
  gamma_D     = c(0.3, 0.6),
  gamma_Y_btw = c(0.0, 0.3, 0.6, 0.9),
  gamma_Y_wth = c(0.0, 0.2, 0.5),
  R2_within   = c(0.1, 0.5, 0.9)
)
grid_B[, `:=`(N = N_fix, TT = TT_fix, beta = beta_fix, nsim = nsim_fix)]

# --- Grid C: 4 x 2 x 2 = 16 scenarios ---
grid_C <- CJ(
  prob_switch = c(0.1, 0.3, 0.5, 0.7),
  gamma_D     = c(0.3, 0.6),
  gamma_Y     = c(0.3, 0.6)
)
grid_C[, `:=`(N = N_fix, TT = TT_fix, beta = beta_fix, nsim = nsim_fix)]

# --- Grid D: 4 x 2 x 2 = 16 scenarios ---
grid_D <- CJ(
  sigma2_me = c(0.0, 0.5, 1.0, 2.0),
  gamma_D   = c(0.3, 0.6),
  gamma_Y   = c(0.3, 0.6)
)
grid_D[, `:=`(N = N_fix, TT = TT_fix, beta = beta_fix, nsim = nsim_fix)]

cat(sprintf("Grid A: %d scenarios\n", nrow(grid_A)))
cat(sprintf("Grid B: %d scenarios\n", nrow(grid_B)))
cat(sprintf("Grid C: %d scenarios\n", nrow(grid_C)))
cat(sprintf("Grid D: %d scenarios\n", nrow(grid_D)))
cat(sprintf("Total:  %d scenarios x %d reps\n",
            nrow(grid_A) + nrow(grid_B) + nrow(grid_C) + nrow(grid_D),
            nsim_fix))


# =============================================================================
# 8. Run All Mechanisms (parallel)
# =============================================================================

run_mechanism <- function(grid, run_fn, label, seed) {
  cat(sprintf("\n--- Mechanism %s: %d scenarios ---\n", label, nrow(grid)))
  t0 <- Sys.time()

  param_list <- lapply(seq_len(nrow(grid)), function(i) as.list(grid[i]))

  plan(multisession, workers = 4L)
  set.seed(seed)
  res_list <- future_lapply(param_list, run_fn, future.seed = TRUE)
  plan(sequential)

  res <- rbindlist(res_list, fill = TRUE)
  elapsed <- as.numeric(difftime(Sys.time(), t0, units = "mins"))
  cat(sprintf("  Done in %.1f min.\n", elapsed))
  res
}

cat("\nStarting v4 simulation...\n")
t_total_start <- Sys.time()

results_A <- run_mechanism(grid_A, run_scenario_A, "A", seed = 2026)
results_B <- run_mechanism(grid_B, run_scenario_B, "B", seed = 2027)
results_C <- run_mechanism(grid_C, run_scenario_C, "C", seed = 2028)
results_D <- run_mechanism(grid_D, run_scenario_D, "D", seed = 2029)

t_total_end <- Sys.time()
cat(sprintf("\nAll mechanisms completed in %.1f minutes.\n",
            as.numeric(difftime(t_total_end, t_total_start, units = "mins"))))


# =============================================================================
# 9. Save Results
# =============================================================================

fwrite(results_A, "sim_ivb_twfe_v4_mechA.csv")
fwrite(results_B, "sim_ivb_twfe_v4_mechB.csv")
fwrite(results_C, "sim_ivb_twfe_v4_mechC.csv")
fwrite(results_D, "sim_ivb_twfe_v4_mechD.csv")

cat("Results saved:\n")
cat(sprintf("  Mechanism A: %d rows x %d cols\n", nrow(results_A), ncol(results_A)))
cat(sprintf("  Mechanism B: %d rows x %d cols\n", nrow(results_B), ncol(results_B)))
cat(sprintf("  Mechanism C: %d rows x %d cols\n", nrow(results_C), ncol(results_C)))
cat(sprintf("  Mechanism D: %d rows x %d cols\n", nrow(results_D), ncol(results_D)))


# =============================================================================
# 10. Sanity Checks
# =============================================================================

cat("\n=== SANITY CHECKS ===\n")

# --- Check A1: FWL identity (mean |IVB_emp - IVB_formula| < 0.01) ---
cat("\n[A] FWL identity check:\n")
max_disc_A <- max(abs(results_A$mean_ivb - results_A$mean_ivb_formula))
cat(sprintf("  Mechanism A: %.6f %s\n",
            max_disc_A, ifelse(max_disc_A < 0.01, "OK", "WARNING")))
max_disc_B <- max(abs(results_B$mean_ivb - results_B$mean_ivb_formula))
cat(sprintf("  Mechanism B: %.6f %s\n",
            max_disc_B, ifelse(max_disc_B < 0.01, "OK", "WARNING")))
max_disc_C <- max(abs(results_C$mean_ivb - results_C$mean_ivb_formula))
cat(sprintf("  Mechanism C: %.6f %s\n",
            max_disc_C, ifelse(max_disc_C < 0.01, "OK", "WARNING")))
max_disc_D <- max(abs(results_D$mean_ivb - results_D$mean_ivb_formula))
cat(sprintf("  Mechanism D: %.6f %s\n",
            max_disc_D, ifelse(max_disc_D < 0.01, "OK", "WARNING")))

# --- Check A2: pi ≈ gamma_D_wth + gamma_Y * beta ---
cat("\n[A] pi = gamma_D_wth + gamma_Y*beta check:\n")
results_A[, pi_theory := gamma_D_wth + gamma_Y * beta]
results_A[, pi_error := abs(mean_pi - pi_theory)]
max_pi_err <- max(results_A$pi_error)
cat(sprintf("  Max |pi_hat - pi_theory|: %.4f %s\n",
            max_pi_err, ifelse(max_pi_err < 0.05, "OK", "CHECK")))

# --- Check A3: IVB independent of gamma_D_btw ---
cat("\n[A] IVB vs gamma_D_btw (should be ~constant within gamma_D_wth x gamma_Y):\n")
check_btw <- results_A[gamma_Y == 0.3 & gamma_D_wth == 0.2 & R2_within == 0.5,
                        .(gamma_D_btw, ivb_pct = round(mean_abs_ivb_over_beta * 100, 2))]
print(check_btw)

# --- Check A4: Backward compatibility (gamma_D_btw == gamma_D_wth) ---
# When btw == wth, should match v1 behavior
cat("\n[A] Backward compat (btw=wth=0.5, gamma_Y=0.5, R2w=0.5):\n")
compat <- results_A[gamma_D_btw == 0.0 & gamma_D_wth == 0.5 & gamma_Y == 0.6 & R2_within == 0.5]
if (nrow(compat) > 0) {
  cat(sprintf("  mean_ivb = %.4f, mean_pi = %.4f\n",
              compat$mean_ivb, compat$mean_pi))
}

# --- Check B: theta* independent of gamma_Y_btw ---
cat("\n[B] theta* vs gamma_Y_btw (should be ~constant within gamma_Y_wth x gamma_D):\n")
check_btw_B <- results_B[gamma_D == 0.3 & gamma_Y_wth == 0.2 & R2_within == 0.5,
                          .(gamma_Y_btw, theta = round(mean_theta, 4),
                            ivb_pct = round(mean_abs_ivb_over_beta * 100, 2))]
print(check_btw_B)
theta_range_B <- diff(range(check_btw_B$theta))
cat(sprintf("  Range of theta across gamma_Y_btw: %.4f %s\n",
            theta_range_B, ifelse(abs(theta_range_B) < 0.05, "OK", "CHECK")))

# --- Check C: IVB/SE decreases with lower prob_switch ---
cat("\n[C] IVB/SE vs prob_switch (should decrease with fewer switchers):\n")
check_C <- results_C[gamma_D == 0.3 & gamma_Y == 0.3,
                      .(prob_switch, ivb_se = round(mean_abs_ivb_over_se, 2),
                        se_long = round(mean_se_long, 4))]
print(check_C)

# --- Check D: |theta*| decreases with sigma2_me ---
cat("\n[D] |theta*| vs sigma2_me (should decrease — attenuation bias):\n")
check_D <- results_D[gamma_D == 0.3 & gamma_Y == 0.3,
                      .(sigma2_me, theta = round(mean_theta, 4),
                        ivb_pct = round(mean_abs_ivb_over_beta * 100, 2))]
print(check_D)

# --- Check coverage (all mechanisms) ---
cat("\n[All] Coverage (short model, should be ~0.95):\n")
cat(sprintf("  A: mean = %.3f, range = [%.3f, %.3f]\n",
            mean(results_A$coverage_short),
            min(results_A$coverage_short), max(results_A$coverage_short)))
cat(sprintf("  B: mean = %.3f, range = [%.3f, %.3f]\n",
            mean(results_B$coverage_short),
            min(results_B$coverage_short), max(results_B$coverage_short)))
cat(sprintf("  C: mean = %.3f, range = [%.3f, %.3f]\n",
            mean(results_C$coverage_short),
            min(results_C$coverage_short), max(results_C$coverage_short)))
cat(sprintf("  D: mean = %.3f, range = [%.3f, %.3f]\n",
            mean(results_D$coverage_short),
            min(results_D$coverage_short), max(results_D$coverage_short)))

# Cleanup temporary column
results_A[, c("pi_theory", "pi_error") := NULL]

cat("\n=== DONE ===\n")

# Record session info
writeLines(capture.output(sessionInfo()), "sim_ivb_twfe_v4_sessioninfo.txt")
