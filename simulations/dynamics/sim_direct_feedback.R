# ============================================================================
# sim_direct_feedback.R
# Sim 1: Direct feedback Y_{t-1} → D_t (Imai & Kim assumption (c) violated)
#
# DGP:
#   D_t = α^D_i + γ_D Z_{t-1} + ρ_D D_{t-1} + φ Y_{t-1} + u_t     ← NEW
#   Y_t = α^Y_i + β D_t + γ_Y Z_{t-1} + ρ_Y Y_{t-1} + e_t
#   Z_t = α^Z_i + δ_D D_t + δ_Y Y_t + ρ_Z Z_{t-1} + ν_t
#
# Grid: φ ∈ {0, 0.05, 0.1} × ρ_Z ∈ {0.5, 0.7} = 6 scenarios × 500 reps
# Note: φ=0.2 and ρ_Z=0.85 excluded — VAR system is non-stationary
#
# 6 models:
#   1. TWFE short:   Y ~ D | FE
#   2. TWFE long:    Y ~ D + Z_lag | FE
#   3. ADL Y_lag:    Y ~ D + Y_lag | FE
#   4. ADL full:     Y ~ D + Z_lag + Y_lag | FE
#   5. Pooled long:  Y ~ D + Z_lag + Y_lag
#   6. ADL+Dlag FE:  Y ~ D + D_lag + Z_lag + Y_lag | FE (preview of Sim 2)
#
# Question: When Y affects D directly (strict exogeneity violated),
# does Nickell bias become substantive? Does ADL+FE+Z still dominate?
# ============================================================================

library(data.table)
library(fixest)

set.seed(2026)

# ---- DGP with direct feedback ----
sim_feedback <- function(N, TT, T_burn, beta, rho_Y, rho_D,
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
      Y[t] <- alpha_Y[i] + beta * D[t] + gamma_Y * Z[t - 1] +
              rho_Y * Y[t - 1] + e
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

# ---- Estimation: 6 models ----
est_models_feedback <- function(dt) {
  # 1. TWFE short: Y ~ D | FE
  m1 <- feols(Y ~ D | id_f + time_f, dt, vcov = "iid")
  # 2. TWFE long: Y ~ D + Z_lag | FE
  m2 <- feols(Y ~ D + Z_lag | id_f + time_f, dt, vcov = "iid")
  # 3. ADL Y_lag: Y ~ D + Y_lag | FE
  m3 <- feols(Y ~ D + Y_lag | id_f + time_f, dt, vcov = "iid")
  # 4. ADL full: Y ~ D + Z_lag + Y_lag | FE
  m4 <- feols(Y ~ D + Z_lag + Y_lag | id_f + time_f, dt, vcov = "iid")
  # 5. Pooled long: Y ~ D + Z_lag + Y_lag
  m5 <- lm(Y ~ D + Z_lag + Y_lag, data = dt)
  # 6. ADL+Dlag FE: Y ~ D + D_lag + Z_lag + Y_lag | FE (preview of fully dynamic)
  m6 <- feols(Y ~ D + D_lag + Z_lag + Y_lag | id_f + time_f, dt, vcov = "iid")

  c(twfe_s    = coef(m1)["D"],
    twfe_l    = coef(m2)["D"],
    adl_Ylag  = coef(m3)["D"],
    adl_full  = coef(m4)["D"],
    pooled_l  = coef(m5)["D"],
    adl_Dlag  = coef(m6)["D"])
}

# ---- Grid ----
grid <- CJ(
  phi   = c(0, 0.05, 0.1),
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
cat("SIM 1: DIRECT FEEDBACK Y_{t-1} → D_t\n")
cat(rep("=", 71), "\n\n")
cat(nrow(grid), "scenarios x", N_REPS, "reps\n")
cat("DGP: beta=1, rho_Y=0.5, rho_D=0.5, gamma_D=0.15, gamma_Y=0.2\n")
cat("     delta_D=0.1, delta_Y=0.1, N=100, T=30, T_burn=100\n")
cat("NEW: phi Y_{t-1} → D_t (direct feedback)\n\n")

all_res <- vector("list", nrow(grid))
elapsed_times <- numeric(nrow(grid))
t0_total <- proc.time()

for (g in 1:nrow(grid)) {
  ph   <- grid$phi[g]
  rz   <- grid$rho_Z[g]

  cat(sprintf("[%d/%d] phi=%.2f rho_Z=%.2f ... ", g, nrow(grid), ph, rz))
  t0 <- proc.time()

  res_g <- rbindlist(lapply(1:N_REPS, function(s) {
    dt <- sim_feedback(P$N, P$TT, P$T_burn, P$beta, P$rho_Y, P$rho_D,
                       P$gamma_D, P$gamma_Y, P$delta_D, P$delta_Y,
                       rz, P$sigma_aZ, ph)
    est <- est_models_feedback(dt)
    as.data.table(as.list(est))[, sim := s]
  }))

  res_g[, `:=`(phi = ph, rho_Z = rz)]
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
              "pooled_l.D", "adl_Dlag.D")
mod_names <- c("twfe_s", "twfe_l", "adl_Ylag", "adl_full",
               "pooled_l", "adl_Dlag")

summ <- results[, {
  out <- list()
  for (j in seq_along(mod_cols)) {
    vals <- get(mod_cols[j])
    out[[paste0(mod_names[j], "_bias")]] <- mean(vals) - beta_true
    out[[paste0(mod_names[j], "_mcse")]] <- sd(vals) / sqrt(.N)
    out[[paste0(mod_names[j], "_sd")]]   <- sd(vals)
    out[[paste0(mod_names[j], "_rmse")]] <- sqrt(mean((vals - beta_true)^2))
  }
  out$n_sims <- .N
  out
}, by = .(phi, rho_Z)]

# ---- Print results ----
cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("RESULTS: BIAS BY MODEL (beta_true = 1)\n")
cat(rep("=", 80), "\n\n")

for (rz in c(0.5, 0.7)) {
  cat(sprintf("--- rho_Z = %.2f ---\n\n", rz))
  s <- summ[rho_Z == rz]

  cat("BIAS (estimate - beta_true):\n")
  bias_tab <- s[, .(phi,
    `TWFE_s`    = round(twfe_s_bias, 4),
    `TWFE_l`    = round(twfe_l_bias, 4),
    `ADL_Ylag`  = round(adl_Ylag_bias, 4),
    `ADL_full`  = round(adl_full_bias, 4),
    `Pool_l`    = round(pooled_l_bias, 4),
    `ADL_Dlag`  = round(adl_Dlag_bias, 4))]
  print(bias_tab)

  cat("\nRMSE:\n")
  rmse_tab <- s[, .(phi,
    `TWFE_s`    = round(twfe_s_rmse, 4),
    `TWFE_l`    = round(twfe_l_rmse, 4),
    `ADL_Ylag`  = round(adl_Ylag_rmse, 4),
    `ADL_full`  = round(adl_full_rmse, 4),
    `Pool_l`    = round(pooled_l_rmse, 4),
    `ADL_Dlag`  = round(adl_Dlag_rmse, 4))]
  print(rmse_tab)

  cat("\nMC STANDARD ERRORS:\n")
  mcse_tab <- s[, .(phi,
    `TWFE_s`    = round(twfe_s_mcse, 4),
    `TWFE_l`    = round(twfe_l_mcse, 4),
    `ADL_Ylag`  = round(adl_Ylag_mcse, 4),
    `ADL_full`  = round(adl_full_mcse, 4),
    `Pool_l`    = round(pooled_l_mcse, 4),
    `ADL_Dlag`  = round(adl_Dlag_mcse, 4))]
  print(mcse_tab)
  cat("\n")
}

# ---- Decompositions ----
cat(rep("=", 80), "\n", sep = "")
cat("DECOMPOSITIONS\n")
cat(rep("=", 80), "\n\n")

cat("A. IVB by specification (bias_long - bias_short):\n")
ivb_tab <- summ[, .(phi, rho_Z,
  `IVB_TWFE`     = round(twfe_l_bias - twfe_s_bias, 4),
  `IVB_ADL`      = round(adl_full_bias - adl_Ylag_bias, 4))]
print(ivb_tab)

cat("\nB. Net benefit of including Z (|bias_short| - |bias_long|, >0 = Z helps):\n")
net_tab <- summ[, .(phi, rho_Z,
  `Net_TWFE`  = round(abs(twfe_s_bias) - abs(twfe_l_bias), 4),
  `Net_ADL`   = round(abs(adl_Ylag_bias) - abs(adl_full_bias), 4))]
print(net_tab)

cat("\nC. Net FE benefit (|ADL_noFE| - |ADL_FE|, >0 = FE helps, pooled_l = no FE):\n")
fe_tab <- summ[, .(phi, rho_Z,
  `Pooled_l`      = round(pooled_l_bias, 4),
  `ADL_full`      = round(adl_full_bias, 4),
  `Net_FE_benefit` = round(abs(pooled_l_bias) - abs(adl_full_bias), 4))]
print(fe_tab)

cat("\nD. Feedback effect (bias change from phi=0 to phi>0):\n")
baseline <- summ[phi == 0, .(rho_Z, base_bias = adl_full_bias)]
fb_tab <- summ[phi > 0][baseline, on = "rho_Z"][, .(phi, rho_Z,
  `Base_bias`  = round(base_bias, 4),
  `New_bias`   = round(adl_full_bias, 4),
  `Delta`      = round(adl_full_bias - base_bias, 4))]
print(fb_tab)

cat("\nE. Best model (smallest |bias|) per scenario:\n")
best_tab <- summ[, {
  biases <- c(twfe_s = abs(twfe_s_bias), twfe_l = abs(twfe_l_bias),
              adl_Ylag = abs(adl_Ylag_bias), adl_full = abs(adl_full_bias),
              pooled_l = abs(pooled_l_bias), adl_Dlag = abs(adl_Dlag_bias))
  best_idx <- which.min(biases)
  .(best_model = names(biases)[best_idx],
    best_bias = round(biases[best_idx], 4))
}, by = .(phi, rho_Z)]
print(best_tab)

# ---- Save ----
fwrite(summ, "results/sim_direct_feedback_results.csv")
fwrite(results, "results/sim_direct_feedback_raw.csv")

timing <- data.table(grid, elapsed_s = elapsed_times, total_s = total_elapsed)
fwrite(timing, "results/sim_direct_feedback_timing.csv")

cat("\nResults saved to results/sim_direct_feedback_results.csv\n")
cat(sprintf("Timing saved (total %.1fs)\n", total_elapsed))

writeLines(capture.output(sessionInfo()),
           "results/sim_direct_feedback_sessioninfo.txt")
