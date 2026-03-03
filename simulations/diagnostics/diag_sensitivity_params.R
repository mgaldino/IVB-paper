# ============================================================================
# diag_sensitivity_params.R
# Diagnostic: Sensitivity of ADL_all dominance to base parameters
#
# Fixed: phi=0.05, beta2=0.2, rho_Z=0.5 (representative extended DGP)
# Varied: rho_Y, gamma_D, gamma_Y
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

# Stationarity check
check_stable <- function(beta, rho_Y, rho_D, gamma_D, gamma_Y, delta_D, delta_Y, rho_Z, phi, beta2) {
  A <- matrix(c(
    rho_D,                phi,               gamma_D,
    beta2 + beta*rho_D,   rho_Y + beta*phi,  gamma_Y + beta*gamma_D,
    delta_D*rho_D + delta_Y*(beta2+beta*rho_D),
    delta_D*phi + delta_Y*(rho_Y+beta*phi),
    rho_Z + delta_D*gamma_D + delta_Y*(gamma_Y+beta*gamma_D)
  ), nrow=3, byrow=TRUE)
  max(Mod(eigen(A)$values)) < 0.98
}

est_models <- function(dt) {
  m1 <- feols(Y ~ D + Z_lag + Y_lag | id_f + time_f, dt, vcov="iid")
  m2 <- feols(Y ~ D + D_lag + Z_lag + Y_lag | id_f + time_f, dt, vcov="iid")
  c(adl_full=coef(m1)["D"], adl_all=coef(m2)["D"])
}

# Grid
grid <- CJ(rho_Y = c(0.3, 0.5, 0.7),
           gamma_D = c(0.05, 0.15, 0.30),
           gamma_Y = c(0.1, 0.2, 0.4))

P <- list(N=100, TT=30, T_burn=100, beta=1, rho_D=0.5,
          delta_D=0.1, delta_Y=0.1, rho_Z=0.5, sigma_aZ=0.5,
          phi=0.05, beta2=0.2)
N_REPS <- 200

# Check stationarity
grid[, stable := mapply(function(ry, gd, gy)
  check_stable(P$beta, ry, P$rho_D, gd, gy, P$delta_D, P$delta_Y, P$rho_Z, P$phi, P$beta2),
  rho_Y, gamma_D, gamma_Y)]

cat("=== DIAGNOSTIC: SENSITIVITY TO BASE PARAMETERS ===\n")
cat("Fixed: phi=0.05, beta2=0.2, rho_Z=0.5\n")
cat(sprintf("Grid: %d scenarios (%d stable, %d unstable)\n\n",
            nrow(grid), sum(grid$stable), sum(!grid$stable)))

if (any(!grid$stable)) {
  cat("Unstable scenarios (skipped):\n")
  print(grid[stable == FALSE, .(rho_Y, gamma_D, gamma_Y)])
  cat("\n")
}

grid_ok <- grid[stable == TRUE]

all_res <- vector("list", nrow(grid_ok))
for (g in 1:nrow(grid_ok)) {
  ry <- grid_ok$rho_Y[g]; gd <- grid_ok$gamma_D[g]; gy <- grid_ok$gamma_Y[g]
  cat(sprintf("[%d/%d] rho_Y=%.1f gamma_D=%.2f gamma_Y=%.1f ... ", g, nrow(grid_ok), ry, gd, gy))
  t0 <- proc.time()
  res_g <- rbindlist(lapply(1:N_REPS, function(s) {
    dt <- sim_dgp(P$N, P$TT, P$T_burn, P$beta, ry, P$rho_D, gd, gy,
                  P$delta_D, P$delta_Y, P$rho_Z, P$sigma_aZ, P$phi, P$beta2)
    est <- est_models(dt)
    as.data.table(as.list(est))[, sim := s]
  }))
  res_g[, `:=`(rho_Y=ry, gamma_D=gd, gamma_Y=gy)]
  all_res[[g]] <- res_g
  cat(sprintf("%.1fs\n", (proc.time()-t0)[3]))
}

results <- rbindlist(all_res)
summ <- results[, .(
  adl_full_bias = mean(adl_full.D) - 1,
  adl_all_bias  = mean(adl_all.D) - 1,
  adl_full_rmse = sqrt(mean((adl_full.D - 1)^2)),
  adl_all_rmse  = sqrt(mean((adl_all.D - 1)^2))
), by = .(rho_Y, gamma_D, gamma_Y)]

cat("\n=== RESULTS ===\n\n")
cat("Bias of ADL_full and ADL_all across parameter combinations:\n")
print(summ[, .(rho_Y, gamma_D, gamma_Y,
  ADL_full=round(adl_full_bias,4), ADL_all=round(adl_all_bias,4),
  RMSE_full=round(adl_full_rmse,4), RMSE_all=round(adl_all_rmse,4))])

cat("\nDoes ADL_all always dominate? (|ADL_all| < |ADL_full|):\n")
summ[, dominates := abs(adl_all_bias) < abs(adl_full_bias)]
cat(sprintf("  ADL_all dominates in %d/%d scenarios\n", sum(summ$dominates), nrow(summ)))

cat("\nWorst case for ADL_all:\n")
print(summ[which.max(abs(adl_all_bias)), .(rho_Y, gamma_D, gamma_Y,
  ADL_all_bias=round(adl_all_bias,4), ADL_all_rmse=round(adl_all_rmse,4))])

cat("\nSensitivity to rho_Y (Nickell bias grows with rho_Y):\n")
rho_tab <- summ[gamma_D == 0.15 & gamma_Y == 0.2,
  .(rho_Y, ADL_full=round(adl_full_bias,4), ADL_all=round(adl_all_bias,4))]
print(rho_tab)

fwrite(summ, "results/diag_sensitivity_params_results.csv")
