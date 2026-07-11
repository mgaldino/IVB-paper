#!/usr/bin/env Rscript

# Task 11: Rebuild the dual-role Figure 2 and firewall table from versioned
# simulation outputs only. This script never sources or runs a simulation.

options(scipen = 999)

required_packages <- c("ggplot2", "dplyr", "tidyr", "readr")
missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages) > 0L) {
  stop("Missing required packages: ", paste(missing_packages, collapse = ", "), call. = FALSE)
}

root <- normalizePath(".", mustWork = TRUE)
output_dir <- file.path(root, "quality_reports", "task11_dual_role_firewall")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

input_paths <- c(
  raw_8models = file.path(root, "simulations", "dual_role_z", "results", "sim_dual_role_z_8models_raw.csv"),
  summary_8models = file.path(root, "simulations", "dual_role_z", "results", "sim_dual_role_z_8models_results.csv"),
  firewall_summary = file.path(root, "simulations", "dual_role_z", "results", "sim_dual_role_z_firewall_results.csv")
)
if (!all(file.exists(input_paths))) {
  stop("One or more required result CSVs are missing.", call. = FALSE)
}

truth_beta <- 1
mc_multiplier <- stats::qnorm(0.975)
expected_repetitions <- 500L
tolerance <- 1e-10

model_lookup <- data.frame(
  raw_column = c("pooled_s.D", "pooled_l.D", "twfe_s.D", "twfe_l.D", "adl_s_nofe.D", "adl_l_nofe.D", "adl_s_fe.D", "adl_l_fe.D"),
  summary_prefix = c("pooled_s", "pooled_l", "twfe_s", "twfe_l", "adl_s_nofe", "adl_l_nofe", "adl_s_fe", "adl_l_fe"),
  model = c(
    "Pooled short", "Pooled + lagged Z", "TWFE short", "TWFE + lagged Z",
    "ADL + lagged Y (no FE)", "ADL + lagged Y and Z (no FE)",
    "ADL + FE", "ADL + FE + lagged Z"
  ),
  stringsAsFactors = FALSE
)

raw_8models <- readr::read_csv(input_paths[["raw_8models"]], show_col_types = FALSE)
summary_8models <- readr::read_csv(input_paths[["summary_8models"]], show_col_types = FALSE)
firewall_summary <- readr::read_csv(input_paths[["firewall_summary"]], show_col_types = FALSE)

required_raw <- c("sim", "rho_Z", "sigma_aZ", model_lookup$raw_column)
required_summary <- c("rho_Z", "sigma_aZ", "n_sims", paste0(model_lookup$summary_prefix, "_bias"), paste0(model_lookup$summary_prefix, "_mcse"))
required_firewall <- c("rho_Z", "rho_Y", "twfe_l_bias", "twfe_l_mcse", "adl_l_bias", "adl_l_mcse")
if (!all(required_raw %in% names(raw_8models)) ||
    !all(required_summary %in% names(summary_8models)) ||
    !all(required_firewall %in% names(firewall_summary))) {
  stop("A required CSV column is absent; no artifact was overwritten.", call. = FALSE)
}

raw_long <- raw_8models |>
  tidyr::pivot_longer(
    cols = dplyr::all_of(model_lookup$raw_column),
    names_to = "raw_column",
    values_to = "estimate"
  ) |>
  dplyr::left_join(model_lookup, by = "raw_column") |>
  dplyr::mutate(
    bias = .data$estimate - truth_beta,
    squared_error = (.data$estimate - truth_beta)^2
  )

replication_counts <- raw_long |>
  dplyr::group_by(.data$rho_Z, .data$sigma_aZ, .data$model) |>
  dplyr::summarise(repetitions_from_raw = dplyr::n(), .groups = "drop")
if (any(replication_counts$repetitions_from_raw != expected_repetitions)) {
  stop("The raw file does not contain 500 replications for every scenario/model.", call. = FALSE)
}
if (any(summary_8models$n_sims != expected_repetitions)) {
  stop("The published summary does not report 500 replications for every scenario.", call. = FALSE)
}

recalculated <- raw_long |>
  dplyr::group_by(.data$rho_Z, .data$sigma_aZ, .data$raw_column, .data$summary_prefix, .data$model) |>
  dplyr::summarise(
    mean_estimate = mean(.data$estimate),
    bias = mean(.data$bias),
    estimator_sd = stats::sd(.data$estimate),
    mcse = .data$estimator_sd / sqrt(dplyr::n()),
    rmse = sqrt(mean(.data$squared_error)),
    repetitions = dplyr::n(),
    .groups = "drop"
  ) |>
  dplyr::mutate(
    mc_lower = .data$bias - mc_multiplier * .data$mcse,
    mc_upper = .data$bias + mc_multiplier * .data$mcse,
    relative_bias = .data$bias / truth_beta
  )

published_long <- summary_8models |>
  tidyr::pivot_longer(
    cols = dplyr::matches("_(bias|mcse)$"),
    names_to = c("summary_prefix", ".value"),
    names_pattern = "(.*)_(bias|mcse)"
  ) |>
  dplyr::left_join(model_lookup, by = "summary_prefix") |>
  dplyr::select(rho_Z, sigma_aZ, raw_column, published_bias = bias, published_mcse = mcse)

mean_check <- recalculated |>
  dplyr::left_join(published_long, by = c("rho_Z", "sigma_aZ", "raw_column")) |>
  dplyr::mutate(
    bias_difference = .data$bias - .data$published_bias,
    mcse_difference = .data$mcse - .data$published_mcse,
    pass = abs(.data$bias_difference) <= tolerance & abs(.data$mcse_difference) <= tolerance
  )
if (any(!mean_check$pass) || any(is.na(mean_check$published_bias))) {
  stop("Recalculated means or MCSEs do not reproduce the published summary; artifact generation stopped.", call. = FALSE)
}

figure_models <- c("TWFE short", "TWFE + lagged Z", "ADL + FE", "ADL + FE + lagged Z")
figure_data <- recalculated |>
  dplyr::filter(.data$sigma_aZ == 0.5, .data$model %in% figure_models) |>
  dplyr::mutate(
    model = factor(.data$model, levels = figure_models),
    panel = "Bias relative to true beta",
    value = .data$relative_bias,
    lower = .data$mc_lower / truth_beta,
    upper = .data$mc_upper / truth_beta
  ) |>
  dplyr::select(rho_Z, sigma_aZ, model, panel, value, lower, upper, bias, mcse, rmse, repetitions) |>
  dplyr::bind_rows(
    recalculated |>
      dplyr::filter(.data$sigma_aZ == 0.5, .data$model %in% figure_models) |>
      dplyr::mutate(
        model = factor(.data$model, levels = figure_models),
        panel = "RMSE",
        value = .data$rmse,
        lower = NA_real_,
        upper = NA_real_
      ) |>
      dplyr::select(rho_Z, sigma_aZ, model, panel, value, lower, upper, bias, mcse, rmse, repetitions)
  ) |>
  dplyr::mutate(panel = factor(.data$panel, levels = c("Bias relative to true beta", "RMSE")))

model_colors <- c(
  "TWFE short" = "#B2182B",
  "TWFE + lagged Z" = "#2166AC",
  "ADL + FE" = "#4D9221",
  "ADL + FE + lagged Z" = "#222222"
)

figure_2 <- ggplot2::ggplot(figure_data, ggplot2::aes(x = .data$rho_Z, y = .data$value, colour = .data$model, group = .data$model)) +
  ggplot2::geom_hline(
    data = data.frame(panel = "Bias relative to true beta"),
    ggplot2::aes(yintercept = 0),
    inherit.aes = FALSE,
    linewidth = 0.85,
    linetype = "dashed",
    colour = "#595959"
  ) +
  ggplot2::geom_errorbar(
    data = function(x) x[x$panel == "Bias relative to true beta", ],
    ggplot2::aes(ymin = .data$lower, ymax = .data$upper),
    width = 0.018,
    linewidth = 0.5
  ) +
  ggplot2::geom_line(linewidth = 0.75) +
  ggplot2::geom_point(size = 2.15) +
  ggplot2::facet_wrap(~panel, scales = "free_y", ncol = 1) +
  ggplot2::scale_colour_manual(values = model_colors, name = "Specification") +
  ggplot2::scale_x_continuous(breaks = c(0.1, 0.3, 0.5, 0.7, 0.85)) +
  ggplot2::labs(
    x = expression(rho[Z]),
    y = NULL,
    caption = "Error bars in the bias panel are 95% Monte Carlo uncertainty intervals for the simulated mean bias (not estimator confidence intervals)."
  ) +
  ggplot2::guides(colour = ggplot2::guide_legend(nrow = 2, byrow = TRUE)) +
  ggplot2::theme_minimal(base_size = 10.5) +
  ggplot2::theme(
    legend.position = "bottom",
    legend.text = ggplot2::element_text(size = 8.5),
    legend.title = ggplot2::element_text(size = 8.5),
    strip.text = ggplot2::element_text(face = "bold"),
    panel.grid.minor = ggplot2::element_blank(),
    plot.caption = ggplot2::element_text(hjust = 0, size = 8)
  )

figure_pdf <- file.path(output_dir, "figure_2_dual_role_bias_rmse.pdf")
figure_png <- file.path(output_dir, "figure_2_dual_role_bias_rmse.png")
ggplot2::ggsave(figure_pdf, figure_2, width = 6.8, height = 7.0, units = "in", device = grDevices::pdf)
ggplot2::ggsave(figure_png, figure_2, width = 6.8, height = 7.0, units = "in", dpi = 320)

format_mc <- function(estimate, mcse, digits = 4L) {
  lower <- estimate - mc_multiplier * mcse
  upper <- estimate + mc_multiplier * mcse
  sprintf(paste0("%.", digits, "f [%.", digits, "f, %.", digits, "f]"), estimate, lower, upper)
}

firewall_table <- firewall_summary |>
  dplyr::mutate(
    firewall_gain = abs(.data$twfe_l_bias) - abs(.data$adl_l_bias),
    twfe_display = format_mc(.data$twfe_l_bias, .data$twfe_l_mcse),
    adl_display = format_mc(.data$adl_l_bias, .data$adl_l_mcse),
    gain_display = sprintf("%.4f", .data$firewall_gain)
  ) |>
  dplyr::arrange(.data$rho_Y, .data$rho_Z) |>
  dplyr::transmute(
    rho_Y = .data$rho_Y,
    rho_Z = .data$rho_Z,
    `TWFE + lagged Z: bias [MC 95% interval]` = .data$twfe_display,
    `ADL + FE + lagged Z: bias [MC 95% interval]` = .data$adl_display,
    `Absolute-bias reduction` = .data$gain_display,
    twfe_bias = .data$twfe_l_bias,
    twfe_mcse = .data$twfe_l_mcse,
    adl_bias = .data$adl_l_bias,
    adl_mcse = .data$adl_l_mcse,
    firewall_gain = .data$firewall_gain
  )

table_for_csv <- firewall_table |>
  dplyr::select(-twfe_bias, -twfe_mcse, -adl_bias, -adl_mcse, -firewall_gain)
readr::write_csv(figure_data, file.path(output_dir, "figure_2_plot_data.csv"))
readr::write_csv(table_for_csv, file.path(output_dir, "table_firewall_mc.csv"))

latex_escape <- function(x) gsub("_", "\\\\_", x, fixed = TRUE)
latex_line_break <- paste0(intToUtf8(92), intToUtf8(92))
table_rows <- apply(table_for_csv, 1, function(row) {
  paste0(paste(
    sprintf("%.1f", as.numeric(row[["rho_Y"]])),
    sprintf("%.2f", as.numeric(row[["rho_Z"]])),
    latex_escape(row[["TWFE + lagged Z: bias [MC 95% interval]"]]),
    latex_escape(row[["ADL + FE + lagged Z: bias [MC 95% interval]"]]),
    row[["Absolute-bias reduction"]],
    sep = " & "
  ), " ", latex_line_break)
})
latex_caption <- paste0(
  "Firewall mechanism in the dual-role DGP (true contemporaneous treatment effect $\\beta=1$). ",
  "Each cell reports simulated mean bias and its 95\\% Monte Carlo uncertainty interval in brackets; these are uncertainty intervals for the simulated mean, not confidence intervals for an estimator. ",
  "The absolute-bias reduction is $|\\mathrm{Bias}_{\\mathrm{TWFE}+Z_{t-1}}|-|\\mathrm{Bias}_{\\mathrm{ADL+FE}+Z_{t-1},Y_{t-1}}|$. ",
  "The existing firewall result artifact reports 500 replications per scenario; the associated dual-role design has $N=100$, $T=30$, and a burn-in of 100 periods. ",
  "Models include unit and time fixed effects."
)
latex_table <- c(
  "\\begin{table}[H]",
  "\\centering",
  paste0("\\caption{", latex_caption, "}"),
  "\\label{tab:firewall_pa}",
  "\\scriptsize",
  "\\begin{tabular}{rrlll}",
  "\\toprule",
  paste0("$\\rho_Y$ & $\\rho_Z$ & TWFE + $Z_{t-1}$: bias [MC 95\\% interval] & ADL + FE + $Z_{t-1}$: bias [MC 95\\% interval] & Absolute-bias reduction ", latex_line_break),
  "\\midrule",
  table_rows,
  "\\bottomrule",
  "\\end{tabular}",
  "\\end{table}"
)
writeLines(latex_table, file.path(output_dir, "table_firewall_mc.tex"), useBytes = TRUE)

manuscript_summary <- figure_data |>
  dplyr::filter(.data$panel == "Bias relative to true beta") |>
  dplyr::group_by(.data$model) |>
  dplyr::summarise(min_bias = min(.data$bias), max_bias = max(.data$bias), .groups = "drop") |>
  tidyr::pivot_wider(names_from = model, values_from = c(min_bias, max_bias), names_glue = "{.value}_{model}")
readr::write_csv(manuscript_summary, file.path(output_dir, "manuscript_summary.csv"))

validation <- data.frame(
  check = c(
    "raw replication count per model-scenario",
    "published replication count per scenario",
    "recalculated bias means reproduce published summary",
    "recalculated MCSEs reproduce published summary",
    "firewall grid has 12 scenarios"
  ),
  value = c(
    as.character(unique(replication_counts$repetitions_from_raw)),
    as.character(unique(summary_8models$n_sims)),
    format(max(abs(mean_check$bias_difference)), scientific = TRUE),
    format(max(abs(mean_check$mcse_difference)), scientific = TRUE),
    as.character(nrow(firewall_summary))
  ),
  threshold_or_expected = c("500", "500", "<= 1e-10", "<= 1e-10", "12"),
  pass = c(TRUE, TRUE, TRUE, TRUE, nrow(firewall_summary) == 12L),
  stringsAsFactors = FALSE
)
readr::write_csv(validation, file.path(output_dir, "validation.csv"))

manifest <- data.frame(
  source_artifact = c(
    "simulations/dual_role_z/results/sim_dual_role_z_8models_raw.csv",
    "simulations/dual_role_z/results/sim_dual_role_z_8models_results.csv",
    "simulations/dual_role_z/results/sim_dual_role_z_firewall_results.csv"
  ),
  md5 = unname(tools::md5sum(input_paths)),
  stringsAsFactors = FALSE
)
readr::write_csv(manifest, file.path(output_dir, "source_manifest.csv"))

message("Task 11 artifacts written to ", output_dir)
