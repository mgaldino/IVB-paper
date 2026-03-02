# ============================================================================
# sim_mechC_adl.R
# Binary D (staggered adoption) with dynamic DGP + 9 estimation strategies
#
# Purpose: Test whether ADL(all lags) reduces the large IVB observed with
#          binary treatment in v4 Mechanism C. Uses dynamic DGP so that
#          ADL specifications are correctly motivated.
#
# DGP (unit i, period t):
#   D_it = 1(t >= T_i*)   — staggered binary treatment (exogenous)
#   Y_it = alpha^Y_i + beta D_it + gamma_Y Z_{i,t-1} + rho_Y Y_{i,t-1} + e_it
#   Z_it = alpha^Z_i + delta_D D_it + delta_Y Y_it + rho_Z Z_{i,t-1} + nu_it
#
# Z is dual-role: collider (D -> Z <- Y) and confounder (Z_lag -> Y).
# D is exogenous binary — no Z -> D feedback.
# Burn-in (100 periods) ensures Y and Z reach stationarity before
# observation window. Switchers have D=0 during burn-in and switch
# during observation window.
#
# 9 models + IVB components:
#   1. twfe_s       Y ~ D                              | FE
#   2. twfe_l       Y ~ D + Z_lag                      | FE
#   3. adl_Ylag     Y ~ D + Y_lag                      | FE
#   4. adl_full     Y ~ D + Z_lag + Y_lag              | FE
#   5. adl_Dlag     Y ~ D + D_lag                      | FE
#   6. adl_DYlag    Y ~ D + D_lag + Y_lag              | FE
#   7. adl_DZlag    Y ~ D + D_lag + Z_lag              | FE
#   8. adl_all      Y ~ D + D_lag + Y_lag + Z_lag      | FE
#   9. adl_all_nofe Y ~ D + D_lag + Y_lag + Z_lag      (no FE)
#   + auxiliary:    Z_lag ~ D | FE  (for theta* and pi)
#
# Grid: prob_switch x delta_D x delta_Y x rho_Z = 4x2x2x2 = 32 scenarios x 500 reps
# Parallelized: future_lapply, 4 workers
# ============================================================================

library(data.table)
library(fixest)
library(future.apply)

set.seed(2026)

# ---- Fixed parameters ----
P <- list(N = 100, TT = 30, T_burn = 100, beta = 1,
          rho_Y = 0.5,
          gamma_Y = 0.2,   # Z_lag -> Y (confounder channel)
          sigma_aZ = 0.5)
N_REPS <- 500L

# ---- DGP: binary D with dynamics ----
sim_binary_dynamic <- function(N, TT, T_burn, beta, rho_Y,
                               gamma_Y, delta_D, delta_Y,
                               rho_Z, sigma_aZ, prob_switch) {
  T_sim <- TT + T_burn

  # Unit types: never-treated, switcher, always-treated
  prob_never  <- (1 - prob_switch) / 2
  prob_always <- (1 - prob_switch) / 2
  unit_type <- sample(c("never", "switcher", "always"), N, replace = TRUE,
                      prob = c(prob_never, prob_switch, prob_always))

  # Switch timing: within observation window only [T_burn+2, T_sim]
  # This ensures all switchers have at least 1 pre-treatment period observed
  t_star <- rep(NA_integer_, N)
  for (i in 1:N) {
    if (unit_type[i] == "switcher") {
      t_star[i] <- sample((T_burn + 2):T_sim, 1)
    }
  }

  # Unit FE
  alpha_Y <- rnorm(N, 0, 1)
  alpha_Z <- rnorm(N, 0, sigma_aZ)

  rows <- vector("list", N)
  explosive <- FALSE

  for (i in 1:N) {
    D <- Y <- Z <- numeric(T_sim)

    # Period 1: always-treated start with D=1, rest with D=0
    D[1] <- if (unit_type[i] == "always") 1 else 0
    Y[1] <- alpha_Y[i] + beta * D[1] + rnorm(1)
    Z[1] <- alpha_Z[i] + delta_D * D[1] + delta_Y * Y[1] + rnorm(1)

    for (t in 2:T_sim) {
      # Binary D: deterministic based on type and timing
      if (unit_type[i] == "never") {
        D[t] <- 0
      } else if (unit_type[i] == "always") {
        D[t] <- 1
      } else {
        D[t] <- if (t >= t_star[i]) 1 else 0
      }

      e  <- rnorm(1)
      nu <- rnorm(1)
      Y[t] <- alpha_Y[i] + beta * D[t] + gamma_Y * Z[t - 1] +
              rho_Y * Y[t - 1] + e
      Z[t] <- alpha_Z[i] + delta_D * D[t] + delta_Y * Y[t] +
              rho_Z * Z[t - 1] + nu

      if (abs(Y[t]) > 1e6 || abs(Z[t]) > 1e6) {
        explosive <- TRUE
        break
      }
    }
    if (explosive) return(NULL)

    idx     <- (T_burn + 1):T_sim
    idx_lag <- T_burn:(T_sim - 1)   # one period earlier for lags
    rows[[i]] <- data.table(
      id = i, time = seq_along(idx),
      D = D[idx], Y = Y[idx], Z = Z[idx],
      D_lag = D[idx_lag],
      Y_lag = Y[idx_lag],
      Z_lag = Z[idx_lag]
    )
  }

  dt <- rbindlist(rows)
  dt[, `:=`(id_f = factor(id), time_f = factor(time))]
  dt
}


# ---- Estimation: 9 models + IVB components ----
# With binary staggered D, D and D_lag are highly collinear within units
# (they differ only at the switch period). Models 5-8 may produce NA for
# D_lag if fixest drops it. We check for this and return NULL if D coef
# is missing from any model.
est_binary_models <- function(dt) {
  tryCatch({
    # 9 standard models
    m1 <- feols(Y ~ D | id_f + time_f, dt, vcov = "iid")
    m2 <- feols(Y ~ D + Z_lag | id_f + time_f, dt, vcov = "iid")
    m3 <- feols(Y ~ D + Y_lag | id_f + time_f, dt, vcov = "iid")
    m4 <- feols(Y ~ D + Z_lag + Y_lag | id_f + time_f, dt, vcov = "iid")
    m5 <- feols(Y ~ D + D_lag | id_f + time_f, dt, vcov = "iid")
    m6 <- feols(Y ~ D + D_lag + Y_lag | id_f + time_f, dt, vcov = "iid")
    m7 <- feols(Y ~ D + D_lag + Z_lag | id_f + time_f, dt, vcov = "iid")
    m8 <- feols(Y ~ D + D_lag + Y_lag + Z_lag | id_f + time_f, dt, vcov = "iid")
    m9 <- lm(Y ~ D + D_lag + Y_lag + Z_lag, data = dt)

    # Check: if D_lag was dropped by fixest due to collinearity, D coef
    # absorbs the combined effect and is not comparable. Discard rep.
    if (is.na(coef(m5)["D_lag"]) || is.na(coef(m8)["D_lag"])) return(NULL)

    # Auxiliary regression for IVB formula: Z_lag ~ D | FE
    m_aux <- feols(Z_lag ~ D | id_f + time_f, dt, vcov = "iid")

    c(twfe_s      = coef(m1)["D"],
      twfe_l      = coef(m2)["D"],
      adl_Ylag    = coef(m3)["D"],
      adl_full    = coef(m4)["D"],
      adl_Dlag    = coef(m5)["D"],
      adl_DYlag   = coef(m6)["D"],
      adl_DZlag   = coef(m7)["D"],
      adl_all     = coef(m8)["D"],
      adl_all_nofe = coef(m9)["D"],
      # IVB components (unname to avoid .Z_lag suffix)
      theta        = unname(coef(m2)["Z_lag"]),
      pi_hat       = unname(coef(m_aux)["D"]),
      se_short     = unname(se(m1)["D"]),
      se_long      = unname(se(m2)["D"]),
      se_adl_all   = unname(se(m8)["D"]))
  }, error = function(e) {
    warning(sprintf("est_binary_models failed: %s", e$message))
    NULL
  })
}


# ---- Grid: 4 x 2 x 2 x 2 = 32 scenarios ----
grid <- CJ(
  prob_switch = c(0.1, 0.3, 0.5, 0.7),
  delta_D     = c(0.1, 0.3),
  delta_Y     = c(0.1, 0.3),
  rho_Z       = c(0.5, 0.7)
)

cat(sprintf("Grid: %d scenarios x %d reps\n", nrow(grid), N_REPS))
cat(sprintf("DGP: beta=%.1f, rho_Y=%.1f, gamma_Y=%.1f\n",
            P$beta, P$rho_Y, P$gamma_Y))
cat(sprintf("     sigma_aZ=%.1f, N=%d, TT=%d, T_burn=%d\n",
            P$sigma_aZ, P$N, P$TT, P$T_burn))
cat("Binary D with staggered adoption. Switch only in observation window.\n")
cat("delta_D x delta_Y varied in grid.\n\n")


# ---- Run (parallel over scenarios) ----
cat(rep("=", 80), "\n", sep = "")
cat("SIM MECHC-ADL: Binary D + 9 estimation strategies\n")
cat(rep("=", 80), "\n\n")

plan(multisession, workers = 4)

run_scenario <- function(g) {
  ps <- grid$prob_switch[g]
  dD <- grid$delta_D[g]
  dY <- grid$delta_Y[g]
  rz <- grid$rho_Z[g]

  n_explosive  <- 0L
  n_collinear  <- 0L
  reps_list    <- vector("list", N_REPS)

  for (s in 1:N_REPS) {
    dt <- sim_binary_dynamic(P$N, P$TT, P$T_burn, P$beta, P$rho_Y,
                             P$gamma_Y, dD, dY,
                             rz, P$sigma_aZ, ps)

    if (is.null(dt)) {
      n_explosive <- n_explosive + 1L
      next
    }

    est <- est_binary_models(dt)
    if (is.null(est)) {
      n_collinear <- n_collinear + 1L
      next
    }
    reps_list[[s]] <- data.table::as.data.table(as.list(est))[, sim := s]
  }

  reps_list <- reps_list[!vapply(reps_list, is.null, logical(1))]
  if (length(reps_list) == 0) {
    return(list(res = NULL, n_explosive = N_REPS, n_collinear = 0L))
  }

  res_g <- data.table::rbindlist(reps_list)
  res_g[, `:=`(prob_switch = ps, delta_D = dD, delta_Y = dY, rho_Z = rz)]

  list(res = res_g, n_explosive = n_explosive, n_collinear = n_collinear)
}

set.seed(2026200)
t0 <- proc.time()
par_out <- future_lapply(1:nrow(grid), run_scenario, future.seed = TRUE)
elapsed <- (proc.time() - t0)[3]
plan(sequential)

cat(sprintf("\nTotal time: %.1fs (parallel, 4 workers)\n", elapsed))

# Unpack results
all_res           <- lapply(par_out, `[[`, "res")
explosive_counts  <- vapply(par_out, `[[`, integer(1), "n_explosive")
collinear_counts  <- vapply(par_out, `[[`, integer(1), "n_collinear")
discarded_counts  <- explosive_counts + collinear_counts

for (g in 1:nrow(grid)) {
  cat(sprintf("[%2d/%d] prob_switch=%.1f delta_D=%.1f delta_Y=%.1f rho_Z=%.2f  explosive: %d  collinear: %d  total_disc: %d/%d\n",
              g, nrow(grid), grid$prob_switch[g], grid$delta_D[g],
              grid$delta_Y[g], grid$rho_Z[g],
              explosive_counts[g], collinear_counts[g],
              discarded_counts[g], N_REPS))
}

results <- rbindlist(all_res[!vapply(all_res, is.null, logical(1))])


# ---- Summary ----
beta_true <- P$beta

mod_cols <- c("twfe_s.D", "twfe_l.D", "adl_Ylag.D", "adl_full.D",
              "adl_Dlag.D", "adl_DYlag.D", "adl_DZlag.D", "adl_all.D",
              "adl_all_nofe.D")
mod_names <- c("twfe_s", "twfe_l", "adl_Ylag", "adl_full",
               "adl_Dlag", "adl_DYlag", "adl_DZlag", "adl_all",
               "adl_all_nofe")

summ <- results[, {
  out <- list()
  for (j in seq_along(mod_cols)) {
    vals <- get(mod_cols[j])
    out[[paste0(mod_names[j], "_bias")]] <- mean(vals) - beta_true
    out[[paste0(mod_names[j], "_mcse")]] <- sd(vals) / sqrt(.N)
    out[[paste0(mod_names[j], "_sd")]]   <- sd(vals)
    out[[paste0(mod_names[j], "_rmse")]] <- sqrt(mean((vals - beta_true)^2))
  }
  # IVB components
  out$mean_theta   <- mean(theta)
  out$mean_pi      <- mean(pi_hat)
  out$mean_ivb     <- mean(twfe_l.D - twfe_s.D)
  out$mean_ivb_formula <- mean(-theta * pi_hat)
  out$mean_se_short <- mean(se_short)
  out$mean_se_long  <- mean(se_long)
  out$mean_se_adl_all <- mean(se_adl_all)
  out$mean_abs_ivb_over_beta <- mean(abs(twfe_l.D - twfe_s.D) / abs(beta_true))
  out$mean_abs_ivb_over_se   <- mean(abs(twfe_l.D - twfe_s.D) / se_long)
  out$n_sims <- .N
  out
}, by = .(prob_switch, delta_D, delta_Y, rho_Z)]

# Add discarded counts
disc_dt <- data.table(grid[, .(prob_switch, delta_D, delta_Y, rho_Z)],
                      n_explosive = explosive_counts,
                      n_collinear = collinear_counts,
                      n_discarded = discarded_counts)
summ <- merge(summ, disc_dt, by = c("prob_switch", "delta_D", "delta_Y", "rho_Z"),
              all.x = TRUE)


# ---- Print results ----
cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("RESULTS: BIAS BY MODEL (beta_true = 1)\n")
cat(rep("=", 80), "\n\n")

for (rz in c(0.5, 0.7)) {
  cat(sprintf("--- rho_Z = %.2f ---\n\n", rz))
  s <- summ[rho_Z == rz]

  cat("BIAS (estimate - beta_true):\n")
  bias_tab <- s[, .(prob_switch, delta_D, delta_Y, n_sims, n_discarded,
    `TWFE_s`    = round(twfe_s_bias, 4),
    `TWFE_l`    = round(twfe_l_bias, 4),
    `ADL_Ylag`  = round(adl_Ylag_bias, 4),
    `ADL_full`  = round(adl_full_bias, 4),
    `ADL_Dlag`  = round(adl_Dlag_bias, 4),
    `ADL_DYlag` = round(adl_DYlag_bias, 4),
    `ADL_all`   = round(adl_all_bias, 4),
    `ADL_noFE`  = round(adl_all_nofe_bias, 4))]
  print(bias_tab)

  cat("\nRMSE:\n")
  rmse_tab <- s[, .(prob_switch, delta_D, delta_Y,
    `TWFE_s`    = round(twfe_s_rmse, 4),
    `TWFE_l`    = round(twfe_l_rmse, 4),
    `ADL_full`  = round(adl_full_rmse, 4),
    `ADL_all`   = round(adl_all_rmse, 4),
    `ADL_noFE`  = round(adl_all_nofe_rmse, 4))]
  print(rmse_tab)
  cat("\n")
}


# ---- IVB Decomposition ----
cat(rep("=", 80), "\n", sep = "")
cat("IVB DECOMPOSITION\n")
cat(rep("=", 80), "\n\n")

ivb_tab <- summ[, .(prob_switch, delta_D, delta_Y, rho_Z,
  `theta`       = round(mean_theta, 4),
  `pi`          = round(mean_pi, 4),
  `IVB`         = round(mean_ivb, 4),
  `IVB_formula` = round(mean_ivb_formula, 4),
  `|IVB/beta|`  = round(mean_abs_ivb_over_beta, 4),
  `|IVB/SE|`    = round(mean_abs_ivb_over_se, 4))]
print(ivb_tab)


# ---- Key comparison: ADL_all vs TWFE ----
cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("KEY COMPARISON: ADL_all vs TWFE (binary D)\n")
cat(rep("=", 80), "\n\n")

comp_tab <- summ[, .(prob_switch, delta_D, delta_Y, rho_Z,
  `|bias|_TWFE_s`  = round(abs(twfe_s_bias), 4),
  `|bias|_TWFE_l`  = round(abs(twfe_l_bias), 4),
  `|bias|_ADL_all` = round(abs(adl_all_bias), 4),
  `RMSE_TWFE_s`    = round(twfe_s_rmse, 4),
  `RMSE_TWFE_l`    = round(twfe_l_rmse, 4),
  `RMSE_ADL_all`   = round(adl_all_rmse, 4),
  `SE_TWFE_s`      = round(mean_se_short, 4),
  `SE_ADL_all`     = round(mean_se_adl_all, 4))]
print(comp_tab)


# ---- Sanity checks ----
cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("SANITY CHECKS\n")
cat(rep("=", 80), "\n\n")

# 1. IVB formula matches computed IVB (FWL identity: b_long - b_short = -theta*pi)
# Small discrepancy expected from Jensen's inequality: E[-theta*pi] != -E[theta]*E[pi]
max_formula_err <- summ[, max(abs(mean_ivb - mean_ivb_formula))]
cat(sprintf("1. Max |IVB - IVB_formula|: %.6f (should be < 0.01)\n", max_formula_err))

# 2. Discarded breakdown (explosive should be 0; some collinearity expected with low prob_switch)
cat(sprintf("2. Explosive: total %d (should be 0). Collinear: total %d (expect some with prob_switch=0.1)\n",
            sum(explosive_counts), sum(collinear_counts)))
cat(sprintf("   Max discarded per scenario: %d/%d\n", max(discarded_counts), N_REPS))

# 3. ADL_all bias direction check (should be negative from Nickell bias)
cat("3. ADL_all bias sign (expect mostly negative from Nickell):\n")
cat(sprintf("   Range: [%.4f, %.4f]\n", min(summ$adl_all_bias), max(summ$adl_all_bias)))

# 4. TWFE_s bias (omitted Z_lag, Y_lag -> expect OVB)
cat("4. TWFE_s bias range:\n")
cat(sprintf("   Range: [%.4f, %.4f]\n", min(summ$twfe_s_bias), max(summ$twfe_s_bias)))

cat("\n")


# ---- Save ----
fwrite(results, "sim_mechC_adl_raw.csv")
fwrite(summ, "sim_mechC_adl_results.csv")

timing <- data.table(
  step = "total", elapsed_sec = round(elapsed, 1),
  n_scenarios = nrow(grid), n_reps = N_REPS, n_workers = 4L
)
fwrite(timing, "sim_mechC_adl_timing.csv")

sink("sim_mechC_adl_sessioninfo.txt")
cat("sim_mechC_adl.R\n")
cat(format(Sys.time()), "\n\n")
print(sessionInfo())
sink()

cat("\nDone. Files saved:\n")
cat("  sim_mechC_adl_raw.csv\n")
cat("  sim_mechC_adl_results.csv\n")
cat("  sim_mechC_adl_timing.csv\n")
cat("  sim_mechC_adl_sessioninfo.txt\n")
