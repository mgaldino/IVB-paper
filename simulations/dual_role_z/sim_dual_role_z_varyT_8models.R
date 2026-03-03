# ============================================================================
# sim_dual_role_z_varyT_8models.R
# Same DGP as 8models but varying T to decompose Nickell bias
# ============================================================================

library(data.table)
library(fixest)

set.seed(2026)

# ---- DGP (same) ----
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
  m1 <- lm(Y ~ D, data = dt)
  m2 <- lm(Y ~ D + Z_lag, data = dt)
  m3 <- feols(Y ~ D | id_f + time_f, dt, vcov = "iid")
  m4 <- feols(Y ~ D + Z_lag | id_f + time_f, dt, vcov = "iid")
  m5 <- lm(Y ~ D + Y_lag, data = dt)
  m6 <- lm(Y ~ D + Z_lag + Y_lag, data = dt)
  m7 <- feols(Y ~ D + Y_lag | id_f + time_f, dt, vcov = "iid")
  m8 <- feols(Y ~ D + Z_lag + Y_lag | id_f + time_f, dt, vcov = "iid")
  c(pooled_s   = coef(m1)["D"],  pooled_l   = coef(m2)["D"],
    twfe_s     = coef(m3)["D"],  twfe_l     = coef(m4)["D"],
    adl_s_nofe = coef(m5)["D"],  adl_l_nofe = coef(m6)["D"],
    adl_s_fe   = coef(m7)["D"],  adl_l_fe   = coef(m8)["D"])
}

# ---- Grid ----
grid <- CJ(
  TT    = c(10L, 20L, 30L, 50L, 100L),
  rho_Z = c(0.5, 0.85)
)

P <- list(N = 100, T_burn = 100, beta = 1,
          rho_Y = 0.5, rho_D = 0.5,
          gamma_D = 0.15, gamma_Y = 0.2,
          delta_D = 0.1, delta_Y = 0.1,
          sigma_aZ = 0.5)
N_REPS <- 500

# ---- Run ----
cat("VaryT 8-model simulation:", nrow(grid), "scenarios x", N_REPS, "reps\n\n")

all_res <- vector("list", nrow(grid))

for (g in 1:nrow(grid)) {
  tt    <- grid$TT[g]
  rho_z <- grid$rho_Z[g]

  cat(sprintf("[%2d/%d] T=%d, rho_Z=%.2f ... ", g, nrow(grid), tt, rho_z))
  t0 <- proc.time()

  res_g <- rbindlist(lapply(1:N_REPS, function(s) {
    dt <- sim_dual_z(P$N, tt, P$T_burn, P$beta, P$rho_Y, P$rho_D,
                     P$gamma_D, P$gamma_Y, P$delta_D, P$delta_Y,
                     rho_z, P$sigma_aZ)
    est <- est_8models(dt)
    as.data.table(as.list(est))[, sim := s]
  }))

  res_g[, `:=`(TT = tt, rho_Z = rho_z)]
  all_res[[g]] <- res_g
  elapsed <- (proc.time() - t0)[3]
  cat(sprintf("%.1fs\n", elapsed))
}

results <- rbindlist(all_res)
beta_true <- P$beta

mod_cols <- c("pooled_s.D", "pooled_l.D", "twfe_s.D", "twfe_l.D",
              "adl_s_nofe.D", "adl_l_nofe.D", "adl_s_fe.D", "adl_l_fe.D")
mod_names <- c("pooled_s", "pooled_l", "twfe_s", "twfe_l",
               "adl_s_nofe", "adl_l_nofe", "adl_s_fe", "adl_l_fe")

summ <- results[, {
  out <- list()
  for (j in seq_along(mod_cols)) {
    vals <- get(mod_cols[j])
    out[[paste0(mod_names[j], "_bias")]] <- mean(vals) - beta_true
    out[[paste0(mod_names[j], "_mcse")]] <- sd(vals) / sqrt(.N)
  }
  out$n_sims <- .N
  out
}, by = .(TT, rho_Z)]

# ---- Print ----
cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("BIAS BY T — KEY MODELS (focus: does bias vanish with T?)\n")
cat(rep("=", 80), "\n\n")

for (rz in c(0.5, 0.85)) {
  cat(sprintf("--- rho_Z = %.2f ---\n", rz))
  s <- summ[rho_Z == rz]

  cat("\nBias:\n")
  tab <- s[, .(T = TT,
    `TWFE_l`     = round(twfe_l_bias, 4),
    `ADL_noFE_l` = round(adl_l_nofe_bias, 4),
    `ADL_FE_l`   = round(adl_l_fe_bias, 4),
    `ADL_FE_s`   = round(adl_s_fe_bias, 4),
    `TWFE_s`     = round(twfe_s_bias, 4))]
  print(tab)

  cat("\nMC SE:\n")
  mcse <- s[, .(T = TT,
    `TWFE_l`     = round(twfe_l_mcse, 4),
    `ADL_noFE_l` = round(adl_l_nofe_mcse, 4),
    `ADL_FE_l`   = round(adl_l_fe_mcse, 4),
    `ADL_FE_s`   = round(adl_s_fe_mcse, 4))]
  print(mcse)

  cat("\nFirewall gain (|TWFE_long| - |ADL_FE_long|):\n")
  fw <- s[, .(T = TT,
    Firewall = round(abs(twfe_l_bias) - abs(adl_l_fe_bias), 4))]
  print(fw)

  cat("\nNickell cost (|ADL_FE_long| - |ADL_noFE_long|):\n")
  nk <- s[, .(T = TT,
    Nickell = round(abs(adl_l_fe_bias) - abs(adl_l_nofe_bias), 4))]
  print(nk)
  cat("\n")
}

cat("INTERPRETATION:\n")
cat("- ADL_FE_long bias should → 0 as T → ∞ (Nickell vanishes)\n")
cat("- TWFE_long bias should stay constant in T (not a finite-T artifact)\n")
cat("- ADL_noFE_long bias should stay constant (OVB from alpha_i, not T-dependent)\n")
cat("- Firewall gain should be stable or grow with T\n")
cat("- Nickell cost should → 0 as T → ∞\n\n")

fwrite(summ, "results/sim_dual_role_z_varyT_8models_results.csv")
cat("Results saved.\n")
