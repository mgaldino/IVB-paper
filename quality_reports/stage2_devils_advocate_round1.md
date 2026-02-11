# Stage 2: Devil's Advocate Report (Round 1)

**Reviewer**: Claude Code (Devil's Advocate Agent)
**Date**: 2026-02-10
**Target Journal**: Political Science Research and Methods (PSRM)
**Manuscript**: "Included Variable Bias: A Formula for Collider Bias in Cross-Sectional and Time-Series Cross-Sectional Regressions"
**Authors**: Galdino, Moreira, Dolleans

---

## 1. Summary Assessment

This paper derives the "Included Variable Bias" (IVB) formula, a closed-form expression for the bias introduced when a regression erroneously includes a collider variable. The formula, IVB = -theta* x pi, mirrors the well-known Omitted Variable Bias (OVB) formula but addresses the opposite problem. The paper extends the result from cross-sectional to ADL(p,q) models via the Frisch-Waugh-Lovell theorem, validates the formula through Monte Carlo simulations, and illustrates it with a civil war example. The writing is generally clear, the structure is logical, and the mathematical derivations are correct.

The paper has genuine merit: the parallel between OVB and IVB is pedagogically elegant, the extension to ADL models is relevant for the TSCS-heavy political science audience, and the practical "three-step recipe" lowers the barrier to adoption. The civil war running example is well-chosen and illustrates foreign collider bias effectively.

However, I have significant concerns about the novelty of the core contribution, the scope of the theoretical claims, the adequacy of the simulation validation strategy, and several unstated assumptions and missing engagements with prior literature. The IVB formula is, mathematically, a direct consequence of the Frisch-Waugh-Lovell theorem and the standard OLS anatomy formula -- a fact that raises the question of whether this is a genuinely new result or an algebraic restatement of well-known regression mechanics. The simulation strategy, while confirming the formula's algebraic identity, does not probe the settings where the formula would be most practically useful or most likely to mislead. And several important limitations -- linearity, the inability to sign the bias without knowing the DAG, the relationship to existing sensitivity analysis tools -- are either underexplored or unmentioned.

---

## 2. Score Calculation

Starting score: **100**

| # | Severity | Deduction | Description |
|---|----------|-----------|-------------|
| C1 | Critical | -20 | Failure to engage with the most relevant prior literature on collider bias quantification |
| M1 | Major | -10 | The core result is arguably an algebraic identity, not a new theorem -- novelty is overstated |
| M2 | Major | -10 | Simulations validate an algebraic identity but do not test the formula's practical usefulness |
| M3 | Major | -10 | Linearity assumption is acknowledged but its severity is underplayed |
| M4 | Major | -10 | Missing discussion of when the formula can mislead (sign and magnitude interpretation) |
| M5 | Major | -10 | No engagement with the Nickell bias / dynamic panel bias problem in ADL models |
| m1 | Minor | -2 | The "foreign collider bias" concept is underdeveloped |
| m2 | Minor | -2 | Appendix E (Potential Outcomes connection) is superficial |
| m3 | Minor | -2 | No standard errors or confidence intervals for the IVB estimate |
| m4 | Minor | -2 | DAG in Figure 3 has a debatable timing/structure for Democracy |
| m5 | Minor | -2 | Missing citations for specific claims about heuristics |
| m6 | Minor | -2 | Simulation DGPs are all linear-Gaussian -- no robustness to non-normality |
| S1 | Style | -1 | Occasional passive voice overuse |
| S2 | Style | -1 | The abstract is slightly too long for PSRM guidelines |

**Total deductions**: -20 + (-10 x 5) + (-2 x 6) + (-1 x 2) = -20 - 50 - 12 - 2 = **-84**

---

## 3. Vulnerabilities by Severity

### CRITICAL VULNERABILITIES

#### C1: Failure to engage with the most relevant prior literature on collider bias quantification (-20)

**The Problem**: The paper claims to "fill a gap" by providing the first closed-form formula for the bias from conditioning on a collider. However, several prior works have derived formulas for collider bias in linear models that are closely related to, or mathematically equivalent to, the IVB formula:

1. **Greenland (2003), "Quantifying Biases in Causal Models: Classical Confounding vs Collider-Stratification Bias," Epidemiology**: This paper explicitly quantifies collider-stratification bias in causal models and compares its magnitude to classical confounding bias. It provides formulas for the bias from conditioning on a collider under linear structural equation models. This is the most directly relevant predecessor and is not cited.

2. **Ding and Miratrix (2015), "To Adjust or Not to Adjust? Sensitivity Analysis of M-Bias and Butterfly-Bias," Journal of Causal Inference**: This paper derives explicit bias formulas for conditioning on a collider in the M-bias setting under linear SEMs. The formula Badj = |abcd|/(1 - (bc)^2) for the M-bias case is a closed-form collider bias expression. Pearl (2013, response to Ding and Miratrix) also derives collider bias formulas for linear models. Neither is cited.

3. **Gaebler et al. (2024), "Mitigating Included- and Omitted-Variable Bias in Estimates of Disparate Impact"**: This paper uses the exact term "included variable bias" in its title and derives formulas for the bias from including a post-treatment variable in the context of discrimination studies. The overlap in terminology and concept is striking, and the paper is not cited.

4. **Pearl (2013), "Linear Models: A Useful Microscope for Causal Analysis"**: While cited in the bibliography, the paper does not engage with the specific bias formulas Pearl derives for conditioning on colliders in linear models (Section 4 of Pearl 2013). Pearl's paper contains expressions for collider bias that follow directly from Wright's path analysis rules.

**Why It Matters**: For a methods paper submitted to a top journal, the novelty claim is the paper's core selling point. If closely related formulas have been derived before, the paper needs to clearly articulate what is new relative to those results. The current paper does not acknowledge these predecessors, which means either (a) the authors are unaware of them, which is a literature gap, or (b) the authors believe their contribution differs, but the difference is not articulated. Either way, this is a critical vulnerability that a knowledgeable referee will identify immediately.

**How to Address It**: The authors should:
- Add a "Related Work" subsection in Section 2 or Section 4 that explicitly discusses Greenland (2003), Ding and Miratrix (2015), Gaebler et al. (2024), and Pearl (2013).
- Clearly articulate what is new: candidates include (i) the specific connection to the OVB formula as a "mirror image," (ii) the extension to ADL/TSCS models, (iii) the practical recipe and direct estimability emphasis, and (iv) the "foreign collider bias" concept for TSCS settings.
- If the formula itself is not new, reframe the contribution around the packaging, the TSCS extension, and the practical diagnostic tool.

---

### MAJOR VULNERABILITIES

#### M1: The core result is arguably an algebraic identity, not a new theorem -- novelty is overstated (-10)

**The Problem**: The IVB formula, IVB = beta1* - beta1 = -beta2* x phi1, is a direct consequence of the standard OLS regression anatomy (sometimes called the "short-long regression" relationship). In any multivariate OLS regression, the difference between the bivariate and multivariate coefficient on a variable equals the negative product of the coefficient on the added variable times the auxiliary regression coefficient. This is a standard result in econometrics (see, e.g., Goldberger 1991, which is cited; Angrist and Pischke 2009, Chapter 3; Wooldridge 2010, Section 3.2).

The paper essentially names this identity "IVB" and interprets it through a causal lens (the added variable is a collider). The naming and interpretation are useful contributions, but the mathematical content of Propositions 1-3 is not new. The FWL-based extension to ADL models in Proposition 2 and 3 likewise follows mechanically from the same regression anatomy.

The paper's language -- "we derive the IVB formula," "we show that IVB = -theta* x pi" -- implies a novel derivation. The Monte Carlo simulations are described as "validating" the formula, but they are testing an algebraic identity that holds by construction in any OLS regression. The claim "this is not an approximation; it is an algebraic identity" (Section 5.4, line ~720) is correct but actually undercuts the novelty claim: if it is an algebraic identity, there is nothing to "validate."

**Why It Matters**: Referees at a top methods journal will recognize this. The contribution needs to be reframed honestly: the novelty lies not in the algebra but in the conceptual packaging, the naming, the parallel to OVB, and the practical recipe. Overselling the mathematical novelty risks a desk rejection.

**How to Address It**:
- Acknowledge explicitly that the formula follows from standard regression anatomy / FWL.
- Reframe the contribution: "While the algebra behind the IVB formula is a consequence of the well-known FWL theorem, to our knowledge it has not been named, packaged, or promoted as a diagnostic tool for collider bias in the way we propose."
- Position the simulations as *illustrative demonstrations* of the formula's application across different DGPs, not as *validation* of a result that holds by construction.

#### M2: Simulations validate an algebraic identity but do not test the formula's practical usefulness (-10)

**The Problem**: All three Monte Carlo DGPs confirm that the formula-predicted bias equals the empirical bias. Since this is an algebraic identity, this result is guaranteed by construction and contains no new information. The simulations would be more valuable if they addressed questions about the formula's *practical utility*:

1. **Can researchers use IVB to correctly diagnose collider bias in realistic scenarios where they don't know the true DGP?** The current simulations assume the researcher knows which variable is the collider. But the formula's practical value depends on scenarios where the researcher is uncertain -- and here, the formula's components (theta* and pi) have *interpretive* ambiguity: a non-zero theta* could indicate that Z is a collider, a confounder, or a mediator. The simulation should include a DGP where Z is actually a confounder (not a collider), compute the IVB formula, and show what happens -- does the formula mislead?

2. **Finite-sample performance**: How does the *estimated* IVB (using sample estimates of theta* and pi) perform in small samples? The current DGPs use n=10,000 (cross-section) and N=200, T=20 (panels). What about n=100 or N=20, T=5, which are realistic for many political science applications? How noisy is the IVB estimate?

3. **Model misspecification**: What if the true DGP is nonlinear but the researcher uses OLS? What if the collider equation has interactions? The formula assumes linearity everywhere; the simulations should test how gracefully it degrades.

4. **Multiple colliders or partial colliders**: What if Z is both a collider and a confounder (it is caused by D and by U, where U causes both D and Y)? This "mixed" case is arguably the most common in practice. The current DGPs test pure collider scenarios.

**Why It Matters**: The simulations are the paper's primary empirical evidence, but they test a tautology. Referees will ask: "What do the simulations teach us that we didn't already know from the proof?"

**How to Address It**: Add simulation scenarios that test: (a) small samples, (b) DGPs where Z is a confounder, (c) nonlinear DGPs, (d) mixed collider-confounder settings. Show the distribution of the estimated IVB across replications (not just the mean), and discuss when the formula-based diagnostic might mislead.

#### M3: Linearity assumption is acknowledged but its severity is underplayed (-10)

**The Problem**: The paper acknowledges in the Conclusion (Section 7, line ~780) that "the IVB formula is derived for linear models and may not directly apply to nonlinear specifications." This is an understatement. The vast majority of TSCS studies in political science that the paper targets -- civil war onset, regime change, democratic transitions -- use *binary* dependent variables. The outcome in the running example is "Civil War," which is inherently binary (onset vs. no onset). The models used in the referenced literature (e.g., Hegre et al. 2001) are typically logistic regressions or probit models, not OLS.

For binary outcomes with nonlinear link functions, the FWL theorem does not apply, the OLS regression anatomy breaks down, and the IVB formula does not hold. Collider bias in logistic regression has a different structure (it depends on the full joint distribution, not just bivariate moments) and can be of different magnitude and even different sign than what the linear formula predicts.

The paper uses a continuous outcome in all simulations (Civil War is simulated as a continuous variable in DGP 3), which obscures this limitation. The running example implicitly assumes a linear probability model, but this is never stated.

**Why It Matters**: If the formula does not apply to the most common specifications used in the substantive literature the paper targets, the practical value is severely limited. A referee in comparative politics or IR will immediately notice that civil war is binary.

**How to Address It**:
- State explicitly that the running example uses a linear model for illustration, and that the substantive literature uses nonlinear models.
- Add a simulation with a binary DGP (logit/probit) to show how much the IVB formula deviates from the true bias in that setting.
- Discuss whether the linear IVB formula provides a useful *approximation* to collider bias in nonlinear models, or whether a separate nonlinear IVB formula is needed.
- Alternatively, if the scope is limited to linear models, adjust the motivating examples to use continuous outcomes that are more naturally modeled linearly.

#### M4: Missing discussion of when the IVB formula can mislead in practice (-10)

**The Problem**: The paper presents the IVB formula as a diagnostic tool: "run these two regressions, multiply the coefficients, and you know the bias." But the formula's practical utility depends critically on the researcher *already knowing* that Z is a collider. The paper acknowledges this in the Conclusion ("the formula quantifies bias under the assumption that the researcher knows which variable is the collider"), but does not explore the implications.

Consider the following scenario. A researcher suspects Z might be either a confounder (Z causes both D and Y) or a collider (D and Y both cause Z). The researcher computes the IVB formula: theta* x pi is non-zero. But this product will also be non-zero when Z is a confounder! In the confounder case, theta* is non-zero because Z genuinely predicts Y, and pi is non-zero because Z correlates with D. The IVB formula cannot distinguish between "the bias I introduced by including Z" and "the bias I would remove by including Z." Without knowing the causal structure, the formula is *descriptively* useful (it decomposes the difference between the short and long regressions) but *causally* ambiguous.

This ambiguity is the Achilles heel of the practical recipe. The paper presents the recipe as if the researcher can use it to "quantify the potential damage" (Section 6), but in reality, the formula only tells you the damage *if* Z is a collider. If Z is a confounder, the "damage" is actually OVB in the short regression, and the long regression is correct.

**Why It Matters**: Applied researchers -- the paper's target audience -- are precisely the people most likely to be uncertain about whether Z is a collider or a confounder. If the paper does not clearly warn that the formula's *causal interpretation* requires knowing the DAG, it risks creating a false sense of security.

**How to Address It**:
- Add a subsection (or at least a prominent paragraph) explicitly discussing this ambiguity.
- Show with a simple example that the IVB formula returns a non-zero value even when Z is a confounder and including it is correct.
- Emphasize that the formula complements DAGs but cannot substitute for them: the DAG tells you *whether* Z is a collider, and only then does the formula tell you *how much* bias results.
- Consider presenting a decision tree: "If you know Z is a collider: use IVB. If you know Z is a confounder: use OVB. If you don't know: neither formula alone resolves the problem."

#### M5: No engagement with the Nickell bias / dynamic panel bias problem in ADL models (-10)

**The Problem**: The paper extends the IVB formula to ADL(1,0) and ADL(p,q) models, which are the standard specifications for TSCS data in political science. However, it does not mention or engage with a fundamental econometric problem in these models: Nickell (1981) bias. When the lagged dependent variable is included as a regressor in a panel with fixed effects (or even in a pooled panel with short T), the OLS estimates of *all* coefficients -- including beta, rho, and theta* -- are biased. This means the IVB formula components are themselves biased in finite samples.

The paper's simulations use N=200 and T=20 with pooled OLS (no fixed effects), which avoids the Nickell bias problem. But this is a special case that does not reflect the majority of applied TSCS research in political science, where unit fixed effects are standard (Beck and Katz 1995, Imai and Kim 2019 -- both cited). If a researcher follows the paper's recipe in a fixed-effects ADL model with moderate T, the estimated IVB will be contaminated by Nickell bias, and it is unclear whether IVB + Nickell bias decompose cleanly.

Moreover, the paper does not include unit or time fixed effects in any simulation. The practical relevance of the ADL extension is therefore undemonstrated for the most common specification.

**Why It Matters**: The paper's ADL extension is presented as a key contribution targeting the TSCS community. But the most common TSCS specification (ADL with fixed effects) introduces complications that the paper ignores entirely.

**How to Address It**:
- Discuss Nickell bias explicitly and explain how it interacts with IVB.
- Add a simulation with unit fixed effects to test whether the IVB formula still holds (it should, as an algebraic identity, but the components will be biased).
- Clarify whether the IVB formula captures only collider bias or the total difference between the short and long regressions (which may include Nickell bias contamination).
- Reference relevant TSCS methodological work: Imai and Kim (2019), Blackwell and Glynn (2018) -- which are cited but not engaged on this specific point.

---

### MINOR VULNERABILITIES

#### m1: The "foreign collider bias" concept is underdeveloped (-2)

**The Problem**: The paper introduces "foreign collider bias" as a distinct phenomenon (Section 3.3, line ~239) but does not formally define it, does not prove it is structurally distinct from ordinary collider bias, and does not show that it requires a different analytical treatment. The concept is described informally ("the collider problem arises from a causal pathway that the researcher discovers only by looking at the 'foreign' literature") but this is about the *discovery process*, not the *statistical mechanism*.

**Why It Matters**: If the concept is a genuine contribution, it needs more development. If it is just collider bias discovered through a particular literature-review pathway, the name is misleading.

**How to Address It**: Either (a) develop the concept with a formal definition and show that it has distinct statistical properties, or (b) use it more modestly as a pedagogical label for a common failure mode in applied research.

#### m2: Appendix E (Potential Outcomes connection) is superficial (-2)

**The Problem**: Appendix E claims to connect the IVB formula to the potential outcomes framework but does not go beyond stating that conditioning on a collider violates conditional independence. The connection is asserted ("the IVB formula bridges the DAG-based and potential outcomes-based perspectives") but not formally developed. There is no formal statement of how IVB relates to the ATE, CATE, or selection bias in the Heckman sense.

**Why It Matters**: The potential outcomes framework is the dominant paradigm in political science methodology. A serious bridge between the two frameworks would strengthen the paper, but a superficial one weakens it.

**How to Address It**: Either develop this appendix substantially (connecting to the formal decomposition of selection bias in potential outcomes) or remove it.

#### m3: No standard errors or confidence intervals for the IVB estimate (-2)

**The Problem**: The paper presents a point estimate for IVB (the product -theta* x pi) but never discusses inference: how uncertain is this estimate? Is it possible to construct confidence intervals for the IVB? The product of two estimated coefficients has a non-trivial distribution (even asymptotically), and the delta method or bootstrap would be needed.

**Why It Matters**: In practice, a researcher who computes IVB = -0.3 needs to know whether this could plausibly be -0.1 or -0.5. Without uncertainty quantification, the diagnostic tool is incomplete.

**How to Address It**: Derive the asymptotic standard error of IVB using the delta method (this is straightforward for the product of two OLS coefficients), or suggest a bootstrap procedure. Report confidence intervals in the application (Section 6).

#### m4: DAG in Figure 3 has debatable timing/structure for Democracy (-2)

**The Problem**: In Figure 3, Democracy Level (Dem_t) is placed at time t, and both CW_{t+1} -> Dem_t and U -> Dem_t are drawn. But CW_{t+1} causing Dem_t implies a backward-in-time causal effect (the future civil war causes current democracy). This is likely a labeling issue -- the intended structure is probably CW_t -> Dem_t or CW_{t+1} -> Dem_{t+1}. But as drawn, the DAG violates the temporal ordering that is fundamental to DAG methodology.

Looking more carefully, the arrows show CW_{t+1} -> Dem_t (red arrow from CW at t+1 to Dem at t), which implies that future civil war causes current democracy levels. This is temporally incoherent.

**Why It Matters**: The paper relies on DAGs as its primary causal reasoning tool. A temporally incoherent DAG undermines the credibility of the example.

**How to Address It**: Fix the timing. If Democracy at time t is the collider, the arrows should be from CW_t (not CW_{t+1}) and U to Dem_t. Alternatively, make Democracy at t+1 the collider, caused by CW_{t+1} and U.

#### m5: Missing citations for specific claims about heuristics (-2)

**The Problem**: Section 2 makes claims about the prevalence of "control checking" and "confounding checking" heuristics in political science, but provides only one citation for each (Dietrich 2016 for control checking, Hegre et al. 2001 for confounding checking). The claim that these are "widely used" and represent the discipline's "standard practices" should be supported more broadly.

**Why It Matters**: The problem framing depends on the claim that these heuristics are widespread. With only one example each, a referee could argue that the paper is attacking a straw man.

**How to Address It**: Add 3-5 additional citations for each heuristic, drawn from recent APSR/AJPS/JOP publications.

#### m6: Simulation DGPs are all linear-Gaussian -- no robustness to non-normality (-2)

**The Problem**: All three DGPs generate errors from N(0,1) distributions. The IVB formula holds for any distribution under OLS (it is an algebraic identity), but the practical properties -- the variance of the IVB estimator, the coverage of implied confidence intervals, the behavior in small samples -- may differ under heavy-tailed or skewed errors.

**Why It Matters**: Many political science outcomes (conflict counts, protest events, spending) have skewed or heavy-tailed distributions.

**How to Address It**: Add one simulation with t-distributed errors or heteroskedastic errors to confirm robustness.

---

### STYLE ISSUES

#### S1: Occasional passive voice overuse (-1)

**The Problem**: Several passages use passive constructions that could be more direct. For example: "variables must be indexed by time" (line ~157), "can be understood as an attempt" (line ~151), "this result is particularly relevant because" (line ~774).

**How to Address It**: Convert to active voice where possible.

#### S2: Abstract slightly long (-1)

**The Problem**: The abstract is approximately 150 words. PSRM's guidelines recommend 150 words maximum, and this abstract is at the upper bound. The phrase "We show that IVB = -theta* x pi, where both components are directly estimable from data" could be cut if space is needed.

**How to Address It**: Tighten the abstract to 120-130 words.

---

## 4. Strengths

Despite the vulnerabilities identified above, the paper has several genuine strengths that deserve acknowledgment:

1. **Pedagogically elegant framing**: The parallel between OVB and IVB is the paper's strongest conceptual contribution. Table 1 (OVB vs. IVB comparison) is excellent and will be immediately memorable for students and applied researchers. This is the kind of clean framing that gets taught in graduate methods courses.

2. **Clear, well-structured writing**: The paper is well-organized, clearly written, and avoids unnecessary jargon. The progression from heuristics (Section 2) to DAGs (Section 3) to the formula (Section 4) to validation (Section 5) to application (Section 6) is logical and well-paced.

3. **Practical recipe**: The three-step procedure in Section 4.5 is concrete and actionable. If the caveats about requiring DAG knowledge are properly addressed, this recipe has real potential to be adopted by applied researchers.

4. **TSCS extension via FWL**: While the FWL-based extension is algebraically straightforward, the explicit treatment of ADL models is useful for the PSRM audience, which works extensively with TSCS data. Making the connection explicit lowers the barrier.

5. **Well-designed running example**: The civil war / democracy / political change example is well-chosen because it is substantively important, familiar to the target audience, and naturally generates the collider structure the paper addresses.

6. **Direct estimability**: The emphasis that both IVB components are estimable from data (unlike OVB, where the omitted variable is by definition unobserved) is a legitimate and underappreciated point. The paper makes this comparison effectively.

7. **Reproducible simulations**: The R code embedded in the Rmd is clean, well-commented, and fully reproducible. The simulation design is straightforward and easy to verify.

8. **Appendices are thorough**: The step-by-step derivations in Appendices A and B are useful and will help readers follow the algebra. The parameter sensitivity analysis (Appendix C, Figure A3 on rho) adds value.

---

## 5. Final Score and Verdict

### Score Breakdown

| Category | Count | Deduction per item | Subtotal |
|----------|-------|--------------------|----------|
| Critical | 1 | -20 | -20 |
| Major | 5 | -10 | -50 |
| Minor | 6 | -2 | -12 |
| Style | 2 | -1 | -2 |
| **Total** | | | **-84** |

### Final Score: **16/100**

### Verdict: **REPROVADO 16**

---

## 6. Interpretation and Path Forward

The low score reflects the cumulative weight of five Major issues and one Critical issue. However, I want to be clear about the nature of these vulnerabilities: **none of them invalidate the core algebra of the paper**. The formula is correct. The derivations are correct. The simulations are correctly implemented. The paper is well-written.

The problems are:
1. **Positioning** (C1, M1): The paper oversells the novelty of the formula and does not engage with the prior literature that has derived closely related or identical results. This is fixable with honest repositioning and a thorough related-work section.
2. **Scope** (M3, M5): The paper targets TSCS political science but does not address the specifications actually used in that literature (binary outcomes, fixed effects). This is fixable with additional simulations and honest scope statements.
3. **Practical guidance** (M2, M4): The paper's practical recipe is incomplete without uncertainty quantification, discussion of interpretive ambiguity, and testing against DGPs where the formula could mislead. This is fixable with additional content.

**If all issues were addressed**, the paper could score in the 70-85 range and would represent a useful, clearly written contribution to the applied methodology toolkit. The key revision priority is C1 (engage prior literature and honestly articulate what is new) followed by M3 and M4 (address linearity and interpretive ambiguity).

### Recommended revision priorities:
1. **[CRITICAL]** Add a thorough related-work discussion engaging Greenland (2003), Ding & Miratrix (2015), Pearl (2013 Section 4), and Gaebler et al. (2024). Reposition the contribution.
2. **[HIGH]** Add simulations with: (a) a confounder DGP to show interpretive ambiguity, (b) a binary outcome DGP, (c) a fixed-effects ADL specification.
3. **[HIGH]** Add a discussion of when the IVB formula can mislead (M4), including a clear warning that the formula's causal interpretation requires prior DAG knowledge.
4. **[MEDIUM]** Add inference for IVB (delta method standard errors or bootstrap CIs).
5. **[MEDIUM]** Fix the temporal incoherence in Figure 3.
6. **[LOW]** Tighten the "foreign collider bias" concept or use it more modestly.
7. **[LOW]** Strengthen or remove Appendix E.
