#!/usr/bin/env Rscript
# Compute standardized IVB metrics across all six applications
# Metrics: |IVB/beta|, IVB/SD(Y), IVB/SE(beta)

library(fixest)
library(haven)
library(dplyr)
source("ivb_utils.R")

cat("=== Standardized IVB Metrics ===\n\n")

all_results <- list()

add_row <- function(paper, collider_label, ivb, beta_long, se_beta, sd_y) {
  all_results[[length(all_results) + 1]] <<- data.frame(
    paper = paper,
    collider = collider_label,
    IVB = ivb,
    beta_long = beta_long,
    SE_beta = se_beta,
    SD_Y = sd_y,
    IVB_pct_beta = 100 * ivb / beta_long,
    IVB_over_SE = ivb / se_beta,
    IVB_over_SDY = ivb / sd_y,
    stringsAsFactors = FALSE
  )
}

# ============================================================
# 1. CLAASSEN (2020) - Pooled OLS + FE
# ============================================================
cat("1. Claassen (2020) ...\n")
dat_cl <- read.delim("candidate_papers/claassen_2020/Support_democracy_ajps_correct.tab",
                     stringsAsFactors = FALSE)

cl_controls <- c("lnGDP_imp_m1", "GDP_imp_grth_m1", "Libdem_regUN_m1",
                 "Pr_Muslim", "Res_cp_WDI_di_m1")
cl_labels <- c("Log GDP p.c.", "GDP growth", "Regional democracy",
               "% Muslim", "Resource dep.")

# OLS
for (j in seq_along(cl_controls)) {
  z_var <- cl_controls[j]
  w_vars <- c("Libdem_m1", "Libdem_m2", setdiff(cl_controls, z_var))
  res <- compute_ivb_multi(dat_cl, y = "Libdem_VD", d_vars = "SupDem_m1",
                           z = z_var, w = w_vars, fe = character(), vcov = "iid")
  r <- res$results
  sd_y <- sd(dat_cl$Libdem_VD[complete.cases(dat_cl[, c("Libdem_VD", "SupDem_m1", cl_controls, "Libdem_m1", "Libdem_m2")])], na.rm = TRUE)
  se_b <- se(res$models$long)["SupDem_m1"]
  add_row("Claassen (OLS)", cl_labels[j], r$ivb_formula, r$beta_long, se_b, sd_y)
}

# FE (no Pr_Muslim - absorbed by FE)
cl_controls_fe <- c("lnGDP_imp_m1", "GDP_imp_grth_m1", "Libdem_regUN_m1",
                    "Res_cp_WDI_di_m1")
cl_labels_fe <- c("Log GDP p.c.", "GDP growth", "Regional democracy",
                  "Resource dep.")
for (j in seq_along(cl_controls_fe)) {
  z_var <- cl_controls_fe[j]
  w_vars <- c("Libdem_m1", "Libdem_m2", setdiff(cl_controls_fe, z_var))
  res <- compute_ivb_multi(dat_cl, y = "Libdem_VD", d_vars = "SupDem_m1",
                           z = z_var, w = w_vars, fe = "Country", vcov = "iid")
  r <- res$results
  all_vars <- c("Libdem_VD", "SupDem_m1", cl_controls_fe, "Libdem_m1", "Libdem_m2", "Country")
  sd_y <- sd(dat_cl$Libdem_VD[complete.cases(dat_cl[, all_vars])], na.rm = TRUE)
  se_b <- se(res$models$long)["SupDem_m1"]
  add_row("Claassen (FE)", cl_labels_fe[j], r$ivb_formula, r$beta_long, se_b, sd_y)
}

# ============================================================
# 2. LEIPZIGER (2024)
# ============================================================
cat("2. Leipziger (2024) ...\n")
dat_lp <- read.delim("candidate_papers/leipziger_2024/Country-level_dataset.tab",
                     stringsAsFactors = FALSE)

dat_lp$lexical_index_5 <- ifelse(dat_lp$lexical_index >= 5, 1,
                                  ifelse(dat_lp$lexical_index <= 4, 0, NA))
dat_lp$SEI <- (dat_lp$v2peapssoc - 3.37) / (-3.135 - 3.37)

dat_lp <- dat_lp %>%
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
dat_lp$year_f <- factor(dat_lp$year)
dat_lp$country_f <- factor(dat_lp$country_id)

# Table 1: only GDP p.c. as control, 3 outcomes
lp_outcomes <- c("SEI", "grg", "ggini")
lp_outcome_labels <- c("SEI", "GRG", "GGINI")

for (oi in seq_along(lp_outcomes)) {
  res <- compute_ivb_multi(dat_lp, y = lp_outcomes[oi], d_vars = "L_lexical_index_5",
                           z = "L_latent_gdppc_mean_log", w = character(),
                           fe = c("country_f", "year_f"), vcov = "iid")
  r <- res$results
  # Get SD(Y) and SE with clustered vcov
  all_vars <- c(lp_outcomes[oi], "L_lexical_index_5", "L_latent_gdppc_mean_log", "country_f", "year_f")
  df_clean <- dat_lp[complete.cases(dat_lp[, all_vars]), ]
  sd_y <- sd(df_clean[[lp_outcomes[oi]]], na.rm = TRUE)
  # Reestimate long model with clustered SE
  mod_long_cl <- feols(res$formulas$long, data = df_clean, vcov = ~country_id)
  se_b <- se(mod_long_cl)["L_lexical_index_5"]
  add_row(paste0("Leipziger (", lp_outcome_labels[oi], ")"),
          "Log GDP p.c.", r$ivb_formula, r$beta_long, se_b, sd_y)
}

# Extended model: multiple controls, SEI only
lp_all_controls <- c("L_latent_gdppc_mean_log", "L_e_total_oil_income_pc",
                      "L_e_civil_war", "L_efindex", "L_e_migdpgro")
lp_ctrl_labels <- c("Log GDP p.c.", "Oil income p.c.", "Civil war",
                     "Ethnic frac.", "GDP growth")

for (j in seq_along(lp_all_controls)) {
  z_var <- lp_all_controls[j]
  w_vars <- setdiff(lp_all_controls, z_var)
  tryCatch({
    res <- compute_ivb_multi(dat_lp, y = "SEI", d_vars = "L_lexical_index_5",
                             z = z_var, w = w_vars,
                             fe = c("country_f", "year_f"), vcov = "iid")
    r <- res$results
    all_vars <- c("SEI", "L_lexical_index_5", lp_all_controls, "country_f", "year_f")
    df_clean <- dat_lp[complete.cases(dat_lp[, all_vars]), ]
    sd_y <- sd(df_clean$SEI, na.rm = TRUE)
    mod_long_cl <- feols(res$formulas$long, data = df_clean, vcov = ~country_id)
    se_b <- se(mod_long_cl)["L_lexical_index_5"]
    add_row("Leipziger (SEI ext.)", lp_ctrl_labels[j],
            r$ivb_formula, r$beta_long, se_b, sd_y)
  }, error = function(e) cat("  Skipping", z_var, ":", e$message, "\n"))
}

# ============================================================
# 3. BLAIR ET AL. (2023)
# ============================================================
cat("3. Blair et al. (2023) ...\n")
df_pk_raw <- read_dta("candidate_papers/peacekeeping/data_replication.dta")
df_pk <- df_pk_raw %>%
  filter(!(gwnoloc == 531 & year < 1993)) %>%
  filter(!(gwnoloc == 626 & year < 2011)) %>%
  arrange(gwnoloc, year) %>%
  group_by(gwnoloc) %>%
  mutate(
    v2x_polyarchy_1l = lag(v2x_polyarchy, 1),
    v2x_polyarchy_2l = lag(v2x_polyarchy, 2),
    v2x_polyarchy_3l = lag(v2x_polyarchy, 3),
    ipema_any_demo_assist_dum_2l = lag(ipema_any_demo_assist_dum, 2)
  ) %>%
  ungroup() %>%
  mutate(itotal_compound_K = itotal_compound / 1000,
         iactual_civilian_total_K = iactual_civilian_total / 1000)

# Impute controls
pk_ctrl_vars <- c("wdi_pop", "wdi_oda", "wdi_gdppc", "unhcr_ref_idp",
                   "wdi_literacy", "wdi_fuel")
for (v in pk_ctrl_vars) {
  new_v <- paste0("i", v)
  df_pk[[new_v]] <- df_pk[[v]]
  country_means <- df_pk %>%
    group_by(gwnoloc) %>%
    summarise(cmean = mean(.data[[v]], na.rm = TRUE), .groups = "drop")
  df_pk <- df_pk %>%
    left_join(country_means, by = "gwnoloc", suffix = c("", "_cm"))
  df_pk[[new_v]] <- ifelse(is.na(df_pk[[new_v]]), df_pk$cmean, df_pk[[new_v]])
  df_pk$cmean <- NULL
}

# Lag controls 3 periods
df_pk <- df_pk %>%
  group_by(gwnoloc) %>%
  mutate(
    iwdi_pop_3l = lag(iwdi_pop, 3),
    iwdi_oda_3l = lag(iwdi_oda, 3),
    iwdi_gdppc_3l = lag(iwdi_gdppc, 3),
    iunhcr_ref_idp_3l = lag(iunhcr_ref_idp, 3),
    iwdi_literacy_3l = lag(iwdi_literacy, 3),
    iwdi_fuel_3l = lag(iwdi_fuel, 3)
  ) %>%
  ungroup() %>%
  filter(year >= 1991)

pk_d_var <- "ipema_any_demo_assist_dum_2l"
pk_controls <- c("iwdi_pop_3l", "iwdi_oda_3l", "iwdi_gdppc_3l",
                  "iunhcr_ref_idp_3l", "iwdi_literacy_3l", "iwdi_fuel_3l")
pk_labels <- c("Population", "Foreign Aid", "GDP per capita",
               "Refugees/IDPs", "Literacy", "Fuel exports")

for (j in seq_along(pk_controls)) {
  z_var <- pk_controls[j]
  w_vars <- setdiff(pk_controls, z_var)
  tryCatch({
    res <- compute_ivb_multi(df_pk, y = "v2x_polyarchy", d_vars = pk_d_var,
                             z = z_var, w = w_vars,
                             fe = "gwnoloc", vcov = "iid")
    r <- res$results
    all_vars <- c("v2x_polyarchy", pk_d_var, pk_controls, "gwnoloc")
    df_clean <- df_pk[complete.cases(df_pk[, all_vars]), ]
    sd_y <- sd(df_clean$v2x_polyarchy, na.rm = TRUE)
    mod_long_cl <- feols(res$formulas$long, data = df_clean, vcov = ~gwnoloc)
    se_b <- se(mod_long_cl)[pk_d_var]
    add_row("Blair et al.", pk_labels[j], r$ivb_formula, r$beta_long, se_b, sd_y)
  }, error = function(e) cat("  Skipping", pk_controls[j], ":", e$message, "\n"))
}

# ============================================================
# 4. ALBERS ET AL. (2023) - from pre-computed CSV
# ============================================================
cat("4. Albers et al. (2023) ...\n")
ivb_fs <- read.csv("candidate_papers/fiscal_state_ivb_results.csv",
                   stringsAsFactors = FALSE)
# Load main panel data for SD(Y)
dat_fs <- read.delim("candidate_papers/fiscal_state_africa/FISCAL_PANEL_V4.tab",
                     stringsAsFactors = FALSE)
sd_y_fs <- sd(dat_fs$d_rev_total_hh, na.rm = TRUE)
if (is.na(sd_y_fs) || sd_y_fs == 0) {
  # Try SOMDJI version
  dat_fs2 <- read.delim("candidate_papers/fiscal_state_africa/FISCAL_PANEL_V4_SOMDJI.tab",
                        stringsAsFactors = FALSE)
  sd_y_fs <- sd(dat_fs2$d_rev_total_hh, na.rm = TRUE)
}

fs_labels <- c("X_indep" = "Independence",
               "X_inflation_ep" = "Hyperinflation",
               "l1_civ_war_all_PRIO" = "Civil war (PRIO)",
               "X_g_gdp_yoy" = "GDP growth (YoY)",
               "l1_drought_affected_merged" = "Drought",
               "libdem_extra_vdem" = "Liberal democracy",
               "X_secession" = "Secession",
               "X_socialist" = "Socialist",
               "S_g5_unw_alliance_abs" = "Alliance (G5)",
               "cr_market_accessXBOEinv" = "Market access",
               "X_external_default_RR" = "External default",
               "l1_int_war_all_PRIO" = "Intl war (PRIO)")

for (i in seq_len(nrow(ivb_fs))) {
  row <- ivb_fs[i, ]
  all_results[[length(all_results) + 1]] <- data.frame(
    paper = "Albers et al.",
    collider = unname(fs_labels[row$candidate_collider]),
    IVB = row$ivb_formula,
    beta_long = row$beta_long,
    SE_beta = NA_real_,
    SD_Y = sd_y_fs,
    IVB_pct_beta = 100 * row$ivb_formula / row$beta_long,
    IVB_over_SE = NA_real_,
    IVB_over_SDY = row$ivb_formula / sd_y_fs,
    stringsAsFactors = FALSE
  )
}

# ============================================================
# 5. ROGOWSKI ET AL. (2022)
# ============================================================
cat("5. Rogowski et al. (2022) ...\n")
dat_rg <- read.delim("candidate_papers/post_office_2022/country_panel.tab",
                     stringsAsFactors = FALSE)
dat_rg <- dat_rg %>%
  arrange(country_id, trend) %>%
  group_by(country_id) %>%
  mutate(F_e_migdpgro_5yr = lead(e_migdpgro_5yr, 1)) %>%
  ungroup()
dat_rg$country_f <- factor(dat_rg$country_id)
dat_rg$year_f <- factor(dat_rg$year)

rg_d_var <- "upu_totalpo_ipo_ln_stock_1_5yr"
rg_controls <- c("e_migdppcln_5yr", "e_mipopula_ipo_ln", "e_miurbaniz_ipo", "e_polity2_ipo")
rg_labels <- c("Log GDP p.c.", "Log population", "Urbanization", "Polity2")

for (j in seq_along(rg_controls)) {
  z_var <- rg_controls[j]
  w_vars <- setdiff(rg_controls, z_var)
  tryCatch({
    res <- compute_ivb_multi(dat_rg, y = "F_e_migdpgro_5yr", d_vars = rg_d_var,
                             z = z_var, w = w_vars,
                             fe = c("country_f", "year_f"), vcov = "iid")
    r <- res$results
    all_vars <- c("F_e_migdpgro_5yr", rg_d_var, rg_controls, "country_f", "year_f")
    df_clean <- dat_rg[complete.cases(dat_rg[, all_vars]), ]
    sd_y <- sd(df_clean$F_e_migdpgro_5yr, na.rm = TRUE)
    mod_long_cl <- feols(res$formulas$long, data = df_clean, vcov = ~country_id)
    se_b <- se(mod_long_cl)[rg_d_var]
    add_row("Rogowski et al.", rg_labels[j], r$ivb_formula, r$beta_long, se_b, sd_y)
  }, error = function(e) cat("  Skipping", rg_controls[j], ":", e$message, "\n"))
}

# ============================================================
# 6. BALLARD-ROSA ET AL. (2022)
# ============================================================
cat("6. Ballard-Rosa et al. (2022) ...\n")
dat_br <- read.delim("candidate_papers/ballard_rosa_2022/Coming_to_Terms_data.tab",
                     stringsAsFactors = FALSE)
dat_br <- dat_br %>%
  arrange(ccode, time) %>%
  group_by(ccode) %>%
  mutate(
    l1_rightwing = lag(rightwing_exec_mo, 1),
    l1_leftwing  = lag(leftwing_exec_mo, 1),
    l12_lngdppc       = lag(lngdppc, 12),
    l12_gdp_growth    = lag(gdp_growth, 12),
    l12_avgDebt_gdp   = lag(avgDebt_gdp, 12),
    l12_curr_act_gdp  = lag(curr_act_gdp, 12),
    l12_tradeGDP      = lag(tradeGDP, 12),
    l12_oil_rents     = lag(oil_rents_gdp, 12),
    l12_fdi_net       = lag(fdi_net_inflow_gdp, 12),
    l12_treasury10yr  = lag(treasury10yr, 12),
    l12_peg           = lag(peg, 12),
    l12_highCBI       = lag(highCBI, 12),
    l12_kaopen        = lag(kaopen, 12),
    l12_imfAnyInPlace = lag(imfAnyInPlace, 12),
    l12_v2x_polyarchy = lag(v2x_polyarchy, 12)
  ) %>%
  ungroup() %>%
  filter(oecd == 0)

br_d_vars <- c("l1_rightwing", "l1_leftwing")
br_controls <- c("l12_lngdppc", "l12_gdp_growth", "l12_avgDebt_gdp",
                  "l12_curr_act_gdp", "l12_tradeGDP", "l12_oil_rents",
                  "l12_fdi_net", "l12_treasury10yr", "l12_peg", "l12_highCBI",
                  "l12_kaopen", "l12_imfAnyInPlace", "crisis_currency",
                  "crisis_inflation", "crisis_sovdebt", "l12_v2x_polyarchy")
br_temporal <- c("time", "time2", "time3")
br_labels <- c("Log GDP p.c.", "GDP growth", "Ext. debt/GDP",
               "Curr. acct/GDP", "Trade/GDP", "Oil rents/GDP",
               "FDI/GDP", "US Treasury 10yr", "Pegged XR", "High CBI",
               "Chinn-Ito open.", "IMF program", "Currency crisis",
               "Inflation crisis", "Sov. debt crisis", "Democracy (V-Dem)")

for (j in seq_along(br_controls)) {
  z_var <- br_controls[j]
  w_vars <- c(setdiff(br_controls, z_var), br_temporal)
  tryCatch({
    res <- compute_ivb_multi(dat_br, y = "propDom_gt1yr", d_vars = br_d_vars,
                             z = z_var, w = w_vars,
                             fe = "ccode", vcov = "iid")
    r_left <- res$results[res$results$term == "l1_leftwing", ]
    all_vars <- c("propDom_gt1yr", br_d_vars, br_controls, br_temporal, "ccode")
    df_clean <- dat_br[complete.cases(dat_br[, all_vars]), ]
    sd_y <- sd(df_clean$propDom_gt1yr, na.rm = TRUE)
    mod_long_cl <- feols(res$formulas$long, data = df_clean, vcov = ~ccode)
    se_b <- se(mod_long_cl)["l1_leftwing"]
    add_row("Ballard-Rosa et al.", br_labels[j],
            r_left$ivb_formula, r_left$beta_long, se_b, sd_y)
  }, error = function(e) cat("  Skipping", br_controls[j], ":", e$message, "\n"))
}

# ============================================================
# COMBINE AND DISPLAY
# ============================================================
cat("\nCombining results...\n\n")
df_all <- do.call(rbind, all_results)
rownames(df_all) <- NULL

# For each paper, find the largest |IVB| row
cat("======================================================================\n")
cat("LARGEST IVB PER PAPER (standardized metrics)\n")
cat("======================================================================\n\n")

summary_rows <- list()
for (p in unique(df_all$paper)) {
  sub <- df_all[df_all$paper == p, ]
  idx <- which.max(abs(sub$IVB))
  summary_rows[[length(summary_rows) + 1]] <- sub[idx, ]
}
summary_df <- do.call(rbind, summary_rows)

for (i in seq_len(nrow(summary_df))) {
  s <- summary_df[i, ]
  cat(sprintf("%-25s | Collider: %-20s | IVB=%.4f | |IVB/beta|=%.1f%% | IVB/SE=%.2f | |IVB/SD(Y)|=%.4f\n",
              s$paper, s$collider, s$IVB,
              abs(s$IVB_pct_beta),
              ifelse(is.na(s$IVB_over_SE), NA, s$IVB_over_SE),
              abs(s$IVB_over_SDY)))
}

cat("\n\n")
cat("======================================================================\n")
cat("ALL CONTROLS RANKED BY |IVB/SD(Y)| (Cohen's d analog)\n")
cat("======================================================================\n\n")

df_all$abs_IVB_SDY <- abs(df_all$IVB_over_SDY)
df_sorted <- df_all[order(-df_all$abs_IVB_SDY), ]

cat(sprintf("%-25s | %-22s | %8s | %10s | %8s | %10s\n",
            "Paper", "Control", "IVB", "|IVB/beta|%", "IVB/SE", "|IVB/SD(Y)|"))
cat(paste(rep("-", 100), collapse = ""), "\n")
for (i in seq_len(min(30, nrow(df_sorted)))) {
  s <- df_sorted[i, ]
  cat(sprintf("%-25s | %-22s | %8.4f | %9.1f%% | %8.2f | %10.4f\n",
              s$paper, s$collider, s$IVB,
              abs(s$IVB_pct_beta),
              ifelse(is.na(s$IVB_over_SE), NA, s$IVB_over_SE),
              abs(s$IVB_over_SDY)))
}

# Summary statistics
cat("\n\n")
cat("======================================================================\n")
cat("SUMMARY STATISTICS\n")
cat("======================================================================\n\n")
cat(sprintf("Total IVB estimates: %d\n", nrow(df_all)))
cat(sprintf("Median |IVB/SD(Y)|:  %.4f\n", median(abs(df_all$IVB_over_SDY), na.rm = TRUE)))
cat(sprintf("Mean |IVB/SD(Y)|:    %.4f\n", mean(abs(df_all$IVB_over_SDY), na.rm = TRUE)))
cat(sprintf("Max |IVB/SD(Y)|:     %.4f (%s, %s)\n",
            max(abs(df_all$IVB_over_SDY), na.rm = TRUE),
            df_sorted$paper[1], df_sorted$collider[1]))

cat(sprintf("\nMedian |IVB/beta|:    %.1f%%\n", median(abs(df_all$IVB_pct_beta), na.rm = TRUE)))
cat(sprintf("Mean |IVB/beta|:      %.1f%%\n", mean(abs(df_all$IVB_pct_beta), na.rm = TRUE)))

non_na_se <- df_all[!is.na(df_all$IVB_over_SE), ]
cat(sprintf("\nMedian |IVB/SE|:      %.2f\n", median(abs(non_na_se$IVB_over_SE), na.rm = TRUE)))
cat(sprintf("Mean |IVB/SE|:        %.2f\n", mean(abs(non_na_se$IVB_over_SE), na.rm = TRUE)))
cat(sprintf("Max |IVB/SE|:         %.2f (%s, %s)\n",
            max(abs(non_na_se$IVB_over_SE), na.rm = TRUE),
            non_na_se$paper[which.max(abs(non_na_se$IVB_over_SE))],
            non_na_se$collider[which.max(abs(non_na_se$IVB_over_SE))]))
n_gt1 <- sum(abs(non_na_se$IVB_over_SE) > 1)
cat(sprintf("|IVB/SE| > 1:         %d of %d (%.0f%%)\n",
            n_gt1, nrow(non_na_se), 100 * n_gt1 / nrow(non_na_se)))

# Save to CSV
write.csv(df_all, "standardized_ivb_metrics.csv", row.names = FALSE)
cat("\nSaved full results to standardized_ivb_metrics.csv\n")
