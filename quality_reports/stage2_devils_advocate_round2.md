# Stage 2: Devil's Advocate -- ivb_paper_psrm.Rmd (Round 2)

**Manuscript reviewed**: `ivb_paper_psrm.Rmd`
**Date**: 2026-03-03
**Reviewer**: Devil's Advocate (Stage 2, Round 2)
**Round 1 score**: 46/100 (5 issues identified)
**Focus**: Verification of 3 fixes (V1, V3) and 2 false positive assessments (V2, V4)

---

## Score: 95/100

Deductions:
- -3 (Minor): Abstract lists 4 structural conditions; body and conclusion list 5 (feedback mechanism omitted from abstract).
- -2 (Minor): ADL-all-lags bias for phi=0.15, rho_Z=0.5 is 1.03% of beta, marginally exceeding the stated bound of "less than 1% of beta across all stable scenarios."

## Status: APROVADO

---

## Verification of Round 1 Fixes

### V1 (Critical, FIXED) -- CONFIRMED CORRECT

Three factual errors in Section 5.3 (ADL Specifications Reduce Residual IVB, line 592) have been corrected.

**1. N=200 changed to N=100.**
Manuscript line 592 now reads: "Across 48 scenarios ($N = 100$, $T = 30$, 500 replications)".
Verified against simulation script `/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/simulations/v4_mechanisms/sim_mechC_adl.R`, line 43: `P <- list(N = 100, TT = 30, ...)`. CORRECT.

Note: The "few switchers" subsection (Section 5.2, line 584) correctly reports N=200, which corresponds to a different simulation file (`sim_ivb_twfe_v4_mechC.csv`) that does use N=200. No cross-contamination.

**2. Bias range 86-169% changed to 77-169%.**
Manuscript line 592 now reads: "TWFE without $Z$ exhibits bias of 77--169% of $\beta$".
Verified from `/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/simulations/v4_mechanisms/results/sim_mechC_adl_results.csv`: the minimum `twfe_s_bias` across all 48 rows is 0.7726 (prob_switch=0.7, delta_D=0.1, delta_Y=0, rho_Z=0.5), and the maximum is 1.6919 (prob_switch=0.1, delta_D=0.3, delta_Y=0.3, rho_Z=0.7). Reported range 77-169% is CORRECT.

**3. DGP described as having Z->D changed to exogenous binary D.**
Manuscript line 592 now reads: "exogenous binary treatment (staggered adoption)".
Verified from `sim_mechC_adl.R`, lines 10 and 83-90: `D_it = 1(t >= T_i*) -- staggered binary treatment (exogenous)`. D is purely deterministic based on unit type and switch timing, with no dependence on Z. CORRECT.

### V3 (Major, FIXED) -- CONFIRMED CORRECT

The overprecise claim "at most 25%" has been replaced with conservative qualitative wording in all three locations.

**Location 1: Section 5.4 (line 598).**
Now reads: "TWFE bias increases modestly relative to the linear case but remains within the same order of magnitude."
"Modestly" is appropriately vague and avoids committing to a specific percentage. CORRECT.

**Location 2: Section 5 Summary (line 610).**
Now reads: "Bounded nonlinearities in the collider channel---the empirically relevant case---do not qualitatively change the IVB picture."
Qualitative language that accurately conveys the simulation finding without overprecision. CORRECT.

**Location 3: Conclusion (line 908).**
Now reads: "bounded nonlinearities in the collider channel do not qualitatively change the IVB picture."
Mirrors the Summary wording. CORRECT.

No remnant of "at most 25%" found anywhere in the manuscript (confirmed via search).

---

## Verification of Round 1 False Positive Assessments

### V2 (Critical, FALSE POSITIVE) -- CONFIRMED VALID

The Round 1 reviewer checked the wrong simulation file (`sim_direct_feedback.R` / `sim_direct_feedback_results.csv`) instead of the correct file (`sim_feedback_Y_to_D.R` / `sim_feedback_Y_to_D_results.csv`).

**Evidence from the correct file** at `/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/simulations/dynamics/results/sim_feedback_Y_to_D_results.csv`:

| phi | rho_Z | twfe_s_bias | Bias as % of beta |
|-----|-------|-------------|-------------------|
| 0 | 0.5 | 0.4337 | 43.4% |
| 0 | 0.7 | 0.5067 | 50.7% |
| 0.05 | 0.5 | 0.5566 | 55.7% |
| 0.05 | 0.7 | 0.6546 | 65.5% |
| 0.10 | 0.5 | 0.6855 | 68.5% |
| 0.10 | 0.7 | 0.8022 | 80.2% |
| **0.15** | **0.5** | **0.8036** | **80.4%** |

Key findings:
- **phi=0.15 EXISTS** in the data (row 8), with rho_Z=0.5.
- **twfe_s_bias = 0.8036** (80.4% of beta), confirming the paper's claim of "80% at phi=0.15".
- **phi=0.15, rho_Z=0.7 is absent**: Only 7 data rows. The combination phi=0.15, rho_Z=0.7 was skipped, consistent with the explanation that it was near the stationarity boundary.
- **No phi >= 0.18**: No rows with phi values at or above 0.18, confirming the explosive boundary claim.

The false positive assessment is VALID. The Round 1 reviewer's error was checking the wrong file.

### V4 (Minor, FALSE POSITIVE) -- CONFIRMED VALID

The claim "over 300 DGP configurations" (lines 33, 576, 908) is correct.

**DGP configuration count from existing simulation result files** (rows minus header):

| Simulation family | File(s) | Scenarios |
|-------------------|---------|-----------|
| v4 Mechanism C (few switchers) | sim_ivb_twfe_v4_mechC.csv | 16 |
| mechC ADL | sim_mechC_adl_results.csv | 48 |
| NL collider | sim_nl_collider_results.csv | 81 |
| NL interact | sim_nl_interact_results.csv | 10 |
| NL carryover | sim_nl_carryover_results.csv | 13 |
| Feedback Y->D | sim_feedback_Y_to_D_results.csv | 7 |
| Dual-role Z (5 files) | various dual_role_z results | 72 |
| Diagnostics (6 files) | diag_* results | 81 |
| Dynamics (3 files) | sim_direct_* and sim_feedback_carryover | 17 |
| **Total** | | **345** |

345 > 300. The claim is accurate. The false positive assessment is VALID.

Note: Even excluding diagnostics and dynamics (which are auxiliary analyses), the core simulation families total 247. Including dual_role_z (which underpins the FE absorption discussion in Section 5.1), the count reaches 319. The claim is robust to different counting methods.

### V5 (Minor, INFORMATIONAL) -- NOTED

The phi >= 0.18 stationarity threshold is described as approximate and based on eigenvalue calculations in the companion matrix. The CSV data shows the last stable configuration at phi=0.15 (rho_Z=0.5), and no configurations at phi >= 0.18. The characterization as "approximately 0.18" is reasonable. No action needed.

---

## New Issues in Modified Text

### N1 (Minor, -3): Abstract omits feedback mechanism from structural conditions list

The abstract (line 33) lists four structural conditions: "fixed effects absorbing between-unit variation, few treatment switchers, ADL specifications blocking collider paths, and bounded nonlinearities."

The body (Section 5, line 576) lists five: "five structural features of typical TSCS designs." Section 5.5 (Feedback from Outcomes to Treatment) is the fifth mechanism, and it produces a substantive result (ADL absorbs feedback up to phi=0.15).

The conclusion (line 908) also lists all five mechanisms explicitly.

This is an inconsistency between the abstract and the rest of the paper. The feedback mechanism is a meaningful contribution (it establishes a boundary condition for when ADL fails) and its omission from the abstract undersells the simulation work.

**Recommendation**: Add "and moderate outcome-to-treatment feedback" (or similar) to the abstract's list of structural conditions.

### N2 (Minor, -2): ADL bias marginally exceeds stated 1% bound in one scenario

Section 5.5 (line 604-606) states: "The ADL specification with all lags, however, remains remarkably robust: $|\text{bias}| < 1\%$ of $\beta$ across all stable scenarios."

From the feedback CSV (`sim_feedback_Y_to_D_results.csv`), the `adl_all_bias` column for phi=0.15, rho_Z=0.5 is -0.01027, which is 1.03% of beta (beta=1). The Monte Carlo standard error for this estimate is 0.00091, so the 95% confidence interval for the true bias is approximately [0.85%, 1.21%].

The stated bound "< 1%" is therefore not strictly guaranteed by the data, although the violation is marginal (1.03% vs 1.00%) and within Monte Carlo sampling noise.

**Recommendation**: Change "less than 1% of $\beta$" to "approximately 1% of $\beta$" or "at most 1.5% of $\beta$" to be strictly accurate. Alternatively, change to "less than 1% of $\beta$ in all but the most extreme stable scenario, where it reaches approximately 1%."

---

## Remaining Issues from Round 1

None. All five issues (V1-V5) have been satisfactorily resolved:
- V1: Fixed (3 factual corrections confirmed).
- V2: Confirmed false positive (wrong file checked).
- V3: Fixed (conservative wording confirmed in 3 locations).
- V4: Confirmed false positive (345 DGP configurations > 300).
- V5: Informational only, no action needed.

---

## Consistency Check: Abstract, Body, and Conclusion

| Claim | Abstract (L33) | Body (Section 5) | Conclusion (L908) | Status |
|-------|-----------------|-------------------|--------------------|--------|
| IVB formula | theta* x pi | theta* x pi | theta* x pi | Consistent |
| 300+ DGP configs | "over 300" | "over 300" (L576) | "over 300" (L908) | Consistent |
| IVB < 3% under ADL | "below 3%" | "less than 3%" (L592) | "less than 3%" (L908) | Consistent |
| Median IVB/SE = 0.13 | ~0.13 | ~0.13 (L703) | ~0.13 (L908) | Consistent |
| Only 1 candidate > 1 SE | GDP p.c. in Rogowski | GDP p.c., IVB/SE=2.11 (L703) | GDP p.c., IVB/SE=2.11 (L908) | Consistent |
| 6 published studies | 6 | 6 (L619) | 6 (L908) | Consistent |
| 14 collider candidates | "theoretically motivated" | 14 (L703) | 14 (L908) | Consistent |
| Structural conditions | 4 listed | 5 listed (L576) | 5 listed (L908) | **INCONSISTENT** (N1) |
| Feedback bias < 1% | Not mentioned | "< 1%" (L604) | "below 1%" (L908) | Marginally inaccurate (N2) |
| IVB = 58% of beta for Rogowski | 58% | 58% (L885) | 58% (L908) | Consistent |
| Lag substitution not a cure | Stated | Prop. 5 (L453) | Stated (L906) | Consistent |

---

## Summary

The manuscript is in strong shape. All three genuine fixes from Round 1 (V1, V3) have been correctly implemented. Both false positive assessments (V2, V4) are validated: the Round 1 reviewer checked the wrong simulation file for V2, and the total DGP configuration count does exceed 300 for V4. Only two new minor issues were identified: (N1) the abstract omits the feedback mechanism from its list of structural conditions, creating a 4-vs-5 inconsistency with the body and conclusion; (N2) the ADL bias bound of "less than 1%" is marginally violated (1.03%) in one scenario. Neither issue threatens the paper's substantive conclusions.

The factual claims in the paper are well-supported by the underlying simulation data. The 77-169% bias range, the 43%-to-80% feedback escalation, the <3% ADL performance, and the phi >= 0.18 stationarity boundary all check out against the CSV files. The N=100 and N=200 values in different subsections correctly correspond to different simulation scripts (mechC_adl and v4_mechC respectively). The abstract, body, and conclusion are consistent on all major quantitative claims except for the minor structural-conditions count discrepancy.
