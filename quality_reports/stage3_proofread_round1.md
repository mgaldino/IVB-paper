# Stage 3: Proofread Review -- Round 1

**Reviewer:** Proofread Reviewer Agent
**Date:** 2026-02-10
**File reviewed:** `ivb_paper_psrm.Rmd` and `references.bib`

---

## Issue Table

| # | Line(s) | Current Text | Proposed Correction | Category |
|---|---------|-------------|-------------------|----------|
| 1 | 31 (abstract) | `$\text{IVB} = -\theta^{\star} \times \pi$` | Consider using the cross-section notation `$-\beta_2^{\star} \times \phi_1$` or explicitly stating this is the ADL notation. The abstract uses the ADL notation ($\theta^{\star}$, $\pi$) while the first derivation (Proposition 1, line 306) uses the cross-section notation ($\beta_2^{\star}$, $\phi_1$). A reader encountering the abstract formula first may be confused when the cross-section result uses different symbols. | Consistency (notation) |
| 2 | 61 (Intro) | `$\text{IVB} = -\theta^{\star} \times \pi$` (eq:ivb_main) | Same as #1. The "main" equation label uses ADL notation but the first formal derivation uses different symbols. Either harmonize notation or add a brief note. | Consistency (notation) |
| 3 | 55 | `...they do not assess whether a candidate control variable is a collider, a variable that is caused by both the treatment and the outcome (or by the treatment and an unobserved common cause of the outcome).` | The parenthetical "(or by the treatment and an unobserved common cause of the outcome)" is a good clarification but creates a very long sentence (6 lines). Consider splitting into two sentences for readability. | Style (sentence length) |
| 4 | 83 | `I include them as control to provide` | This is a direct quote from Dietrich (2016), so it cannot be changed. However, the original text has a grammatical issue: "as control" should be "as controls" (plural). Consider adding `[sic]` after "control" to signal this is faithful to the original. | Grammar (in quotation) |
| 5 | 72 | `Section 2 reviews...Section 3 introduces...Section 4 presents...Section 5 validates...Section 6 provides...Section 7 concludes` | Hard-coded section numbers. If sections are reordered or a section is added/removed, these will be wrong. Consider using `Section~\ref{sec:control}` etc. instead. | Formatting (cross-references) |
| 6 | 745 | `Following the three-step recipe from Section 4.5:` | Hard-coded section number. Should be `Section~\ref{sec:recipe}` for robustness. | Formatting (cross-references) |
| 7 | 152 | `\label{fig:three_structures}` | This figure label is defined but never referenced via `\ref{}` in the text body. The figure is introduced only by proximity, not by explicit cross-reference. Add something like "Figure~\ref{fig:three_structures} displays..." in the text before or after the figure. | Formatting (unused label) |
| 8 | 242 | `\label{fig:dag_collider}` | Same issue: `fig:dag_collider` is defined but never referenced via `\ref{}` in the text. | Formatting (unused label) |
| 9 | 57 | `...which are ubiquitous in comparative politics and international relations \citep{beck1995what, franzese2007spatial}` | The word "ubiquitous" is strong. Consider "common" or "widespread" unless you intend to assert near-universal use. | Style (word choice) |
| 10 | 89 | `A slightly better heuristic is to survey the literature...` | "Slightly better" is informal and somewhat vague for academic writing. Consider "A more targeted heuristic" or "An improved heuristic." | Style (precision) |
| 11 | 93 | `...this heuristic does not assess whether the researcher is inadvertently conditioning on a collider rather than a confounder. In the TSCS context, this omission is particularly dangerous because...` | "This omission" is ambiguous -- it could refer to the heuristic's failure to assess, or to the act of omitting a variable. Consider "This shortcoming" or "This gap in the heuristic" for clarity. | Style (ambiguity) |
| 12 | 105 | `\citet{greenland2003quantifying} quantified collider-stratification bias in linear structural equation models, showing that conditioning on a common effect can induce associations between otherwise independent causes.` | Correct and clear. No change needed. | -- |
| 13 | 105 | `\citet{gaebler2024mitigating} used the exact term ``included variable bias'' in the context of disparate impact estimation, focusing on the legal and fairness implications of conditioning on post-treatment variables.` | "used the exact term" -- consider "coined the term" or "employed the exact term" depending on whether they were the first to use it. If the authors of this paper introduced the term independently, this phrasing is fine. | Style (precision) |
| 14 | 107 | `First, we package the collider bias formula explicitly as an OVB/IVB parallel---a pedagogical device that makes the result immediately accessible...` | "pedagogical device" could be perceived as dismissive of the contribution's substance. Consider "an analytical framework" or "a parallel framing." | Style (word choice) |
| 15 | 203 | `If, in addition, there exist unobserved factors $U$ that affect both democracy levels and civil war---such as institutional quality, state capacity, or regional instability---then democracy level becomes a **collider**` | "there exist" should be "there exists" (subject-verb agreement: "there exists [a set of] unobserved factors $U$"). However, "there exist" is also acceptable if "factors" is treated as the subject. This is borderline; either form is defensible. | Grammar (borderline) |
| 16 | 241 | `Conditioning on $Dem_{t+1}$ opens a spurious backdoor path $PC_t \to CW_{t+1} \leftarrow U \to Dem_{t+1}$` | The path notation mixes $\to$ and $\leftarrow$. Consider writing this as: `$PC_t \to CW_{t+1} \leftarrow U \to Dem_{t+1}$`. Actually, the path is: $PC_t$ causes $CW_{t+1}$, $U$ causes $CW_{t+1}$ (so the arrow is $U \to CW_{t+1}$, not $CW_{t+1} \leftarrow U$). The written path reads: "PC_t -> CW_{t+1} <- U -> Dem_{t+1}". This traces PC_t -> CW_{t+1}, then reverses to U (via collider at CW_{t+1}), then goes to Dem_{t+1}. But the spurious path should be through Dem_{t+1} as the collider, not CW_{t+1}. The path should arguably be: $PC_t \to CW_{t+1} \to Dem_{t+1} \leftarrow U \to CW_{t+1}$. This needs careful verification against the DAG. | Consistency (path notation) |
| 17 | 268 | `$\mathbb{E}[e^{\star} \mid D] \neq 0$ in general` | Technically the error in the misspecified model has $\mathbb{E}[e^{\star} \mid D, Z] \neq 0$, not $\mathbb{E}[e^{\star} \mid D] \neq 0$. The conditioning set in the long regression includes both $D$ and $Z$. The statement that $\mathbb{E}[e^{\star} \mid D] \neq 0$ may or may not hold depending on the DGP. What matters is that conditioning on $Z$ (through inclusion in the regression) induces bias. | Consistency (conditioning set) |
| 18 | 340 | `OVB captures the effect of an omitted common cause channeled through the treatment-outcome relationship, while IVB captures the spurious association created by conditioning on a common effect.` | "channeled through the treatment-outcome relationship" is slightly imprecise. OVB captures the bias from an omitted common cause channeled through the *association between the omitted variable and the treatment*. Consider revising for precision. | Style (precision) |
| 19 | 421 | `$Z_t \sim D_{t-j} + W_t$` | The tilde `~` notation (as a formula operator from R's `lm()`) is used here. In the rest of the paper, regression equations use `=` signs. This is a minor inconsistency -- the `~` notation appears twice (here and line 898). | Consistency (notation) |
| 20 | 428 | `\citet{nickell1981biases} bias` | "Nickell bias" or "Nickell (1981) bias" -- the current phrasing `\citet{nickell1981biases} bias` will render as "Nickell (1981) bias". This is grammatically acceptable but slightly awkward. Consider "Nickell bias \citep{nickell1981biases}" or "the bias identified by \citet{nickell1981biases}". | Style (citation flow) |
| 21 | 428 | `...the IVB formula remains an algebraic identity even in this setting---it correctly decomposes the difference between the short and long regression coefficients---but the components $\theta^{\star}$ and $\pi$ will themselves reflect both collider bias and Nickell bias.` | This sentence is 42 words with two em-dash parentheticals. It is grammatically correct but very dense. Consider splitting. | Style (sentence length) |
| 22 | 457 | `The product $\beta_2^{\star} \times \phi_1$ will be non-zero whenever $Z$ is correlated with both $D$ and $y$ conditional on other controls` | "non-zero" vs "nonzero" -- American academic style typically uses "nonzero" (one word, no hyphen). The paper uses "non-zero" on this line. Check journal style. | Consistency (hyphenation) |
| 23 | 459 | `If $Z$ is actually a confounder, the same algebraic decomposition gives the omitted variable bias in the short regression, and it is the *long* regression that is correctly specified.` | Clear and correct. No change. | -- |
| 24 | 470 | `The first DGP is a simple cross-sectional model with $n = 10{,}000$ observations.` | Good use of `{,}` for thousands separator. Consistent throughout. | -- |
| 25 | 580 | `The true effect of Political Change on Civil War is $\beta_{PC} = 5$.` | The number "5" appears as a digit. This is fine in the mathematical/simulation context. Consistent with other instances. | -- |
| 26 | 663 | `Figure~\ref{fig:scatter_cs} displays the cross-sectional results.` | Good use of `~\ref{}`. Consistent. | -- |
| 27 | 738 | `This is not an approximation; it is an algebraic identity that holds in finite samples whenever the OLS estimates are computed on the same data.` | Excellent sentence. No change. | -- |
| 28 | 783 | `A researcher who naively includes Democracy Level would underestimate the true effect.` | "naively" could be perceived as pejorative toward applied researchers. Consider "inadvertently" or "unknowingly." | Style (tone) |
| 29 | 796 | `It complements \citet{blackwell2018make}, who propose sequential g-estimation and marginal structural models as solutions to post-treatment bias in TSCS, by providing a diagnostic formula that does not require the researcher to adopt a different estimation framework.` | Long sentence (40 words). Grammatically correct but dense. Consider splitting after "TSCS" with a new sentence starting "Our formula provides a diagnostic..." | Style (sentence length) |
| 30 | 798 | `...much of the substantive literature on civil war onset employs logit or probit specifications.` | Good and precise. No change. | -- |
| 31 | 798 | `The Frisch--Waugh--Lovell theorem, on which the IVB derivation relies, does not hold for nonlinear link functions, so the IVB formula as stated does not apply to logistic or probit regression.` | "nonlinear link functions" -- consider "nonlinear models" since the FWL issue is not solely about link functions but about the linearity of the projection. However, "link functions" is common in GLM parlance and is acceptable. | Style (precision, borderline) |
| 32 | 806 | `\bibliography{references}` | The file is `references.bib`, so `\bibliography{references}` is correct (no `.bib` extension needed). Good. | -- |
| 33 | 818 | `## Appendix A: Full Cross-Section Derivation` | The Appendix sections use "##" (subsection level) under "# Online Appendix". This means they will be numbered as subsections (A.1, A.2, etc.) rather than separate appendix sections (A, B, C). This may or may not match the intended formatting given `\appendix` resets counters. Verify rendered output. | Formatting (section levels) |
| 34 | 871 | `$\tilde{y}_t \sim \tilde{D}_t + \tilde{Z}_t$` | Same `~` formula notation inconsistency as issue #19. | Consistency (notation) |
| 35 | 1033 | `...both are causes (or functions of causes) of $Z$.` | "both are causes (or functions of causes) of $Z$" -- this says $D$ and $Y$ are causes of $Z$, but the parenthetical "functions of causes" is vague. Consider "both are causes of $Z$ (or correlated with its causes)" for clarity. | Style (precision) |
| 36 | bib:64-73 | `cinelli2021crash` key with `year={2022}` | The citation key suggests 2021 but the actual publication year is 2022. This is a cosmetic bib inconsistency; the rendered output will show "2022" correctly. Consider renaming key to `cinelli2022crash` for tidiness, or leave as is. | Consistency (bib key) |
| 37 | bib:202-210 | `imai2021matching` key with `year={2023}` | Same issue: key says 2021, year is 2023. Not cited in manuscript, so no impact on paper. | Consistency (bib key) |
| 38 | bib (multiple) | 12 entries in `references.bib` are never cited in the manuscript: `angrist2009mostly`, `bell2015explaining`, `callaway2021difference`, `clark2015should`, `dechaisemartin2020two`, `goldberger1991course`, `imbens2004nonparametric`, `imai2019should`, `imai2021matching`, `newman2019mass`, `white2011causal`, `wooldridge2010econometric` | Remove unused entries from `references.bib` or cite them in the manuscript. Unused bib entries will not appear in the rendered bibliography (BibTeX only includes cited entries), but they add clutter to the source file. | Consistency (bibliography) |
| 39 | 155 | `\citep{pearl2018book, elwert2014endogenous}` | The citation order within `\citep{}` is not chronological (Pearl 2018 before Elwert 2014). Standard practice is chronological order within a single `\citep{}` call. Should be `\citep{elwert2014endogenous, pearl2018book}`. | Consistency (citation order) |
| 40 | 85 | `\citep{hahn2004functional, pearl2013linear, cinelli2021crash}` | Citation order is chronological (2004, 2013, 2022). Good. | -- |
| 41 | 55 | `\citep{pearl2009causality, elwert2014endogenous}` | Citation order is chronological (2009, 2014). Good. | -- |
| 42 | 241-242 | `Conditioning on $Dem_{t+1}$ opens a spurious backdoor path $PC_t \to CW_{t+1} \leftarrow U \to Dem_{t+1}$` | Revisiting issue #16 more carefully: The spurious path from conditioning on the collider $Dem_{t+1}$ should be: the backdoor path from $PC_t$ to $CW_{t+1}$ via $U$ and $Dem_{t+1}$. With $Dem_{t+1}$ as the collider (caused by $CW_{t+1}$ and $U$), conditioning on it opens: $PC_t \to CW_{t+1} \to Dem_{t+1} \leftarrow U \dashrightarrow CW_{t+1}$. The path as written ($PC_t \to CW_{t+1} \leftarrow U \to Dem_{t+1}$) actually describes a collider at $CW_{t+1}$, not at $Dem_{t+1}$. This appears to be a **substantive error** in the path description. The collider in the DAG is $Dem_{t+1}$, not $CW_{t+1}$. The spurious path from conditioning on $Dem_{t+1}$ should be: $U \to Dem_{t+1} \leftarrow CW_{t+1}$, which when conditioned on $Dem_{t+1}$ creates an association $U - CW_{t+1}$, biasing the estimate of $PC_t \to CW_{t+1}$ because $U$ also affects $CW_{t+1}$ directly. | Critical (path description) |
| 43 | 107 | `...we distill the formula into a practical three-step diagnostic recipe that requires only standard regression output, lowering the barrier to routine use by applied political scientists.` | The phrase "lowering the barrier" is slightly informal. Consider "making it accessible for routine use by." | Style (register) |
| 44 | 360 | `Define the set of ``legitimate'' controls $W_t = (1, y_{t-1})$` | Using backtick-style LaTeX quotes is correct. Consistent with other uses. | -- |
| 45 | 898 | `$Z_t \sim D_{t-j} + W_t$` | Same `~` formula notation as #19 and #34. Three occurrences total. | Consistency (notation) |
| 46 | 1016 | `...embedded in the R~Markdown source file.` | `R~Markdown` uses a non-breaking space tilde between R and Markdown. This should be either "R Markdown" (two words, regular space) or "RMarkdown" (one word). The tilde here would render as a non-breaking space, which is unusual for a product name. | Formatting (product name) |

---

## Summary of Issues by Category

### Critical Formatting / Substantive Issues
- **#42**: The backdoor path description in Figure 3's caption appears to trace a collider at $CW_{t+1}$ rather than at $Dem_{t+1}$, which contradicts the DAG structure being described. This needs careful verification.

### Formatting Issues (cross-references, LaTeX)
- **#5, #6**: Hard-coded section numbers instead of `\ref{}` cross-references (2 instances)
- **#7, #8**: Figures with `\label{}` defined but never cross-referenced via `\ref{}` (2 instances)
- **#33**: Appendix subsection levels may not render as intended
- **#46**: `R~Markdown` non-breaking space in product name

### Consistency Issues
- **#1, #2**: Notation mismatch between abstract/intro formula and first derivation ($\theta^{\star}/\pi$ vs $\beta_2^{\star}/\phi_1$)
- **#19, #34, #45**: `~` (tilde) formula notation vs `=` sign notation (3 occurrences)
- **#22**: "non-zero" vs "nonzero" hyphenation
- **#36, #37**: Bib key-year mismatches (2 entries)
- **#38**: 12 unused bib entries
- **#39**: Non-chronological citation order within `\citep{}`

### Grammar Issues
- **#4**: "as control" (should be "as controls") in direct quote -- consider `[sic]`
- **#15**: "there exist" vs "there exists" (borderline, defensible either way)
- **#17**: Conditioning set in error expectation statement

### Style Issues
- **#3, #21, #29**: Long/dense sentences (3 instances)
- **#9**: "ubiquitous" -- strong claim
- **#10**: "slightly better" -- informal
- **#11**: "this omission" -- ambiguous referent
- **#13**: "used the exact term" -- could be more precise
- **#14**: "pedagogical device" -- potentially dismissive
- **#18**: "channeled through the treatment-outcome relationship" -- imprecise
- **#20**: `\citet{nickell1981biases} bias` -- awkward citation flow
- **#28**: "naively" -- potentially pejorative
- **#31**: "nonlinear link functions" -- borderline precision
- **#35**: "functions of causes" -- vague
- **#43**: "lowering the barrier" -- informal register

---

## Score Calculation

**Starting score: 100**

| Deduction | Count | Points Each | Total |
|-----------|-------|-------------|-------|
| Critical formatting/substantive error (#42) | 1 | -10 | -10 |
| Formatting issues (#5, #6, #7, #8, #33, #46) | 6 | -1 | -6 |
| Grammar issues (#4, #15, #17) | 3 | -2 | -6 |
| Consistency issues (#1-2 as one, #19/34/45 as one, #22, #36, #37, #38, #39) | 7 | -1 | -7 |
| Style nitpicks (#3, #9, #10, #11, #13, #14, #18, #20, #21, #28, #29, #31, #35, #43) | 14 | -0.5 | -7 |

**Final Score: 100 - 10 - 6 - 6 - 7 - 7 = 64**

---

## Verdict: REPROVADO (64 / 100)

### Key Actions Required

1. **[CRITICAL] Verify and fix the backdoor path description in Figure 3's caption (line 241-242).** The path `$PC_t \to CW_{t+1} \leftarrow U \to Dem_{t+1}$` describes a collider at $CW_{t+1}$, but the text and DAG identify $Dem_{t+1}$ as the collider. This is the single most important issue.

2. **[HIGH] Replace hard-coded section numbers with `\ref{}` cross-references** (lines 72, 745). This prevents broken references if sections are reordered.

3. **[HIGH] Add `\ref{}` cross-references for Figures 1 and 3** (labels `fig:three_structures` and `fig:dag_collider`), which are defined but never referenced in the text.

4. **[MEDIUM] Harmonize notation between the abstract/introduction formula and the cross-section derivation.** Either use the same symbols throughout or add an explicit note explaining the two notations.

5. **[MEDIUM] Replace `~` formula notation with `=` in the three occurrences** (lines 421, 871, 898) for consistency with the rest of the paper.

6. **[LOW] Clean up bib file**: remove 12 unused entries and consider fixing key-year mismatches.

7. **[LOW] Address style issues**: long sentences, informal register in several places, and minor wording improvements as detailed in the table above.

---

*Report generated by Proofread Reviewer Agent, 2026-02-10*
