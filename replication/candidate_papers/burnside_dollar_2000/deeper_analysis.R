library(haven)
library(dplyr)

df <- read_dta("/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/replication/candidate_papers/burnside_dollar_2000/NDND.dta")

# Generate needed variables
df$bdlgdp <- log(df$bdgdp)
df$bdpolicy <- df$bddatap
df$bdoutlier <- df$bddatao
df$bdaidpolicy <- df$bdaid * df$bdpolicy
df$bdethnfassas <- df$bdethnf * df$bdassas

# Sample: from regression 1 (exclude BHS and SGP, complete cases on reg1 vars)
reg1_vars <- c("bdgdpg", "bdlgdp", "bdethnf", "bdassas", "bdethnfassas", "bdssa",
               "bdeasia", "bdicrge", "bdm21", "bdbb", "bdinfl", "bdsacw")
sample_mask <- (df$country != "BHS") & (df$country != "SGP")
sample_complete <- complete.cases(df[, reg1_vars]) & sample_mask
df$sample <- sample_complete

cat("=== STRUCTURE OF BURNSIDE & DOLLAR (2000) ===\n")
cat("Panel: 56 developing countries, 6 four-year periods (1970-73 to 1990-93)\n")
cat("Note: The Roodman data extends to 1994-97 and adds countries\n\n")

cat("=== REGRESSION 1 (POLICY-FORMING): ===\n")
cat("bdgdpg ~ bdlgdp + bdethnf + bdassas + bdethnf*bdassas + bdssa + bdeasia + bdicrge + bdm21 + bdbb + bdinfl + bdsacw + period_dummies\n")
cat("This regression estimates coefficients on bb, infl, sacw to construct the policy index.\n")
cat("The policy index is a WEIGHTED COMBINATION of budget balance, inflation, and trade openness.\n\n")

cat("=== REGRESSION 5/OLS (MAIN OLS SPEC WITH INTERACTION): ===\n")
cat("bdgdpg ~ bdaid + bdaid*bdpolicy + bdlgdp + bdethnf + bdassas + bdethnf*bdassas + bdssa + bdeasia + bdicrge + bdm21 + bdpolicy + period_dummies\n")
cat("KEY: The policy index REPLACES bb, infl, sacw as individual controls.\n")
cat("  Y = bdgdpg (GDP per capita growth)\n")
cat("  D = bdaid (aid/GDP ratio)\n")
cat("  Key interaction = bdaid * bdpolicy (aid effectiveness depends on policy)\n\n")

# Check variable variation
cat("=== VARIABLE VARIATION WITHIN-BETWEEN ===\n")
sample_df <- df[df$sample, ]
cat("Countries in sample:", length(unique(sample_df$country)), "\n")
cat("Periods in sample:", length(unique(sample_df$period)), "\n\n")

# Check which variables are time-varying vs time-invariant
for (v in c("bdgdpg", "bdaid", "bdpolicy", "bdlgdp", "bdethnf", "bdassas",
            "bdicrge", "bdm21", "bdssa", "bdeasia")) {
  if (v %in% names(sample_df)) {
    # Within-country SD
    within_sd <- sample_df %>%
      group_by(country) %>%
      summarize(sd_v = sd(get(v), na.rm=TRUE)) %>%
      pull(sd_v) %>%
      mean(na.rm=TRUE)
    total_sd <- sd(sample_df[[v]], na.rm=TRUE)
    cat(sprintf("%s: total_sd=%.3f, mean_within_sd=%.3f, ratio=%.2f\n",
        v, total_sd, within_sd, within_sd/total_sd))
  }
}

cat("\n=== KEY ISSUE: INTERACTION TERM ===\n")
cat("The main result in BD2000 is about the INTERACTION bdaid*bdpolicy.\n")
cat("This means the treatment effect is: dY/dAid = beta_aid + beta_interaction * policy\n")
cat("The claim is that beta_interaction > 0 (aid works in good policy environments).\n")
cat("This is fundamentally an interaction/moderation specification.\n\n")

cat("=== IDENTIFICATION STRATEGY ===\n")
cat("BD2000 uses TWO identification strategies:\n")
cat("1. OLS with controls (selection-on-observables): Tables 1-4 OLS columns\n")
cat("2. 2SLS/IV using geography/arms instruments: Tables 4-8 2SLS columns\n")
cat("For IVB, we want the OLS specifications.\n\n")

cat("=== TREATMENT VARIABLE CONSIDERATIONS ===\n")
cat("The treatment is 'aid' (ODA/GDP ratio).\n")
cat("But the MAIN COEFFICIENT OF INTEREST is on the interaction: aid*policy.\n")
cat("This is important: IVB on 'aid' alone may miss the key finding.\n")
cat("For IVB, we should consider BOTH:\n")
cat("  d_vars = c('bdaid', 'bdaidpolicy')  [both main effect and interaction]\n\n")

cat("=== COLLIDER CANDIDATES ASSESSMENT ===\n\n")

cat("1. POLICY INDEX (bdpolicy = budget surplus + inflation + openness):\n")
cat("   Aid -> Policy: Yes (conditionality, structural adjustment)\n")
cat("   Growth -> Policy: Yes (fiscal space, monetary stability, trade)\n")
cat("   Policy -> Growth: YES - this is the paper's central claim\n")
cat("   VERDICT: CONFOUNDER (not just collider) - Policy affects growth AND is affected by aid.\n")
cat("   But in the regression, policy enters as both a control AND via the interaction.\n")
cat("   The interaction aid*policy is PART OF the treatment specification.\n")
cat("   This makes policy DIFFERENT from a pure collider or confounder.\n\n")

cat("2. INSTITUTIONAL QUALITY (bdicrge - ICRG index):\n")
cat("   Aid -> ICRG: Possible (governance conditionality, institution building)\n")
cat("   Growth -> ICRG: Yes (richer countries have better institutions, or at least rated better)\n")
cat("   ICRG -> Growth: Yes (standard in growth literature)\n")
cat("   VERDICT: Could be BOTH confounder AND collider. Plausible IVB candidate.\n")
cat("   This is a continuous, time-varying variable.\n\n")

cat("3. FINANCIAL DEPTH (bdm21 - M2/GDP ratio):\n")
cat("   Aid -> M2/GDP: Possible (monetary expansion from aid inflows)\n")
cat("   Growth -> M2/GDP: Yes (financial deepening with growth)\n")
cat("   M2/GDP -> Growth: Debated (financial development channel)\n")
cat("   VERDICT: Plausible collider. Continuous, time-varying.\n\n")

cat("4. ETHNIC FRACTIONALIZATION (bdethnf):\n")
cat("   Time-invariant in BD data. Does not vary within country.\n")
cat("   Aid -> ethnf: NO (aid does not change ethnic composition)\n")
cat("   Growth -> ethnf: NO\n")
cat("   VERDICT: NOT a collider. Time-invariant confounder only.\n\n")

cat("5. ASSASSINATIONS (bdassas):\n")
cat("   Aid -> assassinations: Unlikely direct effect\n")
cat("   Growth -> assassinations: Possible (poor growth -> instability)\n")
cat("   assassinations -> Growth: Yes (instability reduces growth)\n")
cat("   VERDICT: Possible collider, but the Aid -> assassinations path is weak.\n")
cat("   Continuous, time-varying.\n\n")

cat("6. REGIONAL DUMMIES (bdssa, bdeasia):\n")
cat("   Time-invariant. Cannot be colliders.\n")
cat("   VERDICT: NOT colliders.\n\n")

cat("7. LOG INITIAL GDP (bdlgdp):\n")
cat("   This is INITIAL GDP (beginning of period), not contemporaneous.\n")
cat("   Previous aid -> current initial GDP: Yes (if aid raised growth last period)\n")
cat("   This is LAGGED, so less likely to be a collider for contemporaneous effects.\n")
cat("   VERDICT: Weak collider candidate. Standard convergence control.\n\n")

cat("=== BEST COLLIDER CANDIDATES FOR IVB ===\n")
cat("1. bdicrge (Institutional quality) - STRONGEST candidate\n")
cat("2. bdm21 (Financial depth M2/GDP) - GOOD candidate\n")
cat("3. bdpolicy (Policy index) - COMPLEX: partly treatment moderator, partly confounder\n\n")

cat("=== KEY ISSUE: INTERACTION TERM AND IVB ===\n")
cat("The Burnside-Dollar specification has aid*policy as a KEY variable.\n")
cat("If we treat 'policy' as the collider z, then the interaction aid*policy\n")
cat("must also be removed from the short model. This means the treatment\n")
cat("specification fundamentally changes.\n")
cat("This is COMPLICATED for IVB because:\n")
cat("  - The interaction term IS the main finding\n")
cat("  - Removing policy removes the interaction (since policy is in the interaction)\n")
cat("  - But policy may genuinely be a confounder, not just a collider\n\n")

cat("=== SIMPLER IVB APPLICATION ===\n")
cat("Best approach: Use ICRGE or M2 as collider z.\n")
cat("These are standard controls that might plausibly be colliders.\n")
cat("Treatment = aid (and aid*policy), collider = icrge or m21.\n")
cat("This cleanly tests IVB without disturbing the core specification.\n\n")

cat("=== VERDICT ===\n")
cat("GOOD candidate for IVB analysis.\n")
cat("Reasons:\n")
cat("  + Linear OLS regression (FWL holds)\n")
cat("  + Panel data with continuous time-varying controls\n")
cat("  + Selection-on-observables OLS specification available\n")
cat("  + Multiple plausible collider candidates (icrge, m21, policy components)\n")
cat("  + Highly cited, influential paper with known fragility\n")
cat("  + Data and code publicly available\n")
cat("  + Clean specification that maps well to IVB framework\n")
cat("Concerns:\n")
cat("  - The interaction term (aid*policy) complicates IVB interpretation\n")
cat("  - Many controls are arguably confounders too, not pure colliders\n")
cat("  - The paper's main story is about the INTERACTION, not just aid level effect\n")
cat("  - Policy is both moderator and potential collider\n")
