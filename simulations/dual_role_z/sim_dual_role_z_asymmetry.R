# ============================================================================
# sim_dual_role_z_asymmetry.R
# Vary confounder strength (gamma_D: Z->D) vs collider strength (delta_Y: Y->Z)
# to map when including Z helps vs hurts
#
# Key question: when does OVB reduction > IVB introduction?
# ============================================================================

library(data.table)
library(fixest)

set.seed(2026)

# ---- DGP (same as 8models) ----
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

# ---- Estimation: 4 key models ----
est_models <- function(dt) {
  m1 <- feols(Y ~ D | id_f + time_f, dt, vcov = "iid")              # TWFE short
  m2 <- feols(Y ~ D + Z_lag | id_f + time_f, dt, vcov = "iid")      # TWFE long
  m3 <- feols(Y ~ D + Y_lag | id_f + time_f, dt, vcov = "iid")      # ADL short FE
  m4 <- feols(Y ~ D + Z_lag + Y_lag | id_f + time_f, dt, vcov = "iid") # ADL long FE
  c(twfe_s  = coef(m1)["D"], twfe_l  = coef(m2)["D"],
    adl_s_fe = coef(m3)["D"], adl_l_fe = coef(m4)["D"])
}

# ---- Grid: confounder strength vs collider strength ----
grid <- CJ(
  gamma_D = c(0.00, 0.05, 0.15, 0.30),   # Z -> D (confounder channel)
  delta_Y = c(0.00, 0.05, 0.10, 0.20, 0.30) # Y -> Z (collider channel)
)

P <- list(N = 100, TT = 30, T_burn = 100, beta = 1,
          rho_Y = 0.5, rho_D = 0.5,
          gamma_Y = 0.2,    # Z -> Y (fixed, always confounder for Y)
          delta_D = 0.1,    # D -> Z (fixed, always collider)
          rho_Z = 0.5, sigma_aZ = 0.5)
N_REPS <- 500

# ---- Run ----
cat("Asymmetry simulation:", nrow(grid), "scenarios x", N_REPS, "reps\n")
cat("Varying: gamma_D (Z->D confounder) x delta_Y (Y->Z collider)\n")
cat("Fixed: gamma_Y=0.2, delta_D=0.1, rho_Z=0.5, rho_Y=0.5\n\n")

all_res <- vector("list", nrow(grid))

for (g in 1:nrow(grid)) {
  gd <- grid$gamma_D[g]
  dy <- grid$delta_Y[g]

  cat(sprintf("[%2d/%d] gamma_D=%.2f delta_Y=%.2f ... ", g, nrow(grid), gd, dy))
  t0 <- proc.time()

  res_g <- rbindlist(lapply(1:N_REPS, function(s) {
    dt <- sim_dual_z(P$N, P$TT, P$T_burn, P$beta, P$rho_Y, P$rho_D,
                     gd, P$gamma_Y, P$delta_D, dy,
                     P$rho_Z, P$sigma_aZ)
    est <- est_models(dt)
    as.data.table(as.list(est))[, sim := s]
  }))

  res_g[, `:=`(gamma_D = gd, delta_Y = dy)]
  all_res[[g]] <- res_g
  elapsed <- (proc.time() - t0)[3]
  cat(sprintf("%.1fs\n", elapsed))
}

results <- rbindlist(all_res)
beta_true <- P$beta

summ <- results[, .(
  twfe_s_bias  = mean(twfe_s.D) - beta_true,
  twfe_l_bias  = mean(twfe_l.D) - beta_true,
  adl_s_bias   = mean(adl_s_fe.D) - beta_true,
  adl_l_bias   = mean(adl_l_fe.D) - beta_true,
  twfe_s_mcse  = sd(twfe_s.D) / sqrt(.N),
  twfe_l_mcse  = sd(twfe_l.D) / sqrt(.N),
  adl_s_mcse   = sd(adl_s_fe.D) / sqrt(.N),
  adl_l_mcse   = sd(adl_l_fe.D) / sqrt(.N)
), by = .(gamma_D, delta_Y)]

# ---- Print ----
cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("ASYMMETRY: Confounder (gamma_D) vs Collider (delta_Y)\n")
cat(rep("=", 80), "\n\n")

cat("A. BIAS TABLE (all 4 models):\n")
tab <- summ[, .(gamma_D, delta_Y,
  `TWFE_s` = round(twfe_s_bias, 4),
  `TWFE_l` = round(twfe_l_bias, 4),
  `ADL_s`  = round(adl_s_bias, 4),
  `ADL_l`  = round(adl_l_bias, 4))]
print(tab)

cat("\nB. NET BENEFIT of including Z in TWFE (|TWFE_s| - |TWFE_l|, >0 = Z helps):\n")
net_twfe <- summ[, .(gamma_D, delta_Y,
  Net_TWFE = round(abs(twfe_s_bias) - abs(twfe_l_bias), 4))]
# Reshape to matrix form
net_mat <- dcast(net_twfe, gamma_D ~ delta_Y, value.var = "Net_TWFE")
setnames(net_mat, old = names(net_mat)[-1],
         new = paste0("dY=", names(net_mat)[-1]))
cat("Rows: gamma_D (confounder). Cols: delta_Y (collider).\n")
print(net_mat)

cat("\nC. NET BENEFIT of including Z in ADL+FE (|ADL_s| - |ADL_l|, >0 = Z helps):\n")
net_adl <- summ[, .(gamma_D, delta_Y,
  Net_ADL = round(abs(adl_s_bias) - abs(adl_l_bias), 4))]
net_mat2 <- dcast(net_adl, gamma_D ~ delta_Y, value.var = "Net_ADL")
setnames(net_mat2, old = names(net_mat2)[-1],
         new = paste0("dY=", names(net_mat2)[-1]))
cat("Rows: gamma_D (confounder). Cols: delta_Y (collider).\n")
print(net_mat2)

cat("\nD. BEST MODEL per scenario:\n")
best <- summ[, {
  biases <- c(TWFE_s = abs(twfe_s_bias), TWFE_l = abs(twfe_l_bias),
              ADL_s = abs(adl_s_bias), ADL_l = abs(adl_l_bias))
  best_idx <- which.min(biases)
  .(best = names(biases)[best_idx],
    bias = round(biases[best_idx], 4))
}, by = .(gamma_D, delta_Y)]
best_mat <- dcast(best, gamma_D ~ delta_Y, value.var = "best")
setnames(best_mat, old = names(best_mat)[-1],
         new = paste0("dY=", names(best_mat)[-1]))
cat("Rows: gamma_D (confounder). Cols: delta_Y (collider).\n")
print(best_mat)

cat("\nE. SPECIAL CASES:\n")
cat("   gamma_D=0, delta_Y=0: Z is pure collider (D->Z only), no Z->D confounding\n")
s00 <- summ[gamma_D == 0 & delta_Y == 0]
cat(sprintf("     TWFE_s=%.4f, TWFE_l=%.4f, ADL_s=%.4f, ADL_l=%.4f\n",
            s00$twfe_s_bias, s00$twfe_l_bias, s00$adl_s_bias, s00$adl_l_bias))

cat("   gamma_D=0.30, delta_Y=0: Z is pure confounder (Z->D, Z->Y), no Y->Z collider\n")
s30 <- summ[gamma_D == 0.30 & delta_Y == 0]
cat(sprintf("     TWFE_s=%.4f, TWFE_l=%.4f, ADL_s=%.4f, ADL_l=%.4f\n",
            s30$twfe_s_bias, s30$twfe_l_bias, s30$adl_s_bias, s30$adl_l_bias))

cat("   gamma_D=0, delta_Y=0.30: Z is pure collider (D->Z, Y->Z), strong feedback\n")
s03 <- summ[gamma_D == 0 & delta_Y == 0.30]
cat(sprintf("     TWFE_s=%.4f, TWFE_l=%.4f, ADL_s=%.4f, ADL_l=%.4f\n",
            s03$twfe_s_bias, s03$twfe_l_bias, s03$adl_s_bias, s03$adl_l_bias))

cat("\nINTERPRETATION:\n")
cat("- When gamma_D=0: Z->D confounding is zero. Including Z should only hurt\n")
cat("  (introduces IVB without reducing OVB from Z->D channel).\n")
cat("- But gamma_Y=0.2 always: Z->Y confounding is always present.\n")
cat("  So omitting Z always causes OVB from the Z->Y channel.\n")
cat("- Net benefit depends on: OVB(gamma_D, gamma_Y) vs IVB(delta_D, delta_Y, rho_Y)\n")
cat("- ADL+FE with Y_lag should dominate across all scenarios.\n\n")

fwrite(summ, "results/sim_dual_role_z_asymmetry_results.csv")
cat("Results saved.\n")
