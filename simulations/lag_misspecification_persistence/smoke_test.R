#!/usr/bin/env Rscript

options(scipen = 999)

file_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(file_arg) != 1L) stop("Cannot determine smoke-test path.", call. = FALSE)
test_path <- normalizePath(sub("^--file=", "", file_arg), mustWork = TRUE)
package_root <- dirname(test_path)

source(file.path(package_root, "R", "config.R"))
source(file.path(package_root, "R", "dgp.R"))
source(file.path(package_root, "R", "estimators.R"))
source(file.path(package_root, "R", "simulation.R"))
source(file.path(package_root, "R", "metrics.R"))

assert_true <- function(condition, message) {
  if (!isTRUE(condition)) stop("SMOKE TEST FAIL: ", message, call. = FALSE)
  message("PASS: ", message)
}

lmp_check_packages()
assert_true(requireNamespace("fixest", quietly = TRUE), "fixest is available for coefficient reference checks")
parameters <- lmp_parameters()
grid <- lmp_full_grid(parameters)
validation <- lmp_validate_grid(grid, parameters)
assert_true(all(validation$passed), "the exact 27-scenario grid and transition invariants pass")

scenario_indices <- vapply(1:3, function(p) {
  which(
    grid$true_lag_order == p & grid$rho_D == 0.5 & grid$carryover == 0.25
  )[1L]
}, integer(1))
smoke_raw <- vector("list", 3L)

for (position in seq_along(scenario_indices)) {
  scenario <- grid[scenario_indices[position]]
  seed <- lmp_seed(parameters$base_seed, scenario$scenario_number, 1L)
  panel_1 <- lmp_simulate_panel(scenario, parameters, seed)
  panel_2 <- lmp_simulate_panel(scenario, parameters, seed)
  assert_true(
    identical(panel_1, panel_2),
    sprintf("ADL(%d) DGP is bitwise deterministic", scenario$true_lag_order)
  )
  assert_true(
    nrow(panel_1) == scenario$N * scenario$T && all(table(panel_1$id) == scenario$T),
    sprintf("ADL(%d) panel is balanced with literal T", scenario$true_lag_order)
  )
  assert_true(
    !anyNA(panel_1) && all(is.finite(as.matrix(dplyr::select(
      panel_1,
      dplyr::all_of(c("D", "Y", "Z", "Z_lag", "D_lag_1", "D_lag_2", "D_lag_3", "Y_lag_1", "Y_lag_2", "Y_lag_3"))
    )))),
    sprintf("ADL(%d) DGP has finite observed and lagged variables", scenario$true_lag_order)
  )
  prepared <- lmp_prepare_within(data.table::copy(panel_1), parameters)
  reference <- fixest::feols(
    Y ~ D + Y_lag_1 + Y_lag_2 + D_lag_1 + D_lag_2 + Z_lag | id + time,
    data = panel_1,
    vcov = ~id
  )
  custom <- lmp_fit_within(prepared, lag_order = 2L, control_spec = "Z_lag")
  assert_true(
    abs(custom$beta_hat - stats::coef(reference)["D"]) < 1e-10,
    sprintf("custom ADL(2) coefficient matches fixest for true ADL(%d)", scenario$true_lag_order)
  )
  replication_1 <- lmp_run_replication(scenario, 1L, parameters)
  replication_2 <- lmp_run_replication(scenario, 1L, parameters)
  assert_true(
    identical(replication_1, replication_2),
    sprintf("all estimators are deterministic for true ADL(%d)", scenario$true_lag_order)
  )
  assert_true(
    nrow(replication_1) == 15L && identical(names(replication_1), lmp_expected_raw_columns()),
    sprintf("all five lag rules and three Z specifications are retained for true ADL(%d)", scenario$true_lag_order)
  )
  assert_true(
    all(replication_1$status == "ok"),
    sprintf("bounded estimator run has no failures for true ADL(%d)", scenario$true_lag_order)
  )
  assert_true(
    all(replication_1$selected_lag[replication_1$estimator_id %in% c("adl_aic", "adl_bic")] %in% 1:3),
    sprintf("AIC and BIC select an admissible lag for true ADL(%d)", scenario$true_lag_order)
  )
  assert_true(
    all(is.finite(replication_1$residual_acf1)) &&
      all(is.finite(replication_1$delta_z_lag_minus_none)) &&
      all(is.finite(replication_1$delta_z_contemporaneous_minus_none)),
    sprintf("residual autocorrelation and both Z shifts are recorded for true ADL(%d)", scenario$true_lag_order)
  )
  assert_true(
    all(replication_1$coverage_cet %in% c(TRUE, FALSE)),
    sprintf("CET coverage indicators are present for true ADL(%d)", scenario$true_lag_order)
  )
  smoke_raw[[position]] <- replication_1
}

combined_raw <- data.table::rbindlist(smoke_raw, use.names = TRUE)
combined_grid <- grid[scenario_indices]
combined_validation <- lmp_output_validation(combined_raw, combined_grid, repetitions = 1L)
assert_true(all(combined_validation$passed), "bounded raw output satisfies schema, key, seed, and value invariants")

temporary_csv <- tempfile(fileext = ".csv")
data.table::fwrite(combined_raw, temporary_csv)
round_trip <- data.table::fread(temporary_csv)
unlink(temporary_csv)
assert_true(nrow(round_trip) == nrow(combined_raw), "raw CSV round trip preserves every retained row")

base_grid <- data.table::rbindlist(lapply(1:3, function(p) data.table::data.table(
  scenario_id = sprintf("BASE_L%d", p),
  scenario_number = 100L + p,
  true_lag_order = p,
  rho_D = 0.5,
  carryover = 0.25,
  N = parameters$base_validation_N,
  T = parameters$base_validation_T
)))
base_radii <- vapply(
  seq_len(nrow(base_grid)),
  function(index) lmp_transition_radius(base_grid[index], parameters),
  numeric(1)
)
assert_true(all(base_radii < 1), "all large-sample base DGPs satisfy the stability invariant")
base_raw <- lmp_run_grid(
  base_grid,
  repetitions = parameters$base_validation_repetitions,
  parameters = parameters,
  progress = FALSE
)
base_selection <- lmp_selection_summary(base_raw, parameters$base_validation_repetitions)
aic_base <- base_selection[selection_criterion == "AIC"][order(true_lag_order)]
aic_probability_columns <- c(
  "selected_lag_1_rate", "selected_lag_2_rate", "selected_lag_3_rate"
)
aic_probabilities <- as.matrix(dplyr::select(
  as.data.frame(aic_base),
  dplyr::all_of(aic_probability_columns)
))
assert_true(
  all(base_selection[selection_criterion == "BIC", recovery_rate] >= parameters$base_validation_min_recovery),
  sprintf(
    "BIC recovers the correct true lag in every pre-specified base case at least %.0f%% of the time",
    100 * parameters$base_validation_min_recovery
  )
)
assert_true(
  all(aic_base$n_success == parameters$base_validation_repetitions) &&
    all(abs(rowSums(aic_probabilities) - 1) < 1e-12),
  "AIC base-case selection probabilities are retained completely, including any over-selection"
)
message(
  "INFO: Base-case AIC recovery rates (true ADL(1), ADL(2), ADL(3)): ",
  paste(
    sprintf(
      "%.2f",
      aic_base$recovery_rate
    ),
    collapse = ", "
  )
)

runner <- file.path(package_root, "run_lag_misspecification_persistence.R")
ungated_log <- tempfile(fileext = ".txt")
ungated_status <- suppressWarnings(system2(
  "Rscript",
  c(shQuote(runner), "--mode", "full", "--reps", "1"),
  stdout = ungated_log,
  stderr = ungated_log
))
ungated_text <- readLines(ungated_log, warn = FALSE)
unlink(ungated_log)
assert_true(
  ungated_status != 0L && any(grepl("Full grid is gated", ungated_text)),
  "the full-grid runner refuses execution without --approved"
)

message("TASK 14 SMOKE TEST PASS")
