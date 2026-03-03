# ============================================================================
# sim_nl_utils.R
# Shared utilities for non-linearity simulations (sim_nl_*.R)
#
# Contents:
#   est_models()  — estimate 9 TWFE/ADL models, return D coefficients
#   run_pilot()   — calibrate sd(D_within) and optionally sd(Y_within)
# ============================================================================

# ---- est_models: 9 linear specifications ----
# Returns named vector of D coefficients, or NULL if estimation fails.
#
# Models:
#  1. twfe_s      Y ~ D               | FE
#  2. twfe_l      Y ~ D + Z_lag       | FE
#  3. adl_Ylag    Y ~ D + Y_lag       | FE
#  4. adl_full    Y ~ D + Z_lag+Y_lag | FE
#  5. adl_Dlag    Y ~ D + D_lag       | FE
#  6. adl_DYlag   Y ~ D + D_lag+Y_lag | FE
#  7. adl_DZlag   Y ~ D + D_lag+Z_lag | FE
#  8. adl_all     Y ~ D + D_lag+Y_lag+Z_lag | FE
#  9. adl_all_nofe Y ~ D + D_lag+Y_lag+Z_lag (no FE)

est_models <- function(dt) {
  tryCatch({
    m1 <- fixest::feols(Y ~ D | id_f + time_f, dt, vcov = "iid")
    m2 <- fixest::feols(Y ~ D + Z_lag | id_f + time_f, dt, vcov = "iid")
    m3 <- fixest::feols(Y ~ D + Y_lag | id_f + time_f, dt, vcov = "iid")
    m4 <- fixest::feols(Y ~ D + Z_lag + Y_lag | id_f + time_f, dt, vcov = "iid")
    m5 <- fixest::feols(Y ~ D + D_lag | id_f + time_f, dt, vcov = "iid")
    m6 <- fixest::feols(Y ~ D + D_lag + Y_lag | id_f + time_f, dt, vcov = "iid")
    m7 <- fixest::feols(Y ~ D + D_lag + Z_lag | id_f + time_f, dt, vcov = "iid")
    m8 <- fixest::feols(Y ~ D + D_lag + Y_lag + Z_lag | id_f + time_f, dt, vcov = "iid")
    m9 <- lm(Y ~ D + D_lag + Y_lag + Z_lag, data = dt)

    c(twfe_s      = coef(m1)["D"],
      twfe_l      = coef(m2)["D"],
      adl_Ylag    = coef(m3)["D"],
      adl_full    = coef(m4)["D"],
      adl_Dlag    = coef(m5)["D"],
      adl_DYlag   = coef(m6)["D"],
      adl_DZlag   = coef(m7)["D"],
      adl_all     = coef(m8)["D"],
      adl_all_nofe = coef(m9)["D"])
  }, error = function(e) {
    warning(sprintf("est_models failed: %s", e$message))
    NULL
  })
}

# ---- run_pilot: calibrate within-unit standard deviations ----
# Runs a short pilot (10 reps) with the linear baseline DGP for each rho_Z
# in {0.5, 0.7} and averages. Returns list(sd_D, sd_Y).
#
# Arguments:
#   P         — list of fixed parameters (N, TT, T_burn, beta, rho_Y, rho_D,
#               gamma_D, gamma_Y, delta_D, delta_Y, sigma_aZ)
#   n_pilot   — number of pilot reps per rho_Z (default 10)
#   return_Y  — also return sd(Y_within)? (default TRUE)

run_pilot <- function(P, n_pilot = 10, return_Y = TRUE) {
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
          D[t] <- alpha_D[i] + P$gamma_D * Z[t-1] + P$rho_D * D[t-1] + u
          Y[t] <- alpha_Y[i] + P$beta * D[t] + P$gamma_Y * Z[t-1] + P$rho_Y * Y[t-1] + e
          Z[t] <- alpha_Z[i] + P$delta_D * D[t] + P$delta_Y * Y[t] + rz_pilot * Z[t-1] + nu
        }
        idx <- (P$T_burn + 1):T_sim
        if (return_Y) {
          rows[[i]] <- data.table::data.table(id = i, D = D[idx], Y = Y[idx])
        } else {
          rows[[i]] <- data.table::data.table(id = i, D = D[idx])
        }
      }
      dt <- data.table::rbindlist(rows)
      dt[, D_mean := mean(D), by = id]
      dt[, D_within := D - D_mean]
      out <- list(sd_D = sd(dt$D_within))
      if (return_Y) {
        dt[, Y_mean := mean(Y), by = id]
        dt[, Y_within := Y - Y_mean]
        out$sd_Y <- sd(dt$Y_within)
      }
      out
    })

    entry <- list(sd_D = mean(sapply(ps, `[[`, "sd_D")))
    if (return_Y) entry$sd_Y <- mean(sapply(ps, `[[`, "sd_Y"))
    pilot_stats[[length(pilot_stats) + 1]] <- entry
  }

  result <- list(sd_D = mean(sapply(pilot_stats, `[[`, "sd_D")))
  if (return_Y) result$sd_Y <- mean(sapply(pilot_stats, `[[`, "sd_Y"))
  result
}
