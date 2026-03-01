#### Replication of Leipziger (2024) AJPS — Table 1 (baseline TWFE)
#### + IVB (Included Variable Bias) decomposition
####
#### Main specification (Table 1, columns 1-3):
####   Y_it = β Democracy(0,1)_{i,t-1} + γ lnGDP_{i,t-1} + δ_i + τ_t + ε_it
####
#### Three outcomes:
####   1. SEI: V-Dem public services ethnic inequality (rescaled 0-1)
####   2. grg: Alesina et al. nightlight income inequality
####   3. ggini: Omoeva et al. education inequality
####
#### Table A11 (robustness with additional controls):
####   + oil income p.c., civil war, ethnic frac., GDP growth

library(fixest)
library(dplyr)

# Source IVB utilities
source("ivb_utils.R")

# ── 1. Load and prepare data ─────────────────────────────────────────────────

dat <- read.delim(
  "candidate_papers/leipziger_2024/Country-level_dataset.tab",
  stringsAsFactors = FALSE
)

cat("Raw data:", nrow(dat), "obs,", length(unique(dat$country_id)), "countries\n")
cat("Year range:", range(dat$year, na.rm = TRUE), "\n")

# ── 2. Generate variables (following Stata do-file) ──────────────────────────

# Binary democracy: lexical_index >= 5
dat$lexical_index_5 <- ifelse(dat$lexical_index >= 5, 1,
                               ifelse(dat$lexical_index <= 4, 0, NA))

# SEI: rescale v2peapssoc to 0-1 (lower = normatively better)
# Stata: generate SEI = ((v2peapssoc-3.37)/(-3.135-3.37)*(1-0)+0)
dat$SEI <- (dat$v2peapssoc - 3.37) / (-3.135 - 3.37)

# grg: already in dataset (from Alesina et al.)
# Note: Stata code does linear interpolation: by country_id: ipolate grg year, gen(grg_ip)
# We need to do this in R (handle countries with <2 non-NA values)
dat <- dat %>%
  arrange(country_id, year) %>%
  group_by(country_id) %>%
  mutate(grg_ip = {
    idx <- !is.na(grg)
    if (sum(idx) >= 2) {
      approx(year[idx], grg[idx], xout = year, rule = 1)$y
    } else if (sum(idx) == 1) {
      ifelse(year == year[idx], grg[idx], NA_real_)
    } else {
      NA_real_
    }
  }) %>%
  ungroup()

# ggini: already in dataset (from Omoeva et al.)

# ── 3. Create lagged variables ───────────────────────────────────────────────

dat <- dat %>%
  arrange(country_id, year) %>%
  group_by(country_id) %>%
  mutate(
    L_lexical_index_5 = dplyr::lag(lexical_index_5, 1),
    L_latent_gdppc_mean_log = dplyr::lag(latent_gdppc_mean_log, 1),
    L_e_total_oil_income_pc = dplyr::lag(e_total_oil_income_pc, 1),
    L_e_civil_war = dplyr::lag(e_civil_war, 1),
    L_efindex = dplyr::lag(efindex, 1),
    L_e_migdpgro = dplyr::lag(e_migdpgro, 1)
  ) %>%
  ungroup()

# Convert year and country_id to factors for FE
dat$year_f <- factor(dat$year)
dat$country_f <- factor(dat$country_id)

# ── 4. Replicate Table 1 — Baseline TWFE ─────────────────────────────────────
# Stata: xtreg SEI L.lexical_index_5 L.latent_gdppc_mean_log i.year, fe cluster(country_id)

cat("\n", strrep("=", 70), "\n")
cat("REPLICATION OF TABLE 1 (BASELINE TWFE)\n")
cat(strrep("=", 70), "\n")

# Model 1: Public services (SEI)
mod1_sei <- feols(
  SEI ~ L_lexical_index_5 + L_latent_gdppc_mean_log | country_f + year_f,
  data = dat, vcov = ~country_id
)
cat("\n--- Model 1: Public Services (SEI) ---\n")
cat("N =", mod1_sei$nobs, "\n")
cat("Published: Democracy = -0.035** (0.012), GDP pc = -0.051** (0.011)\n")
cat("Replicated: Democracy =", round(coef(mod1_sei)["L_lexical_index_5"], 3),
    ", GDP pc =", round(coef(mod1_sei)["L_latent_gdppc_mean_log"], 3), "\n")

# Model 2: Income (grg - Alesina et al.) — raw grg, not interpolated
mod1_grg <- feols(
  grg ~ L_lexical_index_5 + L_latent_gdppc_mean_log | country_f + year_f,
  data = dat, vcov = ~country_id
)
cat("\n--- Model 2: Income (Alesina et al.) ---\n")
cat("N =", mod1_grg$nobs, "\n")
cat("Published: Democracy = -0.030* (0.016), GDP pc = -0.027 (0.024)\n")
cat("Replicated: Democracy =", round(coef(mod1_grg)["L_lexical_index_5"], 3),
    ", GDP pc =", round(coef(mod1_grg)["L_latent_gdppc_mean_log"], 3), "\n")

# Model 3: Education (ggini)
mod1_ggini <- feols(
  ggini ~ L_lexical_index_5 + L_latent_gdppc_mean_log | country_f + year_f,
  data = dat, vcov = ~country_id
)
cat("\n--- Model 3: Education (Omoeva et al.) ---\n")
cat("N =", mod1_ggini$nobs, "\n")
cat("Published: Democracy = -0.005 (0.007), GDP pc = 0.007 (0.014)\n")
cat("Replicated: Democracy =", round(coef(mod1_ggini)["L_lexical_index_5"], 3),
    ", GDP pc =", round(coef(mod1_ggini)["L_latent_gdppc_mean_log"], 3), "\n")

# ── 5. IVB for Table 1 — Only GDP per capita as candidate collider ───────────

cat("\n\n", strrep("=", 70), "\n")
cat("IVB DECOMPOSITION — TABLE 1 BASELINE (GDP p.c. as candidate collider)\n")
cat(strrep("=", 70), "\n")

# For IVB identity to hold exactly, we use vcov = "iid"
# Treatment: L_lexical_index_5
# Candidate collider: L_latent_gdppc_mean_log
# w (always included): nothing else (only FE)
# FE: country_f + year_f

outcomes <- c("SEI", "grg", "ggini")
outcome_labels <- c("Public services (SEI)", "Income (Alesina)", "Education (Omoeva)")

ivb_table1 <- list()

for (i in seq_along(outcomes)) {
  y_var <- outcomes[i]

  res <- compute_ivb_multi(
    data = dat,
    y = y_var,
    d_vars = "L_lexical_index_5",
    z = "L_latent_gdppc_mean_log",
    w = character(),
    fe = c("country_f", "year_f"),
    vcov = "iid"
  )

  ivb_table1[[y_var]] <- res

  cat("\n--- Outcome:", outcome_labels[i], "---\n")
  cat("N =", res$sample_n, "\n")
  cat("theta (coef of GDP p.c. in long model):", round(res$theta, 6), "\n")
  num_cols <- setdiff(names(res$results), "term")
  tmp <- res$results
  tmp[num_cols] <- lapply(tmp[num_cols], round, 6)
  print(tmp)
}

# Summary
cat("\n\n=== SUMMARY: IVB on Democracy by outcome (Table 1, GDP p.c. as collider) ===\n")
summary_t1 <- do.call(rbind, lapply(seq_along(outcomes), function(i) {
  r <- ivb_table1[[outcomes[i]]]$results
  data.frame(
    outcome = outcome_labels[i],
    beta_short = r$beta_short,
    beta_long = r$beta_long,
    theta = r$theta,
    pi = r$pi,
    ivb = r$ivb_formula,
    check = r$diff_check,
    stringsAsFactors = FALSE
  )
}))
num_cols <- setdiff(names(summary_t1), "outcome")
summary_t1[num_cols] <- lapply(summary_t1[num_cols], round, 6)
print(summary_t1)


# ── 6. IVB for Table A11 — Extended model with additional controls ───────────

cat("\n\n", strrep("=", 70), "\n")
cat("IVB DECOMPOSITION — TABLE A11 EXTENDED (each control as candidate collider)\n")
cat(strrep("=", 70), "\n")

# Table A11 controls (all lagged):
# L_latent_gdppc_mean_log, L_e_total_oil_income_pc, L_e_civil_war, L_efindex, L_e_migdpgro
all_controls_a11 <- c("L_latent_gdppc_mean_log", "L_e_total_oil_income_pc",
                       "L_e_civil_war", "L_efindex", "L_e_migdpgro")

control_labels_a11 <- c("Log GDP p.c.", "Oil income p.c.", "Civil war",
                         "Ethnic frac.", "GDP growth")

# Focus on SEI (public services) - most robust outcome
cat("\n*** Outcome: Public Services (SEI) ***\n")

ivb_a11_sei <- list()

for (j in seq_along(all_controls_a11)) {
  z_var <- all_controls_a11[j]
  w_vars <- setdiff(all_controls_a11, z_var)

  res <- tryCatch(
    compute_ivb_multi(
      data = dat,
      y = "SEI",
      d_vars = "L_lexical_index_5",
      z = z_var,
      w = w_vars,
      fe = c("country_f", "year_f"),
      vcov = "iid"
    ),
    error = function(e) {
      cat("  ERROR for", z_var, ":", e$message, "\n")
      NULL
    }
  )

  if (!is.null(res)) {
    ivb_a11_sei[[z_var]] <- res
    cat("\n--- Collider candidate:", control_labels_a11[j], "(", z_var, ") ---\n")
    cat("N =", res$sample_n, "\n")
    cat("theta:", round(res$theta, 6), "\n")
    num_cols <- setdiff(names(res$results), "term")
    tmp <- res$results
    tmp[num_cols] <- lapply(tmp[num_cols], round, 6)
    print(tmp)
  }
}

# Summary Table A11 - SEI
cat("\n\n=== SUMMARY: IVB on Democracy for SEI (Table A11, each control as collider) ===\n")
if (length(ivb_a11_sei) > 0) {
  summary_a11 <- do.call(rbind, lapply(names(ivb_a11_sei), function(z_var) {
    r <- ivb_a11_sei[[z_var]]$results
    data.frame(
      collider = z_var,
      beta_short = r$beta_short,
      beta_long = r$beta_long,
      theta = r$theta,
      pi = r$pi,
      ivb = r$ivb_formula,
      check = r$diff_check,
      stringsAsFactors = FALSE
    )
  }))
  num_cols <- setdiff(names(summary_a11), "collider")
  summary_a11[num_cols] <- lapply(summary_a11[num_cols], round, 6)
  print(summary_a11)
}

# ── 7. Table A11 for Income (grg_ip) ────────────────────────────────────────

cat("\n\n*** Outcome: Income (Alesina et al.) ***\n")

# Note: for grg, Table A11 conditional model drops civil war and oil
# "additional controls, minus civil war and oil"
# But the unconditional model includes all 4 controls
# We use the unconditional specification with all controls
all_controls_grg <- c("L_latent_gdppc_mean_log", "L_e_total_oil_income_pc",
                       "L_e_civil_war", "L_efindex", "L_e_migdpgro")

ivb_a11_grg <- list()

for (j in seq_along(all_controls_grg)) {
  z_var <- all_controls_grg[j]
  w_vars <- setdiff(all_controls_grg, z_var)

  res <- tryCatch(
    compute_ivb_multi(
      data = dat,
      y = "grg",
      d_vars = "L_lexical_index_5",
      z = z_var,
      w = w_vars,
      fe = c("country_f", "year_f"),
      vcov = "iid"
    ),
    error = function(e) {
      cat("  ERROR for", z_var, ":", e$message, "\n")
      NULL
    }
  )

  if (!is.null(res)) {
    ivb_a11_grg[[z_var]] <- res
    cat("\n--- Collider candidate:", control_labels_a11[j], "(", z_var, ") ---\n")
    cat("N =", res$sample_n, "\n")
    cat("theta:", round(res$theta, 6), "\n")
    num_cols <- setdiff(names(res$results), "term")
    tmp <- res$results
    tmp[num_cols] <- lapply(tmp[num_cols], round, 6)
    print(tmp)
  }
}

cat("\n\n=== SUMMARY: IVB on Democracy for Income (Table A11, each control as collider) ===\n")
if (length(ivb_a11_grg) > 0) {
  summary_a11_grg <- do.call(rbind, lapply(names(ivb_a11_grg), function(z_var) {
    r <- ivb_a11_grg[[z_var]]$results
    data.frame(
      collider = z_var,
      beta_short = r$beta_short,
      beta_long = r$beta_long,
      theta = r$theta,
      pi = r$pi,
      ivb = r$ivb_formula,
      check = r$diff_check,
      stringsAsFactors = FALSE
    )
  }))
  num_cols <- setdiff(names(summary_a11_grg), "collider")
  summary_a11_grg[num_cols] <- lapply(summary_a11_grg[num_cols], round, 6)
  print(summary_a11_grg)
}

cat("\n\nDone.\n")
