# ============================================================================
# sim_nl_carryover.R
# NL-2: Non-linear carryover D -> Y (misspecification in carryover)
#
# DGP:
#   D_t = alpha^D_i + gamma_D Z_{t-1} + rho_D D_{t-1} + u_t
#   Y_t = alpha^Y_i + beta D_t + beta_nl D_{t-1}^2 + gamma_Y Z_{t-1}
#         + rho_Y Y_{t-1} + e_t
#   Z_t = alpha^Z_i + delta_D D_t + delta_Y Y_t + rho_Z Z_{t-1} + nu_t
#
# Researcher includes D_lag linearly in ADL, but DGP has D_lag^2.
# Question: Does misspecification of the carryover interact with IVB?
#
# DESIGN DECISION: The DGP has beta_nl * D_{t-1}^2 but NO linear D_lag
# term (beyond what rho_D * D_{t-1} provides through D dynamics). This is
# intentional: the non-linear carryover is a *pure* misspecification —
# the researcher's linear D_lag cannot capture D^2. Including a linear
# D_lag in the DGP would confound the misspecification effect with the
# standard carryover channel. The comparison ADL_Dlag vs ADL_all reveals
# whether including Z_lag helps or hurts when carryover is misspecified.
#
# Grid: beta_nl x rho_Z ~ 8 scenarios x 500 reps
# ============================================================================

library(data.table)
library(fixest)

source("sim_nl_utils.R")  # est_models(), run_pilot()

set.seed(2026)

# ---- Fixed parameters ----
P <- list(N = 100, TT = 30, T_burn = 100, beta = 1,
          rho_Y = 0.5, rho_D = 0.5,
          gamma_D = 0.15, gamma_Y = 0.2,
          delta_D = 0.1, delta_Y = 0.1,
          sigma_aZ = 0.5)
N_REPS <- 500

# ============================================================================
# PILOT RUN: calibrate sd(D_within) from linear baseline
# ============================================================================
cat("PILOT RUN: calibrating sd(D_within)...\n")
pilot <- run_pilot(P, n_pilot = 10, return_Y = FALSE)
sd_D_within <- pilot$sd_D
cat(sprintf("  sd(D_within) = %.4f (avg over rho_Z = 0.5, 0.7)\n\n", sd_D_within))

# ---- DGP with non-linear carryover ----
sim_nl_carryover <- function(N, TT, T_burn, beta, beta_nl, rho_Y, rho_D,
                             gamma_D, gamma_Y, delta_D, delta_Y,
                             rho_Z, sigma_aZ) {
  T_sim <- TT + T_burn

  alpha_D <- rnorm(N, 0, 1)
  alpha_Y <- rnorm(N, 0, 1)
  alpha_Z <- rnorm(N, 0, sigma_aZ)

  rows <- vector("list", N)
  explosive <- FALSE

  for (i in 1:N) {
    D <- Y <- Z <- numeric(T_sim)
    D[1] <- alpha_D[i] + rnorm(1)
    Y[1] <- alpha_Y[i] + rnorm(1)
    Z[1] <- alpha_Z[i] + rnorm(1)

    for (t in 2:T_sim) {
      u <- rnorm(1); e <- rnorm(1); nu <- rnorm(1)
      D[t] <- alpha_D[i] + gamma_D * Z[t-1] + rho_D * D[t-1] + u
      Y[t] <- alpha_Y[i] + beta * D[t] + beta_nl * D[t-1]^2 +
              gamma_Y * Z[t-1] + rho_Y * Y[t-1] + e
      Z[t] <- alpha_Z[i] + delta_D * D[t] + delta_Y * Y[t] +
              rho_Z * Z[t-1] + nu

      if (abs(D[t]) > 1e6 || abs(Y[t]) > 1e6 || abs(Z[t]) > 1e6) {
        explosive <- TRUE
        break
      }
    }
    if (explosive) return(NULL)

    idx <- (T_burn + 1):T_sim
    rows[[i]] <- data.table(
      id = i, time = seq_along(idx),
      D = D[idx], Y = Y[idx], Z = Z[idx],
      D_lag = c(NA, D[idx[-length(idx)]]),
      Y_lag = c(NA, Y[idx[-length(idx)]]),
      Z_lag = c(NA, Z[idx[-length(idx)]])
    )
  }

  dt <- rbindlist(rows)
  dt <- dt[complete.cases(dt)]
  dt[, `:=`(id_f = factor(id), time_f = factor(time))]
  dt
}

# ---- Grid ----
# Calibrate beta_nl using sd_D_within
# k = {0, 0.25, 0.5, 1.0} -> beta_nl = k * beta / sd_D_within
k_vals <- c(0, 0.25, 0.5, 1.0)
beta_nl_vals <- round(k_vals * P$beta / sd_D_within, 4)

grid <- CJ(
  beta_nl = beta_nl_vals,
  rho_Z   = c(0.5, 0.7)
)

# Store k for display
grid[, k := round(beta_nl * sd_D_within / P$beta, 2)]

cat(sprintf("Grid: %d scenarios\n", nrow(grid)))
cat(sprintf("Calibration: k * beta / sd_D_within (sd_D_within = %.4f)\n", sd_D_within))
print(grid)

# ---- Run ----
cat("\n")
cat(rep("=", 71), "\n", sep = "")
cat("SIM NL-CARRYOVER: Non-linear D_{t-1}^2 -> Y_t\n")
cat(rep("=", 71), "\n\n")
cat(nrow(grid), "scenarios x", N_REPS, "reps\n")
cat("DGP: beta=1, rho_Y=0.5, rho_D=0.5, gamma_D=0.15, gamma_Y=0.2\n")
cat("     delta_D=0.1, delta_Y=0.1, N=100, T=30, T_burn=100\n")
cat("     Researcher estimates D_lag LINEAR, DGP has D_lag^2\n\n")

all_res <- vector("list", nrow(grid))
elapsed_times <- numeric(nrow(grid))
discarded_counts <- integer(nrow(grid))
scale_stats <- vector("list", nrow(grid))
t0_total <- proc.time()

for (g in 1:nrow(grid)) {
  bnl <- grid$beta_nl[g]
  rz  <- grid$rho_Z[g]
  k_g <- grid$k[g]

  cat(sprintf("[%d/%d] beta_nl=%.4f (k=%.2f) rho_Z=%.2f ... ",
              g, nrow(grid), bnl, k_g, rz))
  t0 <- proc.time()

  n_discarded <- 0L
  n_valid <- 0L
  reps_list <- vector("list", N_REPS)
  D_means <- Y_means <- Z_means <- numeric(N_REPS)
  D_sds   <- Y_sds   <- Z_sds   <- numeric(N_REPS)

  for (s in 1:N_REPS) {
    dt <- sim_nl_carryover(P$N, P$TT, P$T_burn, P$beta, bnl, P$rho_Y, P$rho_D,
                           P$gamma_D, P$gamma_Y, P$delta_D, P$delta_Y,
                           rz, P$sigma_aZ)
    if (is.null(dt)) {
      n_discarded <- n_discarded + 1L
      next
    }
    est <- est_models(dt)
    if (is.null(est)) {
      n_discarded <- n_discarded + 1L
      next
    }
    reps_list[[s]] <- as.data.table(as.list(est))[, sim := s]
    n_valid <- n_valid + 1L
    D_means[n_valid] <- mean(dt$D)
    Y_means[n_valid] <- mean(dt$Y)
    Z_means[n_valid] <- mean(dt$Z)
    D_sds[n_valid]   <- sd(dt$D)
    Y_sds[n_valid]   <- sd(dt$Y)
    Z_sds[n_valid]   <- sd(dt$Z)
  }

  reps_list <- reps_list[!sapply(reps_list, is.null)]
  if (length(reps_list) == 0) {
    cat("ALL DISCARDED!\n")
    discarded_counts[g] <- N_REPS
    next
  }

  res_g <- rbindlist(reps_list)
  res_g[, `:=`(beta_nl = bnl, rho_Z = rz)]
  all_res[[g]] <- res_g
  discarded_counts[g] <- n_discarded

  scale_stats[[g]] <- data.table(
    beta_nl = bnl, rho_Z = rz,
    D_mean = mean(D_means[1:n_valid]), Y_mean = mean(Y_means[1:n_valid]),
    Z_mean = mean(Z_means[1:n_valid]),
    D_sd = mean(D_sds[1:n_valid]), Y_sd = mean(Y_sds[1:n_valid]),
    Z_sd = mean(Z_sds[1:n_valid])
  )

  elapsed <- (proc.time() - t0)[3]
  elapsed_times[g] <- elapsed
  disc_pct <- round(100 * n_discarded / N_REPS, 1)
  cat(sprintf("%.1fs (discarded: %d/%d = %.1f%%)\n", elapsed, n_discarded, N_REPS, disc_pct))
}

total_elapsed <- (proc.time() - t0_total)[3]
cat(sprintf("\nTotal time: %.1fs\n", total_elapsed))

results <- rbindlist(all_res[!sapply(all_res, is.null)])

# ---- Summary ----
beta_true <- P$beta

mod_cols <- c("twfe_s.D", "twfe_l.D", "adl_Ylag.D", "adl_full.D",
              "adl_Dlag.D", "adl_DYlag.D", "adl_DZlag.D", "adl_all.D",
              "adl_all_nofe.D")
mod_names <- c("twfe_s", "twfe_l", "adl_Ylag", "adl_full",
               "adl_Dlag", "adl_DYlag", "adl_DZlag", "adl_all",
               "adl_all_nofe")

summ <- results[, {
  out <- list()
  for (j in seq_along(mod_cols)) {
    vals <- get(mod_cols[j])
    out[[paste0(mod_names[j], "_bias")]] <- mean(vals) - beta_true
    out[[paste0(mod_names[j], "_mcse")]] <- sd(vals) / sqrt(.N)
    out[[paste0(mod_names[j], "_sd")]]   <- sd(vals)
    out[[paste0(mod_names[j], "_rmse")]] <- sqrt(mean((vals - beta_true)^2))
  }
  out$n_sims <- .N
  out
}, by = .(beta_nl, rho_Z)]

# Add discarded count and k
disc_dt <- data.table(grid[, .(beta_nl, rho_Z, k)], n_discarded = discarded_counts)
summ <- merge(summ, disc_dt, by = c("beta_nl", "rho_Z"), all.x = TRUE)

# ---- Print results ----
cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("RESULTS: BIAS BY MODEL (beta_true = 1)\n")
cat(rep("=", 80), "\n\n")

for (rz in c(0.5, 0.7)) {
  cat(sprintf("--- rho_Z = %.2f ---\n\n", rz))
  s <- summ[rho_Z == rz]

  cat("BIAS (estimate - beta_true):\n")
  bias_tab <- s[, .(beta_nl, k, n_sims, n_discarded,
    `TWFE_s`    = round(twfe_s_bias, 4),
    `TWFE_l`    = round(twfe_l_bias, 4),
    `ADL_Ylag`  = round(adl_Ylag_bias, 4),
    `ADL_full`  = round(adl_full_bias, 4),
    `ADL_Dlag`  = round(adl_Dlag_bias, 4),
    `ADL_all`   = round(adl_all_bias, 4))]
  print(bias_tab)

  cat("\nRMSE:\n")
  rmse_tab <- s[, .(beta_nl, k,
    `TWFE_s`    = round(twfe_s_rmse, 4),
    `TWFE_l`    = round(twfe_l_rmse, 4),
    `ADL_full`  = round(adl_full_rmse, 4),
    `ADL_all`   = round(adl_all_rmse, 4),
    `ADL_noFE`  = round(adl_all_nofe_rmse, 4))]
  print(rmse_tab)

  cat("\nMC STANDARD ERRORS:\n")
  mcse_tab <- s[, .(beta_nl, k,
    `TWFE_s`    = round(twfe_s_mcse, 4),
    `TWFE_l`    = round(twfe_l_mcse, 4),
    `ADL_full`  = round(adl_full_mcse, 4),
    `ADL_all`   = round(adl_all_mcse, 4))]
  print(mcse_tab)
  cat("\n")
}

# ---- Decompositions ----
cat(rep("=", 80), "\n", sep = "")
cat("DECOMPOSITIONS\n")
cat(rep("=", 80), "\n\n")

cat("A. IVB of Z_lag (bias with Z - bias without Z):\n")
ivb_z <- summ[, .(beta_nl, k, rho_Z,
  `IVB_TWFE`       = round(twfe_l_bias - twfe_s_bias, 4),
  `|IVB/b|_TWFE`   = round(abs(twfe_l_bias - twfe_s_bias) / abs(beta_true), 4),
  `IVB_ADL`        = round(adl_full_bias - adl_Ylag_bias, 4),
  `|IVB/b|_ADL`    = round(abs(adl_full_bias - adl_Ylag_bias) / abs(beta_true), 4),
  `IVB_ADL+Dlag`   = round(adl_all_bias - adl_DYlag_bias, 4),
  `|IVB/b|_ADL+D`  = round(abs(adl_all_bias - adl_DYlag_bias) / abs(beta_true), 4))]
print(ivb_z)

cat("\nB. Effect of adding D_lag:\n")
dlag_tab <- summ[, .(beta_nl, k, rho_Z,
  `TWFE+Dlag`     = round(adl_Dlag_bias - twfe_s_bias, 4),
  `ADLfull+Dlag`  = round(adl_all_bias - adl_full_bias, 4),
  `ADLYlag+Dlag`  = round(adl_DYlag_bias - adl_Ylag_bias, 4))]
print(dlag_tab)

cat("\nC. Nickell cost (ADL_all FE vs noFE):\n")
nick_tab <- summ[, .(beta_nl, k, rho_Z,
  `ADL_all_FE`   = round(adl_all_bias, 4),
  `ADL_all_noFE` = round(adl_all_nofe_bias, 4),
  `Nickell_cost`  = round(abs(adl_all_bias) - abs(adl_all_nofe_bias), 4))]
print(nick_tab)

cat("\nD. Best model (smallest |bias|) per scenario:\n")
best_tab <- summ[, {
  biases <- c(twfe_s = abs(twfe_s_bias), twfe_l = abs(twfe_l_bias),
              adl_Ylag = abs(adl_Ylag_bias), adl_full = abs(adl_full_bias),
              adl_Dlag = abs(adl_Dlag_bias), adl_DYlag = abs(adl_DYlag_bias),
              adl_DZlag = abs(adl_DZlag_bias), adl_all = abs(adl_all_bias),
              adl_all_nofe = abs(adl_all_nofe_bias))
  best_idx <- which.min(biases)
  .(best_model = names(biases)[best_idx],
    best_bias = round(biases[best_idx], 4),
    second_best = names(sort(biases))[2],
    second_bias = round(sort(biases)[2], 4))
}, by = .(beta_nl, k, rho_Z)]
print(best_tab)

# ---- F. Effect of non-linearity (comparison with baseline) ----
cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("F. EFFECT OF NON-LINEARITY (comparison with baseline beta_nl=0)\n")
cat(rep("=", 80), "\n\n")

baseline <- summ[beta_nl == 0, .(rho_Z,
  bl_twfe_s  = twfe_s_bias,
  bl_twfe_l  = twfe_l_bias,
  bl_adl_full = adl_full_bias,
  bl_adl_all = adl_all_bias,
  bl_ivb_twfe = twfe_l_bias - twfe_s_bias,
  bl_ivb_adl  = adl_full_bias - adl_Ylag_bias)]

nl_rows <- summ[beta_nl > 0]
nl_comp <- merge(nl_rows, baseline, by = "rho_Z")

cat("Delta_bias = bias(nl) - bias(linear):\n")
delta_tab <- nl_comp[, .(beta_nl, k, rho_Z,
  `D_TWFE_s`   = round(twfe_s_bias - bl_twfe_s, 4),
  `D_TWFE_l`   = round(twfe_l_bias - bl_twfe_l, 4),
  `D_ADL_full` = round(adl_full_bias - bl_adl_full, 4),
  `D_ADL_all`  = round(adl_all_bias - bl_adl_all, 4))]
print(delta_tab)

cat("\nDelta_IVB and IVB_ratio:\n")
ivb_comp <- nl_comp[, {
  ivb_nl_twfe <- twfe_l_bias - twfe_s_bias
  ivb_nl_adl  <- adl_full_bias - adl_Ylag_bias
  .(IVB_nl_TWFE   = round(ivb_nl_twfe, 4),
    IVB_bl_TWFE   = round(bl_ivb_twfe, 4),
    Delta_IVB_TWFE = round(ivb_nl_twfe - bl_ivb_twfe, 4),
    Ratio_TWFE     = round(ivb_nl_twfe / bl_ivb_twfe, 2),
    IVB_nl_ADL    = round(ivb_nl_adl, 4),
    IVB_bl_ADL    = round(bl_ivb_adl, 4),
    Delta_IVB_ADL  = round(ivb_nl_adl - bl_ivb_adl, 4),
    Ratio_ADL      = round(ivb_nl_adl / bl_ivb_adl, 2))
}, by = .(beta_nl, k, rho_Z)]
print(ivb_comp)

# ---- Sanity checks ----
cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("SANITY CHECKS\n")
cat(rep("=", 80), "\n\n")

cat("1. Baseline (beta_nl=0) bias should match linear simulations:\n")
print(summ[beta_nl == 0, .(rho_Z, twfe_s = round(twfe_s_bias, 4),
  twfe_l = round(twfe_l_bias, 4), adl_full = round(adl_full_bias, 4),
  adl_all = round(adl_all_bias, 4))])

cat("\n2. Scale of D, Y, Z by scenario:\n")
sc <- rbindlist(scale_stats[!sapply(scale_stats, is.null)])
print(sc[, lapply(.SD, function(x) round(x, 2)),
         .SDcols = c("D_mean", "Y_mean", "Z_mean", "D_sd", "Y_sd", "Z_sd"),
         by = .(beta_nl, rho_Z)])

cat("\n3. Discarded reps (explosive series):\n")
print(disc_dt)
if (any(discarded_counts > N_REPS * 0.1)) {
  cat("  WARNING: >10% discarded in some scenarios!\n")
}
if (any(discarded_counts > N_REPS * 0.5)) {
  cat("  CRITICAL: >50% discarded — scenario marked as UNSTABLE\n")
}

# ---- Save ----
fwrite(summ, "sim_nl_carryover_results.csv")
fwrite(results, "sim_nl_carryover_raw.csv")

timing <- data.table(grid[, .(beta_nl, k, rho_Z)],
                     elapsed_s = elapsed_times, n_discarded = discarded_counts,
                     total_s = total_elapsed)
fwrite(timing, "sim_nl_carryover_timing.csv")

cat(sprintf("\nResults saved to sim_nl_carryover_results.csv (%d rows)\n", nrow(summ)))
cat(sprintf("Raw saved to sim_nl_carryover_raw.csv (%d rows)\n", nrow(results)))
cat(sprintf("Timing saved (total %.1fs)\n", total_elapsed))

writeLines(capture.output(sessionInfo()),
           "sim_nl_carryover_sessioninfo.txt")
