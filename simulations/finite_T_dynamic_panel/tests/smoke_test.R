#!/usr/bin/env Rscript

options(scipen = 999)

file_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(file_arg) != 1L) {
  stop("Cannot determine smoke-test path.", call. = FALSE)
}
test_path <- normalizePath(sub("^--file=", "", file_arg), mustWork = TRUE)
package_root <- normalizePath(file.path(dirname(test_path), ".."), mustWork = TRUE)

source(file.path(package_root, "R", "config.R"))
source(file.path(package_root, "R", "dgp.R"))
source(file.path(package_root, "R", "estimators.R"))
source(file.path(package_root, "R", "simulation.R"))
source(file.path(package_root, "R", "metrics.R"))

assert_true <- function(condition, message) {
  if (!isTRUE(condition)) {
    stop("SMOKE TEST FAIL: ", message, call. = FALSE)
  }
  message("PASS: ", message)
}

task13_check_packages(include_report = TRUE)
assert_true(requireNamespace("fixest", quietly = TRUE), "fixest is available for reference validation")

parameters <- task13_parameters()
grid <- task13_full_grid(parameters)
validation <- task13_validate_grid(grid, parameters)
assert_true(all(validation$passed), "principal and stress grids match the canonical plan")
assert_true(nrow(grid) == 72L, "full design has exactly 72 scenarios")

scenario <- grid[1L]
seed <- task13_seed(parameters$base_seed, scenario$scenario_number, 1L)
panel_1 <- task13_simulate_dual_role(scenario, parameters, seed)
panel_2 <- task13_simulate_dual_role(scenario, parameters, seed)
assert_true(identical(panel_1, panel_2), "DGP is bitwise deterministic for a fixed replication seed")
assert_true(nrow(panel_1) == scenario$N * scenario$T, "declared T equals estimation periods")
assert_true(!anyNA(panel_1), "DGP contains no missing values")
assert_true(all(table(panel_1$id) == scenario$T), "DGP panel is balanced by unit")

fe_pair <- task13_fit_fe_pair(panel_1)
fixest_reference <- fixest::feols(
  Y ~ D + Y_lag + Z_lag | id + time,
  data = panel_1,
  vcov = ~id
)
coefficient_gap <- abs(fe_pair$long$coefficient_D - stats::coef(fixest_reference)["D"])
assert_true(coefficient_gap < 1e-10, "custom two-way within coefficient matches fixest")
assert_true(is.finite(fe_pair$long$se_D) && fe_pair$long$se_D > 0, "FE-ADL clustered standard error is finite")

hpj_pair <- task13_fit_hpj_pair(panel_1, full_pair = fe_pair)
assert_true(is.finite(hpj_pair$long$coefficient_D), "split-panel jackknife estimate is finite")
assert_true(is.finite(hpj_pair$long$se_D) && hpj_pair$long$se_D > 0, "split-panel jackknife joint clustered standard error is finite")

odd_scenario <- grid[grid$design_family == "principal" & grid$N == 50L & grid$T == 15L & grid$rho_Y == 0.2][1L]
odd_seed <- task13_seed(parameters$base_seed, odd_scenario$scenario_number, 1L)
odd_panel <- task13_simulate_dual_role(odd_scenario, parameters, odd_seed)
odd_hpj <- task13_fit_hpj_pair(odd_panel)
assert_true(
  odd_hpj$long$T_first == 7L && odd_hpj$long$T_second == 8L,
  "split-panel jackknife creates the pre-specified 7/8 split when T = 15"
)
assert_true(
  isTRUE(all.equal(odd_hpj$long$weight_first + odd_hpj$long$weight_second, 1)),
  "odd-T half-panel weights sum to one"
)

ab_pair <- task13_fit_ab_pair(panel_1, parameters)
assert_true(is.finite(ab_pair$long$coefficient_D), "Arellano-Bond sensitivity estimate is finite")
assert_true(ab_pair$long$instrument_count <= parameters$ab_max_instruments, "Arellano-Bond instrument count respects the cap")
assert_true(is.finite(ab_pair$long$ar2_p), "Arellano-Bond AR(2) diagnostic is recorded")
assert_true(is.finite(ab_pair$long$hansen_p), "Arellano-Bond Hansen diagnostic is recorded")

edge_scenario <- grid[
  grid$design_family == "principal" &
    grid$N == 50L &
    grid$T == 50L &
    grid$rho_Y == 0.8
][1L]
edge_seed <- task13_seed(parameters$base_seed, edge_scenario$scenario_number, 1L)
edge_panel <- task13_simulate_dual_role(edge_scenario, parameters, edge_seed)
edge_ab <- task13_fit_ab_pair(edge_panel, parameters)
assert_true(is.finite(edge_ab$long$coefficient_D), "Arellano-Bond runs at the T = 50, rho_Y = 0.8 grid edge")
assert_true(edge_ab$long$instrument_count <= parameters$ab_max_instruments, "collapsed instruments remain capped at the longest panel")

raw_1 <- task13_run_grid(
  grid = scenario,
  repetitions = 1L,
  parameters = parameters,
  include_ab = TRUE,
  progress = FALSE
)
raw_2 <- task13_run_grid(
  grid = scenario,
  repetitions = 1L,
  parameters = parameters,
  include_ab = TRUE,
  progress = FALSE
)
assert_true(identical(raw_1, raw_2), "all estimator outputs are deterministic for a fixed seed")
assert_true(identical(names(raw_1), task13_expected_raw_columns()), "raw output schema is exact")
assert_true(nrow(raw_1) == 3L, "one replication retains all three estimator rows")
assert_true(all(raw_1$status == "ok"), "bounded estimator smoke run has no failures")

summary <- task13_summarise_results(raw_1, requested_repetitions = 1L)
assert_true(nrow(summary) == 3L, "summary retains one row per estimator")
assert_true(all(c(
  "bias", "relative_bias", "rmse", "coverage", "mean_delta_z",
  "bias_ge_abs_delta_z", "mcse_bias", "mcse_coverage"
) %in% names(summary)), "pre-specified metrics are present")

temporary_csv <- tempfile(fileext = ".csv")
data.table::fwrite(raw_1, temporary_csv)
round_trip <- data.table::fread(temporary_csv)
unlink(temporary_csv)
assert_true(nrow(round_trip) == nrow(raw_1), "raw CSV round trip preserves row count")

message("TASK 13 SMOKE TEST PASS")
