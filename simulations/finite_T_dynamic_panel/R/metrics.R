task13_mcse_rmse <- function(errors) {
  n <- length(errors)
  rmse <- sqrt(mean(errors^2))
  if (n < 2L || !is.finite(rmse) || rmse == 0) {
    return(NA_real_)
  }
  stats::sd(errors^2) / (2 * rmse * sqrt(n))
}

task13_summarise_one <- function(group, requested_repetitions) {
  successful <- group[group$status == "ok" & is.finite(group$beta_long)]
  n_success <- nrow(successful)
  n_failed <- nrow(group) - n_success

  identity <- group[1L]
  if (n_success == 0L) {
    return(data.table::data.table(
      scenario_id = identity$scenario_id,
      design_family = identity$design_family,
      N = identity$N,
      T = identity$T,
      rho_Y = identity$rho_Y,
      rho_D = identity$rho_D,
      rho_Z = identity$rho_Z,
      sigma_alpha_Z = identity$sigma_alpha_Z,
      unit_effect_heterogeneity = identity$unit_effect_heterogeneity,
      estimator_id = identity$estimator_id,
      estimator = identity$estimator,
      beta_true = identity$beta_true,
      n_requested = requested_repetitions,
      n_success = 0L,
      n_failed = n_failed,
      failure_rate = 1,
      mean_estimate = NA_real_,
      bias = NA_real_,
      relative_bias = NA_real_,
      rmse = NA_real_,
      coverage = NA_real_,
      mean_delta_z = NA_real_,
      abs_delta_z = NA_real_,
      mean_abs_delta_z = NA_real_,
      bias_ge_abs_delta_z = NA,
      mcse_bias = NA_real_,
      mcse_rmse = NA_real_,
      mcse_coverage = NA_real_,
      mcse_delta_z = NA_real_,
      mean_instrument_count = NA_real_,
      ar2_rejection_rate_05 = NA_real_,
      hansen_rejection_rate_05 = NA_real_
    ))
  }

  errors <- successful$estimation_error
  delta <- successful$delta_z_hat
  bias <- mean(errors)
  rmse <- sqrt(mean(errors^2))
  coverage <- mean(successful$covered_long)
  mean_delta <- mean(delta)
  beta_true <- successful$beta_true[1L]

  data.table::data.table(
    scenario_id = identity$scenario_id,
    design_family = identity$design_family,
    N = identity$N,
    T = identity$T,
    rho_Y = identity$rho_Y,
    rho_D = identity$rho_D,
    rho_Z = identity$rho_Z,
    sigma_alpha_Z = identity$sigma_alpha_Z,
    unit_effect_heterogeneity = identity$unit_effect_heterogeneity,
    estimator_id = identity$estimator_id,
    estimator = identity$estimator,
    beta_true = beta_true,
    n_requested = requested_repetitions,
    n_success = n_success,
    n_failed = n_failed,
    failure_rate = n_failed / nrow(group),
    mean_estimate = mean(successful$beta_long),
    bias = bias,
    relative_bias = if (beta_true == 0) NA_real_ else bias / beta_true,
    rmse = rmse,
    coverage = coverage,
    mean_delta_z = mean_delta,
    abs_delta_z = abs(mean_delta),
    mean_abs_delta_z = mean(abs(delta)),
    bias_ge_abs_delta_z = abs(bias) >= abs(mean_delta),
    mcse_bias = if (n_success > 1L) stats::sd(errors) / sqrt(n_success) else NA_real_,
    mcse_rmse = task13_mcse_rmse(errors),
    mcse_coverage = sqrt(coverage * (1 - coverage) / n_success),
    mcse_delta_z = if (n_success > 1L) stats::sd(delta) / sqrt(n_success) else NA_real_,
    mean_instrument_count = if (all(is.na(successful$instrument_count_long))) {
      NA_real_
    } else {
      mean(successful$instrument_count_long, na.rm = TRUE)
    },
    ar2_rejection_rate_05 = if (all(is.na(successful$ar2_p_long))) {
      NA_real_
    } else {
      mean(successful$ar2_p_long < 0.05, na.rm = TRUE)
    },
    hansen_rejection_rate_05 = if (all(is.na(successful$hansen_p_long))) {
      NA_real_
    } else {
      mean(successful$hansen_p_long < 0.05, na.rm = TRUE)
    }
  )
}

task13_summarise_results <- function(raw, requested_repetitions) {
  groups <- split(raw, interaction(raw$scenario_id, raw$estimator_id, drop = TRUE))
  summary <- data.table::rbindlist(
    lapply(groups, task13_summarise_one, requested_repetitions = requested_repetitions),
    use.names = TRUE,
    fill = TRUE
  )
  data.table::setorder(summary, design_family, N, T, rho_Y, rho_D, sigma_alpha_Z, estimator_id)
  summary
}

task13_stability_checks <- function(raw, summary, requested_repetitions) {
  groups <- split(raw, interaction(raw$scenario_id, raw$estimator_id, drop = TRUE))

  batch_checks <- data.table::rbindlist(lapply(groups, function(group) {
    successful <- group[group$status == "ok" & is.finite(group$estimation_error)]
    identity <- group[1L]
    if (nrow(successful) < 4L) {
      return(data.table::data.table(
        scenario_id = identity$scenario_id,
        estimator_id = identity$estimator_id,
        batch_bias_gap = NA_real_,
        batch_gap_se = NA_real_,
        batch_stable_99 = NA
      ))
    }

    midpoint <- floor(requested_repetitions / 2)
    first <- successful[successful$replication <= midpoint]$estimation_error
    second <- successful[successful$replication > midpoint]$estimation_error
    if (length(first) < 2L || length(second) < 2L) {
      return(data.table::data.table(
        scenario_id = identity$scenario_id,
        estimator_id = identity$estimator_id,
        batch_bias_gap = NA_real_,
        batch_gap_se = NA_real_,
        batch_stable_99 = NA
      ))
    }

    gap <- mean(first) - mean(second)
    gap_se <- sqrt(stats::var(first) / length(first) + stats::var(second) / length(second))
    data.table::data.table(
      scenario_id = identity$scenario_id,
      estimator_id = identity$estimator_id,
      batch_bias_gap = gap,
      batch_gap_se = gap_se,
      batch_stable_99 = abs(gap) <= stats::qnorm(0.995) * gap_se
    )
  }))

  checks <- merge(
    summary,
    batch_checks,
    by = c("scenario_id", "estimator_id"),
    all.x = TRUE,
    sort = FALSE
  )
  checks[, `:=`(
    failure_rate_pass = failure_rate <= 0.05,
    mcse_bias_target_pass = is.finite(mcse_bias) & mcse_bias <= 0.01,
    coverage_mcse_target_pass = is.finite(mcse_coverage) & mcse_coverage <= 0.015,
    instrument_limit_pass = is.na(mean_instrument_count) | mean_instrument_count <= 12
  )]
  checks[, `:=`(
    stability_pass = failure_rate_pass &
      mcse_bias_target_pass &
      coverage_mcse_target_pass &
      instrument_limit_pass &
      !is.na(batch_stable_99) &
      batch_stable_99
  )]
  checks
}

task13_failures <- function(raw) {
  raw[raw$status != "ok", list(
    scenario_id,
    replication,
    seed,
    estimator_id,
    error_stage,
    error_message
  )]
}
