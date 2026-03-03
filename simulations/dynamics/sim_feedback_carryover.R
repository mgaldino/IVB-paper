# ============================================================================
# sim_feedback_carryover.R
# Sim 3: Direct feedback + direct carryover combined
# (Imai & Kim assumptions (c) AND (d) violated simultaneously)
#
# DGP:
#   D_t = α^D_i + γ_D Z_{t-1} + ρ_D D_{t-1} + φ Y_{t-1} + u_t      ← (c)
#   Y_t = α^Y_i + β D_t + β₂ D_{t-1} + γ_Y Z_{t-1} + ρ_Y Y_{t-1} + e_t  ← (d)
#   Z_t = α^Z_i + δ_D D_t + δ_Y Y_t + ρ_Z Z_{t-1} + ν_t
#
# Grid: 5 scenarios covering φ × β₂ × ρ_Z combinations × 500 reps
# Note: φ=0.2/β₂=0.5 and ρ_Z=0.85 excluded — non-stationary
#
# 8 models (same as Sim 2 — includes D_lag variants):
#   1. TWFE short:    Y ~ D | FE
#   2. TWFE long:     Y ~ D + Z_lag | FE
#   3. ADL Y_lag:     Y ~ D + Y_lag | FE
#   4. ADL full:      Y ~ D + Z_lag + Y_lag | FE
#   5. ADL D_lag:     Y ~ D + D_lag | FE
#   6. ADL DY_lag:    Y ~ D + D_lag + Y_lag | FE
#   7. ADL DZ_lag:    Y ~ D + D_lag + Z_lag | FE
#   8. ADL all:       Y ~ D + D_lag + Y_lag + Z_lag | FE (fully dynamic)
#   9. ADL all noFE:  Y ~ D + D_lag + Y_lag + Z_lag     (for Nickell cost)
#
# Also extracts hat(beta_2) from ADL_all to verify recovery.
#
# Question: In the "most realistic" scenario (feedback + carryover + dual-role Z),
# which model dominates? Is ADL_all necessary?
# ============================================================================

library(data.table)
library(fixest)

set.seed(2026)

# ---- DGP with both feedback and carryover ----
sim_both <- function(N, TT, T_burn, beta, beta2, rho_Y, rho_D,
                     gamma_D, gamma_Y, delta_D, delta_Y,
                     rho_Z, sigma_aZ, phi) {
  T_sim <- TT + T_burn

  alpha_D <- rnorm(N, 0, 1)
  alpha_Y <- rnorm(N, 0, 1)
  alpha_Z <- rnorm(N, 0, sigma_aZ)

  rows <- vector("list", N)

  for (i in 1:N) {
    D <- Y <- Z <- numeric(T_sim)
    D[1] <- alpha_D[i] + rnorm(1)
    Y[1] <- alpha_Y[i] + rnorm(1)
    Z[1] <- alpha_Z[i] + rnorm(1)

    for (t in 2:T_sim) {
      u <- rnorm(1); e <- rnorm(1); nu <- rnorm(1)
      D[t] <- alpha_D[i] + gamma_D * Z[t - 1] + rho_D * D[t - 1] +
              phi * Y[t - 1] + u
      Y[t] <- alpha_Y[i] + beta * D[t] + beta2 * D[t - 1] +
              gamma_Y * Z[t - 1] + rho_Y * Y[t - 1] + e
      Z[t] <- alpha_Z[i] + delta_D * D[t] + delta_Y * Y[t] +
              rho_Z * Z[t - 1] + nu
    }

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
  dt <- dt[complete.cases(dt)]
  dt[, `:=`(id_f = factor(id), time_f = factor(time))]
  dt
}

# ---- Estimation: 8 models (same as Sim 2) ----
est_models_both <- function(dt) {
  # 1. TWFE short: Y ~ D | FE
  m1 <- feols(Y ~ D | id_f + time_f, dt, vcov = "iid")
  # 2. TWFE long: Y ~ D + Z_lag | FE
  m2 <- feols(Y ~ D + Z_lag | id_f + time_f, dt, vcov = "iid")
  # 3. ADL Y_lag: Y ~ D + Y_lag | FE
  m3 <- feols(Y ~ D + Y_lag | id_f + time_f, dt, vcov = "iid")
  # 4. ADL full: Y ~ D + Z_lag + Y_lag | FE
  m4 <- feols(Y ~ D + Z_lag + Y_lag | id_f + time_f, dt, vcov = "iid")
  # 5. ADL D_lag: Y ~ D + D_lag | FE
  m5 <- feols(Y ~ D + D_lag | id_f + time_f, dt, vcov = "iid")
  # 6. ADL DY_lag: Y ~ D + D_lag + Y_lag | FE
  m6 <- feols(Y ~ D + D_lag + Y_lag | id_f + time_f, dt, vcov = "iid")
  # 7. ADL DZ_lag: Y ~ D + D_lag + Z_lag | FE
  m7 <- feols(Y ~ D + D_lag + Z_lag | id_f + time_f, dt, vcov = "iid")
  # 8. ADL all: Y ~ D + D_lag + Y_lag + Z_lag | FE (fully dynamic)
  m8 <- feols(Y ~ D + D_lag + Y_lag + Z_lag | id_f + time_f, dt, vcov = "iid")
  # 9. ADL all no FE: Y ~ D + D_lag + Y_lag + Z_lag (for Nickell cost)
  m9 <- lm(Y ~ D + D_lag + Y_lag + Z_lag, data = dt)

  c(twfe_s     = coef(m1)["D"],
    twfe_l     = coef(m2)["D"],
    adl_Ylag   = coef(m3)["D"],
    adl_full   = coef(m4)["D"],
    adl_Dlag   = coef(m5)["D"],
    adl_DYlag  = coef(m6)["D"],
    adl_DZlag  = coef(m7)["D"],
    adl_all    = coef(m8)["D"],
    adl_all_nofe = coef(m9)["D"],
    b2_all     = coef(m8)["D_lag"])
}

# ---- Grid: specific φ × β₂ combinations ----
grid <- data.table(
  phi   = c(0.05, 0.05, 0.10, 0.10, 0.05),
  beta2 = c(0.2,  0.2,  0.2,  0.3,  0.3),
  rho_Z = c(0.5,  0.7,  0.7,  0.5,  0.7)
)
# Note: φ=0.10/β₂=0.3/ρ_Z=0.7 is marginally unstable (|λ|=1.01), replaced with φ=0.05
# Added φ=0.10/β₂=0.2/ρ_Z=0.7 (|λ|=0.995, stable) for more phi variation

P <- list(N = 100, TT = 30, T_burn = 100, beta = 1,
          rho_Y = 0.5, rho_D = 0.5,
          gamma_D = 0.15, gamma_Y = 0.2,
          delta_D = 0.1, delta_Y = 0.1,
          sigma_aZ = 0.5)
N_REPS <- 500

# ---- Run ----
cat(rep("=", 71), "\n", sep = "")
cat("SIM 3: FEEDBACK + CARRYOVER COMBINED\n")
cat(rep("=", 71), "\n\n")
cat(nrow(grid), "scenarios x", N_REPS, "reps\n")
cat("DGP: beta=1, rho_Y=0.5, rho_D=0.5, gamma_D=0.15, gamma_Y=0.2\n")
cat("     delta_D=0.1, delta_Y=0.1, N=100, T=30, T_burn=100\n")
cat("NEW: phi Y_{t-1} → D_t + beta2 D_{t-1} → Y_t (both violations)\n\n")

all_res <- vector("list", nrow(grid))
elapsed_times <- numeric(nrow(grid))
t0_total <- proc.time()

for (g in 1:nrow(grid)) {
  ph <- grid$phi[g]
  b2 <- grid$beta2[g]
  rz <- grid$rho_Z[g]

  cat(sprintf("[%d/%d] phi=%.2f beta2=%.2f rho_Z=%.2f ... ",
              g, nrow(grid), ph, b2, rz))
  t0 <- proc.time()

  res_g <- rbindlist(lapply(1:N_REPS, function(s) {
    dt <- sim_both(P$N, P$TT, P$T_burn, P$beta, b2, P$rho_Y, P$rho_D,
                   P$gamma_D, P$gamma_Y, P$delta_D, P$delta_Y,
                   rz, P$sigma_aZ, ph)
    est <- est_models_both(dt)
    as.data.table(as.list(est))[, sim := s]
  }))

  res_g[, `:=`(phi = ph, beta2 = b2, rho_Z = rz)]
  all_res[[g]] <- res_g

  elapsed <- (proc.time() - t0)[3]
  elapsed_times[g] <- elapsed
  cat(sprintf("%.1fs\n", elapsed))
}

total_elapsed <- (proc.time() - t0_total)[3]
cat(sprintf("\nTotal time: %.1fs\n", total_elapsed))

results <- rbindlist(all_res)

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
  # hat(beta_2) recovery from ADL_all
  b2_vals <- get("b2_all.D_lag")
  out$b2_all_mean <- mean(b2_vals)
  out$n_sims <- .N
  out
}, by = .(phi, beta2, rho_Z)]

# ---- Print results ----
cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("RESULTS: BIAS BY MODEL (beta_true = 1)\n")
cat(rep("=", 80), "\n\n")

cat("BIAS (estimate - beta_true) — original 4 models:\n")
bias_tab1 <- summ[, .(phi, beta2, rho_Z,
  `TWFE_s`    = round(twfe_s_bias, 4),
  `TWFE_l`    = round(twfe_l_bias, 4),
  `ADL_Ylag`  = round(adl_Ylag_bias, 4),
  `ADL_full`  = round(adl_full_bias, 4))]
print(bias_tab1)

cat("\nBIAS — D_lag models (NEW):\n")
bias_tab2 <- summ[, .(phi, beta2, rho_Z,
  `ADL_Dlag`  = round(adl_Dlag_bias, 4),
  `ADL_DYlag` = round(adl_DYlag_bias, 4),
  `ADL_DZlag` = round(adl_DZlag_bias, 4),
  `ADL_all`   = round(adl_all_bias, 4),
  `ADL_all_noFE` = round(adl_all_nofe_bias, 4))]
print(bias_tab2)

cat("\nRMSE — key models:\n")
rmse_tab <- summ[, .(phi, beta2, rho_Z,
  `TWFE_s`    = round(twfe_s_rmse, 4),
  `ADL_full`  = round(adl_full_rmse, 4),
  `ADL_all`   = round(adl_all_rmse, 4),
  `ADL_noFE`  = round(adl_all_nofe_rmse, 4))]
print(rmse_tab)

cat("\nhat(beta_2) recovery from ADL_all (true beta_2 in first col):\n")
b2_tab <- summ[, .(phi, beta2, rho_Z,
  `hat_b2` = round(b2_all_mean, 4))]
print(b2_tab)

cat("\nMC STANDARD ERRORS — all models:\n")
mcse_tab <- summ[, .(phi, beta2, rho_Z,
  `TWFE_s`    = round(twfe_s_mcse, 4),
  `TWFE_l`    = round(twfe_l_mcse, 4),
  `ADL_Ylag`  = round(adl_Ylag_mcse, 4),
  `ADL_full`  = round(adl_full_mcse, 4),
  `ADL_Dlag`  = round(adl_Dlag_mcse, 4),
  `ADL_DYlag` = round(adl_DYlag_mcse, 4),
  `ADL_DZlag` = round(adl_DZlag_mcse, 4),
  `ADL_all`   = round(adl_all_mcse, 4))]
print(mcse_tab)

# ---- Decompositions ----
cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("DECOMPOSITIONS\n")
cat(rep("=", 80), "\n\n")

cat("A. Marginal value of each lag (net benefit, >0 = helps):\n")
marg_tab <- summ[, .(phi, beta2, rho_Z,
  `+Z_lag`   = round(abs(adl_DYlag_bias) - abs(adl_all_bias), 4),
  `+Y_lag`   = round(abs(adl_DZlag_bias) - abs(adl_all_bias), 4),
  `+D_lag`   = round(abs(adl_full_bias) - abs(adl_all_bias), 4))]
print(marg_tab)

cat("\nB. Model ranking (top 3 by |bias|) per scenario:\n")
rank_tab <- summ[, {
  biases <- c(twfe_s = abs(twfe_s_bias), twfe_l = abs(twfe_l_bias),
              adl_Ylag = abs(adl_Ylag_bias), adl_full = abs(adl_full_bias),
              adl_Dlag = abs(adl_Dlag_bias), adl_DYlag = abs(adl_DYlag_bias),
              adl_DZlag = abs(adl_DZlag_bias), adl_all = abs(adl_all_bias))
  ranking <- sort(biases)
  .(rank1 = sprintf("%s(%.4f)", names(ranking)[1], ranking[1]),
    rank2 = sprintf("%s(%.4f)", names(ranking)[2], ranking[2]),
    rank3 = sprintf("%s(%.4f)", names(ranking)[3], ranking[3]),
    adl_all_rank = which(names(ranking) == "adl_all"),
    adl_full_rank = which(names(ranking) == "adl_full"))
}, by = .(phi, beta2, rho_Z)]
print(rank_tab)

cat("\nC. Comparison: ADL_full (no D_lag) vs ADL_all (with D_lag):\n")
comp_tab <- summ[, {
  full_abs <- abs(adl_full_bias)
  all_abs  <- abs(adl_all_bias)
  pct <- ifelse(full_abs < 0.001, NA_real_,
                round(100 * (full_abs - all_abs) / full_abs, 1))
  .(ADL_full_bias = round(adl_full_bias, 4),
    ADL_all_bias  = round(adl_all_bias, 4),
    Improvement   = round(full_abs - all_abs, 4),
    Pct_improve   = pct)
}, by = .(phi, beta2, rho_Z)]
print(comp_tab)

cat("\nD. Nickell cost (ADL_all FE vs ADL_all noFE, |FE| - |noFE|, <0 = FE helps):\n")
nick_tab <- summ[, .(phi, beta2, rho_Z,
  `ADL_all_FE`    = round(adl_all_bias, 4),
  `ADL_all_noFE`  = round(adl_all_nofe_bias, 4),
  `Nickell_cost`  = round(abs(adl_all_bias) - abs(adl_all_nofe_bias), 4))]
print(nick_tab)

# ---- Save ----
fwrite(summ, "results/sim_feedback_carryover_results.csv")
fwrite(results, "results/sim_feedback_carryover_raw.csv")

timing <- data.table(grid, elapsed_s = elapsed_times, total_s = total_elapsed)
fwrite(timing, "results/sim_feedback_carryover_timing.csv")

cat("\nResults saved to results/sim_feedback_carryover_results.csv\n")
cat(sprintf("Timing saved (total %.1fs)\n", total_elapsed))

writeLines(capture.output(sessionInfo()),
           "results/sim_feedback_carryover_sessioninfo.txt")
