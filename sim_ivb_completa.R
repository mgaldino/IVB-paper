# =============================================================================
# Simulações completas do IVB — Cross-section e ADL
# Manoel Galdino
# =============================================================================

library(ggplot2)
library(dplyr)
library(tidyr)

theme_set(theme_minimal(base_size = 13))

# =============================================================================
# PARTE 1: CROSS-SECTION — Validação da fórmula IVB
# =============================================================================

## 1A) Simulação única: viés teórico vs empírico ---------------------------------

set.seed(42)
n <- 10000
nsim <- 500

beta1_true <- 1
gamma1 <- 0.6  # D -> Z
gamma2 <- 0.4  # Y -> Z

results_cs <- data.frame(
  sim = 1:nsim,
  beta_short = NA,
  beta_long = NA,
  bias_empirico = NA,
  bias_formula = NA
)

for (i in 1:nsim) {
  D <- rnorm(n)
  e <- rnorm(n)
  u <- rnorm(n)

  Y <- beta1_true * D + e
  Z <- gamma1 * D + gamma2 * Y + u  # collider

  mod_short <- lm(Y ~ D)
  mod_long  <- lm(Y ~ D + Z)
  mod_aux   <- lm(Z ~ D)

  theta_star <- coef(mod_long)["Z"]
  phi1       <- coef(mod_aux)["D"]

  results_cs$beta_short[i]    <- coef(mod_short)["D"]
  results_cs$beta_long[i]     <- coef(mod_long)["D"]
  results_cs$bias_empirico[i] <- coef(mod_long)["D"] - coef(mod_short)["D"]
  results_cs$bias_formula[i]  <- -theta_star * phi1
}

# Plot 1A: Viés empírico vs fórmula (scatter)
p1a <- ggplot(results_cs, aes(x = bias_formula, y = bias_empirico)) +
  geom_point(alpha = 0.3, size = 1) +
  geom_abline(intercept = 0, slope = 1, color = "red", linewidth = 0.8) +
  labs(
    title = "Cross-section: Viés empírico vs fórmula IVB",
    subtitle = paste0("n = ", n, ", ", nsim, " simulações | β₁ = ", beta1_true,
                      ", γ₁ = ", gamma1, ", γ₂ = ", gamma2),
    x = expression("Viés pela fórmula: " * -hat(theta)^"*" * hat(phi)[1]),
    y = expression("Viés empírico: " * hat(beta)["longo"] - hat(beta)["curto"])
  ) +
  coord_equal()

ggsave("plots/cs_bias_scatter.png", p1a, width = 7, height = 6, dpi = 150)


## 1B) Variando γ₁ e γ₂: como o IVB muda ----------------------------------------

grid_params <- expand.grid(
  gamma1 = seq(0, 1, by = 0.2),
  gamma2 = seq(0, 1, by = 0.2)
)

set.seed(123)
n <- 10000

grid_results <- grid_params %>%
  rowwise() %>%
  mutate(
    bias = {
      D <- rnorm(n)
      e <- rnorm(n)
      u <- rnorm(n)
      Y <- beta1_true * D + e
      Z <- gamma1 * D + gamma2 * Y + u

      mod_long <- lm(Y ~ D + Z)
      mod_aux  <- lm(Z ~ D)

      theta_star <- coef(mod_long)["Z"]
      phi1       <- coef(mod_aux)["D"]

      -theta_star * phi1
    }
  ) %>%
  ungroup()

# Plot 1B: Heatmap do IVB em função de γ₁ e γ₂
p1b <- ggplot(grid_results, aes(x = factor(gamma1), y = factor(gamma2), fill = bias)) +
  geom_tile(color = "white", linewidth = 0.5) +
  geom_text(aes(label = round(bias, 3)), size = 3.5) +
  scale_fill_gradient2(low = "steelblue", mid = "white", high = "firebrick",
                       midpoint = 0, name = "IVB") +
  labs(
    title = "Cross-section: IVB em função dos parâmetros do collider",
    subtitle = paste0("β₁ = ", beta1_true, ", n = ", n),
    x = expression(gamma[1] ~ " (D → Z)"),
    y = expression(gamma[2] ~ " (Y → Z)")
  )

ggsave("plots/cs_bias_heatmap.png", p1b, width = 7, height = 6, dpi = 150)


## 1C) Distribuição do estimador longo vs curto -----------------------------------

p1c <- results_cs %>%
  select(sim, beta_short, beta_long) %>%
  pivot_longer(-sim, names_to = "modelo", values_to = "beta") %>%
  mutate(modelo = ifelse(modelo == "beta_short", "Curto (correto)", "Longo (com collider)")) %>%
  ggplot(aes(x = beta, fill = modelo)) +
  geom_density(alpha = 0.5) +
  geom_vline(xintercept = beta1_true, linetype = "dashed", linewidth = 0.8) +
  annotate("text", x = beta1_true + 0.01, y = 0, label = paste0("β₁ = ", beta1_true),
           hjust = 0, vjust = -0.5, size = 4) +
  labs(
    title = "Cross-section: Distribuição dos estimadores",
    subtitle = paste0("n = ", n, ", ", nsim, " simulações"),
    x = expression(hat(beta)[1]),
    y = "Densidade",
    fill = "Modelo"
  ) +
  scale_fill_manual(values = c("Curto (correto)" = "steelblue",
                                "Longo (com collider)" = "firebrick"))

ggsave("plots/cs_distribuicao.png", p1c, width = 8, height = 5, dpi = 150)


# =============================================================================
# PARTE 2: ADL(1,0) — Validação da fórmula IVB com dinâmica
# =============================================================================

## Função para simular painel ADL com collider -----------------------------------

sim_adl_panel <- function(N, T_periods, beta, rho, delta_d, delta_y,
                          seed = NULL) {
  # N: número de unidades
  # T_periods: períodos
  # beta: efeito causal de D sobre Y
  # rho: coeficiente autorregressivo
  # delta_d: D -> Z (direto)
  # delta_y: Y -> Z (collider)

  if (!is.null(seed)) set.seed(seed)

  # Pré-alocar
  Y <- matrix(NA, N, T_periods)
  D <- matrix(rnorm(N * T_periods), N, T_periods)
  Z <- matrix(NA, N, T_periods)

  # Período inicial
  Y[, 1] <- rnorm(N)
  Z[, 1] <- delta_d * D[, 1] + delta_y * Y[, 1] + rnorm(N)

  # Simular
  for (t in 2:T_periods) {
    Y[, t] <- rho * Y[, t-1] + beta * D[, t] + rnorm(N)
    Z[, t] <- delta_d * D[, t] + delta_y * Y[, t] + rnorm(N)
  }

  # Montar data.frame (usar t >= 2 para ter lag)
  df <- data.frame(
    id = rep(1:N, each = (T_periods - 1)),
    t  = rep(2:T_periods, times = N),
    Y  = as.vector(Y[, 2:T_periods]),
    D  = as.vector(D[, 2:T_periods]),
    Z  = as.vector(Z[, 2:T_periods]),
    Y_lag = as.vector(Y[, 1:(T_periods - 1)])
  )

  return(df)
}


## 2A) Simulação Monte Carlo: validação da fórmula ADL --------------------------

set.seed(99)
nsim <- 500
N <- 200
T_periods <- 20
beta_true <- 1
rho_true <- 0.5
delta_d <- 0.6
delta_y <- 0.4

results_adl <- data.frame(
  sim = 1:nsim,
  beta_short = NA,
  beta_long = NA,
  bias_empirico = NA,
  bias_formula = NA
)

for (i in 1:nsim) {
  df <- sim_adl_panel(N, T_periods, beta_true, rho_true, delta_d, delta_y)

  mod_short <- lm(Y ~ D + Y_lag, data = df)
  mod_long  <- lm(Y ~ D + Y_lag + Z, data = df)
  mod_aux   <- lm(Z ~ D + Y_lag, data = df)

  theta_star <- coef(mod_long)["Z"]
  pi_hat     <- coef(mod_aux)["D"]

  results_adl$beta_short[i]    <- coef(mod_short)["D"]
  results_adl$beta_long[i]     <- coef(mod_long)["D"]
  results_adl$bias_empirico[i] <- coef(mod_long)["D"] - coef(mod_short)["D"]
  results_adl$bias_formula[i]  <- -theta_star * pi_hat
}

# Plot 2A: Scatter viés empírico vs fórmula ADL
p2a <- ggplot(results_adl, aes(x = bias_formula, y = bias_empirico)) +
  geom_point(alpha = 0.3, size = 1) +
  geom_abline(intercept = 0, slope = 1, color = "red", linewidth = 0.8) +
  labs(
    title = "ADL(1,0): Viés empírico vs fórmula IVB",
    subtitle = paste0("N = ", N, ", T = ", T_periods, ", ", nsim,
                      " simulações | β = ", beta_true, ", ρ = ", rho_true,
                      ", δ_d = ", delta_d, ", δ_y = ", delta_y),
    x = expression("Viés pela fórmula: " * -hat(theta)^"*" * hat(pi)),
    y = expression("Viés empírico: " * hat(beta)["longo"] - hat(beta)["curto"])
  ) +
  coord_equal()

ggsave("plots/adl_bias_scatter.png", p2a, width = 7, height = 6, dpi = 150)


## 2B) Distribuição dos estimadores ADL ------------------------------------------

p2b <- results_adl %>%
  select(sim, beta_short, beta_long) %>%
  pivot_longer(-sim, names_to = "modelo", values_to = "beta") %>%
  mutate(modelo = ifelse(modelo == "beta_short", "ADL curto (correto)",
                         "ADL longo (com collider)")) %>%
  ggplot(aes(x = beta, fill = modelo)) +
  geom_density(alpha = 0.5) +
  geom_vline(xintercept = beta_true, linetype = "dashed", linewidth = 0.8) +
  annotate("text", x = beta_true + 0.005, y = 0, label = paste0("β = ", beta_true),
           hjust = 0, vjust = -0.5, size = 4) +
  labs(
    title = "ADL(1,0): Distribuição dos estimadores",
    subtitle = paste0("N = ", N, ", T = ", T_periods, ", ", nsim, " simulações"),
    x = expression(hat(beta)),
    y = "Densidade",
    fill = "Modelo"
  ) +
  scale_fill_manual(values = c("ADL curto (correto)" = "steelblue",
                                "ADL longo (com collider)" = "firebrick"))

ggsave("plots/adl_distribuicao.png", p2b, width = 8, height = 5, dpi = 150)


## 2C) Variando ρ: como a persistência afeta o IVB --------------------------------

rho_grid <- seq(0, 0.9, by = 0.1)

set.seed(77)
rho_results <- data.frame(rho = rho_grid, bias_medio = NA, bias_formula_medio = NA)

for (r in seq_along(rho_grid)) {
  biases <- numeric(200)
  formulas <- numeric(200)

  for (i in 1:200) {
    df <- sim_adl_panel(N, T_periods, beta_true, rho_grid[r], delta_d, delta_y)

    mod_short <- lm(Y ~ D + Y_lag, data = df)
    mod_long  <- lm(Y ~ D + Y_lag + Z, data = df)
    mod_aux   <- lm(Z ~ D + Y_lag, data = df)

    biases[i]  <- coef(mod_long)["D"] - coef(mod_short)["D"]
    formulas[i] <- -coef(mod_long)["Z"] * coef(mod_aux)["D"]
  }

  rho_results$bias_medio[r]         <- mean(biases)
  rho_results$bias_formula_medio[r] <- mean(formulas)
}

p2c <- rho_results %>%
  pivot_longer(-rho, names_to = "tipo", values_to = "bias") %>%
  mutate(tipo = ifelse(tipo == "bias_medio", "Viés empírico", "Viés pela fórmula")) %>%
  ggplot(aes(x = rho, y = bias, color = tipo, shape = tipo)) +
  geom_point(size = 3) +
  geom_line(linewidth = 0.8) +
  labs(
    title = "ADL(1,0): Efeito da persistência (ρ) sobre o IVB",
    subtitle = paste0("N = ", N, ", T = ", T_periods,
                      ", β = ", beta_true, ", δ_d = ", delta_d, ", δ_y = ", delta_y),
    x = expression(rho ~ " (coeficiente autorregressivo)"),
    y = "Viés médio",
    color = NULL, shape = NULL
  ) +
  scale_color_manual(values = c("Viés empírico" = "firebrick",
                                 "Viés pela fórmula" = "steelblue"))

ggsave("plots/adl_rho_effect.png", p2c, width = 8, height = 5, dpi = 150)


# =============================================================================
# PARTE 3: DGP "Civil War" — Cenário do "Beware the collider"
# =============================================================================

sim_civil_war <- function(N, T_periods,
                          beta_pc = 5,      # Political Change -> Civil War
                          rho_cw = 0.3,     # persistência de Civil War
                          rho_pc = 0.4,     # persistência de Political Change
                          alpha_inc = 0.5,  # Per Cap Income -> Civil War
                          rho_inc = 0.8,    # persistência de Income
                          gamma_cw_dem = -0.6,  # Civil War -> Democracy Level
                          gamma_u_dem = 1,      # U -> Democracy Level
                          gamma_u_cw = 0.5,     # U -> Civil War (via t+1)
                          seed = NULL) {

  if (!is.null(seed)) set.seed(seed)

  # Pré-alocar
  CW  <- matrix(NA, N, T_periods)  # Civil War
  PC  <- matrix(NA, N, T_periods)  # Political Change
  Inc <- matrix(NA, N, T_periods)  # Per Capita Income
  Dem <- matrix(NA, N, T_periods)  # Democracy Level
  U   <- matrix(rnorm(N * T_periods), N, T_periods)  # Não-observado

  # Inicializar
  PC[, 1]  <- rnorm(N)
  Inc[, 1] <- rnorm(N, 10, 2)
  CW[, 1]  <- beta_pc * PC[, 1] + alpha_inc * Inc[, 1] + gamma_u_cw * U[, 1] + rnorm(N)
  Dem[, 1] <- gamma_cw_dem * CW[, 1] + gamma_u_dem * U[, 1] + rnorm(N)

  for (t in 2:T_periods) {
    Inc[, t] <- rho_inc * Inc[, t-1] + rnorm(N)
    PC[, t]  <- rho_pc * PC[, t-1] + rnorm(N)
    CW[, t]  <- rho_cw * CW[, t-1] + beta_pc * PC[, t] + alpha_inc * Inc[, t] +
                 gamma_u_cw * U[, t] + rnorm(N)
    Dem[, t] <- gamma_cw_dem * CW[, t] + gamma_u_dem * U[, t] + rnorm(N)
  }

  # Data frame (t >= 2 para ter lags)
  df <- data.frame(
    id      = rep(1:N, each = (T_periods - 1)),
    t       = rep(2:T_periods, times = N),
    CW      = as.vector(CW[, 2:T_periods]),
    PC      = as.vector(PC[, 2:T_periods]),
    Inc     = as.vector(Inc[, 2:T_periods]),
    Dem     = as.vector(Dem[, 2:T_periods]),
    CW_lag  = as.vector(CW[, 1:(T_periods - 1)]),
    PC_lag  = as.vector(PC[, 1:(T_periods - 1)]),
    Inc_lag = as.vector(Inc[, 1:(T_periods - 1)])
  )

  return(df)
}

## 3A) Simulação Monte Carlo: guerra civil com e sem Democracy Level ------------

set.seed(321)
nsim <- 500
N <- 200
T_periods <- 20
beta_pc_true <- 5

results_cw <- data.frame(
  sim = 1:nsim,
  beta_sem_dem = NA,    # ADL sem Democracy Level (correto)
  beta_com_dem = NA,    # ADL com Democracy Level (collider)
  bias_empirico = NA,
  bias_formula = NA
)

for (i in 1:nsim) {
  df <- sim_civil_war(N, T_periods, beta_pc = beta_pc_true)

  # Modelo correto: CW ~ PC + CW_lag + Inc
  mod_correto <- lm(CW ~ PC + CW_lag + Inc, data = df)

  # Modelo com collider: CW ~ PC + CW_lag + Inc + Dem
  mod_collider <- lm(CW ~ PC + CW_lag + Inc + Dem, data = df)

  # Regressão auxiliar: Dem ~ PC + CW_lag + Inc
  mod_aux <- lm(Dem ~ PC + CW_lag + Inc, data = df)

  theta_star <- coef(mod_collider)["Dem"]
  pi_hat     <- coef(mod_aux)["PC"]

  results_cw$beta_sem_dem[i]    <- coef(mod_correto)["PC"]
  results_cw$beta_com_dem[i]    <- coef(mod_collider)["PC"]
  results_cw$bias_empirico[i]   <- coef(mod_collider)["PC"] - coef(mod_correto)["PC"]
  results_cw$bias_formula[i]    <- -theta_star * pi_hat
}

# Plot 3A: Distribuição dos estimadores - Civil War
p3a <- results_cw %>%
  select(sim, beta_sem_dem, beta_com_dem) %>%
  pivot_longer(-sim, names_to = "modelo", values_to = "beta") %>%
  mutate(modelo = ifelse(modelo == "beta_sem_dem",
                         "Sem Democracy Level (correto)",
                         "Com Democracy Level (collider)")) %>%
  ggplot(aes(x = beta, fill = modelo)) +
  geom_density(alpha = 0.5) +
  geom_vline(xintercept = beta_pc_true, linetype = "dashed", linewidth = 0.8) +
  annotate("text", x = beta_pc_true + 0.05, y = 0,
           label = paste0("β = ", beta_pc_true),
           hjust = 0, vjust = -0.5, size = 4) +
  labs(
    title = "Civil War: Efeito de Political Change com e sem collider",
    subtitle = paste0("N = ", N, ", T = ", T_periods,
                      ", efeito verdadeiro = ", beta_pc_true),
    x = expression(hat(beta)[PC]),
    y = "Densidade",
    fill = "Modelo"
  ) +
  scale_fill_manual(values = c("Sem Democracy Level (correto)" = "steelblue",
                                "Com Democracy Level (collider)" = "firebrick"))

ggsave("plots/cw_distribuicao.png", p3a, width = 9, height = 5, dpi = 150)


# Plot 3B: Scatter viés empírico vs fórmula - Civil War
p3b <- ggplot(results_cw, aes(x = bias_formula, y = bias_empirico)) +
  geom_point(alpha = 0.3, size = 1) +
  geom_abline(intercept = 0, slope = 1, color = "red", linewidth = 0.8) +
  labs(
    title = "Civil War: Viés empírico vs fórmula IVB",
    subtitle = paste0("N = ", N, ", T = ", T_periods, ", ", nsim, " simulações"),
    x = expression("Viés pela fórmula: " * -hat(theta)^"*" * hat(pi)),
    y = expression("Viés empírico: " * hat(beta)["com Dem"] - hat(beta)["sem Dem"])
  ) +
  coord_equal()

ggsave("plots/cw_bias_scatter.png", p3b, width = 7, height = 6, dpi = 150)


# =============================================================================
# PARTE 4: Tabela-resumo
# =============================================================================

cat("\n")
cat("=================================================================\n")
cat("RESUMO DAS SIMULAÇÕES\n")
cat("=================================================================\n")

cat("\n--- Cross-section ---\n")
cat(sprintf("  β verdadeiro:        %.3f\n", beta1_true))
cat(sprintf("  β̂ curto (média):     %.4f\n", mean(results_cs$beta_short)))
cat(sprintf("  β̂ longo (média):     %.4f\n", mean(results_cs$beta_long)))
cat(sprintf("  Viés empírico médio: %.4f\n", mean(results_cs$bias_empirico)))
cat(sprintf("  Viés fórmula médio:  %.4f\n", mean(results_cs$bias_formula)))

cat("\n--- ADL(1,0) ---\n")
cat(sprintf("  β verdadeiro:        %.3f\n", beta_true))
cat(sprintf("  β̂ curto (média):     %.4f\n", mean(results_adl$beta_short)))
cat(sprintf("  β̂ longo (média):     %.4f\n", mean(results_adl$beta_long)))
cat(sprintf("  Viés empírico médio: %.4f\n", mean(results_adl$bias_empirico)))
cat(sprintf("  Viés fórmula médio:  %.4f\n", mean(results_adl$bias_formula)))

cat("\n--- Civil War (ADL com collider) ---\n")
cat(sprintf("  β verdadeiro:        %.3f\n", beta_pc_true))
cat(sprintf("  β̂ sem Dem (média):   %.4f\n", mean(results_cw$beta_sem_dem)))
cat(sprintf("  β̂ com Dem (média):   %.4f\n", mean(results_cw$beta_com_dem)))
cat(sprintf("  Viés empírico médio: %.4f\n", mean(results_cw$bias_empirico)))
cat(sprintf("  Viés fórmula médio:  %.4f\n", mean(results_cw$bias_formula)))

cat("\n=================================================================\n")
cat("Plots salvos em plots/\n")
cat("=================================================================\n")
