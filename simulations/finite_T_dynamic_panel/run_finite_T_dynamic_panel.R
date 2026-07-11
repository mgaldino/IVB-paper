#!/usr/bin/env Rscript

options(scipen = 999)

task13_script_path <- function() {
  file_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(file_arg) != 1L) {
    stop("Cannot determine the runner path.", call. = FALSE)
  }
  normalizePath(sub("^--file=", "", file_arg), mustWork = TRUE)
}

task13_root <- dirname(task13_script_path())
task13_repo_root <- normalizePath(file.path(task13_root, "..", ".."), mustWork = TRUE)

source(file.path(task13_root, "R", "config.R"))
source(file.path(task13_root, "R", "dgp.R"))
source(file.path(task13_root, "R", "estimators.R"))
source(file.path(task13_root, "R", "simulation.R"))
source(file.path(task13_root, "R", "metrics.R"))

task13_parse_args <- function(args) {
  parsed <- list(
    mode = "preflight",
    repetitions = NA_integer_,
    output_dir = NULL,
    approved = FALSE,
    overwrite = FALSE,
    include_ab = TRUE,
    render_report = FALSE
  )

  i <- 1L
  while (i <= length(args)) {
    arg <- args[[i]]
    if (arg %in% c("--approved", "--overwrite", "--render-report", "--no-ab")) {
      if (arg == "--approved") parsed$approved <- TRUE
      if (arg == "--overwrite") parsed$overwrite <- TRUE
      if (arg == "--render-report") parsed$render_report <- TRUE
      if (arg == "--no-ab") parsed$include_ab <- FALSE
      i <- i + 1L
      next
    }
    if (arg %in% c("--mode", "--reps", "--output-dir")) {
      if (i == length(args)) {
        stop("Missing value after ", arg, ".", call. = FALSE)
      }
      value <- args[[i + 1L]]
      if (arg == "--mode") parsed$mode <- value
      if (arg == "--reps") parsed$repetitions <- as.integer(value)
      if (arg == "--output-dir") parsed$output_dir <- value
      i <- i + 2L
      next
    }
    stop("Unknown command-line argument: ", arg, call. = FALSE)
  }

  if (!parsed$mode %in% c("preflight", "smoke", "full")) {
    stop("--mode must be preflight, smoke, or full.", call. = FALSE)
  }
  parsed
}

task13_atomic_fwrite <- function(object, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  temporary <- tempfile(pattern = paste0(basename(path), "."), tmpdir = dirname(path))
  data.table::fwrite(object, temporary, na = "NA")
  if (!file.rename(temporary, path)) {
    unlink(temporary)
    stop("Atomic write failed for ", path, call. = FALSE)
  }
  invisible(path)
}

task13_parameter_manifest <- function(parameters) {
  scalar <- vapply(parameters, length, integer(1)) == 1L
  data.table::data.table(
    parameter = names(parameters)[scalar],
    value = vapply(parameters[scalar], as.character, character(1))
  )
}

task13_code_manifest <- function() {
  files <- c(
    "run_finite_T_dynamic_panel.R",
    file.path("R", c("config.R", "dgp.R", "estimators.R", "simulation.R", "metrics.R")),
    file.path("tests", "smoke_test.R"),
    "finite_T_dynamic_panel_report.Rmd"
  )
  paths <- file.path(task13_root, files)
  exists <- file.exists(paths)
  data.table::data.table(
    file = files,
    exists = exists,
    md5 = ifelse(exists, unname(tools::md5sum(paths)), NA_character_)
  )
}

task13_write_outputs <- function(raw, grid, repetitions, parameters, output_dir, mode) {
  expected <- task13_expected_raw_columns()
  if (!identical(names(raw), expected)) {
    stop("Raw output schema differs from the pre-specified schema.", call. = FALSE)
  }

  summary <- task13_summarise_results(raw, repetitions)
  stability <- task13_stability_checks(raw, summary, repetitions)
  failures <- task13_failures(raw)

  task13_atomic_fwrite(grid, file.path(output_dir, "design_grid.csv"))
  task13_atomic_fwrite(raw, file.path(output_dir, "raw_replications.csv"))
  task13_atomic_fwrite(summary, file.path(output_dir, "scenario_estimator_summary.csv"))
  task13_atomic_fwrite(stability, file.path(output_dir, "stability_checks.csv"))
  task13_atomic_fwrite(failures, file.path(output_dir, "failures.csv"))
  task13_atomic_fwrite(
    task13_parameter_manifest(parameters),
    file.path(output_dir, "parameter_manifest.csv")
  )
  task13_atomic_fwrite(
    task13_code_manifest(),
    file.path(output_dir, "code_manifest.csv")
  )
  task13_atomic_fwrite(
    data.table::data.table(
      mode = mode,
      repetitions = repetitions,
      base_seed = parameters$base_seed,
      scenario_count = nrow(grid),
      estimator_count = data.table::uniqueN(raw$estimator_id),
      expected_rows = nrow(grid) * repetitions * data.table::uniqueN(raw$estimator_id),
      actual_rows = nrow(raw),
      completed_utc = format(Sys.time(), tz = "UTC", usetz = TRUE)
    ),
    file.path(output_dir, "run_manifest.csv")
  )
  writeLines(capture.output(sessionInfo()), file.path(output_dir, "session_info.txt"))

  list(summary = summary, stability = stability, failures = failures)
}

task13_render_report <- function(output_dir) {
  task13_check_packages(include_report = TRUE)
  report <- file.path(task13_root, "finite_T_dynamic_panel_report.Rmd")
  rmarkdown::render(
    report,
    output_format = "pdf_document",
    output_file = "finite_T_dynamic_panel_report.pdf",
    output_dir = normalizePath(output_dir, mustWork = TRUE),
    params = list(input_dir = normalizePath(output_dir, mustWork = TRUE)),
    envir = new.env(parent = globalenv()),
    quiet = FALSE
  )
}

task13_main <- function() {
  args <- task13_parse_args(commandArgs(trailingOnly = TRUE))
  parameters <- task13_parameters()
  task13_check_packages(include_report = args$render_report)
  full_grid <- task13_full_grid(parameters)
  validation <- task13_validate_grid(full_grid, parameters)

  if (args$mode == "preflight") {
    print(validation)
    message("Task 13 preflight PASS: 54 principal and 18 stress scenarios.")
    return(invisible(validation))
  }

  if (args$mode == "full" && !isTRUE(args$approved)) {
    stop(
      "Full grid is gated. Re-run with --approved only after independent code review.",
      call. = FALSE
    )
  }

  if (is.na(args$repetitions)) {
    args$repetitions <- if (args$mode == "smoke") 2L else parameters$default_repetitions
  }
  if (!is.finite(args$repetitions) || args$repetitions < 1L) {
    stop("--reps must be a positive integer.", call. = FALSE)
  }

  grid <- if (args$mode == "smoke") full_grid[1L] else full_grid
  output_dir <- args$output_dir
  temporary_output <- is.null(output_dir) && args$mode == "smoke"
  if (temporary_output) {
    output_dir <- tempfile("task13_smoke_")
  } else if (is.null(output_dir)) {
    output_dir <- file.path(task13_root, "results")
  }
  if (!grepl("^/", output_dir)) {
    output_dir <- file.path(task13_repo_root, output_dir)
  }
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  output_dir <- normalizePath(output_dir, mustWork = TRUE)

  final_files <- file.path(
    output_dir,
    c("raw_replications.csv", "scenario_estimator_summary.csv")
  )
  if (any(file.exists(final_files)) && !isTRUE(args$overwrite)) {
    stop(
      "Output files already exist. Use --overwrite only after preserving the prior run.",
      call. = FALSE
    )
  }

  checkpoint_dir <- file.path(output_dir, "checkpoints")
  checkpoint_callback <- function(scenario, scenario_raw) {
    checkpoint_path <- file.path(
      checkpoint_dir,
      paste0(scenario$scenario_id, ".csv")
    )
    task13_atomic_fwrite(scenario_raw, checkpoint_path)
  }

  raw <- task13_run_grid(
    grid = grid,
    repetitions = args$repetitions,
    parameters = parameters,
    include_ab = args$include_ab,
    progress = TRUE,
    checkpoint_callback = checkpoint_callback
  )
  outputs <- task13_write_outputs(
    raw = raw,
    grid = grid,
    repetitions = args$repetitions,
    parameters = parameters,
    output_dir = output_dir,
    mode = args$mode
  )

  if (isTRUE(args$render_report)) {
    task13_render_report(output_dir)
  }

  message("Task 13 ", args$mode, " run complete: ", output_dir)
  message("Estimator failures: ", nrow(outputs$failures))
  if (temporary_output) {
    message("Smoke outputs are temporary and will not modify repository results.")
  }
  invisible(outputs)
}

task13_main()
