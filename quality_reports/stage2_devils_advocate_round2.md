# Stage 2: Devil's Advocate Report (Round 2)

**Reviewer**: Claude Code (Devil's Advocate Agent)
**Date**: 2026-02-10
**Target Journal**: Political Science Research and Methods (PSRM)
**Manuscript**: "Included Variable Bias: A Formula for Collider Bias in Cross-Sectional and Time-Series Cross-Sectional Regressions"
**Authors**: Galdino, Moreira, Dolleans
**Round 1 Score**: 16/100 (REPROVADO)

---

## 1. Verification of Implemented Fixes

### C1 (Critical, -20): Related Work on Collider Bias Quantification
**Status: RESOLVED**

The authors added a new subsection "Related Work on Collider Bias Quantification" at the end of Section 2 (lines 103-108). This subsection:
- Cites Greenland (2003) on collider-stratification bias in linear SEMs.
- Cites Pearl (2013) on path-tracing bias formulas.
- Cites Ding and Miratrix (2015) on M-bias closed-form expressions.
- Cites Gaebler et al. (2024) on the exact term "included variable bias" in disparate impact estimation.
- Clearly articulates three dimensions of novelty: (i) the OVB/IVB pedagogical parallel, (ii) the extension to ADL/TSCS models and the "foreign collider bias" concept, and (iii) the practical three-step recipe.

All four references are present in `references.bib` with complete bibliographic information. The subsection is well-written, appropriately positioned, and honestly differentiates the contribution from prior work. **This fix is substantively adequate.** The previous -20 deduction is removed.

### M1 (Major, -10): Algebraic Identity / Overstated Novelty
**Status: RESOLVED**

The authors added a paragraph after Proposition 1 (lines 313-314) that reads:

> "We note that Proposition 1 follows algebraically from the Frisch-Waugh-Lovell theorem and the standard short-versus-long regression decomposition. Our contribution lies not in the algebra per se, but in (i) naming and packaging this result as a diagnostic tool that mirrors OVB, (ii) making the direct estimability of both components explicit, and (iii) extending the result to the ADL models prevalent in TSCS research."

This is an honest and well-calibrated acknowledgment. It does not undermine the paper's value while being transparent about what is and is not new. **This fix is substantively adequate.** The previous -10 deduction is removed.

### M3 (Major, -10): Linearity Limitation Underplayed
**Status: RESOLVED**

The Conclusion (lines 798-799) now contains an expanded discussion that:
- Explicitly acknowledges the civil war literature uses logit/probit specifications.
- States that FWL does not hold for nonlinear link functions.
- Notes that the IVB formula "as stated does not apply to logistic or probit regression."
- Suggests future work on whether linear IVB provides a useful approximation when outcomes are rare.
- Frames this as a genuine scope limitation rather than a minor caveat.

This is a substantial improvement over the Round 1 version. The discussion is honest and appropriately scoped. **This fix is substantively adequate.** The previous -10 deduction is removed.

### M4 (Major, -10): Missing Discussion of When the Formula Can Mislead
**Status: RESOLVED**

The authors added a new subsection "Interpretation Caveats" (Section 4.6, lines 455-461) that:
- Explicitly states the decomposition is an "algebraic identity" that holds regardless of Z's causal role.
- Explains that the product will be non-zero for confounders and mediators too.
- Clearly states that the *causal* interpretation requires prior knowledge from a DAG.
- Warns that "the formula alone cannot supply" the knowledge of whether Z is a collider.
- Emphasizes the formula "complements DAGs but cannot substitute for them."

This addresses the Round 1 concern thoroughly. The subsection is well-placed (immediately after the Practical Recipe) and clearly written. **This fix is substantively adequate.** The previous -10 deduction is removed.

### M5 (Major, -10): No Engagement with Nickell Bias
**Status: RESOLVED**

The authors added a paragraph at the end of Section 4.4 (lines 428) discussing Nickell bias:
- References Nickell (1981) explicitly.
- Explains the mechanism: demeaned lagged DV correlated with demeaned error.
- Clarifies that the IVB formula "remains an algebraic identity even in this setting" but that components "will themselves reflect both collider bias and Nickell bias."
- Warns that "separate corrections for dynamic panel bias (such as GMM estimators) may be needed."
- The Nickell (1981) reference is present in `references.bib` (lines 378-386).

This is a clear and adequate treatment for a methodology paper. It does not claim to solve the Nickell bias problem but transparently flags the interaction. **This fix is substantively adequate.** The previous -10 deduction is removed.

### m4 (Minor, -2): DAG Temporal Ordering
**Status: RESOLVED**

In Figure 3 (the collider DAG), Democracy Level is now labeled as $Dem_{t+1}$ (line 222), and the arrows flow from $CW_{t+1} \to Dem_{t+1}$ and $U \to Dem_{t+1}$ (lines 236-238). This makes the temporal ordering coherent: Civil War at $t+1$ causes Democracy at $t+1$ (contemporaneous effect, which is temporally valid). The caption (lines 241-242) is updated to reflect $Dem_{t+1}$. **This fix is substantively adequate.** The previous -2 deduction is removed.

---

## 2. Re-Assessment of Unaddressed Issues

The following issues from Round 1 were NOT addressed by the implementer. I re-assess each one in light of the overall improvement of the manuscript.

### M2 (Major, -10): Inadequate Simulations
**Status: STILL DEDUCTION-WORTHY, reduced to -5**

The simulations still validate an algebraic identity across three DGPs that all use linear-Gaussian specifications with large samples. There are no simulations with: (a) a confounder DGP to illustrate interpretive ambiguity, (b) small-sample performance, (c) nonlinear DGPs, or (d) mixed collider-confounder settings.

However, I reduce the deduction from -10 to -5 for two reasons. First, the new "Interpretation Caveats" subsection (M4 fix) now explicitly warns that the formula's algebraic identity holds for confounders too, partially addressing the interpretive concern that the simulations would have illustrated. The conceptual point is now made in prose even if not demonstrated in simulation. Second, the honest framing of the formula as an algebraic identity (M1 fix) implicitly repositions the simulations as pedagogical demonstrations rather than empirical validation, which is a more defensible framing even without additional DGPs.

That said, the simulation section remains the paper's weakest empirical component. A referee could reasonably ask: "If it is an algebraic identity, why run 500 replications? And if you run simulations, why not test something that is NOT guaranteed by construction?" At minimum, one small-sample scenario (N=50 cross-section, or N=20, T=5 panel) showing the sampling variability of the IVB estimator would substantially strengthen this section. **Deduction: -5 (reduced from -10).**

### m1 (Minor, -2): "Foreign Collider Bias" Concept Underdeveloped
**Status: STILL DEDUCTION-WORTHY, maintained at -2**

The concept remains as described in Round 1: introduced informally in Section 3.3 as a collider problem discovered by consulting "foreign" literature, but without a formal definition or proof that it is structurally distinct from ordinary collider bias. The manuscript uses it in the Conclusion (line 792) as a named concept, and the new related-work subsection lists it as a distinct contribution.

The concept functions as a useful pedagogical label, but it is never formalized. For a methods paper in PSRM, readers may expect either (a) a formal definition distinguishing foreign from domestic collider bias, or (b) a more modest rhetorical treatment. The current text falls between the two. **Deduction: -2 (maintained).**

### m2 (Minor, -2): Appendix E (Potential Outcomes Connection) Superficial
**Status: STILL DEDUCTION-WORTHY, maintained at -2**

Appendix E (lines 1027-1035) remains unchanged. It asserts that conditioning on a collider violates conditional independence and that the IVB formula "bridges the DAG-based and potential outcomes-based perspectives," but does not formally develop this bridge. There is no formal decomposition of selection bias in potential outcomes notation, no connection to the ATE or CATE, and no engagement with the Heckman selection bias framework.

The appendix occupies space without adding substantial content. For PSRM, where the potential outcomes framework is dominant, this appendix either needs to be developed into a genuine contribution or removed to avoid giving referees a target. **Deduction: -2 (maintained).**

### m3 (Minor, -2): No Standard Errors for IVB
**Status: STILL DEDUCTION-WORTHY, maintained at -2**

The paper still provides only a point estimate for IVB with no discussion of inference. The practical recipe in Section 4.5 instructs the researcher to compute $\widehat{\text{IVB}} = -\hat{\theta}^{\star} \times \hat{\pi}$, and the application in Section 6 reports a single number. There is no mention of the delta method, bootstrap, or any other approach to quantifying uncertainty in the IVB estimate.

For a diagnostic tool paper, this is a notable gap. The product of two estimated coefficients has a distribution that depends on their joint covariance structure, and the delta method derivation is standard. Even a brief remark ("inference can be conducted via the delta method or nonparametric bootstrap; we leave the formal treatment to future work") would partially address this. **Deduction: -2 (maintained).**

### m5 (Minor, -2): Missing Heuristic Citations
**Status: STILL DEDUCTION-WORTHY, reduced to -1**

Section 2 still provides only one citation for each heuristic: Dietrich (2016) for "control checking" and Hegre et al. (2001) for "confounding checking." The claim that these represent the discipline's "standard practices" would benefit from broader citation support.

However, I reduce the deduction to -1 because the problem framing is now better supported by the new related-work subsection, which demonstrates broader engagement with the literature. The heuristic claims are also relatively uncontroversial -- most applied researchers in political science would recognize these patterns. **Deduction: -1 (reduced from -2).**

### m6 (Minor, -2): Only Gaussian DGPs
**Status: STILL DEDUCTION-WORTHY, reduced to -1**

All three DGPs still use $\mathcal{N}(0,1)$ errors exclusively. Since the IVB formula is an algebraic identity under OLS, it holds regardless of the error distribution. However, the practical properties of the estimator (variance, finite-sample behavior) could differ under non-Gaussian errors.

I reduce the deduction to -1 because (a) the honest framing of the formula as an algebraic identity (M1 fix) makes the Gaussian-only simulation less problematic (the identity holds regardless), and (b) this is a minor point that could be addressed in a revision with a single additional DGP using t-distributed errors. **Deduction: -1 (reduced from -2).**

---

## 3. New Issues Identified in Round 2

### N1 (Minor, -2): Collider DAG arrows may confuse readers about contemporaneous vs. lagged effects

In the updated Figure 3 (lines 206-243), the collider structure shows $CW_{t+1} \to Dem_{t+1}$ (contemporaneous). However, in the application (Section 6, line 749), the long regression includes $Dem_{t+1}$ as a regressor for $CW_{t+1}$. This means the researcher is regressing $CW_{t+1}$ on a variable ($Dem_{t+1}$) that is *contemporaneously caused* by $CW_{t+1}$ according to the DAG. While this is precisely the collider problem the paper describes, the notation creates a subtle confusion: $Dem_{t+1}$ appears on both sides of the causal arrow and the regression equation. A brief clarifying sentence in Section 3.3 or Section 6 explaining that this is the essence of post-treatment/contemporaneous collider bias would help. **Deduction: -2.**

### S1 and S2 (Style): Passive voice and abstract length
**Status: NOT ADDRESSED but also not worsened**

These were -1 each in Round 1. The abstract remains at approximately 150 words, and passive voice is still present in places. However, neither issue has worsened, and both are within acceptable bounds for PSRM. I maintain -1 for each. **Deduction: -2 total (maintained).**

---

## 4. Score Calculation

Starting score: **100**

### Resolved Issues (no deduction)
| # | Original Severity | Original Deduction | Status |
|---|-------------------|-------------------|--------|
| C1 | Critical | -20 | RESOLVED: Related work subsection added with all four citations |
| M1 | Major | -10 | RESOLVED: Honest acknowledgment of algebraic identity |
| M3 | Major | -10 | RESOLVED: Expanded linearity limitation discussion |
| M4 | Major | -10 | RESOLVED: Interpretation Caveats subsection added |
| M5 | Major | -10 | RESOLVED: Nickell bias paragraph added with citation |
| m4 | Minor | -2 | RESOLVED: DAG temporal ordering fixed ($Dem_{t+1}$) |

### Remaining Issues (deductions applied)
| # | Severity | Deduction | Description |
|---|----------|-----------|-------------|
| M2 | Major (reduced) | -5 | Simulations still validate algebraic identity without practical stress tests |
| m1 | Minor | -2 | "Foreign collider bias" remains underdeveloped |
| m2 | Minor | -2 | Appendix E (PO connection) remains superficial |
| m3 | Minor | -2 | No standard errors or CIs for IVB estimate |
| m5 | Minor (reduced) | -1 | Heuristic citations still thin |
| m6 | Minor (reduced) | -1 | Simulations still Gaussian-only |
| N1 | Minor (new) | -2 | Contemporaneous collider notation could confuse readers |
| S1 | Style | -1 | Passive voice in places |
| S2 | Style | -1 | Abstract at upper word-count bound |

**Total deductions**: -5 + (-2 x 4) + (-1 x 3) + (-1) = -5 - 8 - 3 - 1 = **-17**

---

## 5. Final Score and Verdict

### Final Score: **83/100**

### Verdict: **APROVADO 83**

---

## 6. Assessment Summary

The manuscript has improved dramatically from Round 1 (16/100) to Round 2 (83/100). The six implemented fixes address all of the most damaging vulnerabilities:

1. **The critical literature gap is closed.** The related-work subsection engages Greenland (2003), Ding & Miratrix (2015), Pearl (2013), and Gaebler et al. (2024), and honestly articulates what the paper adds beyond these predecessors. This alone transforms the paper's positioning from "potentially scooped" to "clearly differentiated."

2. **The novelty is now honestly framed.** The acknowledgment that the formula follows from FWL, paired with the clear statement of what IS new (packaging, estimability, ADL extension, practical recipe), is exactly what a sophisticated referee would want to see.

3. **The practical limitations are now transparently discussed.** The Interpretation Caveats subsection, the Nickell bias paragraph, and the expanded linearity discussion collectively demonstrate methodological self-awareness. The paper no longer oversells the formula's applicability.

4. **The DAG is now temporally coherent.** The relabeling to $Dem_{t+1}$ fixes the backward-in-time causality issue.

The remaining deductions are all minor to moderate. The most substantive remaining weakness is the simulation section (M2, -5), which would benefit from at least one DGP that is not a tautological test of an algebraic identity (e.g., a small-sample scenario showing the variability of the IVB estimator, or a confounder DGP demonstrating the interpretive ambiguity discussed in the new Caveats subsection). The other issues (underdeveloped foreign collider concept, superficial PO appendix, missing SEs, thin heuristic citations, Gaussian-only DGPs) are individually minor and collectively manageable in a revision.

### Recommendations for Final Polish (not score-blocking)

1. **Add one non-tautological simulation**: A small-sample DGP (N=50 or N=20, T=5) showing the sampling distribution of $\widehat{\text{IVB}}$ would demonstrate practical relevance.
2. **Add a delta-method remark**: Even a footnote saying "the asymptotic variance of $\widehat{\text{IVB}}$ can be obtained via the delta method" would signal awareness.
3. **Clarify the contemporaneous collider notation**: One sentence in Section 6 explaining that $Dem_{t+1}$ is included as a regressor despite being contemporaneously caused by $CW_{t+1}$ -- and that this is precisely the problem.
4. **Either develop or cut Appendix E**: In its current form it does not add enough to justify its inclusion.
5. **Add 2-3 more citations for heuristic prevalence**: Easy lift with high payoff for the problem-framing sections.

The paper is now ready for submission. The core contribution -- a clearly framed, honestly positioned, practically useful diagnostic formula with a well-developed TSCS extension -- is solid and well-presented.
