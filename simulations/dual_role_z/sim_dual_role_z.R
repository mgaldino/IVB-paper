# ============================================================================
# sim_dual_role_z.R
# Simulation: Dual-role Z (confounder + collider) under TWFE and ADL
# Purpose: Confirm DAG predictions about IVB accumulation with Z persistence
#
# DGP (unit i, period t):
#   D_{it} = α^D_i + γ_D Z_{i,t-1} + ρ_D D_{i,t-1} + u_{it}
#   Y_{it} = α^Y_i + β D_{it} + γ_Y Z_{i,t-1} + ρ_Y Y_{i,t-1} + e_{it}
#   Z_{it} = α^Z_i + δ_D D_{it} + δ_Y Y_{it} + Σ_k ρ_{Z,k} Z_{i,t-k} + ν_{it}
#
# Z is confounder: Z_{t-1} → D_t (γ_D), Z_{t-1} → Y_t (γ_Y)
# Z is collider:   D_t → Z_t (δ_D), Y_t → Z_t (δ_Y)
# Z has persistence: Z_{t-1} → Z_t (ρ_Z)
#
# Researcher estimates 4 models:
#   TWFE short: Y ~ D            | FE          (omits Z: OVB)
#   TWFE long:  Y ~ D + Z_{t-1}  | FE          (includes Z: trades OVB for IVB)
#   ADL short:  Y ~ D + Y_{t-1}  | FE          (omits Z: OVB, has Nickell bias)
#   ADL long:   Y ~ D + Z_{t-1} + Y_{t-1} | FE (Y_{t-1} blocks collider paths)
# ============================================================================

library(data.table)
library(fixest)

set.seed(2026)

# ---- DGP ----
sim_dual_z <- function(N, TT, T_burn, beta, rho_Y, rho_D,
                       gamma_D, gamma_Y, delta_D, delta_Y,
                       rho_Z_vec, sigma_aZ) {
  T_sim <- TT + T_burn
  p_Z <- length(rho_Z_vec)

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

      z_ar <- 0
      for (k in 1:min(p_Z, t - 1)) {
        z_ar <- z_ar + rho_Z_vec[k] * Z[t - k]
      }
      Z[t] <- alpha_Z[i] + delta_D * D[t] + delta_Y * Y[t] + z_ar + nu
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

# ---- Grid ----
grid <- CJ(
  rho_Z_total = c(0.1, 0.3, 0.5, 0.7, 0.9),
  ar_order    = c(1L, 3L),
  sigma_aZ    = c(0.5, 2.0)
)

# Fixed parameters
P <- list(N = 100, TT = 30, T_burn = 100, beta = 1,
          rho_Y = 0.5, rho_D = 0.5,
          gamma_D = 0.15, gamma_Y = 0.2,
          delta_D = 0.1,  delta_Y = 0.1)
N_REPS <- 200

# ---- Run ----
cat("Starting simulation:", nrow(grid), "scenarios x", N_REPS, "reps\n\n")

all_res <- vector("list", nrow(grid))

for (g in 1:nrow(grid)) {
  rho_tot <- grid$rho_Z_total[g]
  ar_p    <- grid$ar_order[g]
  sig_aZ  <- grid$sigma_aZ[g]

  # Distribute total persistence across lags (geometric decay)
  if (ar_p == 1L) {
    rho_vec <- rho_tot
  } else {
    w <- 1 / 2^(0:(ar_p - 1))
    rho_vec <- rho_tot * w / sum(w)
  }

  cat(sprintf("[%2d/%d] rho_Z=%.1f AR(%d) sigma_aZ=%.1f ... ",
              g, nrow(grid), rho_tot, ar_p, sig_aZ))

  t0 <- proc.time()

  res_g <- rbindlist(lapply(1:N_REPS, function(s) {
    dt <- sim_dual_z(P$N, P$TT, P$T_burn, P$beta, P$rho_Y, P$rho_D,
                     P$gamma_D, P$gamma_Y, P$delta_D, P$delta_Y,
                     rho_vec, sig_aZ)
    est <- est_models(dt)
    as.data.table(as.list(est))[, sim := s]
  }))

  res_g[, `:=`(rho_Z = rho_tot, ar_order = ar_p, sigma_aZ = sig_aZ)]
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
  adl_ivb         = mean(adl_l.D - adl_s.D),
  n_sims          = .N
), by = .(rho_Z, ar_order, sigma_aZ)]

# Net benefit: positive = including Z reduces |bias|
summ[, `:=`(
  twfe_net = abs(twfe_bias_short) - abs(twfe_bias_long),
  adl_net  = abs(adl_bias_short)  - abs(adl_bias_long),
  # Best model: which has smallest |bias|?
  best_abs_bias = pmin(abs(twfe_bias_short), abs(twfe_bias_long),
                       abs(adl_bias_short), abs(adl_bias_long))
)]

summ[, best_model := fcase(
  best_abs_bias == abs(twfe_bias_short), "TWFE_short",
  best_abs_bias == abs(twfe_bias_long),  "TWFE_long",
  best_abs_bias == abs(adl_bias_short),  "ADL_short",
  best_abs_bias == abs(adl_bias_long),   "ADL_long"
)]

# ---- Print ----
cat("\n====================================================\n")
cat("DGP: beta=1, rho_Y=0.5, rho_D=0.5\n")
cat("Confounder: gamma_D=0.15 (Z->D), gamma_Y=0.2 (Z->Y)\n")
cat("Collider:   delta_D=0.1  (D->Z), delta_Y=0.1 (Y->Z)\n")
cat("N=100, T=30, 200 reps per scenario\n")
cat("====================================================\n\n")

# Print by sigma_aZ
for (sa in c(0.5, 2.0)) {
  cat(sprintf("--- sigma_alpha_Z = %.1f (between variation %s) ---\n",
              sa, ifelse(sa > 1, "HIGH", "LOW")))

  s <- summ[sigma_aZ == sa,
            .(rho_Z, ar_order,
              `TWFE_short_bias` = round(twfe_bias_short, 4),
              `TWFE_long_bias`  = round(twfe_bias_long, 4),
              `TWFE_IVB`        = round(twfe_ivb, 4),
              `TWFE_net`        = round(twfe_net, 4),
              `ADL_short_bias`  = round(adl_bias_short, 4),
              `ADL_long_bias`   = round(adl_bias_long, 4),
              `ADL_IVB`         = round(adl_ivb, 4),
              `ADL_net`         = round(adl_net, 4),
              best_model)]

  print(s, nrows = 20)
  cat("\n")
}

# ---- Key findings ----
cat("KEY FINDINGS:\n")
cat("- TWFE_net > 0 means including Z reduces bias (confounder control helps)\n")
cat("- TWFE_net < 0 means including Z increases bias (collider IVB dominates)\n")
cat("- ADL_net > 0 means including Z helps in ADL (Y_{t-1} blocks collider)\n")
cat("- 'best_model' = which specification has smallest |bias|\n\n")

# Check: does IVB grow with rho_Z in TWFE but not ADL?
cat("IVB magnitude by rho_Z (AR(1), sigma_aZ=0.5):\n")
print(summ[ar_order == 1 & sigma_aZ == 0.5,
           .(rho_Z,
             `|TWFE_IVB|` = round(abs(twfe_ivb), 4),
             `|ADL_IVB|`  = round(abs(adl_ivb), 4))])

# Save
fwrite(summ, "results/sim_dual_role_z_results.csv")
fwrite(results, "results/sim_dual_role_z_raw.csv")
cat("\nResults saved.\n")

# Session info
writeLines(capture.output(sessionInfo()),
           "results/sim_dual_role_z_sessioninfo.txt")
