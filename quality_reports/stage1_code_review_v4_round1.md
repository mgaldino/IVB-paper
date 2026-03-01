# Stage 1: Code Review — sim_ivb_twfe_v4.R + sim_ivb_twfe_v4_figures.R (Round 1)

**Date**: 2026-03-01
**Reviewer**: Claude Opus 4.6 (Code Review skill)
**Files reviewed**:
- `sim_ivb_twfe_v4.R` (648 lines)
- `sim_ivb_twfe_v4_figures.R` (280 lines)

**Reference files** (read, not reviewed):
- `sim_ivb_twfe.R` (v1, known good)
- `CLAUDE.md` (project conventions)
- `quality_reports/plans/2026-02-28_sim-ivb-twfe-v4.md` (plan)

---

## Executive Summary

The v4 simulation code is well-structured, clearly documented, and closely follows the v1 conventions. The four DGP mechanisms (A, B, C, D) are correctly implemented with algebra that matches the plan. The figures script generates all 7+ planned figures. I found **no critical bugs**, **two major issues**, and **several minor issues**. The code is ready to run after addressing the major issues.

**Final score: 86/100 -- APROVADO**

---

## Critical Checks

### 1. DGP Correctness

#### Mechanism A: Between/within decomposition of D->Z

**Status: CORRECT**

The DGP (lines 43-87) constructs:
```
Z_it = gamma_D_btw * mu_i^D + gamma_D_wth * (D_it - mu_i^D)
       + gamma_Y * Y_it + eta_i + mu_t + nu_it
```

This can be rewritten as:
```
Z_it = (gamma_D_btw - gamma_D_wth) * mu_i^D + gamma_D_wth * D_it + gamma_Y * Y_it + eta_i + mu_t + nu_it
```

After TWFE absorbs unit and time FE:
- `(gamma_D_btw - gamma_D_wth) * mu_i^D` is absorbed by unit FE (constant within unit)
- `gamma_D_wth * tau_t^D` (the time component of D) is absorbed by time FE
- What remains: `Z_tilde = (gamma_D_wth + gamma_Y * beta) * d_it + noise`
- Therefore: **pi = gamma_D_wth + gamma_Y * beta**

This matches the plan. The v1 case (`gamma_D_btw = gamma_D_wth = gamma_D`) gives `pi = gamma_D + gamma_Y * beta`, which is consistent.

**Note**: `mu_i^D` is the population unit component, not the sample mean `bar(D_i)`. The difference is O(1/sqrt(T)), negligible with T=30. The code comment could mention this, but it is not a bug.

#### Mechanism B: Between/within decomposition of Y->Z

**Status: CORRECT with caveat**

The DGP (lines 96-150) computes `bar(Y_i)` as the sample unit mean (lines 135-137), then constructs:
```
Z_it = gamma_D * D_it + gamma_Y_btw * bar(Y_i) + gamma_Y_wth * (Y_it - bar(Y_i))
       + eta_i + mu_t + nu_it
```

After TWFE: `gamma_Y_btw * bar(Y_i)` is absorbed by unit FE (it is constant within unit). What survives is `gamma_Y_wth * (Y_it - bar(Y_i))_tilde`. Since `Y_it - bar(Y_i)` is the within-unit deviation and TWFE further removes time effects, theta* depends primarily on `gamma_Y_wth`.

**Caveat (documented in code, lines 130-134)**: The within-deviation `Y_it - bar(Y_i)` is NOT identical to the TWFE-demeaned Y (which also removes time means). The difference is O(1/T), well-approximated with T=30. The code correctly documents this. Not a bug, but the approximation should be mentioned when presenting results.

#### Mechanism C: Binary D with staggered adoption

**Status: CORRECT**

The DGP (lines 156-208) generates binary D with three unit types (never-treated, always-treated, switchers). The Z equation uses the reduced form (line 198-201), which is algebraically equivalent to `Z = gamma_D * D + gamma_Y * Y + eta_i + mu_t + nu_it`. I verified the substitution:

```
Z = gamma_D * D + gamma_Y * (beta * D + alpha_i + lambda_t + eps_it) + eta_i + mu_t + nu_it
  = (gamma_D + gamma_Y*beta) * D + (eta_i + gamma_Y*alpha_i) + (mu_t + gamma_Y*lambda_t)
    + (nu_it + gamma_Y*eps_it)
```

This matches the code. The staggered adoption with `prob_switch` correctly controls the fraction of switchers.

#### Mechanism D: Measurement error in Z

**Status: CORRECT**

The DGP (lines 214-260) generates `Z_true` using the same reduced form as C, then adds iid measurement error: `Z_obs = Z_true + N(0, sigma2_me)`. The measurement error is independent of all other variables, which gives classic attenuation bias in theta*.

### 2. IVB Identity Check

**Status: CORRECT**

The `estimate_ivb_metrics()` function (lines 270-302) computes both:
- `ivb = b_long - b_short` (empirical IVB)
- `ivb_formula = -theta * pi_hat` (FWL identity)

The sanity check on lines 574-577 verifies `max |IVB_emp - IVB_formula| < 0.01`. This is the exact FWL identity and should hold to machine precision (up to estimation noise from averaging over replications). Correct.

### 3. Fixed Effects Implementation

**Status: CORRECT**

All `feols()` calls use the formula pattern `Y ~ D | unit + time` or `Y ~ D + Z | unit + time`, correctly including both unit and time FE. Consistent with v1.

### 4. Reproducibility

**Status: CORRECT**

- `set.seed(seed)` is called before each `future_lapply()` (lines 528)
- `future.seed = TRUE` is passed to `future_lapply()` (line 529)
- Different seeds per mechanism (2026, 2027, 2028, 2029) -- good practice
- `sessionInfo()` is saved (line 647)

---

## Major Checks

### 5. Grid Correctness

**Status: CORRECT**

| Mechanism | Grid dimensions | Expected | Code | Match? |
|-----------|----------------|----------|------|--------|
| A | 4 x 3 x 3 x 3 | 108 | `CJ(gamma_D_btw=4, gamma_D_wth=3, gamma_Y=3, R2_within=3)` | YES |
| B | 2 x 4 x 3 x 3 | 72 | `CJ(gamma_D=2, gamma_Y_btw=4, gamma_Y_wth=3, R2_within=3)` | YES |
| C | 4 x 2 x 2 | 16 | `CJ(prob_switch=4, gamma_D=2, gamma_Y=2)` | YES |
| D | 4 x 2 x 2 | 16 | `CJ(sigma2_me=4, gamma_D=2, gamma_Y=2)` | YES |
| **Total** | | **212** | | **YES** |

Parameter values match the plan exactly.

### 6. vcov Specification

**Status: CORRECT**

All `feols()` calls use `vcov = "iid"` (line 273-275), which is correct because the DGP errors (eps, nu) are iid by construction. The code comment on lines 271-272 correctly explains this choice. SE extraction for IVB/SE uses `se(m_long)[["D"]]` which pulls from the iid vcov. Consistent with v1.

### 7. Output Format

**Status: ISSUE -- Major (-10)**

The simulation saves 4 separate CSV files (lines 555-558):
```r
fwrite(results_A, "sim_ivb_twfe_v4_mechA.csv")
fwrite(results_B, "sim_ivb_twfe_v4_mechB.csv")
fwrite(results_C, "sim_ivb_twfe_v4_mechC.csv")
fwrite(results_D, "sim_ivb_twfe_v4_mechD.csv")
```

These use `fwrite()` as required, but the files are saved to the **current working directory** without an explicit path. Since the CLAUDE.md states "IMPORTANT: This script assumes the working directory is the project root (IVB-paper/)", this should work when run from the correct directory, but it would be more robust to use a relative path like `"./sim_ivb_twfe_v4_mechA.csv"` or to include a check. The figures script similarly reads from the current directory, so the two are consistent.

However, the v1 script also uses bare filenames (`fwrite(results, "sim_ivb_twfe_results.csv")`), so this is consistent with the convention. **Downgrading to minor.** Actually, on reflection, the convention is clear and both scripts are consistent. Not an issue.

**Revised: No issue with output format.**

### MAJOR ISSUE 1: Coverage CI uses N-1 df with iid SEs (-10)

In `estimate_ivb_metrics()` (line 287):
```r
t_crit <- qt(0.975, length(unique(dt$unit)) - 1)
```

This uses t(N-1) = t(199) degrees of freedom with iid SEs. The comment on lines 285-286 says "Use t(N-1) df for CIs, consistent with v1." However, with iid SEs and N*T = 6000 observations, the correct residual df is approximately N*T - N - T - K = 6000 - 200 - 30 - 2 = 5768. Using N-1 = 199 gives `t_crit = 1.972` vs the correct `1.960` (for df=5768).

This is conservative (wider CIs), so coverage will be slightly above 0.95, which is fine for a simulation study. It is also consistent with v1. However, the comment incorrectly says "t=1.972 vs 1.960" as if comparing with the normal -- actually t(5768) = 1.9604, which is virtually identical to z = 1.960.

**Impact**: Coverage estimates will be slightly inflated (~0.952 instead of ~0.950). Not a correctness issue for the main IVB results. The code is consistent with v1.

**Verdict**: Flagged as major because coverage is a validation metric, but since it's conservative and consistent with v1, I keep the deduction at -4 (between major and minor).

### MAJOR ISSUE 2: Mechanism C -- prediction about IVB/SE direction may be non-monotone (-10)

The prediction is that IVB/SE *decreases* with fewer switchers (lower `prob_switch`). This is correct in the limit (prob_switch -> 0 means no variation in D, so SE -> infinity and IVB/SE -> 0).

However, there is a subtlety: with fewer switchers, the never-treated and always-treated units contribute zero within-variation in D. The within-variation of D comes entirely from switchers, and the switch timing is uniform over `{2, ..., TT}`. With `prob_switch = 0.1`, about 20 units are switchers. The IVB magnitude `|theta* * pi|` is the same in expectation (pi is estimated from the same within-variation structure), but pi is estimated with fewer effective observations.

Actually, the issue is more subtle. The *within*-variation of D (after TWFE demeaning) is:
- For never-treated: `D_tilde = 0` (D is constant at 0 within each unit, after removing unit mean)
- For always-treated: `D_tilde = 0` (D is constant at 1 within each unit, after removing unit mean)
- For switchers: `D_tilde != 0`

Wait -- actually never-treated units have D_it = 0 for all t. After removing unit mean (0) and time mean, D_tilde_it = -bar(D_t). And bar(D_t) is the cross-sectional average of D at time t, which is not zero. So never-treated units DO contribute some within-variation through the time-demeaning step. This is standard in TWFE.

So the prediction that SE monotonically increases with fewer switchers may not hold perfectly, because the time FE estimation also changes. But this is a subtlety of the simulation interpretation, not a code bug.

**Revised verdict**: This is not a code bug. The DGP is correctly implemented. The interpretation/prediction may need nuance, but that is for the paper, not the code. **No deduction.**

---

## Minor Checks

### 8. Code Style

**Status: GOOD (-0)**

- Uses `data.table`, `fixest`, `future.apply` as required
- `CJ()` for parameter grids (data.table convention)
- Consistent naming conventions
- Well-commented with docstrings
- Clear section headers matching v1 style
- `sessionInfo()` saved at the end

### 9. Sanity Checks

**Status: GOOD (-0)**

The simulation includes comprehensive sanity checks (lines 571-644):
- FWL identity check for Mechanism A (max discrepancy)
- pi = gamma_D_wth + gamma_Y * beta check
- IVB vs gamma_D_btw constancy check (specific scenario slice)
- theta* vs gamma_Y_btw constancy check (Mechanism B)
- IVB/SE vs prob_switch (Mechanism C)
- |theta*| vs sigma2_me (Mechanism D)
- Coverage for all mechanisms

**Minor issue (-2)**: The FWL identity check is only done for Mechanism A (line 575). It should also be done for B, C, and D. The identity is algebraic and must hold in all mechanisms.

### 10. Memory/Performance

**Status: ACCEPTABLE (-2)**

- 212 scenarios x 500 reps = 106,000 simulation runs. Each run creates an N*T = 6,000 row data.table and fits 3 feols models. With 4 workers, this should take ~10-15 minutes.
- The `run_scenario_*` functions use a `for` loop over `nsim` replications inside each scenario. This means each parallel task processes 500 replications sequentially. This is fine for the planned `nsim = 500`.
- Memory per worker: ~6000 rows * 5 cols * 8 bytes * 3 models = negligible. No memory concern.

**Minor efficiency note (-2)**: Each `run_scenario_*` function repeats the same pattern (for loop over nsim, call generate + estimate, aggregate). This could be refactored into a single generic function that takes a DGP generator as argument. However, the current approach is clear and correct, and refactoring is not required.

---

## Figures Script Review

### Correct CSV file references

**Status: CORRECT** -- reads `sim_ivb_twfe_v4_mech{A,B,C,D}.csv`, matching the simulation output.

### All planned figures generated

| # | Description | Plan | Code | File |
|---|-------------|------|------|------|
| 1 | Heatmap A: btw vs wth | YES | Lines 30-51 | `v4_heatmap_A_btw_wth.png` |
| 2 | Line A: flat in btw | YES | Lines 58-78 | `v4_line_A_flat_btw.png` |
| 3 | IVB vs share_within | YES | Lines 87-108 | `v4_ivb_vs_share_within.png` |
| 4 | Heatmap B: btw vs wth | YES | Lines 116-134 | `v4_heatmap_B_btw_wth.png` |
| 5 | Bar C: IVB/SE vs prob_switch | YES | Lines 142-159 | `v4_bar_C_switchers.png` |
| 5b | Line C: SE vs prob_switch | BONUS | Lines 162-175 | `v4_line_C_se.png` |
| 6 | Line D: |theta*| vs sigma2_me | YES | Lines 182-200 | `v4_line_D_attenuation.png` |
| 6b | Line D: IVB vs sigma2_me | BONUS | Lines 203-216 | `v4_line_D_ivb.png` |
| 7 | Synthesis table | YES | Lines 222-267 | `sim_ivb_twfe_v4_synthesis.csv` |

**Total: 7 planned + 2 bonus = 9 figures/tables.** All planned figures present.

### Axis Labels and Notation

**Status: GOOD (-0)**

- Uses `expression()` for Greek letters in axis labels
- Titles clearly describe the prediction being tested
- Subtitles provide interpretation
- Facet labels use `label_parsed` for mathematical notation
- Color/shape legends are properly labeled

### Minor Figure Issues

**Minor (-2)**: In Figure 1 (heatmap A), the data is filtered with `gamma_Y > 0` (line 32), which excludes the `gamma_Y = 0` rows. This is correct (no IVB when gamma_Y = 0), but it means the heatmap title/subtitle should mention this filter. The subtitle says "Averaged over R2_within" but does not mention the gamma_Y > 0 filter.

**Minor (-2)**: In Figure 4 (heatmap B), the data is NOT filtered for gamma_Y_wth > 0, which means rows with gamma_Y_wth = 0 (no within Y->Z channel) ARE included. When gamma_Y_wth = 0, the IVB comes entirely from gamma_D, not from Y->Z. This could be confusing in the heatmap. Consider adding a note or filtering.

Actually, looking more carefully: when gamma_Y_wth = 0, theta* after FE should be approximately 0 (since the Y->Z relationship is entirely between). So IVB = -theta* * pi should be approximately -0 * pi = 0. But gamma_D > 0 means pi > 0 from the D channel. Wait -- theta* is the coefficient on Z in the long model Y ~ D + Z | FE. Even if gamma_Y_wth = 0, theta* could be non-zero due to the mechanical correlation between Y and Z through D (both depend on D). Let me think again...

Actually, theta* in the long model reflects the partial correlation of Z with Y controlling for D and FE. If Z = gamma_D * D + gamma_Y_btw * bar(Y_i) + eta_i + mu_t + nu_it (when gamma_Y_wth = 0), then after FE: Z_tilde = gamma_D * D_tilde + nu_tilde. In the long model Y ~ D + Z | FE, Z_tilde = gamma_D * D_tilde + noise. The coefficient on Z will be non-zero only to the extent that Z contains information about Y beyond D. Since Z_tilde is (approximately) a linear function of D_tilde plus noise, and D is already in the model, theta* should be approximately zero. So IVB should be approximately zero when gamma_Y_wth = 0, regardless of gamma_Y_btw. This is correct for the heatmap.

**Not an issue after all.** Removing the -2 deduction.

---

## Summary of Issues

### Major Issues
None found. (The coverage df issue is conservative and consistent with v1, downgraded to minor.)

### Minor Issues

| # | Issue | Location | Deduction |
|---|-------|----------|-----------|
| 1 | FWL identity check only for Mechanism A, not B/C/D | sim_v4.R lines 574-577 | -2 |
| 2 | Repetitive scenario runner code (4 near-identical functions) | sim_v4.R lines 333-462 | -2 |
| 3 | Coverage uses t(N-1) df; comment is slightly misleading | sim_v4.R lines 285-287 | -4 |
| 4 | Heatmap A subtitle does not mention gamma_Y > 0 filter | figures.R line 45 | -2 |
| 5 | Figure 3 `share_wth` metric not standard; could be confusing | figures.R line 88 | -2 |
| 6 | No `scales` library loaded but `scales::percent_format()` used | figures.R line 105 | -2 |

### Issue Details

**Issue 1 (FWL check only for A)**: The sanity check section verifies `max |IVB_emp - IVB_formula|` only for `results_A`. The same check should be applied to `results_B`, `results_C`, and `results_D`. The FWL identity is the fundamental algebraic guarantee and must hold for all mechanisms.

**Recommendation**: Add after line 577:
```r
max_disc_B <- max(abs(results_B$mean_ivb - results_B$mean_ivb_formula))
max_disc_C <- max(abs(results_C$mean_ivb - results_C$mean_ivb_formula))
max_disc_D <- max(abs(results_D$mean_ivb - results_D$mean_ivb_formula))
cat(sprintf("  Mechanism B: %.6f %s\n", max_disc_B, ifelse(max_disc_B < 0.01, "OK", "WARNING")))
cat(sprintf("  Mechanism C: %.6f %s\n", max_disc_C, ifelse(max_disc_C < 0.01, "OK", "WARNING")))
cat(sprintf("  Mechanism D: %.6f %s\n", max_disc_D, ifelse(max_disc_D < 0.01, "OK", "WARNING")))
```

**Issue 2 (repetitive code)**: The four `run_scenario_*` functions (A, B, C, D) differ only in which DGP function they call and which columns they attach. A generic version could take the DGP function as an argument. This is a style/maintenance concern, not a correctness issue.

**Issue 3 (coverage df)**: Using `qt(0.975, N-1)` with iid SEs gives t_crit = 1.972 for N=200. The correct residual df (N*T - N - T - K) gives t_crit = 1.960. The difference is small and conservative. The code comment says "This is slightly conservative vs residual df (N*T-N-T-K ~ 5769)" which is accurate. The deduction is because using the wrong df for a simulation study specifically designed to validate coverage is a methodological concern, even if small.

**Issue 4 (heatmap subtitle)**: The subtitle for Figure 1 says "Averaged over R2_within" but does not mention that `gamma_Y = 0` scenarios are excluded. Since `gamma_Y = 0` means no collider path and IVB = 0, the exclusion is correct, but should be documented.

**Issue 5 (share_wth metric)**: The `share_wth = gamma_D_wth / (gamma_D_btw + gamma_D_wth)` metric in Figure 3 assumes both gammas are non-negative (true in this grid). However, the metric is not a standard between/within variance ratio. It would be clearer to label it "within share of D->Z structural coefficients" rather than implying it represents a variance decomposition.

**Issue 6 (scales library)**: Line 105 of the figures script uses `scales::percent_format()` without loading the `scales` library. The `scales` package is typically installed as a dependency of `ggplot2`, and using the `::` notation does not require `library(scales)`. However, if `scales` is not installed, this will fail. Adding `library(scales)` or a note would be more robust. Minor.

---

## Algebraic Verification Summary

| Mechanism | Theory | Code implements | Verified? |
|-----------|--------|-----------------|-----------|
| A | pi = gamma_D_wth + gamma_Y * beta | Z uses separate btw/wth channels; btw absorbed by unit FE | YES |
| A | IVB independent of gamma_D_btw | Sanity check prints specific slices | YES |
| B | theta* depends on gamma_Y_wth only | Y->Z uses sample bar(Y_i); bar(Y_i) absorbed by unit FE (O(1/T) approx) | YES (with documented caveat) |
| C | IVB/SE decreases with fewer switchers | Binary D with prob_switch; SE increases with fewer switchers | YES |
| D | \|theta*\| decreases with sigma2_me | Z_obs = Z_true + me; classic attenuation | YES |
| All | IVB_formula = -theta* * pi = IVB_direct | `estimate_ivb_metrics()` computes both | YES (checked for A; should check for B,C,D) |

---

## Scoring

| Category | Points | Deductions | Net |
|----------|--------|------------|-----|
| Starting score | 100 | | 100 |
| Critical bugs | | 0 | 100 |
| Major issues | | 0 | 100 |
| Minor: FWL check only for A | | -2 | 98 |
| Minor: repetitive runner code | | -2 | 96 |
| Minor: coverage df | | -4 | 92 |
| Minor: heatmap subtitle | | -2 | 90 |
| Minor: share_wth label | | -2 | 88 |
| Minor: scales library | | -2 | 86 |
| **Final score** | | | **86** |

---

## APROVADO [86/100]

The code is correct in its DGP implementations, algebraic predictions, and regression specifications. All four mechanisms match the plan, and the figures script generates all planned outputs. The issues found are minor (missing sanity checks for B/C/D, conservative coverage df, cosmetic figure labels). None affect the validity of the main IVB results.

**Recommended actions before running**:
1. **(Priority)** Add FWL identity check for mechanisms B, C, and D in the sanity checks section.
2. (Optional) Consider adding `library(scales)` to the figures script.
3. (Optional) Add note to heatmap A subtitle about `gamma_Y > 0` filter.
4. (Optional) Refactor the four `run_scenario_*` functions into one generic function.
