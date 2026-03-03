# plot_nl_functions.R
# Visualize the non-linear functions used in sim_nl_collider.R
# Two panels: (A) D-channel functions, (B) Y-channel (raw vs softclamp)

library(data.table)
library(ggplot2)

source("../utils/sim_nl_utils.R")  # run_pilot()

# ---- Get pilot values for calibration ----
P <- list(N = 100, TT = 30, T_burn = 100, beta = 1,
          rho_Y = 0.5, rho_D = 0.5,
          gamma_D = 0.15, gamma_Y = 0.2,
          delta_D = 0.1, delta_Y = 0.1,
          sigma_aZ = 0.5)

set.seed(2026)
pilot <- run_pilot(P, n_pilot = 10, return_Y = TRUE)
sd_D <- pilot$sd_D
sd_Y <- pilot$sd_Y

c_D <- 2 * sd_D
c_Y <- 2 * sd_Y

cat(sprintf("sd_D_within = %.4f, sd_Y_within = %.4f\n", sd_D, sd_Y))
cat(sprintf("c_D = %.4f, c_Y = %.4f\n", c_D, c_Y))

# ---- Panel A: D-channel functions (raw, not calibrated) ----
D_seq <- seq(-4 * sd_D, 4 * sd_D, length.out = 500)

dt_D <- rbindlist(list(
  data.table(D = D_seq, f = D_seq^2,                                    type = "D² (raw, unbounded)"),
  data.table(D = D_seq, f = log(1 + D_seq^2),                           type = "log2: log(1+D²)"),
  data.table(D = D_seq, f = log(1 + D_seq^4),                           type = "log4: log(1+D⁴)"),
  data.table(D = D_seq, f = D_seq^2 / (1 + (D_seq / c_D)^2),           type = "softpoly2: D²/(1+(D/c)²)"),
  data.table(D = D_seq, f = sign(D_seq) * abs(D_seq)^1.5,              type = "power1.5: sign(D)|D|^1.5")
))

# Order factor for legend
dt_D[, type := factor(type, levels = c("D² (raw, unbounded)",
                                         "log2: log(1+D²)",
                                         "log4: log(1+D⁴)",
                                         "softpoly2: D²/(1+(D/c)²)",
                                         "power1.5: sign(D)|D|^1.5"))]

p_D <- ggplot(dt_D, aes(x = D, y = f, color = type, linetype = type)) +
  geom_line(linewidth = 0.8) +
  geom_vline(xintercept = c(-sd_D, sd_D), linetype = "dotted", color = "grey50", linewidth = 0.4) +
  annotate("text", x = sd_D, y = max(dt_D$f) * 0.95,
           label = paste0("sd_D = ", round(sd_D, 2)), hjust = -0.1, size = 3, color = "grey40") +
  scale_color_manual(values = c("D² (raw, unbounded)" = "grey60",
                                 "log2: log(1+D²)" = "#E41A1C",
                                 "log4: log(1+D⁴)" = "#377EB8",
                                 "softpoly2: D²/(1+(D/c)²)" = "#4DAF4A",
                                 "power1.5: sign(D)|D|^1.5" = "#984EA3")) +
  scale_linetype_manual(values = c("D² (raw, unbounded)" = "dashed",
                                    "log2: log(1+D²)" = "solid",
                                    "log4: log(1+D⁴)" = "solid",
                                    "softpoly2: D²/(1+(D/c)²)" = "solid",
                                    "power1.5: sign(D)|D|^1.5" = "solid")) +
  labs(title = "A. Non-linear functions f(D) — D channel",
       subtitle = sprintf("Raw functions (not calibrated). c_D = 2·sd_D = %.2f", c_D),
       x = "D (within-unit, demeaned)", y = "f(D)",
       color = NULL, linetype = NULL) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom",
        legend.text = element_text(size = 8),
        plot.title = element_text(face = "bold"))

# ---- Panel A2: Same but calibrated (contribution = delta_nl * f(D)) at nl_strength=1 ----
# Calibration: delta_nl * f(sd_D) = nl_strength * delta_D * sd_D
# So delta_nl = delta_D * sd_D / f(sd_D) for nl_strength=1

delta_D_val <- P$delta_D
cal_log2 <- delta_D_val * sd_D / log(1 + sd_D^2)
cal_log4 <- delta_D_val * sd_D / log(1 + sd_D^4)
cal_sp2  <- delta_D_val * 1.25 / sd_D
cal_p15  <- delta_D_val / sqrt(sd_D)
cal_raw  <- delta_D_val / sd_D  # for reference D^2

dt_Dcal <- rbindlist(list(
  data.table(D = D_seq, f = cal_raw * D_seq^2,                                    type = "D² (raw, unbounded)"),
  data.table(D = D_seq, f = cal_log2 * log(1 + D_seq^2),                          type = "log2: log(1+D²)"),
  data.table(D = D_seq, f = cal_log4 * log(1 + D_seq^4),                          type = "log4: log(1+D⁴)"),
  data.table(D = D_seq, f = cal_sp2 * D_seq^2 / (1 + (D_seq / c_D)^2),           type = "softpoly2: D²/(1+(D/c)²)"),
  data.table(D = D_seq, f = cal_p15 * sign(D_seq) * abs(D_seq)^1.5,              type = "power1.5: sign(D)|D|^1.5")
))

dt_Dcal[, type := factor(type, levels = c("D² (raw, unbounded)",
                                            "log2: log(1+D²)",
                                            "log4: log(1+D⁴)",
                                            "softpoly2: D²/(1+(D/c)²)",
                                            "power1.5: sign(D)|D|^1.5"))]

p_Dcal <- ggplot(dt_Dcal, aes(x = D, y = f, color = type, linetype = type)) +
  geom_line(linewidth = 0.8) +
  geom_vline(xintercept = c(-sd_D, sd_D), linetype = "dotted", color = "grey50", linewidth = 0.4) +
  annotate("text", x = sd_D, y = max(dt_Dcal$f) * 0.95,
           label = paste0("sd_D = ", round(sd_D, 2)), hjust = -0.1, size = 3, color = "grey40") +
  scale_color_manual(values = c("D² (raw, unbounded)" = "grey60",
                                 "log2: log(1+D²)" = "#E41A1C",
                                 "log4: log(1+D⁴)" = "#377EB8",
                                 "softpoly2: D²/(1+(D/c)²)" = "#4DAF4A",
                                 "power1.5: sign(D)|D|^1.5" = "#984EA3")) +
  scale_linetype_manual(values = c("D² (raw, unbounded)" = "dashed",
                                    "log2: log(1+D²)" = "solid",
                                    "log4: log(1+D⁴)" = "solid",
                                    "softpoly2: D²/(1+(D/c)²)" = "solid",
                                    "power1.5: sign(D)|D|^1.5" = "solid")) +
  labs(title = "B. Calibrated NL contribution δ_nl·f(D) — nl_strength = 1",
       subtitle = sprintf("All cross at D = sd_D with contribution = δ_D·sd_D = %.4f", delta_D_val * sd_D),
       x = "D (within-unit, demeaned)", y = "δ_nl · f(D)",
       color = NULL, linetype = NULL) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom",
        legend.text = element_text(size = 8),
        plot.title = element_text(face = "bold"))

# ---- Panel B: Y-channel (raw Y² vs softclamped Y²) ----
Y_seq <- seq(-4 * sd_Y, 4 * sd_Y, length.out = 500)

dt_Y <- rbindlist(list(
  data.table(Y = Y_seq, f = Y_seq^2,                                    type = "Y² (raw, unbounded)"),
  data.table(Y = Y_seq, f = Y_seq^2 / (1 + (Y_seq / c_Y)^2),           type = "Y² softclamped: Y²/(1+(Y/c_Y)²)")
))

dt_Y[, type := factor(type, levels = c("Y² (raw, unbounded)",
                                         "Y² softclamped: Y²/(1+(Y/c_Y)²)"))]

p_Y <- ggplot(dt_Y, aes(x = Y, y = f, color = type, linetype = type)) +
  geom_line(linewidth = 0.8) +
  geom_vline(xintercept = c(-sd_Y, sd_Y), linetype = "dotted", color = "grey50", linewidth = 0.4) +
  annotate("text", x = sd_Y, y = max(dt_Y$f) * 0.95,
           label = paste0("sd_Y = ", round(sd_Y, 2)), hjust = -0.1, size = 3, color = "grey40") +
  geom_hline(yintercept = c_Y^2, linetype = "dashed", color = "grey70", linewidth = 0.3) +
  annotate("text", x = min(Y_seq) * 0.9, y = c_Y^2,
           label = paste0("c_Y² = ", round(c_Y^2, 1)), vjust = -0.5, size = 3, color = "grey50") +
  scale_color_manual(values = c("Y² (raw, unbounded)" = "grey60",
                                 "Y² softclamped: Y²/(1+(Y/c_Y)²)" = "#E41A1C")) +
  scale_linetype_manual(values = c("Y² (raw, unbounded)" = "dashed",
                                    "Y² softclamped: Y²/(1+(Y/c_Y)²)" = "solid")) +
  labs(title = "C. Y-channel: raw Y² vs softclamped",
       subtitle = sprintf("c_Y = 2·sd_Y = %.2f. Softclamp saturates at c_Y² = %.1f", c_Y, c_Y^2),
       x = "Y (within-unit, demeaned)", y = "f(Y)",
       color = NULL, linetype = NULL) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom",
        legend.text = element_text(size = 8),
        plot.title = element_text(face = "bold"))

# ---- Save ----
ggsave("../../plots/nl_functions_D_raw.png", p_D, width = 8, height = 5, dpi = 150)
ggsave("../../plots/nl_functions_D_calibrated.png", p_Dcal, width = 8, height = 5, dpi = 150)
ggsave("../../plots/nl_functions_Y_softclamp.png", p_Y, width = 8, height = 5, dpi = 150)

cat("\nPlots saved:\n")
cat("  plots/nl_functions_D_raw.png\n")
cat("  plots/nl_functions_D_calibrated.png\n")
cat("  plots/nl_functions_Y_softclamp.png\n")
