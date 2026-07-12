#!/usr/bin/env Rscript

options(scipen = 999)

lmp_script_path <- function() {
  file_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(file_arg) != 1L) {
    stop("Cannot determine runner path.", call. = FALSE)
  }
  normalizePath(sub("^--file=", "", file_arg), mustWork = TRUE)
}

lmp_root <- dirname(lmp_script_path())
lmp_repo_root <- normalizePath(file.path(lmp_root, "..", ".."), mustWork = TRUE)

source(file.path(lmp_root, "R", "config.R"))
source(file.path(lmp_root, "R", "dgp.R"))
source(file.path(lmp_root, "R", "estimators.R"))
source(file.path(lmp_root, "R", "simulation.R"))
source(file.path(lmp_root, "R", "metrics.R"))

lmp_parse_args <- function(args) {
  parsed <- list(
    mode = "preflight",
    repetitions = NA_integer_,
    output_dir = NULL,
    approved = FALSE,
    overwrite = FALSE,
    render_report = FALSE
  )
  index <- 1L
  while (index <= length(args)) {
    argument <- args[[index]]
    if (argument %in% c("--approved", "--overwrite", "--render-report")) {
      if (argument == "--approved") parsed$approved <- TRUE
      if (argument == "--overwrite") parsed$overwrite <- TRUE
      if (argument == "--render-report") parsed$render_report <- TRUE
      index <- index + 1L
      next
    }
    if (argument %in% c("--mode", "--reps", "--output-dir")) {
      if (index == length(args)) stop("Missing value after ", argument, ".", call. = FALSE)
      value <- args[[index + 1L]]
      if (argument == "--mode") parsed$mode <- value
      if (argument == "--reps") parsed$repetitions <- as.integer(value)
      if (argument == "--output-dir") parsed$output_dir <- value
      index <- index + 2L
      next
    }
    stop("Unknown command-line argument: ", argument, call. = FALSE)
  }
  if (!parsed$mode %in% c("preflight", "smoke", "full")) {
    stop("--mode must be preflight, smoke, or full.", call. = FALSE)
  }
  parsed
}

lmp_atomic_fwrite <- function(object, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  temporary <- tempfile(pattern = paste0(basename(path), "."), tmpdir = dirname(path))
  data.table::fwrite(object, temporary, na = "NA")
  if (!file.rename(temporary, path)) {
    unlink(temporary)
    stop("Atomic write failed for ", path, call. = FALSE)
  }
  invisible(path)
}

lmp_parameter_manifest <- function(parameters) {
  scalar <- vapply(parameters, length, integer(1)) == 1L
  base <- data.table::data.table(
    parameter = names(parameters)[scalar],
    value = vapply(parameters[scalar], as.character, character(1))
  )
  lag_parameters <- data.table::rbindlist(lapply(
    names(parameters$rho_Y_by_order),
    function(order) data.table::data.table(
      parameter = paste0("rho_Y_lag_", order),
      value = paste(parameters$rho_Y_by_order[[order]], collapse = ";")
    )
  ))
  data.table::rbindlist(list(base, lag_parameters), use.names = TRUE)
}

lmp_code_manifest <- function() {
  files <- c(
    "run_lag_misspecification_persistence.R",
    file.path("R", c("config.R", "dgp.R", "estimators.R", "simulation.R", "metrics.R")),
    "smoke_test.R",
    "lag_misspecification_persistence_report.Rmd",
    "README.md",
    "task14_protocol.md",
    "editorial_recommendation.md"
  )
  paths <- file.path(lmp_root, files)
  exists <- file.exists(paths)
  data.table::data.table(
    file = files,
    exists = exists,
    md5 = ifelse(exists, unname(tools::md5sum(paths)), NA_character_)
  )
}

lmp_hash_preexisting_simulations <- function() {
  simulation_root <- file.path(lmp_repo_root, "simulations")
  package_prefix <- paste0(normalizePath(lmp_root, mustWork = TRUE), "/")
  paths <- list.files(simulation_root, recursive = TRUE, full.names = TRUE, include.dirs = FALSE)
  paths <- paths[file.info(paths)$isdir %in% FALSE]
  paths <- paths[!startsWith(normalizePath(paths, mustWork = TRUE), package_prefix)]
  relative_paths <- sub(paste0("^", lmp_repo_root, "/"), "", normalizePath(paths, mustWork = TRUE))
  hashes <- unname(tools::md5sum(paths))
  data.table::data.table(path = relative_paths, md5 = hashes)[order(path)]
}

lmp_review_gate <- function() {
  review_path <- file.path(
    lmp_repo_root,
    "quality_reports",
    "task14_lag_misspecification_persistence",
    "independent_review_terra_high.md"
  )
  if (!file.exists(review_path)) {
    stop(
      "Full grid is blocked: independent Terra/high review file is missing: ",
      review_path,
      call. = FALSE
    )
  }
  review_text <- readLines(review_path, warn = FALSE, encoding = "UTF-8")
  if (!any(grepl("^## Verdict: PASS$", review_text))) {
    stop("Full grid is blocked: independent review is not recorded as PASS.", call. = FALSE)
  }
  invisible(review_path)
}

lmp_log <- function(output_dir, message) {
  connection <- file(file.path(output_dir, "run_log.txt"), open = "a", encoding = "UTF-8")
  on.exit(close(connection), add = TRUE)
  writeLines(
    sprintf("%s | %s", format(Sys.time(), tz = "UTC", usetz = TRUE), message),
    con = connection,
    sep = "\n",
    useBytes = TRUE
  )
}

lmp_write_outputs <- function(raw, grid, repetitions, parameters, output_dir, mode, hashes_before) {
  if (!identical(names(raw), lmp_expected_raw_columns())) {
    stop("Raw output schema differs from pre-specified schema.", call. = FALSE)
  }
  summary <- lmp_summarise_results(raw, repetitions)
  selection <- lmp_selection_summary(raw, repetitions)
  displacement <- lmp_displacement_summary(raw, repetitions)
  residual_acf <- lmp_residual_acf_summary(summary)
  failures <- lmp_failures(raw)
  stability <- lmp_stability_checks(summary, repetitions)
  validation <- lmp_output_validation(raw, grid, repetitions, parameters)
  hashes_after <- lmp_hash_preexisting_simulations()
  hash_validation <- merge(
    hashes_before,
    hashes_after,
    by = "path",
    all = TRUE,
    suffixes = c("_before", "_after")
  )
  hash_validation[, unchanged := !is.na(md5_before) & md5_before == md5_after]
  if (!all(hash_validation$unchanged)) {
    stop("A pre-existing simulation artifact changed during Task 14 execution.", call. = FALSE)
  }

  lmp_atomic_fwrite(grid, file.path(output_dir, "design_grid.csv"))
  lmp_atomic_fwrite(
    lmp_initialization_manifest(grid, parameters),
    file.path(output_dir, "initialization_manifest.csv")
  )
  lmp_atomic_fwrite(raw, file.path(output_dir, "raw_replications.csv"))
  lmp_atomic_fwrite(summary, file.path(output_dir, "scenario_estimator_summary.csv"))
  lmp_atomic_fwrite(selection, file.path(output_dir, "selection_recovery_summary.csv"))
  lmp_atomic_fwrite(displacement, file.path(output_dir, "displacement_summary.csv"))
  lmp_atomic_fwrite(residual_acf, file.path(output_dir, "residual_autocorrelation_summary.csv"))
  lmp_atomic_fwrite(failures, file.path(output_dir, "failures.csv"))
  lmp_atomic_fwrite(stability, file.path(output_dir, "stability_checks.csv"))
  lmp_atomic_fwrite(validation, file.path(output_dir, "validation.csv"))
  lmp_atomic_fwrite(lmp_parameter_manifest(parameters), file.path(output_dir, "parameter_manifest.csv"))
  lmp_atomic_fwrite(lmp_code_manifest(), file.path(output_dir, "code_manifest.csv"))
  lmp_atomic_fwrite(hashes_before, file.path(output_dir, "preexisting_simulation_hashes_before.csv"))
  lmp_atomic_fwrite(hashes_after, file.path(output_dir, "preexisting_simulation_hashes_after.csv"))
  lmp_atomic_fwrite(hash_validation, file.path(output_dir, "preexisting_simulation_hash_validation.csv"))
  lmp_atomic_fwrite(
    data.table::data.table(
      mode = mode,
      repetitions = repetitions,
      base_seed = parameters$base_seed,
      scenario_count = nrow(grid),
      estimator_count = 5L,
      control_specification_count = 3L,
      expected_rows = nrow(grid) * repetitions * 5L * 3L,
      actual_rows = nrow(raw),
      completed_utc = format(Sys.time(), tz = "UTC", usetz = TRUE)
    ),
    file.path(output_dir, "run_manifest.csv")
  )
  writeLines(capture.output(sessionInfo()), file.path(output_dir, "session_info.txt"))
  lmp_log(output_dir, sprintf("Completed %s run with %d replications per scenario.", mode, repetitions))
  list(
    summary = summary,
    selection = selection,
    displacement = displacement,
    validation = validation,
    failures = failures
  )
}

lmp_render_report <- function(output_dir) {
  lmp_check_packages(include_report = TRUE)
  report <- file.path(lmp_root, "lag_misspecification_persistence_report.Rmd")
  rmarkdown::render(
    report,
    output_format = "pdf_document",
    output_file = "lag_misspecification_persistence_report.pdf",
    output_dir = normalizePath(output_dir, mustWork = TRUE),
    params = list(input_dir = normalizePath(output_dir, mustWork = TRUE)),
    envir = new.env(parent = globalenv()),
    quiet = FALSE
  )
}

lmp_main <- function() {
  arguments <- lmp_parse_args(commandArgs(trailingOnly = TRUE))
  parameters <- lmp_parameters()
  lmp_check_packages(include_report = arguments$render_report)
  full_grid <- lmp_full_grid(parameters)
  grid_validation <- lmp_validate_grid(full_grid, parameters)

  if (arguments$mode == "preflight") {
    print(grid_validation)
    message("Task 14 preflight PASS: 27 pre-specified scenarios.")
    return(invisible(grid_validation))
  }
  if (arguments$mode == "full" && !isTRUE(arguments$approved)) {
    stop("Full grid is gated. Re-run with --approved after independent review.", call. = FALSE)
  }
  if (arguments$mode == "full") lmp_review_gate()

  if (is.na(arguments$repetitions)) {
    arguments$repetitions <- if (arguments$mode == "smoke") 1L else parameters$default_repetitions
  }
  if (!is.finite(arguments$repetitions) || arguments$repetitions < 1L) {
    stop("--reps must be a positive integer.", call. = FALSE)
  }
  grid <- if (arguments$mode == "smoke") full_grid[seq_len(3L)] else full_grid
  output_dir <- arguments$output_dir
  temporary_output <- is.null(output_dir) && arguments$mode == "smoke"
  if (temporary_output) {
    output_dir <- tempfile("task14_smoke_")
  } else if (is.null(output_dir)) {
    output_dir <- file.path(lmp_root, "results")
  }
  if (!grepl("^/", output_dir)) output_dir <- file.path(lmp_repo_root, output_dir)
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  output_dir <- normalizePath(output_dir, mustWork = TRUE)
  final_files <- file.path(output_dir, c("raw_replications.csv", "scenario_estimator_summary.csv"))
  if (any(file.exists(final_files)) && !isTRUE(arguments$overwrite)) {
    stop("Output files already exist. Use --overwrite only after preserving the prior run.", call. = FALSE)
  }
  lmp_log(output_dir, sprintf("Started %s run with %d replications per scenario.", arguments$mode, arguments$repetitions))
  hashes_before <- lmp_hash_preexisting_simulations()
  checkpoint_callback <- function(scenario, scenario_raw) {
    lmp_atomic_fwrite(
      scenario_raw,
      file.path(output_dir, "checkpoints", paste0(scenario$scenario_id, ".csv"))
    )
  }
  raw <- lmp_run_grid(
    grid = grid,
    repetitions = arguments$repetitions,
    parameters = parameters,
    progress = TRUE,
    checkpoint_callback = checkpoint_callback
  )
  outputs <- lmp_write_outputs(
    raw, grid, arguments$repetitions, parameters, output_dir, arguments$mode, hashes_before
  )
  if (isTRUE(arguments$render_report)) lmp_render_report(output_dir)
  message("Task 14 ", arguments$mode, " run complete: ", output_dir)
  message("Estimator failures retained: ", nrow(outputs$failures))
  if (temporary_output) message("Smoke outputs are temporary and do not modify repository results.")
  invisible(outputs)
}

lmp_main()
