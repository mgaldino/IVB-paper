# ============================================================================
# sim_dual_role_z_varyT.R
# Same DGP as sim_dual_role_z.R but varying T to decompose Nickell bias
# Focus: rho_Z = 0.9 (worst case for IVB accumulation)
# ============================================================================

library(data.table)
library(fixest)

set.seed(2026)

# ---- DGP (same as main sim) ----
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

# ---- Estimation ----
est_models <- function(dt) {
  m_twfe_s <- feols(Y ~ D | id_f + time_f, dt, vcov = "iid")
  m_twfe_l <- feols(Y ~ D + Z_lag | id_f + time_f, dt, vcov = "iid")
  m_adl_s  <- feols(Y ~ D + Y_lag | id_f + time_f, dt, vcov = "iid")
  m_adl_l  <- feols(Y ~ D + Z_lag + Y_lag | id_f + time_f, dt, vcov = "iid")

  c(twfe_s = coef(m_twfe_s)["D"], twfe_l = coef(m_twfe_l)["D"],
    adl_s  = coef(m_adl_s)["D"],  adl_l  = coef(m_adl_l)["D"])
}

# ---- Grid: vary T and rho_Z ----
grid <- CJ(
  TT     = c(10L, 20L, 30L, 50L, 100L),
  rho_Z  = c(0.5, 0.9)
)

P <- list(N = 100, T_burn = 100, beta = 1,
          rho_Y = 0.5, rho_D = 0.5,
          gamma_D = 0.15, gamma_Y = 0.2,
          delta_D = 0.1,  delta_Y = 0.1,
          sigma_aZ = 0.5)
N_REPS <- 200

# ---- Run ----
cat("Varying T simulation:", nrow(grid), "scenarios x", N_REPS, "reps\n\n")

all_res <- vector("list", nrow(grid))

for (g in 1:nrow(grid)) {
  tt    <- grid$TT[g]
  rho_z <- grid$rho_Z[g]

  cat(sprintf("[%d/%d] T=%d, rho_Z=%.1f ... ", g, nrow(grid), tt, rho_z))
  t0 <- proc.time()

  res_g <- rbindlist(lapply(1:N_REPS, function(s) {
    dt <- sim_dual_z(P$N, tt, P$T_burn, P$beta, P$rho_Y, P$rho_D,
                     P$gamma_D, P$gamma_Y, P$delta_D, P$delta_Y,
                     rho_z, P$sigma_aZ)
    est <- est_models(dt)
    as.data.table(as.list(est))[, sim := s]
  }))

  res_g[, `:=`(TT = tt, rho_Z = rho_z)]
  all_res[[g]] <- res_g

  elapsed <- (proc.time() - t0)[3]
  cat(sprintf("%.1fs\n", elapsed))
}

results <- rbindlist(all_res)

# ---- Summary ----
beta_true <- P$beta

summ <- results[, .(
  twfe_bias_short = mean(twfe_s.D) - beta_true,
  twfe_bias_long  = mean(twfe_l.D) - beta_true,
  twfe_ivb        = mean(twfe_l.D - twfe_s.D),
  adl_bias_short  = mean(adl_s.D) - beta_true,
  adl_bias_long   = mean(adl_l.D) - beta_true,
  adl_ivb         = mean(adl_l.D - adl_s.D)
), by = .(TT, rho_Z)]

# Nickell bias indicator: ADL_short_bias should shrink with T
# (ADL short has no confounding from Z, bias is pure Nickell + residual)

cat("\n====================================================\n")
cat("BIAS BY T (decomposing Nickell from IVB)\n")
cat("====================================================\n\n")

for (rz in c(0.5, 0.9)) {
  cat(sprintf("--- rho_Z = %.1f ---\n", rz))
  s <- summ[rho_Z == rz,
            .(T = TT,
              `TWFE_short` = round(twfe_bias_short, 4),
              `TWFE_long`  = round(twfe_bias_long, 4),
              `TWFE_IVB`   = round(twfe_ivb, 4),
              `ADL_short`  = round(adl_bias_short, 4),
              `ADL_long`   = round(adl_bias_long, 4),
              `ADL_IVB`    = round(adl_ivb, 4))]
  print(s)
  cat("\n")
}

cat("INTERPRETATION:\n")
cat("- ADL_short bias = Nickell + OVB from omitting Z\n")
cat("- ADL_long bias  = Nickell + residual (should → 0 as T → ∞)\n")
cat("- If ADL_long → 0 as T grows: no Imai-Kim bias beyond Nickell\n")
cat("- TWFE_long bias stays constant in T: IVB is not a finite-T artifact\n\n")

fwrite(summ, "results/sim_dual_role_z_varyT_results.csv")
cat("Results saved.\n")
