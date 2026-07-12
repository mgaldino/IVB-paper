lmp_mcse_mean <- function(values) {
  values <- values[is.finite(values)]
  if (length(values) < 2L) return(NA_real_)
  stats::sd(values) / sqrt(length(values))
}

lmp_summarise_results <- function(raw, requested_repetitions) {
  grouping <- c(
    "scenario_id", "scenario_number", "true_lag_order", "rho_D", "carryover",
    "N", "T", "estimator_id", "estimator", "selection_criterion", "control_spec"
  )
  raw[, {
    successful <- status == "ok"
    errors <- beta_hat[successful] - beta_true[successful]
    coverage_values <- coverage_cet[successful]
    acf_values <- residual_acf1[successful]
    list(
      n_requested = requested_repetitions,
      n_attempted = .N,
      n_success = sum(successful),
      n_failed = sum(!successful),
      failure_rate = mean(!successful),
      mean_beta_hat = if (length(errors)) mean(beta_hat[successful]) else NA_real_,
      bias = if (length(errors)) mean(errors) else NA_real_,
      relative_bias = if (length(errors)) mean(errors) / beta_true[successful][1L] else NA_real_,
      rmse = if (length(errors)) sqrt(mean(errors ^ 2)) else NA_real_,
      coverage_cet = if (length(coverage_values)) mean(coverage_values) else NA_real_,
      mean_residual_acf1 = if (length(acf_values)) mean(acf_values, na.rm = TRUE) else NA_real_,
      mcse_bias = lmp_mcse_mean(errors),
      mcse_rmse = if (length(errors) > 1L) {
        squared_error <- errors ^ 2
        stats::sd(squared_error) / sqrt(length(squared_error)) / (2 * sqrt(mean(squared_error)))
      } else {
        NA_real_
      },
      mcse_coverage = if (length(coverage_values)) {
        sqrt(mean(coverage_values) * (1 - mean(coverage_values)) / length(coverage_values))
      } else {
        NA_real_
      },
      mcse_residual_acf1 = lmp_mcse_mean(acf_values)
    )
  }, by = grouping]
}

lmp_selection_summary <- function(raw, requested_repetitions) {
  selected <- raw[
    estimator_id %in% c("adl_aic", "adl_bic") & control_spec == "Z_lag"
  ]
  grouping <- c(
    "scenario_id", "scenario_number", "true_lag_order", "rho_D", "carryover",
    "N", "T", "estimator_id", "estimator", "selection_criterion"
  )
  selected[, {
    successful <- status == "ok"
    chosen <- selected_lag[successful]
    list(
      n_requested = requested_repetitions,
      n_attempted = .N,
      n_success = sum(successful),
      n_failed = sum(!successful),
      recovery_rate = if (length(chosen)) mean(chosen == true_lag_order[1L]) else NA_real_,
      mcse_recovery = if (length(chosen)) {
        rate <- mean(chosen == true_lag_order[1L])
        sqrt(rate * (1 - rate) / length(chosen))
      } else {
        NA_real_
      },
      selected_lag_1_rate = if (length(chosen)) mean(chosen == 1L) else NA_real_,
      selected_lag_2_rate = if (length(chosen)) mean(chosen == 2L) else NA_real_,
      selected_lag_3_rate = if (length(chosen)) mean(chosen == 3L) else NA_real_
    )
  }, by = grouping]
}

lmp_displacement_summary <- function(raw, requested_repetitions) {
  displacement <- raw[control_spec == "Z_lag" & status == "ok"]
  grouping <- c(
    "scenario_id", "scenario_number", "true_lag_order", "rho_D", "carryover",
    "N", "T", "estimator_id", "estimator", "selection_criterion"
  )
  displacement[, {
    lag_values <- delta_z_lag_minus_none[is.finite(delta_z_lag_minus_none)]
    contemporary_values <- delta_z_contemporaneous_minus_none[
      is.finite(delta_z_contemporaneous_minus_none)
    ]
    list(
      n_requested = requested_repetitions,
      n_success = .N,
      mean_delta_z_lag_minus_none = if (length(lag_values)) mean(lag_values) else NA_real_,
      mean_delta_z_contemporaneous_minus_none = if (length(contemporary_values)) {
        mean(contemporary_values)
      } else {
        NA_real_
      },
      mcse_delta_z_lag_minus_none = lmp_mcse_mean(lag_values),
      mcse_delta_z_contemporaneous_minus_none = lmp_mcse_mean(contemporary_values)
    )
  }, by = grouping]
}

lmp_residual_acf_summary <- function(summary) {
  columns <- c(
    "scenario_id", "scenario_number", "true_lag_order", "rho_D", "carryover", "N", "T",
    "estimator_id", "estimator", "selection_criterion", "control_spec",
    "n_success", "mean_residual_acf1", "mcse_residual_acf1"
  )
  data.table::as.data.table(dplyr::select(
    as.data.frame(summary),
    dplyr::all_of(columns)
  ))
}

lmp_failures <- function(raw) {
  raw[status != "ok"]
}

lmp_stability_checks <- function(summary, requested_repetitions) {
  summary[, .(
    scenario_id, estimator_id, control_spec,
    requested_repetitions = requested_repetitions,
    failure_rate = failure_rate,
    mcse_bias = mcse_bias,
    mcse_coverage = mcse_coverage,
    pass_failure_rate = is.na(failure_rate) | failure_rate <= 0.05,
    pass_mcse_bias = is.na(mcse_bias) | mcse_bias <= 0.01,
    pass_mcse_coverage = is.na(mcse_coverage) | mcse_coverage <= 0.015
  )]
}

lmp_output_validation <- function(raw, grid, repetitions) {
  expected_rows <- nrow(grid) * repetitions * 5L * 3L
  seed_map <- unique(raw[, .(scenario_id, replication, seed)])
  successful <- raw[status == "ok"]
  coverage_values <- successful$coverage_cet
  selection_rows <- raw[
    estimator_id %in% c("adl_aic", "adl_bic") & control_spec == "Z_lag" & status == "ok"
  ]
  key_count <- data.table::uniqueN(raw, by = c("scenario_id", "replication", "estimator_id", "control_spec"))
  checks <- c(
    exact_raw_schema = identical(names(raw), lmp_expected_raw_columns()),
    exact_row_count = nrow(raw) == expected_rows,
    unique_replication_keys = key_count == expected_rows,
    scenario_grid_preserved = identical(sort(unique(raw$scenario_id)), sort(grid$scenario_id)),
    seed_map_complete = nrow(seed_map) == nrow(grid) * repetitions,
    seeds_unique = !anyDuplicated(seed_map$seed),
    successful_coefficients_finite = all(is.finite(successful$beta_hat)),
    successful_standard_errors_positive = all(is.finite(successful$se) & successful$se > 0),
    coverage_is_binary = all(is.na(coverage_values) | coverage_values %in% c(TRUE, FALSE)),
    selected_lags_in_candidate_set = all(
      selection_rows$selected_lag %in% 1:3
    ),
    values_match_grid = all(raw$rho_D %in% c(0.2, 0.5, 0.8)) &&
      all(raw$carryover %in% c(0, 0.25, 0.5)) &&
      all(raw$true_lag_order %in% 1:3)
  )
  data.table::data.table(
    check = names(checks),
    passed = unname(checks),
    detail = c(
      "raw columns equal the pre-specified schema",
      sprintf("expected %d rows", expected_rows),
      "scenario-replication-estimator-control keys are unique",
      "all pre-specified scenarios are present",
      "one seed per scenario-replication draw",
      "replication seeds are unique",
      "all successful coefficient estimates are finite",
      "all successful cluster-robust standard errors are positive",
      "coverage entries are logical indicators",
      "AIC/BIC selected lags are in {1,2,3}",
      "true lag order, rho_D, and carryover equal pre-specified values"
    )
  )
}
