task13_simulate_dual_role <- function(scenario, parameters, seed) {
  set.seed(seed, kind = "L'Ecuyer-CMRG")

  N <- as.integer(scenario$N)
  TT <- as.integer(scenario$T)
  burn_in <- as.integer(parameters$burn_in)
  total_periods <- burn_in + TT

  alpha_D <- stats::rnorm(N, 0, parameters$sigma_alpha_D)
  alpha_Y <- stats::rnorm(N, 0, parameters$sigma_alpha_Y)
  alpha_Z <- stats::rnorm(N, 0, scenario$sigma_alpha_Z)
  beta_i <- if (parameters$sigma_beta > 0) {
    stats::rnorm(N, parameters$beta_cet, parameters$sigma_beta)
  } else {
    rep(parameters$beta_cet, N)
  }

  rows <- vector("list", N)

  for (i in seq_len(N)) {
    D <- Y <- Z <- numeric(total_periods)
    D[1] <- alpha_D[i] + stats::rnorm(1, 0, parameters$sigma_u)
    Y[1] <- alpha_Y[i] + stats::rnorm(1, 0, parameters$sigma_e)
    Z[1] <- alpha_Z[i] + stats::rnorm(1, 0, parameters$sigma_nu)

    for (t in 2:total_periods) {
      u_it <- stats::rnorm(1, 0, parameters$sigma_u)
      e_it <- stats::rnorm(1, 0, parameters$sigma_e)
      nu_it <- stats::rnorm(1, 0, parameters$sigma_nu)

      D[t] <- alpha_D[i] +
        parameters$gamma_D * Z[t - 1L] +
        scenario$rho_D * D[t - 1L] +
        u_it

      Y[t] <- alpha_Y[i] +
        beta_i[i] * D[t] +
        parameters$gamma_Y * Z[t - 1L] +
        scenario$rho_Y * Y[t - 1L] +
        e_it

      Z[t] <- alpha_Z[i] +
        parameters$delta_D * D[t] +
        parameters$delta_Y * Y[t] +
        scenario$rho_Z * Z[t - 1L] +
        nu_it
    }

    # Retain a pre-sample lag from the burn-in so declared T equals the number
    # of estimation periods. The structural DGP and its parameters are unchanged.
    idx <- seq.int(burn_in + 1L, total_periods)
    lag_idx <- idx - 1L

    rows[[i]] <- data.table::data.table(
      id = i,
      time = seq_len(TT),
      D = D[idx],
      Y = Y[idx],
      Z = Z[idx],
      D_lag = D[lag_idx],
      Y_lag = Y[lag_idx],
      Z_lag = Z[lag_idx],
      beta_i = beta_i[i]
    )
  }

  panel <- data.table::rbindlist(rows, use.names = TRUE)

  if (nrow(panel) != N * TT) {
    stop("DGP row-count invariant failed.", call. = FALSE)
  }
  if (anyNA(panel) || any(!is.finite(as.matrix(dplyr::select(
    panel,
    dplyr::all_of(c("D", "Y", "Z", "D_lag", "Y_lag", "Z_lag"))
  ))))) {
    stop("DGP produced missing or non-finite values.", call. = FALSE)
  }
  if (any(table(panel$id) != TT) || any(table(panel$time) != N)) {
    stop("DGP did not produce a balanced panel.", call. = FALSE)
  }

  attr(panel, "beta_target") <- mean(beta_i)
  panel
}

