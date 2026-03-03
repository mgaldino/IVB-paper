library(haven)
df <- read_dta("/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/replication/candidate_papers/burnside_dollar_2000/NDND.dta")

cat("=== VARIABLE LABELS ===\n")
for (v in names(df)) {
  lbl <- attr(df[[v]], "label")
  if (is.null(lbl)) lbl <- "(no label)"
  cat(v, ":", lbl, "\n")
}

cat("\n=== SUMMARY STATS FOR KEY BD VARIABLES ===\n")
bd_vars <- c("bdgdpg", "bdaid", "bddatap", "bdlpop", "bdgdp", "bdbb", "bdinfl", "bdsacw",
             "bdethnf", "bdassas", "bdicrge", "bdm21", "bdssa", "bdeasia", "bddn1900")
for (v in bd_vars) {
  if (v %in% names(df)) {
    x <- df[[v]]
    cat(sprintf("%s: n=%d, mean=%.3f, sd=%.3f, min=%.3f, max=%.3f\n",
        v, sum(is.finite(x)), mean(x, na.rm=TRUE), sd(x, na.rm=TRUE),
        min(x, na.rm=TRUE), max(x, na.rm=TRUE)))
  }
}

cat("\n=== UNIQUE PERIODS ===\n")
print(sort(unique(paste0(df$periodstart, "-", df$periodend))))
cat("\n=== PANEL STRUCTURE ===\n")
cat("Number of unique countries:", length(unique(df$country)), "\n")
cat("Number of observations:", nrow(df), "\n")

# Check which observations have non-missing BD data
bd_complete <- complete.cases(df[, c("bdgdpg", "bdaid", "bddatap", "bdlpop", "bdgdp",
                                      "bdethnf", "bdassas", "bdicrge", "bdm21")])
cat("Observations with complete BD data:", sum(bd_complete), "\n")

# Try to replicate regression 5/OLS (B&D original, excluding outliers)
# From the do-file: regress bdgdpg bdaid bdaidpolicy bdlgdp bdethnf bdassas bdethnfassas bdssa bdeasia bdicrge bdm21 bdpolicy _Iperiod* if sample & !bdoutlier, robust
cat("\n=== REPLICATING BD TABLE 4, COLUMN 5 OLS ===\n")
df$bdlgdp <- log(df$bdgdp)
df$bdpolicy <- df$bddatap
df$bdoutlier <- df$bddatao
df$bdaidpolicy <- df$bdaid * df$bdpolicy
df$bdethnfassas <- df$bdethnf * df$bdassas

# Sample: exclude BHS and SGP (from regression 1 sample creation)
sample_mask <- (df$country != "BHS") & (df$country != "SGP")
# Create the sample from regression 1 first
reg1_vars <- c("bdgdpg", "bdlgdp", "bdethnf", "bdassas", "bdethnfassas", "bdssa",
               "bdeasia", "bdicrge", "bdm21", "bdbb", "bdinfl", "bdsacw")
sample_complete <- complete.cases(df[, reg1_vars]) & sample_mask
df$sample <- sample_complete

# Create period dummies
df$period <- as.factor(df$period)

cat("Sample size (Reg 1 sample):", sum(df$sample), "\n")
cat("Sample size (Reg 5, excl outliers):", sum(df$sample & (df$bdoutlier == 0), na.rm=TRUE), "\n")

# Run regression 5/OLS (outliers excluded)
reg5_data <- df[df$sample & (df$bdoutlier == 0) & is.finite(df$bdoutlier), ]
cat("Reg 5 OLS sample size:", nrow(reg5_data), "\n")

reg5 <- lm(bdgdpg ~ bdaid + bdaidpolicy + bdlgdp + bdethnf + bdassas + bdethnfassas +
            bdssa + bdeasia + bdicrge + bdm21 + bdpolicy + period, data = reg5_data)
cat("\nRegression 5/OLS results:\n")
print(summary(reg5))

# Run regression 5/OLS+ (with outliers)
reg5plus_data <- df[df$sample, ]
reg5plus_data <- reg5plus_data[complete.cases(reg5plus_data[, c("bdgdpg", "bdaid", "bdaidpolicy",
  "bdlgdp", "bdethnf", "bdassas", "bdethnfassas", "bdssa", "bdeasia", "bdicrge", "bdm21", "bdpolicy")]), ]
cat("\n\nRegression 5/OLS+ (with outliers) sample size:", nrow(reg5plus_data), "\n")
reg5plus <- lm(bdgdpg ~ bdaid + bdaidpolicy + bdlgdp + bdethnf + bdassas + bdethnfassas +
            bdssa + bdeasia + bdicrge + bdm21 + bdpolicy + period, data = reg5plus_data)
cat("\nRegression 5/OLS+ results:\n")
print(summary(reg5plus))

# Also run the simpler specification without interaction - just aid and policy separately
# This helps understand the main effect
cat("\n=== VARIABLE TYPES ASSESSMENT ===\n")
cat("bdgdpg (Y): GDP growth - CONTINUOUS\n")
cat("bdaid (D): Aid/GDP ratio - CONTINUOUS\n")
cat("bdpolicy/bddatap (policy index): weighted combo of bb, infl, sacw - CONTINUOUS\n")
cat("bdaidpolicy (interaction): aid * policy - CONTINUOUS\n")
cat("bdlgdp: log initial GDP - CONTINUOUS\n")
cat("bdethnf: ethnic fractionalization - CONTINUOUS\n")
cat("bdassas: assassinations - CONTINUOUS (count-like)\n")
cat("bdethnfassas: ethnf * assassinations - CONTINUOUS\n")
cat("bdssa: Sub-Saharan Africa dummy - BINARY\n")
cat("bdeasia: East Asia dummy - BINARY\n")
cat("bdicrge: Institutional quality (ICRG) - CONTINUOUS\n")
cat("bdm21: M2/GDP lagged - CONTINUOUS (financial depth)\n")
cat("bdbb: Budget balance/GDP - CONTINUOUS\n")
cat("bdinfl: Inflation (log) - CONTINUOUS\n")
cat("bdsacw: Sachs-Warner openness - CONTINUOUS (fraction of years open)\n")
cat("period dummies: BINARY (time FE)\n")
