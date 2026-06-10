# Review-Paper — Dois Pareceristas Independentes

**Data**: 2026-03-23
**Paper**: ivb_paper_psrm.Rmd

---

# Carta Editorial

## Decisao: Revise & Resubmit (minor)

## Sintese

Both reviewers recognize this paper as a well-executed methodological contribution that fills a genuine gap in applied TSCS research. The IVB formula is a simple, operational diagnostic that mirrors the familiar OVB formula but addresses the opposite problem---included rather than omitted variables. The paper is clearly written, carefully scoped, and backed by extensive Monte Carlo evidence and six empirical applications. The reviewers converge on two main concerns: (1) the novelty claim needs more careful positioning relative to the existing econometric literature on short-versus-long regression decompositions (Reviewer 1) and the collider bias quantification literature (Reviewer 2), and (2) the empirical applications, while well executed, yield a somewhat anticlimactic punchline---that IVB is almost always small---which requires better framing as a feature rather than a limitation (both reviewers). The paper is close to publishable and would benefit from a focused revision addressing these points.

## Pontos de consenso entre pareceristas

- The IVB formula is genuinely useful as a practical diagnostic for applied researchers, and the OVB/IVB mirror is pedagogically effective.
- The paper is well written, clearly structured, and appropriately scoped (CET only, linear models, TSCS settings).
- The concept of "foreign collider bias" is a valuable contribution to applied practice.
- The empirical finding that IVB is typically small (~0.13 SE) is important but needs to be sold as the point, not treated as a disappointment.
- The scope conditions and caveats are handled honestly and transparently.

## Pontos divergentes

- Reviewer 1 is more concerned about the novelty claim relative to substantive literatures and the narrative arc of the paper; Reviewer 2 is more concerned about the technical assumptions underlying the Monte Carlo evidence and the DiD extension. Both concerns are valid, but the narrative/framing issues (R1) are more consequential for the paper's reception at a top methods journal.

## Prioridades para revisao

1. **Sharpen the novelty claim** (R1, Major #1): Be more explicit about what is new (the repackaging as a diagnostic, the TSCS/ADL extension, the systematic empirical evidence) versus what is known (the FWL decomposition, short-vs-long algebra). A table or paragraph distinguishing "what we derive" from "what we adapt" would help.

2. **Reframe the empirical punchline** (R1, Major #3; R2, Major #4): The finding that IVB is almost always negligible should be presented as the paper's empirical contribution, not as a null result. Consider: "The formula lets researchers verify---rather than assume---that their specification choice is inconsequential."

3. **Strengthen the DiD section or reduce its weight** (R2, Major #3): The Jensen application is interesting but feels underdeveloped relative to the TSCS material. Either expand it with more applications or reduce it to a brief extension that points to future work.

4. **Address the DAG dependence more directly** (R1, Major #2; R2, Major #2): The paper correctly notes that the formula requires a DAG, but the practical difficulty of constructing credible DAGs in TSCS settings deserves more discussion. Consider adding a brief subsection on how to handle DAG uncertainty.

5. **Minor technical clarifications** (R2, Minor comments): Standard error reporting, functional form sensitivity, and the Nickell bias interaction deserve brief additional discussion in the text or appendix.

---

## Parecer completo --- Parecerista 1 (Teoria & Substancia)

### Recomendacao: R&R minor

### Resumo do paper

This paper introduces "Included Variable Bias" (IVB) as a named diagnostic for TSCS research, providing a closed-form formula (IVB = -theta* x pi) that quantifies the change in a treatment estimate caused by including or excluding a covariate. Combined with DAG-based reasoning about the covariate's causal role (collider, confounder, or mediator), the formula tells the researcher whether and how much a specification choice matters. Monte Carlo simulations across 238 DGP configurations and applications to six published studies confirm that a benchmark ADL + FE specification with lagged state variables keeps collider bias below 3% of the treatment effect for the contemporaneous treatment effect (CET).

### Avaliacao geral

This is a well-crafted methodological paper that addresses a genuine and widespread practical problem in applied political science. The core insight---that the same OLS algebra underlying the familiar OVB formula can be repurposed to diagnose the opposite problem---is elegant and immediately useful. The paper is properly scoped to the CET, honestly acknowledges its limits, and provides a practical recipe that applied researchers can implement with minimal effort. The concept of "foreign collider bias" captures an important practical difficulty that existing methodological guidance overlooks. The paper's main weakness is that the underlying algebra is well known in econometrics (it is the standard short-versus-long regression decomposition via FWL), so the novelty claim needs more careful articulation: the contribution is the repackaging, naming, and systematic application of known results, not the derivation itself. This is a legitimate form of contribution---analogous to what Cinelli and Hazlett (2020) did for OVB sensitivity---but it must be framed with precision to avoid the appearance of rediscovery. Additionally, the empirical punchline (IVB is almost always small) needs to be more forcefully presented as the point of the exercise rather than as an incidental finding.

### Comentarios maiores

1. **The novelty claim requires more careful positioning.** The short-versus-long regression decomposition is textbook material (Goldberger 1991, Angrist and Pischke 2009). The paper acknowledges this (Section 4: "Our contribution is not the algebra but its repackaging as an operational diagnostic") but then presents formal Propositions for what are algebraic identities. This creates a tension: the formal apparatus suggests novelty, while the text correctly disclaims it. I suggest the authors either (a) present the cross-sectional result explicitly as a restatement of a known identity (perhaps as a "Fact" rather than a "Proposition") and reserve the Proposition label for the genuinely new extensions (ADL, TWFE with FE absorption of between-unit channels, the lag-substitution result), or (b) add a brief paragraph in the introduction explicitly listing what is known versus what is new. The comparison with Cinelli and Hazlett (2020) is apt and should be developed further: just as they did not invent sensitivity analysis but made it operational through partial R-squared benchmarks, this paper does not invent the FWL decomposition but makes it operational as a collider diagnostic. Say this clearly and own it.

2. **The DAG dependence is a strength and a vulnerability.** The paper is admirably transparent that the IVB formula is an algebraic identity that "cannot substitute for" DAG reasoning (Section 4.6). But this creates a practical challenge: in the empirical applications, the collider classifications rely on the authors' reading of adjacent literatures, and reasonable researchers could disagree. The Rogowski et al. application illustrates this well---GDP per capita is both a collider and a confounder, and the paper cannot resolve which channel dominates. This is honest, but it leaves the reader wondering: if the formula cannot tell me whether a variable is a collider, and the DAG is debatable, what have I actually gained? The answer is that the formula quantifies the stakes of the debate, which is valuable even when the DAG is uncertain. I suggest the authors add a brief discussion of "DAG uncertainty" as a practical issue, perhaps drawing on the sensitivity analysis literature (e.g., Ding and VanderWeele 2016 on sensitivity to unmeasured confounding) to suggest how researchers might assess the robustness of their DAG classification. This would strengthen the practical value of the framework considerably.

3. **The empirical punchline needs better framing.** The finding that the median IVB/SE is approximately 0.13 across six studies is presented almost apologetically---as if a small IVB is a disappointing result. In fact, this is the paper's most important empirical contribution. The message should be: "Researchers worry about bad controls. They should. But the formula shows that in typical TSCS applications, the damage is modest---and now they can verify this rather than assume it." The current framing buries this insight. I suggest restructuring the empirical section's conclusion to lead with the "good news" interpretation: the formula is valuable precisely because it tells you when you can stop worrying. The Rogowski et al. exception (IVB/SE > 2) then becomes the case that proves the rule: precisely because the formula flagged it, the researcher knows to investigate further.

4. **The "foreign collider bias" concept deserves more development.** This is one of the paper's most original practical contributions---the insight that discovering a collider requires consulting literatures outside the researcher's primary domain. Currently, it is introduced in Section 3.2 and then mostly dropped. I suggest the authors develop it more systematically: How common is this problem? Which types of variables (GDP, conflict, migration, trade) are most likely to be foreign colliders across subfields? A brief typology would increase the paper's practical impact substantially and give the concept the sustained treatment it deserves.

5. **The DiD extension (Section 6) feels somewhat grafted on.** The TSCS material is tightly integrated: formula, benchmark, simulations, applications all reinforce each other. The DiD section introduces a new decomposition, a new application (Jensen 2025), and a new simulation, but the connection to the main TSCS argument is only loosely developed. The "structural advantage of TSCS over DiD" argument is interesting but deserves either fuller treatment or demotion to a brief remark. As written, this section reads like a separate short paper appended to the main contribution. I suggest either (a) integrating it more tightly by showing that the same IVB formula naturally extends to DiD and that the decomposition is a special case, or (b) shortening it to a 1-page extension and moving the details to an appendix.

### Comentarios menores

1. The abstract is too long and technical for a general political science audience. Consider a shorter abstract (150 words) that leads with the practical problem and the solution, and saves the technical details for the introduction.

2. The term "Included Variable Bias" is well chosen and memorable, but the paper should note early on that it is related to (but distinct from) the "included variable problem" occasionally discussed in the measurement error literature. A footnote would suffice.

3. Table 1 (timing logic) is excellent and should be referenced more prominently---perhaps in the abstract or introduction.

4. The six empirical applications are well chosen for coverage, but the paper would benefit from briefly noting how the studies were selected. Was this a convenience sample, or was there a systematic search? Transparency about selection would preempt concerns about cherry-picking.

5. The conclusion's suggestions for future work (sensitivity tools for IVB, extension to synthetic control) are promising. Consider briefly noting whether the IVB formula extends to instrumental variables settings, since the footnote in Section 4.1 hints at this but does not develop it.

6. The paper uses "bad controls" in the title, which is effective for attracting attention, but the term has specific technical meaning in the Angrist and Pischke (2009) tradition that does not perfectly align with the paper's framework (which encompasses colliders, mediators, and confounders). Consider whether this creates a mismatch of expectations.

### Referencias sugeridas

- **Cinelli, C. and Hazlett, C. (2020).** "Making Sense of Sensitivity." *Journal of the Royal Statistical Society: Series B.* --- The closest analogue to what this paper does for IVB; the comparison should be developed more fully.
- **Ding, P. and VanderWeele, T.J. (2016).** "Sensitivity Analysis Without Assumptions." *Epidemiology.* --- For the discussion of DAG uncertainty.
- **Angrist, J.D. and Pischke, J.-S. (2009).** *Mostly Harmless Econometrics.* --- Already cited, but the "bad controls" discussion in Chapter 3.2.3 should be explicitly engaged.
- **Acharya, A., Blackwell, M., and Sen, M. (2016).** "Explaining Causal Findings Without Bias: Detecting and Assessing Direct Effects." *APSR.* --- On the distinction between total and direct effects in the context of mediators, relevant to Section 5.2.
- **Montgomery, J.M., Nyhan, B., and Torres, M. (2018).** "How Conditioning on Posttreatment Variables Can Ruin Your Experiment and What to Do about It." *AJPS.* --- Directly relevant to the post-treatment bias discussion.
- **Elwert, F. and Winship, C. (2014).** "Endogenous Selection Bias." *Annual Review of Sociology.* --- Already cited, but the taxonomy of collider types in their paper could enrich the "foreign collider bias" discussion.

---

## Parecer completo --- Parecerista 2 (Metodo & Inferencia)

### Recomendacao: R&R minor

### Resumo do paper

This paper develops a diagnostic formula for "Included Variable Bias" (IVB = -theta* x pi) that quantifies how much a treatment coefficient changes when a covariate is added to or removed from a regression. The formula is derived via the Frisch-Waugh-Lovell theorem for cross-sectional, TWFE, and ADL models. Monte Carlo simulations across 238 DGP configurations show that an ADL + FE benchmark with lagged state variables limits collider bias to under 3% of the treatment effect for the CET. Six empirical applications demonstrate the diagnostic in practice.

### Avaliacao geral

This paper makes a sound methodological contribution. The IVB formula is algebraically correct, cleanly derived, and properly extended to the panel/ADL context. The Monte Carlo evidence is extensive and well-designed, covering the right range of DGPs (collider, dual-role, mediator, nonlinearity, feedback). The empirical applications are a strength---they demonstrate that the formula is immediately usable and that the typical IVB magnitudes are small. The main methodological concerns are: (a) the paper could be more precise about what the Monte Carlo evidence does and does not establish (it demonstrates performance under specific parametric DGPs, not universal robustness); (b) the DiD extension is promising but technically underdeveloped relative to the TSCS material; and (c) the treatment of standard errors and inference for the IVB diagnostic itself could be strengthened. Overall, the paper is technically correct, practically useful, and well within the scope of a methods-oriented political science journal.

### Comentarios maiores

1. **The Monte Carlo evidence is impressive but needs clearer scope statements.** The paper reports 238 DGP configurations, which is commendable. However, all DGPs share a common structure: linear outcome equation, additive fixed effects, specific distributions for errors, and relatively simple dynamics (AR(1) persistence). The paper correctly notes that bounded nonlinearities in the collider equation do not threaten the ADL benchmark, but the outcome equation is always linear. If the outcome equation contains nonlinearities (e.g., threshold effects, interactions between D and Z), the FWL-based decomposition still holds as an algebraic identity, but the ADL benchmark specification may not capture the true CET. I suggest the authors add a brief discussion of what "bias below 3%" means in terms of the true DGP: it is the bias of the linear ADL estimator relative to the linear projection of the CET, not necessarily relative to the true nonlinear CET. This distinction matters for researchers working with inherently nonlinear processes (e.g., binary outcomes, count data).

2. **The DAG-based classification in the empirical applications is the weakest link methodologically.** The formula itself is an identity that holds regardless of the DAG. The practical value depends entirely on the researcher's ability to correctly classify Z as a collider, confounder, or mediator. In the six applications, the classifications are based on the authors' reading of adjacent literatures, which is reasonable but inevitably subjective. For instance, the classification of GDP per capita as a collider in Leipziger (2024) depends on accepting Acemoglu et al. (2019) and Grundler and Link (2024) as establishing the D-to-Z and Y-to-Z channels, respectively. A skeptic could argue that the D-to-Z channel (democracy causes GDP) operates over decades, making it irrelevant for the annual within-unit variation that drives the IVB. The paper should discuss the temporal mismatch between the structural channels (which operate over decades) and the within-unit variation that drives the empirical IVB (which operates at annual or 5-year frequency). This could explain why the IVBs are so small: the collider channels that are causally real may not operate at the same frequency as the within-unit variation captured by TWFE.

3. **The DiD extension (Section 6) raises technical questions that are not fully addressed.** The three-way decomposition (baseline/safe/full) is intuitive, but the "safe block" (B_i x Post_t) is a specific functional form assumption: it allows the common time effect to vary linearly with baseline traits. If the true conditional PTA requires nonlinear interactions (e.g., different trends for units in different quantiles of the baseline distribution), the safe block may not suffice, and the decomposition's interpretation changes. The paper notes this ("When B_i x Post_t is insufficient for conditional PTA...none of the three models identifies the ATT") but then proceeds as if this caveat is minor. In the Jensen application, how sensitive is the decomposition to the choice of which pre-treatment variables enter the safe block? A robustness check varying the safe block composition would strengthen the analysis. Additionally, the connection to Caetano and Callaway (2024) in Appendix F is well done but could be elevated to the main text, since it clarifies exactly how IVB relates to their bias decomposition.

4. **The empirical finding that IVB is small everywhere except Rogowski et al. deserves a structural explanation.** The paper offers an algebraic explanation (FE absorb between-unit channels), but a deeper question is: why is the within-unit association between D and Z so weak in these applications? Is it because the true collider channels operate at lower frequencies than the within-unit variation? Because treatment effects on Z are delayed? Because measurement error in Z attenuates pi? Providing a structural explanation---even a speculative one---would help researchers anticipate when IVB might be large (e.g., in studies with high-frequency data, strong contemporaneous treatment effects on covariates, or covariates measured without error).

5. **The variance of the IVB estimator (Appendix G) deserves more attention in the main text.** The delta method approximation is correct, but the Cauchy-Schwarz bound in Equation (16) could be quite loose when theta* and pi are both large (which is precisely when IVB matters most). The paper recommends cluster bootstrap as a fallback, but does not implement it in any of the empirical applications. I suggest the authors either (a) implement the bootstrap for at least the Rogowski et al. application (where IVB is large and inference matters) and report the confidence interval, or (b) compute the Cauchy-Schwarz bound for all applications and show that it is tight enough to be informative.

### Comentarios menores

1. **Standard errors in the replication.** The paper uses iid standard errors for the IVB computation ("vcov = iid" in the code) but clustered standard errors for inference on the treatment effect. This is correct (IVB is an identity of point estimates), but the IVB/SE ratio uses the clustered SE in the denominator. This should be stated more clearly in the text---currently it is buried in a code comment.

2. **The 500-replication Monte Carlo.** Is 500 sufficient for precise estimation of bias? For the mean bias, yes (by CLT). But for tail behavior (e.g., "maximum bias across scenarios"), 500 may be insufficient. Consider reporting confidence intervals around the Monte Carlo estimates, or at least noting the Monte Carlo standard error of the reported means.

3. **Nickell bias interaction (Appendix C).** The paper states that Nickell bias is O(1/T) and "becomes negligible" for T > 20-30. This is well established but deserves a brief simulation verification: run the dual-role DGP with T = 10, 20, 30, 50 and show that the ADL benchmark's bias converges. This would make the scope condition concrete rather than relying on citations.

4. **The lag-substitution result (Appendix D) is interesting** but the AR(1) decay corollary (IVB(k) ~ IVB(0) x rho_D^k) assumes that the collider depends only on contemporaneous D. If Z also depends on D_{t-1} (which is common when Z is persistent), the decay rate is slower. This should be noted.

5. **Figure 1 (dual-role simulation)** would benefit from confidence bands (e.g., pointwise 95% intervals from the Monte Carlo) to help the reader assess whether the small ADL bias is precisely estimated as small or merely noisy.

6. **The overcontrol table (Table 3)** reports "Target total = 1.20" and "Target direct = 1.00" but does not explain how these targets are computed from the DGP parameters. A brief note would help.

7. **Code availability.** The paper mentions compute_ivb_multi() as supplementary material. Will the full simulation code be available? Reproducibility is essential for a methods paper.

8. **The paper does not discuss measurement error in Z.** If Z is measured with error, both theta* and pi are attenuated, and the IVB will be biased toward zero. This could partially explain why empirical IVBs are small. A brief note on this would be valuable, especially since attenuation from measurement error is ubiquitous in TSCS data.

### Referencias sugeridas

- **de Luna, X., Waernbaum, I., and Richardson, T.S. (2011).** "Covariate Selection for the Nonparametric Estimation of an Average Treatment Effect." *Biometrika.* --- On formal criteria for selecting controls that avoid collider bias.
- **VanderWeele, T.J. and Shpitser, I. (2011).** "A New Criterion for Confounder Selection." *Biometrics.* --- The "disjunctive cause criterion" for control selection, which could complement the DAG-based approach.
- **Imbens, G.W. (2020).** "Potential Outcome and Directed Acyclic Graph Approaches to Causality." *Journal of Economic Literature.* --- On the integration of DAGs and potential outcomes, relevant to Appendix F.
- **Wooldridge, J.M. (2005).** "Fixed-Effects and Related Estimators for Correlated Random-Coefficient and Treatment-Effect Panel Data Models." *Review of Economics and Statistics.* --- On the interpretation of FE estimators in dynamic panels.
- **Roth, J. (2022).** "Pretest with Caution: Event-Study Estimates after Testing for Parallel Trends." *AER: Insights.* --- Relevant to the DiD extension, on the difficulty of validating conditional PTA.
- **Roth, J., Sant'Anna, P.H.C., Bilinski, A., and Poe, J. (2023).** "What's Trending in Difference-in-Differences?" *Journal of Econometrics.* --- Comprehensive review of recent DiD methods, useful for positioning the DiD extension.
- **Goldsmith-Pinkham, P., Hull, P., and Kolesar, M. (2024).** "Contamination Bias in Linear Regressions." *American Economic Review.* --- On decomposing OLS estimates in heterogeneous treatment effect settings, potentially relevant to the interpretation of IVB under treatment effect heterogeneity.
