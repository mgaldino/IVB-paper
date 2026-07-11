# General functions for allocating a specification shift across correlated controls.
# All functions use unweighted OLS on a common, complete sample. They describe
# movements between nested linear projections; they do not identify causal bias.

options(scipen = 999)

.as_control_matrix <- function(controls) {
  controls <- as.matrix(controls)
  if (!is.numeric(controls)) {
    stop("Candidate controls must be numeric.")
  }
  if (is.null(colnames(controls)) || any(colnames(controls) == "")) {
    stop("Candidate controls must be a matrix with unique column names.")
  }
  if (anyDuplicated(colnames(controls))) {
    stop("Candidate-control names must be unique.")
  }
  controls
}

.validate_inputs <- function(outcome, treatment, common_controls, controls) {
  if (!is.numeric(outcome) || !is.numeric(treatment) ||
      is.factor(outcome) || is.factor(treatment)) {
    stop("Outcome and treatment must be numeric vectors.")
  }
  controls <- .as_control_matrix(controls)
  if (is.null(common_controls)) {
    common_controls <- matrix(
      numeric(0), nrow = length(outcome), ncol = 0L
    )
  } else {
    common_controls <- as.matrix(common_controls)
    if (!is.numeric(common_controls)) {
      stop("Common controls must be numeric.")
    }
  }
  if (length(outcome) != length(treatment) ||
      nrow(common_controls) != length(outcome) ||
      nrow(controls) != length(outcome)) {
    stop("Outcome, treatment, common controls, and candidate controls need a common sample.")
  }
  if (any(!is.finite(c(outcome, treatment, common_controls, controls)))) {
    stop("Inputs must be finite and complete; invalid values would change the estimation sample.")
  }
  list(
    outcome = as.numeric(outcome),
    treatment = as.numeric(treatment),
    common_controls = common_controls,
    controls = controls
  )
}

.validate_set <- function(set, control_names) {
  set <- as.character(set)
  if (anyDuplicated(set) || !all(set %in% control_names)) {
    stop("A control set must contain each candidate-control name at most once.")
  }
  set
}

.treatment_coefficient <- function(outcome, treatment, common_controls, controls, set) {
  set <- .validate_set(set, colnames(controls))
  design <- cbind(`(Intercept)` = 1, D = treatment, common_controls)
  if (length(set) > 0L) {
    design <- cbind(design, controls[, set, drop = FALSE])
  }
  fit <- stats::lm.fit(x = design, y = outcome)
  if (fit$rank != ncol(design)) {
    stop("A requested nested model is not full rank.")
  }
  unname(fit$coefficients["D"])
}

# beta(S): coefficient on treatment in the model with W and controls in S.
beta_set <- function(outcome, treatment, common_controls, controls, set = character()) {
  inputs <- .validate_inputs(outcome, treatment, common_controls, controls)
  .treatment_coefficient(
    inputs$outcome, inputs$treatment, inputs$common_controls, inputs$controls, set
  )
}

# shift(S): beta(S) - beta(empty set).
shift_set <- function(outcome, treatment, common_controls, controls, set) {
  inputs <- .validate_inputs(outcome, treatment, common_controls, controls)
  beta_full <- .treatment_coefficient(
    inputs$outcome, inputs$treatment, inputs$common_controls, inputs$controls, set
  )
  beta_short <- .treatment_coefficient(
    inputs$outcome, inputs$treatment, inputs$common_controls, inputs$controls, character()
  )
  beta_full - beta_short
}

# One-at-a-time increments: beta({j}) - beta(empty set), for every j.
one_at_a_time <- function(outcome, treatment, common_controls, controls) {
  inputs <- .validate_inputs(outcome, treatment, common_controls, controls)
  names <- colnames(inputs$controls)
  beta_short <- .treatment_coefficient(
    inputs$outcome, inputs$treatment, inputs$common_controls, inputs$controls, character()
  )
  increments <- vapply(
    names,
    function(name) .treatment_coefficient(
      inputs$outcome, inputs$treatment, inputs$common_controls, inputs$controls, name
    ) - beta_short,
    numeric(1)
  )
  data.frame(control = names, one_at_a_time = unname(increments), row.names = NULL)
}

# Contributions along one specified inclusion order. The final sum telescopes.
sequential_contributions <- function(outcome, treatment, common_controls, controls, order) {
  inputs <- .validate_inputs(outcome, treatment, common_controls, controls)
  names <- colnames(inputs$controls)
  order <- .validate_set(order, names)
  if (!setequal(order, names)) {
    stop("The inclusion order must include every candidate control exactly once.")
  }
  beta_before <- .treatment_coefficient(
    inputs$outcome, inputs$treatment, inputs$common_controls, inputs$controls, character()
  )
  included <- character()
  rows <- vector("list", length(order))
  for (step in seq_along(order)) {
    control <- order[[step]]
    included <- c(included, control)
    beta_after <- .treatment_coefficient(
      inputs$outcome, inputs$treatment, inputs$common_controls, inputs$controls, included
    )
    rows[[step]] <- data.frame(
      step = step,
      control = control,
      contribution = beta_after - beta_before,
      stringsAsFactors = FALSE
    )
    beta_before <- beta_after
  }
  result <- do.call(rbind, rows)
  attr(result, "joint_shift") <- beta_before - .treatment_coefficient(
    inputs$outcome, inputs$treatment, inputs$common_controls, inputs$controls, character()
  )
  result
}

# Last-in conditional increments: beta(all controls) - beta(all controls except j).
leave_one_out <- function(outcome, treatment, common_controls, controls) {
  inputs <- .validate_inputs(outcome, treatment, common_controls, controls)
  names <- colnames(inputs$controls)
  beta_full <- .treatment_coefficient(
    inputs$outcome, inputs$treatment, inputs$common_controls, inputs$controls, names
  )
  increments <- vapply(
    names,
    function(name) beta_full - .treatment_coefficient(
      inputs$outcome,
      inputs$treatment,
      inputs$common_controls,
      inputs$controls,
      setdiff(names, name)
    ),
    numeric(1)
  )
  data.frame(control = names, leave_one_out = unname(increments), row.names = NULL)
}

.all_permutations <- function(values) {
  if (length(values) == 0L) {
    return(matrix(character(), nrow = 1L, ncol = 0L))
  }
  if (length(values) == 1L) {
    return(matrix(values, nrow = 1L))
  }
  do.call(
    rbind,
    lapply(seq_along(values), function(index) {
      cbind(values[[index]], .all_permutations(values[-index]))
    })
  )
}

# Shapley allocation: average each control's sequential contribution over q! orders.
shapley_allocation <- function(outcome,
                               treatment,
                               common_controls,
                               controls,
                               max_controls = 9L) {
  inputs <- .validate_inputs(outcome, treatment, common_controls, controls)
  names <- colnames(inputs$controls)
  if (length(names) == 0L) {
    stop("At least one candidate control is required.")
  }
  if (length(names) > max_controls) {
    stop(
      "Exact Shapley enumeration requires q! orders. ",
      "Increase max_controls explicitly or use a separately validated approximation."
    )
  }
  orders <- .all_permutations(names)
  contributions <- matrix(
    NA_real_, nrow = nrow(orders), ncol = length(names),
    dimnames = list(NULL, names)
  )
  for (index in seq_len(nrow(orders))) {
    path <- sequential_contributions(
      inputs$outcome,
      inputs$treatment,
      inputs$common_controls,
      inputs$controls,
      orders[index, ]
    )
    contributions[index, path$control] <- path$contribution
  }
  data.frame(
    control = names,
    shapley = colMeans(contributions),
    row.names = NULL
  )
}
