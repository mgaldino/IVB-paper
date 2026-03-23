# ============================================================================
# sim_persistent_confounder.R
# Persistent unobserved confounder U (Bellemare, Masaki & Pepinsky 2017)
#
# DGP:
#   U_t = phi_U * U_{t-1} + v_t                                        <- NEW
#   D_t = alpha^D_i + gamma_D Z_{t-1} + rho_D D_{t-1} + kappa U_t + u_t    <- NEW: kappa U_t
#   Y_t = alpha^Y_i + beta D_t + gamma_Y Z_{t-1} + rho_Y Y_{t-1}
#         + delta_U U_t + e_t                                          <- NEW: delta_U U_t
#   Z_t = alpha^Z_i + delta_D D_t + delta_Y Y_t + rho_Z Z_{t-1} + nu_t
#
# Motivation: Bellemare et al. (2017, JoP) show that lagging explanatory
# variables does not resolve endogeneity when unobservables have temporal
# dynamics (phi != 0). We test whether ADL_all (which resolves collider bias
# from Z_{t-1}) also handles persistent unobserved confounders.
#
# Expected result: ADL_all does NOT resolve OVB from persistent U.
# The contemporaneous correlation kappa*U_t in D and delta_U*U_t in Y
# creates OVB that no conditioning on lagged observables can remove.
#
# Parallelized: future_lapply over scenarios, 4 workers
# Grid: kappa x phi_U x rho_Z x delta_U = 36 scenarios x 500 reps
#   kappa = 0:   baseline (no endogeneity)
#     phi_U in {0, 0.5} x rho_Z in {0.5, 0.7} x delta_U = 1   -> 4 rows
#   kappa > 0:   endogeneity with varying persistence and confounding strength
#     kappa in {0.3, 0.5} x phi_U in {0, 0.3, 0.5, 0.7}
#     x rho_Z in {0.5, 0.7} x delta_U in {0.3, 1.0}           -> 32 rows
#
# 13 models:
#   1-9:   Standard battery (est_models from sim_nl_utils.R)
#   10:    Oracle ADL:   Y ~ D + U + D_lag + Y_lag + Z_lag | FE
#   11:    Oracle TWFE:  Y ~ D + U | FE  (isolates effect of observing U)
#   12:    Lag-ID:       Y ~ D_lag | FE  (Bellemare's naive lag identification)
#   13:    Lag-ID+ctl:   Y ~ D_lag + Z_lag + Y_lag | FE
#
# Note on lag-ID models: in our DGP (with Y_lag and Z_lag in the true model),
# the lag-ID estimand is NOT simply beta*rho_D. We report mean coefficients
# and deviation from beta (not "bias", since the estimand differs).
# ============================================================================

library(data.table)
library(fixest)
library(future.apply)

source("../utils/sim_nl_utils.R")  # est_models()

set.seed(2026)

# ---- DGP with persistent unobserved confounder ----
sim_persistent_U <- function(N, TT, T_burn, beta, rho_Y, rho_D,
                              gamma_D, gamma_Y, delta_D, delta_Y,
                              rho_Z, sigma_aZ, kappa, phi_U, delta_U) {
  T_sim <- TT + T_burn

  alpha_D <- rnorm(N, 0, 1)
  alpha_Y <- rnorm(N, 0, 1)
  alpha_Z <- rnorm(N, 0, sigma_aZ)

  rows <- vector("list", N)

  # Stationary SD of U: SD = 1 / sqrt(1 - phi_U^2)
  sd_U_stationary <- 1 / sqrt(1 - phi_U^2)

  for (i in 1:N) {
    D <- Y <- Z <- U <- numeric(T_sim)
    U[1] <- rnorm(1, 0, sd_U_stationary)
    D[1] <- alpha_D[i] + kappa * U[1] + rnorm(1)
    Y[1] <- alpha_Y[i] + beta * D[1] + delta_U * U[1] + rnorm(1)  # Fix #6
    Z[1] <- alpha_Z[i] + rnorm(1)

    for (t in 2:T_sim) {
      v  <- rnorm(1)  # innovation in U
      u  <- rnorm(1)
      e  <- rnorm(1)
      nu <- rnorm(1)

      U[t] <- phi_U * U[t - 1] + v
      D[t] <- alpha_D[i] + gamma_D * Z[t - 1] + rho_D * D[t - 1] +
              kappa * U[t] + u
      Y[t] <- alpha_Y[i] + beta * D[t] + gamma_Y * Z[t - 1] +
              rho_Y * Y[t - 1] + delta_U * U[t] + e
      Z[t] <- alpha_Z[i] + delta_D * D[t] + delta_Y * Y[t] +
              rho_Z * Z[t - 1] + nu

      # Fix #3: explosive check
      if (abs(D[t]) > 1e6 || abs(Y[t]) > 1e6 || abs(Z[t]) > 1e6) {
        return(NULL)
      }
    }

    idx <- (T_burn + 1):T_sim
    rows[[i]] <- data.table(
      id = i, time = seq_along(idx),
      D = D[idx], Y = Y[idx], Z = Z[idx], U = U[idx],
      D_lag = c(NA, D[idx[-length(idx)]]),
      Y_lag = c(NA, Y[idx[-length(idx)]]),
      Z_lag = c(NA, Z[idx[-length(idx)]]),
      U_lag = c(NA, U[idx[-length(idx)]])
    )
  }

  dt <- rbindlist(rows)
  dt <- dt[complete.cases(dt)]
  dt[, `:=`(id_f = factor(id), time_f = factor(time))]
  dt
}

# ---- Estimation: standard 9 + oracle ADL + oracle TWFE + lag-ID ----
est_models_U <- function(dt) {
  # Standard 9 models (from sim_nl_utils.R)
  base <- est_models(dt)
  if (is.null(base)) return(NULL)

  tryCatch({
    # 10. Oracle ADL: observes U (benchmark for OVB)
    m10 <- feols(Y ~ D + U + D_lag + Y_lag + Z_lag | id_f + time_f,
                 dt, vcov = "iid")
    # 11. Oracle TWFE: observes U, no dynamics (Fix #9)
    m11 <- feols(Y ~ D + U | id_f + time_f, dt, vcov = "iid")
    # 12. Lag-ID: regress Y on D_lag only (Bellemare's naive approach)
    m12 <- feols(Y ~ D_lag | id_f + time_f, dt, vcov = "iid")
    # 13. Lag-ID with controls
    m13 <- feols(Y ~ D_lag + Z_lag + Y_lag | id_f + time_f, dt, vcov = "iid")

    c(base,
      oracle_adl  = coef(m10)["D"],
      oracle_twfe = coef(m11)["D"],
      lagid       = coef(m12)["D_lag"],
      lagid_ctl   = coef(m13)["D_lag"])
  }, error = function(e) {
    warning(sprintf("est_models_U extra models failed: %s", e$message))
    NULL
  })
}

# ---- Diagnostic: within-unit Cor(D, U) ----
# Fix #1: no side-effects on dt (avoid `:=` by reference)
compute_DU_corr <- function(dt) {
  d_means <- dt[, .(D_mean = mean(D), U_mean = mean(U)), by = id]
  dt_tmp <- dt[d_means, on = "id"]
  cor(dt_tmp$D - dt_tmp$D_mean, dt_tmp$U - dt_tmp$U_mean)
}

# ---- Grid ----
# kappa=0: sanity check (no endogeneity from U)
# delta_U irrelevant for OVB when kappa=0, fix at 1
grid_k0 <- CJ(
  kappa   = 0,
  phi_U   = c(0, 0.5),
  rho_Z   = c(0.5, 0.7),
  delta_U = 1
)

# kappa>0: endogeneity with varying persistence and confounding strength
# Fix #8: vary delta_U to show OVB scales with confounding strength
grid_k_pos <- CJ(
  kappa   = c(0.3, 0.5),
  phi_U   = c(0, 0.3, 0.5, 0.7),
  rho_Z   = c(0.5, 0.7),
  delta_U = c(0.3, 1.0)
)

grid <- rbind(grid_k0, grid_k_pos)

P <- list(N = 100, TT = 30, T_burn = 100, beta = 1,
          rho_Y = 0.5, rho_D = 0.5,
          gamma_D = 0.15, gamma_Y = 0.2,
          delta_D = 0.1, delta_Y = 0.1,
          sigma_aZ = 0.5)
N_REPS <- 500

# ---- Run (parallel over scenarios, 4 workers) ----
cat(rep("=", 71), "\n", sep = "")
cat("SIM: PERSISTENT UNOBSERVED CONFOUNDER (Bellemare et al. 2017)\n")
cat(rep("=", 71), "\n\n")
cat(nrow(grid), "scenarios x", N_REPS, "reps (4 workers)\n")
cat("DGP: beta=1, rho_Y=0.5, rho_D=0.5, gamma_D=0.15, gamma_Y=0.2\n")
cat("     delta_D=0.1, delta_Y=0.1, N=100, T=30, T_burn=100\n")
cat("NEW: U_t = phi_U * U_{t-1} + v_t\n")
cat("     kappa * U_t -> D_t, delta_U * U_t -> Y_t\n")
cat("     delta_U in {0.3, 1.0} (varied for kappa>0)\n\n")

plan(multisession, workers = 4)

run_scenario <- function(g) {
  kp <- grid$kappa[g]
  pu <- grid$phi_U[g]
  rz <- grid$rho_Z[g]
  du <- grid$delta_U[g]

  n_valid <- 0L
  n_discarded <- 0L
  reps_list <- vector("list", N_REPS)
  corr_vals <- numeric(N_REPS)

  for (s in 1:N_REPS) {
    dt <- sim_persistent_U(P$N, P$TT, P$T_burn, P$beta, P$rho_Y, P$rho_D,
                            P$gamma_D, P$gamma_Y, P$delta_D, P$delta_Y,
                            rz, P$sigma_aZ, kp, pu, du)
    if (is.null(dt)) {
      n_discarded <- n_discarded + 1L
      next
    }
    cr <- compute_DU_corr(dt)
    est <- est_models_U(dt)
    if (is.null(est)) {
      n_discarded <- n_discarded + 1L
      next
    }
    n_valid <- n_valid + 1L
    reps_list[[n_valid]] <- data.table::as.data.table(as.list(est))[,
      `:=`(sim = s, cor_DU = cr)]
    corr_vals[n_valid] <- cr
  }

  if (n_valid == 0) {
    return(list(res = NULL, n_discarded = N_REPS,
                cor_DU_mean = NA_real_))
  }

  reps_list <- reps_list[seq_len(n_valid)]
  res_g <- data.table::rbindlist(reps_list)
  res_g[, `:=`(kappa = kp, phi_U = pu, rho_Z = rz, delta_U = du)]

  list(res = res_g,
       n_discarded = n_discarded,
       cor_DU_mean = mean(corr_vals[seq_len(n_valid)]))
}

set.seed(2026100)  # isolate main simulation RNG from setup
t0_total <- proc.time()

par_out <- future_lapply(1:nrow(grid), run_scenario, future.seed = TRUE)

total_elapsed <- (proc.time() - t0_total)[3]
plan(sequential)  # release workers

cat(sprintf("\nTotal time: %.1fs (parallel, 4 workers)\n", total_elapsed))

# Unpack parallel results
all_res          <- lapply(par_out, `[[`, "res")
n_discarded_vec  <- vapply(par_out, `[[`, integer(1), "n_discarded")
DU_corrs         <- vapply(par_out, `[[`, double(1), "cor_DU_mean")

# Report per-scenario summary
for (g in 1:nrow(grid)) {
  disc_pct <- round(100 * n_discarded_vec[g] / N_REPS, 1)
  cat(sprintf("[%d/%d] kappa=%.2f phi_U=%.2f rho_Z=%.2f delta_U=%.1f  cor(D,U)=%.3f  discarded=%d/%d (%.1f%%)\n",
              g, nrow(grid), grid$kappa[g], grid$phi_U[g],
              grid$rho_Z[g], grid$delta_U[g],
              DU_corrs[g], n_discarded_vec[g], N_REPS, disc_pct))
}

results <- rbindlist(all_res)

# ---- Summary ----
beta_true <- P$beta

# CET models: bias = mean - beta_true
# Lag-ID models: dev = mean - beta_true (different estimand, not "bias")
cet_cols  <- c("twfe_s.D", "twfe_l.D", "adl_Ylag.D", "adl_full.D",
               "adl_Dlag.D", "adl_DYlag.D", "adl_DZlag.D", "adl_all.D",
               "adl_all_nofe.D",
               "oracle_adl.D", "oracle_twfe.D")
cet_names <- c("twfe_s", "twfe_l", "adl_Ylag", "adl_full",
               "adl_Dlag", "adl_DYlag", "adl_DZlag", "adl_all",
               "adl_all_nofe",
               "oracle_adl", "oracle_twfe")

# Fix #2: lag-ID uses _dev suffix, not _bias
lagid_cols  <- c("lagid.D_lag", "lagid_ctl.D_lag")
lagid_names <- c("lagid", "lagid_ctl")

summ <- results[, {
  out <- list()
  # CET models
  for (j in seq_along(cet_cols)) {
    vals <- get(cet_cols[j])
    out[[paste0(cet_names[j], "_mean")]] <- mean(vals)
    out[[paste0(cet_names[j], "_bias")]] <- mean(vals) - beta_true
    out[[paste0(cet_names[j], "_mcse")]] <- sd(vals) / sqrt(.N)
    out[[paste0(cet_names[j], "_sd")]]   <- sd(vals)
    out[[paste0(cet_names[j], "_rmse")]] <- sqrt(mean((vals - beta_true)^2))
  }
  # Lag-ID models (deviation from beta, not bias)
  for (j in seq_along(lagid_cols)) {
    vals <- get(lagid_cols[j])
    out[[paste0(lagid_names[j], "_mean")]] <- mean(vals)
    out[[paste0(lagid_names[j], "_dev")]]  <- mean(vals) - beta_true
    out[[paste0(lagid_names[j], "_mcse")]] <- sd(vals) / sqrt(.N)
    out[[paste0(lagid_names[j], "_sd")]]   <- sd(vals)
  }
  out$n_sims <- .N
  out$cor_DU_mean <- mean(cor_DU)
  out
}, by = .(kappa, phi_U, rho_Z, delta_U)]

# Add discarded count
disc_dt <- data.table(grid, n_discarded = n_discarded_vec)
summ <- merge(summ, disc_dt, by = c("kappa", "phi_U", "rho_Z", "delta_U"), all.x = TRUE)

# ---- Print results ----
cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("RESULTS: BIAS BY MODEL (CET models: bias = estimate - beta_true = 1)\n")
cat("  Lag-ID models estimate a different quantity; reported as 'dev from beta'.\n")
cat(rep("=", 80), "\n\n")

for (rz in c(0.5, 0.7)) {
  cat(sprintf("--- rho_Z = %.2f ---\n\n", rz))
  s <- summ[rho_Z == rz]

  cat("BIAS (key CET models):\n")
  bias_tab <- s[, .(kappa, phi_U, delta_U, cor_DU_mean, n_discarded,
    `TWFE_s`     = round(twfe_s_bias, 4),
    `TWFE_l`     = round(twfe_l_bias, 4),
    `ADL_full`   = round(adl_full_bias, 4),
    `ADL_all`    = round(adl_all_bias, 4),
    `ADL_noFE`   = round(adl_all_nofe_bias, 4),
    `Orc_ADL`    = round(oracle_adl_bias, 4),
    `Orc_TWFE`   = round(oracle_twfe_bias, 4))]
  print(bias_tab)

  cat("\nBIAS AS % OF BETA (CET models only):\n")
  pct_tab <- s[, .(kappa, phi_U, delta_U,
    `TWFE_s_%`    = round(100 * twfe_s_bias / beta_true, 1),
    `TWFE_l_%`    = round(100 * twfe_l_bias / beta_true, 1),
    `ADL_full_%`  = round(100 * adl_full_bias / beta_true, 1),
    `ADL_all_%`   = round(100 * adl_all_bias / beta_true, 1),
    `ADL_noFE_%`  = round(100 * adl_all_nofe_bias / beta_true, 1),
    `Orc_ADL_%`   = round(100 * oracle_adl_bias / beta_true, 1),
    `Orc_TWFE_%`  = round(100 * oracle_twfe_bias / beta_true, 1))]
  print(pct_tab)

  cat("\nLAG-ID MODELS (mean coefs — estimand differs from beta):\n")
  lagid_tab <- s[, .(kappa, phi_U, delta_U,
    `LagID_mean`     = round(lagid_mean, 4),
    `LagID_ctl_mean` = round(lagid_ctl_mean, 4),
    `LagID_dev`      = round(lagid_dev, 4),
    `LagID_ctl_dev`  = round(lagid_ctl_dev, 4))]
  print(lagid_tab)

  cat("\nRMSE (CET models):\n")
  rmse_tab <- s[, .(kappa, phi_U, delta_U,
    `TWFE_s`    = round(twfe_s_rmse, 4),
    `ADL_all`   = round(adl_all_rmse, 4),
    `Orc_ADL`   = round(oracle_adl_rmse, 4),
    `Orc_TWFE`  = round(oracle_twfe_rmse, 4))]
  print(rmse_tab)

  cat("\nMC STANDARD ERRORS:\n")
  mcse_tab <- s[, .(kappa, phi_U, delta_U,
    `TWFE_s`    = round(twfe_s_mcse, 4),
    `ADL_all`   = round(adl_all_mcse, 4),
    `Orc_ADL`   = round(oracle_adl_mcse, 4))]
  print(mcse_tab)
  cat("\n")
}

# ---- Decompositions ----
cat(rep("=", 80), "\n", sep = "")
cat("DECOMPOSITIONS\n")
cat(rep("=", 80), "\n\n")

cat("A. IVB of Z_lag (bias_long - bias_short):\n")
ivb_tab <- summ[, .(kappa, phi_U, rho_Z, delta_U,
  `IVB_TWFE`     = round(twfe_l_bias - twfe_s_bias, 4),
  `IVB_ADL`      = round(adl_full_bias - adl_Ylag_bias, 4),
  `IVB_ADL+Dlag` = round(adl_all_bias - adl_DYlag_bias, 4))]
print(ivb_tab)

cat("\nB. OVB from U (ADL_all - Oracle_ADL = residual bias from not observing U):\n")
ovb_tab <- summ[, .(kappa, phi_U, rho_Z, delta_U, cor_DU_mean,
  `ADL_all`    = round(adl_all_bias, 4),
  `Orc_ADL`    = round(oracle_adl_bias, 4),
  `OVB_from_U` = round(adl_all_bias - oracle_adl_bias, 4),
  `|OVB/b|_%`  = round(100 * abs(adl_all_bias - oracle_adl_bias) / abs(beta_true), 1))]
print(ovb_tab)

# Fix #7: add safety check for merge
cat("\nC. Effect of persistence (delta = bias(phi>0) - bias(phi=0), same kappa):\n")
baseline <- summ[phi_U == 0, .(kappa, rho_Z, delta_U,
  bl_adl_all = adl_all_bias,
  bl_oracle  = oracle_adl_bias)]
stopifnot("Baseline must have one row per (kappa, rho_Z, delta_U)" =
            nrow(baseline) == nrow(unique(baseline[, .(kappa, rho_Z, delta_U)])))
pers_comp <- summ[phi_U > 0]
pers_tab <- merge(pers_comp, baseline, by = c("kappa", "rho_Z", "delta_U"))
pers_tab <- pers_tab[, .(kappa, phi_U, rho_Z, delta_U,
  `ADL_all_delta`  = round(adl_all_bias - bl_adl_all, 4),
  `Oracle_delta`   = round(oracle_adl_bias - bl_oracle, 4))]
print(pers_tab)

cat("\nD. Does Y_lag help absorb U? (ADL_all vs TWFE_s):\n")
ylag_tab <- summ[, .(kappa, phi_U, rho_Z, delta_U,
  `TWFE_s`       = round(twfe_s_bias, 4),
  `ADL_all`      = round(adl_all_bias, 4),
  `Ylag_benefit` = round(abs(twfe_s_bias) - abs(adl_all_bias), 4))]
print(ylag_tab)

cat("\nE. Oracle TWFE vs Oracle ADL (value of dynamics when U is observed):\n")
orc_tab <- summ[, .(kappa, phi_U, rho_Z, delta_U,
  `Orc_TWFE`       = round(oracle_twfe_bias, 4),
  `Orc_ADL`        = round(oracle_adl_bias, 4),
  `ADL_benefit`    = round(abs(oracle_twfe_bias) - abs(oracle_adl_bias), 4))]
print(orc_tab)

cat("\nF. Best model (smallest |bias|) per scenario:\n")
best_tab <- summ[, {
  biases <- c(twfe_s = abs(twfe_s_bias), twfe_l = abs(twfe_l_bias),
              adl_Ylag = abs(adl_Ylag_bias), adl_full = abs(adl_full_bias),
              adl_all = abs(adl_all_bias),
              oracle_adl = abs(oracle_adl_bias), oracle_twfe = abs(oracle_twfe_bias))
  best_idx <- which.min(biases)
  .(best_model = names(biases)[best_idx],
    best_bias = round(biases[best_idx], 4),
    adl_all_bias_pct  = round(100 * abs(adl_all_bias) / abs(beta_true), 1),
    oracle_adl_pct    = round(100 * abs(oracle_adl_bias) / abs(beta_true), 1))
}, by = .(kappa, phi_U, rho_Z, delta_U)]
print(best_tab)

# ---- Sanity checks ----
cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("SANITY CHECKS\n")
cat(rep("=", 80), "\n\n")

cat("1. kappa=0: no OVB from U. ADL_all bias should be <3% (pure collider):\n")
print(summ[kappa == 0, .(kappa, phi_U, rho_Z, delta_U,
  adl_all_bias = round(adl_all_bias, 4),
  `adl_all_%` = round(100 * abs(adl_all_bias) / abs(beta_true), 1),
  cor_DU_mean)])
cat("  (cor_DU_mean should be ~0 when kappa=0)\n")

cat("\n2. Oracle ADL bias should be small (<3%) regardless of kappa, phi_U:\n")
print(summ[, .(kappa, phi_U, rho_Z, delta_U,
  oracle_adl_bias = round(oracle_adl_bias, 4),
  `oracle_%` = round(100 * abs(oracle_adl_bias) / abs(beta_true), 1))])

cat("\n3. OVB should increase with kappa (stronger endogeneity):\n")
print(summ[phi_U == 0.5, .(kappa, phi_U, rho_Z, delta_U,
  `OVB_%` = round(100 * abs(adl_all_bias - oracle_adl_bias) / abs(beta_true), 1))])

cat("\n4. At kappa>0 and phi_U=0, OVB still exists (contemporaneous U):\n")
print(summ[phi_U == 0 & kappa > 0, .(kappa, phi_U, rho_Z, delta_U,
  adl_all_bias = round(adl_all_bias, 4),
  oracle_adl_bias = round(oracle_adl_bias, 4),
  `OVB_%` = round(100 * abs(adl_all_bias - oracle_adl_bias) / abs(beta_true), 1))])
cat("  (OVB exists even without persistence because kappa*U_t is contemporaneous)\n")

cat("\n5. OVB should scale with delta_U:\n")
print(summ[kappa == 0.5 & phi_U == 0.5, .(kappa, phi_U, rho_Z, delta_U,
  `OVB_%` = round(100 * abs(adl_all_bias - oracle_adl_bias) / abs(beta_true), 1))])

cat("\n6. Discarded reps (explosive series):\n")
print(data.table(grid, n_discarded = n_discarded_vec)[n_discarded > 0])
if (all(n_discarded_vec == 0)) cat("  None — all scenarios stable.\n")
if (any(n_discarded_vec > N_REPS * 0.1)) {
  cat("  WARNING: >10% discarded in some scenarios!\n")
}

# ---- Save ----
fwrite(summ, "results/sim_persistent_confounder_results.csv")
fwrite(results, "results/sim_persistent_confounder_raw.csv")

timing <- data.table(grid, n_discarded = n_discarded_vec,
                     total_s = total_elapsed)
fwrite(timing, "results/sim_persistent_confounder_timing.csv")

cat(sprintf("\nResults saved to results/sim_persistent_confounder_results.csv (%d rows)\n",
            nrow(summ)))
cat(sprintf("Raw saved to results/sim_persistent_confounder_raw.csv (%d rows)\n",
            nrow(results)))
cat(sprintf("Timing saved (total %.1fs)\n", total_elapsed))

writeLines(capture.output(sessionInfo()),
           "results/sim_persistent_confounder_sessioninfo.txt")
