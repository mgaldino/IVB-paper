options(scipen = 999)

lmp_required_packages <- function(include_report = FALSE) {
  packages <- c("data.table", "dplyr")
  if (isTRUE(include_report)) {
    packages <- c(packages, "ggplot2", "knitr", "rmarkdown")
  }
  packages
}

lmp_check_packages <- function(include_report = FALSE) {
  packages <- lmp_required_packages(include_report = include_report)
  available <- vapply(packages, requireNamespace, logical(1), quietly = TRUE)
  if (any(!available)) {
    stop(
      "Missing required R packages: ",
      paste(names(available)[!available], collapse = ", "),
      call. = FALSE
    )
  }
  invisible(available)
}

lmp_parameters <- function() {
  list(
    burn_in = 100L,
    beta_cet = 1,
    rho_Y_by_order = list(
      `1` = c(0.50),
      `2` = c(0.35, 0.25),
      `3` = c(0.26, 0.18, 0.12)
    ),
    carryover_decay = 0.5,
    rho_D = 0.5,
    rho_Z = 0.5,
    gamma_D = 0.15,
    gamma_Y = 0.20,
    delta_D = 0.10,
    delta_Y = 0.10,
    sigma_alpha_D = 1,
    sigma_alpha_Y = 1,
    sigma_alpha_Z = 0.5,
    sigma_u = 1,
    sigma_e = 1,
    sigma_nu = 1,
    nominal_coverage = 0.95,
    base_seed = 14072026L,
    default_repetitions = 500L,
    N = 100L,
    T = 30L,
    candidate_lags = 1:3,
    base_validation_N = 300L,
    base_validation_T = 60L,
    base_validation_repetitions = 20L,
    base_validation_min_recovery = 0.80
  )
}

lmp_carryover_coefficients <- function(true_lag_order, carryover, parameters) {
  carryover * (parameters$carryover_decay ^ (seq_len(true_lag_order) - 1L))
}

lmp_true_outcome_lags <- function(true_lag_order, parameters) {
  parameters$rho_Y_by_order[[as.character(true_lag_order)]]
}

lmp_full_grid <- function(parameters = lmp_parameters()) {
  grid <- data.table::CJ(
    true_lag_order = 1:3,
    rho_D = c(0.2, 0.5, 0.8),
    carryover = c(0.0, 0.25, 0.50),
    sorted = TRUE
  )
  grid[, `:=`(
    N = parameters$N,
    T = parameters$T,
    scenario_id = sprintf(
      "L%d_RD%02d_CO%02d",
      true_lag_order,
      round(100 * rho_D),
      round(100 * carryover)
    ),
    scenario_number = seq_len(.N)
  )]
  data.table::setcolorder(
    grid,
    c(
      "scenario_id", "scenario_number", "true_lag_order", "rho_D",
      "carryover", "N", "T"
    )
  )
  grid
}

lmp_transition_radius <- function(scenario, parameters = lmp_parameters()) {
  p <- as.integer(scenario$true_lag_order)
  phi <- lmp_true_outcome_lags(p, parameters)
  psi <- lmp_carryover_coefficients(p, scenario$carryover, parameters)
  state_size <- 3L + 2L * (p - 1L)
  transition <- matrix(0, nrow = state_size, ncol = state_size)

  d_row <- numeric(state_size)
  d_row[1L] <- scenario$rho_D
  d_row[3L] <- parameters$gamma_D

  y_row <- parameters$beta_cet * d_row
  y_row[3L] <- y_row[3L] + parameters$gamma_Y
  for (lag in seq_len(p)) {
    d_col <- if (lag == 1L) 1L else 2L * lag
    y_col <- if (lag == 1L) 2L else 2L * lag + 1L
    y_row[d_col] <- y_row[d_col] + psi[lag]
    y_row[y_col] <- y_row[y_col] + phi[lag]
  }

  z_row <- parameters$delta_D * d_row + parameters$delta_Y * y_row
  z_row[3L] <- z_row[3L] + parameters$rho_Z

  transition[1L, ] <- d_row
  transition[2L, ] <- y_row
  transition[3L, ] <- z_row

  if (p > 1L) {
    for (lag in seq_len(p - 1L)) {
      target_d <- 3L + 2L * (lag - 1L) + 1L
      target_y <- target_d + 1L
      source_d <- if (lag == 1L) 1L else 3L + 2L * (lag - 2L) + 1L
      source_y <- if (lag == 1L) 2L else source_d + 1L
      transition[target_d, source_d] <- 1
      transition[target_y, source_y] <- 1
    }
  }

  max(Mod(eigen(transition, only.values = TRUE)$values))
}

lmp_validate_grid <- function(grid, parameters = lmp_parameters()) {
  radii <- vapply(
    seq_len(nrow(grid)),
    function(index) lmp_transition_radius(grid[index], parameters),
    numeric(1)
  )
  checks <- c(
    scenario_count = nrow(grid) == 27L,
    true_lag_orders = identical(sort(unique(grid$true_lag_order)), 1:3),
    rho_D_values = isTRUE(all.equal(sort(unique(grid$rho_D)), c(0.2, 0.5, 0.8))),
    carryover_values = isTRUE(all.equal(sort(unique(grid$carryover)), c(0, 0.25, 0.5))),
    fixed_N = identical(unique(grid$N), parameters$N),
    fixed_T = identical(unique(grid$T), parameters$T),
    unique_scenario_ids = !anyDuplicated(grid$scenario_id),
    valid_dimensions = all(grid$N > 1L & grid$T >= 8L),
    valid_persistence = all(abs(grid$rho_D) < 1 & abs(parameters$rho_Z) < 1),
    stable_transition = all(is.finite(radii) & radii < 1)
  )
  if (any(!checks)) {
    stop(
      "Task 14 grid validation failed: ",
      paste(names(checks)[!checks], collapse = ", "),
      call. = FALSE
    )
  }
  data.table::data.table(
    check = names(checks),
    passed = unname(checks),
    detail = c(
      "27 = 3 true ADL orders x 3 rho_D values x 3 carryover values",
      "true ADL order = {1,2,3}",
      "rho_D = {0.2,0.5,0.8}",
      "carryover = {0,0.25,0.50}",
      sprintf("N = %d", parameters$N),
      sprintf("T = %d", parameters$T),
      "scenario_id is unique",
      "N > 1 and T >= 8",
      "all persistence parameters are inside (-1,1)",
      sprintf("maximum transition spectral radius = %.6f", max(radii))
    )
  )
}

lmp_seed <- function(base_seed, scenario_number, replication) {
  seed <- as.double(base_seed) + as.double(scenario_number) * 100000 + replication
  if (seed > .Machine$integer.max) {
    stop("Seed exceeds R integer range.", call. = FALSE)
  }
  as.integer(seed)
}

lmp_expected_raw_columns <- function() {
  c(
    "scenario_id", "scenario_number", "true_lag_order", "rho_D", "carryover",
    "N", "T", "replication", "seed", "estimator_id", "estimator",
    "selection_criterion", "selected_lag", "selection_correct", "control_spec",
    "beta_true", "beta_hat", "se", "ci_lower", "ci_upper", "coverage_cet",
    "residual_acf1", "aic", "bic", "nobs", "n_clusters", "condition_number",
    "delta_z_lag_minus_none", "delta_z_contemporaneous_minus_none", "status",
    "error_stage", "error_message"
  )
}
