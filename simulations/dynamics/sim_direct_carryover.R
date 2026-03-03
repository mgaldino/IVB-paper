# ============================================================================
# sim_direct_carryover.R
# Sim 2: Direct carryover D_{t-1} → Y_t (Imai & Kim assumption (d) violated)
#
# DGP:
#   D_t = α^D_i + γ_D Z_{t-1} + ρ_D D_{t-1} + u_t
#   Y_t = α^Y_i + β D_t + β₂ D_{t-1} + γ_Y Z_{t-1} + ρ_Y Y_{t-1} + e_t  ← NEW
#   Z_t = α^Z_i + δ_D D_t + δ_Y Y_t + ρ_Z Z_{t-1} + ν_t
#
# Grid: β₂ ∈ {0, 0.2, 0.5} × ρ_Z ∈ {0.5, 0.7} = 6 scenarios × 500 reps
# Note: ρ_Z=0.85 excluded — non-stationary when β₂=0.5
#
# 8 models (including D_lag variants — Imai & Kim Table 1):
#   1. TWFE short:    Y ~ D | FE
#   2. TWFE long:     Y ~ D + Z_lag | FE
#   3. ADL Y_lag:     Y ~ D + Y_lag | FE
#   4. ADL full:      Y ~ D + Z_lag + Y_lag | FE
#   5. ADL D_lag:     Y ~ D + D_lag | FE                     ← NEW
#   6. ADL DY_lag:    Y ~ D + D_lag + Y_lag | FE             ← NEW
#   7. ADL DZ_lag:    Y ~ D + D_lag + Z_lag | FE             ← NEW
#   8. ADL all:       Y ~ D + D_lag + Y_lag + Z_lag | FE     ← NEW (fully dynamic)
#   9. ADL all noFE:  Y ~ D + D_lag + Y_lag + Z_lag         ← for Nickell cost
#
# Also extracts hat(beta_2) from D_lag models (5-8) to verify recovery.
#
# Question: When D has direct carryover, does omitting D_lag cause bias?
# Is the fully dynamic model (ADL_all) necessary?
# ============================================================================

library(data.table)
library(fixest)

set.seed(2026)

# ---- DGP with direct carryover ----
sim_carryover <- function(N, TT, T_burn, beta, beta2, rho_Y, rho_D,
                          gamma_D, gamma_Y, delta_D, delta_Y,
                          rho_Z, sigma_aZ) {
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
      D[t] <- alpha_D[i] + gamma_D * Z[t - 1] + rho_D * D[t - 1] + u
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

# ---- Estimation: 8 models ----
est_models_carryover <- function(dt) {
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
    # hat(beta_2) from D_lag models
    b2_Dlag   = coef(m5)["D_lag"],
    b2_DYlag  = coef(m6)["D_lag"],
    b2_DZlag  = coef(m7)["D_lag"],
    b2_all    = coef(m8)["D_lag"])
}

# ---- Grid ----
grid <- CJ(
  beta2 = c(0, 0.2, 0.5),
  rho_Z = c(0.5, 0.7)
)

P <- list(N = 100, TT = 30, T_burn = 100, beta = 1,
          rho_Y = 0.5, rho_D = 0.5,
          gamma_D = 0.15, gamma_Y = 0.2,
          delta_D = 0.1, delta_Y = 0.1,
          sigma_aZ = 0.5)
N_REPS <- 500

# ---- Run ----
cat(rep("=", 71), "\n", sep = "")
cat("SIM 2: DIRECT CARRYOVER D_{t-1} → Y_t\n")
cat(rep("=", 71), "\n\n")
cat(nrow(grid), "scenarios x", N_REPS, "reps\n")
cat("DGP: beta=1, rho_Y=0.5, rho_D=0.5, gamma_D=0.15, gamma_Y=0.2\n")
cat("     delta_D=0.1, delta_Y=0.1, N=100, T=30, T_burn=100\n")
cat("NEW: beta2 D_{t-1} → Y_t (direct carryover)\n\n")

all_res <- vector("list", nrow(grid))
elapsed_times <- numeric(nrow(grid))
t0_total <- proc.time()

for (g in 1:nrow(grid)) {
  b2 <- grid$beta2[g]
  rz <- grid$rho_Z[g]

  cat(sprintf("[%d/%d] beta2=%.2f rho_Z=%.2f ... ", g, nrow(grid), b2, rz))
  t0 <- proc.time()

  res_g <- rbindlist(lapply(1:N_REPS, function(s) {
    dt <- sim_carryover(P$N, P$TT, P$T_burn, P$beta, b2, P$rho_Y, P$rho_D,
                        P$gamma_D, P$gamma_Y, P$delta_D, P$delta_Y,
                        rz, P$sigma_aZ)
    est <- est_models_carryover(dt)
    as.data.table(as.list(est))[, sim := s]
  }))

  res_g[, `:=`(beta2 = b2, rho_Z = rz)]
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

# D_lag coefficient columns (hat(beta_2))
b2_cols <- c("b2_Dlag.D_lag", "b2_DYlag.D_lag", "b2_DZlag.D_lag", "b2_all.D_lag")
b2_names <- c("b2_Dlag", "b2_DYlag", "b2_DZlag", "b2_all")

summ <- results[, {
  out <- list()
  for (j in seq_along(mod_cols)) {
    vals <- get(mod_cols[j])
    out[[paste0(mod_names[j], "_bias")]] <- mean(vals) - beta_true
    out[[paste0(mod_names[j], "_mcse")]] <- sd(vals) / sqrt(.N)
    out[[paste0(mod_names[j], "_sd")]]   <- sd(vals)
    out[[paste0(mod_names[j], "_rmse")]] <- sqrt(mean((vals - beta_true)^2))
  }
  # hat(beta_2) recovery
  for (j in seq_along(b2_cols)) {
    vals <- get(b2_cols[j])
    out[[paste0(b2_names[j], "_mean")]] <- mean(vals)
  }
  out$n_sims <- .N
  out
}, by = .(beta2, rho_Z)]

# ---- Print results ----
cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("RESULTS: BIAS BY MODEL (beta_true = 1)\n")
cat(rep("=", 80), "\n\n")

for (rz in c(0.5, 0.7)) {
  cat(sprintf("--- rho_Z = %.2f ---\n\n", rz))
  s <- summ[rho_Z == rz]

  cat("BIAS (estimate - beta_true) — original 4 models:\n")
  bias_tab1 <- s[, .(beta2,
    `TWFE_s`    = round(twfe_s_bias, 4),
    `TWFE_l`    = round(twfe_l_bias, 4),
    `ADL_Ylag`  = round(adl_Ylag_bias, 4),
    `ADL_full`  = round(adl_full_bias, 4))]
  print(bias_tab1)

  cat("\nBIAS — D_lag models (NEW):\n")
  bias_tab2 <- s[, .(beta2,
    `ADL_Dlag`  = round(adl_Dlag_bias, 4),
    `ADL_DYlag` = round(adl_DYlag_bias, 4),
    `ADL_DZlag` = round(adl_DZlag_bias, 4),
    `ADL_all`   = round(adl_all_bias, 4),
    `ADL_all_noFE` = round(adl_all_nofe_bias, 4))]
  print(bias_tab2)

  cat("\nRMSE — all models:\n")
  rmse_tab <- s[, .(beta2,
    `TWFE_s`    = round(twfe_s_rmse, 4),
    `TWFE_l`    = round(twfe_l_rmse, 4),
    `ADL_full`  = round(adl_full_rmse, 4),
    `ADL_all`   = round(adl_all_rmse, 4),
    `ADL_noFE`  = round(adl_all_nofe_rmse, 4))]
  print(rmse_tab)

  cat("\nhat(beta_2) recovery (true beta_2 shown in first col):\n")
  b2_tab <- s[, .(beta2,
    `Dlag`   = round(b2_Dlag_mean, 4),
    `DYlag`  = round(b2_DYlag_mean, 4),
    `DZlag`  = round(b2_DZlag_mean, 4),
    `All`    = round(b2_all_mean, 4))]
  print(b2_tab)

  cat("\nMC STANDARD ERRORS — all models:\n")
  mcse_tab <- s[, .(beta2,
    `TWFE_s`    = round(twfe_s_mcse, 4),
    `TWFE_l`    = round(twfe_l_mcse, 4),
    `ADL_Ylag`  = round(adl_Ylag_mcse, 4),
    `ADL_full`  = round(adl_full_mcse, 4),
    `ADL_Dlag`  = round(adl_Dlag_mcse, 4),
    `ADL_DYlag` = round(adl_DYlag_mcse, 4),
    `ADL_DZlag` = round(adl_DZlag_mcse, 4),
    `ADL_all`   = round(adl_all_mcse, 4))]
  print(mcse_tab)
  cat("\n")
}

# ---- Decompositions ----
cat(rep("=", 80), "\n", sep = "")
cat("DECOMPOSITIONS\n")
cat(rep("=", 80), "\n\n")

cat("A. Effect of adding D_lag (bias with D_lag - bias without):\n")
dlag_tab <- summ[, .(beta2, rho_Z,
  `TWFE→+Dlag`  = round(adl_Dlag_bias - twfe_s_bias, 4),
  `ADLfull→+Dlag` = round(adl_all_bias - adl_full_bias, 4),
  `ADLYlag→+Dlag` = round(adl_DYlag_bias - adl_Ylag_bias, 4))]
print(dlag_tab)

cat("\nB. Net benefit of D_lag (|without D_lag| - |with D_lag|, >0 = D_lag helps):\n")
net_dlag <- summ[, .(beta2, rho_Z,
  `Net_TWFE`     = round(abs(twfe_s_bias) - abs(adl_Dlag_bias), 4),
  `Net_ADLfull`  = round(abs(adl_full_bias) - abs(adl_all_bias), 4),
  `Net_ADLYlag`  = round(abs(adl_Ylag_bias) - abs(adl_DYlag_bias), 4))]
print(net_dlag)

cat("\nC. IVB of Z_lag (bias with Z - bias without Z, same D_lag/Y_lag spec):\n")
ivb_z <- summ[, .(beta2, rho_Z,
  `IVB_TWFE`       = round(twfe_l_bias - twfe_s_bias, 4),
  `IVB_ADL`        = round(adl_full_bias - adl_Ylag_bias, 4),
  `IVB_ADL+Dlag`   = round(adl_all_bias - adl_DYlag_bias, 4))]
print(ivb_z)

cat("\nD. Nickell cost (ADL_all FE vs ADL_all noFE, |FE| - |noFE|, <0 = FE helps):\n")
nick_tab <- summ[, .(beta2, rho_Z,
  `ADL_all_FE`   = round(adl_all_bias, 4),
  `ADL_all_noFE` = round(adl_all_nofe_bias, 4),
  `Nickell_cost`  = round(abs(adl_all_bias) - abs(adl_all_nofe_bias), 4))]
print(nick_tab)

cat("\nE. Best model (smallest |bias|) per scenario:\n")
best_tab <- summ[, {
  biases <- c(twfe_s = abs(twfe_s_bias), twfe_l = abs(twfe_l_bias),
              adl_Ylag = abs(adl_Ylag_bias), adl_full = abs(adl_full_bias),
              adl_Dlag = abs(adl_Dlag_bias), adl_DYlag = abs(adl_DYlag_bias),
              adl_DZlag = abs(adl_DZlag_bias), adl_all = abs(adl_all_bias),
              adl_all_nofe = abs(adl_all_nofe_bias))
  best_idx <- which.min(biases)
  .(best_model = names(biases)[best_idx],
    best_bias = round(biases[best_idx], 4),
    second_best = names(sort(biases))[2],
    second_bias = round(sort(biases)[2], 4))
}, by = .(beta2, rho_Z)]
print(best_tab)

# ---- Sanity: when β₂ = 0, D_lag models should behave like originals ----
cat("\nSANITY CHECK: when beta_2 = 0, adding D_lag should not help:\n")
sanity_tab <- summ[beta2 == 0, .(rho_Z,
  `ADL_full` = round(adl_full_bias, 4),
  `ADL_all`  = round(adl_all_bias, 4),
  `Diff`     = round(adl_all_bias - adl_full_bias, 4))]
print(sanity_tab)

# ---- Save ----
fwrite(summ, "results/sim_direct_carryover_results.csv")
fwrite(results, "results/sim_direct_carryover_raw.csv")

timing <- data.table(grid, elapsed_s = elapsed_times, total_s = total_elapsed)
fwrite(timing, "results/sim_direct_carryover_timing.csv")

cat("\nResults saved to results/sim_direct_carryover_results.csv\n")
cat(sprintf("Timing saved (total %.1fs)\n", total_elapsed))

writeLines(capture.output(sessionInfo()),
           "results/sim_direct_carryover_sessioninfo.txt")
