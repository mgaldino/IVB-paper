# ============================================================================
# diag_time_fe_in_dgp.R
# CRITICAL CHECK: Does adding time FE to the DGP change results?
#
# Current DGP has unit FE (alpha_i) but NO time FE (delta_t).
# Imai & Kim's framework requires both. This test verifies whether
# adding delta_t to all 3 equations changes the bias of estimators.
#
# If results are the same: add delta_t for fidelity, results hold.
# If results differ: all previous simulations need re-running.
# ============================================================================

library(data.table)
library(fixest)
set.seed(2026)

# DGP WITHOUT time FE (current)
sim_no_time_fe <- function(N, TT, T_burn, beta, rho_Y, rho_D,
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

# DGP WITH time FE (corrected — faithful to Imai & Kim)
sim_with_time_fe <- function(N, TT, T_burn, beta, rho_Y, rho_D,
                             gamma_D, gamma_Y, delta_D, delta_Y,
                             rho_Z, sigma_aZ, phi, beta2, sigma_delta) {
  T_sim <- TT + T_burn
  alpha_D <- rnorm(N); alpha_Y <- rnorm(N); alpha_Z <- rnorm(N, 0, sigma_aZ)

  # Time fixed effects — common across units within each period
  delta_t_D <- rnorm(T_sim, 0, sigma_delta)
  delta_t_Y <- rnorm(T_sim, 0, sigma_delta)
  delta_t_Z <- rnorm(T_sim, 0, sigma_delta)

  rows <- vector("list", N)
  for (i in 1:N) {
    D <- Y <- Z <- numeric(T_sim)
    D[1] <- alpha_D[i] + delta_t_D[1] + rnorm(1)
    Y[1] <- alpha_Y[i] + delta_t_Y[1] + rnorm(1)
    Z[1] <- alpha_Z[i] + delta_t_Z[1] + rnorm(1)
    for (t in 2:T_sim) {
      D[t] <- alpha_D[i] + delta_t_D[t] + gamma_D*Z[t-1] + rho_D*D[t-1] + phi*Y[t-1] + rnorm(1)
      Y[t] <- alpha_Y[i] + delta_t_Y[t] + beta*D[t] + beta2*D[t-1] + gamma_Y*Z[t-1] + rho_Y*Y[t-1] + rnorm(1)
      Z[t] <- alpha_Z[i] + delta_t_Z[t] + delta_D*D[t] + delta_Y*Y[t] + rho_Z*Z[t-1] + rnorm(1)
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
  m1 <- feols(Y ~ D | id_f + time_f, dt, vcov="iid")
  m2 <- feols(Y ~ D + Z_lag | id_f + time_f, dt, vcov="iid")
  m3 <- feols(Y ~ D + Z_lag + Y_lag | id_f + time_f, dt, vcov="iid")
  m4 <- feols(Y ~ D + D_lag + Z_lag + Y_lag | id_f + time_f, dt, vcov="iid")
  m5 <- lm(Y ~ D + D_lag + Z_lag + Y_lag, data=dt)
  c(twfe_s=coef(m1)["D"], twfe_l=coef(m2)["D"], adl_full=coef(m3)["D"],
    adl_all=coef(m4)["D"], adl_nofe=coef(m5)["D"])
}

# Test scenarios
scenarios <- data.table(
  label = c("Base", "Feedback", "Carryover", "Both"),
  phi   = c(0,     0.10, 0,    0.05),
  beta2 = c(0,     0,    0.2,  0.2)
)

P <- list(N=100, TT=30, T_burn=100, beta=1, rho_Y=0.5, rho_D=0.5,
          gamma_D=0.15, gamma_Y=0.2, delta_D=0.1, delta_Y=0.1,
          rho_Z=0.5, sigma_aZ=0.5)
sigma_deltas <- c(0, 0.3, 0.5, 1.0)
N_REPS <- 200

cat("=== CRITICAL CHECK: TIME FE IN DGP ===\n")
cat("Comparing DGP without vs with time FE (delta_t)\n")
cat("sigma_delta = 0 is equivalent to no time FE\n\n")

all_res <- list()
cnt <- 0
total <- nrow(scenarios) * length(sigma_deltas)

for (s in 1:nrow(scenarios)) {
  for (sd in sigma_deltas) {
    cnt <- cnt + 1
    lb <- scenarios$label[s]; ph <- scenarios$phi[s]; b2 <- scenarios$beta2[s]
    cat(sprintf("[%d/%d] %s sigma_delta=%.1f ... ", cnt, total, lb, sd))
    t0 <- proc.time()

    res <- rbindlist(lapply(1:N_REPS, function(r) {
      if (sd == 0) {
        dt <- sim_no_time_fe(P$N, P$TT, P$T_burn, P$beta, P$rho_Y, P$rho_D,
                             P$gamma_D, P$gamma_Y, P$delta_D, P$delta_Y,
                             P$rho_Z, P$sigma_aZ, ph, b2)
      } else {
        dt <- sim_with_time_fe(P$N, P$TT, P$T_burn, P$beta, P$rho_Y, P$rho_D,
                               P$gamma_D, P$gamma_Y, P$delta_D, P$delta_Y,
                               P$rho_Z, P$sigma_aZ, ph, b2, sd)
      }
      est <- est_models(dt)
      as.data.table(as.list(est))[, sim := r]
    }))
    res[, `:=`(label=lb, phi=ph, beta2=b2, sigma_delta=sd)]
    all_res[[cnt]] <- res
    cat(sprintf("%.1fs\n", (proc.time()-t0)[3]))
  }
}

results <- rbindlist(all_res)
summ <- results[, .(
  twfe_s   = mean(twfe_s.D) - 1,
  twfe_l   = mean(twfe_l.D) - 1,
  adl_full = mean(adl_full.D) - 1,
  adl_all  = mean(adl_all.D) - 1,
  adl_nofe = mean(adl_nofe.D) - 1
), by = .(label, phi, beta2, sigma_delta)]

cat("\n=== RESULTS ===\n\n")

for (lb in scenarios$label) {
  cat(sprintf("--- %s ---\n", lb))
  s <- summ[label == lb]
  print(s[, .(sigma_delta,
    TWFE_s=round(twfe_s,4), TWFE_l=round(twfe_l,4),
    ADL_full=round(adl_full,4), ADL_all=round(adl_all,4),
    ADL_noFE=round(adl_nofe,4))])
  cat("\n")
}

cat("=== COMPARISON: max absolute difference (sigma_delta=0 vs others) ===\n\n")
baseline <- summ[sigma_delta == 0]
for (sd in sigma_deltas[sigma_deltas > 0]) {
  comp <- summ[sigma_delta == sd]
  diffs <- merge(baseline, comp, by=c("label","phi","beta2"), suffixes=c(".0",".sd"))
  max_diff <- max(abs(diffs$adl_all.sd - diffs$adl_all.0))
  max_diff_full <- max(abs(diffs$adl_full.sd - diffs$adl_full.0))
  max_diff_twfe <- max(abs(diffs$twfe_l.sd - diffs$twfe_l.0))
  cat(sprintf("sigma_delta=%.1f: max |diff| ADL_all=%.4f, ADL_full=%.4f, TWFE_l=%.4f\n",
              sd, max_diff, max_diff_full, max_diff_twfe))
}

cat("\n=== VERDICT ===\n")
cat("If max differences are < 0.01, time FE in DGP don't affect results.\n")
cat("Add them for fidelity, but previous results remain valid.\n")

fwrite(summ, "results/diag_time_fe_results.csv")
