# ============================================================================
# sim_feedback_Y_to_D.R
# Feedback: Y_{t-1} -> D_t (strict exogeneity violation) with dual-role Z
#
# Purpose: Test how feedback from outcome to treatment affects IVB and
#          whether ADL specifications remain robust under strict exogeneity
#          violation. This is the boundary condition for the paper's claim
#          that ADL+FE is the practical choice.
#
# DGP (unit i, period t):
#   D_it = α^D_i + φ Y_{i,t-1} + ρ_D D_{i,t-1} + γ_D Z_{i,t-1} + u_it
#   Y_it = α^Y_i + β D_it + γ_Y Z_{i,t-1} + ρ_Y Y_{i,t-1} + e_it
#   Z_it = α^Z_i + δ_D D_it + δ_Y Y_it + ρ_Z Z_{i,t-1} + ν_it
#
# φ ≠ 0 introduces feedback Y_{t-1} → D_t (violation of strict exogeneity).
# φ = 0 reduces to the dual_role_z baseline.
# Z is dual-role: collider (D → Z ← Y) and confounder (Z_lag → Y, Z_lag → D).
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
#   9. adl_all_nofe Y ~ D + D_lag + Y_lag + Z_lag      (no FE — benchmark)
#   + auxiliary:    Z_lag ~ D | FE  (for theta* and pi)
#
# Grid: phi x rho_Z = 5 x 2 = 10 scenarios x 500 reps
# Parallelized: future_lapply, 4 workers
# ============================================================================

library(data.table)
library(fixest)
library(future.apply)

set.seed(2026)

# ---- Fixed parameters ----
# Match dual_role_z defaults so phi=0 reproduces baseline
P <- list(N = 100, TT = 30, T_burn = 100, beta = 1,
          rho_Y = 0.5, rho_D = 0.5,
          gamma_D = 0.15,  # Z_lag -> D (confounder channel)
          gamma_Y = 0.2,   # Z_lag -> Y (confounder channel)
          delta_D = 0.1,   # D -> Z (collider channel)
          delta_Y = 0.1,   # Y -> Z (collider channel)
          sigma_aZ = 0.5)
N_REPS <- 500L

# ---- DGP: continuous D with Y_{t-1} feedback ----
sim_feedback <- function(N, TT, T_burn, beta, rho_Y, rho_D,
                         gamma_D, gamma_Y, delta_D, delta_Y,
                         rho_Z, sigma_aZ, phi) {
  T_sim <- TT + T_burn

  alpha_D <- rnorm(N, 0, 1)
  alpha_Y <- rnorm(N, 0, 1)
  alpha_Z <- rnorm(N, 0, sigma_aZ)

  rows <- vector("list", N)

  for (i in 1:N) {
    explosive <- FALSE
    D <- Y <- Z <- numeric(T_sim)
    D[1] <- alpha_D[i] + rnorm(1)
    Y[1] <- alpha_Y[i] + beta * D[1] + rnorm(1)
    Z[1] <- alpha_Z[i] + delta_D * D[1] + delta_Y * Y[1] + rnorm(1)

    for (t in 2:T_sim) {
      u  <- rnorm(1)
      e  <- rnorm(1)
      nu <- rnorm(1)

      D[t] <- alpha_D[i] + phi * Y[t - 1] + rho_D * D[t - 1] +
              gamma_D * Z[t - 1] + u
      Y[t] <- alpha_Y[i] + beta * D[t] + gamma_Y * Z[t - 1] +
              rho_Y * Y[t - 1] + e
      Z[t] <- alpha_Z[i] + delta_D * D[t] + delta_Y * Y[t] +
              rho_Z * Z[t - 1] + nu

      if (abs(Y[t]) > 1e6 || abs(Z[t]) > 1e6 || abs(D[t]) > 1e6) {
        explosive <- TRUE
        break
      }
    }
    if (explosive) return(NULL)

    # Within-window lags (not pulling from burn-in)
    idx <- (T_burn + 1):T_sim
    rows[[i]] <- data.table(
      id = i, time = seq_along(idx),
      D = D[idx], Y = Y[idx], Z = Z[idx],
      D_lag = c(NA, D[idx[-length(idx)]]),
      Y_lag = c(NA, Y[idx[-length(idx)]]),
      Z_lag = c(NA, Z[idx[-length(idx)]])
    )
  }

  dt <- rbindlist(rows)
  dt <- dt[complete.cases(dt)]   # drop first period (no within-window lag)
  dt[, `:=`(id_f = factor(id), time_f = factor(time))]
  dt
}


# ---- Estimation: 9 models + IVB components ----
est_feedback_models <- function(dt) {
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
    warning(sprintf("est_feedback_models failed: %s", e$message))
    NULL
  })
}


# ---- Grid: 5 x 2 = 10 scenarios ----
grid <- CJ(
  phi   = c(0, 0.05, 0.1, 0.2, 0.3),
  rho_Z = c(0.5, 0.7)
)

# ---- Stationarity check: reduced-form VAR(1) for (D_t, Y_t, Z_t) ----
# The structural system is:
#   D_t = ρ_D D_{t-1} + φ Y_{t-1} + γ_D Z_{t-1} + ...
#   Y_t = β D_t + ρ_Y Y_{t-1} + γ_Y Z_{t-1} + ...
#   Z_t = δ_D D_t + δ_Y Y_t + ρ_Z Z_{t-1} + ...
#
# Substituting D_t into Y_t, then both into Z_t, gives the reduced form:
#   D_t = ρ_D D_{t-1} + φ Y_{t-1} + γ_D Z_{t-1}
#   Y_t = β·ρ_D D_{t-1} + (ρ_Y + β·φ) Y_{t-1} + (β·γ_D + γ_Y) Z_{t-1}
#   Z_t = (δ_D+δ_Y·β)·ρ_D D_{t-1} + ((δ_D+δ_Y·β)·φ + δ_Y·ρ_Y) Y_{t-1}
#         + ((δ_D+δ_Y·β)·γ_D + δ_Y·γ_Y + ρ_Z) Z_{t-1}
cat("Stationarity check (3x3 VAR companion matrix eigenvalues):\n")
for (g in 1:nrow(grid)) {
  ph <- grid$phi[g]
  rz <- grid$rho_Z[g]
  b  <- P$beta
  dD <- P$delta_D
  dY <- P$delta_Y
  rD <- P$rho_D
  rY <- P$rho_Y
  gD <- P$gamma_D
  gY <- P$gamma_Y
  a  <- dD + dY * b   # total D→Z effect (direct + through Y)

  # Companion matrix (rows = D_t, Y_t, Z_t; cols = D_{t-1}, Y_{t-1}, Z_{t-1})
  A <- matrix(c(
    rD,      ph,            gD,
    b * rD,  rY + b * ph,   b * gD + gY,
    a * rD,  a * ph + dY * rY,  a * gD + dY * gY + rz
  ), nrow = 3, byrow = TRUE)

  max_eig <- max(abs(eigen(A, only.values = TRUE)$values))
  cat(sprintf("  [%2d] phi=%.2f rho_Z=%.2f  max|eig|=%.4f %s\n",
              g, ph, rz, max_eig, ifelse(max_eig >= 1, "UNSTABLE!", "OK")))
  if (max_eig >= 1) {
    stop(sprintf("Unstable DGP at grid row %d: phi=%.2f, rho_Z=%.2f, max|eig|=%.4f",
                 g, ph, rz, max_eig))
  }
}
cat(sprintf("  All %d scenarios stable (max|eig| < 1).\n\n", nrow(grid)))

cat(sprintf("Grid: %d scenarios x %d reps\n", nrow(grid), N_REPS))
cat(sprintf("DGP: beta=%.1f, rho_Y=%.1f, rho_D=%.1f, gamma_D=%.2f, gamma_Y=%.2f\n",
            P$beta, P$rho_Y, P$rho_D, P$gamma_D, P$gamma_Y))
cat(sprintf("     delta_D=%.1f, delta_Y=%.1f, sigma_aZ=%.1f\n",
            P$delta_D, P$delta_Y, P$sigma_aZ))
cat(sprintf("     N=%d, TT=%d, T_burn=%d\n", P$N, P$TT, P$T_burn))
cat("Feedback: phi * Y_{t-1} -> D_t (strict exogeneity violation)\n")
cat("phi=0 reproduces dual_role_z baseline.\n\n")


# ---- Run (parallel over scenarios) ----
cat(rep("=", 80), "\n", sep = "")
cat("SIM FEEDBACK Y->D: Strict exogeneity violation + 9 estimation strategies\n")
cat(rep("=", 80), "\n\n")

dir.create("results", showWarnings = FALSE)

plan(multisession, workers = 4)
on.exit(plan(sequential), add = TRUE)

run_scenario <- function(g) {
  ph <- grid$phi[g]
  rz <- grid$rho_Z[g]

  n_explosive  <- 0L
  n_est_failed <- 0L
  reps_list    <- vector("list", N_REPS)

  for (s in 1:N_REPS) {
    dt <- sim_feedback(P$N, P$TT, P$T_burn, P$beta, P$rho_Y, P$rho_D,
                       P$gamma_D, P$gamma_Y, P$delta_D, P$delta_Y,
                       rz, P$sigma_aZ, ph)

    if (is.null(dt)) {
      n_explosive <- n_explosive + 1L
      next
    }

    est <- est_feedback_models(dt)
    if (is.null(est)) {
      n_est_failed <- n_est_failed + 1L
      next
    }
    reps_list[[s]] <- data.table::as.data.table(as.list(est))[, sim := s]
  }

  reps_list <- reps_list[!vapply(reps_list, is.null, logical(1))]
  if (length(reps_list) == 0) {
    return(list(res = NULL, n_explosive = N_REPS, n_est_failed = 0L))
  }

  res_g <- data.table::rbindlist(reps_list)
  res_g[, `:=`(phi = ph, rho_Z = rz)]

  list(res = res_g, n_explosive = n_explosive, n_est_failed = n_est_failed)
}

set.seed(2026300)
t0 <- proc.time()
par_out <- future_lapply(1:nrow(grid), run_scenario, future.seed = TRUE)
elapsed <- (proc.time() - t0)[3]
plan(sequential)

cat(sprintf("\nTotal time: %.1fs (parallel, 4 workers)\n", elapsed))

# Unpack results
all_res           <- lapply(par_out, `[[`, "res")
explosive_counts  <- vapply(par_out, `[[`, integer(1), "n_explosive")
est_failed_counts <- vapply(par_out, `[[`, integer(1), "n_est_failed")
discarded_counts  <- explosive_counts + est_failed_counts

for (g in 1:nrow(grid)) {
  cat(sprintf("[%2d/%d] phi=%.2f rho_Z=%.2f  explosive: %d  est_failed: %d  total_disc: %d/%d\n",
              g, nrow(grid), grid$phi[g], grid$rho_Z[g],
              explosive_counts[g], est_failed_counts[g],
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
}, by = .(phi, rho_Z)]

# Add explosive counts
disc_dt <- data.table(grid[, .(phi, rho_Z)],
                      n_explosive = explosive_counts)
summ <- merge(summ, disc_dt, by = c("phi", "rho_Z"), all.x = TRUE)


# ---- Print results ----
cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("RESULTS: BIAS BY MODEL (beta_true = 1)\n")
cat(rep("=", 80), "\n\n")

for (rz in c(0.5, 0.7)) {
  cat(sprintf("--- rho_Z = %.2f ---\n\n", rz))
  s <- summ[rho_Z == rz]

  cat("BIAS (estimate - beta_true):\n")
  bias_tab <- s[, .(phi, n_sims, n_explosive,
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
  rmse_tab <- s[, .(phi,
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

ivb_tab <- summ[, .(phi, rho_Z,
  `theta`       = round(mean_theta, 4),
  `pi`          = round(mean_pi, 4),
  `IVB`         = round(mean_ivb, 4),
  `IVB_formula` = round(mean_ivb_formula, 4),
  `|IVB/beta|`  = round(mean_abs_ivb_over_beta, 4),
  `|IVB/SE|`    = round(mean_abs_ivb_over_se, 4))]
print(ivb_tab)


# ---- Key comparison: feedback intensity vs model performance ----
cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("KEY COMPARISON: Feedback intensity vs bias\n")
cat(rep("=", 80), "\n\n")

comp_tab <- summ[, .(phi, rho_Z,
  `|bias|_TWFE_s`  = round(abs(twfe_s_bias), 4),
  `|bias|_TWFE_l`  = round(abs(twfe_l_bias), 4),
  `|bias|_ADL_Ylag` = round(abs(adl_Ylag_bias), 4),
  `|bias|_ADL_all` = round(abs(adl_all_bias), 4),
  `|bias|_ADL_noFE` = round(abs(adl_all_nofe_bias), 4),
  `RMSE_TWFE_s`    = round(twfe_s_rmse, 4),
  `RMSE_ADL_all`   = round(adl_all_rmse, 4))]
print(comp_tab)


# ---- Sanity checks ----
cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("SANITY CHECKS\n")
cat(rep("=", 80), "\n\n")

# 1. FWL identity: b_long - b_short = -theta*pi (exact per-rep)
if (nrow(results) > 0) {
  max_formula_err_rep <- results[, max(abs((twfe_l.D - twfe_s.D) - (-theta * pi_hat)))]
  cat(sprintf("1a. Max rep-level |IVB - (-theta*pi)|: %.2e (should be < 1e-8)\n",
              max_formula_err_rep))
} else {
  cat("1a. SKIP — no valid reps to check\n")
}
# Aggregated check
max_formula_err <- summ[, max(abs(mean_ivb - mean_ivb_formula))]
cat(sprintf("1b. Max scenario-level |mean_IVB - mean(-theta*pi)|: %.6f (should be ~0)\n",
            max_formula_err))

# 2. Explosive count
cat(sprintf("2. Explosive/failed: total %d (should be 0 or very low)\n",
            sum(explosive_counts)))

# 3. phi=0 baseline: TWFE_s bias should match dual_role_z pattern
# (OVB from omitting Z_lag with confounder channels active)
baseline <- summ[phi == 0]
if (nrow(baseline) > 0) {
  cat(sprintf("3. Baseline (phi=0): TWFE_s bias = [%.4f, %.4f] (expect OVB from Z_lag omission)\n",
              min(baseline$twfe_s_bias), max(baseline$twfe_s_bias)))
  cat(sprintf("   Baseline (phi=0): ADL_all bias = [%.4f, %.4f] (expect ~0.01 or less)\n",
              min(baseline$adl_all_bias), max(baseline$adl_all_bias)))
}

# 4. TWFE bias should grow with phi (strict exogeneity violation)
cat("4. TWFE_s bias by phi (expect monotonic growth in |bias|):\n")
for (rz in c(0.5, 0.7)) {
  s <- summ[rho_Z == rz, .(phi, bias = round(twfe_s_bias, 4))]
  cat(sprintf("   rho_Z=%.1f: ", rz))
  cat(paste0("phi=", s$phi, ":", s$bias, collapse = "  "), "\n")
}

# 5. ADL_all should be more robust than TWFE (at least for moderate phi)
cat("5. ADL_all bias by phi (expect smaller |bias| than TWFE, at least for phi<=0.1):\n")
for (rz in c(0.5, 0.7)) {
  s <- summ[rho_Z == rz, .(phi, bias = round(adl_all_bias, 4))]
  cat(sprintf("   rho_Z=%.1f: ", rz))
  cat(paste0("phi=", s$phi, ":", s$bias, collapse = "  "), "\n")
}

# 6. ADL_all |bias| < TWFE_s |bias| count
n_adl_wins <- summ[, sum(abs(adl_all_bias) < abs(twfe_s_bias))]
cat(sprintf("6. ADL_all |bias| < TWFE_s |bias|: %d/%d scenarios\n",
            n_adl_wins, nrow(summ)))

cat("\n")


# ---- Save ----
fwrite(results, "results/sim_feedback_Y_to_D_raw.csv")
fwrite(summ, "results/sim_feedback_Y_to_D_results.csv")

timing <- data.table(
  step = "total", elapsed_sec = round(elapsed, 1),
  n_scenarios = nrow(grid), n_reps = N_REPS, n_workers = 4L
)
fwrite(timing, "results/sim_feedback_Y_to_D_timing.csv")

writeLines(c("sim_feedback_Y_to_D.R", format(Sys.time()), "",
             capture.output(sessionInfo())),
           "results/sim_feedback_Y_to_D_sessioninfo.txt")

cat("\nDone. Files saved:\n")
cat("  results/sim_feedback_Y_to_D_raw.csv\n")
cat("  results/sim_feedback_Y_to_D_results.csv\n")
cat("  results/sim_feedback_Y_to_D_timing.csv\n")
cat("  results/sim_feedback_Y_to_D_sessioninfo.txt\n")
