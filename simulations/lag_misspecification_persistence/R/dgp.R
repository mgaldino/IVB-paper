lmp_simulate_panel <- function(scenario, parameters, seed) {
  set.seed(seed, kind = "L'Ecuyer-CMRG")

  N <- as.integer(scenario$N)
  TT <- as.integer(scenario$T)
  p <- as.integer(scenario$true_lag_order)
  burn_in <- as.integer(parameters$burn_in)
  if (burn_in < p) {
    stop("Burn-in must be at least the true ADL order.", call. = FALSE)
  }

  phi <- lmp_true_outcome_lags(p, parameters)
  psi <- lmp_carryover_coefficients(p, scenario$carryover, parameters)
  total_periods <- burn_in + TT
  alpha_D <- stats::rnorm(N, 0, parameters$sigma_alpha_D)
  alpha_Y <- stats::rnorm(N, 0, parameters$sigma_alpha_Y)
  alpha_Z <- stats::rnorm(N, 0, parameters$sigma_alpha_Z)
  rows <- vector("list", N)

  for (unit in seq_len(N)) {
    D <- Y <- Z <- numeric(total_periods)
    D[seq_len(p)] <- alpha_D[unit] + stats::rnorm(p, 0, parameters$sigma_u)
    Y[seq_len(p)] <- alpha_Y[unit] + stats::rnorm(p, 0, parameters$sigma_e)
    Z[seq_len(p)] <- alpha_Z[unit] + stats::rnorm(p, 0, parameters$sigma_nu)

    for (period in seq.int(p + 1L, total_periods)) {
      D_lags <- D[period - seq_len(p)]
      Y_lags <- Y[period - seq_len(p)]
      D[period] <- alpha_D[unit] +
        parameters$gamma_D * Z[period - 1L] +
        scenario$rho_D * D[period - 1L] +
        stats::rnorm(1L, 0, parameters$sigma_u)
      Y[period] <- alpha_Y[unit] +
        parameters$beta_cet * D[period] +
        sum(psi * D_lags) +
        sum(phi * Y_lags) +
        parameters$gamma_Y * Z[period - 1L] +
        stats::rnorm(1L, 0, parameters$sigma_e)
      Z[period] <- alpha_Z[unit] +
        parameters$delta_D * D[period] +
        parameters$delta_Y * Y[period] +
        parameters$rho_Z * Z[period - 1L] +
        stats::rnorm(1L, 0, parameters$sigma_nu)
    }

    index <- seq.int(burn_in + 1L, total_periods)
    unit_panel <- data.table::data.table(
      id = unit,
      time = seq_len(TT),
      D = D[index],
      Y = Y[index],
      Z = Z[index],
      Z_lag = Z[index - 1L]
    )
    for (lag in seq_len(max(parameters$candidate_lags))) {
      unit_panel[[paste0("D_lag_", lag)]] <- D[index - lag]
      unit_panel[[paste0("Y_lag_", lag)]] <- Y[index - lag]
    }
    rows[[unit]] <- unit_panel
  }

  panel <- data.table::rbindlist(rows, use.names = TRUE)
  numeric_columns <- c(
    "D", "Y", "Z", "Z_lag",
    paste0("D_lag_", parameters$candidate_lags),
    paste0("Y_lag_", parameters$candidate_lags)
  )
  if (nrow(panel) != N * TT) {
    stop("DGP row-count invariant failed.", call. = FALSE)
  }
  if (anyNA(panel) || any(!is.finite(as.matrix(dplyr::select(
    panel,
    dplyr::all_of(numeric_columns)
  ))))) {
    stop("DGP produced missing or non-finite values.", call. = FALSE)
  }
  if (any(table(panel$id) != TT) || any(table(panel$time) != N)) {
    stop("DGP did not produce a balanced panel.", call. = FALSE)
  }
  data.table::setorder(panel, id, time)
  panel
}
