# Devil's Advocate Report -- Stage 2, Round 2

**Manuscript**: `ivb_paper_psrm.Rmd` (post-Round-1 corrections)
**Date**: 2026-03-22
**Reviewer**: Devil's Advocate (Stage 2, Round 2 -- re-evaluation after rewrite)
**Round 1 report**: `stage2_devils_advocate_round1.md` (score: 66/100, REPROVADO)
**Target journal**: Political Science Research and Methods (PSRM)
**Context**: This is a re-evaluation after corrections to C1, C2, M1, M2, and (claimed) M3 from Round 1. The same rubric is applied.

---

## Score: 82/100
## Status: APROVADO

---

## Re-evaluation of Round 1 Issues

### C1. IVB formula is a tautology dressed as a contribution -- RESOLVED (-5 residual, down from -15)

**Changes made**: The manuscript now explicitly frames the formula as a known decomposition repurposed as a diagnostic:

- Section 4 opening (line 244): "The decomposition is a direct application of the Frisch--Waugh--Lovell theorem and the standard short-versus-long regression identity [see, e.g., Angrist & Pischke, Theorem 3.2.1]. Our contribution is not the algebra itself---which is well known in econometrics---but rather its repackaging as an operational diagnostic for the collider/mediator/confounder classification problem in TSCS settings."
- Line 292: "The following result restates the standard short-versus-long regression decomposition in a form that is directly operational as a diagnostic for covariate inclusion decisions."
- Line 306: "Proposition [X] is an algebraic identity---the complement of the standard OVB decomposition, well known in econometrics [e.g., Goldberger 1991, pp. 197--198]. Its value as a contribution lies not in the algebra but in its application."

**Assessment**: The rhetorical shift is substantial and well-executed. The paper now acknowledges the identity's textbook origin and locates the contribution in the *diagnostic application* rather than the algebra. This is honest and defensible.

**Residual concern (-5)**: The formal label remains "Proposition" (Propositions 1, 2, 3) for results explicitly acknowledged as algebraic identities. The surrounding text manages expectations correctly, but the theorem environment still signals novelty. A referee who skims the formal results without reading the commentary may still perceive overclaiming. Using "Observation," "Fact," or "Result" would better match the stated framing. This is primarily a cosmetic issue since the text does the heavy lifting.

---

### C2. "Over 300 DGPs" is factually incorrect -- FULLY RESOLVED (0, down from -15)

**Changes made**: All four occurrences of "over 300" have been replaced with "238":
- Abstract (line 33): "238 DGP configurations"
- Section 5 intro (line 504): "238 DGP configurations"
- Section 5.4 (line 550): "238 DGP configurations"
- Conclusion (line 846): "238 DGP configurations"

**Assessment**: Fully resolved. The count now matches the simulation evidence cited in Section 5.

---

### M1. ADL benchmark recommendation is well-known -- RESOLVED (-2 residual, down from -8)

**Changes made**: Section 5.4 (line 550) now reads:

> "This recommendation is consistent with and reinforces the qualitative guidance of Blackwell & Glynn (2018), who showed that the CET (beta_1) is consistent in the ADL under linearity (p. 1073), and of Imai & Kim (2021), who recommend ADL + FE as the parametric solution for dynamic panel identification (Table 1, rows 2--4). Our contribution is to provide (a) a quantitative diagnostic formula for the change caused by specification choices, and (b) systematic Monte Carlo evidence across 238 DGP configurations---spanning collider, dual-role, and mediator cases with nonlinearities and feedback---that the ADL benchmark works uniformly for these cases."

The conclusion (line 846) similarly states: "This recommendation reinforces the qualitative guidance of Blackwell & Glynn (2018) and Imai & Kim (2021); our contribution is the quantitative diagnostic formula and systematic Monte Carlo validation..."

**Assessment**: This is the correct framing. The prior literature is explicitly credited, the contribution is clearly identified as incremental (diagnostic formula + MC validation + timing insight for mediators), and the language avoids claiming discovery of a known result.

**Residual concern (-2)**: The phrase "the evidence converges on a single recommendation" (line 504) still reads as if the paper is arriving at a novel recommendation through its own evidence, rather than confirming a known one. Minor.

---

### M2. "Foreign collider bias" adds no analytical content -- RESOLVED (-2 residual, down from -8)

**Changes made**: Line 223 now reads:

> "We use the term *foreign collider bias* descriptively, not analytically---it denotes the practical difficulty that the causal knowledge needed to identify a collider often resides in literatures outside the researcher's primary domain."

The paragraph continues: "The underlying causal phenomenon is standard collider bias; what 'foreign' adds is a practical warning about the disciplinary boundaries that make such colliders easy to miss."

**Assessment**: The claim is now appropriately modest. The paper explicitly disclaims any analytical novelty in the concept and frames it as a descriptive label for a practical pattern. The examples (civil war/democracy, democratization/GDP, media coverage) remain vivid and pedagogically effective. This is exactly the right framing.

**Residual concern (-2)**: The section heading remains "## Foreign Collider Bias" as a standalone subsection, which gives it more structural prominence than the text warrants. Given the explicit disclaimer, this is minor.

---

### M3. Empirical applications: selection bias and GDP dominance -- PARTIALLY RESOLVED (-4 residual, down from -8)

**What the user stated**: "Already corrected."

**Assessment**: The manuscript has improved on two of the three sub-issues from Round 1:

1. **GDP dominance -- ADDRESSED.** Line 641 now explicitly states: "Third, GDP per capita and related economic variables dominate the collider candidates across studies, consistent with their dual role as common effects of political treatments and socioeconomic outcomes---and illustrating why the DAG-based classification step is essential before interpreting the formula." This directly addresses the concern.

2. **Cross-study caveat -- ADDRESSED.** Line 645 adds: "A caveat on cross-study comparisons: standard errors vary substantially across studies [...] The |IVB/SE| benchmark is most informative *within* a given study [...] and should be interpreted with caution when comparing across studies with very different precision levels."

3. **Selection on availability -- NOT ADDRESSED.** The text at line 557 states the selection criterion ("with the requirement that replication data and a TWFE or panel FE specification be publicly available") but does NOT add a caveat acknowledging that this selects for well-executed studies whose authors made data available. Studies with sloppy control selection (where IVB might be larger) are less likely to have publicly available replication data.

**Residual concern (-4)**: The selection-on-availability caveat is still absent. The conclusion (line 846) still presents "median |IVB/SE| approximately 0.13" without qualifying the sample's representativeness. A single sentence would suffice, e.g.: "Because our sample is limited to studies with publicly available replication data, it may skew toward best-practice studies with carefully chosen controls."

---

## Remaining Issues from Round 1 (not claimed as fixed)

### m1. "Bias" vs "change" inconsistency -- UNCHANGED (-3)

The name "Included Variable *Bias*" still frames the result as bias throughout, while Sections 4.5 and 6.2 argue it is not always bias. The Caveats section (4.5) does the heavy lifting, and the conclusion (line 844) uses "the arithmetic difference between specifications." This is adequately managed within the text, but the terminological tension persists in the formula's name.

**Status**: Acknowledged in the text; not a blocking issue. Keeping -3.

---

### m2. "57 study-control combinations" does not match CSV -- UNCHANGED (-3)

The paper still states "57 study-control combinations" in three locations (lines 559, ~634, 1167). The `standardized_ivb_metrics.csv` file has 56 lines (55 data rows + 1 header = 55 study-control combinations). This factual error was flagged in Round 1 and has not been corrected.

**Status**: Still incorrect. A replicator who counts the CSV rows will notice the discrepancy. Keeping -3.

---

### m3. Appendix E describes simulations from a previous paper version -- UNCHANGED (-3)

Appendix E (lines 985-995) still describes three DGPs from the prior paper version:
- DGP 1: Cross-section, N=10,000, gamma_1=0.6, gamma_2=0.4
- DGP 2: ADL panel, N=200, T=20, delta_d=0.6, delta_y=0.4
- DGP 3: Civil War DGP, N=200, T=20

None of these correspond to the simulations cited in Section 5. Section 5.1 uses mechC_adl (N=100, T=30, exogenous binary D). Section 5.2 uses the overcontrol simulations (N=100 or N=200, T=30). Section 5.3 uses NL and feedback sims. The appendix still references `sim_ivb_completa.R` as the companion file.

**Status**: Still incorrect. A replicator reading the appendix will not find the parameters described there in any of the paper's cited simulations. Keeping -3.

---

### m4. No uncertainty quantification for empirical IVB estimates -- UNCHANGED (-3)

Appendix F derives the delta-method variance and the Cauchy-Schwarz upper bound for SE(IVB) but does not compute either for any of the six applications. The Rogowski case (IVB/SE = 2.11) -- the only case where the IVB is consequential -- still has no confidence interval. The reader cannot assess whether IVB/SE = 2.11 is statistically distinguishable from zero.

**Status**: Unchanged. Keeping -3.

---

### m5. DID bridge underdeveloped -- UNCHANGED (-3)

The DID comparison remains in two short paragraphs (lines 532, 848) without engagement with Caetano & Callaway (2024) or Lin & Zhang (2022). The paper cites Caetano et al. (2022) as "active research" (line 63), and the claim is modestly stated ("a structural advantage"). The bridge is more asserted than developed, but the restraint in claims partially compensates.

**Status**: Unchanged. Keeping -3.

---

### m6. "One-eighth SE" framing -- IMPROVED (-1, down from -3)

The conclusion (line 846) still leads with "median |IVB/SE| approximately 0.13" as a headline finding. However, the cross-study caveat at line 645 and the GDP-dominance acknowledgment at line 641 now contextualize this claim within the body. The gap is that the conclusion does not repeat these caveats. Reducing from -3 to -1 because the body text now provides adequate context.

---

## New Vulnerabilities from Edits

### N1. Marginal contribution claim may invite skepticism (-2, new)

The corrections to C1 and M1 were necessary and well-executed, but they create a new rhetorical challenge. The paper now explicitly states:
- The formula is "well known in econometrics" (line 244)
- The ADL benchmark "reinforces the qualitative guidance of BG and IK" (line 550)
- The contribution is "repackaging as an operational diagnostic" (line 244) and "systematic Monte Carlo evidence" (line 550)

A referee may ask: is repackaging a textbook identity + confirming a known recommendation + six empirical illustrations enough for a standalone article? The paper's strongest unique contribution -- the timing insight for mediators (Section 5.2, where Z_{t-1} separates confounding from over-control in the mediator-plus-confounder case) -- is presented as one simulation result among several rather than elevated as a headline contribution. Elevating this insight more prominently in the abstract and introduction would strengthen the case.

---

### N2. Proposition labels for known results -- COSMETIC (-1, new)

The paper retains "Proposition" (Propositions 1, 2, 3) for results explicitly acknowledged as algebraic identities or direct applications of FWL. This creates a mismatch between the formal apparatus (which signals novelty) and the text (which disclaims it). "Observation," "Fact," or "Result" would better match. This is cosmetic -- the text manages expectations correctly -- but it is a minor inconsistency that a careful referee may note.

---

## Strengths (carried from Round 1, still valid)

1. **The timing insight for mediators** (Section 5.2) remains the paper's strongest and most original simulation contribution. The three-way comparison (ADL total / ADL bad / ADL safe) and the mediator-plus-confounder extension are clean and actionable. The result that Z_{t-1} simultaneously removes confounding and avoids over-control is genuinely useful for applied researchers.

2. **The Rogowski application** remains honest and illuminating -- the paper does not hide its most challenging case and uses it to illustrate the limits of the formula.

3. **The IVB/OVB comparison table** is pedagogically effective.

4. **The practical recipe** (Section 4.6) is well-structured and actionable.

5. **The explicit attribution to BG and IK** (new in this version) strengthens the paper's credibility by demonstrating awareness of the field and intellectual honesty about the incremental nature of the contributions.

6. **The "foreign collider bias" disclaimer** (new in this version) is a model of how to handle a descriptive concept without overclaiming.

7. **The Caveats section (4.5)** is unusually forthcoming -- stating explicitly that the formula cannot distinguish collider from confounder from mediator without a DAG.

---

## Score Calculation

```
Starting score: 100

Round 1 issues (re-evaluated):
  C1. Tautology framing:            -5  (was -15, largely resolved)
  C2. DGP count:                     0  (was -15, fully resolved)
  M1. ADL = BG/IK:                  -2  (was -8, properly attributed)
  M2. Foreign collider bias:        -2  (was -8, now descriptive)
  M3. Selection bias:               -4  (was -8, partially resolved)
  m1. Bias vs change:               -3  (unchanged)
  m2. 57 combinations:              -3  (unchanged, factual error)
  m3. Appendix E:                   -3  (unchanged, factual error)
  m4. No SE(IVB):                   -3  (unchanged)
  m5. DID bridge:                   -3  (unchanged)
  m6. One-eighth SE:                -1  (was -3, improved by body caveats)

New vulnerabilities:
  N1. Marginal contribution:        -2
  N2. Proposition labels:           -1

Subtotal deductions: -32

Mitigants applied:
  C1: Text framing is now well-calibrated, Proposition label is cosmetic: +3
  M1: BG/IK attribution is precise and strengthens credibility: +3
  M2: Disclaimer is well-crafted and pedagogical value is preserved: +1
  M3: GDP dominance and cross-study caveats improve empirical section: +2
  Timing insight for mediators is genuinely original: +3
  Rogowski honesty demonstrates intellectual integrity: +2

Subtotal mitigants: +14

Net deductions: -32 + 14 = -18

Final: 100 - 18 = 82
```

**Score: 82/100 -- APROVADO (threshold: 80/100)**

---

## Summary

The manuscript has improved substantially from Round 1 (66 -> 82). Both Critical issues are resolved: C1 (tautology) through careful rhetorical reframing that acknowledges the decomposition's textbook origin, and C2 (DGP count) through factual correction to 238. Two of the three Major issues are resolved: M1 (ADL benchmark) now explicitly credits BG and IK, and M2 (foreign collider bias) is properly disclaimed as descriptive. M3 (empirical selection) is partially resolved -- GDP dominance and cross-study caveats are addressed, but the selection-on-availability bias remains unacknowledged.

Six minor issues from Round 1 remain unaddressed (m1-m5, partially m6). Two are factual errors that should be fixed before submission: m2 (57 vs 55 study-control combinations) and m3 (Appendix E describes wrong simulations). The others are improvements that would strengthen the paper but are not blocking.

Two new minor vulnerabilities (N1, N2) arise from the edits: the marginal contribution claim is now very honestly stated, which is correct but may invite referee skepticism, and the Proposition labels are slightly inconsistent with the disclaimer language.

---

## Priority Actions (pre-submission)

1. **Fix m2** (5 min): Verify actual count from CSV (55 data rows) and correct "57" in lines 559, ~634, 1167.

2. **Fix m3** (30 min): Rewrite Appendix E to describe the simulations actually cited in Section 5 (mechC_adl N=100 T=30; overcontrol N=200 T=30; NL collider; feedback Y->D).

3. **Add selection caveat** (5 min, M3 residual): One sentence in Section 6 intro or conclusion acknowledging that replication-data availability may bias the sample toward well-executed studies.

4. **Elevate mediator timing insight** (10 min, N1): Add a sentence in the abstract and/or introduction highlighting the Z_{t-1} timing insight for mediator-plus-confounder cases as a distinct contribution.

5. **Consider renaming "Proposition" to "Fact" or "Result"** (5 min, N2 + C1 residual): Cosmetic but would eliminate the last mismatch between formal apparatus and stated framing.

6. **Compute SE(IVB) for Rogowski** (20 min, m4): The Cauchy-Schwarz upper bound from Appendix F would strengthen the one case where IVB is consequential.

Items 1-3 should be fixed before submission. Items 4-6 are recommended improvements.
