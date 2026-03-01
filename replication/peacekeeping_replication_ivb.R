###############################################################################
# IVB Decomposition for:
#   "UN Peacekeeping and Democratization in Conflict-Affected Countries"
#   Blair, Di Salvatore, and Smidt (2023), APSR
#
# Replication of Tables 2, 4, 5, and 6 + IVB analysis
#
# IVB Identity: beta* - beta = -theta* x pi
#   beta*  = treatment coeff in "long" model (with candidate collider z)
#   beta   = treatment coeff in "short" model (without z)
#   theta* = coeff of z in the long model
#   pi     = coeff of treatment in auxiliary regression z ~ treatment + controls
###############################################################################

library(haven)
library(dplyr)
library(fixest)

source("ivb_utils.R")

# ============================================================================
# 1. LOAD AND PREPARE DATA
# ============================================================================

df_raw <- read_dta("candidate_papers/peacekeeping/data_replication.dta")

cat("Raw data dimensions:", dim(df_raw), "\n")

# --- Replicate Stata data processing steps ---

# Drop Eritrea before 1993 and South Sudan before 2011
df <- df_raw %>%
  filter(!(gwnoloc == 531 & year < 1993)) %>%
  filter(!(gwnoloc == 626 & year < 2011))

# Sort by country-year (essential for lag generation)
df <- df %>% arrange(gwnoloc, year)

# --- Generate lagged dependent variables ---
# NOTE: Panel is balanced (no year gaps), so row-based lag is equivalent to
# time-based lag. This matches the Stata code which uses [_n-k] after sort.
df <- df %>%
  group_by(gwnoloc) %>%
  mutate(
    v2x_polyarchy_1l = lag(v2x_polyarchy, 1),
    v2x_polyarchy_2l = lag(v2x_polyarchy, 2),
    v2x_polyarchy_3l = lag(v2x_polyarchy, 3)
  ) %>%
  ungroup()

# --- Divide personnel numbers by 1,000 ---
df <- df %>%
  mutate(
    itotal_compound_K = itotal_compound / 1000,
    iactual_civilian_total_K = iactual_civilian_total / 1000
  )

# --- Generate lagged independent variables (2-period lag) ---
# Stata: gen `x'_2l=`x'[_n-2] (done BEFORE imputation of controls)
df <- df %>%
  group_by(gwnoloc) %>%
  mutate(
    ipema_any_demo_assist_dum_2l = lag(ipema_any_demo_assist_dum, 2),
    itotal_compound_K_2l = lag(itotal_compound_K, 2),
    iactual_civilian_total_K_2l = lag(iactual_civilian_total_K, 2),
    iany_demo_all_max_dum_2l = lag(iany_demo_all_max_dum, 2)
  ) %>%
  ungroup()

# --- Impute missing controls with within-country means ---
# Stata code: bys gwnoloc: egen `x'_mean=mean(`x')
#             gen i`x'=`x'
#             replace i`x'=`x'_mean if `x'==.
# IMPORTANT: Imputation is done BEFORE lagging controls.
ctrl_vars <- c("wdi_pop", "wdi_oda", "wdi_gdppc", "unhcr_ref_idp",
               "wdi_literacy", "wdi_fuel")

for (v in ctrl_vars) {
  new_v <- paste0("i", v)
  df[[new_v]] <- df[[v]]
  # Compute within-country mean
  country_means <- df %>%
    group_by(gwnoloc) %>%
    summarise(cmean = mean(.data[[v]], na.rm = TRUE), .groups = "drop")
  df <- df %>%
    left_join(country_means, by = "gwnoloc", suffix = c("", "_cm"))
  # Replace missing with country mean
  df[[new_v]] <- ifelse(is.na(df[[new_v]]), df$cmean, df[[new_v]])
  df$cmean <- NULL
}

# --- Generate lagged control variables (3-period lag) ---
# Stata: gen i`x'_3l=i`x'[_n-3]  (lagging the IMPUTED versions)
df <- df %>%
  group_by(gwnoloc) %>%
  mutate(
    iwdi_pop_3l = lag(iwdi_pop, 3),          # imputed version
    iwdi_oda_3l = lag(iwdi_oda, 3),
    iwdi_gdppc_3l = lag(iwdi_gdppc, 3),
    iunhcr_ref_idp_3l = lag(iunhcr_ref_idp, 3),
    iwdi_literacy_3l = lag(iwdi_literacy, 3),
    iwdi_fuel_3l = lag(iwdi_fuel, 3)
  ) %>%
  ungroup()

# NOTE: The Stata code lags iwdi_X (the imputed controls), not wdi_X.
# Our lag names match the imputed prefix convention.
# However, the raw column names are wdi_pop, etc. -- the imputed versions
# (iwdi_pop, etc.) were created above. We need to lag those instead.

# --- Generate UCDP conflict subsamples ---
df <- df %>%
  mutate(ucdp_0yrs = ucdp)

# ucdp_1yrs: 1 if at peace for at least 1 year after conflict end
df <- df %>%
  group_by(gwnoloc) %>%
  mutate(
    ucdp_first_start_alt = ifelse(any(!is.na(ucdp_start_alt)),
                                   min(ucdp_start_alt, na.rm = TRUE), NA_real_)
  ) %>%
  ungroup() %>%
  mutate(
    ucdp_1yrs = case_when(
      ucdp_ever == 0 ~ NA_real_,
      ucdp == 1 ~ 0,
      !is.na(ucdp_end_alt) & year >= ucdp_end_alt + 1 ~ 1,
      TRUE ~ 0
    ),
    ucdp_2yrs = case_when(
      ucdp_ever == 0 ~ NA_real_,
      ucdp == 1 ~ 0,
      !is.na(ucdp_end_alt) & year >= ucdp_end_alt + 2 ~ 1,
      TRUE ~ 0
    ),
    ucdp_3yrs = case_when(
      ucdp_ever == 0 ~ NA_real_,
      ucdp == 1 ~ 0,
      !is.na(ucdp_end_alt) & year >= ucdp_end_alt + 3 ~ 1,
      TRUE ~ 0
    )
  )

# Set to NA before first conflict start
df <- df %>%
  mutate(
    ucdp_1yrs = ifelse(!is.na(ucdp_first_start_alt) & year < ucdp_first_start_alt, NA_real_, ucdp_1yrs),
    ucdp_2yrs = ifelse(!is.na(ucdp_first_start_alt) & year < ucdp_first_start_alt, NA_real_, ucdp_2yrs),
    ucdp_3yrs = ifelse(!is.na(ucdp_first_start_alt) & year < ucdp_first_start_alt, NA_real_, ucdp_3yrs)
  )

# --- Drop observations before 1991 ---
df <- df %>% filter(year >= 1991)

cat("Analysis data dimensions:", dim(df), "\n")
cat("Year range:", range(df$year), "\n")

# ============================================================================
# 2. DEFINE SPECIFICATION COMPONENTS
# ============================================================================

# Outcome
y_var <- "v2x_polyarchy"

# Treatment variables (one per table)
d_table2 <- "ipema_any_demo_assist_dum_2l"   # Democracy mandate (Table 2)
d_table4 <- "itotal_compound_K_2l"           # Uniformed personnel (Table 4)
d_table5 <- "iactual_civilian_total_K_2l"    # Civilian personnel (Table 5)
d_table6 <- "iany_demo_all_max_dum_2l"       # Democracy activities (Table 6)

# Controls (all lagged 3 periods)
ctrl_vars_lagged <- c("iwdi_pop_3l", "iwdi_oda_3l", "iwdi_gdppc_3l",
                       "iunhcr_ref_idp_3l", "iwdi_literacy_3l", "iwdi_fuel_3l")

# Fixed effects
fe_var <- "gwnoloc"

# ============================================================================
# 3. REPLICATE TABLE 2 - Democracy Mandates (Column 1: Full Sample)
# ============================================================================

cat("\n")
cat("=" %>% rep(70) %>% paste(collapse = ""), "\n")
cat("REPLICATION: TABLE 2 - Electoral Democracy and UN Democracy Mandates\n")
cat("=" %>% rep(70) %>% paste(collapse = ""), "\n\n")

# Full sample (Column 1)
fml_t2 <- as.formula(paste0(y_var, " ~ ", d_table2, " + ",
                             paste(ctrl_vars_lagged, collapse = " + "),
                             " | ", fe_var))
m_t2_col1 <- feols(fml_t2, data = df, vcov = "iid")
cat("Table 2, Column 1 (Full sample):\n")
cat("  Democracy mandate coeff:", round(coef(m_t2_col1)[d_table2], 3), "\n")
cat("  SE:", round(sqrt(vcov(m_t2_col1)[d_table2, d_table2]), 3), "\n")
cat("  N:", nobs(m_t2_col1), "\n\n")

# Subsamples
for (sub_name in c("ucdp_0yrs", "ucdp_1yrs", "ucdp_2yrs", "ucdp_3yrs")) {
  df_sub <- df %>% filter(.data[[sub_name]] == 1)
  m_sub <- feols(fml_t2, data = df_sub, vcov = "iid")
  cat(sprintf("Table 2, %s subsample: coeff = %.3f, SE = %.3f, N = %d\n",
              sub_name, coef(m_sub)[d_table2],
              sqrt(vcov(m_sub)[d_table2, d_table2]), nobs(m_sub)))
}

# ============================================================================
# 4. REPLICATE TABLE 4 - Uniformed Personnel (Column 1: Full Sample)
# ============================================================================

cat("\n")
cat("=" %>% rep(70) %>% paste(collapse = ""), "\n")
cat("REPLICATION: TABLE 4 - Electoral Democracy and UN Uniformed Personnel\n")
cat("=" %>% rep(70) %>% paste(collapse = ""), "\n\n")

fml_t4 <- as.formula(paste0(y_var, " ~ ", d_table4, " + ",
                             paste(ctrl_vars_lagged, collapse = " + "),
                             " | ", fe_var))
m_t4_col1 <- feols(fml_t4, data = df, vcov = "iid")
cat("Table 4, Column 1 (Full sample):\n")
cat("  # uniformed personnel coeff:", round(coef(m_t4_col1)[d_table4], 3), "\n")
cat("  SE:", round(sqrt(vcov(m_t4_col1)[d_table4, d_table4]), 3), "\n")
cat("  N:", nobs(m_t4_col1), "\n\n")

# ============================================================================
# 5. REPLICATE TABLE 5 - Civilian Personnel (Column 1: Full Sample)
# ============================================================================

cat("=" %>% rep(70) %>% paste(collapse = ""), "\n")
cat("REPLICATION: TABLE 5 - Electoral Democracy and UN Civilian Personnel\n")
cat("=" %>% rep(70) %>% paste(collapse = ""), "\n\n")

fml_t5 <- as.formula(paste0(y_var, " ~ ", d_table5, " + ",
                             paste(ctrl_vars_lagged, collapse = " + "),
                             " | ", fe_var))
m_t5_col1 <- feols(fml_t5, data = df, vcov = "iid")
cat("Table 5, Column 1 (Full sample):\n")
cat("  # civilian personnel coeff:", round(coef(m_t5_col1)[d_table5], 3), "\n")
cat("  SE:", round(sqrt(vcov(m_t5_col1)[d_table5, d_table5]), 3), "\n")
cat("  N:", nobs(m_t5_col1), "\n\n")

# ============================================================================
# 6. REPLICATE TABLE 6 - Democracy Activities (Column 1: Full Sample)
# ============================================================================

cat("=" %>% rep(70) %>% paste(collapse = ""), "\n")
cat("REPLICATION: TABLE 6 - Electoral Democracy and UN Democracy Activities\n")
cat("=" %>% rep(70) %>% paste(collapse = ""), "\n\n")

fml_t6 <- as.formula(paste0(y_var, " ~ ", d_table6, " + ",
                             paste(ctrl_vars_lagged, collapse = " + "),
                             " | ", fe_var))
m_t6_col1 <- feols(fml_t6, data = df, vcov = "iid")
cat("Table 6, Column 1 (Full sample):\n")
cat("  Any democracy activities coeff:", round(coef(m_t6_col1)[d_table6], 3), "\n")
cat("  SE:", round(sqrt(vcov(m_t6_col1)[d_table6, d_table6]), 3), "\n")
cat("  N:", nobs(m_t6_col1), "\n\n")


# ============================================================================
# 7. IVB DECOMPOSITION
# ============================================================================
#
# For each table's main specification (Column 1 = full sample), we treat each
# control variable as a candidate collider z. The IVB tells us how much the
# treatment coefficient changes when z is added.
#
# The "short" model: Y ~ D + W_(-z) | FE
# The "long" model:  Y ~ D + W_(-z) + z | FE  (= full specification)
# Auxiliary:          z ~ D + W_(-z) | FE
#
# This means: for each control z_k, the remaining controls W_(-z_k) serve as
# the "legitimate" controls w, and z_k is the candidate collider.
# ============================================================================

cat("\n")
cat("=" %>% rep(70) %>% paste(collapse = ""), "\n")
cat("IVB DECOMPOSITION\n")
cat("=" %>% rep(70) %>% paste(collapse = ""), "\n\n")

# Pretty names for controls
ctrl_labels <- c(
  "iwdi_pop_3l" = "Population (3yr lag)",
  "iwdi_oda_3l" = "Foreign Aid (3yr lag)",
  "iwdi_gdppc_3l" = "GDP per capita (3yr lag)",
  "iunhcr_ref_idp_3l" = "Refugees & IDPs (3yr lag)",
  "iwdi_literacy_3l" = "Literacy (3yr lag)",
  "iwdi_fuel_3l" = "Fuel Exports (3yr lag)"
)

# Function to run IVB for all controls as candidate colliders
run_ivb_all_controls <- function(data, y, d_var, controls, fe, table_name) {
  cat("\n")
  cat("-" %>% rep(70) %>% paste(collapse = ""), "\n")
  cat(sprintf("IVB for %s\n", table_name))
  cat(sprintf("Treatment: %s\n", d_var))
  cat("-" %>% rep(70) %>% paste(collapse = ""), "\n\n")

  results_list <- list()

  for (z in controls) {
    w <- setdiff(controls, z)

    tryCatch({
      res <- compute_ivb_multi(
        data = data,
        y = y,
        d_vars = d_var,
        z = z,
        w = w,
        fe = fe,
        vcov = "iid"
      )

      res_df <- res$results
      res_df$collider <- z
      res_df$collider_label <- ctrl_labels[z]
      res_df$table <- table_name
      res_df$sample_n <- res$sample_n
      results_list[[z]] <- res_df

      cat(sprintf("  Collider: %-35s | theta* = %10.6f | pi = %10.6f | IVB = %10.6f | check = %e\n",
                  ctrl_labels[z],
                  res_df$theta,
                  res_df$pi,
                  res_df$ivb_formula,
                  res_df$diff_check))

    }, error = function(e) {
      cat(sprintf("  Collider: %-35s | ERROR: %s\n", ctrl_labels[z], e$message))
    })
  }

  if (length(results_list) > 0) {
    combined <- do.call(rbind, results_list)
    rownames(combined) <- NULL

    # Sort by absolute IVB
    combined <- combined %>% arrange(desc(abs(ivb_formula)))

    cat("\n  Summary (sorted by |IVB|):\n")
    cat(sprintf("  %-35s %12s %12s %12s %12s %12s\n",
                "Collider", "beta_short", "beta_long", "theta*", "pi", "IVB"))
    cat("  ", paste(rep("-", 100), collapse = ""), "\n")
    for (i in seq_len(nrow(combined))) {
      r <- combined[i, ]
      cat(sprintf("  %-35s %12.6f %12.6f %12.6f %12.6f %12.6f\n",
                  r$collider_label, r$beta_short, r$beta_long,
                  r$theta, r$pi, r$ivb_formula))
    }
    cat("\n")

    return(combined)
  } else {
    return(NULL)
  }
}

# --- Run IVB for Table 2: Democracy Mandates ---
ivb_t2 <- run_ivb_all_controls(
  data = df,
  y = y_var,
  d_var = d_table2,
  controls = ctrl_vars_lagged,
  fe = fe_var,
  table_name = "Table 2: Democracy Mandates"
)

# --- Run IVB for Table 4: Uniformed Personnel ---
ivb_t4 <- run_ivb_all_controls(
  data = df,
  y = y_var,
  d_var = d_table4,
  controls = ctrl_vars_lagged,
  fe = fe_var,
  table_name = "Table 4: Uniformed Personnel"
)

# --- Run IVB for Table 5: Civilian Personnel ---
ivb_t5 <- run_ivb_all_controls(
  data = df,
  y = y_var,
  d_var = d_table5,
  controls = ctrl_vars_lagged,
  fe = fe_var,
  table_name = "Table 5: Civilian Personnel"
)

# --- Run IVB for Table 6: Democracy Activities ---
ivb_t6 <- run_ivb_all_controls(
  data = df,
  y = y_var,
  d_var = d_table6,
  controls = ctrl_vars_lagged,
  fe = fe_var,
  table_name = "Table 6: Democracy Activities"
)

# ============================================================================
# 8. COMBINED IVB RESULTS AND INTERPRETATION
# ============================================================================

cat("\n")
cat("=" %>% rep(70) %>% paste(collapse = ""), "\n")
cat("COMBINED IVB RESULTS AND INTERPRETATION\n")
cat("=" %>% rep(70) %>% paste(collapse = ""), "\n\n")

all_ivb <- bind_rows(ivb_t2, ivb_t4, ivb_t5, ivb_t6)

# For each table, show the proportion of total bias from each control
for (tbl in unique(all_ivb$table)) {
  tbl_data <- all_ivb %>% filter(table == tbl)
  total_ivb <- sum(tbl_data$ivb_formula)
  beta_short_no_controls <- tbl_data$beta_long[1] - total_ivb  # approximate

  cat(sprintf("\n--- %s ---\n", tbl))
  cat(sprintf("  Treatment coefficient (long/full model): %.6f\n", tbl_data$beta_long[1]))
  cat(sprintf("  Sum of all IVBs: %.6f\n", total_ivb))
  cat(sprintf("  Treatment coefficient without ANY controls (short, no z): approx %.6f\n\n",
              tbl_data$beta_long[1] - total_ivb))

  cat(sprintf("  %-35s %12s %12s\n", "Control (candidate collider)", "IVB", "% of total"))
  cat("  ", paste(rep("-", 65), collapse = ""), "\n")
  for (i in seq_len(nrow(tbl_data))) {
    r <- tbl_data[i, ]
    pct <- ifelse(abs(total_ivb) > 1e-10, 100 * r$ivb_formula / total_ivb, NA)
    cat(sprintf("  %-35s %12.6f %11.1f%%\n",
                r$collider_label, r$ivb_formula, pct))
  }
  cat("\n")
}

# ============================================================================
# 9. COLLIDER PLAUSIBILITY ASSESSMENT
# ============================================================================

cat("\n")
cat("=" %>% rep(70) %>% paste(collapse = ""), "\n")
cat("COLLIDER PLAUSIBILITY ASSESSMENT\n")
cat("=" %>% rep(70) %>% paste(collapse = ""), "\n\n")

cat("For IVB to represent actual bias, the control must be a collider:\n")
cat("  D -> Z <- Y (treatment and outcome both cause the control)\n")
cat("Note: controls are lagged 3 periods; treatment is lagged 2 periods.\n")
cat("So controls are measured BEFORE the treatment, making reverse causality\n")
cat("from Y to Z unlikely for most controls.\n\n")

cat("Control-by-control assessment:\n\n")

cat("1. Population (3yr lag): iwdi_pop_3l\n")
cat("   Plausible collider? UNLIKELY. Population is slow-moving and unlikely\n")
cat("   to be caused by current democracy levels. IVB likely reflects\n")
cat("   confounding rather than collider bias.\n\n")

cat("2. Foreign Aid (3yr lag): iwdi_oda_3l\n")
cat("   Plausible collider? POSSIBLE but unlikely given lag structure.\n")
cat("   Foreign aid could respond to democratization AND peacekeeping.\n")
cat("   Donors may reward democratization with more aid, and also provide\n")
cat("   more aid to countries with UN missions. But the 3-year lag reduces\n")
cat("   this concern.\n\n")

cat("3. GDP per capita (3yr lag): iwdi_gdppc_3l\n")
cat("   Plausible collider? UNLIKELY. GDP per capita is unlikely to be\n")
cat("   caused by current electoral democracy in the short run.\n\n")

cat("4. Refugees & IDPs (3yr lag): iunhcr_ref_idp_3l\n")
cat("   Plausible collider? POSSIBLE. Refugee flows could respond to both\n")
cat("   peacekeeping presence and democratization processes. Countries with\n")
cat("   UN missions may attract refugee returns, and democratization may\n")
cat("   reduce displacement. But again the 3-year lag structure mitigates.\n\n")

cat("5. Literacy (3yr lag): iwdi_literacy_3l\n")
cat("   Plausible collider? VERY UNLIKELY. Literacy changes slowly and is\n")
cat("   not plausibly caused by electoral democracy.\n\n")

cat("6. Fuel Exports (3yr lag): iwdi_fuel_3l\n")
cat("   Plausible collider? VERY UNLIKELY. Fuel exports are determined by\n")
cat("   natural resource endowments, not by democracy or peacekeeping.\n\n")

cat("OVERALL ASSESSMENT:\n")
cat("The 3-period lag on controls relative to the 2-period lag on treatment\n")
cat("makes collider bias unlikely for most controls, since the controls are\n")
cat("measured BEFORE the treatment. This is a deliberate design choice by\n")
cat("the authors to avoid post-treatment bias. The IVB decomposition here\n")
cat("primarily reveals the sensitivity of the treatment coefficient to the\n")
cat("inclusion/exclusion of each control, which could reflect either collider\n")
cat("bias or confounding bias depending on the underlying causal structure.\n")

cat("\n\nDone.\n")

# ============================================================================
# 10. SAVE RESULTS
# ============================================================================

write.csv(all_ivb,
          "candidate_papers/peacekeeping/ivb_results_all_tables.csv",
          row.names = FALSE)
cat("IVB results saved to candidate_papers/peacekeeping/ivb_results_all_tables.csv\n")
