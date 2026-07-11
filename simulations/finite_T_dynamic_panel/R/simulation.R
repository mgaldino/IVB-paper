task13_estimator_labels <- function(include_ab = TRUE) {
  labels <- c(
    fe_adl = "FE-ADL within",
    hpj_fe_adl = "split-panel jackknife FE-ADL"
  )
  if (isTRUE(include_ab)) {
    labels <- c(labels, arellano_bond = "Arellano-Bond sensitivity")
  }
  labels
}

task13_failed_row <- function(
    scenario,
    replication,
    seed,
    estimator_id,
    estimator_label,
    beta_true,
    error_stage,
    error_message) {
  data.table::data.table(
    scenario_id = scenario$scenario_id,
    design_family = scenario$design_family,
    scenario_number = scenario$scenario_number,
    replication = replication,
    seed = seed,
    N = scenario$N,
    T = scenario$T,
    rho_Y = scenario$rho_Y,
    rho_D = scenario$rho_D,
    rho_Z = scenario$rho_Z,
    sigma_alpha_Z = scenario$sigma_alpha_Z,
    unit_effect_heterogeneity = scenario$unit_effect_heterogeneity,
    estimator_id = estimator_id,
    estimator = estimator_label,
    beta_true = beta_true,
    beta_short = NA_real_,
    se_short = NA_real_,
    covered_short = NA,
    beta_long = NA_real_,
    se_long = NA_real_,
    covered_long = NA,
    estimation_error = NA_real_,
    delta_z_hat = NA_real_,
    nobs_short = NA_integer_,
    nobs_long = NA_integer_,
    instrument_count_short = NA_integer_,
    instrument_count_long = NA_integer_,
    ar2_p_short = NA_real_,
    ar2_p_long = NA_real_,
    hansen_p_short = NA_real_,
    hansen_p_long = NA_real_,
    estimator_warnings = NA_character_,
    status = "failed",
    error_stage = error_stage,
    error_message = error_message
  )
}

task13_success_row <- function(
    scenario,
    replication,
    seed,
    estimator_id,
    estimator_label,
    beta_true,
    pair,
    nominal_coverage) {
  critical_value <- stats::qnorm(1 - (1 - nominal_coverage) / 2)
  short <- pair$short
  long <- pair$long

  covered <- function(estimate, standard_error) {
    is.finite(estimate) &&
      is.finite(standard_error) &&
      standard_error > 0 &&
      beta_true >= estimate - critical_value * standard_error &&
      beta_true <= estimate + critical_value * standard_error
  }

  is_ab <- identical(estimator_id, "arellano_bond")
  warnings <- if (is_ab) {
    paste(unique(c(short$warnings, long$warnings)), collapse = " | ")
  } else {
    ""
  }

  data.table::data.table(
    scenario_id = scenario$scenario_id,
    design_family = scenario$design_family,
    scenario_number = scenario$scenario_number,
    replication = replication,
    seed = seed,
    N = scenario$N,
    T = scenario$T,
    rho_Y = scenario$rho_Y,
    rho_D = scenario$rho_D,
    rho_Z = scenario$rho_Z,
    sigma_alpha_Z = scenario$sigma_alpha_Z,
    unit_effect_heterogeneity = scenario$unit_effect_heterogeneity,
    estimator_id = estimator_id,
    estimator = estimator_label,
    beta_true = beta_true,
    beta_short = short$coefficient_D,
    se_short = short$se_D,
    covered_short = covered(short$coefficient_D, short$se_D),
    beta_long = long$coefficient_D,
    se_long = long$se_D,
    covered_long = covered(long$coefficient_D, long$se_D),
    estimation_error = long$coefficient_D - beta_true,
    delta_z_hat = long$coefficient_D - short$coefficient_D,
    nobs_short = as.integer(short$nobs),
    nobs_long = as.integer(long$nobs),
    instrument_count_short = if (is_ab) as.integer(short$instrument_count) else NA_integer_,
    instrument_count_long = if (is_ab) as.integer(long$instrument_count) else NA_integer_,
    ar2_p_short = if (is_ab) short$ar2_p else NA_real_,
    ar2_p_long = if (is_ab) long$ar2_p else NA_real_,
    hansen_p_short = if (is_ab) short$hansen_p else NA_real_,
    hansen_p_long = if (is_ab) long$hansen_p else NA_real_,
    estimator_warnings = warnings,
    status = "ok",
    error_stage = NA_character_,
    error_message = NA_character_
  )
}

task13_run_replication <- function(
    scenario,
    replication,
    parameters,
    include_ab = TRUE) {
  seed <- task13_seed(
    parameters$base_seed,
    scenario$scenario_number,
    replication
  )
  labels <- task13_estimator_labels(include_ab = include_ab)

  dgp_fit <- task13_safe_fit(
    task13_simulate_dual_role(scenario, parameters, seed)
  )
  if (dgp_fit$status != "ok") {
    return(data.table::rbindlist(lapply(names(labels), function(estimator_id) {
      task13_failed_row(
        scenario = scenario,
        replication = replication,
        seed = seed,
        estimator_id = estimator_id,
        estimator_label = labels[[estimator_id]],
        beta_true = parameters$beta_cet,
        error_stage = "dgp",
        error_message = dgp_fit$error_message
      )
    })))
  }

  panel <- dgp_fit$result
  beta_true <- attr(panel, "beta_target")

  fe_fit <- task13_safe_fit(task13_fit_fe_pair(panel))
  fe_row <- if (fe_fit$status == "ok") {
    task13_success_row(
      scenario, replication, seed, "fe_adl", labels[["fe_adl"]],
      beta_true, fe_fit$result, parameters$nominal_coverage
    )
  } else {
    task13_failed_row(
      scenario, replication, seed, "fe_adl", labels[["fe_adl"]], beta_true,
      "fe_adl", fe_fit$error_message
    )
  }

  hpj_fit <- if (fe_fit$status == "ok") {
    task13_safe_fit(task13_fit_hpj_pair(panel, full_pair = fe_fit$result))
  } else {
    list(
      status = "failed",
      result = NULL,
      error_message = "FE-ADL prerequisite failed."
    )
  }
  hpj_row <- if (hpj_fit$status == "ok") {
    task13_success_row(
      scenario, replication, seed, "hpj_fe_adl", labels[["hpj_fe_adl"]],
      beta_true, hpj_fit$result, parameters$nominal_coverage
    )
  } else {
    task13_failed_row(
      scenario, replication, seed, "hpj_fe_adl", labels[["hpj_fe_adl"]], beta_true,
      "hpj_fe_adl", hpj_fit$error_message
    )
  }

  rows <- list(fe_row, hpj_row)
  if (isTRUE(include_ab)) {
    ab_fit <- task13_safe_fit(task13_fit_ab_pair(panel, parameters))
    ab_row <- if (ab_fit$status == "ok") {
      task13_success_row(
        scenario, replication, seed, "arellano_bond", labels[["arellano_bond"]],
        beta_true, ab_fit$result, parameters$nominal_coverage
      )
    } else {
      task13_failed_row(
        scenario, replication, seed, "arellano_bond", labels[["arellano_bond"]],
        beta_true, "arellano_bond", ab_fit$error_message
      )
    }
    rows <- c(rows, list(ab_row))
  }

  data.table::rbindlist(rows, use.names = TRUE, fill = TRUE)
}

task13_run_grid <- function(
    grid,
    repetitions,
    parameters,
    include_ab = TRUE,
    progress = interactive(),
    checkpoint_callback = NULL) {
  scenario_outputs <- vector("list", nrow(grid))

  for (g in seq_len(nrow(grid))) {
    scenario <- grid[g]
    if (isTRUE(progress)) {
      message(sprintf(
        "[%d/%d] %s: %d replications",
        g,
        nrow(grid),
        scenario$scenario_id,
        repetitions
      ))
    }

    replication_outputs <- lapply(seq_len(repetitions), function(replication) {
      task13_run_replication(
        scenario = scenario,
        replication = replication,
        parameters = parameters,
        include_ab = include_ab
      )
    })
    scenario_outputs[[g]] <- data.table::rbindlist(
      replication_outputs,
      use.names = TRUE,
      fill = TRUE
    )

    if (is.function(checkpoint_callback)) {
      checkpoint_callback(scenario, scenario_outputs[[g]])
    }
  }

  data.table::rbindlist(scenario_outputs, use.names = TRUE, fill = TRUE)
}

task13_expected_raw_columns <- function() {
  c(
    "scenario_id", "design_family", "scenario_number", "replication", "seed",
    "N", "T", "rho_Y", "rho_D", "rho_Z", "sigma_alpha_Z",
    "unit_effect_heterogeneity", "estimator_id", "estimator", "beta_true",
    "beta_short", "se_short", "covered_short", "beta_long", "se_long",
    "covered_long", "estimation_error", "delta_z_hat", "nobs_short",
    "nobs_long", "instrument_count_short", "instrument_count_long",
    "ar2_p_short", "ar2_p_long", "hansen_p_short", "hansen_p_long",
    "estimator_warnings", "status", "error_stage", "error_message"
  )
}

