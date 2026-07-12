lmp_estimator_definitions <- function() {
  data.table::data.table(
    estimator_id = c("adl_1", "adl_2", "adl_oracle", "adl_aic", "adl_bic"),
    estimator = c(
      "ADL(1), fixed lag",
      "ADL(2), fixed lag",
      "ADL, true lag order",
      "ADL, AIC-selected lag",
      "ADL, BIC-selected lag"
    ),
    selection_criterion = c("fixed", "fixed", "oracle", "AIC", "BIC")
  )
}

lmp_failure_rows <- function(scenario, replication, seed, error_stage, error_message) {
  methods <- lmp_estimator_definitions()
  controls <- c("no_Z", "Z_lag", "Z_contemporaneous")
  rows <- data.table::CJ(
    method_index = seq_len(nrow(methods)),
    control_spec = controls,
    unique = TRUE
  )
  rows[, `:=`(
    scenario_id = scenario$scenario_id,
    scenario_number = scenario$scenario_number,
    true_lag_order = scenario$true_lag_order,
    rho_D = scenario$rho_D,
    carryover = scenario$carryover,
    N = scenario$N,
    T = scenario$T,
    replication = replication,
    seed = seed,
    estimator_id = methods$estimator_id[method_index],
    estimator = methods$estimator[method_index],
    selection_criterion = methods$selection_criterion[method_index],
    selected_lag = NA_integer_,
    selection_correct = NA,
    beta_true = NA_real_,
    beta_hat = NA_real_,
    se = NA_real_,
    ci_lower = NA_real_,
    ci_upper = NA_real_,
    coverage_cet = NA,
    residual_acf1 = NA_real_,
    aic = NA_real_,
    bic = NA_real_,
    nobs = NA_integer_,
    n_clusters = NA_integer_,
    condition_number = NA_real_,
    delta_z_lag_minus_none = NA_real_,
    delta_z_contemporaneous_minus_none = NA_real_,
    status = "failed",
    error_stage = error_stage,
    error_message = error_message
  )]
  rows[, method_index := NULL]
  data.table::setcolorder(rows, lmp_expected_raw_columns())
  rows
}

lmp_result_row <- function(
  scenario,
  replication,
  seed,
  method,
  selected_lag,
  control_spec,
  fit,
  parameters,
  delta_z_lag_minus_none,
  delta_z_contemporaneous_minus_none
) {
  success <- identical(fit$status, "ok")
  data.table::data.table(
    scenario_id = scenario$scenario_id,
    scenario_number = scenario$scenario_number,
    true_lag_order = scenario$true_lag_order,
    rho_D = scenario$rho_D,
    carryover = scenario$carryover,
    N = scenario$N,
    T = scenario$T,
    replication = replication,
    seed = seed,
    estimator_id = method$estimator_id,
    estimator = method$estimator,
    selection_criterion = method$selection_criterion,
    selected_lag = selected_lag,
    selection_correct = if (is.na(selected_lag)) NA else selected_lag == scenario$true_lag_order,
    control_spec = control_spec,
    beta_true = parameters$beta_cet,
    beta_hat = fit$beta_hat,
    se = fit$se,
    ci_lower = fit$ci_lower,
    ci_upper = fit$ci_upper,
    coverage_cet = if (success) {
      fit$ci_lower <= parameters$beta_cet && parameters$beta_cet <= fit$ci_upper
    } else {
      NA
    },
    residual_acf1 = fit$residual_acf1,
    aic = fit$aic,
    bic = fit$bic,
    nobs = fit$nobs,
    n_clusters = fit$n_clusters,
    condition_number = fit$condition_number,
    delta_z_lag_minus_none = delta_z_lag_minus_none,
    delta_z_contemporaneous_minus_none = delta_z_contemporaneous_minus_none,
    status = fit$status,
    error_stage = fit$error_stage,
    error_message = fit$error_message
  )
}

lmp_run_replication <- function(scenario, replication, parameters) {
  seed <- lmp_seed(parameters$base_seed, scenario$scenario_number, replication)
  panel <- tryCatch(
    lmp_simulate_panel(scenario, parameters, seed),
    error = function(error) error
  )
  if (inherits(panel, "error")) {
    return(lmp_failure_rows(
      scenario, replication, seed, "dgp", conditionMessage(panel)
    ))
  }
  prepared <- tryCatch(
    lmp_prepare_within(panel, parameters),
    error = function(error) error
  )
  if (inherits(prepared, "error")) {
    return(lmp_failure_rows(
      scenario, replication, seed, "within_transformation", conditionMessage(prepared)
    ))
  }

  cache <- new.env(parent = emptyenv())
  get_fit <- function(lag_order, control_spec) {
    key <- paste(lag_order, control_spec, sep = "__")
    if (!exists(key, envir = cache, inherits = FALSE)) {
      assign(key, lmp_safe_fit(prepared, lag_order, control_spec), envir = cache)
    }
    get(key, envir = cache, inherits = FALSE)
  }
  candidate_lags <- parameters$candidate_lags
  candidate_fits <- lapply(
    candidate_lags,
    function(lag_order) get_fit(lag_order, "Z_lag")
  )
  aic_selection <- lmp_select_lag(candidate_fits, "AIC", candidate_lags)
  bic_selection <- lmp_select_lag(candidate_fits, "BIC", candidate_lags)

  methods <- lmp_estimator_definitions()
  method_lags <- list(
    adl_1 = list(status = "ok", selected_lag = 1L),
    adl_2 = list(status = "ok", selected_lag = 2L),
    adl_oracle = list(status = "ok", selected_lag = as.integer(scenario$true_lag_order)),
    adl_aic = aic_selection,
    adl_bic = bic_selection
  )
  controls <- c("no_Z", "Z_lag", "Z_contemporaneous")
  rows <- vector("list", nrow(methods) * length(controls))
  row_index <- 1L

  for (method_index in seq_len(nrow(methods))) {
    method <- methods[method_index]
    lag_choice <- method_lags[[method$estimator_id]]
    if (!identical(lag_choice$status, "ok")) {
      for (control_spec in controls) {
        failed_fit <- list(
          status = "failed",
          error_stage = lag_choice$error_stage,
          error_message = lag_choice$error_message,
          beta_hat = NA_real_, se = NA_real_, ci_lower = NA_real_, ci_upper = NA_real_,
          residual_acf1 = NA_real_, aic = NA_real_, bic = NA_real_, nobs = NA_integer_,
          n_clusters = NA_integer_, condition_number = NA_real_
        )
        rows[[row_index]] <- lmp_result_row(
          scenario, replication, seed, method, NA_integer_, control_spec, failed_fit,
          parameters, NA_real_, NA_real_
        )
        row_index <- row_index + 1L
      }
      next
    }

    selected_lag <- lag_choice$selected_lag
    fitted_controls <- lapply(
      controls,
      function(control_spec) get_fit(selected_lag, control_spec)
    )
    names(fitted_controls) <- controls
    delta_z_lag_minus_none <- if (
      identical(fitted_controls$no_Z$status, "ok") &&
        identical(fitted_controls$Z_lag$status, "ok")
    ) {
      fitted_controls$Z_lag$beta_hat - fitted_controls$no_Z$beta_hat
    } else {
      NA_real_
    }
    delta_z_contemporaneous_minus_none <- if (
      identical(fitted_controls$no_Z$status, "ok") &&
        identical(fitted_controls$Z_contemporaneous$status, "ok")
    ) {
      fitted_controls$Z_contemporaneous$beta_hat - fitted_controls$no_Z$beta_hat
    } else {
      NA_real_
    }

    for (control_spec in controls) {
      rows[[row_index]] <- lmp_result_row(
        scenario, replication, seed, method, selected_lag, control_spec,
        fitted_controls[[control_spec]], parameters, delta_z_lag_minus_none,
        delta_z_contemporaneous_minus_none
      )
      row_index <- row_index + 1L
    }
  }
  raw <- data.table::rbindlist(rows, use.names = TRUE)
  data.table::setcolorder(raw, lmp_expected_raw_columns())
  raw
}

lmp_run_grid <- function(grid, repetitions, parameters, progress = TRUE, checkpoint_callback = NULL) {
  scenario_results <- vector("list", nrow(grid))
  for (scenario_index in seq_len(nrow(grid))) {
    scenario <- grid[scenario_index]
    if (isTRUE(progress)) {
      message(sprintf(
        "Task 14 scenario %d/%d: %s (%d replications)",
        scenario_index, nrow(grid), scenario$scenario_id, repetitions
      ))
    }
    replication_results <- lapply(
      seq_len(repetitions),
      function(replication) lmp_run_replication(scenario, replication, parameters)
    )
    scenario_raw <- data.table::rbindlist(replication_results, use.names = TRUE)
    if (!identical(names(scenario_raw), lmp_expected_raw_columns())) {
      stop("Raw schema invariant failed within scenario.", call. = FALSE)
    }
    if (!is.null(checkpoint_callback)) {
      checkpoint_callback(scenario, scenario_raw)
    }
    scenario_results[[scenario_index]] <- scenario_raw
  }
  raw <- data.table::rbindlist(scenario_results, use.names = TRUE)
  data.table::setcolorder(raw, lmp_expected_raw_columns())
  raw
}
