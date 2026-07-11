# Deterministic checks for specification-shift uncertainty utilities.
# This file does not call set.seed(), sample(), bootstrap re-estimation, or any
# paper simulation. The fixture is a fixed algebraic panel.

options(scipen = 999)
if (!exists("fit_specification_shift", mode = "function")) {
  source("specification_shift_uncertainty.R")
}

tolerance <- 1e-10

unit <- rep(paste0("u", seq_len(12L)), each = 8L)
time <- rep(seq_len(8L), times = 12L)
unit_number <- rep(seq_len(12L), each = 8L)
index <- seq_along(unit)

unit_dummies <- stats::model.matrix(~ factor(unit) - 1)[, -1, drop = FALSE]
colnames(unit_dummies) <- paste0("unit_", seq_len(ncol(unit_dummies)) + 1L)
w1 <- as.numeric(scale(time))
w2 <- sin(index / 9) + 0.15 * cos(index / 4)
d <- 0.35 * w1 + 0.20 * w2 + 0.08 * unit_number + cos(index / 7)
z <- 0.75 * d - 0.30 * w1 + 0.25 * sin(index / 5) + 0.03 * unit_number
y <- 1.10 * d + 0.65 * z + 0.40 * w1 - 0.20 * w2 +
  0.12 * sin(index / 3) - 0.05 * cos(index / 11)
W <- cbind(W1 = w1, W2 = w2, unit_dummies)

fit <- fit_specification_shift(
  outcome = y,
  treatment = d,
  candidate_control = z,
  common_controls = W,
  unit = unit
)

identity_error <- unname(fit$estimates["identity_error"])
stopifnot(identity_error < tolerance)

joint_covariance <- stacked_cluster_vcov(fit, correction = "CR0")
difference_result <- delta_variance_difference(fit, correction = "CR0")
manual_difference_variance <-
  joint_covariance["long::D", "long::D"] +
  joint_covariance["short::D", "short::D"] -
  2 * joint_covariance["long::D", "short::D"]
difference_variance_error <- abs(
  difference_result["variance"] - manual_difference_variance
)
stopifnot(difference_variance_error < tolerance)

product_result <- product_delta_variance(fit, correction = "CR0")
manual_product_variance <-
  fit$estimates["pi"]^2 * joint_covariance["long::Z", "long::Z"] +
  fit$estimates["theta"]^2 *
    joint_covariance["auxiliary::D", "auxiliary::D"] +
  2 * fit$estimates["theta"] * fit$estimates["pi"] *
    joint_covariance["long::Z", "auxiliary::D"]
product_variance_error <- abs(product_result["variance"] - manual_product_variance)
stopifnot(product_variance_error < tolerance)

# A fixed covariance example shows why the covariance term cannot be dropped.
simple_var_long <- 0.04
simple_var_short <- 0.09
simple_covariance <- 0.03
simple_paired_variance <- variance_of_difference(
  simple_var_long, simple_var_short, simple_covariance
)
simple_independence_variance <- simple_var_long + simple_var_short
simple_expected_variance <- 0.07
simple_comparison_error <- abs(simple_paired_variance - simple_expected_variance)
stopifnot(
  simple_comparison_error < tolerance,
  abs(simple_independence_variance - 0.13) < tolerance,
  simple_paired_variance != simple_independence_variance
)

# This is an index-structure check only. It does not fit a bootstrap replicate.
observed_units <- unique(unit)
sampled_units <- observed_units[c(3, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)]
bootstrap_index <- expand_unit_bootstrap_indices(unit, sampled_units)
index_checks <- validate_unit_bootstrap_indices(
  bootstrap_index, unit, sampled_units
)
expected_bootstrap_rows <- sum(vapply(
  sampled_units,
  function(source_unit) sum(unit == source_unit),
  integer(1)
))
repeated_source_has_distinct_ids <- length(unique(
  bootstrap_index$bootstrap_unit[bootstrap_index$source_unit == observed_units[3L]]
)) == 2L
index_structure_passed <-
  nrow(bootstrap_index) == expected_bootstrap_rows &&
  all(index_checks$passed) &&
  repeated_source_has_distinct_ids
stopifnot(index_structure_passed)

malformed_index <- bootstrap_index
malformed_index$row_index[1L] <- malformed_index$row_index[1L] + 1L
malformed_index_rejected <- inherits(
  try(
    validate_unit_bootstrap_indices(malformed_index, unit, sampled_units),
    silent = TRUE
  ),
  "try-error"
)
stopifnot(malformed_index_rejected)

test_summary <- data.frame(
  check = c(
    "Fixed-sample difference-product identity",
    "Difference variance includes cross-estimator covariance",
    "Product delta variance matches its stated gradient formula",
    "Simple paired-variance algebra",
    "Whole-unit index structure",
    "Repeated source units receive distinct bootstrap identifiers",
    "Malformed unit index is rejected"
  ),
  diagnostic = c(
    identity_error,
    difference_variance_error,
    product_variance_error,
    simple_comparison_error,
    as.numeric(index_structure_passed),
    as.numeric(repeated_source_has_distinct_ids),
    as.numeric(malformed_index_rejected)
  ),
  criterion = c(
    "error < 1e-10",
    "error < 1e-10",
    "error < 1e-10",
    "error < 1e-10",
    "equals 1",
    "equals 1",
    "equals 1"
  ),
  result = "PASS",
  stringsAsFactors = FALSE
)

if (sys.nframe() == 0L) {
  print(test_summary, row.names = FALSE)
  cat("\nDirect shift:", format(fit$estimates["delta_direct"], digits = 16), "\n")
  cat("Product shift:", format(fit$estimates["delta_product"], digits = 16), "\n")
  cat("Paired variance in simple example:", simple_paired_variance, "\n")
  cat("Independence variance in simple example:", simple_independence_variance, "\n")
}
