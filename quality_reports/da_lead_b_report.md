# Devil's Advocate Report: Lead B Viability

## 1. Does the trade-off exist?

**Short answer: The trade-off is real but is not framed as a "debate" in the literature. Lead B overstates the degree of active controversy.**

The ideation document (lines 41-42) claims there is "an unresolved debate in TSCS" pitting TWFE vs ADL vs MSM, with Blackwell & Glynn on one side and Imai & Kim on the other. Let me stress-test this claim.

Blackwell & Glynn (2018) do recommend SNMM/MSM for causal effects with time-varying treatments. Imai & Kim (2019) do show that TWFE is not identified under causal dynamics and recommend ADL+FE. But here is the problem: **these papers are not in direct disagreement with each other in the way Lead B implies**. Blackwell & Glynn's concern is about post-treatment bias when you condition on lagged time-varying covariates affected by treatment. Imai & Kim's concern is about strict exogeneity failure in static TWFE. They are addressing different failure modes.

More critically, neither Blackwell & Glynn nor Imai & Kim would recognize the paper's framing as representing their positions. Blackwell & Glynn do not say "never use ADL" -- they say ADL has post-treatment bias for lagged effects, and recommend SNMM/MSM when you want to estimate effects of treatment sequences. Imai & Kim do not endorse ADL+FE as a universal solution -- they present it as one parametric identification strategy (Table 1, rows 2-4) among several.

The real landscape is more nuanced. Applied researchers in comparative politics largely use TWFE or ADL+FE already. MSM/SNMM have almost zero adoption in political science. The "debate" is therefore largely academic: very few researchers are actually choosing between ADL+FE and MSM in practice. If nobody is seriously considering MSM, then "resolving the trade-off" solves a problem that applied researchers do not know they have.

**The CLAUDE.md itself** (the project instructions) acknowledges this risk: "Reviewer pode dizer 'ADL+FE ja e o default, qual a novidade?'" (ideation_paper_lead.md, line 49). This is not a minor risk -- it is the central vulnerability of Lead B. If ADL+FE is already the default, and the paper's conclusion is "use ADL+FE," then the paper is telling people to do what they already do.

**Verdict on Section 1**: The trade-off exists in principle but is not a live, contested debate with active participants on both sides. Lead B risks constructing a straw man by presenting Blackwell & Glynn as advocates for MSM in typical TSCS applications when they are really advocates for MSM in specific settings with treatment sequences. The literature gap is real (nobody has quantified the cost of conditioning on colliders in ADL+FE), but framing it as "resolving a debate" oversells it.

## 2. Do simulations represent the trade-off faithfully?

**Short answer: The simulations are well-executed but do NOT actually simulate the trade-off that Lead B claims to resolve. They simulate a different question.**

The NL simulation report (nl_simulation_report.md) tests the question: "Does the result 'IVB is small under linearity' survive non-linearities?" This is a boundary-condition exercise. The simulations vary the functional form of the collider channel (D->Z, Y->Z) across 8 types and measure how IVB changes.

But Lead B claims to resolve the trade-off between ADL+FE, TWFE, and MSM. The simulations **never estimate MSM or SNMM models**. There is no marginal structural model anywhere in the simulation design. The 9 models estimated (nl_simulation_report.md, Section 1.3, lines 38-49) are all variants of OLS: TWFE, ADL with various lag structures, and ADL without FE. The comparison is between different OLS specifications, not between OLS and sequential g-estimation or IPTW.

This is a critical omission. If the paper claims "ADL+FE dominates MSM," then the simulations must include MSM as a competitor. Otherwise, the claim is unsupported by the simulation evidence. What the simulations actually show is that ADL(all lags) dominates other OLS specifications -- a useful but narrower finding.

Furthermore, the DGP has specific features that favor ADL+FE:

1. **Linearity in the outcome equation** (Y = beta*D + ...). The outcome equation is always linear. Non-linearity is introduced only in the collider equation (Z = ... + f_nl(D)). This is favorable to ADL because ADL's assumption about the outcome process is satisfied. If the outcome equation were also non-linear, ADL+FE could perform much worse.

2. **Fixed N=100, T in {10, 30}**. These are moderate panel dimensions. The simulations do not explore N very large with T very small (e.g., N=1000, T=5), which is common in political science (large-N country-year panels with short windows).

3. **Continuous treatment**. The treatment D is continuous and normally distributed. Many TSCS applications in political science have binary treatments (democratization, peacekeeping deployment), which change the mechanics of IVB substantially. The v4 simulations (described in CLAUDE.md) were supposed to address this with Mechanism C (binary treatment), but those results are not in the NL simulation report.

4. **No time-varying confounders other than Z**. The DGP has Z as the sole time-varying covariate. In real applications, researchers include many controls, and the IVB from multiple colliders could compound.

5. **The "true" beta is always 1, and the DGP is known**. The simulations measure bias against the known truth. In real applications, the researcher does not know which model is correctly specified. The comparison between models is meaningful only because we know the DGP.

**A specific concern about the IVB ratio metric**: The report defines IVB ratio = IVB(NL) / IVB(baseline linear) (line 57). This ratio measures whether non-linearity amplifies the IVB relative to the linear case. But for Lead B, the relevant metric is the absolute magnitude of IVB relative to beta or SE(beta), not relative to the linear-case IVB. An IVB ratio of 3.5x sounds alarming, but if the baseline IVB is 0.03, then 3.5 * 0.03 = 0.10 -- which may still be small relative to the treatment effect.

**Verdict on Section 2**: The simulations are rigorous for the question they actually answer (does non-linearity amplify IVB?). But they do not answer the question Lead B poses (does ADL+FE dominate MSM?). This is a fundamental mismatch between the claimed contribution and the supporting evidence.

## 3. Does IVB resolve the trade-off?

**Short answer: No. The IVB formula is a diagnostic, not a resolution. Calling it a "resolution" is an overreach that reviewers will immediately challenge.**

The IVB formula, IVB = -theta* x pi, is an algebraic identity. The manuscript correctly states this multiple times (line 553 of the Rmd: "The decomposition... is an algebraic identity: it holds whenever the short and long regressions are nested, regardless of the causal role of Z"). The formula tells you the arithmetic difference between two nested OLS specifications. This is useful, but it has several limitations that prevent it from "resolving" the model choice trade-off:

**Limitation 1: The formula cannot distinguish colliders from confounders.** The manuscript's own Section "Interpretation Caveats" (lines 551-568) makes this crystal clear. The IVB is non-zero whenever Z is correlated with both D and Y conditional on other controls -- whether Z is a collider, confounder, or mediator. In the Rogowski et al. application (Section 5.2, lines 815-877), the paper openly concedes that GDP per capita is simultaneously a collider and a confounder, and "the IVB formula alone cannot answer" which effect dominates. If the formula cannot resolve the most interesting empirical case in its own paper, how can it resolve a broader methodological debate?

**Limitation 2: IVB is only one source of bias in ADL+FE.** The trade-off between ADL+FE and MSM involves multiple sources of bias: (a) IVB from conditioning on colliders, (b) Nickell bias from the within-transformation with LDV, (c) functional form misspecification, (d) time-varying confounding bias when the confounding adjustment set is incomplete. The IVB formula quantifies only (a). Even if IVB is small, (b)-(d) could dominate. The paper acknowledges Nickell bias (Section 4.6, lines 439-447) but does not quantify it jointly with IVB in the applications. The NL simulation report shows ADL_all bias of -0.022 with T=10 (line 275) -- this is predominantly Nickell bias, not IVB, and it is 10x the T=30 value.

**Limitation 3: The formula requires knowing that Z is a collider.** Step 0 of the diagnostic recipe (line 528) says "Establish causal status... using a DAG or substantive domain expertise." But if the researcher can correctly draw the DAG, they already know whether to include Z. The formula then tells them how much it matters, which is useful but does not help with the hard problem (drawing the correct DAG). This makes the formula a "quantitative refinement" rather than a "resolution."

**Limitation 4: The empirical evidence is limited.** Six studies with 14 collider candidates is a small sample. The result "median IVB/SE = 0.13" (line 681) is interesting but could be driven by selection: the studies were chosen because they are prominent TWFE applications, which by construction tend to have slow-moving variables where IVB is small (as the paper's own theory predicts). A more adversarial sample of studies with continuous treatments and short panels might yield different results.

**Limitation 5: The formula says nothing about settings where MSM genuinely dominates.** Blackwell & Glynn's concern is about estimating the effects of treatment sequences or dynamic treatment regimes. In those settings, the estimand itself is different (e.g., the effect of "treat at t=1 and t=2" vs. "treat at t=1 only"). ADL+FE does not even target this estimand. The IVB formula, which compares nested OLS specifications, is irrelevant to this class of problems. Lead B's claim that "ADL+FE dominates" is silent on estimands that ADL+FE cannot identify.

**Verdict on Section 3**: The IVB formula is a useful diagnostic tool. It is not, and cannot be, a resolution of the model choice trade-off. Calling it a resolution invites devastating reviewer pushback.

## 4. Holes and weaknesses

1. **No MSM/SNMM in simulations.** The paper claims ADL+FE dominates but never runs a competing MSM. This is the single largest gap.

2. **Straw man framing.** Blackwell & Glynn recommend MSM for dynamic treatment regimes with time-varying confounders. The paper fights against a position that is more nuanced than presented. A careful reviewer who has read BG2018 will notice.

3. **The pure collider vs. mixed case distinction is undertheorized in the manuscript.** The CLAUDE.md (project instructions, "Collider puro vs caso misto" section) recognizes this distinction as central: in the pure collider case, Blackwell & Glynn are "100% correct," and IVB is pure bias. In the mixed case, including Z creates IVB but removes larger OVB. The manuscript (ivb_paper_psrm.Rmd) discusses this in the Interpretation Caveats and the Rogowski application, but it is not systematized into a formal result. For Lead B, this distinction would need to be the central theoretical contribution, not a caveat.

4. **The manuscript is currently written as Lead A, not Lead B.** The title is "Included Variable Bias: A Formula for Collider Bias in Cross-Sectional and Time-Series Cross-Sectional Regressions" (line 2). The intro starts with "Applied researchers using observational data face a fundamental challenge: which variables should be included as controls?" (line 61). The conclusion lists three contributions, all centered on the formula (line 882). Rewriting for Lead B is not a cosmetic change -- it requires restructuring the entire paper.

5. **The "foreign collider bias" concept, while interesting, is a distraction for Lead B.** It is a naming innovation, not a methodological one. The mechanism (variables caused by treatment and outcome through literatures outside the researcher's domain) is just regular collider bias with an epidemiological observation about disciplinary silos. For Lead B, this concept would need to be cut or significantly downweighted.

6. **The NL simulation results create an awkward tension.** The paper would need to say "ADL+FE dominates under linearity and bounded non-linearity, but not under unbounded non-linearity." This is a fine contribution but is a boundary condition, not a resolution. The reviewer will ask: "How does the researcher know whether their real-world collider channel is bounded or unbounded?"

7. **The six empirical applications are all TWFE with slow-moving variables.** There is no application with a continuous treatment, short T (5-10 periods), or a setting where IVB is large and problematic. The Rogowski application (IVB/SE = 2.11) is the exception, but the paper itself says the collider status is "causally ambiguous." This weakens the claim that the formula provides practical guidance.

8. **No comparison to Cinelli & Hazlett (2020) sensitivity analysis.** The manuscript cites Cinelli & Hazlett as developing OVB sensitivity tools but does not compare the IVB formula to their approach. A natural reviewer question: "Why not just use the Cinelli & Hazlett framework, which handles both OVB and IVB under a unified partial-R^2 framework?"

## 5. What could kill this paper

1. **"So what?" from both directions.** Methodologist reviewers may say: "This is just FWL, we know this." Applied reviewers may say: "ADL+FE is already the default, who cares?" Lead B addresses the second concern but may amplify the first.

2. **A reviewer who knows Blackwell & Glynn well** will point out that their argument is about estimands (dynamic treatment regimes), not just estimators. The paper never engages with the question: "What if the researcher wants to estimate the effect of a treatment sequence, not a static treatment effect?" In that case, ADL+FE does not target the right estimand regardless of IVB magnitude.

3. **A reviewer who notices that MSM is never simulated** will reject the claim that ADL+FE "dominates." You cannot claim dominance over a competitor you never ran.

4. **The bounded/unbounded boundary condition** could be turned against the paper: "So IVB is small only when the world is approximately linear. This is not new -- we already knew OLS works when the world is linear."

## 6. What would strengthen it

1. **Add MSM/SNMM to the simulation comparison.** Even a simple IPTW estimator would suffice. Show that ADL+FE has lower RMSE than IPTW under the DGP conditions where IVB is small, and show where IPTW starts to dominate. This would genuinely resolve the trade-off with simulation evidence.

2. **Reframe as "diagnostic tool for a common practical dilemma" rather than "resolution of a debate."** Instead of claiming to resolve a debate (which invites the response "what debate?"), frame it as: "Researchers routinely face the question of whether a control is helpful or harmful. We provide the first quantitative tool for answering this question in TSCS data." This is Lead D from the ideation document, and it is honestly more defensible than Lead B.

3. **Formalize the collider-confounder trade-off.** Derive a closed-form condition (or at least a computable criterion) for when including Z (as both collider and confounder) reduces net bias under TWFE. The manuscript's own future directions paragraph (line 569) identifies this as "a promising direction." It would be more than promising -- it would be necessary for Lead B.

4. **Diversify the empirical applications.** Add at least one application with a continuous treatment, one with short T (5-10 periods), and one where IVB is demonstrably large and problematic. The current set of applications proves that IVB is usually small in slow-moving TWFE applications -- but this is the easiest case.

5. **Engage more seriously with Blackwell & Glynn's actual argument.** Specifically, acknowledge that their concern about dynamic treatment regimes involves a different estimand. Show that for the static treatment effect estimand (which is what most applied researchers actually target), IVB quantifies the relevant trade-off. This narrows the claim but makes it defensible.

6. **Clarify the relationship to Ding & Miratrix (2015).** The manuscript cites their result that conditioning on a butterfly-structure variable reduces bias in 75% of the parameter space. Explain how the IVB formula extends or refines this result for the TSCS case.

7. **The NL simulations should be in the paper, not just in a report.** They are currently not in the manuscript (ivb_paper_psrm.Rmd). For Lead B, the boundary conditions (bounded vs. unbounded) would need to be a main section, not an afterthought.

## 7. Verdict

**Lives with conditions -- but the conditions are substantial.**

Lead B+E is viable if and only if:

(a) **MSM/SNMM are added to the simulation comparison.** Without this, the "resolving the trade-off" claim is unsupported.

(b) **The claim is narrowed.** Instead of "resolving the TSCS model choice debate," the paper should claim "quantifying the cost of the most common model choice in TSCS" -- specifically, the cost of conditioning on potentially endogenous covariates in ADL+FE. This is honest and still interesting.

(c) **The collider-confounder trade-off is formalized.** The pure collider case (where IVB is pure harm) and the mixed case (where IVB is offset by OVB reduction) need to be distinguished with a formal result, not just a caveat.

(d) **The manuscript is actually rewritten.** Currently, the paper is Lead A (formula-first). Switching to Lead B requires restructuring the intro, rebalancing the sections, integrating the NL simulations, and potentially changing the title. This is months of work, not a weekend revision.

If these conditions are met, Lead B+E could target Political Analysis or PSRM confidently, and AJPS ambitiously. Without them, Lead B+E is a promissory note that will not survive peer review. The safer path is a strengthened version of the current paper (Lead A with elements of D) targeting PSRM, with the trade-off framing deferred to a follow-up paper that includes the MSM comparison.

**Bottom line**: The IVB formula is a genuine contribution. The "resolving the trade-off" framing is aspirational. The paper has the ingredients for something important, but it currently overpromises relative to what the evidence delivers. The formula is a good diagnostic tool; it is not (yet) a resolution.
