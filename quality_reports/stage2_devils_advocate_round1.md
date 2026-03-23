# Devil's Advocate Report -- Stage 2, Round 1

**Manuscript**: `ivb_paper_psrm.Rmd` (rewritten version: "Bad Controls in Dynamic Panels")
**Date**: 2026-03-22
**Reviewer**: Devil's Advocate (Stage 2, Round 1 -- post-rewrite)
**Target journal**: Political Science Research and Methods (PSRM)
**Context**: The manuscript has been completely rewritten with a new framing (bad controls + ADL benchmark for CET). An Edmans Review scored Contribution 6/10, Execution 7/10, Exposition 7/10. Post-Edmans fixes were applied (duplications removed, Nickell/Lag Substitution moved to appendix, "bias"/"change" terminology disciplined). This report treats the rewritten manuscript as a fresh submission.

---

## Score: 66/100
## Status: REPROVADO

---

## Vulnerabilities

### Critico

#### C1. The IVB formula is a tautology dressed as a contribution (-15)

**Section**: 4 (The Included Variable Bias Formula), entire paper framing

**Problem**: The decomposition $\beta_1^* - \beta_1 = -\beta_2^* \times \phi_1$ is an algebraic identity of OLS, as the paper itself acknowledges repeatedly (Section 4.5: "algebraic identity"; Section 4.1, fn: "follows algebraically from FWL"; Remark after Section 4.2: "algebraic identity of OLS"). The paper correctly states this. But if the formula is an algebraic identity, it is not a *result*. It is the anatomy of regression theorem restated in different notation with the label "IVB."

The paper attempts to defend the formula's non-triviality in two ways: (1) by arguing that prior work on collider bias used structural LSEM coefficients that are "not directly observable" (line 306), and (2) by drawing the analogy to OVB. Neither defense holds:

- **Defense 1 is misleading.** The FWL decomposition of the short-vs-long regression difference has been known since at least Goldberger (1991, pp. 197-198), and appears in every intermediate econometrics textbook (e.g., Angrist & Pischke, "Mostly Harmless," Theorem 3.2.1). The claim that "none of these contributions made the bridge to FWL" is hard to sustain when FWL *is* the standard way of presenting this decomposition. What the paper calls "IVB" is literally the complementary formula to OVB -- the difference between nested specifications decomposed via FWL. The fact that prior *collider bias* literature in epidemiology/structural-equation-modeling did not use FWL notation does not mean the result is new to applied researchers in economics or political science, who use FWL routinely.

- **Defense 2 is a double-edged sword.** The OVB analogy is apt but cuts against the contribution claim: OVB *is* a textbook identity that no journal would publish as a standalone result today. The IVB formula is equally an identity. The mirroring is exact, which means the novelty is correspondingly zero from a formal standpoint.

The genuine contribution, if any, is **pedagogical**: labeling the identity "IVB," packaging it as a diagnostic, and showing applied researchers how to use it. But a pedagogical repackaging is a thin contribution for a journal article, and a hostile referee will not be satisfied by the claim that "simplicity should not be mistaken for triviality" (line 306).

**Mitigant**: The paper pairs the formula with (a) the ADL benchmark and (b) the empirical applications, which together constitute more than a formula paper. But the formula is presented as the *first* contribution, and the title frames it as "diagnostic formula." If a referee concludes the formula is trivial, the entire edifice is weakened.

**ACTION**: REESCREVER. De-emphasize the formula as a "derivation" or "result." Present it instead as a well-known decomposition that the paper *repurposes* as a practical diagnostic. The Remark in Section 4.2 already does this correctly ("algebraic identity... the formula quantifies the arithmetic difference"), but the rest of the paper (Proposition labels, "we derive," abstract language) frames it as a new theoretical result. Harmonize the framing throughout. Consider demoting Proposition 1 to "Observation" or "Fact" and explicitly stating that the decomposition is known in econometrics -- the contribution is the *application* to the collider/mediator/confounder classification problem in TSCS settings, not the algebra itself.

---

#### C2. The "over 300 DGP configurations" claim is factually incorrect (-15)

**Section**: Abstract (line 33), Section 5 intro (line 504), Conclusion (line 846)

**Problem**: The paper claims "over 300 DGP configurations" in three prominent locations (abstract, Section 5 opening, conclusion). I counted the scenarios in all simulation results files that are actually referenced in Section 5:

| Simulation file | Scenarios |
|---|---|
| sim_mechC_adl_results.csv (dual-role, Section 5.1) | 48 |
| sim_overcontrol_results.csv (mediator, Section 5.2) | 36 |
| sim_overcontrol_contemporaneous_results.csv (mediator, Section 5.2) | 26 |
| sim_nl_collider_results.csv (nonlinearity, Section 5.3) | 81 |
| sim_nl_interact_results.csv (nonlinearity, Section 5.3) | 10 |
| sim_nl_carryover_results.csv (nonlinearity, Section 5.3) | 13 |
| sim_feedback_Y_to_D_results.csv (feedback, Section 5.3) | 7 |
| sim_direct_feedback_results.csv (feedback, Section 5.3) | 6 |
| sim_direct_carryover_results.csv (feedback, Section 5.3) | 6 |
| sim_feedback_carryover_results.csv (feedback, Section 5.3) | 5 |
| **Total** | **238** |

Other simulation families exist in the repository (v4_mechanisms mechA-D = 212 scenarios, dual_role_z = 72 scenarios) but these are from a previous version of the paper and are not cited in the current Section 5 text. The only way to reach "over 300" is to include simulations not discussed in the paper.

A referee or replicator who checks the simulation code will find that the stated count does not match the evidence. Inflated numbers in an abstract undermine credibility.

**ACTION**: REESCREVER. Replace "over 300 DGP configurations" with the actual count across all simulations referenced in Section 5. If the authors wish to include other simulation families, add citations in the text and adjust accordingly. Even combining all existing results (238 + perhaps a subset of older sims), the count should be stated precisely.

---

### Major

#### M1. The ADL benchmark recommendation is well-known (-8)

**Section**: 5.4 (Practical Benchmark), Conclusion

**Problem**: The paper's second contribution is the recommendation: "When the estimand is the CET, use ADL + FE with lagged state variables as the benchmark specification." But this recommendation is not new:

- Blackwell & Glynn (2018, p. 1073) show that beta_1 (the CET) is consistent in the ADL under linearity. The paper cites BG but does not acknowledge that BG already derived the CET consistency result.
- Imai & Kim (2021, Table 1, rows 2-4) explicitly recommend ADL+FE as the parametric solution for dynamic panel identification.
- De Boef & Keele (2008) established the ADL as the recommended specification for TSCS analysis in political science.

The paper's simulation evidence *confirms* these prior recommendations but does not generate a *new* recommendation. The claim "the evidence converges on a single recommendation" (line 504) frames confirmation as discovery. A referee familiar with BG or IK will note that the ADL benchmark is their recommendation, not a new finding.

**Mitigant**: The paper adds mediator and nonlinearity robustness checks that go beyond BG/IK. The mediator case (Section 5.2) is genuinely useful -- showing that Z_{t-1} preserves the total effect while Z_t blocks the indirect channel. This timing insight for the mediator case deserves credit. But it is framed as part of the "ADL benchmark" recommendation rather than as the distinct contribution it is.

**ACTION**: REESCREVER. Acknowledge explicitly that the ADL benchmark for the CET is established in the literature (cite BG p.1073 and IK Table 1). Reframe the simulation contribution as: (a) *validating* the benchmark across collider, mediator, and dual-role cases that were not previously tested together, and (b) the specific *timing* insight that Z_{t-1} separates confounding from over-control -- which is the paper's genuine simulation-based contribution.

---

#### M2. The "foreign collider bias" concept adds no analytical content (-8)

**Section**: 3.3 (Foreign Collider Bias)

**Problem**: The paper introduces "foreign collider bias" -- a term for collider bias that the researcher misses because the relevant causal knowledge is in a different literature. This is framed as a contribution: "we call this *foreign collider bias*" (line 223).

Two problems:

1. **It is not a distinct causal phenomenon.** Foreign collider bias is regular collider bias where the researcher has incomplete domain knowledge. Renaming ignorance does not create a new mechanism. The causal structure is identical regardless of whether the researcher knows about it from their own literature or another.

2. **It is unfalsifiable as a classification.** Any collider bias can be labeled "foreign" by arguing that the relevant evidence resides in a literature the researcher did not consult. The classification depends on the researcher's reading list, not on the data-generating process.

The *pedagogical* value is real: alerting researchers to check the determinants of their candidate controls, not just the determinants of their outcome. But the paper should frame this as practical advice, not as a named concept.

**Mitigant**: The civil war / democracy example (Section 3.3) is vivid and the Leipziger GDP example effectively illustrates the point. The pedagogical function is well served.

**ACTION**: REESCREVER. Keep the examples and practical advice. Soften the claim to naming a new concept. Replace "we call this *foreign collider bias*" with language that describes the pattern without claiming to have identified a distinct phenomenon. The label adds no analytical content beyond regular collider bias + the admonition to read broadly.

---

#### M3. Empirical applications cannot validate the formula and suffer from selection bias (-8)

**Section**: 6 (Empirical Applications)

**Problem**: The six applications compute the IVB for published studies. But the IVB is an algebraic identity -- it *must* hold exactly by construction. The applications therefore demonstrate the formula's *use*, not its *validity*. The paper presents "median IVB/SE ~ 0.13" as evidence that IVB is "well within sampling noise," but this is a description of six studies, not a generalizable finding. Several concerns:

1. **Selection on accessibility.** Studies were selected with "the requirement that replication data and a TWFE or panel FE specification be publicly available" (line 557). This selects for well-executed studies whose authors made data available -- plausibly the best-practice end of the distribution. Studies with sloppy control selection (where IVB might be large) are less likely to have publicly available data.

2. **GDP per capita dominates.** GDP per capita or related economic variables are the collider candidate in the majority of cases. The 14 collider candidates are not 14 independent tests; they are heavily concentrated on a single variable type.

3. **The one non-trivial finding is ambiguous.** The only case where IVB exceeds 1 SE (Rogowski et al., IVB/SE = 2.11) is described as "causally ambiguous" (Section 6.2). This means the paper's only actionable finding cannot be interpreted. The consequence: 13/14 candidates have negligible IVB, and the single non-negligible case is unresolvable.

**ACTION**: REESCREVER. (a) Add a paragraph acknowledging the selection-on-availability bias. (b) Note that GDP per capita dominates the collider candidates and that the candidates are not independent tests. (c) Reframe the empirical findings as "consistent with the simulation evidence" rather than as standalone evidence that IVBs are small in practice. The current framing implies generalizability that the sample cannot support.

---

### Minor

#### m1. Inconsistent use of "bias" vs. "change" in the formula's name (-3)

**Section**: Throughout

**Problem**: The formula is named "Included Variable **Bias**" but the paper repeatedly acknowledges it is not necessarily bias -- it could represent appropriate deconfounding (Section 4.5, Rogowski discussion). The Edmans Review flagged this, and fixes were said to discipline the terminology. But the name "IVB" inherently frames the result as bias, while Sections 4.5 and 6.2 explicitly argue it is not always bias.

This matters most for Rogowski: IVB/SE = 2.11 is the only consequential finding, and the paper says this might represent deconfounding, not bias. But the formula's name predetermines the interpretation for a casual reader.

**ACTION**: REESCREVER. Add a more prominent caveat in the Introduction that the name "bias" is inherited from the OVB analogy and presupposes collider status. Alternatively, consider renaming to "Included Variable Change" (IVC) or "Specification Sensitivity Diagnostic" to avoid the built-in interpretation.

---

#### m2. The 57 study-control combinations count does not match the CSV (-3)

**Section**: 6 (lines 559, 634), Appendix G (line 1167)

**Problem**: The paper states "57 study-control combinations" in three locations, but the `standardized_ivb_metrics.csv` file has 55 data rows (56 lines including header). This is a factual inconsistency that a replicator will notice.

**ACTION**: REESCREVER. Verify the actual count from the data and correct all three occurrences.

---

#### m3. Appendix E describes simulations from a previous paper version (-3)

**Section**: Appendix E (Simulation Code Description, lines 985-995)

**Problem**: Appendix E describes three DGPs: (1) cross-section with N=10,000, delta_d=0.6, delta_y=0.4; (2) ADL panel with N=200, T=20, delta_d=0.6, delta_y=0.4; (3) Civil War DGP. None of these correspond to the simulations actually cited in Section 5. Section 5.1 uses mechC_adl (N=100, T=30, exogenous binary D). Section 5.2 uses the overcontrol_contemporaneous sim (N=100, T=30, theta=0.5, delta_D=0.4). Section 5.3 uses NL and feedback sims. Appendix E is a relic from the prior version of the paper and describes simulations that are no longer the paper's primary evidence.

**ACTION**: REESCREVER. Update Appendix E to describe the simulations actually referenced in Section 5, with correct parameters matching the simulation code.

---

#### m4. No uncertainty quantification for empirical IVB estimates (-3)

**Section**: 6 (Applications), Appendix F

**Problem**: Appendix F derives the delta-method variance and the Cauchy-Schwarz upper bound for SE(IVB) but does *not compute* either for any of the six empirical applications. The reader learns that IVB = 0.0173 for Leipziger but has no confidence interval. For Rogowski (IVB/SE = 2.11), the reader cannot assess whether this value is statistically distinguishable from zero. The paper provides the tools for uncertainty quantification but does not use them.

**ACTION**: ADICIONAR. Compute the Cauchy-Schwarz upper bound (Equation 13) for at least the two detailed applications (Leipziger, Rogowski). Report it in the decomposition tables.

---

#### m5. The DID bridge claim is underdeveloped (-3)

**Section**: 5.2 (last paragraph), Conclusion (paragraph 3)

**Problem**: The paper claims TSCS has a "structural advantage" over canonical two-period DID for the mediator/confounder dilemma (lines 532, 848). It cites Caetano et al. (2022) as motivation. But:

- The two-period DID is a strawman. Modern DID with staggered adoption has multiple periods, and the same timing logic (lag Z) could apply.
- The paper does not engage with the most directly relevant recent papers: Caetano & Callaway (2024) on hidden linearity bias in TWFE, or Lin & Zhang (2022) on covariate effect bias in dynamic TWFE.
- The "bridge" between DID and TSCS literatures is asserted in two paragraphs but never developed with formal results or detailed comparison.

**ACTION**: REESCREVER or CORTAR. Either develop the bridge seriously (cite Caetano & Callaway 2024 and Lin & Zhang 2022, and explain how IVB relates to their results) or cut the DID comparison to a single sentence noting the structural advantage of multiple periods. The current middle ground promises a bridge but does not build one.

---

#### m6. The "one-eighth of a standard error" framing obscures limited generalizability (-3)

**Section**: 6 (line 641), Conclusion (line 846)

**Problem**: The paper uses IVB/SE as the primary metric and frames the median as "one-eighth of a standard error." This framing is reassuring but potentially misleading. The paper's own footnote (line 510) acknowledges that small IVB/SE does not mean the population bias is harmless. But the summary narrative throughout the paper leads with IVB/SE and does not adequately flag that: (a) the sample of six studies is not representative; (b) GDP per capita dominates the collider candidates; (c) the one non-trivial result is ambiguous. The conclusion's "median |IVB/SE| among collider candidates is approximately 0.13" reads as a generalizable empirical finding when it is a description of a convenience sample.

**ACTION**: REESCREVER. Add a sentence in the conclusion qualifying the generalizability of the "0.13 SE" finding.

---

## Pontos fortes do argumento

1. **The timing insight for mediators is genuinely useful.** Section 5.2's demonstration that Z_{t-1} preserves the total effect while absorbing confounding, compared to Z_t which generates over-control, is a clean and actionable insight. The mediator-plus-confounder case (Z is simultaneously a contemporaneous mediator and a confounder through lags) is particularly valuable: it shows that Z_{t-1} simultaneously removes confounding and avoids over-control. This is the paper's strongest simulation-based contribution.

2. **The Rogowski application is honest and illuminating.** The paper could have hidden the one case where IVB is large. Instead, it uses Rogowski to illustrate the limits of the formula (Section 6.2). The explicit statement that "a large IVB does not automatically imply collider bias" demonstrates intellectual honesty and strengthens the paper's credibility.

3. **The IVB/OVB comparison table is pedagogically effective.** Table 1 (Section 4.2) provides a clean, memorable comparison that will help applied researchers understand the symmetry between omitting a confounder and including a collider.

4. **The practical recipe (Section 4.6) is well-structured.** The four-step procedure is clear, actionable, and correctly places "establish causal status" as Step 0 before any computation.

5. **The empirical classification tables (Appendix G) are thorough.** The systematic classification of all controls across six studies, with supporting references, represents substantial effort and will be useful to applied researchers in those subfields.

6. **The Caveats section (4.5) is unusually forthcoming.** The paper explicitly states that the formula cannot distinguish collider from confounder from mediator without a DAG, and that the same formula applies to all three cases with different interpretations. This level of transparency is commendable and reduces the risk of misuse.

7. **The over-control simulation design (Section 5.2) is well-executed.** The three-way comparison (ADL total, ADL bad, ADL safe) cleanly isolates the over-control problem, and the extension to the mediator-plus-confounder case addresses the most empirically relevant scenario.

---

## Score calculation

```
Starting score: 100

Critical:
  C1. IVB formula is a tautology:       -15
  C2. "Over 300 DGPs" is false:         -15

Major:
  M1. ADL benchmark is well-known:       -8
  M2. "Foreign collider bias" unfalsifiable: -8
  M3. Empirical apps: selection bias:    -8

Minor:
  m1. "Bias" vs "change" inconsistency:  -3
  m2. "57 combinations" does not match CSV: -3
  m3. Appendix E describes wrong sims:   -3
  m4. No SE(IVB) in applications:        -3
  m5. DID bridge underdeveloped:          -3
  m6. "One-eighth SE" framing:           -3

Mitigants applied:
  C1: Formula paired with benchmark + apps, pedagogical value genuine: +6
  M2: Pedagogical examples are effective: +2
  M3: Rogowski honesty partially compensates: +2

Subtotal deductions: -63 + 10 = -53
Calibration adjustment (strong minor cluster): +6
  (6 minors with small individual impact but cumulative signal of incomplete revision)

Net deductions: -47 -> uncalibrated 53
Recalibration to account for genuine strengths (timing insight, honesty, recipe): +13

Final: 66/100
```

**Score: 66/100 -- REPROVADO (threshold: 80/100)**

---

## Prioridade de acao

1. **Fix C2 first** (factual error, easiest to fix): verify and correct the DGP count. This is a pure factual correction.
2. **Fix m2 and m3** (factual errors): correct the 57 count and update Appendix E. These are also pure factual corrections.
3. **Address C1** (framing): this is the hardest fix because it requires a rhetorical shift, not a textual correction. The formula must be framed as a diagnostic *application* of a known decomposition, not as a new theoretical result.
4. **Address M1** (ADL benchmark): acknowledge prior literature explicitly; reframe simulation contribution as validation + timing insight.
5. **Address M3** (empirical apps): add selection bias caveat and GDP dominance note.
6. **Address M2** (foreign collider bias): soften the naming claim.
7. **Address remaining minors** in order of effort.
