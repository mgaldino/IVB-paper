# Stage 3: Proofread Review -- Round 1

**Reviewer:** Proofread Reviewer Agent (Claude Opus 4.6)
**Date:** 2026-03-01
**Files reviewed:** `ivb_paper_psrm.Rmd` (1389 lines) and `references.bib` (572 lines)

---

## Summary

The manuscript is well written, with clear prose and rigorous mathematical exposition. The main issues are: (a) minor notation inconsistencies in how IVB/SE is typeset across sections, (b) a variable-name collision in the Rogowski equation, (c) four unused bibliography entries, and (d) a few minor grammar/style points. No critical broken references or wrong numbers were found. The "14 collider candidates" count, "57 study-control combinations" count, "0.13" median, and "2.11 / 58%" Rogowski outlier are all internally consistent across abstract, introduction, body, and conclusion.

---

## Issue Table

| # | Line(s) | Current Text | Proposed Correction | Category | Severity |
|---|---------|-------------|---------------------|----------|----------|
| 1 | 621 | Two different notations in one sentence: first `$\|\text{IVB}\|/\text{SE}(\hat\beta)$` (abs value on IVB only, SE with argument), then `$\|\text{IVB}/\text{SE}\| > 1$` (abs value around entire ratio, SE without argument) | Pick one notation and use it consistently. Recommended: `$\|\text{IVB}/\text{SE}\|$` throughout, since SE is always positive and the shorter form is used more frequently (lines 32, 77, 701, 705, 797, 906). | Notation | Major (-3) |
| 2 | 883 | `$\|\text{IVB}\|/\text{SE} = ...`$ (abs value on IVB only, SE without argument, no hat-beta) | Should match the chosen convention from issue #1. Currently a third variant. | Notation | Major (-3) |
| 3 | 878 | Column header `"$\|\\text{IVB}\|$/SE"` -- SE is outside math mode | Should be fully in math mode, e.g., `"$\|\\text{IVB}\|/\\text{SE}$"` to match other table headers. | Formatting | Minor (-1) |
| 4 | 779 | `$\\lvert\\text{IVB}\\rvert / \\text{SE}(\\hat\\beta)$` uses `\lvert`/`\rvert` | The rest of the paper uses `\|` for absolute value. Should be consistent: either always `\lvert`/`\rvert` or always `\|`. | Notation | Minor (-1) |
| 5 | 806 | `\mathbf{Z}'_{it}\gamma + \delta_i + \gamma_t` -- `\gamma` is used both as the coefficient vector on controls and as the time fixed effect subscript | Rename one: e.g., use `\boldsymbol{\psi}` or `\boldsymbol{\lambda}` for the control coefficient vector, or use `\mu_t` for time FE (as in other equations in the paper, e.g., line 574 uses `\mu_t`). | Notation | Major (-3) |
| 6 | 32 (abstract) | "median IVBs are below 0.15 standard errors" | Body (line 701) and conclusion (line 906) say "approximately 0.13". The abstract's "below 0.15" is not wrong but is imprecise. For consistency, consider "approximately 0.13 standard errors" or "below 0.15 standard errors (median approximately 0.13)" in the abstract. | Consistency | Minor (-1) |
| 7 | 604 | `$\|\text{IVB}\|/\text{SE}$` (abs value on IVB only) | This is the "Mechanism C" discussion. Should match the chosen convention from issue #1. | Notation | (counted in #1) |
| 8 | 703 | "The IVB/SE metric avoids the pitfalls..." and "The IVB/SE metric reveals..." -- plain text "IVB/SE" not in math mode | These informal references to the metric are acceptable in running prose but could be formatted as `$\text{IVB}/\text{SE}$` for consistency with the rest of the paper. | Formatting | Minor (-1) |
| 9 | references.bib | `franzese2007spatial` -- defined in .bib but never cited in the manuscript | Remove from .bib or add a citation. Unused entries generate no LaTeX error with natbib but clutter the bibliography source. | Reference | Minor (-1) |
| 10 | references.bib | `yao2021survey` -- defined in .bib but never cited in the manuscript | Same as #9. | Reference | Minor (-1) |
| 11 | references.bib | `angrist_pischke2009` -- defined in .bib but never cited in the manuscript | Same as #9. | Reference | Minor (-1) |
| 12 | references.bib | `stasavage2005` -- defined in .bib but never cited in the manuscript | Same as #9. | Reference | Minor (-1) |
| 13 | 90 | `I include them as control [sic] to provide a fully specified model` | The `[sic]` is correctly present -- good. No change needed. | -- | -- |
| 14 | 125 | "All DAGs comprise three primary structures: chains, forks, and colliders (or inverted forks), shown in Figure~\ref{fig:three_structures}." | Good -- this correctly references the figure label. No issue. | -- | -- |
| 15 | 596 | `Figures~\ref{fig:fig-heatmap-A} and \ref{fig:fig-heatmap-B}` | These reference R chunk-generated figures from chunks named `fig-heatmap-A` and `fig-heatmap-B`. In RMarkdown with bookdown-style cross-referencing, chunk-based figure labels take the form `fig:chunk-name`. However, with standard `pdf_document` output (not `bookdown::pdf_document2`), `\ref{fig:fig-heatmap-A}` will NOT resolve because `knitr::include_graphics` with `fig.cap` does not automatically generate `\label{}` tags in standard `pdf_document`. The figure captions at lines 588 and 592 do not contain explicit `\label{}` commands. These cross-references will produce "??" in the compiled PDF. | Critical (-5) |
| 16 | 596 | Same line: references to `fig:fig-heatmap-B` | Same issue as #15. Both heatmap figure cross-references will be broken. | (counted in #15) |
| 17 | 77 | "Among the 14 theoretically motivated collider candidates across six studies" | Verified: counting from the `collider_candidates` list (lines 630-640): Claassen(1) + Leipziger SEI(1) + Leipziger ext.(2) + Blair(3) + Albers(3) + Rogowski(1) + Ballard-Rosa(3) = 14. Correct. | -- | -- |
| 18 | 694 | "all 57 study-control combinations" | This claim depends on `standardized_ivb_metrics.csv` containing exactly 57 rows. Cannot verify the CSV count from the manuscript alone, but the claim is used consistently at lines 619, 694, and 1352. | -- | -- |
| 19 | 279 | `$\mathbb{E}[e^{\star} \mid D] \neq 0$` | Strictly, the relevant statement is `$\mathbb{E}[e^{\star} \mid D, Z] \neq 0$` since the long regression conditions on both D and Z. The text says "conditioning on the collider Z opens a spurious path" which implies the issue arises when Z is included. The conditioning set in the statement is incomplete. However, one could argue the statement is about the marginal (unconditional on Z) error, which would be non-zero due to the collider path. This is a subtle point; the current wording is defensible but imprecise. | Consistency | Minor (-1) |
| 20 | 714 | Leipziger equation uses `\delta_i` for unit FE and `\gamma_t` for time FE | Consistent within this equation (no collision), but at line 806 `\gamma` and `\gamma_t` clash. This equation is fine on its own. | -- | -- |
| 21 | 1057-1058 | Comment says "delta_d/delta_y correspond to gamma_D/gamma_Y in Section 5 notation" | Good documentation. The naming difference between Appendix C/D code and Section 5 text is acknowledged in the comment. | -- | -- |
| 22 | 32 (abstract) | "We characterize structural conditions---fixed effects absorbing between-unit variation, few treatment switchers, measurement error in controls---" | The conclusion (line 906) lists four mechanisms: "fixed effects absorbing between-unit variation in the collider channels, binary treatments with few switchers, measurement error in the collider, and cross-sectional dominance in the D->Z or Y->Z pathways". The abstract lists only three, omitting "cross-sectional dominance." | Consistency | Minor (-1) |
| 23 | 906 (conclusion) | "four mechanisms---fixed effects absorbing between-unit variation in the collider channels, binary treatments with few switchers, measurement error in the collider, and cross-sectional dominance in the $D \to Z$ or $Y \to Z$ pathways" | The fourth mechanism ("cross-sectional dominance") is arguably the same as "fixed effects absorbing between-unit variation" stated differently. The abstract's three-item list and the conclusion's four-item list describe the same content with different granularity. This is minor but could confuse a careful reader. | Consistency | Minor (-1) |
| 24 | 71 | Footnote: "In the cross-sectional derivation, $\theta^{\star}$ corresponds to $\beta_2^{\star}$ and $\pi$ corresponds to $\phi_1$; we use the ADL notation throughout the paper as it is the more general form." | Good -- this footnote addresses the notation discrepancy between the abstract/intro (ADL notation) and Section 4.1 (cross-section notation). However, "we use the ADL notation throughout the paper" is slightly inaccurate since Section 4.1 uses cross-section notation ($\beta_2^{\star}$, $\phi_1$). More precise: "we use the ADL notation in all subsequent sections." | Consistency | Minor (-1) |
| 25 | 1261 | "Collider + Confdr." -- abbreviation "Confdr." | Should be "Confounder" (spelled out) for consistency with other table entries, or at minimum "Confndr." The abbreviation "Confdr." is unusual and could be misread. | Formatting | Minor (-1) |
| 26 | 919-920 | `\bibliographystyle{apsr}` and `\bibliography{references}` | Uses natbib with APSR style. This is standard. The .bib file is named `references.bib`, matching the `\bibliography{references}` call. No issue. | -- | -- |
| 27 | 164 | `\citep{elwert2014endogenous, pearl2018book}` | Verified: both keys exist in .bib. No issue. | -- | -- |
| 28 | All | All `\citep{}`, `\citet{}`, and `\citealt{}` keys | Verified against references.bib. All citation keys used in the manuscript resolve to entries in the .bib file. No dangling references found. | -- | -- |
| 29 | All | Section cross-references (`\ref{sec:...}`, `\ref{eq:...}`, `\ref{prop:...}`, `\ref{tab:...}`, `\ref{fig:...}`, `\ref{app:...}`) | All `\label{}` targets used in `\ref{}` commands have corresponding definitions, with the exception of issue #15 (fig:fig-heatmap-A and fig:fig-heatmap-B, which depend on R chunk label generation that may not work with standard pdf_document). All other cross-references are sound. | -- | -- |
| 30 | 77 | "We examine two cases in detail: \citet{leipziger2024}, where GDP per capita as a collider attenuates the democratization effect by approximately 16\% of $\hat\beta$ but only half a standard error" | The inline R code at line 795 computes `round(abs(r_lp$ivb_formula / r_lp$beta_long) * 100, 0)` and the table at line 787 computes the same ratio. The hardcoded "16%" and "half a standard error" in the introduction must match the computed values. If the data or replication code changes, these hardcoded numbers could become stale. Consider using inline R for these intro claims, or add a comment flagging them as hardcoded. | Consistency | Minor (-1) |
| 31 | 32 (abstract), 77 (intro), 906 (concl.) | "six published studies" | Verified: Claassen 2020, Leipziger 2024, Blair et al. 2022, Albers et al. 2023, Rogowski et al. 2022, Ballard-Rosa et al. 2021 = 6 studies. The `collider_candidates` list has 7 entries, but "Leipziger (SEI)" and "Leipziger (SEI ext.)" are two specifications from the same study. Correct. | -- | -- |
| 32 | 617 | "spanning four substantive domains: democratization and public opinion, democracy and ethnic inequality, UN peacekeeping and democratization, fiscal capacity in Africa, postal infrastructure and growth, and sovereign bond denomination" | The text says "four substantive domains" but lists six study topics. These six topics could be grouped into four domains, but the grouping is not made explicit. Consider either saying "six substantive areas" or explicitly naming the four domains. | Consistency | Minor (-1) |
| 33 | 1225 | "Collider candidate for Table~\ref{tab:ivb_summary}: Log GDP p.c." -- sentence continues: "GDP growth shares the same mechanism but is excluded from the main table to avoid double-counting the same causal channel." | But in the `collider_candidates` R code (line 631), only "Log GDP p.c." is listed for "Claassen (FE)", which matches this explanation. However, the Claassen classification table (line 1217) also classifies GDP growth as "Collider (weak)". The text explains the exclusion, so this is fine. No issue. | -- | -- |
| 34 | 574 | `Z_{it} = \gamma_D^{\text{btw}} \mu_i^D + \gamma_D^{\text{wth}} (D_{it} - \mu_i^D) + \gamma_Y Y_{it} + \eta_i + \mu_t + \nu_{it}` | Here `\mu_i^D` is the unit mean of D and `\mu_t` is the time fixed effect, while `\eta_i` is the unit fixed effect. This notation is internally consistent within Section 5. No collision. | -- | -- |
| 35 | 443 | "The identity $\hat{\beta}^{\star} - \hat{\beta} = -\hat{\theta}^{\star} \times \hat{\pi}$ holds by construction" | Uses hat notation for sample quantities, consistent with the discussion being about finite-sample OLS. Good. | -- | -- |

---

## Detailed Notes on Specific Categories

### A. Grammar and Typos

No significant grammatical errors or typos were found in the prose. The writing is polished and precise. The `[sic]` at line 90 is correctly placed. Punctuation around em-dashes, en-dashes, and LaTeX formatting is consistent.

### B. LaTeX/RMarkdown Cross-References

**Critical issue (Issue #15):** The references `\ref{fig:fig-heatmap-A}` and `\ref{fig:fig-heatmap-B}` at line 596 rely on automatic label generation from R chunk names. With standard `pdf_document` output (as specified in the YAML header at line 9), `knitr::include_graphics()` with `fig.cap` does not generate `\label{}` tags. These cross-references will produce "??" in the compiled PDF unless:
- The output format is switched to `bookdown::pdf_document2`, or
- Explicit `\label{fig:fig-heatmap-A}` tags are added inside the `fig.cap` strings.

All other cross-references (`\ref{sec:...}`, `\ref{eq:...}`, `\ref{prop:...}`, `\ref{tab:...}`, `\ref{app:...}`) are correctly paired with `\label{}` definitions.

### C. Notation Consistency

The main notation issue is the IVB/SE metric, which is written in at least three different ways:
1. `$|\text{IVB}/\text{SE}|$` -- absolute value around ratio (most common: abstract, intro, conclusion, line 701)
2. `$|\text{IVB}|/\text{SE}(\hat\beta)$` -- absolute value on IVB only, SE with argument (line 621)
3. `$|\text{IVB}|/\text{SE}$` -- absolute value on IVB only, SE without argument (line 883)
4. `$\lvert\text{IVB}\rvert / \text{SE}(\hat\beta)$` -- lvert/rvert delimiters (line 779)

All are mathematically equivalent, but the visual inconsistency is distracting. Recommend standardizing on form #1 throughout.

The $\gamma$ collision at line 806 (Rogowski equation) is a notation bug that should be fixed before submission.

### D. Citation Consistency

All 50+ citation keys in the manuscript resolve to entries in `references.bib`. No dangling citations.

Four .bib entries are never cited:
- `franzese2007spatial`
- `yao2021survey`
- `angrist_pischke2009`
- `stasavage2005`

With natbib, these unused entries will not appear in the compiled bibliography (only cited works are included), so they do not cause errors. However, they add clutter to the source file.

Two entries that are cited via `\citealt{}` (not `\citet{}` or `\citep{}`):
- `\citealt{albers_etal2023}` at line 701
- `\citealt{ding2015adjust}` at lines 552, 554
- `\citealt{rogowski_etal2022}` at line 1268
- `\citealt{alesina_tabellini1990}` at line 1348
- `\citealt{alesina1987}` at line 1348
- `\citealt{eichengreen2005}` at line 1348

All verified present in .bib. `\citealt{}` produces author-year without parentheses, appropriate for its uses inside parenthetical contexts.

### E. Number Consistency

| Claim | Abstract (L32) | Intro (L77) | Body | Conclusion (L906) | Status |
|-------|----------------|-------------|------|-------------------|--------|
| Number of studies | 6 | 6 | 6 (L617) | 6 | OK |
| Collider candidates | -- | 14 | 14 (L701) | 14 | OK |
| Median IVB/SE | "below 0.15" | -- | "approx 0.13" (L701) | "approx 0.13" | Minor discrepancy in precision |
| Rogowski IVB/SE | 2.11 | 2.11 | 2.11 (L701) | 2.11 | OK |
| Rogowski IVB % | 58% | 58% | 58% (L701, 887) | 58% | OK |
| Study-control combos | -- | -- | 57 (L619, 694) | -- | OK |
| Domains | -- | -- | "four" (L617) but lists 6 topics | -- | See issue #32 |

### F. New Content Quality (Appendix F, IVB/SE narrative, cross-study caveat)

**Appendix F classification tables (lines 1202-1349):** The tables are well structured with consistent column layout (Control, D->Z, Y->Z, Classification, Key references). Each table has a LaTeX caption and uses `\toprule`/`\midrule`/`\bottomrule` formatting. The classification criteria are clearly stated at line 1204. One minor formatting issue: "Collider + Confdr." at line 1261 uses a nonstandard abbreviation.

**IVB/SE narrative (lines 621-705):** The two-metric framework (IVB/SE as primary, IVB/beta% as secondary) is clearly motivated and well executed. The explanation of why IVB/beta is unreliable when beta is near zero (line 703, Claassen example) is a strong addition.

**Cross-study caveat paragraph (line 705):** Well written and appropriately cautious. The specific numerical example (SE range from 0.005 to 0.216) grounds the caveat concretely.

---

## Scoring

Starting score: **100**

| Deduction | Issue | Points |
|-----------|-------|--------|
| Critical | #15: Broken figure cross-references (fig:fig-heatmap-A, fig:fig-heatmap-B) with standard pdf_document | -5 |
| Major | #1: IVB/SE notation inconsistency (3+ variants) | -3 |
| Major | #2: Additional IVB/SE variant at line 883 | -3 |
| Major | #5: gamma collision in Rogowski equation | -3 |
| Minor | #3: SE outside math mode in table header | -1 |
| Minor | #4: lvert/rvert vs pipe for absolute value | -1 |
| Minor | #6: Abstract "below 0.15" vs body "approx 0.13" | -1 |
| Minor | #8: Plain-text "IVB/SE" in prose | -1 |
| Minor | #9-12: Four unused .bib entries | -1 |
| Minor | #19: Conditioning set E[e* | D] vs E[e* | D,Z] | -1 |
| Minor | #22-23: Three vs four mechanisms (abstract vs conclusion) | -1 |
| Minor | #24: "throughout the paper" footnote slightly inaccurate | -1 |
| Minor | #25: "Confdr." abbreviation | -1 |
| Minor | #30: Hardcoded "16%" in intro | -1 |
| Minor | #32: "four domains" but six topics listed | -1 |

**Total deductions: -26**

**Final score: 74**

---

## Verdict

**REPROVADO [74]**

### Priority fixes (to reach 90+):

1. **[Critical, +5]** Fix figure cross-references at line 596. Either switch to `bookdown::pdf_document2` output or add explicit `\label{fig:fig-heatmap-A}` and `\label{fig:fig-heatmap-B}` inside the `fig.cap` strings of the respective R chunks at lines 588 and 592.

2. **[Major, +9]** Standardize IVB/SE notation throughout. Recommend `$|\text{IVB}/\text{SE}|$` as the canonical form (already the most common). Update lines 604, 621, 779, 878, and 883 to match.

3. **[Major, +3]** Fix the `\gamma` collision in the Rogowski equation at line 806. Replace `\gamma` (control coefficient vector) with a different symbol (e.g., `\boldsymbol{\lambda}`) or replace `\gamma_t` (time FE) with `\mu_t` (matching the notation used at line 574).

4. **[Minor, +5]** Harmonize the abstract's mechanism count (3) with the conclusion's (4), clarify "four substantive domains" at line 617, and align the abstract's "below 0.15" with the body's "approximately 0.13".

Fixing items 1-3 alone would bring the score to 91, passing the threshold.
