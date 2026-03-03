# ============================================================================
# diag_phi_bias_mechanism.R
# Diagnostic: Why does ADL_full bias DECREASE with phi?
#
# Hypothesis: phi increases R²(D ~ Y_lag | FE), so more "contaminated" variation
# in D is absorbed by Y_lag. Residual D is cleaner (more exogenous).
#
# Tests:
# 1. ADL_full with FE vs without FE — does pattern disappear without FE?
# 2. rho_Y = 0 vs 0.5 — does pattern disappear without Nickell source?
# 3. R²(D ~ Y_lag | FE) — does it increase with phi?
# ============================================================================

library(data.table)
library(fixest)
set.seed(2026)

sim_dgp <- function(N, TT, T_burn, beta, rho_Y, rho_D,
                    gamma_D, gamma_Y, delta_D, delta_Y,
                    rho_Z, sigma_aZ, phi) {
  T_sim <- TT + T_burn
  alpha_D <- rnorm(N); alpha_Y <- rnorm(N); alpha_Z <- rnorm(N, 0, sigma_aZ)
  rows <- vector("list", N)
  for (i in 1:N) {
    D <- Y <- Z <- numeric(T_sim)
    D[1] <- alpha_D[i] + rnorm(1); Y[1] <- alpha_Y[i] + rnorm(1); Z[1] <- alpha_Z[i] + rnorm(1)
    for (t in 2:T_sim) {
      D[t] <- alpha_D[i] + gamma_D*Z[t-1] + rho_D*D[t-1] + phi*Y[t-1] + rnorm(1)
      Y[t] <- alpha_Y[i] + beta*D[t] + gamma_Y*Z[t-1] + rho_Y*Y[t-1] + rnorm(1)
      Z[t] <- alpha_Z[i] + delta_D*D[t] + delta_Y*Y[t] + rho_Z*Z[t-1] + rnorm(1)
    }
    idx <- (T_burn+1):T_sim
    rows[[i]] <- data.table(id=i, time=seq_along(idx), D=D[idx], Y=Y[idx],
                            Y_lag=c(NA,Y[idx[-length(idx)]]), Z_lag=c(NA,Z[idx[-length(idx)]]))
  }
  dt <- rbindlist(rows); dt <- dt[complete.cases(dt)]
  dt[, `:=`(id_f=factor(id), time_f=factor(time))]
}

est_phi_diag <- function(dt) {
  m_fe  <- feols(Y ~ D + Z_lag + Y_lag | id_f + time_f, dt, vcov="iid")
  m_nofe <- lm(Y ~ D + Z_lag + Y_lag, data=dt)
  # R² of D ~ Y_lag | FE (how much Y_lag explains D after FE)
  m_d <- feols(D ~ Y_lag | id_f + time_f, dt, vcov="iid")
  c(adl_fe = coef(m_fe)["D"], adl_nofe = coef(m_nofe)["D"], r2_D_Ylag = unname(r2(m_d, "wr2")))
}

# Grid
grid <- CJ(phi = c(0, 0.05, 0.10, 0.15), rho_Y = c(0, 0.5))
P <- list(N=100, TT=30, T_burn=100, beta=1, rho_D=0.5, gamma_D=0.15, gamma_Y=0.2,
          delta_D=0.1, delta_Y=0.1, rho_Z=0.5, sigma_aZ=0.5)
N_REPS <- 300

cat("=== DIAGNOSTIC: PHI BIAS MECHANISM ===\n")
cat(nrow(grid), "scenarios x", N_REPS, "reps\n\n")

all_res <- vector("list", nrow(grid))
for (g in 1:nrow(grid)) {
  ph <- grid$phi[g]; ry <- grid$rho_Y[g]
  cat(sprintf("[%d/%d] phi=%.2f rho_Y=%.1f ... ", g, nrow(grid), ph, ry))
  t0 <- proc.time()
  res_g <- rbindlist(lapply(1:N_REPS, function(s) {
    dt <- sim_dgp(P$N, P$TT, P$T_burn, P$beta, ry, P$rho_D, P$gamma_D, P$gamma_Y,
                  P$delta_D, P$delta_Y, P$rho_Z, P$sigma_aZ, ph)
    est <- est_phi_diag(dt)
    as.data.table(as.list(est))[, sim := s]
  }))
  res_g[, `:=`(phi=ph, rho_Y=ry)]
  all_res[[g]] <- res_g
  cat(sprintf("%.1fs\n", (proc.time()-t0)[3]))
}

results <- rbindlist(all_res)

# Summary
summ <- results[, .(
  adl_fe_bias  = mean(adl_fe.D) - 1,
  adl_nofe_bias = mean(adl_nofe.D) - 1,
  r2_D_Ylag    = mean(r2_D_Ylag)
), by = .(phi, rho_Y)]

cat("\n=== RESULTS ===\n\n")
cat("1. BIAS by model and phi (does bias decrease with phi?):\n")
tab1 <- dcast(summ, phi ~ rho_Y, value.var="adl_fe_bias")
setnames(tab1, c("phi", "rhoY_0_FE", "rhoY_05_FE"))
tab1[, rhoY_0_FE := round(rhoY_0_FE, 5)]
tab1[, rhoY_05_FE := round(rhoY_05_FE, 5)]
print(tab1)

cat("\n2. ADL without FE (does pattern persist without Nickell source?):\n")
tab2 <- dcast(summ, phi ~ rho_Y, value.var="adl_nofe_bias")
setnames(tab2, c("phi", "rhoY_0_noFE", "rhoY_05_noFE"))
tab2[, rhoY_0_noFE := round(rhoY_0_noFE, 5)]
tab2[, rhoY_05_noFE := round(rhoY_05_noFE, 5)]
print(tab2)

cat("\n3. R²(D ~ Y_lag | FE) — does phi make D more predictable from Y_lag?:\n")
tab3 <- dcast(summ, phi ~ rho_Y, value.var="r2_D_Ylag")
setnames(tab3, c("phi", "rhoY_0_R2", "rhoY_05_R2"))
tab3[, rhoY_0_R2 := round(rhoY_0_R2, 4)]
tab3[, rhoY_05_R2 := round(rhoY_05_R2, 4)]
print(tab3)

cat("\n4. Full table:\n")
print(summ[, .(phi, rho_Y, adl_fe=round(adl_fe_bias,5), adl_nofe=round(adl_nofe_bias,5), R2=round(r2_D_Ylag,4))])

cat("\n=== INTERPRETATION ===\n")
cat("If bias decreases with phi ONLY when rho_Y > 0 AND only with FE,\n")
cat("then the mechanism is: phi increases R²(D~Y_lag|FE), absorbing more\n")
cat("Nickell-contaminated variation, leaving residual D cleaner.\n")

fwrite(summ, "results/diag_phi_bias_mechanism_results.csv")
