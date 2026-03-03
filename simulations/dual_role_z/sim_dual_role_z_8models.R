# ============================================================================
# sim_dual_role_z_8models.R
# Comprehensive simulation: Dual-role Z under 8 estimation strategies
#
# DGP (unit i, period t):
#   D_{it} = α^D_i + γ_D Z_{i,t-1} + ρ_D D_{i,t-1} + u_{it}
#   Y_{it} = α^Y_i + β D_{it} + γ_Y Z_{i,t-1} + ρ_Y Y_{i,t-1} + e_{it}
#   Z_{it} = α^Z_i + δ_D D_{it} + δ_Y Y_{it} + ρ_Z Z_{i,t-1} + ν_{it}
#
# 8 models (full 2x2x2 grid: {FE,noFE} x {Y_lag,noY_lag} x {Z_lag,noZ_lag}):
#   1. Pooled short:    Y ~ D                     (no FE, no Y_lag, no Z_lag)
#   2. Pooled long:     Y ~ D + Z_lag             (no FE, no Y_lag, with Z_lag)
#   3. TWFE short:      Y ~ D | FE                (FE, no Y_lag, no Z_lag)
#   4. TWFE long:       Y ~ D + Z_lag | FE        (FE, no Y_lag, with Z_lag)
#   5. ADL short noFE:  Y ~ D + Y_lag             (no FE, with Y_lag, no Z_lag)
#   6. ADL long noFE:   Y ~ D + Z_lag + Y_lag     (no FE, with Y_lag, with Z_lag)
#   7. ADL short FE:    Y ~ D + Y_lag | FE        (FE, with Y_lag, no Z_lag)
#   8. ADL long FE:     Y ~ D + Z_lag + Y_lag | FE (FE, with Y_lag, with Z_lag)
#
# Purpose: Decompose biases from FE, Y_lag, Z_lag inclusion/exclusion
# ============================================================================

library(data.table)
library(fixest)

set.seed(2026)

# ---- DGP ----
sim_dual_z <- function(N, TT, T_burn, beta, rho_Y, rho_D,
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
      Y[t] <- alpha_Y[i] + beta * D[t] + gamma_Y * Z[t - 1] +
              rho_Y * Y[t - 1] + e
      Z[t] <- alpha_Z[i] + delta_D * D[t] + delta_Y * Y[t] +
              rho_Z * Z[t - 1] + nu
    }

    idx <- (T_burn + 1):T_sim
    rows[[i]] <- data.table(
      id = i, time = seq_along(idx),
      D = D[idx], Y = Y[idx], Z = Z[idx],
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
est_8models <- function(dt) {
  # 1. Pooled short: Y ~ D
  m1 <- lm(Y ~ D, data = dt)
  # 2. Pooled long: Y ~ D + Z_lag
  m2 <- lm(Y ~ D + Z_lag, data = dt)
  # 3. TWFE short: Y ~ D | FE
  m3 <- feols(Y ~ D | id_f + time_f, dt, vcov = "iid")
  # 4. TWFE long: Y ~ D + Z_lag | FE
  m4 <- feols(Y ~ D + Z_lag | id_f + time_f, dt, vcov = "iid")
  # 5. ADL short noFE: Y ~ D + Y_lag
  m5 <- lm(Y ~ D + Y_lag, data = dt)
  # 6. ADL long noFE: Y ~ D + Z_lag + Y_lag
  m6 <- lm(Y ~ D + Z_lag + Y_lag, data = dt)
  # 7. ADL short FE: Y ~ D + Y_lag | FE
  m7 <- feols(Y ~ D + Y_lag | id_f + time_f, dt, vcov = "iid")
  # 8. ADL long FE: Y ~ D + Z_lag + Y_lag | FE
  m8 <- feols(Y ~ D + Z_lag + Y_lag | id_f + time_f, dt, vcov = "iid")

  c(pooled_s   = coef(m1)["D"],
    pooled_l   = coef(m2)["D"],
    twfe_s     = coef(m3)["D"],
    twfe_l     = coef(m4)["D"],
    adl_s_nofe = coef(m5)["D"],
    adl_l_nofe = coef(m6)["D"],
    adl_s_fe   = coef(m7)["D"],
    adl_l_fe   = coef(m8)["D"])
}

# ---- Grid ----
grid <- CJ(
  rho_Z    = c(0.1, 0.3, 0.5, 0.7, 0.85),
  sigma_aZ = c(0.5, 2.0)
)

P <- list(N = 100, TT = 30, T_burn = 100, beta = 1,
          rho_Y = 0.5, rho_D = 0.5,
          gamma_D = 0.15, gamma_Y = 0.2,
          delta_D = 0.1, delta_Y = 0.1)
N_REPS <- 500

# ---- Run ----
cat("8-model simulation:", nrow(grid), "scenarios x", N_REPS, "reps\n")
cat("DGP: beta=1, rho_Y=0.5, rho_D=0.5, gamma_D=0.15, gamma_Y=0.2\n")
cat("     delta_D=0.1, delta_Y=0.1, N=100, T=30, T_burn=100\n\n")

all_res <- vector("list", nrow(grid))

for (g in 1:nrow(grid)) {
  rho_z  <- grid$rho_Z[g]
  sig_aZ <- grid$sigma_aZ[g]

  cat(sprintf("[%2d/%d] rho_Z=%.2f sigma_aZ=%.1f ... ",
              g, nrow(grid), rho_z, sig_aZ))
  t0 <- proc.time()

  res_g <- rbindlist(lapply(1:N_REPS, function(s) {
    dt <- sim_dual_z(P$N, P$TT, P$T_burn, P$beta, P$rho_Y, P$rho_D,
                     P$gamma_D, P$gamma_Y, P$delta_D, P$delta_Y,
                     rho_z, sig_aZ)
    est <- est_8models(dt)
    as.data.table(as.list(est))[, sim := s]
  }))

  res_g[, `:=`(rho_Z = rho_z, sigma_aZ = sig_aZ)]
  all_res[[g]] <- res_g

  elapsed <- (proc.time() - t0)[3]
  cat(sprintf("%.1fs\n", elapsed))
}

results <- rbindlist(all_res)

# ---- Summary with MC standard errors ----
beta_true <- P$beta

# Model name mapping for column names
mod_cols <- c("pooled_s.D", "pooled_l.D", "twfe_s.D", "twfe_l.D",
              "adl_s_nofe.D", "adl_l_nofe.D", "adl_s_fe.D", "adl_l_fe.D")
mod_names <- c("pooled_s", "pooled_l", "twfe_s", "twfe_l",
               "adl_s_nofe", "adl_l_nofe", "adl_s_fe", "adl_l_fe")
mod_labels <- c("Pooled short", "Pooled long", "TWFE short", "TWFE long",
                "ADL short (no FE)", "ADL long (no FE)",
                "ADL short (FE)", "ADL long (FE)")

# Compute bias and MC SE for each model
summ <- results[, {
  out <- list()
  for (j in seq_along(mod_cols)) {
    vals <- get(mod_cols[j])
    out[[paste0(mod_names[j], "_bias")]] <- mean(vals) - beta_true
    out[[paste0(mod_names[j], "_mcse")]] <- sd(vals) / sqrt(.N)
    out[[paste0(mod_names[j], "_sd")]]   <- sd(vals)
  }
  out$n_sims <- .N
  out
}, by = .(rho_Z, sigma_aZ)]

# ---- Print results ----
cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("RESULTS: BIAS BY MODEL (beta_true = 1)\n")
cat(rep("=", 80), "\n\n")

for (sa in c(0.5, 2.0)) {
  cat(sprintf("--- sigma_alpha_Z = %.1f ---\n\n", sa))

  s <- summ[sigma_aZ == sa]

  # Bias table
  cat("BIAS (estimate - beta_true):\n")
  bias_tab <- s[, .(rho_Z,
    `Pool_s` = round(pooled_s_bias, 4),
    `Pool_l` = round(pooled_l_bias, 4),
    `TWFE_s` = round(twfe_s_bias, 4),
    `TWFE_l` = round(twfe_l_bias, 4),
    `ADL_s_noFE` = round(adl_s_nofe_bias, 4),
    `ADL_l_noFE` = round(adl_l_nofe_bias, 4),
    `ADL_s_FE` = round(adl_s_fe_bias, 4),
    `ADL_l_FE` = round(adl_l_fe_bias, 4))]
  print(bias_tab)

  # MC SE table
  cat("\nMC STANDARD ERRORS:\n")
  mcse_tab <- s[, .(rho_Z,
    `Pool_s` = round(pooled_s_mcse, 4),
    `Pool_l` = round(pooled_l_mcse, 4),
    `TWFE_s` = round(twfe_s_mcse, 4),
    `TWFE_l` = round(twfe_l_mcse, 4),
    `ADL_s_noFE` = round(adl_s_nofe_mcse, 4),
    `ADL_l_noFE` = round(adl_l_nofe_mcse, 4),
    `ADL_s_FE` = round(adl_s_fe_mcse, 4),
    `ADL_l_FE` = round(adl_l_fe_mcse, 4))]
  print(mcse_tab)
  cat("\n")
}

# ---- Decompositions ----
cat(rep("=", 80), "\n", sep = "")
cat("DECOMPOSITIONS (sigma_aZ = 0.5)\n")
cat(rep("=", 80), "\n\n")

s <- summ[sigma_aZ == 0.5]

cat("A. IVB by specification (bias_long - bias_short):\n")
ivb_tab <- s[, .(rho_Z,
  `IVB_pooled` = round(pooled_l_bias - pooled_s_bias, 4),
  `IVB_twfe`   = round(twfe_l_bias - twfe_s_bias, 4),
  `IVB_adl_noFE` = round(adl_l_nofe_bias - adl_s_nofe_bias, 4),
  `IVB_adl_FE`   = round(adl_l_fe_bias - adl_s_fe_bias, 4))]
print(ivb_tab)

cat("\nB. Net benefit of including Z (|bias_short| - |bias_long|, positive = Z helps):\n")
net_tab <- s[, .(rho_Z,
  `Net_pooled` = round(abs(pooled_s_bias) - abs(pooled_l_bias), 4),
  `Net_twfe`   = round(abs(twfe_s_bias) - abs(twfe_l_bias), 4),
  `Net_adl_noFE` = round(abs(adl_s_nofe_bias) - abs(adl_l_nofe_bias), 4),
  `Net_adl_FE`   = round(abs(adl_s_fe_bias) - abs(adl_l_fe_bias), 4))]
print(net_tab)

cat("\nC. Effect of adding FE (bias with FE - bias without FE, same Y_lag/Z_lag):\n")
fe_tab <- s[, .(rho_Z,
  `FE_effect_short_noYlag` = round(twfe_s_bias - pooled_s_bias, 4),
  `FE_effect_long_noYlag`  = round(twfe_l_bias - pooled_l_bias, 4),
  `FE_effect_short_Ylag`   = round(adl_s_fe_bias - adl_s_nofe_bias, 4),
  `FE_effect_long_Ylag`    = round(adl_l_fe_bias - adl_l_nofe_bias, 4))]
print(fe_tab)

cat("\nD. Firewall effect (TWFE_long vs ADL_FE_long, both include Z):\n")
fw_tab <- s[, .(rho_Z,
  `TWFE_long_bias`  = round(twfe_l_bias, 4),
  `ADL_FE_long_bias` = round(adl_l_fe_bias, 4),
  `Firewall_gain`   = round(abs(twfe_l_bias) - abs(adl_l_fe_bias), 4))]
print(fw_tab)

cat("\nE. Nickell cost (ADL+FE vs ADL no-FE, both include Y_lag):\n")
nick_tab <- s[, .(rho_Z,
  `ADL_noFE_long` = round(adl_l_nofe_bias, 4),
  `ADL_FE_long`   = round(adl_l_fe_bias, 4),
  `Nickell_cost`  = round(abs(adl_l_fe_bias) - abs(adl_l_nofe_bias), 4))]
print(nick_tab)

cat("\nF. Best model (smallest |bias|) per scenario:\n")
best_tab <- s[, {
  biases <- c(pooled_s = abs(pooled_s_bias), pooled_l = abs(pooled_l_bias),
              twfe_s = abs(twfe_s_bias), twfe_l = abs(twfe_l_bias),
              adl_s_nofe = abs(adl_s_nofe_bias), adl_l_nofe = abs(adl_l_nofe_bias),
              adl_s_fe = abs(adl_s_fe_bias), adl_l_fe = abs(adl_l_fe_bias))
  best_idx <- which.min(biases)
  .(best_model = names(biases)[best_idx],
    best_bias = round(biases[best_idx], 4),
    second_best = names(sort(biases))[2],
    second_bias = round(sort(biases)[2], 4))
}, by = rho_Z]
print(best_tab)

# ---- Save ----
fwrite(summ, "results/sim_dual_role_z_8models_results.csv")
fwrite(results, "results/sim_dual_role_z_8models_raw.csv")
cat("\nResults saved to results/sim_dual_role_z_8models_results.csv\n")

writeLines(capture.output(sessionInfo()),
           "results/sim_dual_role_z_8models_sessioninfo.txt")
