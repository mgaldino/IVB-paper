# ============================================================================
# sim_overcontrol.R
# Over-control bias: including contemporaneous mediator Z_t in regression
#
# DGP (mediator: D -> Z -> Y, NO Y -> Z):
#   D_t = alpha^D_i + [gamma_D Z_{t-1}] + rho_D D_{t-1} + u_t
#   Z_t = alpha^Z_i + delta_D D_t + f_nl(D_t) + rho_Z Z_{t-1} + nu_t
#   Y_t = alpha^Y_i + beta D_t + theta Z_t + [gamma_Y Z_{t-1}] + rho_Y Y_{t-1} + e_t
#
# Key difference from collider sims: Y does NOT cause Z (no delta_Y term).
# Z_t is a mediator: D_t -> Z_t -> Y_t.
# Including Z_t blocks the indirect effect D -> Z -> Y (over-control).
#
# True total effect (linear only) = beta + theta * delta_D (direct + indirect)
# True direct effect = beta
# Under NL, the true total effect is NOT beta + theta*delta_D because the
# marginal effect dZ/dD varies with D. We use the linear baseline's twfe_s
# as empirical benchmark for the total effect under NL.
#
# Including Z_t: researcher estimates ~ beta (direct only) -> over-control
# Including Z_{t-1}: should NOT block contemporaneous indirect effect
#
# Two variants:
#   Pure mediator:         gamma_D = 0, gamma_Y = 0 (Z is not confounder)
#   Mediator + confounder: gamma_D = 0.15, gamma_Y = 0.2 (Z_{t-1} confounds)
#
# NL types: same 8 as sim_nl_collider.R (bounded + unbounded)
# Grid: 2 variants x (1 baseline + 8 NL) x 2 rho_Z = 36 scenarios x 500 reps
# ============================================================================

library(data.table)
library(fixest)
library(future.apply)

set.seed(2026)

# ---- Fixed parameters ----
P <- list(N = 100, TT = 30, T_burn = 100, beta = 1,
          rho_Y = 0.5, rho_D = 0.5,
          delta_D = 0.1, theta = 0.3,
          sigma_aZ = 0.5)
N_REPS <- 500L

# ---- Pilot: calibrate sd(D_within) ----
# Run pilot for BOTH variants and average, to get a single calibration
# constant that is consistent across variants.
cat("PILOT RUN: calibrating sd(D_within)...\n")
pilot_stats <- list()
pilot_variants <- list(
  pure     = list(gamma_D = 0,    gamma_Y = 0),
  confound = list(gamma_D = 0.15, gamma_Y = 0.2)
)

for (vname in names(pilot_variants)) {
  pv <- pilot_variants[[vname]]
  for (rz_pilot in c(0.5, 0.7)) {
    ps <- lapply(1:10, function(s) {
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
          D[t] <- alpha_D[i] + pv$gamma_D * Z[t-1] + P$rho_D * D[t-1] + u
          Z[t] <- alpha_Z[i] + P$delta_D * D[t] + rz_pilot * Z[t-1] + nu
          Y[t] <- alpha_Y[i] + P$beta * D[t] + P$theta * Z[t] +
                  pv$gamma_Y * Z[t-1] + P$rho_Y * Y[t-1] + e
        }
        idx <- (P$T_burn + 1):T_sim
        rows[[i]] <- data.table(id = i, D = D[idx])
      }
      dt <- rbindlist(rows)
      dt[, D_bar := mean(D), by = id]
      sd(dt$D - dt$D_bar)
    })
    key <- paste0(vname, "_rz", rz_pilot)
    pilot_stats[[key]] <- mean(unlist(ps))
  }
}
sd_D_within <- mean(unlist(pilot_stats))
cat(sprintf("  sd(D_within) = %.4f (avg over variants x rho_Z)\n", sd_D_within))
cat(sprintf("  Per-variant: pure_rz0.5=%.4f, pure_rz0.7=%.4f, conf_rz0.5=%.4f, conf_rz0.7=%.4f\n\n",
            pilot_stats[["pure_rz0.5"]], pilot_stats[["pure_rz0.7"]],
            pilot_stats[["confound_rz0.5"]], pilot_stats[["confound_rz0.7"]]))

# ---- Calibration constants ----
c_soft <- 2 * sd_D_within
c_tanh <- 1.5 * sd_D_within
softpoly2_adj <- 1 + (sd_D_within / c_soft)^2

cat(sprintf("  Calibration: c_soft=%.4f, c_tanh=%.4f, softpoly2_adj=%.4f\n\n",
            c_soft, c_tanh, softpoly2_adj))

# ---- DGP function ----
sim_overcontrol <- function(N, TT, T_burn, beta, rho_Y, rho_D,
                            gamma_D, gamma_Y, delta_D, theta,
                            rho_Z, sigma_aZ,
                            delta_D2, delta_log4, delta_softpoly2,
                            delta_power15, c_soft,
                            delta_sin, delta_invlogit, delta_Dlog,
                            delta_tanh, c_tanh) {
  T_sim <- TT + T_burn

  alpha_D <- rnorm(N, 0, 1)
  alpha_Y <- rnorm(N, 0, 1)
  alpha_Z <- rnorm(N, 0, sigma_aZ)

  rows <- vector("list", N)
  explosive <- FALSE

  for (i in 1:N) {
    D <- Y <- Z <- numeric(T_sim)
    D[1] <- alpha_D[i] + rnorm(1)
    Z[1] <- alpha_Z[i] + rnorm(1)
    Y[1] <- alpha_Y[i] + rnorm(1)

    for (t in 2:T_sim) {
      u <- rnorm(1); e <- rnorm(1); nu <- rnorm(1)

      # D_t: optionally depends on Z_{t-1} (confounder channel)
      D[t] <- alpha_D[i] + gamma_D * Z[t-1] + rho_D * D[t-1] + u

      # Z_t: mediator — caused by D_t, NOT by Y_t
      Z[t] <- alpha_Z[i] + delta_D * D[t] +
              delta_D2 * log(1 + D[t]^2) +
              delta_log4 * log(1 + D[t]^4) +
              delta_softpoly2 * (D[t]^2 / (1 + (D[t] / c_soft)^2)) +
              delta_power15 * (sign(D[t]) * abs(D[t])^1.5) +
              delta_sin * sin(D[t]) +
              delta_invlogit * (1 / (1 + exp(-D[t])) - 0.5) +
              delta_Dlog * (D[t] * log(1 + abs(D[t]))) +
              delta_tanh * (c_tanh * tanh(D[t] / c_tanh)) +
              rho_Z * Z[t-1] + nu

      # Y_t: depends on D_t (direct) + Z_t (indirect) + Z_{t-1} (confounder)
      Y[t] <- alpha_Y[i] + beta * D[t] + theta * Z[t] +
              gamma_Y * Z[t-1] + rho_Y * Y[t-1] + e

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

# ---- Model estimation: 10 models ----
# Models with Z (contemporaneous) should show over-control
# Models with Z_lag should NOT show over-control
est_overcontrol_models <- function(dt) {
  tryCatch({
    # Without Z: should recover total effect
    m1  <- feols(Y ~ D | id_f + time_f, dt, vcov = "iid")
    m4  <- feols(Y ~ D + Y_lag | id_f + time_f, dt, vcov = "iid")
    m7  <- feols(Y ~ D + D_lag + Y_lag | id_f + time_f, dt, vcov = "iid")

    # With Z contemporaneous: should recover direct effect -> over-control
    m2  <- feols(Y ~ D + Z | id_f + time_f, dt, vcov = "iid")
    m5  <- feols(Y ~ D + Y_lag + Z | id_f + time_f, dt, vcov = "iid")
    m8  <- feols(Y ~ D + D_lag + Y_lag + Z | id_f + time_f, dt, vcov = "iid")

    # With Z_lag: should NOT block D_t -> Z_t -> Y_t
    m3  <- feols(Y ~ D + Z_lag | id_f + time_f, dt, vcov = "iid")
    m6  <- feols(Y ~ D + Y_lag + Z_lag | id_f + time_f, dt, vcov = "iid")
    m9  <- feols(Y ~ D + D_lag + Y_lag + Z_lag | id_f + time_f, dt, vcov = "iid")
    m10 <- lm(Y ~ D + D_lag + Y_lag + Z_lag, data = dt)

    c(twfe_s        = unname(coef(m1)["D"]),
      twfe_Z        = unname(coef(m2)["D"]),
      twfe_Zlag     = unname(coef(m3)["D"]),
      adl_Ylag      = unname(coef(m4)["D"]),
      adl_Ylag_Z    = unname(coef(m5)["D"]),
      adl_Ylag_Zlag = unname(coef(m6)["D"]),
      adl_DYlag     = unname(coef(m7)["D"]),
      adl_DYlag_Z   = unname(coef(m8)["D"]),
      adl_all       = unname(coef(m9)["D"]),
      adl_all_nofe  = unname(coef(m10)["D"]))
  }, error = function(e) {
    warning(sprintf("est_overcontrol_models failed: %s", e$message))
    NULL
  })
}

# ---- Grid ----
# 2 variants x (1 baseline + 8 NL) x 2 rho_Z = 36 scenarios

variants <- data.table(
  variant = c("pure_mediator", "mediator_confounder"),
  gamma_D = c(0, 0.15),
  gamma_Y = c(0, 0.2)
)

# NL grid (baseline linear + 8 NL types at strength=1)
nl_grid <- rbind(
  data.table(nl_type = "baseline", nl_strength = 0),
  CJ(nl_type = c("log2", "log4", "softpoly2", "power1.5",
                  "sin", "invlogit", "tanh", "Dlog"),
     nl_strength = 1)
)

grid <- CJ(variant_idx = 1:2, nl_idx = 1:nrow(nl_grid), rho_Z = c(0.5, 0.7))
grid[, `:=`(
  variant     = variants$variant[variant_idx],
  gamma_D     = variants$gamma_D[variant_idx],
  gamma_Y     = variants$gamma_Y[variant_idx],
  nl_type     = nl_grid$nl_type[nl_idx],
  nl_strength = nl_grid$nl_strength[nl_idx]
)]

# Compute calibrated NL coefficients
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

cat(sprintf("Grid: %d scenarios x %d reps\n", nrow(grid), N_REPS))
print(grid[, .(variant, nl_type, nl_strength, rho_Z, gamma_D, gamma_Y)])

# ---- Run (parallel over scenarios) ----
cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("SIM OVERCONTROL: mediator D->Z->Y (no Y->Z), linear + 8 NL types\n")
cat(rep("=", 80), "\n\n")
cat(nrow(grid), "scenarios x", N_REPS, "reps (4 workers)\n")
cat(sprintf("DGP: beta=1, theta=0.3, delta_D=0.1, rho_Y=0.5, rho_D=0.5\n"))
cat(sprintf("     True total effect (linear) = beta + theta*delta_D = %.2f\n",
            P$beta + P$theta * P$delta_D))
cat(sprintf("     True direct effect = beta = %.2f\n", P$beta))
cat(sprintf("     NOTE: Under NL, true total effect differs from %.2f\n",
            P$beta + P$theta * P$delta_D))
cat(sprintf("     sd_D_within=%.4f\n\n", sd_D_within))

plan(multisession, workers = 4)

run_scenario <- function(g) {
  var_name <- grid$variant[g]
  gD  <- grid$gamma_D[g]
  gY  <- grid$gamma_Y[g]
  nlt <- grid$nl_type[g]
  nls <- grid$nl_strength[g]
  rz  <- grid$rho_Z[g]
  dD2  <- grid$delta_D2[g]
  dl4  <- grid$delta_log4[g]
  dsp2 <- grid$delta_softpoly2[g]
  dp15 <- grid$delta_power15[g]
  dsin <- grid$delta_sin[g]
  dinv <- grid$delta_invlogit[g]
  dtnh <- grid$delta_tanh[g]
  dDlg <- grid$delta_Dlog[g]

  n_discarded <- 0L
  n_valid <- 0L
  reps_list <- vector("list", N_REPS)

  for (s in 1:N_REPS) {
    dt <- sim_overcontrol(P$N, P$TT, P$T_burn, P$beta, P$rho_Y, P$rho_D,
                          gD, gY, P$delta_D, P$theta,
                          rz, P$sigma_aZ, dD2, dl4, dsp2, dp15, c_soft,
                          dsin, dinv, dDlg, dtnh, c_tanh)
    if (is.null(dt)) {
      n_discarded <- n_discarded + 1L
      next
    }
    est <- est_overcontrol_models(dt)
    if (is.null(est)) {
      n_discarded <- n_discarded + 1L
      next
    }
    reps_list[[s]] <- data.table::as.data.table(as.list(est))[, sim := s]
    n_valid <- n_valid + 1L
  }

  reps_list <- reps_list[!vapply(reps_list, is.null, logical(1))]
  if (length(reps_list) == 0) return(NULL)

  res_g <- data.table::rbindlist(reps_list)
  res_g[, `:=`(variant = var_name, nl_type = nlt, nl_strength = nls,
               rho_Z = rz, gamma_D = gD, gamma_Y = gY,
               n_discarded = n_discarded, n_valid = n_valid)]
  res_g
}

set.seed(2026200)
t0 <- proc.time()

par_out <- future_lapply(1:nrow(grid), run_scenario, future.seed = TRUE)

elapsed <- (proc.time() - t0)[3]
cat(sprintf("\nTotal time: %.1f seconds (%.1f min)\n", elapsed, elapsed / 60))

# ---- Aggregate results ----
all_raw <- rbindlist(par_out[!vapply(par_out, is.null, logical(1))])

# True effects (exact under linearity only)
total_effect_linear <- P$beta + P$theta * P$delta_D   # 1 + 0.3*0.1 = 1.03
direct_effect       <- P$beta                          # 1.0

model_cols <- c("twfe_s", "twfe_Z", "twfe_Zlag",
                "adl_Ylag", "adl_Ylag_Z", "adl_Ylag_Zlag",
                "adl_DYlag", "adl_DYlag_Z", "adl_all", "adl_all_nofe")

# Aggregate: mean coefficients + n_valid/n_discarded per scenario
results <- all_raw[, c(
  lapply(.SD, mean),
  list(n_valid = .N, n_discarded = max(n_discarded))
), .SDcols = model_cols,
  by = .(variant, nl_type, nl_strength, rho_Z, gamma_D, gamma_Y)]

# Bias relative to direct effect (always valid)
for (mc in model_cols) {
  results[, paste0(mc, "_bias_direct") := get(mc) - direct_effect]
}

# Bias relative to linear total effect (valid only for baseline)
for (mc in model_cols) {
  results[, paste0(mc, "_bias_total_linear") := get(mc) - total_effect_linear]
}

# Empirical total effect benchmark: use twfe_s from same variant x rho_Z baseline.
# twfe_s (Y ~ D | FE) without dynamics captures the total contemporaneous effect
# of D including the indirect path D -> Z -> Y, which is the correct benchmark
# for measuring over-control. It does not include Y_lag, so no Nickell bias.
# Under linearity, twfe_s ≈ beta + theta*delta_D (the true total effect).
# Under NL, twfe_s captures the population linear projection of the total effect.
baseline_benchmarks <- results[nl_type == "baseline",
                               .(variant, rho_Z, empirical_total = twfe_s)]
results <- merge(results, baseline_benchmarks, by = c("variant", "rho_Z"), all.x = TRUE)
setorder(results, variant, nl_type, rho_Z)

# Bias relative to empirical benchmark (valid for all scenarios)
for (mc in model_cols) {
  results[, paste0(mc, "_bias_empirical") := get(mc) - empirical_total]
}

# IVB = coef(with Z) - coef(without Z)
results[, ivb_twfe := twfe_Z - twfe_s]
results[, ivb_adl_Ylag := adl_Ylag_Z - adl_Ylag]
results[, ivb_adl_DYlag := adl_DYlag_Z - adl_DYlag]
# Expected IVB under linearity: -theta * pi (where pi ~ delta_D)
results[, expected_ivb_linear := -P$theta * P$delta_D]

# ---- Save ----
fwrite(all_raw,
       "results/sim_overcontrol_raw.csv")
fwrite(results,
       "results/sim_overcontrol_results.csv")
fwrite(grid,
       "results/sim_overcontrol_grid.csv")

# Free memory before sanity checks
rm(all_raw)
gc()

# ---- Sanity checks (also saved to file) ----
sink("results/sim_overcontrol_console.txt", split = TRUE)
cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("SANITY CHECKS\n")
cat(rep("=", 80), "\n\n")

cat(sprintf("True total effect (linear):  %.3f (beta + theta*delta_D)\n", total_effect_linear))
cat(sprintf("True direct effect:          %.3f (beta)\n", direct_effect))
cat(sprintf("Expected IVB (linear):       %.4f (-theta*delta_D = -0.3*0.1)\n\n",
            -P$theta * P$delta_D))

# Check 1: Linear baseline, pure mediator
cat("--- Check 1: Linear baseline, pure mediator ---\n")
baseline_pure <- results[nl_type == "baseline" & variant == "pure_mediator"]
for (i in 1:nrow(baseline_pure)) {
  r <- baseline_pure[i]
  cat(sprintf("  rho_Z=%.1f (n_valid=%d, n_discarded=%d):\n",
              r$rho_Z, r$n_valid, r$n_discarded))
  cat(sprintf("    twfe_s (no Z):   %.4f  (expected ~%.3f total)\n",
              r$twfe_s, total_effect_linear))
  cat(sprintf("    twfe_Z (with Z): %.4f  (expected ~%.3f direct)\n",
              r$twfe_Z, direct_effect))
  cat(sprintf("    IVB_twfe:        %.4f  (expected ~%.4f)\n",
              r$ivb_twfe, -P$theta * P$delta_D))
  cat(sprintf("    adl_all (Z_lag): %.4f  (expected ~%.3f total)\n\n",
              r$adl_all, total_effect_linear))
}

# Check 2: Linear baseline, mediator+confounder
cat("--- Check 2: Linear baseline, mediator+confounder ---\n")
baseline_dual <- results[nl_type == "baseline" & variant == "mediator_confounder"]
for (i in 1:nrow(baseline_dual)) {
  r <- baseline_dual[i]
  cat(sprintf("  rho_Z=%.1f (n_valid=%d, n_discarded=%d):\n",
              r$rho_Z, r$n_valid, r$n_discarded))
  cat(sprintf("    twfe_s (no Z):   %.4f\n", r$twfe_s))
  cat(sprintf("    twfe_Z (with Z): %.4f\n", r$twfe_Z))
  cat(sprintf("    IVB_twfe:        %.4f\n", r$ivb_twfe))
  cat(sprintf("    adl_all (Z_lag): %.4f\n\n", r$adl_all))
}

# Check 3: NL scenarios — models with Z_lag should NOT over-control (both variants)
for (vname in c("pure_mediator", "mediator_confounder")) {
  cat(sprintf("--- Check 3: Z_lag vs Z contemp, NL scenarios, %s ---\n", vname))
  nl_res <- results[nl_strength > 0 & variant == vname]
  if (nrow(nl_res) > 0) {
    cat(sprintf("  Empirical total effect (baseline twfe_s): %.4f / %.4f (rho_Z 0.5/0.7)\n",
                results[nl_type == "baseline" & variant == vname & rho_Z == 0.5, twfe_s],
                results[nl_type == "baseline" & variant == vname & rho_Z == 0.7, twfe_s]))
    cat(sprintf("  Max |bias_empirical| of adl_all (Z_lag):      %.4f\n",
                nl_res[, max(abs(adl_all_bias_empirical))]))
    cat(sprintf("  Max |bias_empirical| of adl_DYlag_Z (Z contemp): %.4f\n",
                nl_res[, max(abs(adl_DYlag_Z_bias_empirical))]))
    cat(sprintf("  Max |IVB| (twfe_Z - twfe_s):                  %.4f\n",
                nl_res[, max(abs(ivb_twfe))]))
    cat(sprintf("  Max n_discarded:                               %d\n\n",
                nl_res[, max(n_discarded)]))
  }
}

# Check 4: Summary table
cat("--- Summary: mean coefs by variant x nl_type ---\n")
summary_tab <- results[, .(
  twfe_s   = mean(twfe_s),
  twfe_Z   = mean(twfe_Z),
  adl_all  = mean(adl_all),
  ivb_twfe = mean(ivb_twfe),
  n_valid  = mean(n_valid),
  n_disc   = mean(n_discarded)
), by = .(variant, nl_type, nl_strength)]
print(summary_tab)

# ---- Session info ----
si <- capture.output(sessionInfo())
writeLines(si, "results/sim_overcontrol_sessioninfo.txt")

cat("\n\nDone. Results saved to simulations/overcontrol/results/\n")
sink()
