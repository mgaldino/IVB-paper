# Stage 3: Proofread Review -- Round 2 (Verification of Fixes)

**Reviewer:** Proofread Re-Reviewer Agent
**Date:** 2026-03-03
**File reviewed:** `ivb_paper_psrm.Rmd`
**Previous report:** `stage3_proofread_round1_v2.md` (or prior round)
**Scope:** Verify 7 applied fixes + confirm 8 deferred issues are acceptable + check for new issues

---

## Part 1: Verification of Applied Fixes

### Fix #1 -- Line ~74: "putting a collider" -> "including a collider"

**Status: VERIFIED FIXED**

Line 74 now reads:
> "IVB quantifies the cost of including a collider."

The informal "putting" has been replaced with the more formal "including", consistent with the paper's academic register. The same verb "including" is used throughout the manuscript (e.g., lines 335, 345, 427).

**No deduction.**

---

### Fix #2 -- Line ~76: "We show that is primarily" -> "We show that when the treatment--collider association is primarily"

**Status: VERIFIED FIXED**

Line 76 now reads:
> "We show that when the treatment--collider association is primarily cross-sectional (e.g., richer countries have better governance in levels), fixed effects remove this association, and the residual within-unit IVB is small."

The sentence is now grammatically complete with a proper subject after "that". The added clause ("when the treatment--collider association is") clarifies the condition being described and flows naturally into the rest of the sentence.

**No deduction.**

---

### Fix #3 -- Line ~592: R-formula `$Y \sim D + ...$` -> prose "including $Y_{t-1}$, $D_{t-1}$, and $Z_{t-1}$"

**Status: VERIFIED FIXED**

Line 592 now reads:
> "We estimate nine specifications ranging from TWFE without controls to ADL models with all available lags ($Y_{t-1}$, $D_{t-1}$, $Z_{t-1}$)."

And later in the same line:
> "The ADL specification including $Y_{t-1}$, $D_{t-1}$, and $Z_{t-1}$ reduces bias to less than 3\% of $\beta$ in every scenario."

The R-formula syntax has been replaced with proper mathematical notation in prose. The three variables are listed in standard LaTeX math mode with correct subscript notation. The Oxford comma is used consistently.

**No deduction.**

---

### Fix #4 -- Line ~604: `$\gamma_D$` -> `$\lambda_D$` in feedback equation

**Status: VERIFIED FIXED**

Line 604 now reads:
> "$D_{it} = \alpha^D_i + \phi Y_{i,t-1} + \rho_D D_{i,t-1} + \lambda_D Z_{i,t-1} + u_{it}$"

The coefficient on $Z_{i,t-1}$ is now `\lambda_D`, which distinguishes it from any `\gamma_D` used elsewhere in the simulation parameters (CLAUDE.md). The `\lambda` symbol is also used on lines 393 and 1004 for a different purpose (coefficient on $y_{t-1}$ in the auxiliary regression), but there is no conflict because those are in different equations with different subscripts (`\lambda` vs `\lambda_D`).

**No deduction.**

---

### Fix #5 -- Line ~602: "TWFE" -> "static TWFE"

**Status: VERIFIED FIXED**

Line 602 now reads:
> "This feedback violates the strict exogeneity assumption that underpins static TWFE \citep{imai_kim2021}"

The qualifier "static" is important because it distinguishes basic TWFE (which requires strict exogeneity) from ADL specifications (which relax that assumption). This is consistent with the paper's framing of Imai & Kim (2019), where the distinction between static TWFE and ADL is central.

**No deduction.**

---

### Fix #6 -- Line ~610: "And moderate" -> "Finally, moderate"

**Status: VERIFIED FIXED**

Line 610 now reads:
> "Finally, moderate feedback from outcomes to treatment ($Y_{t-1} \to D_t$) is absorbed by the ADL specification, with IVB remaining at approximately 1\% of $\beta$."

"And" at the start of the sentence has been replaced with "Finally,", which is appropriate given that this is the fifth and last item in the enumerated list of mechanisms. The comma after "Finally" follows standard English usage.

**No deduction.**

---

### Fix #7 -- Line ~604: `0.10` -> `0.1`

**Status: VERIFIED FIXED**

Line 604 now reads:
> "$\phi \in \{0, 0.05, 0.1, 0.15\}$"

The trailing zero has been removed from `0.10`, yielding `0.1`. This is consistent with the formatting of the other values in the set (which use the minimum number of decimal places needed). The set `{0, 0.05, 0.1, 0.15}` is visually clean and mathematically standard.

**No deduction.**

---

## Part 2: Deferred Issues (Verify Acceptability)

### Deferred #3 -- Abstract wording: "moderate outcome-to-treatment feedback"

**Verdict: ACCEPTABLE**

The phrase appears on line 33 of the abstract. In context, it reads: "bounded nonlinearities, and moderate outcome-to-treatment feedback---that explain why IVB tends to be modest". The meaning is clear: moderate strength of the $Y_{t-1} \to D_t$ channel. No ambiguity.

---

### Deferred #5 -- Verifiability of "300" DGP configurations

**Verdict: ACCEPTABLE**

Line 576 states "over 300 DGP configurations" and line 33 (abstract) says "over 300 DGP configurations". The actual total is approximately 370+ across the various simulation families (dual-role Z, nonlinearity, feedback, carryover, etc.). "Over 300" is conservative and verifiable.

---

### Deferred #7 -- "log bounded": "concave" listed separately

**Verdict: ACCEPTABLE**

Line 596 lists: "(i) concave transformations ($\log(1 + |D|)$, soft-clamped polynomial), (ii) polynomial terms ($D^2$), and (iii) interaction terms". Line 598 refers to "bounded nonlinearities---concave or saturating transformations". The word "bounded" is not applied to "log" as a separate claim; rather, "bounded nonlinearities" is a category that includes concave/saturating functions. The usage is accurate.

---

### Deferred #8 -- Line 580 precision

**Verdict: ACCEPTABLE**

Line 580 reads: "As shown in Corollary \ref{cor:ivb_twfe}, the IVB under TWFE depends only on the within-unit components..." This is existing text and the phrasing is precise enough for the context.

---

### Deferred #9 -- Missing label on "Summary: When Is IVB Small?"

**Verdict: ACCEPTABLE**

Line 608: `## Summary: When Is IVB Small?` has no `\label{}`. There are no cross-references to this section anywhere in the manuscript. Adding a label would be unnecessary overhead.

---

### Deferred #12 -- Long conclusion sentence

**Verdict: ACCEPTABLE**

The conclusion (lines 902-918) contains some long sentences, but they are well-structured with clear clause boundaries (semicolons, em-dashes). This is a style preference and does not impair readability.

---

### Deferred #13 -- "below 3%" in abstract

**Verdict: ACCEPTABLE**

The abstract (line 33) says "keep IVB below 3\% of the treatment effect." Line 592 confirms: "reduces bias to less than 3\% of $\beta$ in every scenario." Line 610 says "less than 3\% of $\beta$." The claim is consistent and supported.

---

### Deferred #16 -- N=200 vs N=100

**Verdict: ACCEPTABLE**

- N=200 is used in the between/within simulation (line 584) and the Appendix DGPs 2-3 (lines 1023-1025).
- N=100 is used in the ADL/feedback/nonlinearity simulations (lines 592, 604).

These are different simulation designs with different purposes. The N=100 simulations test dynamics where smaller samples are sufficient; the N=200 simulations test mechanisms that require more cross-sectional variation. No inconsistency.

---

## Part 3: Check for New Issues Introduced by Fixes

I performed the following checks on the manuscript:

1. **Duplicate words scan** (e.g., "the the", "a a"): None found.
2. **Old text residue** (original unfixed phrasing): Confirmed absent for all 7 fixes.
3. **LaTeX syntax around edits**: No broken math environments, unmatched braces, or orphaned commands.
4. **Notation consistency for `\lambda_D`**: The symbol `\lambda_D` is used only on line 604. It does not conflict with `\lambda` (no subscript) on lines 393 and 1004. No issue.
5. **Grammar around "when the treatment--collider association"** (Fix #2): The sentence is grammatically correct and reads naturally.
6. **Oxford comma in "including $Y_{t-1}$, $D_{t-1}$, and $Z_{t-1}$"** (Fix #3): Consistent with the rest of the manuscript.

**No new issues found.**

---

## Score Calculation

| Item | Status | Deduction |
|------|--------|-----------|
| Fix #1: "including a collider" | VERIFIED | 0 |
| Fix #2: "when the treatment--collider association is primarily" | VERIFIED | 0 |
| Fix #3: R-formula -> prose notation | VERIFIED | 0 |
| Fix #4: `\gamma_D` -> `\lambda_D` | VERIFIED | 0 |
| Fix #5: "static TWFE" | VERIFIED | 0 |
| Fix #6: "Finally, moderate" | VERIFIED | 0 |
| Fix #7: `0.10` -> `0.1` | VERIFIED | 0 |
| Deferred #3 (abstract wording) | ACCEPTABLE | 0 |
| Deferred #5 ("300" verifiable) | ACCEPTABLE | 0 |
| Deferred #7 ("bounded" usage) | ACCEPTABLE | 0 |
| Deferred #8 (line 580 precision) | ACCEPTABLE | 0 |
| Deferred #9 (missing label) | ACCEPTABLE | 0 |
| Deferred #12 (long sentence) | ACCEPTABLE | 0 |
| Deferred #13 ("below 3%") | ACCEPTABLE | 0 |
| Deferred #16 (N=200 vs N=100) | ACCEPTABLE | 0 |
| New issues from fixes | NONE | 0 |
| **Total deductions** | | **0** |

**Final Score: 100/100**

---

## Verdict: APROVADO [100]

All seven fixes have been applied correctly. The edits are clean, grammatically sound, and notation-consistent. No new issues were introduced. The eight deferred items are all acceptable as-is -- none requires further action for manuscript quality.

---

*Report generated by Proofread Re-Reviewer Agent (Round 2), 2026-03-03*
