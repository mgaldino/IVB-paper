# ============================================================================
# sim_staggered_posttreat.R
# ADL with staggered binary treatment: is Y_lag post-treatment?
#
# DGP:
#   D_it = 1{t >= T_i*}   (binary absorbing treatment, staggered adoption)
#   Y_t = alpha^Y_i + beta D_t + gamma_Y Z_{t-1} + rho_Y Y_{t-1} + e_t
#   Z_t = alpha^Z_i + delta_D D_t + delta_Y Y_t + rho_Z Z_{t-1} + nu_t
#
# T_i* = treatment onset time, drawn uniformly from [T_start, T_end]
# A fraction prob_never are never-treated (control group)
#
# Key question: When D is absorbing, Y_{t-1} for treated units contains
# treatment effects from D_{t-1}=1. Including Y_lag in ADL conditions on
# a post-treatment variable. Does this bias beta_hat?
#
# Comparison: standard TSCS DGP (continuous D, non-absorbing) as control
#
# Grid: prob_never x rho_Y x delta_Y = 24 scenarios x 500 reps
# ============================================================================

library(data.table)
library(fixest)
library(future.apply)

source("../utils/sim_nl_utils.R")  # est_models()

set.seed(2026)

# ---- DGP: staggered binary absorbing treatment ----
sim_staggered <- function(N, TT, T_burn, beta, rho_Y,
                           gamma_Y, delta_D, delta_Y,
                           rho_Z, sigma_aZ,
                           prob_never, T_start_frac, T_end_frac) {
  T_sim <- TT + T_burn

  alpha_Y <- rnorm(N, 0, 1)
  alpha_Z <- rnorm(N, 0, sigma_aZ)

  # Treatment timing: never-treated or staggered
  T_start <- T_burn + round(T_start_frac * TT)  # earliest treatment in obs period
  T_end   <- T_burn + round(T_end_frac * TT)    # latest treatment onset

  is_never <- rbinom(N, 1, prob_never) == 1
  T_star <- rep(NA_integer_, N)
  T_star[!is_never] <- sample(T_start:T_end, sum(!is_never), replace = TRUE)

  rows <- vector("list", N)

  for (i in 1:N) {
    D <- Y <- Z <- numeric(T_sim)
    D[1] <- 0
    Y[1] <- alpha_Y[i] + rnorm(1)
    Z[1] <- alpha_Z[i] + rnorm(1)

    for (t in 2:T_sim) {
      e  <- rnorm(1)
      nu <- rnorm(1)

      # Binary absorbing treatment
      D[t] <- if (!is_never[i] && t >= T_star[i]) 1 else 0

      Y[t] <- alpha_Y[i] + beta * D[t] + gamma_Y * Z[t - 1] +
              rho_Y * Y[t - 1] + e
      Z[t] <- alpha_Z[i] + delta_D * D[t] + delta_Y * Y[t] +
              rho_Z * Z[t - 1] + nu
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
P <- list(N = 200, TT = 30, T_burn = 100, beta = 1,
          gamma_Y = 0.2, delta_D = 0.1,
          sigma_aZ = 0.5,
          T_start_frac = 0.2,   # treatment starts at ~obs period t=6
          T_end_frac   = 0.7)   # last onset at ~obs period t=21
N_REPS <- 500L

# ---- Grid ----
grid <- CJ(
  prob_never = c(0.3, 0.5),
  rho_Y      = c(0, 0.3, 0.5),
  delta_Y    = c(0, 0.1),
  rho_Z      = c(0.5, 0.7)
)

cat(sprintf("Grid: %d scenarios x %d reps\n", nrow(grid), N_REPS))

# ---- Run ----
cat(rep("=", 71), "\n", sep = "")
cat("SIM: STAGGERED BINARY TREATMENT — Y_lag as post-treatment\n")
cat(rep("=", 71), "\n\n")
cat(nrow(grid), "scenarios x", N_REPS, "reps (4 workers)\n")
cat(sprintf("DGP: beta=1, gamma_Y=0.2, delta_D=0.1, N=%d, T=%d\n",
            P$N, P$TT))
cat(sprintf("     Treatment onset: [%.0f%%, %.0f%%] of obs period\n",
            100 * P$T_start_frac, 100 * P$T_end_frac))
cat("     prob_never: fraction of never-treated units\n")
cat("     rho_Y: AR(1) in Y (0 = static, >0 = dynamic)\n")
cat("     delta_Y in {0, 0.1}: collider on/off\n\n")

plan(multisession, workers = 4)

run_scenario <- function(g) {
  pn  <- grid$prob_never[g]
  ry  <- grid$rho_Y[g]
  dY  <- grid$delta_Y[g]
  rz  <- grid$rho_Z[g]

  n_valid <- 0L
  n_discarded <- 0L
  reps_list <- vector("list", N_REPS)

  for (s in 1:N_REPS) {
    dt <- sim_staggered(P$N, P$TT, P$T_burn, P$beta, ry,
                         P$gamma_Y, P$delta_D, dY,
                         rz, P$sigma_aZ,
                         pn, P$T_start_frac, P$T_end_frac)
    est <- est_models(dt)
    if (is.null(est)) {
      n_discarded <- n_discarded + 1L
      next
    }
    n_valid <- n_valid + 1L
    reps_list[[n_valid]] <- data.table::as.data.table(as.list(est))[, sim := s]
  }

  if (n_valid == 0) return(list(res = NULL, n_discarded = N_REPS))

  reps_list <- reps_list[seq_len(n_valid)]
  res_g <- data.table::rbindlist(reps_list)
  res_g[, `:=`(prob_never = pn, rho_Y = ry, delta_Y = dY, rho_Z = rz)]

  list(res = res_g, n_discarded = n_discarded)
}

set.seed(2026300)
t0_total <- proc.time()

par_out <- future_lapply(1:nrow(grid), run_scenario, future.seed = TRUE)

total_elapsed <- (proc.time() - t0_total)[3]
plan(sequential)

cat(sprintf("\nTotal time: %.1fs (parallel, 4 workers)\n", total_elapsed))

# Unpack
all_res         <- lapply(par_out, `[[`, "res")
n_discarded_vec <- vapply(par_out, `[[`, integer(1), "n_discarded")

for (g in 1:nrow(grid)) {
  cat(sprintf("[%d/%d] pn=%.1f rY=%.1f dY=%.1f rZ=%.1f  disc=%d/%d\n",
              g, nrow(grid), grid$prob_never[g], grid$rho_Y[g],
              grid$delta_Y[g], grid$rho_Z[g],
              n_discarded_vec[g], N_REPS))
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
  }
  out$n_sims <- .N
  out
}, by = .(prob_never, rho_Y, delta_Y, rho_Z)]

# ---- Print ----
cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("RESULTS: STAGGERED BINARY TREATMENT (beta_true = 1)\n")
cat("  Key question: does rho_Y > 0 make Y_lag post-treatment bias worse?\n")
cat(rep("=", 80), "\n\n")

for (rz in c(0.5, 0.7)) {
  cat(sprintf("--- rho_Z = %.2f ---\n\n", rz))
  s <- summ[rho_Z == rz]

  cat("BIAS AS % OF BETA:\n")
  print(s[, .(prob_never, rho_Y, delta_Y,
    `TWFE_s_%`   = round(100 * twfe_s_bias / beta_true, 1),
    `TWFE_l_%`   = round(100 * twfe_l_bias / beta_true, 1),
    `ADL_Ylag_%` = round(100 * adl_Ylag_bias / beta_true, 1),
    `ADL_full_%` = round(100 * adl_full_bias / beta_true, 1),
    `ADL_all_%`  = round(100 * adl_all_bias / beta_true, 1),
    `ADL_noFE_%` = round(100 * adl_all_nofe_bias / beta_true, 1))])

  cat("\nEFFECT OF rho_Y ON ADL_all (does post-treatment Y_lag hurt?):\n")
  print(s[, .(prob_never, rho_Y, delta_Y,
    `ADL_all_%` = round(100 * adl_all_bias / beta_true, 1))])
  cat("\n")
}

cat("\nKEY COMPARISON: rho_Y=0 (static, Y_lag irrelevant) vs rho_Y=0.5 (dynamic):\n")
s0 <- summ[rho_Y == 0, .(prob_never, delta_Y, rho_Z, bias0 = adl_all_bias)]
s5 <- summ[rho_Y == 0.5, .(prob_never, delta_Y, rho_Z, bias5 = adl_all_bias)]
comp <- merge(s0, s5, by = c("prob_never", "delta_Y", "rho_Z"))
comp[, delta_pct := round(100 * (bias5 - bias0) / beta_true, 1)]
print(comp[, .(prob_never, delta_Y, rho_Z,
  `static_%` = round(100 * bias0 / beta_true, 1),
  `dynamic_%` = round(100 * bias5 / beta_true, 1),
  `delta_pp` = delta_pct)])

# ---- Save ----
fwrite(summ, "results/sim_staggered_posttreat_results.csv")
fwrite(results, "results/sim_staggered_posttreat_raw.csv")

timing <- data.table(grid, n_discarded = n_discarded_vec,
                     total_s = total_elapsed)
fwrite(timing, "results/sim_staggered_posttreat_timing.csv")

cat(sprintf("\nResults saved (%d rows). Total time: %.1fs\n",
            nrow(summ), total_elapsed))

writeLines(capture.output(sessionInfo()),
           "results/sim_staggered_posttreat_sessioninfo.txt")
