# plot_nl_results.R
# Result-level plots for NL simulations
# 1. Bias by model across nl_strength (collider) — faceted by nl_type
# 2. IVB ratio across nl_strength — faceted by {TWFE, ADL}
# 3. RMSE comparison for selected scenarios

library(data.table)
library(ggplot2)

# ============================================================================
# Load data
# ============================================================================
co <- fread("results/sim_nl_collider_results.csv")
cr <- fread("results/sim_nl_carryover_results.csv")
it <- fread("results/sim_nl_interact_results.csv")

beta_true <- 1

# ============================================================================
# PLOT 1: Bias by model across nl_strength (collider, nl_Y=FALSE)
# ============================================================================

# Melt to long format: one row per (scenario, model)
mod_cols <- c("twfe_s_bias", "twfe_l_bias", "adl_Ylag_bias", "adl_full_bias",
              "adl_Dlag_bias", "adl_DYlag_bias", "adl_DZlag_bias",
              "adl_all_bias", "adl_all_nofe_bias")
mod_labels <- c("TWFE short", "TWFE long", "ADL(Y_lag)", "ADL(Y,Z_lag)",
                "ADL(D_lag)", "ADL(D,Y_lag)", "ADL(D,Z_lag)",
                "ADL(all lags)", "ADL(all, no FE)")

co_long <- melt(co, id.vars = c("nl_type", "nl_strength", "nl_Y", "rho_Z"),
                measure.vars = mod_cols, variable.name = "model", value.name = "bias")
co_long[, model_label := factor(mod_labels[match(model, mod_cols)], levels = mod_labels)]

# Focus on nl_Y=FALSE, rho_Z=0.5 for clarity
d1 <- co_long[nl_Y == FALSE & rho_Z == 0.5]

# Select key models for readability
key_models <- c("TWFE short", "TWFE long", "ADL(Y,Z_lag)", "ADL(all lags)", "ADL(all, no FE)")
d1_key <- d1[model_label %in% key_models]

p1 <- ggplot(d1_key, aes(x = nl_strength, y = bias, color = model_label, shape = model_label)) +
  geom_line(linewidth = 0.7) +
  geom_point(size = 2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  facet_wrap(~ nl_type, scales = "free_y", nrow = 1) +
  scale_color_brewer(palette = "Set1") +
  labs(title = "Bias by model and non-linearity type (rho_Z = 0.5, nl_Y = FALSE)",
       subtitle = "beta_true = 1. Ideal: bias = 0.",
       x = "nl_strength", y = "Bias (estimate - beta_true)",
       color = "Model", shape = "Model") +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom",
        legend.text = element_text(size = 8),
        strip.text = element_text(face = "bold"),
        plot.title = element_text(face = "bold"))

ggsave("../../plots/nl_bias_by_model_rhoZ05.png", p1, width = 12, height = 5, dpi = 150)

# Same for rho_Z = 0.7
d1_07 <- co_long[nl_Y == FALSE & rho_Z == 0.7 & model_label %in% key_models]

p1b <- ggplot(d1_07, aes(x = nl_strength, y = bias, color = model_label, shape = model_label)) +
  geom_line(linewidth = 0.7) +
  geom_point(size = 2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  facet_wrap(~ nl_type, scales = "free_y", nrow = 1) +
  scale_color_brewer(palette = "Set1") +
  labs(title = "Bias by model and non-linearity type (rho_Z = 0.7, nl_Y = FALSE)",
       subtitle = "beta_true = 1. Ideal: bias = 0.",
       x = "nl_strength", y = "Bias (estimate - beta_true)",
       color = "Model", shape = "Model") +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom",
        legend.text = element_text(size = 8),
        strip.text = element_text(face = "bold"),
        plot.title = element_text(face = "bold"))

ggsave("../../plots/nl_bias_by_model_rhoZ07.png", p1b, width = 12, height = 5, dpi = 150)

# ============================================================================
# PLOT 2: All 9 models, faceted by nl_type x rho_Z (nl_Y=FALSE only)
# ============================================================================

d_all <- co_long[nl_Y == FALSE]

p2 <- ggplot(d_all, aes(x = nl_strength, y = bias, color = model_label)) +
  geom_line(linewidth = 0.5, alpha = 0.8) +
  geom_point(size = 1.2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  facet_grid(rho_Z ~ nl_type, scales = "free_y",
             labeller = labeller(rho_Z = function(x) paste0("rho_Z = ", x))) +
  scale_color_manual(values = c(
    "TWFE short" = "#E41A1C", "TWFE long" = "#377EB8",
    "ADL(Y_lag)" = "#4DAF4A", "ADL(Y,Z_lag)" = "#984EA3",
    "ADL(D_lag)" = "#FF7F00", "ADL(D,Y_lag)" = "#A65628",
    "ADL(D,Z_lag)" = "#F781BF",
    "ADL(all lags)" = "#000000", "ADL(all, no FE)" = "#999999")) +
  labs(title = "Bias of all 9 models by NL type and rho_Z (nl_Y = FALSE)",
       subtitle = "beta_true = 1. ADL models cluster near 0; TWFE models show large bias.",
       x = "nl_strength", y = "Bias",
       color = "Model") +
  theme_minimal(base_size = 10) +
  theme(legend.position = "bottom",
        legend.text = element_text(size = 7),
        strip.text = element_text(face = "bold"),
        plot.title = element_text(face = "bold"))

ggsave("../../plots/nl_bias_all_models.png", p2, width = 13, height = 7, dpi = 150)

# ============================================================================
# PLOT 3: IVB ratio across nl_strength, faceted by TWFE vs ADL
# ============================================================================

co[, ivb_twfe := twfe_l_bias - twfe_s_bias]
co[, ivb_adl := adl_full_bias - adl_Ylag_bias]

bl <- co[nl_strength == 0, .(rho_Z, bl_twfe = ivb_twfe, bl_adl = ivb_adl)]
m <- merge(co[nl_strength > 0], bl, by = "rho_Z")
m[, ratio_twfe := ivb_twfe / bl_twfe]
m[, ratio_adl := ivb_adl / bl_adl]

m_long <- melt(m, id.vars = c("nl_type", "nl_strength", "nl_Y", "rho_Z"),
               measure.vars = c("ratio_twfe", "ratio_adl"),
               variable.name = "ivb_type", value.name = "ratio")
m_long[, ivb_label := fifelse(ivb_type == "ratio_twfe", "IVB (TWFE)", "IVB (ADL)")]
m_long[, nl_Y_label := fifelse(nl_Y, "nl_Y = TRUE", "nl_Y = FALSE")]

p3 <- ggplot(m_long[nl_Y == FALSE], aes(x = nl_strength, y = ratio,
                                          color = nl_type, shape = nl_type)) +
  geom_line(linewidth = 0.7) +
  geom_point(size = 2) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "grey50") +
  facet_grid(rho_Z ~ ivb_label,
             labeller = labeller(rho_Z = function(x) paste0("rho_Z = ", x))) +
  scale_color_brewer(palette = "Set2") +
  labs(title = "IVB ratio (non-linear / baseline) by NL type (nl_Y = FALSE)",
       subtitle = "Ratio = 1 means non-linearity has no effect on IVB. power1.5 diverges.",
       x = "nl_strength", y = "IVB ratio (nl / baseline)",
       color = "NL type", shape = "NL type") +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom",
        strip.text = element_text(face = "bold"),
        plot.title = element_text(face = "bold"))

ggsave("../../plots/nl_ivb_ratio.png", p3, width = 10, height = 6, dpi = 150)

# ============================================================================
# PLOT 4: Bias vs delta_DH (interact), TWFE vs ADL_all
# ============================================================================

it_long <- melt(it, id.vars = c("delta_DH", "rho_Z"),
                measure.vars = c("twfe_s_bias", "twfe_l_bias", "adl_full_bias",
                                 "adl_all_bias"),
                variable.name = "model", value.name = "bias")
it_long[, model_label := c("twfe_s_bias" = "TWFE short",
                            "twfe_l_bias" = "TWFE long",
                            "adl_full_bias" = "ADL(Y,Z_lag)",
                            "adl_all_bias" = "ADL(all lags)")[model]]

p4 <- ggplot(it_long, aes(x = delta_DH, y = bias, color = model_label, shape = model_label)) +
  geom_line(linewidth = 0.7) +
  geom_point(size = 2.5) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  facet_wrap(~ rho_Z, labeller = labeller(rho_Z = function(x) paste0("rho_Z = ", x))) +
  scale_color_brewer(palette = "Set1") +
  labs(title = "Interact (NL-1b): Bias vs delta_DH by model",
       subtitle = "TWFE bias grows with interaction strength; ADL stays near zero.",
       x = "delta_DH (interaction D*H in Z equation)",
       y = "Bias (estimate - beta_true)",
       color = "Model", shape = "Model") +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom",
        plot.title = element_text(face = "bold"))

ggsave("../../plots/nl_interact_bias.png", p4, width = 9, height = 4.5, dpi = 150)

# ============================================================================
# PLOT 5: Carryover — bias vs k (softclamp only), TWFE vs ADL_all
# ============================================================================

cr_sc <- cr[carryover_type == "softclamp" | beta_nl == 0]
cr_sc[, k := beta_nl]  # use beta_nl as x-axis

cr_long <- melt(cr_sc, id.vars = c("carryover_type", "k", "rho_Z"),
                measure.vars = c("twfe_s_bias", "twfe_l_bias", "adl_full_bias",
                                 "adl_all_bias"),
                variable.name = "model", value.name = "bias")
cr_long[, model_label := c("twfe_s_bias" = "TWFE short",
                            "twfe_l_bias" = "TWFE long",
                            "adl_full_bias" = "ADL(Y,Z_lag)",
                            "adl_all_bias" = "ADL(all lags)")[model]]

p5 <- ggplot(cr_long, aes(x = k, y = bias, color = model_label, shape = model_label)) +
  geom_line(linewidth = 0.7) +
  geom_point(size = 2.5) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  facet_wrap(~ rho_Z, labeller = labeller(rho_Z = function(x) paste0("rho_Z = ", x))) +
  scale_color_brewer(palette = "Set1") +
  labs(title = "Carryover (NL-2): Bias vs k (softclamp only)",
       subtitle = "TWFE bias is large and stable; ADL stays near zero across all k.",
       x = "k (non-linear carryover strength)",
       y = "Bias (estimate - beta_true)",
       color = "Model", shape = "Model") +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom",
        plot.title = element_text(face = "bold"))

ggsave("../../plots/nl_carryover_bias.png", p5, width = 9, height = 4.5, dpi = 150)

# ============================================================================
# PLOT 6: RMSE comparison for selected scenarios (collider)
# ============================================================================

rmse_cols <- c("twfe_s_rmse", "twfe_l_rmse", "adl_Ylag_rmse", "adl_full_rmse",
               "adl_Dlag_rmse", "adl_DYlag_rmse", "adl_DZlag_rmse",
               "adl_all_rmse", "adl_all_nofe_rmse")

# Select representative scenarios
sel <- co[(nl_strength == 0 & rho_Z == 0.5) |
          (nl_type == "log2" & nl_strength == 1 & nl_Y == FALSE & rho_Z == 0.5) |
          (nl_type == "softpoly2" & nl_strength == 2 & nl_Y == TRUE & rho_Z == 0.5) |
          (nl_type == "power1.5" & nl_strength == 0.5 & rho_Z == 0.5) |
          (nl_type == "log4" & nl_strength == 2 & nl_Y == FALSE & rho_Z == 0.5)]

sel[, scenario := paste0(nl_type, " s=", nl_strength, ifelse(nl_Y, " +Y²", ""))]
sel[nl_strength == 0, scenario := "baseline (linear)"]

sel_long <- melt(sel, id.vars = "scenario",
                 measure.vars = rmse_cols, variable.name = "model", value.name = "rmse")
sel_long[, model_label := factor(mod_labels[match(model, gsub("_bias$", "_rmse",
                                  paste0(gsub("_rmse$", "_bias", as.character(model)))))],
                                  levels = mod_labels)]
# Fix model labels
sel_long[, model_label := mod_labels[match(gsub("_rmse", "_bias", model), mod_cols)]]
sel_long[, model_label := factor(model_label, levels = mod_labels)]

p6 <- ggplot(sel_long, aes(x = model_label, y = rmse, fill = scenario)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  geom_hline(yintercept = 0, color = "grey50") +
  scale_fill_brewer(palette = "Set2") +
  labs(title = "RMSE comparison: selected scenarios (rho_Z = 0.5)",
       subtitle = "Lower is better. ADL models consistently outperform TWFE.",
       x = NULL, y = "RMSE",
       fill = "Scenario") +
  theme_minimal(base_size = 10) +
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 35, hjust = 1, size = 8),
        plot.title = element_text(face = "bold"))

ggsave("../../plots/nl_rmse_comparison.png", p6, width = 11, height = 5.5, dpi = 150)

cat("All plots saved:\n")
cat("  plots/nl_bias_by_model_rhoZ05.png\n")
cat("  plots/nl_bias_by_model_rhoZ07.png\n")
cat("  plots/nl_bias_all_models.png\n")
cat("  plots/nl_ivb_ratio.png\n")
cat("  plots/nl_interact_bias.png\n")
cat("  plots/nl_carryover_bias.png\n")
cat("  plots/nl_rmse_comparison.png\n")
