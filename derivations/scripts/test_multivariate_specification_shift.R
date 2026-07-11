# Deterministic checks for the multivariate specification-shift identities.
# This is an algebraic test fixture, not a simulation from the paper.

tolerance <- 1e-12

fit_coefficients <- function(outcome, treatment, controls = NULL) {
  design <- cbind(`(Intercept)` = 1, D = treatment)
  if (!is.null(controls) && ncol(as.matrix(controls)) > 0L) {
    controls <- as.matrix(controls)
    design <- cbind(design, controls)
  }

  fit <- stats::lm.fit(x = design, y = outcome)
  if (fit$rank != ncol(design)) {
    stop("The deterministic test design is not full rank.")
  }

  stats::setNames(as.numeric(fit$coefficients), colnames(design))
}

coefficient_on_treatment <- function(outcome, treatment, controls = NULL) {
  unname(fit_coefficients(outcome, treatment, controls)["D"])
}

all_permutations <- function(x) {
  if (length(x) == 1L) {
    return(matrix(x, nrow = 1L))
  }

  do.call(
    rbind,
    lapply(seq_along(x), function(j) {
      cbind(x[j], all_permutations(x[-j]))
    })
  )
}

n <- 240L
index <- seq_len(n)
w1 <- as.numeric(scale(index))
w2 <- as.numeric(scale((index - mean(index))^2))
d <- 0.55 * w1 - 0.20 * w2 + sin(index / 7) + 0.35 * cos(index / 13)

u1 <- sin(index / 3) + 0.20 * cos(index / 17)
u2 <- cos(index / 5) - 0.15 * sin(index / 19)
u3 <- sin(index / 11) + 0.25 * cos(index / 23)

z1 <- 0.90 * d + 0.55 * w1 + 0.45 * u1
z2 <- -0.45 * d + 0.35 * w2 + 0.70 * z1 + 0.35 * u2
z3 <- 0.55 * d - 0.30 * w1 + 0.40 * z1 - 0.35 * z2 + 0.30 * u3

deterministic_error <- 0.20 * sin(index / 2) - 0.10 * cos(index / 29)
y <- 1.25 * d + 0.80 * z1 - 0.55 * z2 + 0.65 * z3 +
  0.40 * w1 - 0.25 * w2 + deterministic_error

W <- cbind(W1 = w1, W2 = w2)
Z <- cbind(Z1 = z1, Z2 = z2, Z3 = z3)
control_names <- colnames(Z)

beta_short <- coefficient_on_treatment(y, d, W)
full_coefficients <- fit_coefficients(y, d, cbind(W, Z))
beta_joint <- unname(full_coefficients["D"])
theta_joint <- unname(full_coefficients[control_names])

pi_joint <- vapply(
  control_names,
  function(control_name) {
    coefficient_on_treatment(Z[, control_name], d, W)
  },
  numeric(1)
)

delta_joint <- beta_joint - beta_short
joint_product <- -sum(theta_joint * pi_joint)
joint_error <- abs(delta_joint - joint_product)

permutation_matrix <- all_permutations(control_names)
sequential_rows <- vector("list", nrow(permutation_matrix) * ncol(permutation_matrix))
telescope_rows <- vector("list", nrow(permutation_matrix))
row_index <- 1L

for (order_index in seq_len(nrow(permutation_matrix))) {
  order_now <- permutation_matrix[order_index, ]
  order_label <- paste(order_now, collapse = " -> ")
  included <- character(0)
  beta_before <- beta_short
  contribution_sum <- 0

  for (step_index in seq_along(order_now)) {
    control_now <- order_now[step_index]
    controls_before <- cbind(W, Z[, included, drop = FALSE])
    controls_after <- cbind(controls_before, Z[, control_now, drop = FALSE])
    coefficients_after <- fit_coefficients(y, d, controls_after)
    beta_after <- unname(coefficients_after["D"])
    theta_conditional <- unname(coefficients_after[control_now])
    pi_conditional <- coefficient_on_treatment(
      Z[, control_now],
      d,
      controls_before
    )
    direct_increment <- beta_after - beta_before
    product_increment <- -theta_conditional * pi_conditional

    sequential_rows[[row_index]] <- data.frame(
      order = order_label,
      step = step_index,
      control = control_now,
      direct_increment = direct_increment,
      product_increment = product_increment,
      conditional_identity_error = abs(direct_increment - product_increment),
      stringsAsFactors = FALSE
    )

    row_index <- row_index + 1L
    contribution_sum <- contribution_sum + direct_increment
    beta_before <- beta_after
    included <- c(included, control_now)
  }

  telescope_rows[[order_index]] <- data.frame(
    order = order_label,
    sequential_sum = contribution_sum,
    joint_shift = delta_joint,
    telescope_error = abs(contribution_sum - delta_joint),
    stringsAsFactors = FALSE
  )
}

sequential_results <- do.call(rbind, sequential_rows)
telescope_results <- do.call(rbind, telescope_rows)

order_dependence <- do.call(
  rbind,
  lapply(control_names, function(control_name) {
    values <- sequential_results$direct_increment[
      sequential_results$control == control_name
    ]
    data.frame(
      control = control_name,
      minimum_increment = min(values),
      maximum_increment = max(values),
      range_across_orders = diff(range(values)),
      stringsAsFactors = FALSE
    )
  })
)

loo_rows <- lapply(control_names, function(control_name) {
  other_controls <- setdiff(control_names, control_name)
  beta_without <- coefficient_on_treatment(
    y,
    d,
    cbind(W, Z[, other_controls, drop = FALSE])
  )
  direct_increment <- beta_joint - beta_without
  theta_conditional <- unname(full_coefficients[control_name])
  pi_conditional <- coefficient_on_treatment(
    Z[, control_name],
    d,
    cbind(W, Z[, other_controls, drop = FALSE])
  )
  product_increment <- -theta_conditional * pi_conditional

  data.frame(
    control = control_name,
    direct_increment = direct_increment,
    product_increment = product_increment,
    conditional_identity_error = abs(direct_increment - product_increment),
    stringsAsFactors = FALSE
  )
})

leave_one_out_results <- do.call(rbind, loo_rows)
leave_one_out_sum <- sum(leave_one_out_results$direct_increment)
leave_one_out_gap <- leave_one_out_sum - delta_joint

correlation_matrix <- stats::cor(cbind(D = d, Z))
minimum_absolute_control_correlation <- min(abs(stats::cor(Z)[upper.tri(stats::cor(Z))]))

max_conditional_identity_error <- max(
  sequential_results$conditional_identity_error,
  leave_one_out_results$conditional_identity_error
)
max_telescope_error <- max(telescope_results$telescope_error)
minimum_order_range <- min(order_dependence$range_across_orders)

stopifnot(
  joint_error < tolerance,
  max_conditional_identity_error < tolerance,
  max_telescope_error < tolerance,
  minimum_absolute_control_correlation > 0.20,
  minimum_order_range > 1e-4,
  abs(leave_one_out_gap) > 1e-4
)

test_summary <- data.frame(
  check = c(
    "Joint vector identity",
    "Conditional scalar identities",
    "Sequential telescoping, all orders",
    "Controls are correlated",
    "Sequential allocations vary by order",
    "Leave-one-out sum differs from joint shift"
  ),
  diagnostic = c(
    joint_error,
    max_conditional_identity_error,
    max_telescope_error,
    minimum_absolute_control_correlation,
    minimum_order_range,
    abs(leave_one_out_gap)
  ),
  criterion = c(
    paste0("error < ", format(tolerance, scientific = TRUE)),
    paste0("error < ", format(tolerance, scientific = TRUE)),
    paste0("error < ", format(tolerance, scientific = TRUE)),
    "minimum absolute pairwise correlation > 0.20",
    "minimum range across orders > 1e-4",
    "absolute gap > 1e-4"
  ),
  result = "PASS",
  stringsAsFactors = FALSE
)

if (sys.nframe() == 0L) {
  print(test_summary, row.names = FALSE)
  cat("\nJoint shift:", format(delta_joint, digits = 16), "\n")
  cat("Joint product:", format(joint_product, digits = 16), "\n")
  cat("Leave-one-out sum:", format(leave_one_out_sum, digits = 16), "\n")
  cat("Leave-one-out gap:", format(leave_one_out_gap, digits = 16), "\n")
}
