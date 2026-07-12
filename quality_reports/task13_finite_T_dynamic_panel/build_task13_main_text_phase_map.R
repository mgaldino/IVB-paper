#!/usr/bin/env Rscript

options(scipen = 999)

required_packages <- c("data.table", "dplyr", "ggplot2", "tibble")
packages_available <- vapply(
  required_packages,
  requireNamespace,
  logical(1),
  quietly = TRUE
)
if (any(!packages_available)) {
  stop(
    "Missing required packages: ",
    paste(required_packages[!packages_available], collapse = ", ")
  )
}

command_args <- commandArgs(trailingOnly = FALSE)
script_argument <- grep("^--file=", command_args, value = TRUE)
if (length(script_argument) != 1L) {
  stop("Run this file with Rscript so the repository root can be resolved.")
}

script_path <- normalizePath(
  sub("^--file=", "", script_argument),
  mustWork = TRUE
)
output_dir <- dirname(script_path)
repo_root <- normalizePath(file.path(output_dir, "..", ".."), mustWork = TRUE)
input_path <- file.path(
  repo_root,
  "simulations",
  "finite_T_dynamic_panel",
  "results",
  "scenario_estimator_summary.csv"
)

if (!file.exists(input_path)) {
  stop("Task 13 summary file not found: ", input_path)
}

scenario_summary <- data.table::fread(input_path) |>
  tibble::as_tibble()

required_columns <- c(
  "scenario_id", "design_family", "N", "T", "rho_Y", "estimator_id",
  "estimator", "n_requested", "n_success", "bias", "coverage",
  "mean_delta_z", "bias_ge_abs_delta_z"
)
missing_columns <- setdiff(required_columns, names(scenario_summary))
if (length(missing_columns) > 0L) {
  stop("Missing required columns: ", paste(missing_columns, collapse = ", "))
}

estimator_labels <- c(
  fe_adl = "FE-ADL within",
  hpj_fe_adl = "Split-panel jackknife FE-ADL"
)
expected_N <- c(50L, 100L, 250L)
expected_T <- c(8L, 10L, 15L, 20L, 30L, 50L)
expected_rho_Y <- c(0.2, 0.5, 0.8)

principal_phase <- scenario_summary |>
  dplyr::filter(
    design_family == "principal",
    estimator_id %in% names(estimator_labels)
  ) |>
  dplyr::mutate(
    estimator_label = unname(estimator_labels[estimator_id]),
    phase_condition = abs(bias) >= abs(mean_delta_z)
  )

expected_grid <- expand.grid(
  estimator_id = names(estimator_labels),
  N = expected_N,
  T = expected_T,
  rho_Y = expected_rho_Y,
  KEEP.OUT.ATTRS = FALSE,
  stringsAsFactors = FALSE
) |>
  tibble::as_tibble()

observed_grid <- principal_phase |>
  dplyr::select(estimator_id, N, T, rho_Y)

duplicate_cells <- observed_grid |>
  dplyr::count(estimator_id, N, T, rho_Y) |>
  dplyr::filter(n != 1L)
missing_cells <- dplyr::anti_join(
  expected_grid,
  observed_grid,
  by = c("estimator_id", "N", "T", "rho_Y")
)
unexpected_cells <- dplyr::anti_join(
  observed_grid,
  expected_grid,
  by = c("estimator_id", "N", "T", "rho_Y")
)

if (nrow(duplicate_cells) > 0L ||
    nrow(missing_cells) > 0L ||
    nrow(unexpected_cells) > 0L) {
  stop("The principal-grid estimator cells do not match the pre-specified grid.")
}

metric_matrix <- principal_phase |>
  dplyr::select(bias, mean_delta_z, coverage) |>
  as.matrix()
if (any(!is.finite(metric_matrix))) {
  stop("The plotted principal-grid metrics contain missing or non-finite values.")
}
if (any(principal_phase$coverage < 0 | principal_phase$coverage > 1)) {
  stop("Coverage must lie in [0, 1].")
}
if (any(principal_phase$n_requested != 500L) ||
    any(principal_phase$n_success != principal_phase$n_requested)) {
  stop("Every plotted cell must contain all 500 requested replications.")
}
if (!identical(
  as.logical(principal_phase$bias_ge_abs_delta_z),
  principal_phase$phase_condition
)) {
  stop("The stored phase indicator does not match abs(bias) >= abs(mean_delta_z).")
}

estimator_summary <- principal_phase |>
  dplyr::group_by(estimator_id, estimator_label) |>
  dplyr::summarise(
    phase_cells = sum(phase_condition),
    total_cells = dplyr::n(),
    max_abs_bias = max(abs(bias)),
    max_abs_mean_shift = max(abs(mean_delta_z)),
    min_coverage = min(coverage),
    .groups = "drop"
  ) |>
  dplyr::arrange(match(estimator_id, names(estimator_labels)))

fe_summary <- estimator_summary |>
  dplyr::filter(estimator_id == "fe_adl")
hpj_summary <- estimator_summary |>
  dplyr::filter(estimator_id == "hpj_fe_adl")

main_text_summary <- data.frame(
  principal_cells_per_estimator = unique(estimator_summary$total_cells),
  fe_adl_phase_cells = fe_summary$phase_cells,
  hpj_fe_adl_phase_cells = hpj_summary$phase_cells,
  max_abs_bias = max(abs(principal_phase$bias)),
  max_abs_mean_shift = max(abs(principal_phase$mean_delta_z)),
  min_coverage = min(principal_phase$coverage),
  replications_per_cell = unique(principal_phase$n_requested),
  stringsAsFactors = FALSE
)

plot_data <- principal_phase |>
  dplyr::mutate(
    estimator_label = factor(
      estimator_label,
      levels = unname(estimator_labels)
    ),
    N_label = factor(
      paste0("N = ", N),
      levels = paste0("N = ", expected_N)
    ),
    T_label = factor(T, levels = expected_T),
    rho_Y_label = factor(
      sprintf("%.1f", rho_Y),
      levels = sprintf("%.1f", expected_rho_Y)
    ),
    phase_label = factor(
      ifelse(
        phase_condition,
        "Yes: |bias| >= |mean Delta_Z|",
        "No: |bias| < |mean Delta_Z|"
      ),
      levels = c(
        "No: |bias| < |mean Delta_Z|",
        "Yes: |bias| >= |mean Delta_Z|"
      )
    ),
    cell_label = ifelse(phase_condition, ">=", "<")
  )

phase_plot <- ggplot2::ggplot(
  plot_data,
  ggplot2::aes(x = T_label, y = rho_Y_label, fill = phase_label)
) +
  ggplot2::geom_tile(color = "white", linewidth = 0.65) +
  ggplot2::geom_text(
    ggplot2::aes(label = cell_label),
    color = "#1A1A1A",
    fontface = "bold",
    size = 3.1
  ) +
  ggplot2::facet_grid(rows = ggplot2::vars(estimator_label), cols = ggplot2::vars(N_label)) +
  ggplot2::scale_fill_manual(
    values = c(
      "No: |bias| < |mean Delta_Z|" = "#56B4E9",
      "Yes: |bias| >= |mean Delta_Z|" = "#E69F00"
    ),
    drop = FALSE
  ) +
  ggplot2::labs(
    x = "Observed periods (T)",
    y = expression("Outcome persistence (" * rho[Y] * ")"),
    fill = "Design-specific comparison"
  ) +
  ggplot2::theme_minimal(base_size = 9.5) +
  ggplot2::theme(
    panel.grid = ggplot2::element_blank(),
    panel.spacing = grid::unit(0.8, "lines"),
    strip.background = ggplot2::element_rect(fill = "#F2F2F2", color = "#B3B3B3"),
    strip.text = ggplot2::element_text(face = "bold", color = "#1A1A1A"),
    axis.text = ggplot2::element_text(color = "#1A1A1A"),
    axis.title = ggplot2::element_text(color = "#1A1A1A"),
    legend.position = "bottom",
    legend.title = ggplot2::element_text(face = "bold"),
    legend.key.height = grid::unit(0.45, "lines"),
    legend.margin = ggplot2::margin(t = 2, unit = "pt"),
    plot.margin = ggplot2::margin(5, 6, 3, 5)
  ) +
  ggplot2::guides(
    fill = ggplot2::guide_legend(
      nrow = 1,
      byrow = TRUE,
      override.aes = list(color = NA)
    )
  )

pdf_path <- file.path(output_dir, "task13_finite_T_phase_map.pdf")
png_path <- file.path(output_dir, "task13_finite_T_phase_map.png")
plot_data_path <- file.path(output_dir, "task13_finite_T_phase_map_data.csv")
estimator_summary_path <- file.path(output_dir, "task13_estimator_summary.csv")
main_text_summary_path <- file.path(output_dir, "task13_main_text_summary.csv")
validation_path <- file.path(output_dir, "task13_figure_validation.csv")

ggplot2::ggsave(
  filename = pdf_path,
  plot = phase_plot,
  width = 7.0,
  height = 4.65,
  units = "in",
  device = grDevices::pdf
)
ggplot2::ggsave(
  filename = png_path,
  plot = phase_plot,
  width = 7.0,
  height = 4.65,
  units = "in",
  dpi = 300,
  bg = "white"
)

data.table::fwrite(
  plot_data |>
    dplyr::select(
      scenario_id, estimator_id, estimator_label, N, T, rho_Y,
      bias, mean_delta_z, coverage, phase_condition
    ),
  plot_data_path
)
data.table::fwrite(estimator_summary, estimator_summary_path)
data.table::fwrite(main_text_summary, main_text_summary_path)

output_files <- c(pdf_path, png_path, plot_data_path, estimator_summary_path, main_text_summary_path)
outputs_valid <- all(file.exists(output_files)) && all(file.info(output_files)$size > 0)
if (!outputs_valid) {
  stop("One or more Task 13 main-text artifacts are missing or empty.")
}

validation <- data.frame(
  check = c(
    "required_columns_present",
    "principal_grid_exact",
    "metrics_finite_and_coverage_valid",
    "all_500_replications_successful",
    "stored_phase_indicator_matches_recalculation",
    "output_files_exist_and_are_nonempty"
  ),
  status = rep("PASS", 6L),
  stringsAsFactors = FALSE
)
data.table::fwrite(validation, validation_path)

message("Task 13 main-text phase map and summaries written to: ", output_dir)
