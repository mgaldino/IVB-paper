# =============================================================================
# Figures for TWFE Monte Carlo Simulation v4
#
# Reads sim_ivb_twfe_v4_mech{A,B,C,D}.csv and generates diagnostic figures.
# See plan: quality_reports/plans/2026-02-28_sim-ivb-twfe-v4.md
#
# Dependencies: data.table, ggplot2
# =============================================================================

library(data.table)
library(ggplot2)

theme_set(theme_minimal(base_size = 13))
dir.create("plots", showWarnings = FALSE)

# Load results
res_A <- fread("sim_ivb_twfe_v4_mechA.csv")
res_B <- fread("sim_ivb_twfe_v4_mechB.csv")
res_C <- fread("sim_ivb_twfe_v4_mechC.csv")
res_D <- fread("sim_ivb_twfe_v4_mechD.csv")

cat(sprintf("Loaded: A=%d, B=%d, C=%d, D=%d scenarios\n",
            nrow(res_A), nrow(res_B), nrow(res_C), nrow(res_D)))


# =============================================================================
# Figure 1: Heatmap A — |IVB/beta| vs (gamma_D_btw, gamma_D_wth)
# Key prediction: horizontal bands (IVB depends on gamma_D_wth, NOT gamma_D_btw)
# =============================================================================

# Average over R2_within
heat_A <- res_A[gamma_Y > 0,
                .(ivb_pct = mean(mean_abs_ivb_over_beta) * 100),
                by = .(gamma_D_btw, gamma_D_wth, gamma_Y)]

p1 <- ggplot(heat_A, aes(x = factor(gamma_D_btw), y = factor(gamma_D_wth),
                           fill = ivb_pct)) +
  geom_tile(color = "white", linewidth = 0.5) +
  geom_text(aes(label = sprintf("%.1f", ivb_pct)), size = 3) +
  facet_wrap(~ paste0("gamma[Y] == ", gamma_Y), labeller = label_parsed) +
  scale_fill_gradient(low = "white", high = "firebrick",
                      name = "|IVB/beta| (%)") +
  labs(
    title = "Mechanism A: IVB depends on within channel, not between",
    subtitle = "Horizontal bands: gamma_D_btw (absorbed by FE) does not affect IVB | Averaged over R2_within",
    x = expression(gamma[D]^{btw} ~ " (D" %->% "Z between, absorbed by FE)"),
    y = expression(gamma[D]^{wth} ~ " (D" %->% "Z within, survives FE)")
  )

ggsave("plots/v4_heatmap_A_btw_wth.png", p1, width = 12, height = 5, dpi = 150)
cat("Saved: plots/v4_heatmap_A_btw_wth.png\n")


# =============================================================================
# Figure 2: Line A — |IVB/beta| vs gamma_D_btw (should be flat)
# =============================================================================

line_A <- res_A[gamma_Y > 0,
                .(ivb_pct = mean(mean_abs_ivb_over_beta) * 100),
                by = .(gamma_D_btw, gamma_D_wth, gamma_Y)]

p2 <- ggplot(line_A, aes(x = gamma_D_btw, y = ivb_pct,
                           color = factor(gamma_D_wth),
                           shape = factor(gamma_D_wth))) +
  geom_point(size = 2.5) +
  geom_line(linewidth = 0.7) +
  facet_wrap(~ paste0("gamma[Y] == ", gamma_Y), labeller = label_parsed) +
  labs(
    title = "FE absorbs the between channel: IVB is flat in gamma_D_btw",
    subtitle = "Each line = different gamma_D_wth | Lines are flat because FE removes between variation",
    x = expression(gamma[D]^{btw} ~ " (between channel, absorbed)"),
    y = "|IVB/beta| (%)",
    color = expression(gamma[D]^{wth}),
    shape = expression(gamma[D]^{wth})
  )

ggsave("plots/v4_line_A_flat_btw.png", p2, width = 12, height = 5, dpi = 150)
cat("Saved: plots/v4_line_A_flat_btw.png\n")


# =============================================================================
# Figure 3: Comparison — IVB as function of within share of D->Z channel
# Shows that when most of D->Z is between, IVB is small
# =============================================================================

# Compute share_within = gamma_D_wth / (gamma_D_btw + gamma_D_wth)
comp_A <- res_A[gamma_Y > 0 & (gamma_D_btw + gamma_D_wth) > 0]
comp_A[, share_wth := gamma_D_wth / (gamma_D_btw + gamma_D_wth)]
comp_A_agg <- comp_A[, .(ivb_pct = mean(mean_abs_ivb_over_beta) * 100),
                      by = .(share_wth, gamma_Y)]

p3 <- ggplot(comp_A_agg, aes(x = share_wth, y = ivb_pct,
                               color = factor(gamma_Y),
                               shape = factor(gamma_Y))) +
  geom_point(size = 3) +
  geom_line(linewidth = 0.7) +
  labs(
    title = "IVB increases with within-share of D->Z channel",
    subtitle = "When D->Z is primarily between (left), FE absorbs it and IVB is small",
    x = "Within share of D->Z channel  (gamma_D_wth / (gamma_D_btw + gamma_D_wth))",
    y = "|IVB/beta| (%)",
    color = expression(gamma[Y]),
    shape = expression(gamma[Y])
  ) +
  scale_x_continuous(labels = scales::percent_format())

ggsave("plots/v4_ivb_vs_share_within.png", p3, width = 10, height = 6, dpi = 150)
cat("Saved: plots/v4_ivb_vs_share_within.png\n")


# =============================================================================
# Figure 4: Heatmap B — |IVB/beta| vs (gamma_Y_btw, gamma_Y_wth)
# Key prediction: horizontal bands (theta* depends on gamma_Y_wth, not btw)
# =============================================================================

heat_B <- res_B[, .(ivb_pct = mean(mean_abs_ivb_over_beta) * 100),
                by = .(gamma_Y_btw, gamma_Y_wth, gamma_D)]

p4 <- ggplot(heat_B, aes(x = factor(gamma_Y_btw), y = factor(gamma_Y_wth),
                           fill = ivb_pct)) +
  geom_tile(color = "white", linewidth = 0.5) +
  geom_text(aes(label = sprintf("%.1f", ivb_pct)), size = 3) +
  facet_wrap(~ paste0("gamma[D] == ", gamma_D), labeller = label_parsed) +
  scale_fill_gradient(low = "white", high = "steelblue",
                      name = "|IVB/beta| (%)") +
  labs(
    title = "Mechanism B: theta* depends on Y->Z within, not between",
    subtitle = "Horizontal bands: gamma_Y_btw (absorbed by FE) does not affect IVB | Averaged over R2_within",
    x = expression(gamma[Y]^{btw} ~ " (Y" %->% "Z between, absorbed by FE)"),
    y = expression(gamma[Y]^{wth} ~ " (Y" %->% "Z within, survives FE)")
  )

ggsave("plots/v4_heatmap_B_btw_wth.png", p4, width = 10, height = 5, dpi = 150)
cat("Saved: plots/v4_heatmap_B_btw_wth.png\n")


# =============================================================================
# Figure 5: Bar C — |IVB/SE| vs prob_switch
# Key prediction: IVB/SE decreases with fewer switchers
# =============================================================================

bar_C <- res_C[, .(ivb_se = mean(mean_abs_ivb_over_se),
                   se_long = mean(mean_se_long)),
               by = .(prob_switch, gamma_D, gamma_Y)]
bar_C[, label := paste0("gD=", gamma_D, ", gY=", gamma_Y)]

p5 <- ggplot(bar_C, aes(x = factor(prob_switch), y = ivb_se, fill = label)) +
  geom_col(position = "dodge", alpha = 0.8) +
  labs(
    title = "Mechanism C: Fewer switchers -> IVB less detectable",
    subtitle = "Binary D with staggered adoption | Fewer switchers = larger SE = smaller |IVB/SE|",
    x = "Probability of switching (prob_switch)",
    y = "|IVB| / SE(beta_long)",
    fill = "Parameters"
  ) +
  scale_fill_brewer(palette = "Set2")

ggsave("plots/v4_bar_C_switchers.png", p5, width = 10, height = 6, dpi = 150)
cat("Saved: plots/v4_bar_C_switchers.png\n")

# Also show SE increasing with fewer switchers
p5b <- ggplot(bar_C, aes(x = prob_switch, y = se_long,
                          color = label, shape = label)) +
  geom_point(size = 3) +
  geom_line(linewidth = 0.7) +
  labs(
    title = "Mechanism C: SE increases with fewer switchers",
    subtitle = "Never-treated and always-treated units contribute zero within variation",
    x = "Probability of switching",
    y = "Mean SE(beta_long)",
    color = "Parameters", shape = "Parameters"
  )

ggsave("plots/v4_line_C_se.png", p5b, width = 10, height = 6, dpi = 150)
cat("Saved: plots/v4_line_C_se.png\n")


# =============================================================================
# Figure 6: Line D — |theta*| vs sigma2_me (attenuation bias)
# =============================================================================

line_D <- res_D[, .(abs_theta = mean(abs(mean_theta)),
                    ivb_pct = mean(mean_abs_ivb_over_beta) * 100),
                by = .(sigma2_me, gamma_D, gamma_Y)]
line_D[, label := paste0("gD=", gamma_D, ", gY=", gamma_Y)]

p6 <- ggplot(line_D, aes(x = sigma2_me, y = abs_theta,
                           color = label, shape = label)) +
  geom_point(size = 3) +
  geom_line(linewidth = 0.7) +
  labs(
    title = "Mechanism D: Measurement error attenuates theta*",
    subtitle = "Classic attenuation bias | More noise in Z -> theta* shrinks -> IVB shrinks",
    x = expression(sigma[me]^2 ~ " (measurement error variance)"),
    y = expression("|" * hat(theta) * "*|"),
    color = "Parameters", shape = "Parameters"
  )

ggsave("plots/v4_line_D_attenuation.png", p6, width = 10, height = 6, dpi = 150)
cat("Saved: plots/v4_line_D_attenuation.png\n")

# Also IVB directly
p6b <- ggplot(line_D, aes(x = sigma2_me, y = ivb_pct,
                            color = label, shape = label)) +
  geom_point(size = 3) +
  geom_line(linewidth = 0.7) +
  labs(
    title = "Mechanism D: IVB shrinks with measurement error in Z",
    subtitle = "Attenuation of theta* directly reduces IVB",
    x = expression(sigma[me]^2 ~ " (measurement error variance)"),
    y = "|IVB/beta| (%)",
    color = "Parameters", shape = "Parameters"
  )

ggsave("plots/v4_line_D_ivb.png", p6b, width = 10, height = 6, dpi = 150)
cat("Saved: plots/v4_line_D_ivb.png\n")


# =============================================================================
# Figure 7: Synthesis table — conditions for IVB < 1 SE
# =============================================================================

cat("\n=== SYNTHESIS TABLE ===\n\n")

# Mechanism A: when is |IVB/SE| < 1?
cat("[A] Scenarios with |IVB/SE| < 1 (IVB invisible to inference):\n")
small_A <- res_A[mean_abs_ivb_over_se < 1]
cat(sprintf("  %d / %d scenarios (%.0f%%)\n",
            nrow(small_A), nrow(res_A), 100 * nrow(small_A) / nrow(res_A)))
if (nrow(small_A) > 0) {
  cat("  Typical: gamma_D_wth = ",
      paste(sort(unique(small_A$gamma_D_wth)), collapse = ", "), "\n")
}

cat("\n[B] Scenarios with |IVB/SE| < 1:\n")
small_B <- res_B[mean_abs_ivb_over_se < 1]
cat(sprintf("  %d / %d scenarios (%.0f%%)\n",
            nrow(small_B), nrow(res_B), 100 * nrow(small_B) / nrow(res_B)))

cat("\n[C] Scenarios with |IVB/SE| < 1:\n")
small_C <- res_C[mean_abs_ivb_over_se < 1]
cat(sprintf("  %d / %d scenarios (%.0f%%)\n",
            nrow(small_C), nrow(res_C), 100 * nrow(small_C) / nrow(res_C)))

cat("\n[D] Scenarios with |IVB/SE| < 1:\n")
small_D <- res_D[mean_abs_ivb_over_se < 1]
cat(sprintf("  %d / %d scenarios (%.0f%%)\n",
            nrow(small_D), nrow(res_D), 100 * nrow(small_D) / nrow(res_D)))

# Combined summary
# Save synthesis table as CSV
synthesis <- rbind(
  res_A[, .(mechanism = "A", ivb_se = mean_abs_ivb_over_se, ivb_pct = mean_abs_ivb_over_beta * 100)],
  res_B[, .(mechanism = "B", ivb_se = mean_abs_ivb_over_se, ivb_pct = mean_abs_ivb_over_beta * 100)],
  res_C[, .(mechanism = "C", ivb_se = mean_abs_ivb_over_se, ivb_pct = mean_abs_ivb_over_beta * 100)],
  res_D[, .(mechanism = "D", ivb_se = mean_abs_ivb_over_se, ivb_pct = mean_abs_ivb_over_beta * 100)]
)
synthesis_summary <- synthesis[, .(
  n_scenarios = .N,
  n_ivb_se_lt1 = sum(ivb_se < 1),
  pct_ivb_se_lt1 = round(100 * mean(ivb_se < 1), 1),
  median_ivb_pct = round(median(ivb_pct), 2),
  max_ivb_pct = round(max(ivb_pct), 2)
), by = mechanism]
fwrite(synthesis_summary, "sim_ivb_twfe_v4_synthesis.csv")
cat("Saved: sim_ivb_twfe_v4_synthesis.csv\n")
print(synthesis_summary)

cat("\n--- Key insights ---\n")
cat("A: FE absorbs between channel of D->Z. If D causes Z mainly in levels,\n")
cat("   pi is small after FE, and IVB is small.\n")
cat("B: FE absorbs between channel of Y->Z. If Y-Z correlation is mainly\n")
cat("   cross-sectional, theta* is small after FE, and IVB is small.\n")
cat("C: Binary D with few switchers: population IVB unchanged, but SE is\n")
cat("   large -> IVB/SE small -> invisible to inference.\n")
cat("D: Measurement error in Z attenuates theta* toward zero,\n")
cat("   reducing IVB proportionally.\n")

cat("\n=== DONE ===\n")
