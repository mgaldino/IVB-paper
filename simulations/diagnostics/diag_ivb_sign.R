# ============================================================================
# diag_ivb_sign.R
# Diagnostic: When does IVB become positive (collider dominates)?
#
# IVB = bias_long - bias_short. IVB < 0 means Z helps (confounder dominates).
# IVB > 0 means Z hurts (collider dominates).
#
# Key parameters: gamma_D (Z→D confounder), delta_Y (Y→Z collider)
# When gamma_D → 0 and delta_Y large, Z is pure collider → IVB should be > 0
# ============================================================================

library(data.table)
library(fixest)
set.seed(2026)

sim_dgp <- function(N, TT, T_burn, beta, rho_Y, rho_D,
                    gamma_D, gamma_Y, delta_D, delta_Y,
                    rho_Z, sigma_aZ) {
  T_sim <- TT + T_burn
  alpha_D <- rnorm(N); alpha_Y <- rnorm(N); alpha_Z <- rnorm(N, 0, sigma_aZ)
  rows <- vector("list", N)
  for (i in 1:N) {
    D <- Y <- Z <- numeric(T_sim)
    D[1] <- alpha_D[i] + rnorm(1); Y[1] <- alpha_Y[i] + rnorm(1); Z[1] <- alpha_Z[i] + rnorm(1)
    for (t in 2:T_sim) {
      D[t] <- alpha_D[i] + gamma_D*Z[t-1] + rho_D*D[t-1] + rnorm(1)
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

est_ivb <- function(dt) {
  m1 <- feols(Y ~ D | id_f + time_f, dt, vcov="iid")
  m2 <- feols(Y ~ D + Z_lag | id_f + time_f, dt, vcov="iid")
  m3 <- feols(Y ~ D + Y_lag | id_f + time_f, dt, vcov="iid")
  m4 <- feols(Y ~ D + Z_lag + Y_lag | id_f + time_f, dt, vcov="iid")
  c(twfe_s=coef(m1)["D"], twfe_l=coef(m2)["D"], adl_s=coef(m3)["D"], adl_l=coef(m4)["D"])
}

# Grid: vary confounder vs collider strength
grid <- CJ(gamma_D = c(0, 0.05, 0.15, 0.30),
           delta_Y = c(0.05, 0.10, 0.20, 0.30))

P <- list(N=100, TT=30, T_burn=100, beta=1, rho_Y=0.5, rho_D=0.5,
          gamma_Y=0.2, delta_D=0.1, rho_Z=0.5, sigma_aZ=0.5)
N_REPS <- 200

cat("=== DIAGNOSTIC: IVB SIGN (CONFOUNDER vs COLLIDER) ===\n")
cat(nrow(grid), "scenarios x", N_REPS, "reps\n\n")

all_res <- vector("list", nrow(grid))
for (g in 1:nrow(grid)) {
  gd <- grid$gamma_D[g]; dy <- grid$delta_Y[g]
  cat(sprintf("[%d/%d] gamma_D=%.2f delta_Y=%.2f ... ", g, nrow(grid), gd, dy))
  t0 <- proc.time()
  res_g <- rbindlist(lapply(1:N_REPS, function(s) {
    dt <- sim_dgp(P$N, P$TT, P$T_burn, P$beta, P$rho_Y, P$rho_D,
                  gd, P$gamma_Y, P$delta_D, dy, P$rho_Z, P$sigma_aZ)
    est <- est_ivb(dt)
    as.data.table(as.list(est))[, sim := s]
  }))
  res_g[, `:=`(gamma_D=gd, delta_Y=dy)]
  all_res[[g]] <- res_g
  cat(sprintf("%.1fs\n", (proc.time()-t0)[3]))
}

results <- rbindlist(all_res)
summ <- results[, .(
  twfe_s = mean(twfe_s.D) - 1, twfe_l = mean(twfe_l.D) - 1,
  adl_s  = mean(adl_s.D) - 1,  adl_l  = mean(adl_l.D) - 1
), by = .(gamma_D, delta_Y)]

summ[, `:=`(IVB_TWFE = twfe_l - twfe_s, IVB_ADL = adl_l - adl_s,
            net_TWFE = abs(twfe_s) - abs(twfe_l), net_ADL = abs(adl_s) - abs(adl_l))]

cat("\n=== RESULTS ===\n\n")
cat("IVB = bias_long - bias_short (>0 = collider dominates, Z hurts):\n\n")
ivb_tab <- summ[, .(gamma_D, delta_Y,
  IVB_TWFE = round(IVB_TWFE, 4), IVB_ADL = round(IVB_ADL, 4),
  net_TWFE = round(net_TWFE, 4), net_ADL = round(net_ADL, 4))]
print(ivb_tab)

cat("\nBias by model:\n")
bias_tab <- summ[, .(gamma_D, delta_Y,
  twfe_s = round(twfe_s, 4), twfe_l = round(twfe_l, 4),
  adl_s = round(adl_s, 4), adl_l = round(adl_l, 4))]
print(bias_tab)

cat("\nScenarios where IVB > 0 (including Z INCREASES bias):\n")
pos <- summ[IVB_TWFE > 0 | IVB_ADL > 0]
if (nrow(pos) > 0) {
  print(pos[, .(gamma_D, delta_Y, IVB_TWFE=round(IVB_TWFE,4), IVB_ADL=round(IVB_ADL,4))])
} else {
  cat("None found.\n")
}

cat("\nCrossover analysis (where does IVB change sign?):\n")
for (dy in unique(summ$delta_Y)) {
  s <- summ[delta_Y == dy, .(gamma_D, IVB_TWFE=round(IVB_TWFE,4), IVB_ADL=round(IVB_ADL,4))]
  cat(sprintf("\n  delta_Y = %.2f:\n", dy))
  print(s)
}

fwrite(summ, "results/diag_ivb_sign_results.csv")
