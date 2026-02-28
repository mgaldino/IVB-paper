# =============================================================================
# Figures for TWFE Monte Carlo Simulation
#
# Reads sim_ivb_twfe_results.csv and generates diagnostic figures.
# See plan: quality_reports/plans/2026-02-27_sim-ivb-twfe.md
#
# Dependencies: data.table, ggplot2
# =============================================================================

library(data.table)
library(ggplot2)

theme_set(theme_minimal(base_size = 13))

dir.create("plots", showWarnings = FALSE)

# Load results
results <- fread("sim_ivb_twfe_results.csv")
results <- results[stable == TRUE]

cat(sprintf("Loaded %d scenarios (stable).\n", nrow(results)))


# =============================================================================
# Figure 1: Heatmap — |IVB/beta| by (gamma_Y, gamma_D) for each delta
# =============================================================================

# Average over R2_within (since IVB/|beta| should be ~constant in R2_within)
heatmap_dt <- results[, .(ivb_pct = mean(mean_abs_ivb_over_beta) * 100),
                      by = .(gamma_Y, gamma_D, delta)]

p1 <- ggplot(heatmap_dt, aes(x = factor(gamma_D), y = factor(gamma_Y),
                              fill = ivb_pct)) +
  geom_tile(color = "white", linewidth = 0.5) +
  geom_text(aes(label = sprintf("%.1f", ivb_pct)), size = 2.8) +
  facet_wrap(~ paste0("delta == ", delta), labeller = label_parsed, nrow = 1) +
  scale_fill_gradient(
    low = "white", high = "firebrick",
    name = "|IVB/beta| (%)"
  ) +
  labs(
    title = "|IVB| as percentage of true effect, by collider/confounder strength",
    subtitle = "Averaged over R2_within | N=200, T=30, beta=1",
    x = expression(gamma[D] ~ " (D" %->% "Z)"),
    y = expression(gamma[Y] ~ " (Y" %->% "Z)")
  ) +
  theme(strip.text = element_text(size = 10))

ggsave("plots/twfe_heatmap_ivb.png", p1, width = 14, height = 5, dpi = 150)
cat("Saved: plots/twfe_heatmap_ivb.png\n")


# =============================================================================
# Figure 2: Line plots — IVB/|beta| and IVB/SE vs R2_within
# =============================================================================

# 2a: IVB/|beta| vs R2_within — should be flat (key theoretical prediction)
line_dt <- results[gamma_Y > 0,
                   .(ivb_pct = mean(mean_abs_ivb_over_beta) * 100,
                     ivb_se  = mean(mean_abs_ivb_over_se)),
                   by = .(gamma_Y, gamma_D, delta, R2_within)]

p2a <- ggplot(line_dt[delta == 0],
              aes(x = R2_within, y = ivb_pct,
                  color = factor(gamma_Y), shape = factor(gamma_Y))) +
  geom_point(size = 2) +
  geom_line(linewidth = 0.6) +
  facet_wrap(~ paste0("gamma[D] == ", gamma_D), labeller = label_parsed) +
  labs(
    title = "|IVB/beta| vs within-variance share (clean case, delta=0)",
    subtitle = "If flat: IVB magnitude depends on structural parameters, not variance decomposition",
    x = expression(R[within]^2),
    y = "|IVB/beta| (%)",
    color = expression(gamma[Y]),
    shape = expression(gamma[Y])
  )

ggsave("plots/twfe_ivb_vs_r2within_clean.png", p2a, width = 12, height = 7, dpi = 150)
cat("Saved: plots/twfe_ivb_vs_r2within_clean.png\n")

# 2b: IVB/SE vs R2_within — should increase (more within var -> smaller SE)
p2b <- ggplot(line_dt[delta == 0],
              aes(x = R2_within, y = ivb_se,
                  color = factor(gamma_Y), shape = factor(gamma_Y))) +
  geom_point(size = 2) +
  geom_line(linewidth = 0.6) +
  facet_wrap(~ paste0("gamma[D] == ", gamma_D), labeller = label_parsed) +
  labs(
    title = "|IVB/SE| vs within-variance share (clean case, delta=0)",
    subtitle = "Should increase: more within variation -> smaller SEs -> IVB matters more for inference",
    x = expression(R[within]^2),
    y = "|IVB| / SE(beta_long)",
    color = expression(gamma[Y]),
    shape = expression(gamma[Y])
  )

ggsave("plots/twfe_ivbse_vs_r2within_clean.png", p2b, width = 12, height = 7, dpi = 150)
cat("Saved: plots/twfe_ivbse_vs_r2within_clean.png\n")

# 2c: Full grid with delta coloring
p2c <- ggplot(line_dt[gamma_D > 0],
              aes(x = R2_within, y = ivb_pct,
                  color = factor(delta), shape = factor(delta))) +
  geom_point(size = 2) +
  geom_line(linewidth = 0.6) +
  facet_grid(gamma_Y ~ gamma_D,
             labeller = label_bquote(
               rows = gamma[Y] == .(gamma_Y),
               cols = gamma[D] == .(gamma_D)
             )) +
  labs(
    title = "|IVB/beta| vs R2_within, by structural parameters (positive gamma_D)",
    x = expression(R[within]^2),
    y = "|IVB/beta| (%)",
    color = expression(delta),
    shape = expression(delta)
  )

ggsave("plots/twfe_ivb_vs_r2within_full.png", p2c, width = 12, height = 10, dpi = 150)
cat("Saved: plots/twfe_ivb_vs_r2within_full.png\n")


# =============================================================================
# Figure 3: Scatter — bias_short vs bias_long (which model is better?)
# =============================================================================

results[, abs_bias_short := abs(bias_short)]
results[, abs_bias_long := abs(bias_long)]
results[, case := ifelse(delta == 0, "Clean (delta=0)", "Dirty (delta!=0)")]

p3 <- ggplot(results, aes(x = abs_bias_short, y = abs_bias_long,
                           color = factor(delta))) +
  geom_point(alpha = 0.5, size = 1.5) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "grey40") +
  facet_wrap(~ case, scales = "free") +
  labs(
    title = "Which model has less bias? Short (without Z) vs Long (with Z)",
    subtitle = "Points below diagonal: long model has less bias | Above: short model has less bias",
    x = "|Bias| of short model (without Z)",
    y = "|Bias| of long model (with Z)",
    color = expression(delta)
  ) +
  scale_color_brewer(palette = "RdYlBu")

ggsave("plots/twfe_bias_comparison.png", p3, width = 12, height = 5, dpi = 150)
cat("Saved: plots/twfe_bias_comparison.png\n")

# Same but with RMSE
p3b <- ggplot(results, aes(x = rmse_short, y = rmse_long,
                            color = factor(delta))) +
  geom_point(alpha = 0.5, size = 1.5) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "grey40") +
  facet_wrap(~ case, scales = "free") +
  labs(
    title = "Which model has lower RMSE? Short vs Long",
    subtitle = "Points below diagonal: long model is better | Above: short model is better",
    x = "RMSE of short model",
    y = "RMSE of long model",
    color = expression(delta)
  ) +
  scale_color_brewer(palette = "RdYlBu")

ggsave("plots/twfe_rmse_comparison.png", p3b, width = 12, height = 5, dpi = 150)
cat("Saved: plots/twfe_rmse_comparison.png\n")


# =============================================================================
# Figure 4: Boxplot — IVB/SD(Y) distribution, comparable to empirical data
# =============================================================================

# Create label for scenario grouping
results[, scenario_label := paste0("gY=", gamma_Y, " gD=", gamma_D, " d=", delta)]

# For the boxplot, focus on scenarios with gamma_Y > 0 (actual collider)
box_dt <- results[gamma_Y > 0]

p4 <- ggplot(box_dt, aes(x = factor(gamma_Y), y = mean_abs_ivb_over_sd_y,
                          fill = factor(delta))) +
  geom_boxplot(outlier.size = 0.8, alpha = 0.7) +
  geom_hline(yintercept = 0.04, linetype = "dashed", color = "red", linewidth = 0.6) +
  annotate("text", x = -Inf, y = 0.045, label = "Max empirical |IVB/SD(Y)| ~ 0.04",
           hjust = -0.05, vjust = 0, size = 3.5, color = "red") +
  labs(
    title = "|IVB/SD(Y)| distribution across scenarios",
    subtitle = "Red dashed line: maximum observed in 7 empirical applications",
    x = expression(gamma[Y] ~ " (Y" %->% "Z)"),
    y = "|IVB| / SD(Y)",
    fill = expression(delta)
  )

ggsave("plots/twfe_ivb_sdy_boxplot.png", p4, width = 10, height = 6, dpi = 150)
cat("Saved: plots/twfe_ivb_sdy_boxplot.png\n")


# =============================================================================
# Figure 5: Coverage by scenario
# =============================================================================

# Show full distribution of coverage across gamma_D and R2_within
cov_long <- melt(results, id.vars = c("gamma_Y", "gamma_D", "delta", "R2_within"),
                 measure.vars = c("coverage_short", "coverage_long"),
                 variable.name = "model", value.name = "coverage")
cov_long[, model := ifelse(model == "coverage_short",
                            "Short (without Z)", "Long (with Z)")]

p5 <- ggplot(cov_long, aes(x = factor(gamma_Y), y = coverage,
                            fill = model)) +
  geom_boxplot(outlier.size = 0.5, alpha = 0.7) +
  geom_hline(yintercept = 0.95, linetype = "dashed", color = "grey40") +
  facet_wrap(~ paste0("delta = ", delta), nrow = 1) +
  labs(
    title = "95% CI coverage rate distribution by model and scenario",
    subtitle = "Boxplot across gamma_D and R2_within values | Dashed line: nominal 95%",
    x = expression(gamma[Y]),
    y = "Coverage rate",
    fill = "Model"
  ) +
  scale_fill_manual(values = c("Short (without Z)" = "steelblue",
                                "Long (with Z)" = "firebrick")) +
  coord_cartesian(ylim = c(0, 1))

ggsave("plots/twfe_coverage.png", p5, width = 14, height = 5, dpi = 150)
cat("Saved: plots/twfe_coverage.png\n")


# =============================================================================
# Summary Table
# =============================================================================

cat("\n=== SUMMARY TABLE: Large IVB scenarios ===\n\n")

large <- results[mean_abs_ivb_over_beta > 0.25][order(-mean_abs_ivb_over_beta)]
if (nrow(large) > 0) {
  cat(sprintf("%d scenarios with |IVB/beta| > 25%%\n", nrow(large)))
  print(large[1:min(20, .N),
              .(gamma_Y, gamma_D, delta, R2_within,
                ivb_pct = round(mean_abs_ivb_over_beta * 100, 1),
                ivb_se = round(mean_abs_ivb_over_se, 2),
                ivb_sdy = round(mean_abs_ivb_over_sd_y, 4),
                bias_short = round(bias_short, 4),
                bias_long = round(bias_long, 4),
                cov_short = round(coverage_short, 3),
                cov_long = round(coverage_long, 3))])
} else {
  cat("No scenarios with |IVB/beta| > 25%%.\n")
}

cat("\n=== DONE ===\n")
