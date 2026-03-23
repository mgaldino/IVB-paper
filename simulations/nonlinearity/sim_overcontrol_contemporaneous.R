# ============================================================================
# sim_overcontrol_contemporaneous.R
# Validate contemporaneous over-control with a pure mediator:
#   D_t -> Z_t -> Y_t, without Y_t -> Z_t.
#
# Goals:
#   1. Linear benchmark: verify that including contemporaneous Z_t recovers
#      the direct effect and therefore subtracts the indirect effect.
#   2. Nonlinear extension: verify that the same qualitative pattern survives
#      when D -> Z is nonlinear.
#   3. TSCS timing check: show that replacing contemporaneous Z_t with Z_{t-1}
#      avoids contemporaneous over-control in ADL specifications.
# ============================================================================

library(data.table)
library(fixest)
library(future.apply)

options(scipen = 999)
set.seed(20260322)

# ---- Fixed parameters ----
P <- list(
  N = 100L,
  TT = 30L,
  T_burn = 100L,
  beta = 1.0,      # direct effect D_t -> Y_t
  theta = 0.5,     # mediator effect Z_t -> Y_t
  rho_D = 0.5,
  rho_Y = 0.5,
  delta_D = 0.4,   # linear D_t -> Z_t channel
  sigma_aZ = 0.5
)
N_REPS <- as.integer(Sys.getenv("IVB_N_REPS", unset = "500"))
N_WORKERS <- as.integer(Sys.getenv("IVB_N_WORKERS", unset = "4"))

# ---- Pilot calibration: within-SD of D under the linear baseline ----
run_pilot_sd_d <- function(P, n_pilot = 10L) {
  vals <- numeric(n_pilot)

  for (s in seq_len(n_pilot)) {
    T_sim <- P$TT + P$T_burn
    alpha_D <- rnorm(P$N, 0, 1)
    rows <- vector("list", P$N)

    for (i in seq_len(P$N)) {
      D <- numeric(T_sim)
      D[1] <- alpha_D[i] + rnorm(1)

      for (t in 2:T_sim) {
        D[t] <- alpha_D[i] + P$rho_D * D[t - 1] + rnorm(1)
      }

      idx <- (P$T_burn + 1):T_sim
      rows[[i]] <- data.table(id = i, D = D[idx])
    }

    dt <- rbindlist(rows)
    dt[, D_mean := mean(D), by = id]
    dt[, D_within := D - D_mean]
    vals[s] <- sd(dt$D_within)
  }

  mean(vals)
}

sd_D_within <- run_pilot_sd_d(P)
c_soft <- 2 * sd_D_within
c_tanh <- 1.5 * sd_D_within

cat(sprintf("Pilot: sd(D_within)=%.4f, c_soft=%.4f, c_tanh=%.4f\n\n",
            sd_D_within, c_soft, c_tanh))

# ---- DGP ----
sim_overcontrol <- function(N, TT, T_burn, beta, theta, rho_D, rho_Y,
                            delta_D, rho_Z, sigma_aZ,
                            delta_log2, delta_softpoly2,
                            delta_tanh, delta_Dlog,
                            c_soft, c_tanh) {
  T_sim <- TT + T_burn

  alpha_D <- rnorm(N, 0, 1)
  alpha_Y <- rnorm(N, 0, 1)
  alpha_Z <- rnorm(N, 0, sigma_aZ)

  rows <- vector("list", N)
  explosive <- FALSE

  for (i in seq_len(N)) {
    D <- Y <- Z <- numeric(T_sim)
    D[1] <- alpha_D[i] + rnorm(1)
    Z[1] <- alpha_Z[i] + rnorm(1)
    Y[1] <- alpha_Y[i] + beta * D[1] + theta * Z[1] + rnorm(1)

    for (t in 2:T_sim) {
      u <- rnorm(1)
      nu <- rnorm(1)
      e <- rnorm(1)

      D[t] <- alpha_D[i] + rho_D * D[t - 1] + u

      Z[t] <- alpha_Z[i] +
        delta_D * D[t] +
        delta_log2 * log(1 + D[t]^2) +
        delta_softpoly2 * (D[t]^2 / (1 + (D[t] / c_soft)^2)) +
        delta_tanh * (c_tanh * tanh(D[t] / c_tanh)) +
        delta_Dlog * (D[t] * log(1 + abs(D[t]))) +
        rho_Z * Z[t - 1] + nu

      Y[t] <- alpha_Y[i] + beta * D[t] + theta * Z[t] + rho_Y * Y[t - 1] + e

      if (abs(D[t]) > 1e6 || abs(Y[t]) > 1e6 || abs(Z[t]) > 1e6) {
        explosive <- TRUE
        break
      }
    }

    if (explosive) {
      return(NULL)
    }

    idx <- (T_burn + 1):T_sim
    rows[[i]] <- data.table(
      id = i,
      time = seq_along(idx),
      D = D[idx],
      Y = Y[idx],
      Z = Z[idx],
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

# ---- Estimation ----
est_overcontrol_models <- function(dt) {
  tryCatch({
    m1 <- feols(Y ~ D | id_f + time_f, dt, vcov = "iid")
    m2 <- feols(Y ~ D + Z | id_f + time_f, dt, vcov = "iid")
    m3 <- feols(Y ~ D + Y_lag | id_f + time_f, dt, vcov = "iid")
    m4 <- feols(Y ~ D + D_lag + Y_lag | id_f + time_f, dt, vcov = "iid")
    m5 <- feols(Y ~ D + D_lag + Y_lag + Z | id_f + time_f, dt, vcov = "iid")
    m6 <- feols(Y ~ D + D_lag + Y_lag + Z_lag | id_f + time_f, dt, vcov = "iid")
    m7 <- feols(Y ~ D + D_lag + Y_lag + Z + Z_lag | id_f + time_f, dt, vcov = "iid")

    aux_twfe <- feols(Z ~ D | id_f + time_f, dt, vcov = "iid")
    aux_adl <- feols(Z ~ D + D_lag + Y_lag | id_f + time_f, dt, vcov = "iid")

    c(
      twfe_s = unname(coef(m1)["D"]),
      twfe_bad = unname(coef(m2)["D"]),
      adl_Ylag = unname(coef(m3)["D"]),
      adl_total = unname(coef(m4)["D"]),
      adl_bad = unname(coef(m5)["D"]),
      adl_safe = unname(coef(m6)["D"]),
      adl_both = unname(coef(m7)["D"]),
      theta_twfe_bad = unname(coef(m2)["Z"]),
      theta_adl_bad = unname(coef(m5)["Z"]),
      pi_twfe = unname(coef(aux_twfe)["D"]),
      pi_adl = unname(coef(aux_adl)["D"]),
      ivb_twfe_formula = -unname(coef(m2)["Z"]) * unname(coef(aux_twfe)["D"]),
      ivb_adl_formula = -unname(coef(m5)["Z"]) * unname(coef(aux_adl)["D"]),
      ivb_twfe_diff = unname(coef(m2)["D"]) - unname(coef(m1)["D"]),
      ivb_adl_diff = unname(coef(m5)["D"]) - unname(coef(m4)["D"])
    )
  }, error = function(e) {
    warning(sprintf("estimation failed: %s", e$message))
    NULL
  })
}

# ---- Grid ----
grid_linear <- CJ(
  nl_type = "linear",
  nl_strength = 0,
  rho_Z = c(0.3, 0.7)
)

grid_nl <- rbind(
  CJ(nl_type = "log2", nl_strength = c(0.5, 1.0, 2.0), rho_Z = c(0.3, 0.7)),
  CJ(nl_type = "softpoly2", nl_strength = c(0.5, 1.0, 2.0), rho_Z = c(0.3, 0.7)),
  CJ(nl_type = "tanh", nl_strength = c(0.5, 1.0, 2.0), rho_Z = c(0.3, 0.7)),
  CJ(nl_type = "Dlog", nl_strength = c(0.5, 1.0, 2.0), rho_Z = c(0.3, 0.7))
)

grid <- rbind(grid_linear, grid_nl)

softpoly2_adj <- 1 + (sd_D_within / c_soft)^2

grid[, delta_log2 := fifelse(nl_type == "log2",
                             nl_strength * P$delta_D * sd_D_within /
                               log(1 + sd_D_within^2), 0)]
grid[, delta_softpoly2 := fifelse(nl_type == "softpoly2",
                                  nl_strength * P$delta_D * softpoly2_adj /
                                    sd_D_within, 0)]
grid[, delta_tanh := fifelse(nl_type == "tanh",
                             nl_strength * P$delta_D * sd_D_within /
                               (c_tanh * tanh(sd_D_within / c_tanh)), 0)]
grid[, delta_Dlog := fifelse(nl_type == "Dlog",
                             nl_strength * P$delta_D / log(1 + sd_D_within), 0)]

cat(sprintf("Grid: %d scenarios x %d reps\n", nrow(grid), N_REPS))
print(grid)
cat("\n")

run_scenario <- function(g) {
  nlt <- grid$nl_type[g]
  nls <- grid$nl_strength[g]
  rz <- grid$rho_Z[g]

  cat(sprintf("Scenario %02d/%02d: %s strength=%.1f rho_Z=%.1f\n",
              g, nrow(grid), nlt, nls, rz))

  out <- rbindlist(lapply(seq_len(N_REPS), function(s) {
    dt <- sim_overcontrol(
      N = P$N,
      TT = P$TT,
      T_burn = P$T_burn,
      beta = P$beta,
      theta = P$theta,
      rho_D = P$rho_D,
      rho_Y = P$rho_Y,
      delta_D = P$delta_D,
      rho_Z = rz,
      sigma_aZ = P$sigma_aZ,
      delta_log2 = grid$delta_log2[g],
      delta_softpoly2 = grid$delta_softpoly2[g],
      delta_tanh = grid$delta_tanh[g],
      delta_Dlog = grid$delta_Dlog[g],
      c_soft = c_soft,
      c_tanh = c_tanh
    )

    est <- est_overcontrol_models(dt)
    if (is.null(est)) {
      return(NULL)
    }

    as.data.table(as.list(est))[, sim := s]
  }), fill = TRUE)

  out[, `:=`(
    nl_type = nlt,
    nl_strength = nls,
    rho_Z = rz
  )]
  out
}

start_time <- Sys.time()
if (N_WORKERS <= 1L) {
  plan(sequential)
} else {
  plan(multisession, workers = N_WORKERS)
}

raw_list <- future_lapply(seq_len(nrow(grid)), run_scenario, future.seed = TRUE)
raw <- rbindlist(raw_list, fill = TRUE)

plan(sequential)
end_time <- Sys.time()

true_direct <- P$beta
true_total_linear <- P$beta + P$theta * P$delta_D

coef_cols <- c(
  "twfe_s", "twfe_bad", "adl_Ylag", "adl_total",
  "adl_bad", "adl_safe", "adl_both"
)

summ <- raw[, {
  out <- list()

  for (nm in coef_cols) {
    vals <- get(nm)
    out[[paste0(nm, "_mean")]] <- mean(vals)
    out[[paste0(nm, "_mcse")]] <- sd(vals) / sqrt(.N)
  }

  out$ivb_twfe_diff_mean <- mean(ivb_twfe_diff)
  out$ivb_twfe_formula_mean <- mean(ivb_twfe_formula)
  out$ivb_twfe_formula_gap <- mean(abs(ivb_twfe_diff - ivb_twfe_formula))
  out$ivb_adl_diff_mean <- mean(ivb_adl_diff)
  out$ivb_adl_formula_mean <- mean(ivb_adl_formula)
  out$ivb_adl_formula_gap <- mean(abs(ivb_adl_diff - ivb_adl_formula))
  out$n_sims <- .N
  out
}, by = .(nl_type, nl_strength, rho_Z)]

summ[, `:=`(
  twfe_s_bias_vs_total = twfe_s_mean - true_total_linear,
  twfe_bad_bias_vs_direct = twfe_bad_mean - true_direct,
  adl_total_bias_vs_total = adl_total_mean - true_total_linear,
  adl_bad_bias_vs_direct = adl_bad_mean - true_direct,
  adl_safe_bias_vs_total = adl_safe_mean - true_total_linear,
  overcontrol_twfe = twfe_bad_mean - twfe_s_mean,
  overcontrol_adl = adl_bad_mean - adl_total_mean,
  safe_shift_adl = adl_safe_mean - adl_total_mean
)]

results_dir <- file.path("simulations", "nonlinearity", "results")
dir.create(results_dir, recursive = TRUE, showWarnings = FALSE)

fwrite(raw, file.path(results_dir, "sim_overcontrol_contemporaneous_raw.csv"))
fwrite(summ, file.path(results_dir, "sim_overcontrol_contemporaneous_results.csv"))
fwrite(
  data.table(
    started_at = as.character(start_time),
    finished_at = as.character(end_time),
    elapsed_minutes = as.numeric(difftime(end_time, start_time, units = "mins"))
  ),
  file.path(results_dir, "sim_overcontrol_contemporaneous_timing.csv")
)
writeLines(capture.output(sessionInfo()),
           file.path(results_dir, "sim_overcontrol_contemporaneous_sessioninfo.txt"))

cat(rep("=", 80), "\n", sep = "")
cat("RESULTS: CONTEMPORANEOUS OVER-CONTROL\n")
cat(rep("=", 80), "\n\n", sep = "")
cat(sprintf("True direct effect: %.3f\n", true_direct))
cat(sprintf("True linear total effect: %.3f\n\n", true_total_linear))

print(summ[, .(
  nl_type, nl_strength, rho_Z,
  twfe_s_mean = round(twfe_s_mean, 4),
  twfe_bad_mean = round(twfe_bad_mean, 4),
  adl_total_mean = round(adl_total_mean, 4),
  adl_bad_mean = round(adl_bad_mean, 4),
  adl_safe_mean = round(adl_safe_mean, 4),
  overcontrol_twfe = round(overcontrol_twfe, 4),
  overcontrol_adl = round(overcontrol_adl, 4),
  safe_shift_adl = round(safe_shift_adl, 4),
  ivb_adl_formula_gap = signif(ivb_adl_formula_gap, 3)
)])
