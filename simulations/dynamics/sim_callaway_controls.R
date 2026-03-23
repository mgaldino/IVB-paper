# ============================================================================
# sim_callaway_controls.R
# Boundary conditions for ADL: NL in Z->Y + Level-Dependent Trends
#
# Motivation: Callaway et al. identify that TWFE/ADL can fail when:
# (A) The Z->Y relationship is nonlinear (researcher models linearly)
# (B) The evolution of Y(0) depends on the LEVEL of Z, not just changes
#
# These are NOT collider mechanisms — they are functional form and trend
# misspecification. We test whether they interact with the collider structure
# by varying delta_Y in {0, 0.1}:
#   delta_Y = 0:   Z is NOT a collider (pure confounder)
#   delta_Y = 0.1: Z IS a collider (our standard DGP)
# The DIFFERENCE isolates the collider x misspec interaction.
#
# ---- Mechanism A: NL in Z->Y ----
# DGP:
#   D_t = alpha^D_i + gamma_D Z_{t-1} + rho_D D_{t-1} + u_t
#   Y_t = alpha^Y_i + beta D_t + gamma_Y Z_{t-1}
#         + gamma_nl g(Z_{t-1})                           <- NEW
#         + rho_Y Y_{t-1} + e_t
#   Z_t = alpha^Z_i + delta_D D_t + delta_Y Y_t + rho_Z Z_{t-1} + nu_t
#
# g types: softpoly2 (bounded), power1.5 (unbounded), quadratic (Z^2)
# Calibration: gamma_nl = nl_str * gamma_Y * sd_Z / g(sd_Z)
#
# ---- Mechanism B: Level-Dependent Trends ----
# DGP:
#   H_i ~ N(0, 1)  — exogenous, unit-level
#   D_t = alpha^D_i + gamma_D Z_{t-1} + rho_D D_{t-1} + u_t
#   Y_t = alpha^Y_i + beta D_t + gamma_Y Z_{t-1}
#         + lambda H_i (t/T)                              <- NEW
#         + rho_Y Y_{t-1} + e_t
#   Z_t = alpha^Z_i + delta_H H_i + delta_D D_t + delta_Y Y_t
#         + rho_Z Z_{t-1} + nu_t
#
# H_i is exogenous (indep. of D, Y, Z errors).
# delta_H makes units with high H have high Z levels.
# lambda H_i (t_obs/TT) creates level-dependent trends in Y
#   (t_obs = t - T_burn, scales from 0 to 1 over observation period).
# Unit FE in Y absorb alpha_Y_i; H_i's level effect on Z is absorbed
#   indirectly. But H_i x t_obs is NOT absorbed by FE.
#
# Parallelized: future_lapply over scenarios, 4 workers
# Grid: 56 scenarios x 500 reps
# ============================================================================

library(data.table)
library(fixest)
library(future.apply)

source("../utils/sim_nl_utils.R")  # est_models()

set.seed(2026)

# ---- Pilot: calibrate sd_Z_within ----
# Needed for NL calibration in Mechanism A.
# Runs linear baseline DGP, extracts within-unit sd(Z).
run_pilot_Z <- function(P, n_pilot = 10) {
  pilot_stats <- list()

  for (rz_pilot in c(0.5, 0.7)) {
    ps <- lapply(1:n_pilot, function(s) {
      T_sim <- P$TT + P$T_burn
      N <- P$N

      alpha_D <- rnorm(N, 0, 1)
      alpha_Y <- rnorm(N, 0, 1)
      alpha_Z <- rnorm(N, 0, P$sigma_aZ)

      rows <- vector("list", N)
      for (i in 1:N) {
        D <- Y <- Z <- numeric(T_sim)
        D[1] <- alpha_D[i] + rnorm(1)
        Y[1] <- alpha_Y[i] + rnorm(1)
        Z[1] <- alpha_Z[i] + rnorm(1)
        for (t in 2:T_sim) {
          u <- rnorm(1); e <- rnorm(1); nu <- rnorm(1)
          D[t] <- alpha_D[i] + P$gamma_D * Z[t - 1] + P$rho_D * D[t - 1] + u
          Y[t] <- alpha_Y[i] + P$beta * D[t] + P$gamma_Y * Z[t - 1] +
                  P$rho_Y * Y[t - 1] + e
          Z[t] <- alpha_Z[i] + P$delta_D * D[t] + P$delta_Y_base * Y[t] +
                  rz_pilot * Z[t - 1] + nu
        }
        idx <- (P$T_burn + 1):T_sim
        rows[[i]] <- data.table::data.table(id = i, Z = Z[idx])
      }
      dt <- data.table::rbindlist(rows)
      dt[, Z_mean := mean(Z), by = id]
      dt[, Z_within := Z - Z_mean]
      sd(dt$Z_within)
    })

    pilot_stats[[length(pilot_stats) + 1]] <- mean(unlist(ps))
  }

  mean(unlist(pilot_stats))
}

# ---- DGP: Mechanism A (NL in Z->Y) ----
sim_mech_A <- function(N, TT, T_burn, beta, rho_Y, rho_D,
                        gamma_D, gamma_Y, delta_D, delta_Y,
                        rho_Z, sigma_aZ,
                        gamma_nl, nl_type, c_soft_Z) {
  T_sim <- TT + T_burn

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

      # NL term in Z->Y
      nl_term <- 0
      z_prev <- Z[t - 1]
      if (gamma_nl != 0) {
        nl_term <- switch(nl_type,
          softpoly2 = gamma_nl * (z_prev^2 / (1 + (z_prev / c_soft_Z)^2)),
          power1.5  = gamma_nl * (sign(z_prev) * abs(z_prev)^1.5),
          quadratic = gamma_nl * z_prev^2
        )
      }

      Y[t] <- alpha_Y[i] + beta * D[t] + gamma_Y * Z[t - 1] + nl_term +
              rho_Y * Y[t - 1] + e
      Z[t] <- alpha_Z[i] + delta_D * D[t] + delta_Y * Y[t] +
              rho_Z * Z[t - 1] + nu

      if (abs(D[t]) > 1e6 || abs(Y[t]) > 1e6 || abs(Z[t]) > 1e6) {
        return(NULL)
      }
    }

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

# ---- DGP: Mechanism B (Level-Dependent Trends) ----
sim_mech_B <- function(N, TT, T_burn, beta, rho_Y, rho_D,
                        gamma_D, gamma_Y, delta_D, delta_Y,
                        rho_Z, sigma_aZ,
                        lambda, delta_H) {
  T_sim <- TT + T_burn

  alpha_D <- rnorm(N, 0, 1)
  alpha_Y <- rnorm(N, 0, 1)
  alpha_Z <- rnorm(N, 0, sigma_aZ)
  H       <- rnorm(N, 0, 1)  # exogenous unit-level characteristic

  rows <- vector("list", N)

  for (i in 1:N) {
    D <- Y <- Z <- numeric(T_sim)
    D[1] <- alpha_D[i] + rnorm(1)
    Y[1] <- alpha_Y[i] + rnorm(1)
    Z[1] <- alpha_Z[i] + delta_H * H[i] + rnorm(1)

    for (t in 2:T_sim) {
      u <- rnorm(1); e <- rnorm(1); nu <- rnorm(1)

      D[t] <- alpha_D[i] + gamma_D * Z[t - 1] + rho_D * D[t - 1] + u

      # Level-dependent trend: scales over observation period only
      # During burn-in: trend = 0 (no discontinuity at t = T_burn)
      # During observation: t_obs goes from 1 to TT, trend from 1/TT to 1
      t_obs <- max(0, t - T_burn)
      trend_term <- lambda * H[i] * (t_obs / TT)

      Y[t] <- alpha_Y[i] + beta * D[t] + gamma_Y * Z[t - 1] + trend_term +
              rho_Y * Y[t - 1] + e
      Z[t] <- alpha_Z[i] + delta_H * H[i] + delta_D * D[t] + delta_Y * Y[t] +
              rho_Z * Z[t - 1] + nu

      if (abs(D[t]) > 1e6 || abs(Y[t]) > 1e6 || abs(Z[t]) > 1e6) {
        return(NULL)
      }
    }

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

# ---- Fixed parameters ----
P <- list(N = 100, TT = 30, T_burn = 100, beta = 1,
          rho_Y = 0.5, rho_D = 0.5,
          gamma_D = 0.15, gamma_Y = 0.2,
          delta_D = 0.1, delta_Y_base = 0.1,
          sigma_aZ = 0.5)
N_REPS <- 500L

# ---- Pilot for sd_Z_within ----
cat("PILOT RUN: calibrating sd(Z_within)...\n")
sd_Z_within <- run_pilot_Z(P, n_pilot = 10)
cat(sprintf("  sd(Z_within) = %.4f\n\n", sd_Z_within))

# Calibration constants for NL types
c_soft_Z <- 2 * sd_Z_within  # softpoly2 saturation scale
softpoly2_adj_Z <- 1 + (sd_Z_within / c_soft_Z)^2

cat(sprintf("  Calibration: c_soft_Z=%.4f, softpoly2_adj_Z=%.4f\n\n",
            c_soft_Z, softpoly2_adj_Z))

# ---- Grid: Mechanism A (NL in Z->Y) ----
# Baseline rows (nl_str=0): shared across all nl_types
grid_A_base <- CJ(
  mechanism = "A",
  nl_type   = "softpoly2",  # placeholder, nl_str=0 means no NL
  nl_str    = 0,
  lambda    = 0,
  delta_H   = 0,
  delta_Y   = c(0, 0.1),
  rho_Z     = c(0.5, 0.7)
)

# NL scenarios — separate grids because quadratic needs lower nl_str
# (Z^2 is unbounded and causes explosive feedback with collider at higher str)
grid_A_bounded <- CJ(
  mechanism = "A",
  nl_type   = c("softpoly2", "power1.5"),
  nl_str    = c(0.5, 1.0, 2.0),
  lambda    = 0,
  delta_H   = 0,
  delta_Y   = c(0, 0.1),
  rho_Z     = c(0.5, 0.7)
)

grid_A_quad <- CJ(
  mechanism = "A",
  nl_type   = "quadratic",
  nl_str    = c(0.1, 0.2, 0.3),
  lambda    = 0,
  delta_H   = 0,
  delta_Y   = c(0, 0.1),
  rho_Z     = c(0.5, 0.7)
)

grid_A_nl <- rbind(grid_A_bounded, grid_A_quad)

# Compute calibrated gamma_nl coefficients
# Formula: gamma_nl = nl_str * gamma_Y * sd_Z / g(sd_Z)
compute_gamma_nl <- function(nl_type, nl_str, gamma_Y, sd_Z, c_soft) {
  if (nl_str == 0) return(0)
  target <- nl_str * gamma_Y * sd_Z
  g_at_sd <- switch(nl_type,
    softpoly2 = sd_Z^2 / (1 + (sd_Z / c_soft)^2),
    power1.5  = abs(sd_Z)^1.5,
    quadratic = sd_Z^2
  )
  target / g_at_sd
}

grid_A_nl[, gamma_nl := mapply(compute_gamma_nl, nl_type, nl_str,
                                MoreArgs = list(gamma_Y = P$gamma_Y,
                                                sd_Z = sd_Z_within,
                                                c_soft = c_soft_Z))]
grid_A_base[, gamma_nl := 0]

grid_A <- rbind(grid_A_base, grid_A_nl)

# ---- Grid: Mechanism B (Level-Dependent Trends) ----
# delta_H=0 baseline matches Mech A (no H in Z) for cross-mechanism comparison
grid_B_base <- CJ(
  mechanism = "B",
  nl_type   = "none",
  nl_str    = 0,
  lambda    = 0,
  delta_H   = 0,
  delta_Y   = c(0, 0.1),
  rho_Z     = c(0.5, 0.7)
)

# Main grid: H_i active in Z (delta_H=0.5)
grid_B_main <- CJ(
  mechanism = "B",
  nl_type   = "none",
  nl_str    = 0,
  lambda    = c(0, 0.1, 0.3, 0.5),
  delta_H   = 0.5,
  delta_Y   = c(0, 0.1),
  rho_Z     = c(0.5, 0.7)
)

grid_B <- rbind(grid_B_base, grid_B_main)
grid_B[, gamma_nl := 0]

# ---- Combined grid ----
grid <- rbind(grid_A, grid_B)

cat(sprintf("Grid: %d scenarios (%d Mech A + %d Mech B)\n",
            nrow(grid), nrow(grid_A), nrow(grid_B)))

# ---- Run (parallel over scenarios) ----
cat(rep("=", 71), "\n", sep = "")
cat("SIM: CALLAWAY CONTROLS — NL in Z->Y + Level-Dependent Trends\n")
cat(rep("=", 71), "\n\n")
cat(nrow(grid), "scenarios x", N_REPS, "reps (4 workers)\n")
cat("DGP: beta=1, rho_Y=0.5, rho_D=0.5, gamma_D=0.15, gamma_Y=0.2\n")
cat("     delta_D=0.1, N=100, T=30, T_burn=100\n")
cat("     delta_Y in {0, 0.1} — collider on/off control\n")
cat(sprintf("     sd_Z_within=%.4f (from pilot)\n\n", sd_Z_within))

plan(multisession, workers = 4)

run_scenario <- function(g) {
  mech <- grid$mechanism[g]
  dY   <- grid$delta_Y[g]
  rz   <- grid$rho_Z[g]

  n_valid <- 0L
  n_discarded <- 0L
  reps_list <- vector("list", N_REPS)

  for (s in 1:N_REPS) {
    dt <- if (mech == "A") {
      sim_mech_A(P$N, P$TT, P$T_burn, P$beta, P$rho_Y, P$rho_D,
                  P$gamma_D, P$gamma_Y, P$delta_D, dY,
                  rz, P$sigma_aZ,
                  grid$gamma_nl[g], grid$nl_type[g], c_soft_Z)
    } else {
      sim_mech_B(P$N, P$TT, P$T_burn, P$beta, P$rho_Y, P$rho_D,
                  P$gamma_D, P$gamma_Y, P$delta_D, dY,
                  rz, P$sigma_aZ,
                  grid$lambda[g], grid$delta_H[g])
    }

    if (is.null(dt)) {
      n_discarded <- n_discarded + 1L
      next
    }
    est <- est_models(dt)
    if (is.null(est)) {
      n_discarded <- n_discarded + 1L
      next
    }
    n_valid <- n_valid + 1L
    reps_list[[n_valid]] <- data.table::as.data.table(as.list(est))[, sim := s]
  }

  if (n_valid == 0) {
    return(list(res = NULL, n_discarded = N_REPS))
  }

  reps_list <- reps_list[seq_len(n_valid)]
  res_g <- data.table::rbindlist(reps_list)
  res_g[, `:=`(mechanism = mech, nl_type = grid$nl_type[g],
               nl_str = grid$nl_str[g], gamma_nl = grid$gamma_nl[g],
               lambda = grid$lambda[g], delta_H = grid$delta_H[g],
               delta_Y = dY, rho_Z = rz)]

  list(res = res_g, n_discarded = n_discarded)
}

set.seed(2026200)
t0_total <- proc.time()

par_out <- future_lapply(1:nrow(grid), run_scenario, future.seed = TRUE)

total_elapsed <- (proc.time() - t0_total)[3]
plan(sequential)

cat(sprintf("\nTotal time: %.1fs (parallel, 4 workers)\n", total_elapsed))

# Unpack results
all_res         <- lapply(par_out, `[[`, "res")
n_discarded_vec <- vapply(par_out, `[[`, integer(1), "n_discarded")

# Report per-scenario summary
for (g in 1:nrow(grid)) {
  disc_pct <- round(100 * n_discarded_vec[g] / N_REPS, 1)
  cat(sprintf("[%d/%d] mech=%s nl=%s str=%.1f lam=%.1f dY=%.1f rZ=%.1f  disc=%d/%d (%.1f%%)\n",
              g, nrow(grid), grid$mechanism[g], grid$nl_type[g],
              grid$nl_str[g], grid$lambda[g], grid$delta_Y[g], grid$rho_Z[g],
              n_discarded_vec[g], N_REPS, disc_pct))
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
    out[[paste0(mod_names[j], "_mean")]] <- mean(vals)
    out[[paste0(mod_names[j], "_bias")]] <- mean(vals) - beta_true
    out[[paste0(mod_names[j], "_mcse")]] <- sd(vals) / sqrt(.N)
    out[[paste0(mod_names[j], "_rmse")]] <- sqrt(mean((vals - beta_true)^2))
  }
  out$n_sims <- .N
  out
}, by = .(mechanism, nl_type, nl_str, gamma_nl, lambda, delta_H, delta_Y, rho_Z)]

# Add discarded count
disc_dt <- data.table(grid, n_discarded = n_discarded_vec)
summ <- merge(summ, disc_dt,
              by = c("mechanism", "nl_type", "nl_str", "lambda",
                     "delta_H", "delta_Y", "rho_Z", "gamma_nl"),
              all.x = TRUE)

# ---- Print results: Mechanism A ----
cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("MECHANISM A: NL IN Z->Y (bias = estimate - beta_true = 1)\n")
cat(rep("=", 80), "\n\n")

sA <- summ[mechanism == "A"]

cat("BIAS (key models) — by NL type, strength, and collider on/off:\n")
print(sA[, .(nl_type, nl_str, delta_Y, rho_Z, n_sims, n_discarded,
  `TWFE_s`   = round(twfe_s_bias, 4),
  `TWFE_l`   = round(twfe_l_bias, 4),
  `ADL_full` = round(adl_full_bias, 4),
  `ADL_all`  = round(adl_all_bias, 4))])

cat("\nBIAS AS % OF BETA:\n")
print(sA[, .(nl_type, nl_str, delta_Y, rho_Z,
  `TWFE_s_%`   = round(100 * twfe_s_bias / beta_true, 1),
  `ADL_full_%` = round(100 * adl_full_bias / beta_true, 1),
  `ADL_all_%`  = round(100 * adl_all_bias / beta_true, 1))])

cat("\nCOLLIDER x MISSPEC INTERACTION (bias(dY=0.1) - bias(dY=0)):\n")
sA_0  <- sA[delta_Y == 0,   .(nl_type, nl_str, rho_Z, bias0 = adl_all_bias)]
sA_1  <- sA[delta_Y == 0.1, .(nl_type, nl_str, rho_Z, bias1 = adl_all_bias)]
interact_A <- merge(sA_0, sA_1, by = c("nl_type", "nl_str", "rho_Z"))
interact_A[, `:=`(
  interaction = round(bias1 - bias0, 4),
  `inter_%`   = round(100 * (bias1 - bias0) / beta_true, 1)
)]
print(interact_A[, .(nl_type, nl_str, rho_Z, bias0 = round(bias0, 4),
                      bias1 = round(bias1, 4), interaction, `inter_%`)])

# ---- Print results: Mechanism B ----
cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("MECHANISM B: LEVEL-DEPENDENT TRENDS (bias = estimate - beta_true = 1)\n")
cat(rep("=", 80), "\n\n")

sB <- summ[mechanism == "B"]

cat("BIAS (key models) — by lambda and collider on/off:\n")
print(sB[, .(lambda, delta_Y, rho_Z, n_sims, n_discarded,
  `TWFE_s`   = round(twfe_s_bias, 4),
  `TWFE_l`   = round(twfe_l_bias, 4),
  `ADL_full` = round(adl_full_bias, 4),
  `ADL_all`  = round(adl_all_bias, 4))])

cat("\nBIAS AS % OF BETA:\n")
print(sB[, .(lambda, delta_Y, rho_Z,
  `TWFE_s_%`   = round(100 * twfe_s_bias / beta_true, 1),
  `ADL_full_%` = round(100 * adl_full_bias / beta_true, 1),
  `ADL_all_%`  = round(100 * adl_all_bias / beta_true, 1))])

cat("\nY_LAG ABSORPTION (|TWFE_s bias| - |ADL_all bias|, >0 = Y_lag helps):\n")
print(sB[, .(lambda, delta_Y, rho_Z,
  `TWFE_s`      = round(twfe_s_bias, 4),
  `ADL_all`     = round(adl_all_bias, 4),
  `Ylag_benefit` = round(abs(twfe_s_bias) - abs(adl_all_bias), 4))])

cat("\nCOLLIDER x TREND INTERACTION (bias(dY=0.1) - bias(dY=0), delta_H=0.5 only):\n")
sB_dH <- sB[delta_H == 0.5]
sB_0  <- sB_dH[delta_Y == 0,   .(lambda, rho_Z, bias0 = adl_all_bias)]
sB_1  <- sB_dH[delta_Y == 0.1, .(lambda, rho_Z, bias1 = adl_all_bias)]
interact_B <- merge(sB_0, sB_1, by = c("lambda", "rho_Z"))
interact_B[, `:=`(
  interaction = round(bias1 - bias0, 4),
  `inter_%`   = round(100 * (bias1 - bias0) / beta_true, 1)
)]
print(interact_B[, .(lambda, rho_Z, bias0 = round(bias0, 4),
                      bias1 = round(bias1, 4), interaction, `inter_%`)])

# ---- Sanity checks ----
cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("SANITY CHECKS\n")
cat(rep("=", 80), "\n\n")

cat("1. Baseline (nl_str=0, lambda=0, dY=0.1): ADL_all bias <3%?\n")
print(summ[nl_str == 0 & lambda == 0 & delta_Y == 0.1, .(
  mechanism, rho_Z,
  `ADL_all_%` = round(100 * abs(adl_all_bias) / beta_true, 1))])

cat("\n2. Baseline (nl_str=0, lambda=0, dY=0): bias near 0?\n")
print(summ[nl_str == 0 & lambda == 0 & delta_Y == 0, .(
  mechanism, rho_Z,
  `ADL_all_%` = round(100 * abs(adl_all_bias) / beta_true, 1))])

cat("\n3. Discarded reps (explosive series):\n")
disc_report <- data.table(grid[, .(mechanism, nl_type, nl_str, lambda,
                                    delta_Y, rho_Z)],
                           n_discarded = n_discarded_vec)
print(disc_report[n_discarded > 0])
if (all(n_discarded_vec == 0)) cat("  None — all scenarios stable.\n")
if (any(n_discarded_vec > N_REPS * 0.1)) {
  cat("  WARNING: >10% discarded in some scenarios!\n")
}

cat("\n4. Mech A: bias grows with nl_str (ADL_all, dY=0.1, rho_Z=0.5):\n")
print(sA[delta_Y == 0.1 & rho_Z == 0.5, .(nl_type, nl_str,
  `ADL_all_%` = round(100 * adl_all_bias / beta_true, 1))])

cat("\n5. Mech B: bias grows with lambda (ADL_all, dY=0.1, rho_Z=0.5):\n")
print(sB[delta_Y == 0.1 & rho_Z == 0.5, .(lambda,
  `ADL_all_%` = round(100 * adl_all_bias / beta_true, 1))])

# ---- Save ----
fwrite(summ, "results/sim_callaway_controls_results.csv")
fwrite(results, "results/sim_callaway_controls_raw.csv")

timing <- data.table(grid, n_discarded = n_discarded_vec,
                     total_s = total_elapsed)
fwrite(timing, "results/sim_callaway_controls_timing.csv")

cat(sprintf("\nResults saved to results/sim_callaway_controls_results.csv (%d rows)\n",
            nrow(summ)))
cat(sprintf("Raw saved to results/sim_callaway_controls_raw.csv (%d rows)\n",
            nrow(results)))
cat(sprintf("Timing saved (total %.1fs)\n", total_elapsed))

writeLines(capture.output(sessionInfo()),
           "results/sim_callaway_controls_sessioninfo.txt")
