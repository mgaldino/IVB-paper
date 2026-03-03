# ============================================================================
# sim_nl_collider.R
# NL-1a/1c: Non-linearity in D->Z (and optionally Y->Z)
#
# DGP:
#   D_t = alpha^D_i + gamma_D Z_{t-1} + rho_D D_{t-1} + u_t
#   Y_t = alpha^Y_i + beta D_t + gamma_Y Z_{t-1} + rho_Y Y_{t-1} + e_t
#   Z_t = alpha^Z_i + delta_D D_t + f_nl(D_t)
#         + delta_Y Y_t + [delta_Y2 Y_t^2/(1+(Y_t/c_Y)^2)]
#         + rho_Z Z_{t-1} + nu_t
#
# Eight non-linearity types:
#   Bounded:
#     log2:      log(1 + D^2)                  — log-bounded, ~D^2 near origin
#     log4:      log(1 + D^4)                  — saturation (bounded growth)
#     softpoly2: D^2 / (1 + (D/c)^2)          — bounded, ~D^2 near origin -> c^2
#     sin:       sin(D)                        — bounded, non-monotone, periodic
#     invlogit:  1/(1+exp(-D)) - 0.5          — bounded sigmoid, fast saturation
#                Note: slope ~0.25 near origin, saturates at ~0.5;
#                at 3*sd_D, contribution is only 1.8x that at 1*sd_D
#     tanh:      c*tanh(D/c)                  — bounded, odd, saturates at +/-c
#   Unbounded:
#     power1.5:  sign(D)*|D|^1.5              — super-linear, sub-quadratic
#     Dlog:      D*log(1+|D|)                 — slow unbounded (~D*logD);
#                odd function: f(-D)=-f(D); ~sign(D)*D^2 near origin
#
# All calibrated so that at D = sd_D_within, the non-linear contribution
# = nl_strength * delta_D * sd_D_within (ensures direct comparability).
#
# Researcher always estimates LINEAR models (TWFE, ADL).
# Question: How much does non-linearity in the collider channel increase IVB?
#
# Grid: nl_type x nl_strength x nl_Y x rho_Z x TT ~ 84 scenarios x 500 reps
# TT varies: 30 (all scenarios), 10 (baseline + log2 + Dlog subset)
# Parallelized: future_lapply over scenarios, 4 workers
# ============================================================================

library(data.table)
library(fixest)
library(future.apply)

source("../utils/sim_nl_utils.R")  # est_models(), run_pilot()

set.seed(2026)

# ---- Fixed parameters ----
# P$TT = 30 is used only for the pilot calibration run.
# The actual TT per scenario comes from the grid (TT = 10 or 30).
P <- list(N = 100, TT = 30, T_burn = 100, beta = 1,
          rho_Y = 0.5, rho_D = 0.5,
          gamma_D = 0.15, gamma_Y = 0.2,
          delta_D = 0.1, delta_Y = 0.1,
          sigma_aZ = 0.5)
N_REPS <- 500L

# ============================================================================
# PILOT RUN: calibrate sd(D_within) and sd(Y_within) from linear baseline
# ============================================================================
# sd_D_within and sd_Y_within are properties of the stationary distribution,
# not of sample size T. After T_burn=100, the series is at stationarity,
# so the pilot at T=30 gives valid calibration constants for T=10 too.
cat("PILOT RUN: calibrating sd(D_within) and sd(Y_within)...\n")
pilot <- run_pilot(P, n_pilot = 10, return_Y = TRUE)
sd_D_within <- pilot$sd_D
sd_Y_within <- pilot$sd_Y
cat(sprintf("  sd(D_within) = %.4f (avg over rho_Z = 0.5, 0.7)\n", sd_D_within))
cat(sprintf("  sd(Y_within) = %.4f (avg over rho_Z = 0.5, 0.7)\n\n", sd_Y_within))

# ---- DGP with non-linear collider ----
sim_nl_collider <- function(N, TT, T_burn, beta, rho_Y, rho_D,
                            gamma_D, gamma_Y, delta_D, delta_Y,
                            rho_Z, sigma_aZ,
                            delta_D2, delta_log4, delta_softpoly2,
                            delta_power15, c_soft,
                            delta_sin, delta_invlogit, delta_Dlog,
                            delta_tanh, c_tanh,
                            delta_Y2, c_soft_Y) {
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
      Y[t] <- alpha_Y[i] + beta * D[t] + gamma_Y * Z[t-1] + rho_Y * Y[t-1] + e
      Z[t] <- alpha_Z[i] + delta_D * D[t] +
              delta_D2 * log(1 + D[t]^2) +
              delta_log4 * log(1 + D[t]^4) +
              delta_softpoly2 * (D[t]^2 / (1 + (D[t] / c_soft)^2)) +
              delta_power15 * (sign(D[t]) * abs(D[t])^1.5) +
              delta_sin * sin(D[t]) +
              delta_invlogit * (1 / (1 + exp(-D[t])) - 0.5) +
              delta_Dlog * (D[t] * log(1 + abs(D[t]))) +
              delta_tanh * (c_tanh * tanh(D[t] / c_tanh)) +
              delta_Y * Y[t] + delta_Y2 * (Y[t]^2 / (1 + (Y[t] / c_soft_Y)^2)) +
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

# ---- Calibration constants for stabilized non-linearities ----
c_soft   <- 2 * sd_D_within      # softpoly2 saturation scale (D channel)
c_soft_Y <- 2 * sd_Y_within      # softclamp saturation scale (Y channel)
c_tanh   <- 1.5 * sd_D_within    # tanh saturation scale

# At D = sd_D_within, each f(D) is calibrated so that:
#   delta_nl * f(sd_D) = nl_strength * delta_D * sd_D
# This ensures direct comparability across nl_types.
#
# log2:      f(sd_D) = log(1 + sd_D^2)
# log4:      f(sd_D) = log(1 + sd_D^4)
# softpoly2: f(sd_D) = sd_D^2 / (1 + (sd_D/c)^2)
# power1.5:  f(sd_D) = sd_D^1.5
# sin:       f(sd_D) = sin(sd_D)
# invlogit:  f(sd_D) = 1/(1+exp(-sd_D)) - 0.5
# tanh:      f(sd_D) = c_tanh * tanh(sd_D / c_tanh)
# Dlog:      f(sd_D) = sd_D * log(1 + sd_D)

# Computed dynamically from c_soft / sd_D — avoids hardcoded constants
softpoly2_adj   <- 1 + (sd_D_within / c_soft)^2    # = 1/(fraction at sd_D)
softpoly2_adj_Y <- 1 + (sd_Y_within / c_soft_Y)^2  # idem for Y channel

cat(sprintf("  Calibration: c_soft=%.4f, c_soft_Y=%.4f, c_tanh=%.4f\n",
            c_soft, c_soft_Y, c_tanh))
cat(sprintf("               softpoly2_adj=%.4f (D), %.4f (Y)\n\n",
            softpoly2_adj, softpoly2_adj_Y))

# ---- Grid ----
# Build in parts for clarity, then rbind.
# Part 1 (grid_T30_old) is first in rbind to preserve row ordering
# for seed reproducibility of existing scenarios.

# Part 1: Existing scenarios at TT=30 (42 rows, unchanged)
grid_T30_old <- CJ(
  nl_type     = c("log2", "log4", "softpoly2", "power1.5"),
  nl_strength = c(0, 0.1, 0.2, 0.5, 1.0, 2.0),
  nl_Y        = c(FALSE, TRUE),
  rho_Z       = c(0.5, 0.7)
)
grid_T30_old <- grid_T30_old[
  (nl_strength == 0 & nl_type == "log2" & nl_Y == FALSE) |            # baseline: 2
  (nl_strength %in% c(0.1, 0.2) & nl_type == "log2" & !nl_Y) |       # log2 frontier: 4
  (nl_strength %in% c(0.5, 1.0, 2.0) & nl_type == "log2" & !nl_Y) |  # log2 NL-1a: 6
  (nl_strength %in% c(0.5, 1.0, 2.0) & nl_type == "log2" & nl_Y) |   # log2 NL-1c: 6
  (nl_strength %in% c(0.5, 1.0, 2.0) & nl_type == "log4" & !nl_Y) |  # log4: 6
  (nl_strength %in% c(0.5, 1.0, 2.0) & nl_type == "softpoly2" & !nl_Y) | # softpoly2 NL-1a: 6
  (nl_strength %in% c(0.5, 1.0, 2.0) & nl_type == "softpoly2" & nl_Y) |  # softpoly2 NL-1c: 6
  (nl_strength %in% c(0.5, 1.0, 2.0) & nl_type == "power1.5" & !nl_Y)    # power1.5: 6
]
grid_T30_old[, TT := 30L]

# Part 2: New NL types at TT=30 (28 rows)
grid_T30_new <- rbind(
  CJ(nl_type = "sin",      nl_strength = c(0.5, 1.0, 2.0),      nl_Y = FALSE, rho_Z = c(0.5, 0.7)),
  CJ(nl_type = "invlogit", nl_strength = c(0.5, 1.0, 2.0),      nl_Y = FALSE, rho_Z = c(0.5, 0.7)),
  CJ(nl_type = "tanh",     nl_strength = c(0.2, 0.5, 1.0, 2.0), nl_Y = FALSE, rho_Z = c(0.5, 0.7)),
  CJ(nl_type = "Dlog",     nl_strength = c(0.2, 0.5, 1.0, 2.0), nl_Y = FALSE, rho_Z = c(0.5, 0.7))
)
grid_T30_new[, TT := 30L]

# Part 3: T=10 subset — baseline + log2 + Dlog (14 rows)
grid_T10 <- rbind(
  CJ(nl_type = "log2", nl_strength = 0,                  nl_Y = FALSE, rho_Z = c(0.5, 0.7)),
  CJ(nl_type = "log2", nl_strength = c(0.5, 1.0, 2.0),  nl_Y = FALSE, rho_Z = c(0.5, 0.7)),
  CJ(nl_type = "Dlog", nl_strength = c(0.5, 1.0, 2.0),  nl_Y = FALSE, rho_Z = c(0.5, 0.7))
)
grid_T10[, TT := 10L]

grid <- rbind(grid_T30_old, grid_T30_new, grid_T10)

# Compute calibrated non-linear coefficients
# General formula: delta_nl = nl_str * delta_D * sd_D / f(sd_D)
grid[, delta_D2 := fifelse(nl_type == "log2" & nl_strength > 0,
                           nl_strength * P$delta_D * sd_D_within / log(1 + sd_D_within^2), 0)]
grid[, delta_log4 := fifelse(nl_type == "log4" & nl_strength > 0,
                             nl_strength * P$delta_D * sd_D_within / log(1 + sd_D_within^4), 0)]
grid[, delta_softpoly2 := fifelse(nl_type == "softpoly2" & nl_strength > 0,
                                  nl_strength * P$delta_D * softpoly2_adj / sd_D_within, 0)]
grid[, delta_power15 := fifelse(nl_type == "power1.5" & nl_strength > 0,
                                nl_strength * P$delta_D / sqrt(sd_D_within), 0)]
grid[, delta_sin := fifelse(nl_type == "sin" & nl_strength > 0,
                            nl_strength * P$delta_D * sd_D_within / sin(sd_D_within), 0)]
grid[, delta_invlogit := fifelse(nl_type == "invlogit" & nl_strength > 0,
                                 nl_strength * P$delta_D * sd_D_within /
                                   (1 / (1 + exp(-sd_D_within)) - 0.5), 0)]
grid[, delta_tanh := fifelse(nl_type == "tanh" & nl_strength > 0,
                             nl_strength * P$delta_D * sd_D_within /
                               (c_tanh * tanh(sd_D_within / c_tanh)), 0)]
grid[, delta_Dlog := fifelse(nl_type == "Dlog" & nl_strength > 0,
                             nl_strength * P$delta_D / log(1 + sd_D_within), 0)]
# Y^2 for NL-1c (log2 and softpoly2), with softclamp adjustment
grid[, delta_Y2 := fifelse(nl_Y == TRUE & nl_strength > 0,
                           nl_strength * P$delta_Y * softpoly2_adj_Y / sd_Y_within, 0)]

# Assertion: each non-baseline row activates exactly one NL term in D->Z
n_active <- grid[nl_strength > 0, (delta_D2 != 0) + (delta_log4 != 0) +
                                   (delta_softpoly2 != 0) + (delta_power15 != 0) +
                                   (delta_sin != 0) + (delta_invlogit != 0) +
                                   (delta_tanh != 0) + (delta_Dlog != 0)]
stopifnot("Each scenario must activate exactly one NL D-term" = all(n_active == 1))

cat(sprintf("Grid: %d scenarios\n", nrow(grid)))
print(grid[, .(nl_type, nl_strength, nl_Y, rho_Z, TT,
               delta_D2, delta_log4, delta_softpoly2, delta_power15,
               delta_sin, delta_invlogit, delta_tanh, delta_Dlog, delta_Y2)])

# ---- Run (parallel over scenarios) ----
cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("SIM NL-COLLIDER: 8 NL types + T variation (10, 30)\n")
cat(rep("=", 80), "\n\n")
cat(nrow(grid), "scenarios x", N_REPS, "reps (4 workers)\n")
cat("DGP: beta=1, rho_Y=0.5, rho_D=0.5, gamma_D=0.15, gamma_Y=0.2\n")
cat("     delta_D=0.1, delta_Y=0.1, N=100, T_burn=100\n")
cat(sprintf("     sd_D_within=%.4f, sd_Y_within=%.4f (from pilot)\n\n", sd_D_within, sd_Y_within))

plan(multisession, workers = 4)

run_scenario <- function(g) {
  nlt  <- grid$nl_type[g]
  nls  <- grid$nl_strength[g]
  nly  <- grid$nl_Y[g]
  rz   <- grid$rho_Z[g]
  tt   <- grid$TT[g]
  dD2  <- grid$delta_D2[g]
  dl4  <- grid$delta_log4[g]
  dsp2 <- grid$delta_softpoly2[g]
  dp15 <- grid$delta_power15[g]
  dsin <- grid$delta_sin[g]
  dinv <- grid$delta_invlogit[g]
  dtnh <- grid$delta_tanh[g]
  dDlg <- grid$delta_Dlog[g]
  dY2  <- grid$delta_Y2[g]

  n_discarded <- 0L
  n_valid <- 0L
  reps_list <- vector("list", N_REPS)
  D_means <- Y_means <- Z_means <- numeric(N_REPS)
  D_sds   <- Y_sds   <- Z_sds   <- numeric(N_REPS)

  for (s in 1:N_REPS) {
    dt <- sim_nl_collider(P$N, tt, P$T_burn, P$beta, P$rho_Y, P$rho_D,
                          P$gamma_D, P$gamma_Y, P$delta_D, P$delta_Y,
                          rz, P$sigma_aZ, dD2, dl4, dsp2, dp15, c_soft,
                          dsin, dinv, dDlg, dtnh, c_tanh,
                          dY2, c_soft_Y)
    if (is.null(dt)) {
      n_discarded <- n_discarded + 1L
      next
    }
    est <- est_models(dt)
    if (is.null(est)) {
      n_discarded <- n_discarded + 1L
      next
    }
    reps_list[[s]] <- data.table::as.data.table(as.list(est))[, sim := s]
    n_valid <- n_valid + 1L
    D_means[n_valid] <- mean(dt$D)
    Y_means[n_valid] <- mean(dt$Y)
    Z_means[n_valid] <- mean(dt$Z)
    D_sds[n_valid]   <- sd(dt$D)
    Y_sds[n_valid]   <- sd(dt$Y)
    Z_sds[n_valid]   <- sd(dt$Z)
  }

  reps_list <- reps_list[!vapply(reps_list, is.null, logical(1))]
  if (length(reps_list) == 0) {
    return(list(res = NULL, n_discarded = N_REPS, scale = NULL))
  }

  res_g <- data.table::rbindlist(reps_list)
  res_g[, `:=`(nl_type = nlt, nl_strength = nls, nl_Y = nly, rho_Z = rz, TT = tt)]

  sc <- data.table::data.table(
    nl_type = nlt, nl_strength = nls, nl_Y = nly, rho_Z = rz, TT = tt,
    D_mean = mean(D_means[1:n_valid]), Y_mean = mean(Y_means[1:n_valid]),
    Z_mean = mean(Z_means[1:n_valid]),
    D_sd = mean(D_sds[1:n_valid]), Y_sd = mean(Y_sds[1:n_valid]),
    Z_sd = mean(Z_sds[1:n_valid])
  )

  list(res = res_g, n_discarded = n_discarded, scale = sc)
}

set.seed(2026100)  # isolate main simulation RNG from pilot
t0_total <- proc.time()

par_out <- future_lapply(1:nrow(grid), run_scenario, future.seed = TRUE)

total_elapsed <- (proc.time() - t0_total)[3]
plan(sequential)  # release workers

cat(sprintf("\nTotal time: %.1fs (parallel, 4 workers)\n", total_elapsed))

# Unpack parallel results
all_res          <- lapply(par_out, `[[`, "res")
discarded_counts <- vapply(par_out, `[[`, integer(1), "n_discarded")
scale_stats      <- lapply(par_out, `[[`, "scale")

# Report per-scenario summary
for (g in 1:nrow(grid)) {
  disc_pct <- round(100 * discarded_counts[g] / N_REPS, 1)
  cat(sprintf("[%d/%d] type=%-9s nl_str=%.1f nl_Y=%-5s rho_Z=%.2f TT=%d  discarded: %d/%d (%.1f%%)\n",
              g, nrow(grid), grid$nl_type[g], grid$nl_strength[g],
              grid$nl_Y[g], grid$rho_Z[g], grid$TT[g],
              discarded_counts[g], N_REPS, disc_pct))
}

results <- rbindlist(all_res[!vapply(all_res, is.null, logical(1))])

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
}, by = .(nl_type, nl_strength, nl_Y, rho_Z, TT)]

# Add discarded count
disc_dt <- data.table(grid[, .(nl_type, nl_strength, nl_Y, rho_Z, TT)],
                      n_discarded = discarded_counts)
summ <- merge(summ, disc_dt, by = c("nl_type", "nl_strength", "nl_Y", "rho_Z", "TT"),
              all.x = TRUE)

# ---- Print results ----
cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("RESULTS: BIAS BY MODEL (beta_true = 1)\n")
cat(rep("=", 80), "\n\n")

for (rz in c(0.5, 0.7)) {
  cat(sprintf("--- rho_Z = %.2f ---\n\n", rz))
  s <- summ[rho_Z == rz]

  cat("BIAS (estimate - beta_true):\n")
  bias_tab <- s[, .(nl_type, nl_strength, nl_Y, TT, n_sims, n_discarded,
    `TWFE_s`    = round(twfe_s_bias, 4),
    `TWFE_l`    = round(twfe_l_bias, 4),
    `ADL_Ylag`  = round(adl_Ylag_bias, 4),
    `ADL_full`  = round(adl_full_bias, 4),
    `ADL_all`   = round(adl_all_bias, 4))]
  print(bias_tab)

  cat("\nRMSE:\n")
  rmse_tab <- s[, .(nl_type, nl_strength, nl_Y, TT,
    `TWFE_s`    = round(twfe_s_rmse, 4),
    `TWFE_l`    = round(twfe_l_rmse, 4),
    `ADL_full`  = round(adl_full_rmse, 4),
    `ADL_all`   = round(adl_all_rmse, 4),
    `ADL_noFE`  = round(adl_all_nofe_rmse, 4))]
  print(rmse_tab)

  cat("\nMC STANDARD ERRORS:\n")
  mcse_tab <- s[, .(nl_type, nl_strength, nl_Y, TT,
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
ivb_z <- summ[, .(nl_type, nl_strength, nl_Y, rho_Z, TT,
  `IVB_TWFE`       = round(twfe_l_bias - twfe_s_bias, 4),
  `|IVB/b|_TWFE`   = round(abs(twfe_l_bias - twfe_s_bias) / abs(beta_true), 4),
  `IVB_ADL`        = round(adl_full_bias - adl_Ylag_bias, 4),
  `|IVB/b|_ADL`    = round(abs(adl_full_bias - adl_Ylag_bias) / abs(beta_true), 4),
  `IVB_ADL+Dlag`   = round(adl_all_bias - adl_DYlag_bias, 4),
  `|IVB/b|_ADL+D`  = round(abs(adl_all_bias - adl_DYlag_bias) / abs(beta_true), 4))]
print(ivb_z)

cat("\nB. Nickell cost (ADL_all FE vs noFE):\n")
nick_tab <- summ[, .(nl_type, nl_strength, nl_Y, rho_Z, TT,
  `ADL_all_FE`   = round(adl_all_bias, 4),
  `ADL_all_noFE` = round(adl_all_nofe_bias, 4),
  `Nickell_cost`  = round(abs(adl_all_bias) - abs(adl_all_nofe_bias), 4))]
print(nick_tab)

cat("\nC. Best model (smallest |bias|) per scenario:\n")
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
}, by = .(nl_type, nl_strength, nl_Y, rho_Z, TT)]
print(best_tab)

# ---- F. Effect of non-linearity (comparison with linear baseline) ----
cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("F. EFFECT OF NON-LINEARITY (comparison with baseline linear)\n")
cat(rep("=", 80), "\n\n")

# Get baseline rows (nl_strength=0), one per (rho_Z, TT)
baseline <- summ[nl_strength == 0, .(rho_Z, TT,
  bl_twfe_s  = twfe_s_bias,
  bl_twfe_l  = twfe_l_bias,
  bl_adl_full = adl_full_bias,
  bl_adl_all = adl_all_bias,
  bl_ivb_twfe = twfe_l_bias - twfe_s_bias,
  bl_ivb_adl  = adl_full_bias - adl_Ylag_bias)]

# Merge with non-baseline
nl_rows <- summ[nl_strength > 0]
nl_comp <- merge(nl_rows, baseline, by = c("rho_Z", "TT"))

cat("Delta_bias = bias(nl) - bias(linear):\n")
delta_tab <- nl_comp[, .(nl_type, nl_strength, nl_Y, rho_Z, TT,
  `D_TWFE_s`   = round(twfe_s_bias - bl_twfe_s, 4),
  `D_TWFE_l`   = round(twfe_l_bias - bl_twfe_l, 4),
  `D_ADL_full` = round(adl_full_bias - bl_adl_full, 4),
  `D_ADL_all`  = round(adl_all_bias - bl_adl_all, 4))]
print(delta_tab)

cat("\nDelta_IVB = IVB(nl) - IVB(linear) and IVB_ratio = IVB(nl)/IVB(linear):\n")
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
}, by = .(nl_type, nl_strength, nl_Y, rho_Z, TT)]
print(ivb_comp)

# ---- Sanity checks ----
cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("SANITY CHECKS\n")
cat(rep("=", 80), "\n\n")

cat("1. Baseline (nl_strength=0) bias should match linear simulations:\n")
print(summ[nl_strength == 0, .(rho_Z, TT, twfe_s = round(twfe_s_bias, 4),
  twfe_l = round(twfe_l_bias, 4), adl_full = round(adl_full_bias, 4),
  adl_all = round(adl_all_bias, 4))])

cat("\n2. Scale of D, Y, Z by scenario (mean of means and mean of sds):\n")
sc <- rbindlist(scale_stats[!vapply(scale_stats, is.null, logical(1))])
print(sc[, lapply(.SD, function(x) round(x, 2)),
         .SDcols = c("D_mean", "Y_mean", "Z_mean", "D_sd", "Y_sd", "Z_sd"),
         by = .(nl_type, nl_strength, nl_Y, rho_Z, TT)])

cat("\n3. Discarded reps (explosive series):\n")
print(disc_dt)
if (any(discarded_counts > N_REPS * 0.1)) {
  cat("  WARNING: >10% discarded in some scenarios!\n")
}
if (any(discarded_counts > N_REPS * 0.5)) {
  cat("  CRITICAL: >50% discarded — scenario marked as UNSTABLE\n")
}

cat("\n4. T=10 vs T=30 Nickell cost comparison:\n")
nick_comp <- summ[nl_strength == 0, .(rho_Z, TT,
  Nickell_cost = round(abs(adl_all_bias) - abs(adl_all_nofe_bias), 4),
  ADL_all_bias = round(adl_all_bias, 4),
  ADL_noFE_bias = round(adl_all_nofe_bias, 4))]
print(nick_comp)

# ---- Save ----
fwrite(summ, "results/sim_nl_collider_results.csv")
fwrite(results, "results/sim_nl_collider_raw.csv")

timing <- data.table(grid[, .(nl_type, nl_strength, nl_Y, rho_Z, TT)],
                     n_discarded = discarded_counts,
                     total_s = total_elapsed)
fwrite(timing, "results/sim_nl_collider_timing.csv")

cat(sprintf("\nResults saved to sim_nl_collider_results.csv (%d rows)\n", nrow(summ)))
cat(sprintf("Raw saved to sim_nl_collider_raw.csv (%d rows)\n", nrow(results)))
cat(sprintf("Timing saved (total %.1fs)\n", total_elapsed))

writeLines(capture.output(sessionInfo()),
           "results/sim_nl_collider_sessioninfo.txt")
