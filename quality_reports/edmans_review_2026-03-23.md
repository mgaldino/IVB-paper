# Carta Editorial --- Framework Edmans (Contribution, Execution, Exposition)

**Data**: 2026-03-23
**Paper**: ivb_paper_psrm.Rmd

## Decisao: R&R Major

## Scores consolidados
| Dimensao     | Score | Rating            |
|-------------|-------|-------------------|
| Contribution | 5/10  | Adequate but narrow |
| Execution    | 7/10  | Strong            |
| Exposition   | 7/10  | Good              |
| **Global**   | 6/10  | **Promising but not yet publication-ready** |

## Sintese editorial

This manuscript presents a useful methodological tool---the IVB formula---and a practical benchmark specification (ADL + FE with lagged state variables) for researchers working with time-series cross-sectional data. The execution is strong: the Monte Carlo simulations are extensive (238 DGPs), the empirical applications span six studies, and the authors are commendably honest about the limits of the formula. The exposition is generally clear and well-organized. However, the contribution faces a fundamental tension: the IVB formula is an algebraic identity already known in econometrics (the short-vs-long regression decomposition via FWL), and the benchmark recommendation (use ADL with lagged controls) largely echoes Blackwell & Glynn (2018) and Imai & Kim (2021). The paper's value-added lies in repackaging these known results as an operational diagnostic for political scientists---a valid but inherently narrower contribution. The main weakness is that the paper has not yet convincingly demonstrated that this repackaging solves a problem that the existing literature leaves unsolved. The strongest parts---the "foreign collider bias" concept, the Rogowski et al. application showing the limits of the formula, and the DiD decomposition---deserve more prominence.

## Hierarquia Edmans aplicada

The contribution is the bottleneck. Execution is already quite strong---the simulations are thorough, the applications are well-chosen, and the authors are transparent about limitations. Exposition is good, with room for tightening. But investing in further execution improvements (more simulations, more applications) will not help if the contribution claim is not sharpened. The central question is: what does the reader learn from this paper that they could not learn by reading Blackwell & Glynn (2018, p. 1073), Imai & Kim (2021, Table 1), and any standard econometrics textbook on the FWL theorem? The authors gesture at the answer---operational diagnostic, named problem, quantification gap---but they need to make it much more concrete and demonstrate it with a killer example.

## Prioridades para revisao

1. **Sharpen the contribution claim.** The paper must identify clearly what problem IVB solves that was previously unsolvable. The "foreign collider bias" concept and the quantification gap (DAGs tell you *whether*, IVB tells you *how much*) are promising, but they need to be the headline, not buried in Section 3. The current framing ("we repackage known algebra as a diagnostic") is honest but undersells the paper.

2. **Strengthen the empirical payoff.** Across six studies and 14 collider candidates, the median IVB is 0.13 standard errors---essentially zero. The one interesting case (Rogowski et al., 58% of beta) is causally ambiguous. This raises a troubling question: if IVB is almost always negligible, why does the reader need the formula? The paper needs either (a) an application where IVB is consequential and the formula resolves an ambiguity that changes a published conclusion, or (b) a more convincing argument for why knowing that IVB is small is itself valuable (the "verification" argument needs strengthening).

3. **Clarify the relationship to Blackwell & Glynn more precisely.** The paper claims to be complementary, not adversarial. But the benchmark recommendation (ADL + FE with lagged state variables) is essentially what BG already recommend for the CET. The paper needs to articulate what it adds beyond the BG recommendation---presumably the diagnostic formula and the Monte Carlo evidence that quantifies "how much" the specification choice matters.

4. **Tighten the DiD section.** Section 6 (Jensen extension) feels like a separate paper grafted onto the TSCS paper. It broadens scope but dilutes focus. Either develop it fully (with its own simulations and multiple applications) or demote it to a brief discussion of extensibility.

5. **Reduce length.** The paper is long. Appendices A-B (full derivations of known algebra) can be shortened significantly. The six classification tables in Appendix I are useful but could be condensed. The paper would benefit from being 20-25% shorter overall.

## Recomendacao estrategica ao autor

This paper is a reasonable fit for **Political Analysis** or **PSRM** as a methodological contribution to political science. It is not, in its current form, competitive for APSR/AJPS/JOP---the contribution would need to be substantially larger (e.g., discovering that a major published finding is overturned by IVB) or the theoretical framework would need to generate genuinely new insights beyond repackaging FWL. For PA/PSRM, the paper is close: the execution is strong, but the contribution needs sharpening along the lines described above. A major revision focused on points 1-3 above could make it publishable. The authors should resist the temptation to add more material; instead, they should cut and sharpen.

---

## Parecer completo --- Contribution

### Score: 5/10

### Resumo da contribuicao alegada

The paper claims two contributions: (1) the IVB formula, which quantifies the change in the treatment estimate caused by including or excluding a covariate, using quantities the researcher already has; and (2) a benchmark ADL + FE specification with lagged state variables for the contemporaneous treatment effect in TSCS settings. The formula is presented as the mirror image of OVB, and the benchmark is validated through 238 DGP Monte Carlo simulations and six empirical applications.

### Avaliacao por dimensao

#### Novidade [Fraca]

The IVB formula is, by the authors' own admission, an algebraic identity of OLS via the Frisch-Waugh-Lovell theorem. The short-vs-long regression decomposition is textbook material (Goldberger 1991, Angrist & Pischke 2009). The authors acknowledge this directly: "Our contribution is not the algebra but its repackaging as an operational diagnostic for TSCS settings" (Section 4). This is an honest but double-edged framing. The "repackaging" claim means the novelty must come from the application context, not the result itself.

The benchmark recommendation---use ADL + FE with lagged state variables for the CET---is consistent with and largely reproduces what Blackwell & Glynn (2018, p. 1073) and Imai & Kim (2021, Table 1) already recommend. The paper states this explicitly: "This recommendation is consistent with and reinforces the qualitative guidance of Blackwell and Glynn (2018)... and of Imai and Kim (2021)." The incremental novelty is the quantitative diagnostic formula and the systematic Monte Carlo evidence, but neither produces a surprising or counter-intuitive finding. The main empirical finding---that IVB is almost always negligible in practice (median 0.13 SE)---is reassuring but does not generate a large Bayesian update.

The concept of "foreign collider bias" (Section 3.2) is the most novel element---the idea that identifying colliders requires consulting literatures outside the researcher's primary domain. This is a genuine insight, but it is presented as a descriptive label rather than developed as a theoretical contribution.

#### Importancia [Adequada]

The problem the paper addresses---which time-varying covariates to include in TSCS regressions---is genuinely important and ubiquitous in applied political science. The paper is correct that researchers routinely face this decision and that existing heuristics ("control checking," "confounding checking") are insufficient. A survey paper on TSCS methods would likely mention IVB if it became established terminology.

However, the practical payoff is modest. Across six published studies and 14 collider candidates, IVB is almost always negligible. The one case where it matters (Rogowski et al.) is causally ambiguous. This raises a fundamental question: if the formula almost always returns "don't worry," does the applied researcher need it? The paper's answer---"knowing that is itself the point"---is valid but not fully convincing. Applied researchers already have the short-vs-long comparison available; naming it "IVB" and providing a formula is incrementally helpful but not transformative.

The benchmark recommendation has more practical importance, but it is not new. The paper's value here is in the Monte Carlo evidence that quantifies the benchmark's performance across 238 DGPs. This is useful for practitioners who want numerical reassurance.

#### Adequacao ao escopo [Adequada]

The bibliography is predominantly from political science (comparative politics, IPE) and econometrics. The applications span six studies in CP/IPE. The paper is squarely within the scope of a methods journal targeting political scientists (Political Analysis, PSRM). It would be less appropriate for a general-interest political science journal (APSR, AJPS) because the contribution is methodological rather than substantive.

#### Generalizabilidade [Forte]

The IVB formula is an algebraic identity that holds for any nested linear models---cross-sectional, TWFE, ADL, with any treatment type. The Monte Carlo simulations cover a wide range of DGPs (collider, dual-role, mediator, nonlinear, feedback). The six empirical applications span different substantive domains, treatments (binary and continuous), and outcome types. The paper's scope conditions are clearly stated: the benchmark is local to the CET, requires sufficiently large T, and does not address unobserved contemporaneous confounding. This is a strength.

#### Trade-offs [Completo]

The paper is commendably balanced about the limits of IVB. Section 4.6 (Interpretation Caveats) explicitly addresses the three cases (collider, confounder, mediator) and notes that the formula alone cannot distinguish them. The Rogowski et al. application (Section 7.2) is presented as a case where "a large IVB does not automatically imply collider bias." The limitations section in the conclusion is thorough: the benchmark does not address unobserved confounding, is local to the CET, requires large T, and assumes approximate linearity. The discussion of trade-offs between OVB and IVB in the dual-role case is also well-handled.

#### Hipoteses [Claras e direcionais]

This is a methodology paper, so the relevant "hypotheses" are about the performance of the diagnostic and the benchmark. The paper's predictions are clear and directional: (1) the IVB formula should quantify the specification shift exactly (it does, by algebraic identity); (2) the ADL benchmark should keep bias below 3% of beta (confirmed across 238 DGPs); (3) the empirical IVB should typically be small (confirmed: median 0.13 SE). The theoretical framework (DAGs + FWL decomposition) generates clear predictions that are tested systematically.

### Veredicto geral sobre contribution

The paper addresses a real and important problem in applied TSCS research. Its execution is strong and its framing is honest. However, the contribution is inherently constrained by two facts: the algebra is known, and the benchmark recommendation largely echoes existing guidance. The paper's incremental contribution---naming the diagnostic, quantifying it with a formula, and validating the benchmark across 238 DGPs---is real but narrow. The empirical applications reinforce rather than surprise: IVB is almost always small. For a top methods journal (PA, PSRM), this is on the boundary of sufficiency. The contribution would be substantially strengthened if the authors could either (a) find an application where IVB changes a published conclusion, or (b) develop the "foreign collider bias" concept into a more substantial theoretical contribution.

### Sugestoes construtivas

1. **Lead with the quantification gap, not the algebra.** The paper's strongest claim is that DAGs tell you *whether* a variable is a collider, but not *how much* bias results. Make this the first sentence of the abstract and develop it as the core contribution. Currently, the formula is introduced before the problem is fully motivated.

2. **Develop "foreign collider bias" as a theoretical contribution.** This is the paper's most original idea. Currently it is a descriptive label in Section 3.2. Consider making it a central concept: when does it arise? What structural features of disciplinary boundaries make it more or less likely? Can you predict which types of controls are most vulnerable?

3. **Find or construct a consequential application.** The current applications show IVB is negligible. This is informative but not exciting. If possible, find a published study where IVB is large enough to change the conclusion---or construct a realistic DGP where it would be. The Rogowski case is close but causally ambiguous.

4. **Clarify the increment over BG and IK more sharply.** Consider a table that lists exactly what this paper provides that BG (2018) and IK (2021) do not. The current discussion is diffuse. A crisp comparison would help the reader assess the marginal contribution.

5. **Consider whether the DiD extension (Section 6) is helping or diluting.** It broadens scope but is not fully developed. If it stays, it needs its own motivation beyond "proof of concept." If it goes, the paper becomes tighter and more focused.

---

## Parecer completo --- Execution

### Score: 7/10

### Tipo de paper: Misto (Methodological/Theoretical with Empirical Applications)

### Resumo da estrategia

The paper combines three execution layers: (1) algebraic derivation of the IVB formula via FWL for cross-sectional, TWFE, and ADL models; (2) Monte Carlo simulations across 238 DGP configurations and 500 replications each, covering collider, dual-role, mediator, nonlinear, and feedback scenarios; and (3) empirical application of the diagnostic to six published TSCS studies, computing the IVB for each control variable and classifying controls via DAG reasoning. The theoretical derivations support the formula; the simulations validate the benchmark; the applications demonstrate practical relevance.

### Principio "Dados vs. Evidencia"

The paper's data constitute evidence for the specific claims being made. The simulations are well-designed to test the benchmark's performance across a wide range of DGPs---they are not just "running the numbers" but are structured to isolate specific mechanisms (collider channels, mediator channels, nonlinearity, feedback). The empirical applications go beyond mechanical computation: the DAG-based classification of controls (Appendix I) requires substantive reasoning, and the Rogowski application explicitly demonstrates where the formula reaches its limits. The distinction between "algebraic identity" (the formula) and "empirical claim" (the benchmark) is clearly maintained throughout.

### Avaliacao por dimensao

#### E.1 Mensuracao [Forte]

The IVB formula is measured exactly---it is an algebraic identity, so there is no measurement error in the formula itself. The simulated DGPs have known true parameters, so the bias metrics are precisely defined. In the empirical applications, the authors use published replication data and replicate the original specifications before computing IVB, which is good practice. The control classifications rely on substantive reasoning grounded in published literature, which is transparent and auditable. One minor concern: the collider classification depends on the researchers' reading of the literature, which is inherently subjective. The paper acknowledges this.

#### E.2 Robustez [Forte]

The robustness evidence is extensive and well-targeted. The 238 DGP configurations cover: (a) collider and dual-role controls with varying persistence; (b) pure mediators and mediator-plus-confounder designs; (c) six types of bounded nonlinearity and two types of unbounded nonlinearity in the collider equation; (d) outcome-to-treatment feedback with varying strength; (e) staggered binary treatment with varying switcher proportions; (f) Callaway-style level-dependent trends; (g) Bellemare-style persistent unobserved confounding. The boundary conditions are clearly identified: the benchmark fails for persistent unobserved confounding (which is expected---this is classical endogeneity) but is robust to everything else. The "firewall" mechanism (Table 2) is a clean demonstration of why outcome persistence drives the bias.

Two robustness concerns are worth noting. First, all simulations use N=100 or N=200 and T=30. The paper would benefit from showing that results hold for smaller T (e.g., T=10-15, which is common in CP). The paper acknowledges that Nickell bias becomes relevant for small T but does not simulate it directly. Second, the nonlinearity tests use specific functional forms; a fully nonparametric DGP (e.g., random forests for the collider equation) would provide stronger evidence that the results are not driven by the choice of functional form.

#### E.3 Selecao amostral [Adequada]

The six empirical applications are selected to cover a range of treatments, outcomes, and subfields. The selection criterion (publicly available replication data with TWFE or panel FE specification) is transparent but creates a potential selection bias toward well-executed studies that may have fewer specification problems. The paper does not claim the six studies are representative; they are illustrative.

#### E.4 Explicacoes alternativas [Forte]

This is a strength of the paper. The authors are remarkably transparent about alternative interpretations. The Rogowski application (Section 7.2) is explicitly presented as a case where "a large IVB does not automatically imply collider bias"---the same number could reflect appropriate deconfounding. The interpretation caveats section (4.6) systematically works through the three cases (collider, confounder, mediator). The paper never overclaims: it presents the formula as a diagnostic, not a decision rule, and requires the DAG for interpretation.

#### E.5 Variaveis instrumentais [N/A]

The paper does not use instrumental variables. It notes in a footnote that the IVB formula extends to 2SLS second-stage coefficients, which is a useful observation.

#### E.6 Log(1+Y) [Parcialmente aplicavel]

Some of the replicated studies use log GDP per capita, but the paper does not add this transformation---it replicates the original authors' specifications. This is appropriate for a diagnostic paper.

#### E.7 Discretizacao [Adequada]

The simulations cover both binary (staggered) and continuous treatments. The Leipziger application uses a discretized democracy indicator (Lexical Index >= 5), but this is the original authors' choice, not the paper's.

#### T.1 Distancia premissas-conclusoes [Adequada]

The IVB formula is derived from the FWL theorem, which is a mathematical identity. There is no gap between premises and conclusions for the formula itself. The benchmark recommendation, however, requires additional assumptions: linearity (or bounded nonlinearity), sufficient T for Nickell bias to be negligible, and knowledge of the DAG. These assumptions are clearly stated.

#### T.2 Parcimonia [Forte]

The paper's theoretical framework is parsimonious: DAGs classify controls, FWL decomposes the specification shift, the product of two estimable quantities gives the IVB. The mechanism is clear and does not require elaborate modeling assumptions.

#### T.3 Caminho causal [Adequada]

The DAG reasoning is careful in most cases. The classification tables in Appendix I provide references for each causal channel. Some classifications are debatable (e.g., whether liberal democracy is a "weak" collider in Albers et al.), but the paper's approach of requiring evidence from separate studies for both D->Z and Y->Z channels is a reasonable standard.

### Veredicto geral sobre execution

The execution is the paper's strongest dimension. The algebraic derivations are correct and clearly presented. The Monte Carlo design is extensive, well-structured, and covers the relevant boundary conditions. The empirical applications are carefully replicated, with transparent DAG reasoning. The authors are exceptionally honest about limitations---the Rogowski application and the interpretation caveats section demonstrate intellectual integrity that is rare in submitted manuscripts. The main weaknesses are minor: the simulations could explore smaller T, and the nonlinearity tests could be more varied. Overall, this is strong methodological work.

### Sugestoes construtivas

1. **Add simulations with T=10-15.** Many CP panels have short T dimensions. The paper should verify that the benchmark's performance degrades gracefully and quantify the Nickell bias contamination of the IVB components directly, rather than relying on citations to Judson & Owen (1999).

2. **Report standard errors for the IVB estimates.** The paper derives the delta-method variance (Appendix G) but does not report SE(IVB) for the empirical applications. This would make the diagnostic more complete---currently, the reader sees point estimates of IVB but does not know their precision.

3. **Consider a formal sensitivity analysis.** The paper mentions Cinelli & Hazlett (2020) as inspiration. A natural extension would be a sensitivity parameter: "How large would the unobserved collider channel need to be to make IVB exceed 1 SE?" This would give the formula more bite in ambiguous cases like Rogowski et al.

4. **Clarify the DGP for the DiD simulation (Appendix H).** The calibration to Jensen's magnitudes is briefly described but the DGP details are sparse. A reader wanting to replicate would need more information.

5. **Consider adding a power analysis.** Given that IVB is almost always small in the empirical applications, it would be useful to know whether the formula has power to detect consequential IVB when it exists. Under what conditions would IVB exceed 1 SE in a realistic TSCS application?

---

## Parecer completo --- Exposition

### Score: 7/10

### Avaliacao por dimensao

#### Clareza [Boa]

**Qualidade da escrita.** The writing is generally clear, precise, and professional. The prose reads well and avoids jargon where possible. Technical concepts (FWL, collider, d-separation) are introduced with appropriate references. I did not detect significant typos or grammatical errors in the manuscript text (though the R code chunks contain some complex formatting that is harder to evaluate). The use of boxed equations for the main results (Propositions 1-4) is effective for highlighting key formulas.

**Significancia substantiva.** The abstract and introduction contain specific, memorable numbers: "bias below 3% of the treatment effect," "median IVB is approximately 0.13 standard errors," "238 DGP configurations." These are good. The paper consistently distinguishes between statistical significance and substantive magnitude---e.g., the discussion of IVB/SE vs. IVB/beta, and the explicit handling of non-significant treatment effects (reporting "---" instead of meaningless ratios). This is exemplary practice.

**Precisao da linguagem.** The language is precise in most places. The paper is careful to say "algebraic identity" rather than "result" when describing the IVB formula. The scope conditions are precisely stated: "the benchmark is local to the CET," "a lagged control is pre-treatment only relative to the effect of D_t on Y_t." One area where precision could improve: the term "diagnostic" is used throughout but never formally defined. What makes something a "diagnostic" vs. a "decomposition" vs. a "formula"? The paper seems to use these interchangeably.

#### Extensao [Longo]

**Introducao.** The introduction is well-structured and follows the recommended pattern: problem statement, the paper's approach, results, positioning relative to literature. However, it is on the long side---approximately 4-5 pages of dense text (lines 197-217 in the Rmd). The last two paragraphs of the introduction (the "architecture" paragraph and the road map) could be shortened. The road map paragraph is particularly pro-forma and adds nothing.

**Notas de rodape.** The paper has approximately 6-8 footnotes across the main text, which is reasonable. However, some footnotes contain substantive information that arguably belongs in the main text (e.g., the footnote on extending IVB to 2SLS) or in the appendix (e.g., the footnote on few switchers and IVB/SE vs. IVB/beta). The footnote on line 429 (extending to 2SLS and nonlinear models) is particularly long and contains content that either deserves a full appendix treatment or should be cut.

**Extensoes desnecessarias.** The paper includes several components that could be considered extensions:
- **Section 6 (DiD extension):** This is the most significant extension. It broadens scope to a different research design (DiD) and includes an application to Jensen (2025). While interesting, it feels like a separate contribution that dilutes the TSCS focus. It is not fully developed---only one application, and the simulation is relegated to an appendix.
- **Appendices A-B (Full derivations):** These provide step-by-step algebra for results that follow directly from the FWL theorem. For a methods journal audience, these are unnecessary---the derivation in the main text is sufficient. They could be reduced to 1-2 paragraphs noting that "the proof follows from FWL; see supplementary materials."
- **Appendix D (Lag substitution):** This is a useful result but adds to the paper's length. It could be shortened.
- **Six classification tables in Appendix I:** These are thorough but long. Consider condensing into a single summary table with the most important cases, with full details in supplementary materials.

The paper would benefit from being approximately 20-25% shorter. The current length signals that the authors are trying to anticipate every possible objection, which can be counterproductive---it makes the paper harder to read and obscures the main contribution.

#### Citacoes [Precisas]

**Problemas especificos.** The citations are generally appropriate and well-targeted. Key references are correctly characterized:
- Blackwell & Glynn (2018) and Imai & Kim (2021) are accurately described as complementary, not adversarial.
- Caetano & Callaway (2024) and Caetano et al. (2022) are correctly positioned as related DID work.
- The empirical citations supporting collider classifications (Acemoglu et al. 2019 for democracy->GDP, Grundler & Link 2024 for inequality->GDP, etc.) are substantive and appropriate.

One potential issue: the citation of Goldberger (1991, pp. 197-198) for the short-vs-long decomposition is appropriate, but the paper could also cite the more recent and widely-read treatment in Angrist & Pischke (2009, Chapter 3), which it does later but not at the point of first introduction. The citation of Pearl (2013) for "path-tracing formulas" for collider bias quantification is appropriate but somewhat niche---the more widely-known reference for collider bias quantification in epidemiology is Greenland (2003), which is also cited.

No systematic citation problems detected. The paper does not engage in strategic citation inflation or mis-citation.

### Veredicto geral sobre exposition

The paper is well-written, clearly structured, and precise in its claims. The main exposition weakness is length: the paper tries to do too much (TSCS formula + benchmark + DiD extension + six applications + nine appendices) and would benefit from strategic cutting. The writing quality is consistently good, with effective use of concrete numbers and careful scope qualifications. The DAG figures are well-designed and clearly labeled. The tables are informative and properly formatted. The main structural choice that could be reconsidered is the placement of the DiD section (Section 6), which interrupts the flow from the TSCS benchmark (Section 5) to the empirical applications (Section 7).

### Top 5 sugestoes de melhoria

1. **Cut Appendices A-B to brief sketches.** The full derivations of the FWL-based decomposition are step-by-step proofs of a known identity. For the target audience (methods-literate political scientists), the main-text derivation is sufficient. Replace with "Proof: By FWL, [key step]. See supplementary materials for the complete algebra." This saves 2-3 pages.

2. **Restructure: move the DiD section after the empirical applications, or make it a brief "Extensions" discussion.** Currently, Section 6 (DiD) separates the simulation benchmark (Section 5) from its empirical validation (Section 7). This breaks the narrative arc. Consider: Sections 1-5 (problem, DAGs, formula, benchmark) -> Section 6 (applications) -> Section 7 (extensions to DiD) -> Section 8 (conclusion). Alternatively, reduce Section 6 to 1-2 paragraphs in the conclusion noting the extensibility.

3. **Add a "one-page summary" or workflow diagram.** The paper introduces many concepts (IVB formula, OVB comparison, timing logic, benchmark specification, diagnostic recipe, DAG classification, foreign collider bias). A single-page visual summary---perhaps a flowchart showing the decision tree from "I have a candidate control Z" to "include Z_t / include Z_{t-1} / exclude Z / compute IVB"---would be extremely valuable for the applied reader who wants to use this in practice.

4. **Tighten the introduction by removing the road map paragraph.** The final paragraph of the introduction ("The remainder of this paper is organized as follows...") is pure boilerplate. The reader can see the section headings. Remove it and save the space.

5. **Define "diagnostic" precisely.** The paper's central claim is that IVB is a "diagnostic." This term does important work but is never defined. Is it a test (with a rejection threshold)? A measure (with a unit)? A procedure (with steps)? The practical recipe in Section 4.7 comes closest, but a formal definition early in the paper would anchor the reader's expectations. Consider: "A diagnostic, as we use the term, is a quantitative measure that (a) is computable from standard regression output, (b) has a natural benchmark for 'large' vs. 'small,' and (c) requires external information (here, a DAG) for causal interpretation."
