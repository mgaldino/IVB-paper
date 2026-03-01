# Referee Report: "Included Variable Bias: A Formula for Collider Bias in Cross-Sectional and Time-Series Cross-Sectional Regressions"

**Journal**: Political Science Research and Methods
**Date**: March 2026
**Reviewer**: Anonymous

---

## 1. Summary

This paper derives what the authors call the "Included Variable Bias" (IVB) formula, which quantifies the bias introduced when a researcher erroneously includes a collider variable in a regression model. The core result is that IVB = -theta* x pi, where theta* is the coefficient on the collider in the misspecified ("long") regression and pi is the coefficient on the treatment in an auxiliary regression of the collider on the treatment and other legitimate controls. The authors present this as the mirror image of the classical Omitted Variable Bias (OVB) formula, emphasizing that both components are directly estimable from data. The formula is derived first for cross-sectional OLS, then extended to ADL(1,0) and general ADL(p,q) models via the Frisch-Waugh-Lovell theorem.

Beyond the formula itself, the paper makes two additional contributions. First, it uses Monte Carlo simulations to characterize structural conditions under which IVB tends to be small in panel data with two-way fixed effects: absorption of between-unit variation by FE, binary treatments with few switchers, and measurement error in the collider. Second, the authors apply the formula to six published studies in comparative politics and international political economy, classifying each control variable as a collider, confounder, mediator, or predetermined variable using DAG-based reasoning. The empirical finding is reassuring: among 14 collider candidates across six studies, only one (GDP per capita in a growth regression) produces an IVB exceeding one standard error of the treatment effect.

The paper also introduces the concept of "foreign collider bias"---the idea that the collider structure may only be discovered by consulting literatures outside the researcher's primary domain---and provides a practical four-step diagnostic recipe.

## 2. Overall Assessment

The paper addresses a genuine gap in applied methodology. The OVB formula is one of the most widely taught results in quantitative political science; having a symmetric formula for the opposite problem---including a harmful variable rather than omitting a necessary one---is a natural and useful complement. The paper is generally well-written, well-organized, and demonstrates a genuine effort to be useful to applied researchers.

However, I have significant reservations about the novelty and depth of the core theoretical contribution. The IVB formula is, as the authors themselves acknowledge (Section 3.1, after Proposition 1), an algebraic identity that follows directly from the FWL theorem and the standard short-versus-long regression decomposition. The authors are candid about this, stating that their contribution lies "not in the algebra per se." This candor is appreciated, but it shifts the burden to the other claimed contributions---naming/packaging, direct estimability, and the ADL extension---which I find insufficient for a top methods journal without substantially more development.

The empirical applications are the strongest part of the paper. The careful DAG-based classification of controls across six studies is a valuable exercise that demonstrates the kind of reasoning applied researchers should routinely perform. However, the finding that IVBs are almost always small somewhat undercuts the paper's own motivation. If the problem is nearly always negligible, why should researchers invest effort in the diagnostic?

The paper would benefit from a more honest engagement with the question of novelty relative to the existing literature (particularly Pearl 2013 and Ding and Lu 2015), a deeper theoretical treatment of the collider-plus-confounder case (which is the empirically dominant scenario), and either a formal sensitivity analysis framework or a clearer statement of why the paper stops short of one.

## 3. Major Comments

### 3.1. Novelty of the core formula

The central theoretical result---IVB = -theta* x pi---is an algebraic identity of OLS. The authors acknowledge this explicitly. The FWL decomposition of the difference between short and long regression coefficients is a standard textbook result (e.g., Angrist and Pischke 2009, Chapter 3). Path-tracing formulas for collider bias in linear SEMs have been available since at least Pearl (2013). The specific product decomposition for M-bias configurations was derived by Ding and Lu (2015). The authors position their contribution as (i) naming/packaging, (ii) making estimability explicit, and (iii) extending to ADL models.

I find (i) and (ii) modest. Regarding (iii), the ADL extension is straightforward: the FWL theorem holds for any set of controls, so partitioning out lagged dependent variables and additional lags is a direct application. The "extension" to ADL(p,q) in Section 3.4 is a single paragraph, because the argument is identical.

What would elevate the contribution? Two directions come to mind. First, a formal sensitivity analysis framework parallel to Cinelli and Hazlett (2020) for OVB. The authors mention this as future work (Section 7) but do not develop it. Without this, the IVB formula remains a point estimate of a bias quantity that itself depends on whether the DAG is correctly specified---and if the researcher is uncertain about the DAG, a point estimate of IVB is of limited value. Second, a closed-form treatment of the collider-plus-confounder case under TWFE, which the authors identify as the empirically dominant scenario but do not analyze beyond noting that Ding and Lu (2015) studied a cross-sectional version. The authors acknowledge this as a "promising direction for future work" (end of Section 3.6), but this is arguably the most important case for applied researchers.

### 3.2. The tautology concern

The paper's empirical conclusion is that IVBs are almost always small. The simulation section (Section 5) identifies four mechanisms that attenuate IVB in typical TSCS applications. But this creates a tension: if the bias is nearly always negligible, the practical value of the formula is diminished. The authors need to engage more directly with this tension.

One resolution would be to emphasize the formula's value as a screening tool: it is precisely because IVB is *usually* small that the rare cases where it is large (like Rogowski et al.) become important to identify. The paper gestures at this but does not develop it clearly. Another resolution would be to demonstrate settings where IVBs are large and consequential---e.g., cross-sectional studies, short panels, or continuous treatments---which the authors mention in passing (end of Section 7) but do not illustrate.

### 3.3. The collider identification problem

The IVB formula requires, as its critical Step 0, that the researcher correctly identify Z as a collider rather than a confounder. The authors are commendably transparent about this limitation (Section 3.6). However, the practical recipe (Section 3.5) buries this crucial caveat. In my experience, applied researchers will skip Step 0 and go straight to computing the product -theta* x pi, then interpret a large value as evidence of collider bias. The Rogowski et al. application demonstrates exactly this danger: the large IVB could reflect either collider bias or appropriate deconfounding.

The paper should do more to guard against misuse. At minimum, I would recommend: (a) renaming the formula to something less suggestive---"Specification Sensitivity Decomposition" or "Included Variable Decomposition"---since calling it "Included Variable Bias" presupposes that the inclusion is wrong, which is precisely the assumption under question; or (b) presenting the formula explicitly as a decomposition of the difference between nested specifications, agnostic about which is correct, and reserving the term "bias" for contexts where the DAG has been convincingly established. The current framing is likely to mislead precisely the applied researchers the paper aims to help.

### 3.4. Treatment of the dual collider-confounder case

The empirically dominant scenario---where a control is simultaneously a collider and a confounder---receives surprisingly little analytical attention. The Rogowski et al. application (Section 6.2) illustrates the problem beautifully, but the paper offers no analytical framework for evaluating the trade-off. The authors cite Ding and Lu (2015) on the cross-sectional "Butterfly-Structure" and note that TWFE introduces differential absorption of the two channels, but they do not pursue this.

For a methods paper aiming to provide practical guidance, this is a significant gap. The majority of candidate colliders in the six replications (GDP per capita in nearly every study) are plausibly both colliders and confounders. If the paper cannot help the researcher determine whether including or excluding these variables is the lesser evil, its practical utility is limited to the narrow case of pure colliders---which may be rare.

### 3.5. Simulation design and generalizability

The simulation section (Section 5) examines four mechanisms using a specific DGP with N=200, T=30, and a continuous treatment. I have several concerns:

(a) The DGP is specifically designed to illustrate why IVB is small. This is informative, but it would be more convincing to also show when IVB is large. A simulation that varies the ratio of within- to between-unit variation systematically, or that examines short panels (T=5-10) where Nickell bias interacts with IVB, would strengthen the paper.

(b) The simulation results for Mechanisms A and B (heatmaps referenced in Figures 1-2 of the text) are described as "horizontal bands" confirming that FE absorbs between-unit variation. This is a well-known property of FE estimators and does not require simulation to establish. The algebraic argument in the text (equations in Section 5.1) is sufficient and more rigorous. The simulations add confirmation but not new insight.

(c) The claim that "few switchers render IVB statistically invisible" (Mechanism C) conflates two distinct issues: the population IVB and its detectability. The population IVB is constant; what changes is the standard error. This means the *bias* is the same---it just becomes harder to distinguish from noise. In a study with few switchers and a marginally significant result, a constant IVB could still flip the significance of the treatment effect even if |IVB/SE| < 1.

(d) Mechanism D (measurement error attenuation) is well known and does not need simulation.

### 3.6. Selection of empirical applications

The six applications are weighted toward TWFE panel designs with binary or slow-moving treatments and GDP per capita as the recurring collider candidate. This creates the impression that the IVB is small because of the specific niche of comparative politics TSCS designs, rather than as a general property. If the paper's main empirical message is "IVB is usually small in TSCS comparative politics," that is a much narrower claim than the framing suggests. Applications with continuous treatments, cross-sectional designs, or shorter panels would test the formula's utility more stringently and demonstrate its value in precisely the settings where the authors expect larger IVBs.

### 3.7. The lag substitution result is underdeveloped

Proposition 4 (Section 3.5) establishes that lagging the treatment does not mechanically eliminate IVB, which is a useful insight. However, the result is stated in terms of the projection coefficients omega, which are opaque objects. The paper does not provide any empirical or simulation-based illustration of how much lag attenuation actually occurs in practice. How quickly does IVB decay with lag length? Under what autocorrelation structures? This result, as stated, is too abstract to be useful and should either be developed with examples or moved to an appendix.

## 4. Minor Comments

### 4.1. Notation
The paper uses different notation in the cross-sectional derivation (beta_2*, phi_1) versus the ADL derivation (theta*, pi). While the footnote on p. 3 explains this, it creates unnecessary confusion. I would recommend unifying the notation throughout.

### 4.2. "Foreign collider bias"
The term "foreign" is somewhat confusing. The paper clarifies that it does not mean "cross-national," but the association is hard to shake in a paper about comparative politics. Consider "interdisciplinary collider bias" or "cross-literature collider bias" as alternatives, though I acknowledge these are also imperfect.

### 4.3. The practical recipe (Section 3.5)
Step 0 starts the numbering at 0, while Steps 1-3 use standard numbering. This is a small inelegance that may confuse readers. Either start at Step 1 or use a different label for the prerequisite step (e.g., "Prerequisite: Establish causal status").

### 4.4. Connection to Potential Outcomes (Appendix E)
The connection to potential outcomes is superficial. Saying that "conditioning on a common effect violates conditional independence" is true but does not leverage the potential outcomes framework to provide new insight beyond what the DAG framework already offers. Either develop this connection more fully (e.g., by relating IVB to specific parameters of the selection process) or drop the appendix.

### 4.5. The civil war running example
The civil war/democracy DAG example (Section 2.2-2.3) is used to motivate foreign collider bias but is not among the six replicated studies. Including it as a seventh empirical application, or explaining why it was excluded, would improve coherence.

### 4.6. DAG classification subjectivity
The control classifications in Appendix F involve substantial subjective judgment. For instance, classifying Refugees/IDPs in Blair et al. as "Collider + Confounder" while classifying GDP per capita in the same study as "Collider" (without the confounder label) seems inconsistent, given that GDP per capita in Blair et al. is surely also a confounder (richer countries both attract less peacekeeping and have higher democratization levels for structural reasons). The classification criteria should be stated more precisely and applied more consistently.

### 4.7. Standard errors for IVB
The paper computes the IVB as a point estimate but provides no standard error or confidence interval for the IVB itself. Since IVB is a product of two estimated coefficients, the delta method (or bootstrap) could be used to compute a standard error. Reporting IVB without uncertainty quantification is inconsistent with the paper's own emphasis on comparing IVB to SE(beta).

### 4.8. Nickell bias discussion
The discussion of Nickell bias interaction (Section 3.4) is thoughtful but inconclusive. The claim that "the direction of the IVB is less affected by Nickell bias than its magnitude" is stated without formal justification. For T < 20, which is common in comparative politics, the paper essentially says the IVB estimate is unreliable. This should be stated more prominently, as many potential users of the formula work with short panels.

### 4.9. Writing
The paper is generally well-written but long. The introduction could be shortened by 30-40%. The discussion of the two heuristics (Section 2.1-2.2) is clear but takes up significant space for a concept that is well established. Consider condensing this section and moving some of the detail to an appendix.

### 4.10. Missing references
The paper should cite Angrist and Pischke (2009) for the short-versus-long regression decomposition that is the algebraic foundation of the IVB formula. The connection to their "bad controls" discussion (Chapter 3) is direct and relevant. The paper should also engage with Aronow and Miller (2019), who provide a systematic treatment of regression adjustment under misspecification that is relevant to the paper's framework.

### 4.11. Title
The title is accurate but long. Consider shortening to "Included Variable Bias: Quantifying Collider Bias in Panel Regressions" or similar.

## 5. Recommendation

**Major Revisions.**

The paper addresses a real and underappreciated problem in applied political science methodology. The practical recipe is useful, and the empirical applications demonstrate genuine craft in DAG-based reasoning. However, I have significant concerns about the novelty of the core theoretical contribution (which is an algebraic identity, not a new result), the lack of a sensitivity analysis framework, the underdeveloped treatment of the collider-plus-confounder case, and the tension between the paper's motivation (collider bias is dangerous) and its findings (collider bias is almost always negligible).

For publication in PSRM, I would want to see:

1. A more honest and prominent discussion of the formula's status as an algebraic identity and how this paper's contribution differs from existing derivations (Pearl 2013, Ding and Lu 2015) beyond naming.
2. Either (a) a formal sensitivity analysis extension or (b) substantially more development of the collider-plus-confounder case, ideally with analytical results under TWFE.
3. At least one empirical or simulation example where IVB is large and consequential, to demonstrate the formula's value as a screening tool.
4. Standard errors or confidence intervals for the IVB estimates.
5. A clearer framing that guards against misuse by researchers who skip Step 0.

The paper is not ready for publication in its current form, but the project has merit and could become a solid contribution with significant revision.
