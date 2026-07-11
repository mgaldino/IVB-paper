# Inference utilities for the scalar specification shift.
#
# The functions implement unweighted OLS on one common, complete sample. They
# jointly retain the short, long, and auxiliary equations so that covariance
# across estimators is not discarded. Unit bootstrap functions resample whole
# units and re-estimate all three equations on each paired resample. Nothing in
# this file executes a bootstrap when the file is sourced.

options(scipen = 999)

.ssu_as_matrix <- function(x, n, prefix) {
  if (is.null(x)) {
    return(matrix(numeric(), nrow = n, ncol = 0L))
  }
  x <- as.matrix(x)
  if (nrow(x) != n) {
    stop(prefix, " must have one row per observation.")
  }
  if (!is.numeric(x) || any(!is.finite(x))) {
    stop(prefix, " must be numeric and finite.")
  }
  if (is.null(colnames(x))) {
    colnames(x) <- paste0(prefix, seq_len(ncol(x)))
  }
  if (any(colnames(x) == "") || anyDuplicated(colnames(x))) {
    stop(prefix, " must have unique, nonempty column names.")
  }
  x
}

.ssu_validate_inputs <- function(
    outcome, treatment, candidate_control, common_controls, unit) {
  n <- length(outcome)
  if (n < 1L || length(treatment) != n ||
      length(candidate_control) != n || length(unit) != n) {
    stop("Outcome, treatment, candidate control, and unit must share one sample.")
  }
  if (!is.numeric(outcome) || !is.numeric(treatment) ||
      !is.numeric(candidate_control) ||
      any(!is.finite(c(outcome, treatment, candidate_control)))) {
    stop("Outcome, treatment, and candidate control must be numeric and finite.")
  }
  if (anyNA(unit)) {
    stop("Unit identifiers must be complete.")
  }
  common_controls <- .ssu_as_matrix(common_controls, n, "W")
  forbidden <- c("(Intercept)", "D", "Z")
  if (any(colnames(common_controls) %in% forbidden)) {
    stop("Common-control names cannot be (Intercept), D, or Z.")
  }
  list(
    outcome = as.numeric(outcome),
    treatment = as.numeric(treatment),
    candidate_control = as.numeric(candidate_control),
    common_controls = common_controls,
    unit = unit
  )
}

.ssu_lm_fit <- function(design, response, equation) {
  fit <- stats::lm.fit(x = design, y = response)
  if (fit$rank != ncol(design)) {
    stop("The ", equation, " equation is not full rank.")
  }
  coefficients <- stats::setNames(as.numeric(fit$coefficients), colnames(design))
  list(
    equation = equation,
    design = design,
    response = response,
    coefficients = coefficients,
    residuals = as.numeric(fit$residuals)
  )
}

# Re-estimate the nested short and long models and the auxiliary equation on
# exactly the same observations and with exactly the same common regressors.
fit_specification_shift <- function(
    outcome, treatment, candidate_control, common_controls = NULL, unit) {
  inputs <- .ssu_validate_inputs(
    outcome, treatment, candidate_control, common_controls, unit
  )
  short_design <- cbind(
    `(Intercept)` = 1,
    D = inputs$treatment,
    inputs$common_controls
  )
  long_design <- cbind(short_design, Z = inputs$candidate_control)

  short <- .ssu_lm_fit(short_design, inputs$outcome, "short")
  long <- .ssu_lm_fit(long_design, inputs$outcome, "long")
  auxiliary <- .ssu_lm_fit(short_design, inputs$candidate_control, "auxiliary")

  beta_short <- unname(short$coefficients["D"])
  beta_long <- unname(long$coefficients["D"])
  theta <- unname(long$coefficients["Z"])
  pi <- unname(auxiliary$coefficients["D"])
  delta_direct <- beta_long - beta_short
  delta_product <- -theta * pi

  structure(
    list(
      models = list(short = short, long = long, auxiliary = auxiliary),
      unit = inputs$unit,
      estimates = c(
        beta_short = beta_short,
        beta_long = beta_long,
        theta = theta,
        pi = pi,
        delta_direct = delta_direct,
        delta_product = delta_product,
        identity_error = abs(delta_direct - delta_product)
      )
    ),
    class = "specification_shift_fit"
  )
}

.ssu_block_indices <- function(models) {
  sizes <- vapply(models, function(model) ncol(model$design), integer(1))
  ends <- cumsum(sizes)
  starts <- ends - sizes + 1L
  Map(seq.int, starts, ends)
}

# Stacked cluster-sandwich covariance for coefficients from all three OLS
# equations. Cross-equation meat blocks retain covariance between estimators.
stacked_cluster_vcov <- function(object, correction = c("CR0", "CR1")) {
  if (!inherits(object, "specification_shift_fit")) {
    stop("object must come from fit_specification_shift().")
  }
  correction <- match.arg(correction)
  models <- object$models
  n <- nrow(models[[1L]]$design)
  if (any(vapply(models, function(model) nrow(model$design) != n, logical(1)))) {
    stop("All equations must use the same observations.")
  }
  unit_factor <- factor(object$unit, levels = unique(object$unit))
  cluster_count <- nlevels(unit_factor)
  if (cluster_count < 2L) {
    stop("Cluster covariance requires at least two units.")
  }

  cluster_scores <- lapply(models, function(model) {
    observation_scores <- model$design * model$residuals
    rowsum(observation_scores, group = unit_factor, reorder = FALSE)
  })
  breads <- lapply(models, function(model) {
    solve(crossprod(model$design))
  })
  indices <- .ssu_block_indices(models)
  total_parameters <- sum(vapply(models, function(model) ncol(model$design), integer(1)))
  covariance <- matrix(0, total_parameters, total_parameters)

  for (left in seq_along(models)) {
    for (right in seq_along(models)) {
      meat_cross <- crossprod(cluster_scores[[left]], cluster_scores[[right]])
      covariance[indices[[left]], indices[[right]]] <-
        breads[[left]] %*% meat_cross %*% breads[[right]]
    }
  }
  if (correction == "CR1") {
    covariance <- covariance * cluster_count / (cluster_count - 1)
  }

  parameter_names <- unlist(Map(
    function(model_name, model) paste0(model_name, "::", names(model$coefficients)),
    names(models), models
  ), use.names = FALSE)
  dimnames(covariance) <- list(parameter_names, parameter_names)
  covariance
}

variance_of_difference <- function(var_long, var_short, cov_long_short) {
  variance <- var_long + var_short - 2 * cov_long_short
  if (!is.finite(variance)) {
    stop("Variance inputs must be finite.")
  }
  variance
}

# Delta variance of the linear contrast beta_long - beta_short. The covariance
# term is required; treating the nested estimates as independent is incorrect.
delta_variance_difference <- function(object, correction = c("CR0", "CR1")) {
  correction <- match.arg(correction)
  covariance <- stacked_cluster_vcov(object, correction)
  long_name <- "long::D"
  short_name <- "short::D"
  var_long <- covariance[long_name, long_name]
  var_short <- covariance[short_name, short_name]
  cov_long_short <- covariance[long_name, short_name]
  variance <- variance_of_difference(var_long, var_short, cov_long_short)
  if (variance < -sqrt(.Machine$double.eps)) {
    stop("The estimated variance of the difference is materially negative.")
  }
  variance <- max(variance, 0)
  c(
    estimate = unname(object$estimates["delta_direct"]),
    variance = variance,
    standard_error = sqrt(variance),
    var_long = var_long,
    var_short = var_short,
    cov_long_short = cov_long_short
  )
}

variance_of_product_delta <- function(theta, pi, var_theta, var_pi, cov_theta_pi) {
  variance <- pi^2 * var_theta + theta^2 * var_pi +
    2 * theta * pi * cov_theta_pi
  if (!is.finite(variance)) {
    stop("Product delta-method inputs must be finite.")
  }
  variance
}

# First-order delta-method variance for -theta*pi. This is a verification path,
# not an automatic substitute for inference on the paired coefficient contrast.
product_delta_variance <- function(object, correction = c("CR0", "CR1")) {
  correction <- match.arg(correction)
  covariance <- stacked_cluster_vcov(object, correction)
  theta_name <- "long::Z"
  pi_name <- "auxiliary::D"
  theta <- unname(object$estimates["theta"])
  pi <- unname(object$estimates["pi"])
  var_theta <- covariance[theta_name, theta_name]
  var_pi <- covariance[pi_name, pi_name]
  cov_theta_pi <- covariance[theta_name, pi_name]
  variance <- variance_of_product_delta(
    theta, pi, var_theta, var_pi, cov_theta_pi
  )
  if (variance < -sqrt(.Machine$double.eps)) {
    stop("The product delta-method variance is materially negative.")
  }
  variance <- max(variance, 0)
  c(
    estimate = -theta * pi,
    variance = variance,
    standard_error = sqrt(variance),
    var_theta = var_theta,
    var_pi = var_pi,
    cov_theta_pi = cov_theta_pi
  )
}

# Expand a vector of sampled source units into row indices. Repeated source
# units receive distinct bootstrap-unit identifiers.
expand_unit_bootstrap_indices <- function(unit, sampled_units) {
  if (anyNA(unit) || anyNA(sampled_units)) {
    stop("Unit identifiers and sampled units must be complete.")
  }
  observed_units <- unique(as.character(unit))
  sampled_units_character <- as.character(sampled_units)
  if (!all(sampled_units_character %in% observed_units)) {
    stop("Every sampled unit must occur in the original sample.")
  }
  rows <- lapply(seq_along(sampled_units_character), function(draw) {
    source_unit <- sampled_units_character[[draw]]
    source_rows <- which(as.character(unit) == source_unit)
    data.frame(
      row_index = source_rows,
      source_unit = source_unit,
      bootstrap_unit = draw,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

# Validate that each bootstrap occurrence contains every row of its source unit
# exactly once and that repeated source units remain distinct pseudo-units.
validate_unit_bootstrap_indices <- function(index, unit, sampled_units) {
  required <- c("row_index", "source_unit", "bootstrap_unit")
  if (!is.data.frame(index) || !all(required %in% names(index))) {
    stop("index must contain row_index, source_unit, and bootstrap_unit.")
  }
  sampled_units <- as.character(sampled_units)
  if (!identical(sort(unique(index$bootstrap_unit)), seq_along(sampled_units))) {
    stop("Bootstrap-unit identifiers must run from 1 through the number of draws.")
  }
  checks <- lapply(seq_along(sampled_units), function(draw) {
    expected <- which(as.character(unit) == sampled_units[[draw]])
    observed <- index$row_index[index$bootstrap_unit == draw]
    recorded_source <- unique(index$source_unit[index$bootstrap_unit == draw])
    passed <- identical(as.integer(observed), as.integer(expected)) &&
      identical(recorded_source, sampled_units[[draw]])
    data.frame(
      bootstrap_unit = draw,
      source_unit = sampled_units[[draw]],
      expected_rows = length(expected),
      observed_rows = length(observed),
      passed = passed,
      stringsAsFactors = FALSE
    )
  })
  checks <- do.call(rbind, checks)
  if (!all(checks$passed)) {
    stop("At least one bootstrap unit does not preserve its source-unit rows.")
  }
  checks
}

.ssu_draw_unit_samples <- function(unit, repetitions, seed) {
  if (length(repetitions) != 1L || repetitions < 1L || repetitions %% 1 != 0) {
    stop("repetitions must be a positive integer.")
  }
  if (missing(seed) || length(seed) != 1L || !is.finite(seed)) {
    stop("A finite scalar seed is required when bootstrap samples are generated.")
  }
  units <- unique(unit)
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  if (had_seed) {
    old_seed <- get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  }
  on.exit({
    if (had_seed) {
      assign(".Random.seed", old_seed, envir = .GlobalEnv)
    } else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
      rm(".Random.seed", envir = .GlobalEnv)
    }
  }, add = TRUE)
  set.seed(seed)
  lapply(seq_len(repetitions), function(ignored) {
    sample(units, length(units), replace = TRUE)
  })
}

bootstrap_percentile_interval <- function(estimates, conf_level = 0.95) {
  if (!is.numeric(estimates) || any(!is.finite(estimates))) {
    stop("Bootstrap estimates must be numeric and finite.")
  }
  if (length(conf_level) != 1L || conf_level <= 0 || conf_level >= 1) {
    stop("conf_level must lie strictly between zero and one.")
  }
  alpha <- 1 - conf_level
  stats::quantile(
    estimates,
    probs = c(alpha / 2, 1 - alpha / 2),
    names = FALSE,
    type = 6
  )
}

# Paired unit bootstrap. Each replicate resamples whole units once, applies that
# same row index to all variables, and jointly re-estimates the three equations.
# This function is intentionally inert until explicitly called.
bootstrap_specification_shift <- function(
    outcome, treatment, candidate_control, common_controls = NULL, unit,
    repetitions = NULL, seed, sampled_units = NULL,
    conf_level = 0.95, identity_tolerance = 1e-10) {
  inputs <- .ssu_validate_inputs(
    outcome, treatment, candidate_control, common_controls, unit
  )
  unit_count <- length(unique(inputs$unit))
  if (is.null(sampled_units)) {
    if (is.null(repetitions)) {
      stop("Supply repetitions or an explicit list of sampled_units.")
    }
    sampled_units <- .ssu_draw_unit_samples(inputs$unit, repetitions, seed)
  } else {
    if (!is.list(sampled_units) || length(sampled_units) < 1L) {
      stop("sampled_units must be a nonempty list of unit vectors.")
    }
    repetitions <- length(sampled_units)
  }
  if (any(vapply(sampled_units, length, integer(1)) != unit_count)) {
    stop("Each bootstrap replicate must draw exactly the original number of units.")
  }

  estimates <- lapply(seq_len(repetitions), function(replication) {
    sampled_now <- sampled_units[[replication]]
    index <- expand_unit_bootstrap_indices(inputs$unit, sampled_now)
    validate_unit_bootstrap_indices(index, inputs$unit, sampled_now)
    rows <- index$row_index
    fit <- fit_specification_shift(
      outcome = inputs$outcome[rows],
      treatment = inputs$treatment[rows],
      candidate_control = inputs$candidate_control[rows],
      common_controls = inputs$common_controls[rows, , drop = FALSE],
      unit = index$bootstrap_unit
    )
    if (fit$estimates["identity_error"] > identity_tolerance) {
      stop("The difference-product identity failed in bootstrap replicate ", replication, ".")
    }
    data.frame(
      replication = replication,
      beta_short = fit$estimates["beta_short"],
      beta_long = fit$estimates["beta_long"],
      theta = fit$estimates["theta"],
      pi = fit$estimates["pi"],
      delta_direct = fit$estimates["delta_direct"],
      delta_product = fit$estimates["delta_product"],
      identity_error = fit$estimates["identity_error"],
      row.names = NULL
    )
  })
  estimates <- do.call(rbind, estimates)
  interval <- bootstrap_percentile_interval(estimates$delta_direct, conf_level)
  list(
    estimates = estimates,
    interval = stats::setNames(interval, c("lower", "upper")),
    conf_level = conf_level,
    resampling_unit = "unit"
  )
}
