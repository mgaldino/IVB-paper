# ============================================================================
# diag_heterogeneous.R
# Diagnostic: Heterogeneous treatment effects
#
# beta_i ~ N(1, sigma_beta²) — varies across units
# Regression estimates weighted average. Bias relative to E[beta_i] = 1.
# ============================================================================

library(data.table)
library(fixest)
set.seed(2026)

sim_dgp_het <- function(N, TT, T_burn, beta_mean, sigma_beta, rho_Y, rho_D,
                        gamma_D, gamma_Y, delta_D, delta_Y,
                        rho_Z, sigma_aZ, phi, beta2) {
  T_sim <- TT + T_burn
  alpha_D <- rnorm(N); alpha_Y <- rnorm(N); alpha_Z <- rnorm(N, 0, sigma_aZ)
  beta_i <- if (sigma_beta > 0) rnorm(N, beta_mean, sigma_beta) else rep(beta_mean, N)

  rows <- vector("list", N)
  for (i in 1:N) {
    D <- Y <- Z <- numeric(T_sim)
    D[1] <- alpha_D[i] + rnorm(1); Y[1] <- alpha_Y[i] + rnorm(1); Z[1] <- alpha_Z[i] + rnorm(1)
    for (t in 2:T_sim) {
      D[t] <- alpha_D[i] + gamma_D*Z[t-1] + rho_D*D[t-1] + phi*Y[t-1] + rnorm(1)
      Y[t] <- alpha_Y[i] + beta_i[i]*D[t] + beta2*D[t-1] + gamma_Y*Z[t-1] + rho_Y*Y[t-1] + rnorm(1)
      Z[t] <- alpha_Z[i] + delta_D*D[t] + delta_Y*Y[t] + rho_Z*Z[t-1] + rnorm(1)
    }
    idx <- (T_burn+1):T_sim
    rows[[i]] <- data.table(id=i, time=seq_along(idx), D=D[idx], Y=Y[idx],
                            D_lag=c(NA,D[idx[-length(idx)]]),
                            Y_lag=c(NA,Y[idx[-length(idx)]]),
                            Z_lag=c(NA,Z[idx[-length(idx)]]))
  }
  dt <- rbindlist(rows); dt <- dt[complete.cases(dt)]
  dt[, `:=`(id_f=factor(id), time_f=factor(time))]
}

est_models <- function(dt) {
  m1 <- feols(Y ~ D + Z_lag + Y_lag | id_f + time_f, dt, vcov="iid")
  m2 <- feols(Y ~ D + D_lag + Z_lag + Y_lag | id_f + time_f, dt, vcov="iid")
  m3 <- feols(Y ~ D | id_f + time_f, dt, vcov="iid")
  c(adl_full=coef(m1)["D"], adl_all=coef(m2)["D"], twfe_s=coef(m3)["D"])
}

# Grid
grid <- CJ(sigma_beta = c(0, 0.3, 0.5, 1.0),
           scenario = c("base", "extended"))
grid[scenario == "base", `:=`(phi=0, beta2=0)]
grid[scenario == "extended", `:=`(phi=0.05, beta2=0.2)]

P <- list(N=100, TT=30, T_burn=100, beta=1, rho_Y=0.5, rho_D=0.5,
          gamma_D=0.15, gamma_Y=0.2, delta_D=0.1, delta_Y=0.1,
          rho_Z=0.5, sigma_aZ=0.5)
N_REPS <- 200

cat("=== DIAGNOSTIC: HETEROGENEOUS TREATMENT EFFECTS ===\n")
cat("beta_i ~ N(1, sigma_beta^2). Bias measured relative to E[beta_i] = 1.\n")
cat(nrow(grid), "scenarios x", N_REPS, "reps\n\n")

all_res <- vector("list", nrow(grid))
for (g in 1:nrow(grid)) {
  sb <- grid$sigma_beta[g]; sc <- grid$scenario[g]
  ph <- grid$phi[g]; b2 <- grid$beta2[g]
  cat(sprintf("[%d/%d] sigma_beta=%.1f %s (phi=%.2f beta2=%.1f) ... ",
              g, nrow(grid), sb, sc, ph, b2))
  t0 <- proc.time()
  res_g <- rbindlist(lapply(1:N_REPS, function(s) {
    dt <- sim_dgp_het(P$N, P$TT, P$T_burn, P$beta, sb, P$rho_Y, P$rho_D,
                      P$gamma_D, P$gamma_Y, P$delta_D, P$delta_Y,
                      P$rho_Z, P$sigma_aZ, ph, b2)
    est <- est_models(dt)
    as.data.table(as.list(est))[, sim := s]
  }))
  res_g[, `:=`(sigma_beta=sb, scenario=sc, phi=ph, beta2=b2)]
  all_res[[g]] <- res_g
  cat(sprintf("%.1fs\n", (proc.time()-t0)[3]))
}

results <- rbindlist(all_res)
summ <- results[, .(
  twfe_s_bias   = mean(twfe_s.D) - 1,
  adl_full_bias = mean(adl_full.D) - 1,
  adl_all_bias  = mean(adl_all.D) - 1,
  adl_full_rmse = sqrt(mean((adl_full.D - 1)^2)),
  adl_all_rmse  = sqrt(mean((adl_all.D - 1)^2))
), by = .(sigma_beta, scenario, phi, beta2)]

cat("\n=== RESULTS ===\n\n")
cat("Bias (relative to E[beta_i] = 1) by heterogeneity level:\n\n")

for (sc in c("base", "extended")) {
  cat(sprintf("--- %s (phi=%.2f, beta2=%.1f) ---\n",
              sc, ifelse(sc=="base",0,0.05), ifelse(sc=="base",0,0.2)))
  s <- summ[scenario == sc]
  print(s[, .(sigma_beta,
    TWFE_s=round(twfe_s_bias,4),
    ADL_full=round(adl_full_bias,4),
    ADL_all=round(adl_all_bias,4),
    RMSE_full=round(adl_full_rmse,4),
    RMSE_all=round(adl_all_rmse,4))])
  cat("\n")
}

cat("Key question: Does heterogeneity change model ranking or bias magnitude?\n")
cat("If bias is similar across sigma_beta, ADL results are robust to heterogeneity.\n")

fwrite(summ, "results/diag_heterogeneous_results.csv")
