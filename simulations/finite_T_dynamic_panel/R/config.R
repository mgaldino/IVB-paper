options(scipen = 999)

task13_required_packages <- function(include_report = FALSE) {
  packages <- c("data.table", "dplyr", "plm")
  if (isTRUE(include_report)) {
    packages <- c(packages, "ggplot2", "knitr", "rmarkdown")
  }
  packages
}

task13_check_packages <- function(include_report = FALSE) {
  packages <- task13_required_packages(include_report = include_report)
  available <- vapply(packages, requireNamespace, logical(1), quietly = TRUE)
  if (any(!available)) {
    stop(
      "Missing required R packages: ",
      paste(names(available)[!available], collapse = ", "),
      call. = FALSE
    )
  }
  invisible(available)
}

task13_parameters <- function() {
  list(
    burn_in = 100L,
    beta_cet = 1,
    rho_Y = 0.5,
    rho_D = 0.5,
    rho_Z = 0.5,
    gamma_D = 0.15,
    gamma_Y = 0.2,
    delta_D = 0.1,
    delta_Y = 0.1,
    sigma_alpha_D = 1,
    sigma_alpha_Y = 1,
    sigma_alpha_Z = 0.5,
    sigma_beta = 0,
    sigma_u = 1,
    sigma_e = 1,
    sigma_nu = 1,
    nominal_coverage = 0.95,
    ab_lag_min = 2L,
    ab_lag_max = 3L,
    ab_max_instruments = 12L,
    base_seed = 13072026L,
    default_repetitions = 500L
  )
}

task13_principal_grid <- function(parameters = task13_parameters()) {
  grid <- data.table::CJ(
    N = c(50L, 100L, 250L),
    T = c(8L, 10L, 15L, 20L, 30L, 50L),
    rho_Y = c(0.2, 0.5, 0.8),
    sorted = TRUE
  )
  grid[, `:=`(
    design_family = "principal",
    rho_D = parameters$rho_D,
    rho_Z = parameters$rho_Z,
    sigma_alpha_Z = parameters$sigma_alpha_Z,
    unit_effect_heterogeneity = "baseline",
    scenario_id = sprintf("P_N%03d_T%02d_RY%02d", N, T, round(100 * rho_Y))
  )]
  data.table::setcolorder(
    grid,
    c("scenario_id", "design_family", "N", "T", "rho_Y", "rho_D",
      "rho_Z", "sigma_alpha_Z", "unit_effect_heterogeneity")
  )
  grid
}

task13_stress_grid <- function(parameters = task13_parameters()) {
  grid <- data.table::CJ(
    T = c(10L, 20L, 30L),
    rho_D = c(0.2, 0.5, 0.8),
    sigma_alpha_Z = c(0.5, 2.0),
    sorted = TRUE
  )
  grid[, `:=`(
    design_family = "stress",
    N = 100L,
    rho_Y = parameters$rho_Y,
    rho_Z = parameters$rho_Z,
    unit_effect_heterogeneity = ifelse(
      sigma_alpha_Z == parameters$sigma_alpha_Z,
      "baseline",
      "high_alpha_Z"
    ),
    scenario_id = sprintf(
      "S_N100_T%02d_RD%02d_SAZ%03d",
      T,
      round(100 * rho_D),
      round(100 * sigma_alpha_Z)
    )
  )]
  data.table::setcolorder(
    grid,
    c("scenario_id", "design_family", "N", "T", "rho_Y", "rho_D",
      "rho_Z", "sigma_alpha_Z", "unit_effect_heterogeneity")
  )
  grid
}

task13_full_grid <- function(parameters = task13_parameters()) {
  grid <- data.table::rbindlist(
    list(
      task13_principal_grid(parameters),
      task13_stress_grid(parameters)
    ),
    use.names = TRUE
  )
  grid[, scenario_number := seq_len(.N)]
  grid
}

task13_transition_radius <- function(rho_Y, rho_D, rho_Z, parameters) {
  beta <- parameters$beta_cet
  gamma_D <- parameters$gamma_D
  gamma_Y <- parameters$gamma_Y
  delta_D <- parameters$delta_D
  delta_Y <- parameters$delta_Y

  transition <- rbind(
    c(rho_D, 0, gamma_D),
    c(beta * rho_D, rho_Y, beta * gamma_D + gamma_Y),
    c(
      (delta_D + delta_Y * beta) * rho_D,
      delta_Y * rho_Y,
      (delta_D + delta_Y * beta) * gamma_D + delta_Y * gamma_Y + rho_Z
    )
  )
  max(Mod(eigen(transition, only.values = TRUE)$values))
}

task13_validate_grid <- function(grid, parameters = task13_parameters()) {
  principal <- grid[grid$design_family == "principal"]
  stress <- grid[grid$design_family == "stress"]

  checks <- c(
    principal_scenarios = nrow(principal) == 54L,
    stress_scenarios = nrow(stress) == 18L,
    principal_N = identical(sort(unique(principal$N)), c(50L, 100L, 250L)),
    principal_T = identical(sort(unique(principal$T)), c(8L, 10L, 15L, 20L, 30L, 50L)),
    principal_rho_Y = isTRUE(all.equal(sort(unique(principal$rho_Y)), c(0.2, 0.5, 0.8))),
    stress_N = identical(unique(stress$N), 100L),
    stress_T = identical(sort(unique(stress$T)), c(10L, 20L, 30L)),
    stress_rho_D = isTRUE(all.equal(sort(unique(stress$rho_D)), c(0.2, 0.5, 0.8))),
    stress_unit_effect_levels = isTRUE(all.equal(
      sort(unique(stress$sigma_alpha_Z)), c(0.5, 2.0)
    )),
    unique_scenario_ids = !anyDuplicated(grid$scenario_id),
    valid_panel_dimensions = all(grid$N > 1L & grid$T >= 8L),
    valid_persistence = all(abs(grid$rho_Y) < 1 & abs(grid$rho_D) < 1 & abs(grid$rho_Z) < 1),
    valid_scales = all(grid$sigma_alpha_Z > 0)
  )

  radii <- mapply(
    task13_transition_radius,
    rho_Y = grid$rho_Y,
    rho_D = grid$rho_D,
    rho_Z = grid$rho_Z,
    MoreArgs = list(parameters = parameters)
  )
  checks <- c(checks, stable_transition = all(is.finite(radii) & radii < 1))

  if (any(!checks)) {
    stop(
      "Task 13 grid validation failed: ",
      paste(names(checks)[!checks], collapse = ", "),
      call. = FALSE
    )
  }

  data.table::data.table(
    check = names(checks),
    passed = unname(checks),
    detail = c(
      "54 = 3 N x 6 T x 3 rho_Y",
      "18 = 3 T x 3 rho_D x 2 sigma_alpha_Z",
      "N = {50,100,250}",
      "T = {8,10,15,20,30,50}",
      "rho_Y = {0.2,0.5,0.8}",
      "N = 100",
      "T = {10,20,30}",
      "rho_D = {0.2,0.5,0.8}",
      "sigma_alpha_Z = {0.5,2.0}",
      "scenario_id is unique",
      "N > 1 and T >= 8",
      "all persistence parameters are inside (-1,1)",
      "unit-effect standard deviations are positive",
      sprintf("maximum companion-matrix spectral radius = %.6f", max(radii))
    )
  )
}

task13_seed <- function(base_seed, scenario_number, replication) {
  seed <- as.double(base_seed) + as.double(scenario_number) * 100000 + replication
  if (seed > .Machine$integer.max) {
    stop("Seed exceeds R's integer range.", call. = FALSE)
  }
  as.integer(seed)
}

