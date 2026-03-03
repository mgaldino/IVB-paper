library(haven)
library(dplyr)

df <- read_dta("/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/replication/candidate_papers/burnside_dollar_2000/NDND.dta")

# Generate needed variables
df$bdlgdp <- log(df$bdgdp)
df$bdpolicy <- df$bddatap
df$bdoutlier <- df$bddatao
df$bdaidpolicy <- df$bdaid * df$bdpolicy
df$bdethnfassas <- df$bdethnf * df$bdassas

# Check time variation for ICRGE more carefully
cat("=== CHECKING bdicrge TIME VARIATION ===\n")
# Show some countries' ICRGE values over time
sample_countries <- c("ARG", "BRA", "IND", "KEN", "THA", "GHA")
for (cc in sample_countries) {
  sub <- df[df$country == cc, c("country", "period", "periodstart", "bdicrge")]
  sub <- sub[order(sub$period), ]
  cat(cc, ": ")
  vals <- sub$bdicrge
  cat(paste(round(vals, 2), collapse=", "), "\n")
}

cat("\n=== Per-country variation in ICRGE ===\n")
icrg_var <- df %>%
  filter(is.finite(bdicrge)) %>%
  group_by(country) %>%
  summarize(
    n = n(),
    mean_icrge = mean(bdicrge, na.rm=TRUE),
    sd_icrge = sd(bdicrge, na.rm=TRUE),
    min_icrge = min(bdicrge, na.rm=TRUE),
    max_icrge = max(bdicrge, na.rm=TRUE)
  ) %>%
  filter(n > 1)

cat("Countries with >1 ICRGE observation:", nrow(icrg_var), "\n")
cat("Countries where ICRGE varies (sd>0):", sum(icrg_var$sd_icrge > 0.001, na.rm=TRUE), "\n")
cat("Countries where ICRGE is constant (sd~0):", sum(icrg_var$sd_icrge <= 0.001, na.rm=TRUE), "\n\n")

# Show those with variation
varying <- icrg_var %>% filter(sd_icrge > 0.001)
cat("Countries with ICRGE variation:\n")
print(as.data.frame(varying))

# Now check which periods have ICRGE data
cat("\n=== ICRGE coverage by period ===\n")
for (p in sort(unique(df$period))) {
  n_obs <- sum(is.finite(df$bdicrge[df$period == p]))
  pstart <- unique(df$periodstart[df$period == p])
  cat(sprintf("Period %d (%d): %d obs with ICRGE\n", p, pstart, n_obs))
}

# Check if ICRGE is really just one cross-sectional value
cat("\n=== ICRGE data availability pattern ===\n")
icrge_check <- df %>%
  filter(is.finite(bdicrge)) %>%
  group_by(country) %>%
  summarize(
    n_periods = n(),
    periods = paste(period, collapse=","),
    unique_vals = length(unique(round(bdicrge, 4)))
  )
cat("Distribution of unique ICRGE values per country:\n")
print(table(icrge_check$unique_vals))
cat("\nDistribution of number of periods with ICRGE:\n")
print(table(icrge_check$n_periods))

# ICRGE appears to be time-invariant in BD data (same value across periods)
# This is because BD used a single cross-section of ICRG data

cat("\n\n=== CHECKING bdm21 (M2/GDP) TIME VARIATION ===\n")
m21_var <- df %>%
  filter(is.finite(bdm21)) %>%
  group_by(country) %>%
  summarize(
    n = n(),
    mean_m21 = mean(bdm21, na.rm=TRUE),
    sd_m21 = sd(bdm21, na.rm=TRUE)
  ) %>%
  filter(n > 1)

cat("Countries with >1 M2/GDP observation:", nrow(m21_var), "\n")
cat("Countries where M2/GDP varies (sd>0):", sum(m21_var$sd_m21 > 0.001, na.rm=TRUE), "\n")
cat("Mean within-country SD of M2/GDP:", mean(m21_var$sd_m21, na.rm=TRUE), "\n")

cat("\n=== CHECKING bdassas (assassinations) TIME VARIATION ===\n")
assas_var <- df %>%
  filter(is.finite(bdassas)) %>%
  group_by(country) %>%
  summarize(
    n = n(),
    mean_assas = mean(bdassas, na.rm=TRUE),
    sd_assas = sd(bdassas, na.rm=TRUE)
  ) %>%
  filter(n > 1)

cat("Countries with >1 assassinations observation:", nrow(assas_var), "\n")
cat("Countries where assassinations varies (sd>0):", sum(assas_var$sd_assas > 0.001, na.rm=TRUE), "\n")

# Check ELR versions for time-varying ICRGE
cat("\n=== CHECKING ELR versions of key variables ===\n")
cat("elricrge variation:\n")
elr_icrg <- df %>%
  filter(is.finite(elricrge)) %>%
  group_by(country) %>%
  summarize(
    n = n(),
    sd_icrge = sd(elricrge, na.rm=TRUE),
    unique_vals = length(unique(round(elricrge, 4)))
  ) %>%
  filter(n > 1)
cat("Countries with >1 obs:", nrow(elr_icrg), "\n")
cat("Distribution of unique ELR ICRGE values:\n")
print(table(elr_icrg$unique_vals))
