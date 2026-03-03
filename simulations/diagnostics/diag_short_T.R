# ============================================================================
# diag_short_T.R
# Diagnostic: How does T=10 affect results? (Nickell bias is O(1/T))
#
# Re-runs key scenarios from Sims 1-3 with T=10 and T=30 for comparison.
# ============================================================================

library(data.table)
library(fixest)
set.seed(2026)

sim_dgp <- function(N, TT, T_burn, beta, rho_Y, rho_D,
                    gamma_D, gamma_Y, delta_D, delta_Y,
                    rho_Z, sigma_aZ, phi, beta2) {
  T_sim <- TT + T_burn
  alpha_D <- rnorm(N); alpha_Y <- rnorm(N); alpha_Z <- rnorm(N, 0, sigma_aZ)
  rows <- vector("list", N)
  for (i in 1:N) {
    D <- Y <- Z <- numeric(T_sim)
    D[1] <- alpha_D[i] + rnorm(1); Y[1] <- alpha_Y[i] + rnorm(1); Z[1] <- alpha_Z[i] + rnorm(1)
    for (t in 2:T_sim) {
      D[t] <- alpha_D[i] + gamma_D*Z[t-1] + rho_D*D[t-1] + phi*Y[t-1] + rnorm(1)
      Y[t] <- alpha_Y[i] + beta*D[t] + beta2*D[t-1] + gamma_Y*Z[t-1] + rho_Y*Y[t-1] + rnorm(1)
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
  m1 <- feols(Y ~ D + Z_lag | id_f + time_f, dt, vcov="iid")
  m2 <- feols(Y ~ D + Z_lag + Y_lag | id_f + time_f, dt, vcov="iid")
  m3 <- feols(Y ~ D + D_lag + Z_lag + Y_lag | id_f + time_f, dt, vcov="iid")
  m4 <- lm(Y ~ D + D_lag + Z_lag + Y_lag, data=dt)
  c(twfe_l=coef(m1)["D"], adl_full=coef(m2)["D"], adl_all=coef(m3)["D"], adl_all_nofe=coef(m4)["D"])
}

# Scenarios: representative cases from Sims 1-3
scenarios <- data.table(
  label = c("Base", "Feedback", "Carryover", "Both", "Strong_carry"),
  phi   = c(0,     0.10, 0,    0.05, 0),
  beta2 = c(0,     0,    0.2,  0.2,  0.5)
)

scenarios[, scenario := .I]
grid <- CJ(TT = c(10, 30), scenario = 1:nrow(scenarios))
grid <- merge(grid, scenarios, by = "scenario")

P <- list(N=100, T_burn=100, beta=1, rho_Y=0.5, rho_D=0.5,
          gamma_D=0.15, gamma_Y=0.2, delta_D=0.1, delta_Y=0.1,
          rho_Z=0.5, sigma_aZ=0.5)
N_REPS <- 200

cat("=== DIAGNOSTIC: SHORT T (T=10 vs T=30) ===\n")
cat(nrow(grid), "scenarios x", N_REPS, "reps\n\n")

all_res <- vector("list", nrow(grid))
for (g in 1:nrow(grid)) {
  tt <- grid$TT[g]; ph <- grid$phi[g]; b2 <- grid$beta2[g]; lb <- grid$label[g]
  cat(sprintf("[%d/%d] T=%d %s (phi=%.2f beta2=%.1f) ... ", g, nrow(grid), tt, lb, ph, b2))
  t0 <- proc.time()
  res_g <- rbindlist(lapply(1:N_REPS, function(s) {
    dt <- sim_dgp(P$N, tt, P$T_burn, P$beta, P$rho_Y, P$rho_D, P$gamma_D, P$gamma_Y,
                  P$delta_D, P$delta_Y, P$rho_Z, P$sigma_aZ, ph, b2)
    est <- est_models(dt)
    as.data.table(as.list(est))[, sim := s]
  }))
  res_g[, `:=`(TT=tt, phi=ph, beta2=b2, label=lb)]
  all_res[[g]] <- res_g
  cat(sprintf("%.1fs\n", (proc.time()-t0)[3]))
}

results <- rbindlist(all_res)
summ <- results[, .(
  twfe_l     = mean(twfe_l.D) - 1,
  adl_full   = mean(adl_full.D) - 1,
  adl_all    = mean(adl_all.D) - 1,
  adl_nofe   = mean(adl_all_nofe.D) - 1,
  adl_all_rmse = sqrt(mean((adl_all.D - 1)^2))
), by = .(TT, label, phi, beta2)]

cat("\n=== RESULTS ===\n\n")
cat("Bias comparison T=10 vs T=30:\n")
wide <- dcast(summ, label + phi + beta2 ~ TT, value.var = c("adl_full", "adl_all", "twfe_l"))
setnames(wide, gsub("_10$", "_T10", gsub("_30$", "_T30", names(wide))))
print(wide[, .(label, phi, beta2,
  ADLfull_T10=round(adl_full_T10,4), ADLfull_T30=round(adl_full_T30,4),
  ADLall_T10=round(adl_all_T10,4), ADLall_T30=round(adl_all_T30,4),
  TWFE_T10=round(twfe_l_T10,4), TWFE_T30=round(twfe_l_T30,4))])

cat("\nNickell cost (|FE| - |noFE|) for ADL_all:\n")
nick <- summ[, .(TT, label, Nickell_cost = round(abs(adl_all) - abs(adl_nofe), 4))]
print(dcast(nick, label ~ TT, value.var="Nickell_cost"))

cat("\nRMSE of ADL_all by T:\n")
print(summ[, .(TT, label, RMSE=round(adl_all_rmse,4))])

fwrite(summ, "results/diag_short_T_results.csv")
