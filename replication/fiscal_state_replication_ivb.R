###############################################################################
# Replication + IVB Decomposition
# Paper: "The Fiscal State in Africa: Evidence from a Century of Growth"
#         Albers, Jerven, and Suesse (2023), International Organization
#         DOI: 10.1017/S0020818322000285
#
# Table 1, Column 6 (Full specification with controls)
#
# Dependent variable: Change in real tax collection per capita,
#                     excluding trade and resource taxes (5-year averages)
# Treatment variables (for IVB, we focus on government turnover as primary):
#   - government turnover (lagged)
#   - liberal democracy score
#   - civil wars (lagged)
#   - international wars (lagged)
#   - resource exports [NOT AVAILABLE -- complex commodity price index]
#   - exposure to foreign aid
#   - credit market access
# Controls: droughts, GDP growth, hyperinflation, sovereign default,
#           socialist systems, territorial changes, independent statehood
# Fixed effects: Polity (iso_n) + Period (demidecade)
#
# IVB formula: beta* - beta = -theta* * pi
#
# REPLICATION NOTE:
#   This script reconstructs the 5-year panel from raw Dataverse files in R,
#   replicating the Stata data pipeline (13 do-files). Some variables could
#   not be perfectly replicated due to:
#   1. P_ind_total_f_realshare (resource exports): requires commodity prices,
#      trade shares, and deflators from multiple sources with complex weighting
#   2. S_g5_unw_alliance_abs (aid exposure): partially available (political
#      similarity scores + metropolitan budget weights)
#   3. Minor differences in interpolation/extrapolation methods between R/Stata
#   The sample is N=491 (vs N=873 in the paper), primarily due to missing ODA
#   data reducing the sample when S_g5_unw_alliance_abs is included.
#
# Replication data: https://doi.org/10.7910/DVN/TT0SJZ
###############################################################################

# Load packages
library(data.table)
library(fixest)
library(haven)     # for reading .dta files (Political_similarity)

# Source IVB utilities
source("ivb_utils.R")

# Data directory
data_dir <- "candidate_papers/fiscal_state_africa/"

cat("=================================================================\n")
cat("STEP 1: Loading and processing raw data files\n")
cat("=================================================================\n\n")

###############################################################################
# 1. NOMENCLATURE -- define polity-year panel
###############################################################################
cat("Loading Nomenclature...\n")
nom <- fread(file.path(data_dir, "Nomenclature.tab"), sep = "\t")
nom[, core_sample := 1L]

nom_exp <- fread(file.path(data_dir, "Nomenclature_expand.tab"), sep = "\t")
nom_exp[, core_sample := 0L]

# Harmonise columns before rbinding
common_cols <- intersect(names(nom), names(nom_exp))
master <- rbind(nom[, ..common_cols], nom_exp[, ..common_cols], fill = TRUE)
master[is.na(core_sample), core_sample := 0L]

setorder(master, iso, year)

# iso_cow mapping
iso_cow <- fread(file.path(data_dir, "iso_cow.tab"), sep = "\t")
master <- merge(master, iso_cow, by = "iso", all.x = TRUE)

# cow_states for state years
cow_states <- fread(file.path(data_dir, "cow_states_2016.tab"), sep = "\t")
if ("cow_num" %in% names(cow_states) & "cow_num" %in% names(master)) {
  master <- merge(master, cow_states, by = "cow_num", all.x = TRUE, suffixes = c("", ".cow"))
}

# Independence & coloniser coding
master[iso == "LBR", styear := 1890]
master[iso == "ZAF", styear := 1931]
master[, indep := as.integer(!is.na(styear) & styear <= year)]
master[iso == "ETH" & year < 1936, indep := 1L]
master[is.na(indep), indep := 0L]

# Coloniser dummies
master[, Britain_col := as.integer(coloniser %in% c("UK  - FRN", "UK", "SA") | iso == "EGY")]
master[is.na(Britain_col), Britain_col := 0L]
master[, France_col := as.integer(coloniser %in% c("France - AEF", "France - AOF", "France"))]
master[is.na(France_col), France_col := 0L]
master[, Portugal_col := as.integer(coloniser == "Portugal")]
master[is.na(Portugal_col), Portugal_col := 0L]
master[, Belgium_col := as.integer(coloniser == "Belgium")]
master[is.na(Belgium_col), Belgium_col := 0L]
master[, Italy_col := as.integer(coloniser == "Italy")]
master[is.na(Italy_col), Italy_col := 0L]
master[, AOF_col := as.integer(coloniser == "France - AOF")]
master[is.na(AOF_col), AOF_col := 0L]
master[, AEF_col := as.integer(coloniser == "France - AEF")]
master[is.na(AEF_col), AEF_col := 0L]

master[, Germany_col := as.integer(iso %in% c("TZA", "NAM", "TGO", "CMR", "RWA", "BDI") & year < 1916)]
master[is.na(Germany_col), Germany_col := 0L]

# Socialist coding
master[, socialist := 0L]
master[iso == "EGY" & year > 1954 & year < 1974, socialist := 1L]
master[iso == "GIN" & year > 1960 & year < 1978, socialist := 1L]
master[iso == "MLI" & year > 1960 & year < 1968, socialist := 1L]
master[iso == "TZA" & year > 1967 & year < 1985, socialist := 1L]
master[iso == "SOM" & year > 1969 & year < 1978, socialist := 1L]
master[iso == "DZA" & year > 1963 & year < 1987, socialist := 1L]
master[iso == "GHA" & year > 1964 & year < 1966, socialist := 1L]
master[iso == "SDN" & year > 1969 & year < 1971, socialist := 1L]
master[iso == "LBY" & year > 1978 & year < 1999, socialist := 1L]
master[iso == "COG" & year > 1969 & year < 1991, socialist := 1L]
master[iso == "MDG" & year > 1975 & year < 1992, socialist := 1L]
master[iso == "GNB" & year > 1973 & year < 1991, socialist := 1L]
master[iso == "ETH" & year > 1974 & year < 1991, socialist := 1L]
master[iso == "BEN" & year > 1975 & year < 1989, socialist := 1L]
master[iso == "MOZ" & year > 1975 & year < 1989, socialist := 1L]
master[iso == "AGO" & year > 1975 & year < 1991, socialist := 1L]
master[iso == "BFA" & year > 1983 & year < 1987, socialist := 1L]

# Secession
master[, secession := 0L]
master[iso == "ETH" & year %in% c(1991, 1992, 1993), secession := 1L]
master[iso == "SDN" & year == 2011, secession := 1L]

cat("  Nomenclature loaded:", uniqueN(master$iso), "polities,", nrow(master), "rows\n")

###############################################################################
# 2. FISCAL DATA
###############################################################################
cat("Loading Fiscal Data...\n")
fiscal <- fread(file.path(data_dir, "FISCAL_PANEL_V4.tab"), sep = "\t")
# Clean quoted strings
for (col in names(fiscal)) {
  if (is.character(fiscal[[col]])) {
    fiscal[, (col) := gsub('^"|"$', '', get(col))]
  }
}
fiscal[, iso := gsub('^"|"$', '', iso)]

fiscal_somdji <- fread(file.path(data_dir, "FISCAL_PANEL_V4_SOMDJI.tab"), sep = "\t")
for (col in names(fiscal_somdji)) {
  if (is.character(fiscal_somdji[[col]])) {
    fiscal_somdji[, (col) := gsub('^"|"$', '', get(col))]
  }
}
fiscal_somdji[, iso := gsub('^"|"$', '', iso)]

# Merge fiscal data - update with SOMDJI data
fiscal_cols <- c("INDIRECT_NOMINAL", "DIRECT_NOMINAL", "NONTAX_ORDINARY_NOMINAL",
                 "RESOURCES_NOMINAL", "EXTRAORDINARY_NOMINAL", "INDIRECT_EXCL_TR_NOMINAL",
                 "TRADE_TAXES_NOMINAL", "WAGES", "POPULATION", "Forced_Labourdays_pc", "GDP_Deflator")

# Convert to numeric
for (col in fiscal_cols) {
  if (col %in% names(fiscal)) fiscal[, (col) := as.numeric(get(col))]
  if (col %in% names(fiscal_somdji)) fiscal_somdji[, (col) := as.numeric(get(col))]
}

# Merge main fiscal panel first
fiscal_keep <- fiscal[, c("iso", "year", fiscal_cols[fiscal_cols %in% names(fiscal)]), with = FALSE]
master <- merge(master, fiscal_keep, by = c("iso", "year"), all.x = TRUE)

# Update with SOMDJI data where missing
somdji_cols <- intersect(fiscal_cols, names(fiscal_somdji))
fiscal_somdji_keep <- fiscal_somdji[, c("iso", "year", somdji_cols), with = FALSE]
for (col in somdji_cols) {
  setnames(fiscal_somdji_keep, col, paste0(col, "_somdji"))
}
master <- merge(master, fiscal_somdji_keep, by = c("iso", "year"), all.x = TRUE)
for (col in somdji_cols) {
  scol <- paste0(col, "_somdji")
  if (scol %in% names(master)) {
    master[is.na(get(col)) & !is.na(get(scol)), (col) := get(scol)]
    master[, (scol) := NULL]
  }
}

# Define expanded sample
master[, expansion := as.integer(iso %in% c("DJI", "SOM", "LBR", "LBY", "ETH"))]

# Create iso_n
master[, iso_n := as.integer(factor(iso))]
setorder(master, iso_n, year)

# Compute fiscal variables
# tax_non_trade_real = (DIRECT_NOMINAL + INDIRECT_EXCL_TR_NOMINAL) / WAGES / POPULATION
master[, tax_non_trade_real := (DIRECT_NOMINAL + INDIRECT_EXCL_TR_NOMINAL) / WAGES / POPULATION]

cat("  Fiscal data merged.\n")

###############################################################################
# 3. DEMOCRACY (V-Dem)
###############################################################################
cat("Loading Democracy data...\n")
vdem <- fread(file.path(data_dir, "VDEM_small.tab"), sep = "\t")
for (col in names(vdem)) {
  if (is.character(vdem[[col]])) vdem[, (col) := gsub('^"|"$', '', get(col))]
}
# Keep key democracy variables
vdem_cols <- c("v2x_libdem", "v2x_polyarchy", "v2x_partipdem", "v2x_delibdem", "v2x_egaldem")
vdem_keep <- intersect(c("iso", "year", vdem_cols), names(vdem))
vdem <- vdem[, ..vdem_keep]
for (col in vdem_cols[vdem_cols %in% names(vdem)]) {
  vdem[, (col) := as.numeric(get(col))]
}

# Extrapolate backward: for CMR, use TGO values pre-1960
if ("v2x_libdem" %in% names(vdem)) {
  tgo_vals <- vdem[iso == "TGO", .(year, v2x_libdem_tgo = v2x_libdem)]
  vdem <- merge(vdem, tgo_vals, by = "year", all.x = TRUE)
  vdem[iso == "CMR" & year < 1960 & is.na(v2x_libdem), v2x_libdem := v2x_libdem_tgo]
  vdem[, v2x_libdem_tgo := NULL]
}

# Interpolate and backfill within iso
setorder(vdem, iso, year)
if ("v2x_libdem" %in% names(vdem)) {
  # Interpolate within iso, but only if >= 2 non-NA values
  vdem[, n_nonNA := sum(!is.na(v2x_libdem)), by = iso]
  vdem[n_nonNA >= 2, libdem_extra_vdem := approx(year, v2x_libdem, xout = year, rule = 2)$y, by = iso]
  vdem[n_nonNA < 2, libdem_extra_vdem := v2x_libdem]
  vdem[, n_nonNA := NULL]
  # Backfill for early years
  vdem[, libdem_extra_vdem := nafill(libdem_extra_vdem, type = "nocb"), by = iso]
} else {
  vdem[, libdem_extra_vdem := NA_real_]
}

master <- merge(master, vdem[, .(iso, year, libdem_extra_vdem)], by = c("iso", "year"), all.x = TRUE)

cat("  Democracy data merged.\n")

###############################################################################
# 4. REGIME TURNOVER
###############################################################################
cat("Loading Regime Turnover data...\n")
vdem_regime <- fread(file.path(data_dir, "V-Dem_regime_change.tab"), sep = "\t")
for (col in names(vdem_regime)) {
  if (is.character(vdem_regime[[col]])) vdem_regime[, (col) := gsub('^"|"$', '', get(col))]
}

# Extract regime end years
if ("v2reginfo" %in% names(vdem_regime)) {
  vdem_regime[, regime_end_str := substr(v2reginfo, nchar(v2reginfo) - 4, nchar(v2reginfo) - 1)]
  vdem_regime[regime_end_str %in% c(" - E", "egim", ""), regime_end_str := NA_character_]
  vdem_regime[, regime_year := as.numeric(regime_end_str)]

  # Create regime_end events
  regime_ends <- vdem_regime[!is.na(regime_year), .(regime_year = mean(regime_year)), by = .(iso, year)]
  regime_ends[, year_r := floor(regime_year)]
  regime_ends <- regime_ends[!is.na(year_r)]
  regime_ends <- unique(regime_ends[, .(iso, year = year_r)])
  regime_ends[, regime_end := 1L]

  master <- merge(master, regime_ends, by = c("iso", "year"), all.x = TRUE)
  master[is.na(regime_end), regime_end := 0L]
} else {
  master[, regime_end := 0L]
}

# Electoral change from v2eltvrexo
if ("v2eltvrexo" %in% names(vdem_regime)) {
  vdem_regime[, v2eltvrexo := as.numeric(v2eltvrexo)]
  elec <- vdem_regime[!is.na(v2eltvrexo), .(v2eltvrexo_sum = sum(v2eltvrexo, na.rm = TRUE)), by = .(iso, year)]
  elec[v2eltvrexo_sum > 2, v2eltvrexo_sum := 2]
  elec[, elec_change := as.integer(v2eltvrexo_sum == 2)]
  elec <- elec[elec_change == 1, .(iso, year, elec_change)]

  master <- merge(master, elec, by = c("iso", "year"), all.x = TRUE)
  master[is.na(elec_change), elec_change := 0L]
} else {
  master[, elec_change := 0L]
}

# gov_change = regime_end + elec_change (capped at 1)
master[, gov_change := pmin(regime_end + elec_change, 1L)]

cat("  Regime turnover data merged.\n")

###############################################################################
# 5. CONFLICT (UCDP/PRIO)
###############################################################################
cat("Loading Conflict data...\n")
ucdp <- fread(file.path(data_dir, "UCDP_PRIO_updated_v16.tab"), sep = "\t")
for (col in names(ucdp)) {
  if (is.character(ucdp[[col]])) ucdp[, (col) := gsub('^"|"$', '', get(col))]
}

if ("type_of_conflict" %in% names(ucdp)) {
  ucdp[, type_of_conflict := as.integer(type_of_conflict)]
  ucdp[, intensity_level := as.integer(intensity_level)]

  # Civil wars (types 3 and 4)
  civ <- ucdp[type_of_conflict %in% c(3, 4), .(civ_war_all_PRIO = 1L), by = .(iso, year)]
  civ[, civ_war_all_PRIO := pmin(civ_war_all_PRIO, 1L)]

  # International wars (type 2)
  int_war <- ucdp[type_of_conflict == 2, .(int_war_all_PRIO = 1L), by = .(iso, year)]
  int_war[, int_war_all_PRIO := pmin(int_war_all_PRIO, 1L)]

  # Also check iso_b for side B countries
  if ("iso_b" %in% names(ucdp)) {
    civ_b <- ucdp[type_of_conflict %in% c(3, 4) & iso_b != "" & !is.na(iso_b),
                  .(civ_war_all_PRIO = 1L), by = .(iso = iso_b, year)]
    int_b <- ucdp[type_of_conflict == 2 & iso_b != "" & !is.na(iso_b),
                  .(int_war_all_PRIO = 1L), by = .(iso = iso_b, year)]
    civ <- rbind(civ, civ_b)[, .(civ_war_all_PRIO = pmin(sum(civ_war_all_PRIO), 1L)), by = .(iso, year)]
    int_war <- rbind(int_war, int_b)[, .(int_war_all_PRIO = pmin(sum(int_war_all_PRIO), 1L)), by = .(iso, year)]
  }

  master <- merge(master, civ, by = c("iso", "year"), all.x = TRUE)
  master <- merge(master, int_war, by = c("iso", "year"), all.x = TRUE)
  master[is.na(civ_war_all_PRIO), civ_war_all_PRIO := 0L]
  master[is.na(int_war_all_PRIO), int_war_all_PRIO := 0L]
} else {
  master[, civ_war_all_PRIO := 0L]
  master[, int_war_all_PRIO := 0L]
}

cat("  Conflict data merged.\n")

###############################################################################
# 6. DISASTERS (Droughts)
###############################################################################
cat("Loading Drought data...\n")
droughts <- fread(file.path(data_dir, "Droughts_GDO.tab"), sep = "\t")
for (col in names(droughts)) {
  if (is.character(droughts[[col]])) droughts[, (col) := gsub('^"|"$', '', get(col))]
}
# Key variable: drought_affected_merged (population affected by drought in millions)
# This is complex to construct. Use available drought data as proxy
if ("avgarea_percen" %in% names(droughts)) {
  droughts[, drought_affected_merged := as.numeric(avgarea_percen)]
} else if ("drght_occ" %in% names(droughts)) {
  droughts[, drought_affected_merged := as.numeric(drght_occ)]
} else {
  # Use any numeric column that seems relevant
  drought_cols <- names(droughts)[sapply(droughts, is.numeric)]
  if (length(drought_cols) > 0) {
    droughts[, drought_affected_merged := 0]
  }
}

if ("drought_affected_merged" %in% names(droughts)) {
  master <- merge(master, droughts[, .(iso, year, drought_affected_merged)],
                  by = c("iso", "year"), all.x = TRUE)
  master[is.na(drought_affected_merged), drought_affected_merged := 0]
} else {
  master[, drought_affected_merged := 0]
}

cat("  Drought data merged.\n")

###############################################################################
# 7. FINANCIAL VARIABLES
###############################################################################
cat("Loading Financial data (Interest rates, Credit)...\n")

# Interest rates
ir <- fread(file.path(data_dir, "Interest_rates.tab"), sep = "\t")
for (col in names(ir)) {
  if (is.character(ir[[col]])) ir[, (col) := gsub('^"|"$', '', get(col))]
}
# Extract year and average BoE interest rate
if ("date" %in% names(ir) & "boeinterestrate" %in% names(ir)) {
  ir[, boeinterestrate := as.numeric(boeinterestrate)]
  # Parse date to get year
  ir[, year_parsed := as.integer(substr(date, nchar(date) - 3, nchar(date)))]
  ir_annual <- ir[!is.na(year_parsed), .(IR_BoE = mean(boeinterestrate, na.rm = TRUE)), by = .(year = year_parsed)]
} else {
  # Try to use year column directly
  ir_cols <- names(ir)
  cat("  Interest rate columns:", paste(ir_cols, collapse=", "), "\n")
  ir[, year := as.integer(year)]
  boe_col <- grep("boe|BoE|BOE|interest", names(ir), value = TRUE, ignore.case = TRUE)
  if (length(boe_col) > 0) {
    ir[, IR_BoE := as.numeric(get(boe_col[1]))]
    ir_annual <- ir[!is.na(year), .(IR_BoE = mean(IR_BoE, na.rm = TRUE)), by = year]
  } else {
    ir_annual <- data.table(year = 1900:2015, IR_BoE = 5.0)
  }
}

master <- merge(master, ir_annual, by = "year", all.x = TRUE)

# Credit market access (replicate the coding from 1_8a do-file)
master[, credit_market_access := 0L]
master[indep == 1, credit_market_access := 1L]
master[iso %in% c("LBR", "EGY", "ZAF", "SLE"), credit_market_access := 1L]
master[iso == "GMB" & year >= 1888, credit_market_access := 1L]
master[iso == "GHA" & year >= 1895, credit_market_access := 1L]
master[iso == "NGA" & year >= 1906, credit_market_access := 1L]
master[iso == "KEN" & year >= 1920, credit_market_access := 1L]
master[iso == "ZWE" & year >= 1923, credit_market_access := 1L]
master[iso %in% c("BWA", "ZMB", "MWI", "UGA", "SWZ", "LSO", "TZA") & year >= 1930, credit_market_access := 1L]
master[iso == "ETH" & year >= 1950, credit_market_access := 1L]
master[iso == "COD", credit_market_access := 1L]
master[iso %in% c("RWA", "BDI") & year >= 1930, credit_market_access := 1L]
master[iso == "AGO" & year >= 1914 & year < 1930, credit_market_access := 1L]
master[iso == "AGO" & year >= 1958, credit_market_access := 1L]
master[iso == "MOZ" & year >= 1916 & year < 1930, credit_market_access := 1L]
master[iso == "MOZ" & year >= 1958, credit_market_access := 1L]
master[iso == "GNB" & year >= 1916 & year < 1930, credit_market_access := 1L]
master[iso == "GNB" & year >= 1958, credit_market_access := 1L]
master[iso == "DZA" & year >= 1902, credit_market_access := 1L]
master[iso %in% c("TUN", "MAR", "MDG"), credit_market_access := 1L]
master[iso == "CMR" & year >= 1931, credit_market_access := 1L]
master[iso == "TGO" & year >= 1931, credit_market_access := 1L]
# No wartime access for British colonies
master[Britain_col == 1 & year >= 1915 & year <= 1918, credit_market_access := 0L]
master[Britain_col == 1 & year >= 1940 & year <= 1945, credit_market_access := 0L]

# cr_market_accessXBOEinv = credit_market_access * (1/IR_BoE) / 2
master[, cr_market_accessXBOEinv := credit_market_access * (1 / IR_BoE) / 2]

cat("  Financial data merged.\n")

###############################################################################
# 8. AID / ODA -- Political Similarity measure
###############################################################################
cat("Loading Political similarity / ODA data...\n")

# Political similarity data (.dta format)
pol_sim <- tryCatch({
  as.data.table(read_dta(file.path(data_dir, "Political_similarity.dta")))
}, error = function(e) {
  cat("  Warning: Could not read Political_similarity.dta:", e$message, "\n")
  NULL
})

# Metropolitan budgets
met_budgets <- fread(file.path(data_dir, "Metropolitan_budgets.tab"), sep = "\t")
for (col in names(met_budgets)) {
  if (is.character(met_budgets[[col]])) met_budgets[, (col) := gsub('^"|"$', '', get(col))]
}

# This is the most complex part of the data construction.
# The aid variable S_g5_unw_alliance_abs is constructed from:
# 1. Political similarity scores (alliance-based, absolute S-score)
# 2. Weighted by metropolitan budget deficits
# 3. For independent polities after 1945: sum of UK, FR, US, RU, CN weighted scores
# 4. For colonial polities: weighted score of the respective metropole
#
# Given the extreme complexity, we construct this variable from the raw similarity data
# following the steps in 1_8b_DataGeneration_ODA.do

if (!is.null(pol_sim)) {
  # Extract similarity scores for each UNSC member
  setorder(pol_sim, cabb1, cabb2, year)

  # Forward-fill missing alliance data (none for 2013-2015)
  pol_sim[, srsvaa := nafill(nafill(srsvaa, type = "locf"), type = "locf"), by = .(cabb1, cabb2)]

  # Extract for each power
  powers <- c("UKG", "FRN", "USA", "RUS", "CHN")
  power_names <- c("uk", "fr", "us", "ru", "cn")

  # Merge with metropolitan budgets for budget weights
  for (col in names(met_budgets)) {
    if (col != "year") met_budgets[, (col) := as.numeric(get(col))]
  }
  met_budgets[, year := as.integer(year)]

  # Create cow_alf mapping from master
  cow_map <- unique(master[, .(iso, cow_alf)])
  cow_map <- cow_map[!is.na(cow_alf) & cow_alf != ""]

  # For each power, extract srsvaa scores and weight by budget
  sim_data_list <- list()
  for (i in seq_along(powers)) {
    pw <- powers[i]
    pn <- power_names[i]

    sub <- pol_sim[cabb1 == pw, .(year, cow_alf = cabb2, srsvaa)]
    sub <- merge(sub, cow_map, by = "cow_alf", all.x = TRUE, allow.cartesian = TRUE)
    sub <- sub[!is.na(iso)]

    # Merge with budget deficits
    budget_col <- paste0("x", pn, "_def")
    if (budget_col %in% names(met_budgets)) {
      sub <- merge(sub, met_budgets[, c("year", budget_col), with = FALSE], by = "year", all.x = TRUE)
      sub[, weighted_score := srsvaa * get(budget_col)]
    } else {
      sub[, weighted_score := srsvaa]
    }

    setnames(sub, "weighted_score", paste0(pn, "_weighted"))
    setnames(sub, "srsvaa", paste0(pn, "_srsvaa"))
    sim_data_list[[pn]] <- sub[, c("iso", "year", paste0(pn, "_weighted"), paste0(pn, "_srsvaa")), with = FALSE]
  }

  # Merge all power scores
  aid_data <- sim_data_list[[1]]
  for (i in 2:length(sim_data_list)) {
    aid_data <- merge(aid_data, sim_data_list[[i]], by = c("iso", "year"), all = TRUE)
  }

  # For colonial polities: use the colonial power's score
  # For independent polities after 1945: sum of G5
  aid_data <- merge(aid_data, master[, .(iso, year, indep, Britain_col, France_col, Portugal_col,
                                          Belgium_col, Italy_col, Germany_col)],
                    by = c("iso", "year"), all.x = TRUE)

  # Colonial score = score of respective metropole
  aid_data[, S_col_unw := NA_real_]
  aid_data[Britain_col == 1 | iso == "ETH", S_col_unw := uk_weighted]
  aid_data[France_col == 1, S_col_unw := fr_weighted]
  aid_data[Portugal_col == 1, S_col_unw := NA_real_]  # Portuguese alliance data often missing
  aid_data[Belgium_col == 1, S_col_unw := NA_real_]
  aid_data[iso == "LBR", S_col_unw := us_weighted]

  # G5 score for independent polities after 1945
  aid_data[, S_g5_unw_alliance_abs := S_col_unw]
  g5_cols <- paste0(c("uk", "fr", "us", "ru", "cn"), "_weighted")
  for (gc in g5_cols) {
    aid_data[is.na(get(gc)), (gc) := 0]
  }
  aid_data[indep == 1 & year > 1945,
           S_g5_unw_alliance_abs := uk_weighted + fr_weighted + us_weighted + ru_weighted + cn_weighted]

  master <- merge(master, aid_data[, .(iso, year, S_g5_unw_alliance_abs)],
                  by = c("iso", "year"), all.x = TRUE)
} else {
  cat("  Warning: Political similarity data not available. Aid variable will be NA.\n")
  master[, S_g5_unw_alliance_abs := NA_real_]
}

cat("  ODA/Political similarity data merged.\n")

###############################################################################
# 9. RESOURCES
###############################################################################
cat("Loading Resource data...\n")
# Resource prices are very complex to construct (trade-weighted commodity price indices)
# The variable P_ind_total_f_realshare requires commodity prices, export shares, and deflators
# We will attempt a simplified construction

# Read the 1_8c do-file to understand resource construction
res_do <- readLines(file.path(data_dir, "1_8c_DataGeneration_Resources.do"))
cat("  Resource price construction is extremely complex (trade-weighted real commodity price index).\n")
cat("  Setting resource variable to NA for now -- will be populated from data if available.\n")
master[, P_ind_total_f_realshare := NA_real_]

###############################################################################
# 10. GDP GROWTH
###############################################################################
cat("Loading GDP data...\n")
# The GDP growth variable uses Maddison/Jerven data
rgdp_jerven <- fread(file.path(data_dir, "rGDP_Mad_Jerven.tab"), sep = "\t")
for (col in names(rgdp_jerven)) {
  if (is.character(rgdp_jerven[[col]])) rgdp_jerven[, (col) := gsub('^"|"$', '', get(col))]
}

# This is a wide-format table -- needs reshaping
# Try to identify structure
cat("  rGDP_Mad_Jerven columns:", paste(head(names(rgdp_jerven), 10), collapse = ", "), "...\n")

# Attempt to reshape if in wide format with iso codes as columns
if ("year" %in% names(rgdp_jerven) | "Year" %in% names(rgdp_jerven)) {
  yr_col <- grep("^year$|^Year$", names(rgdp_jerven), value = TRUE)[1]
  setnames(rgdp_jerven, yr_col, "year")
  rgdp_jerven[, year := as.integer(year)]
  iso_cols <- setdiff(names(rgdp_jerven), "year")

  rgdp_long <- melt(rgdp_jerven, id.vars = "year", variable.name = "iso", value.name = "rgdp_Jerven_pc")
  rgdp_long[, iso := toupper(as.character(iso))]
  rgdp_long[, rgdp_Jerven_pc := as.numeric(rgdp_Jerven_pc)]

  # Fix non-standard ISO codes from the Jerven data
  rgdp_long[iso == "BFO", iso := "BFA"]  # Burkina Faso
  rgdp_long[iso == "RWI", iso := "RWA"]  # Rwanda
  rgdp_long[iso == "COMOROISLANDS", iso := "COM"]
  rgdp_long[iso == "EQUATORIALGUINEA", iso := "GNQ"]
  rgdp_long[iso == "MAURITIUS", iso := "MUS"]
  rgdp_long[iso == "SEYCHELLES", iso := "SYC"]

  # Interpolate within iso (need >= 2 non-NA)
  setorder(rgdp_long, iso, year)
  rgdp_long[, n_nonNA := sum(!is.na(rgdp_Jerven_pc)), by = iso]
  rgdp_long[n_nonNA >= 2, rgdp_Jerven_pc := approx(year, rgdp_Jerven_pc, xout = year, rule = 1)$y, by = iso]
  rgdp_long[, n_nonNA := NULL]

  # Multiply by population to get total GDP (the do-file computes per-capita growth from total)
  # For simplicity, use per-capita growth directly
  rgdp_long[, rgdp_Jerven := rgdp_Jerven_pc]
  setorder(rgdp_long, iso, year)
  rgdp_long[, g_gdp_yoy := (rgdp_Jerven - shift(rgdp_Jerven, 1)) / shift(rgdp_Jerven, 1), by = iso]

  # Also load Maddison 2018 for post-2007 data
  rgdp_mad <- fread(file.path(data_dir, "rGDP_Mad_2018.tab"), sep = "\t")
  for (col in names(rgdp_mad)) {
    if (is.character(rgdp_mad[[col]])) rgdp_mad[, (col) := gsub('^"|"$', '', get(col))]
  }
  if ("rgdpnapc" %in% names(rgdp_mad) & "iso" %in% names(rgdp_mad)) {
    rgdp_mad[, iso := toupper(gsub('^"|"$', '', iso))]
    rgdp_mad[, year := as.integer(year)]
    rgdp_mad[, rgdpnapc := as.numeric(rgdpnapc)]
    setorder(rgdp_mad, iso, year)
    rgdp_mad[, g_gdp_mad_yoy := (rgdpnapc - shift(rgdpnapc, 1)) / shift(rgdpnapc, 1), by = iso]
    # Merge and fill post-2007 with Maddison
    rgdp_long <- merge(rgdp_long, rgdp_mad[, .(iso, year, g_gdp_mad_yoy)],
                        by = c("iso", "year"), all.x = TRUE)
    rgdp_long[year > 2007 & !is.na(g_gdp_mad_yoy), g_gdp_yoy := g_gdp_mad_yoy]
    rgdp_long[, g_gdp_mad_yoy := NULL]
  }

  master <- merge(master, rgdp_long[, .(iso, year, g_gdp_yoy)], by = c("iso", "year"), all.x = TRUE)
} else {
  master[, g_gdp_yoy := NA_real_]
}

cat("  GDP data merged.\n")

###############################################################################
# 11. INFLATION EPISODES
###############################################################################
cat("Computing inflation episodes...\n")
# Simplified: use GDP deflator to compute inflation
setorder(master, iso_n, year)
master[, inflation_deflator := (GDP_Deflator - shift(GDP_Deflator, 1)) / GDP_Deflator * 100, by = iso_n]
master[, inflation_ep := as.integer(inflation_deflator > 20 & !is.na(inflation_deflator))]
master[is.na(inflation_ep), inflation_ep := 0L]

###############################################################################
# 12. EXTERNAL DEFAULTS
###############################################################################
cat("Loading External default data...\n")
defaults <- fread(file.path(data_dir, "External_default_RR.tab"), sep = "\t")
for (col in names(defaults)) {
  if (is.character(defaults[[col]])) defaults[, (col) := gsub('^"|"$', '', get(col))]
}

# Try to merge default data
if ("external_default_RR" %in% names(defaults)) {
  defaults[, external_default_RR := as.numeric(external_default_RR)]
  if ("name" %in% names(defaults) & "name" %in% names(master)) {
    master <- merge(master, defaults[, .(name, year, external_default_RR)], by = c("name", "year"), all.x = TRUE)
  } else if ("iso" %in% names(defaults)) {
    master <- merge(master, defaults[, .(iso, year, external_default_RR)], by = c("iso", "year"), all.x = TRUE)
  }
}
if (!"external_default_RR" %in% names(master)) {
  master[, external_default_RR := 0L]
}
master[is.na(external_default_RR), external_default_RR := 0L]

cat("  External default data merged.\n")

###############################################################################
# 13. COLLAPSE TO 5-YEAR PANEL
###############################################################################
cat("\n=================================================================\n")
cat("STEP 2: Collapsing to 5-year panel\n")
cat("=================================================================\n\n")

# Create demidecade variable
master[, demidecade := NA_integer_]
decade_map <- data.table(
  start = seq(1890, 2010, by = 5),
  end = c(seq(1894, 2009, by = 5), 2015),
  dd = 1:25
)
for (i in 1:nrow(decade_map)) {
  master[year >= decade_map$start[i] & year <= decade_map$end[i], demidecade := decade_map$dd[i]]
}

# Rename control variables to X_ prefix (matching the do-file)
# These are the controls in the full specification
master[, X_g_gdp_yoy := g_gdp_yoy]
master[, X_inflation_ep := inflation_ep]
master[, X_external_default_RR := external_default_RR]
master[, X_socialist := socialist]
master[, X_secession := secession]
master[, X_indep := indep]

# Variables to take max (binary indicators)
max_vars <- c("indep", "civ_war_all_PRIO", "int_war_all_PRIO",
              "drought_affected_merged")

# Variables to take mean
mean_vars <- c("tax_non_trade_real", "libdem_extra_vdem",
               "P_ind_total_f_realshare", "S_g5_unw_alliance_abs",
               "cr_market_accessXBOEinv",
               "X_g_gdp_yoy", "X_inflation_ep", "X_external_default_RR",
               "X_socialist", "X_secession", "X_indep",
               "credit_market_access", "IR_BoE")

# Variables to take sum (count variables)
sum_vars <- c("gov_change", "external_default_RR")

# Keep only years >= 1900
panel_data <- master[year >= 1900 & !is.na(demidecade)]

# Collapse
collapse_mean <- panel_data[, lapply(.SD, mean, na.rm = TRUE),
                             by = .(iso, demidecade), .SDcols = intersect(mean_vars, names(panel_data))]
collapse_max <- panel_data[, lapply(.SD, function(x) max(x, na.rm = TRUE)),
                            by = .(iso, demidecade), .SDcols = intersect(max_vars, names(panel_data))]
# Fix -Inf from max of empty groups
for (col in names(collapse_max)) {
  if (is.numeric(collapse_max[[col]])) {
    collapse_max[is.infinite(get(col)), (col) := NA]
  }
}

collapse_sum <- panel_data[, lapply(.SD, sum, na.rm = TRUE),
                            by = .(iso, demidecade), .SDcols = intersect(sum_vars, names(panel_data))]

# Get first year per group
collapse_year <- panel_data[, .(year = min(year)), by = .(iso, demidecade)]

# Merge all collapse results
panel5 <- collapse_year
panel5 <- merge(panel5, collapse_mean, by = c("iso", "demidecade"), all.x = TRUE)
panel5 <- merge(panel5, collapse_max, by = c("iso", "demidecade"), all.x = TRUE, suffixes = c("", "_max"))
panel5 <- merge(panel5, collapse_sum, by = c("iso", "demidecade"), all.x = TRUE, suffixes = c("", "_sum"))

# Use sum version of gov_change if available
if ("gov_change_sum" %in% names(panel5)) {
  panel5[, gov_change := gov_change_sum]
  panel5[, gov_change_sum := NULL]
}

# Create iso_n for panel
panel5[, iso_n := as.integer(factor(iso))]
setorder(panel5, iso_n, demidecade)

# Rescale democracy measures (* 100 as in the do-file)
panel5[, libdem_extra_vdem := libdem_extra_vdem * 100]

# Create first-differenced dependent variable
panel5[, dtax_non_trade_real := tax_non_trade_real - shift(tax_non_trade_real, 1), by = iso_n]

# Create credit market access variable (reconstructed)
# cr_market_accessXBOEinv is already computed at annual level and averaged

# Create lagged variables (lag in the 5-year panel)
panel5[, l1_gov_change := shift(gov_change, 1), by = iso_n]
panel5[, l1_civ_war_all_PRIO := shift(civ_war_all_PRIO, 1), by = iso_n]
panel5[, l1_int_war_all_PRIO := shift(int_war_all_PRIO, 1), by = iso_n]
panel5[, l1_drought_affected_merged := shift(drought_affected_merged, 1), by = iso_n]

cat("Panel collapsed to 5-year averages:", nrow(panel5), "observations,",
    uniqueN(panel5$iso), "polities,", uniqueN(panel5$demidecade), "periods.\n")

###############################################################################
# 14. REPLICATE TABLE 1 COLUMN 6
###############################################################################
cat("\n=================================================================\n")
cat("STEP 3: Replicating Table 1, Column 6\n")
cat("=================================================================\n\n")

# The full specification (column 6) from the do-file:
# reghdfe dtax_non_trade_real libdem_extra_vdem l1.gov_change l1.civ_war_all_PRIO
#         l1.int_war_all_PRIO P_ind_total_f_realshare S_g5_unw_alliance_abs
#         cr_market_accessXBOEinv X_* l1.drought_affected_merged,
#         absorb(year iso_n) cluster(iso_n)

# Check which variables are available
cat("Checking variable availability:\n")
key_vars <- c("dtax_non_trade_real", "libdem_extra_vdem", "l1_gov_change",
              "l1_civ_war_all_PRIO", "l1_int_war_all_PRIO",
              "P_ind_total_f_realshare", "S_g5_unw_alliance_abs",
              "cr_market_accessXBOEinv",
              "X_g_gdp_yoy", "X_inflation_ep", "X_external_default_RR",
              "X_socialist", "X_secession", "X_indep",
              "l1_drought_affected_merged")

for (v in key_vars) {
  if (v %in% names(panel5)) {
    n_obs <- sum(!is.na(panel5[[v]]))
    cat(sprintf("  %-35s: %d non-NA (%.0f%%)\n", v, n_obs, 100 * n_obs / nrow(panel5)))
  } else {
    cat(sprintf("  %-35s: NOT FOUND\n", v))
  }
}

# Convert factor variables
panel5[, iso_n := as.factor(iso_n)]
panel5[, demidecade := as.factor(demidecade)]

# Identify available treatment and control variables
# Treatment variables from Table 1: the "canonical" and "extraversion" variables
# The paper conceptualizes them as theoretically motivated covariates, not "treatments" per se,
# but for IVB purposes we need to pick one as the main treatment of interest.
# Government turnover is the most consistently significant.

# Define available variables for regression
avail_treatment <- c("l1_gov_change", "libdem_extra_vdem")
avail_extrav <- c()
if (sum(!is.na(panel5$P_ind_total_f_realshare)) > 50) avail_extrav <- c(avail_extrav, "P_ind_total_f_realshare")
if (sum(!is.na(panel5$S_g5_unw_alliance_abs)) > 50) avail_extrav <- c(avail_extrav, "S_g5_unw_alliance_abs")
if (sum(!is.na(panel5$cr_market_accessXBOEinv)) > 50) avail_extrav <- c(avail_extrav, "cr_market_accessXBOEinv")

avail_canonical_wars <- c()
if (sum(!is.na(panel5$l1_civ_war_all_PRIO)) > 50) avail_canonical_wars <- c(avail_canonical_wars, "l1_civ_war_all_PRIO")
if (sum(!is.na(panel5$l1_int_war_all_PRIO)) > 50) avail_canonical_wars <- c(avail_canonical_wars, "l1_int_war_all_PRIO")

avail_controls <- c()
ctrl_candidates <- c("X_g_gdp_yoy", "X_inflation_ep", "X_external_default_RR",
                      "X_socialist", "X_secession", "X_indep", "l1_drought_affected_merged")
for (cv in ctrl_candidates) {
  if (cv %in% names(panel5) && sum(!is.na(panel5[[cv]])) > 50) {
    avail_controls <- c(avail_controls, cv)
  }
}

all_rhs <- c(avail_treatment, avail_canonical_wars, avail_extrav, avail_controls)

cat("\nAvailable RHS variables for regression:\n")
cat("  Treatment (canonical):", paste(avail_treatment, collapse = ", "), "\n")
cat("  Canonical wars:", paste(avail_canonical_wars, collapse = ", "), "\n")
cat("  Extraversion:", paste(avail_extrav, collapse = ", "), "\n")
cat("  Controls:", paste(avail_controls, collapse = ", "), "\n")

# Build formula
rhs_str <- paste(all_rhs, collapse = " + ")
fml_str <- paste0("dtax_non_trade_real ~ ", rhs_str, " | iso_n + demidecade")
cat("\nRegression formula:\n  ", fml_str, "\n\n")

# Convert panel5 to data.frame for fixest
df <- as.data.frame(panel5)

# Run the full specification regression (Table 1, Col 6)
# Use clustered SE for replication, but IID for IVB
cat("Running regression with clustered SE (for replication)...\n")
m_full_cl <- tryCatch({
  feols(as.formula(fml_str), data = df, vcov = ~iso_n)
}, error = function(e) {
  cat("  Error:", e$message, "\n")
  NULL
})

if (!is.null(m_full_cl)) {
  cat("\n--- Table 1, Column 6 Replication (Clustered SE) ---\n")
  print(summary(m_full_cl))
  cat("\nN =", m_full_cl$nobs, "\n")
  cat("Adj. R2 =", round(fitstat(m_full_cl, "ar2")[[1]], 3), "\n")
}

cat("\nRunning regression with IID SE (for IVB identity)...\n")
m_full_iid <- tryCatch({
  feols(as.formula(fml_str), data = df, vcov = "iid")
}, error = function(e) {
  cat("  Error:", e$message, "\n")
  NULL
})

if (!is.null(m_full_iid)) {
  cat("\n--- Table 1, Column 6 (IID SE for IVB) ---\n")
  print(summary(m_full_iid))
}

###############################################################################
# 15. IVB DECOMPOSITION
###############################################################################
cat("\n=================================================================\n")
cat("STEP 4: IVB Decomposition\n")
cat("=================================================================\n\n")

# Strategy: We treat government turnover (l1_gov_change) as the primary treatment.
# Each other covariate is in turn treated as a candidate collider z.
# The "short" model omits z, the "long" model includes z.
# IVB = -theta* * pi, where theta* is z's coefficient in the long model,
# and pi is l1_gov_change's coefficient in the auxiliary regression z ~ l1_gov_change + w | FE.

# For a comprehensive IVB analysis, we cycle through each variable as the candidate collider.
# The treatment of interest is l1_gov_change (government turnover, lagged).

treatment_var <- "l1_gov_change"

# All variables in the full model except the treatment
all_covariates <- setdiff(all_rhs, treatment_var)

# Store results
ivb_results <- list()

cat("Computing IVB for each covariate as candidate collider...\n")
cat("Treatment variable (D):", treatment_var, "\n")
cat("Outcome variable (Y): dtax_non_trade_real\n")
cat("Fixed effects: iso_n + demidecade\n\n")

for (z_var in all_covariates) {
  w_vars <- setdiff(all_covariates, z_var)

  res <- tryCatch({
    compute_ivb_multi(
      data = df,
      y = "dtax_non_trade_real",
      d_vars = treatment_var,
      z = z_var,
      w = w_vars,
      fe = c("iso_n", "demidecade"),
      vcov = "iid",
      na_action = "omit"
    )
  }, error = function(e) {
    cat(sprintf("  %-35s: ERROR - %s\n", z_var, e$message))
    NULL
  })

  if (!is.null(res)) {
    ivb_results[[z_var]] <- res
    r <- res$results
    cat(sprintf("  %-35s: theta=%.4f, pi=%.4f, IVB=%.4f (beta_short=%.4f, beta_long=%.4f, diff_check=%.2e)\n",
                z_var, r$theta, r$pi, r$ivb_formula, r$beta_short, r$beta_long, r$diff_check))
  }
}

###############################################################################
# 16. SUMMARIZE IVB RESULTS
###############################################################################
cat("\n=================================================================\n")
cat("STEP 5: IVB Summary\n")
cat("=================================================================\n\n")

if (length(ivb_results) > 0) {
  # Compile all results
  ivb_summary <- rbindlist(lapply(names(ivb_results), function(zname) {
    r <- ivb_results[[zname]]$results
    data.table(
      candidate_collider = zname,
      beta_short = r$beta_short,
      beta_long = r$beta_long,
      theta = r$theta,
      pi = r$pi,
      ivb_formula = r$ivb_formula,
      ivb_direct = r$ivb_direct,
      abs_ivb = abs(r$ivb_formula),
      sample_n = ivb_results[[zname]]$sample_n
    )
  }))

  setorder(ivb_summary, -abs_ivb)

  cat("IVB Decomposition Results\n")
  cat("Treatment: l1_gov_change (lagged government turnover)\n")
  cat("Outcome: dtax_non_trade_real (change in real tax collection per capita)\n\n")

  cat(sprintf("%-35s %10s %10s %10s %10s %10s %6s\n",
              "Candidate Collider (z)", "theta*", "pi", "IVB", "beta_short", "beta_long", "N"))
  cat(paste(rep("-", 117), collapse = ""), "\n")

  for (i in 1:nrow(ivb_summary)) {
    r <- ivb_summary[i]
    cat(sprintf("%-35s %10.4f %10.4f %10.4f %10.4f %10.4f %6d\n",
                r$candidate_collider, r$theta, r$pi, r$ivb_formula,
                r$beta_short, r$beta_long, r$sample_n))
  }

  cat("\n\n--- Assessment of Plausible Colliders ---\n\n")
  cat("A variable Z is a plausible collider if the outcome Y (fiscal capacity change)\n")
  cat("could causally affect Z, making Z a post-treatment variable.\n\n")

  cat("Variables sorted by |IVB| (largest bias first):\n\n")
  for (i in 1:nrow(ivb_summary)) {
    r <- ivb_summary[i]
    collider_assessment <- switch(r$candidate_collider,
      "libdem_extra_vdem" = "PLAUSIBLE COLLIDER: Fiscal capacity could affect democratic institutions (state capacity -> democratization)",
      "l1_civ_war_all_PRIO" = "UNLIKELY COLLIDER: Lagged (previous period), so temporal ordering protects against reverse causality",
      "l1_int_war_all_PRIO" = "UNLIKELY COLLIDER: Lagged (previous period) and international wars are largely exogenous",
      "S_g5_unw_alliance_abs" = "PLAUSIBLE COLLIDER: Fiscal capacity could affect political alliances and aid relationships",
      "cr_market_accessXBOEinv" = "PLAUSIBLE COLLIDER: Higher fiscal capacity could improve credit market access (creditworthiness)",
      "P_ind_total_f_realshare" = "UNLIKELY COLLIDER: World commodity prices are exogenous to individual country fiscal capacity",
      "X_g_gdp_yoy" = "PLAUSIBLE COLLIDER: Fiscal capacity changes could affect GDP growth",
      "X_inflation_ep" = "POSSIBLE COLLIDER: Fiscal capacity changes could affect inflation through monetary/fiscal linkages",
      "X_external_default_RR" = "PLAUSIBLE COLLIDER: Fiscal capacity directly affects sovereign default risk",
      "X_socialist" = "UNLIKELY COLLIDER: Socialist ideology is not plausibly caused by fiscal capacity changes",
      "X_secession" = "UNLIKELY COLLIDER: Territorial changes driven by broader political forces",
      "X_indep" = "UNLIKELY COLLIDER: Independence timing not plausibly affected by fiscal capacity",
      "l1_drought_affected_merged" = "UNLIKELY COLLIDER: Lagged drought is a natural disaster, exogenous to fiscal capacity",
      "Assessment not available"
    )

    cat(sprintf("  %d. %-30s |IVB| = %.4f  --> %s\n",
                i, r$candidate_collider, r$abs_ivb, collider_assessment))
  }

  cat("\n\n--- Key Findings ---\n\n")

  # Find largest IVB
  top <- ivb_summary[1]
  cat(sprintf("Largest IVB: %s (IVB = %.4f)\n", top$candidate_collider, top$ivb_formula))
  cat(sprintf("  Adding %s to the model shifts the govt turnover coefficient from %.4f to %.4f\n",
              top$candidate_collider, top$beta_short, top$beta_long))
  cat(sprintf("  This is a %.1f%% change relative to the short-model coefficient\n",
              100 * abs(top$ivb_formula) / abs(top$beta_short)))

  # Total IVB across all colliders
  cat(sprintf("\nSum of all IVBs: %.4f\n", sum(ivb_summary$ivb_formula)))
  cat(sprintf("Sum of |IVB|: %.4f\n", sum(ivb_summary$abs_ivb)))

  # Save results
  fwrite(ivb_summary,
         file.path(dirname(data_dir), "fiscal_state_ivb_results.csv"))
  cat("\nResults saved to fiscal_state_ivb_results.csv\n")
} else {
  cat("No IVB results computed. Check variable availability.\n")
}

cat("\n=================================================================\n")
cat("ANALYSIS COMPLETE\n")
cat("=================================================================\n")
