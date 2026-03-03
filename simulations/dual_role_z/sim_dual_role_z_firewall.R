# ============================================================================
# sim_dual_role_z_firewall.R
# Test: Is the Y_{t-1} "firewall" a genuine d-separation mechanism or just
# correct specification?
#
# Approach: Set rho_Y = 0 (Y has no persistence). If ADL_FE_long still beats
# TWFE_long, the firewall is genuine (d-separation blocks collider paths).
# If not, the gain was merely from correctly specifying Y_{t-1} as a regressor.
#
# Also tests rho_Y = 0.8 (strong persistence) for comparison.
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

# ---- Estimation: 4 FE models ----
est_fe_models <- function(dt) {
  m1 <- feols(Y ~ D | id_f + time_f, dt, vcov = "iid")
  m2 <- feols(Y ~ D + Z_lag | id_f + time_f, dt, vcov = "iid")
  m3 <- feols(Y ~ D + Y_lag | id_f + time_f, dt, vcov = "iid")
  m4 <- feols(Y ~ D + Z_lag + Y_lag | id_f + time_f, dt, vcov = "iid")
  c(twfe_s  = coef(m1)["D"], twfe_l  = coef(m2)["D"],
    adl_s_fe = coef(m3)["D"], adl_l_fe = coef(m4)["D"])
}

# ---- Grid ----
grid <- CJ(
  rho_Z = c(0.3, 0.5, 0.7, 0.85),
  rho_Y = c(0.0, 0.5, 0.8)
)

P <- list(N = 100, TT = 30, T_burn = 100, beta = 1,
          rho_D = 0.5,
          gamma_D = 0.15, gamma_Y = 0.2,
          delta_D = 0.1, delta_Y = 0.1,
          sigma_aZ = 0.5)
N_REPS <- 500

# ---- Run ----
cat("Firewall test:", nrow(grid), "scenarios x", N_REPS, "reps\n\n")

all_res <- vector("list", nrow(grid))

for (g in 1:nrow(grid)) {
  rho_z <- grid$rho_Z[g]
  rho_y <- grid$rho_Y[g]

  cat(sprintf("[%2d/%d] rho_Z=%.2f rho_Y=%.1f ... ", g, nrow(grid), rho_z, rho_y))
  t0 <- proc.time()

  res_g <- rbindlist(lapply(1:N_REPS, function(s) {
    dt <- sim_dual_z(P$N, P$TT, P$T_burn, P$beta, rho_y, P$rho_D,
                     P$gamma_D, P$gamma_Y, P$delta_D, P$delta_Y,
                     rho_z, P$sigma_aZ)
    est <- est_fe_models(dt)
    as.data.table(as.list(est))[, sim := s]
  }))

  res_g[, `:=`(rho_Z = rho_z, rho_Y = rho_y)]
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
), by = .(rho_Z, rho_Y)]

# ---- Print ----
cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("FIREWALL TEST: Does Y_{t-1} help even when rho_Y = 0?\n")
cat(rep("=", 80), "\n\n")

for (ry in c(0.0, 0.5, 0.8)) {
  cat(sprintf("--- rho_Y = %.1f %s ---\n", ry,
              ifelse(ry == 0, "(NO Y persistence — pure firewall test)",
              ifelse(ry == 0.5, "(baseline)", "(strong Y persistence)"))))

  s <- summ[rho_Y == ry]
  tab <- s[, .(rho_Z,
    `TWFE_short` = round(twfe_s_bias, 4),
    `TWFE_long`  = round(twfe_l_bias, 4),
    `ADL_short`  = round(adl_s_bias, 4),
    `ADL_long`   = round(adl_l_bias, 4),
    `Firewall_gain` = round(abs(twfe_l_bias) - abs(adl_l_bias), 4))]
  print(tab)
  cat("\n")
}

cat("INTERPRETATION:\n")
cat("- If Firewall_gain > 0 when rho_Y = 0: Y_{t-1} blocks collider paths\n")
cat("  via d-separation, NOT via correct specification of dynamics.\n")
cat("- If Firewall_gain ≈ 0 when rho_Y = 0: the gain was from correct spec.\n")
cat("- If ADL_long bias is WORSE when rho_Y = 0: Y_{t-1} introduces noise\n")
cat("  without benefit when it's not a true regressor.\n\n")

fwrite(summ, "results/sim_dual_role_z_firewall_results.csv")
cat("Results saved.\n")
