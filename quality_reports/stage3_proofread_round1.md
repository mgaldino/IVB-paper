# Proofread Report -- Stage 3, Round 1 (Post-Rewrite)

**Reviewer:** Proofread Agent (Claude Opus 4.6)
**Date:** 2026-03-22
**File reviewed:** `ivb_paper_psrm.Rmd` (1207 lines)
**Scope:** Full manuscript proofread -- grammar, notation, facts, cross-references, formatting

---

## Score: 78
## Status: REPROVADO (<90)

---

## Corrections Proposed

| # | Line(s) | Current Text | Proposed Correction | Category |
|---|---------|-------------|---------------------|----------|
| 1 | 559 | "The full mechanical IVB decomposition for all 57 study-control combinations" | Change "57" to "55" -- the CSV `standardized_ivb_metrics.csv` contains exactly 55 data rows (header + 55 rows, verified by counting). Breakdown: Claassen OLS=5, Claassen FE=4, Leipziger SEI/GRG/GGINI=3, Leipziger SEI ext=5, Blair=6, Albers=12, Rogowski=4, Ballard-Rosa=16. Total=55. | Facto (-5) |
| 2 | 634 | `"The full mechanical decomposition for all 57 study-control combinations "` | Change "57" to "55" (same factual error, repeated in kable caption for Table 1). | Facto (same error, -1) |
| 3 | 1167 | "Table~\ref{tab:ivb-full-table} reports the complete IVB decomposition for all 57 study-control combinations" | Change "57" to "55" (same factual error, third occurrence, in Appendix G text). | Facto (same error, -1) |
| 4 | 987 | "All simulations in this paper are implemented in R and embedded in the R Markdown source file." | This is false. The 238-DGP simulations reported in Section 5 are in external R files (`simulations/v4_mechanisms/`, `simulations/nonlinearity/`, `simulations/dynamics/`, etc.), NOT embedded in the Rmd. The Rmd contains only replication/IVB-computation code for the empirical applications. Rewrite to: "Simulation code is implemented in R. The companion scripts for Section 5 simulations are in the `simulations/` directory; the replication code for Section 6 applications is embedded in the R Markdown source file." | Facto (-5) |
| 5 | 987 | "The code is fully reproducible: all random number generators are seeded, and results can be exactly replicated by compiling the source document." | False for Section 5 simulations -- compiling the Rmd does NOT replicate those simulations. Only the Section 6 replications are embedded. Revise to clarify that Section 5 simulations require running the external scripts. | Facto (counted with #4) |
| 6 | 989-995 | Appendix E describes only 3 DGPs (Cross-section, ADL, Civil War) from `sim_ivb_completa.R` | Appendix E does not describe ANY of the 238 DGP configurations that produce the results in Section 5 (collider/dual-role 48 scenarios, mediator, nonlinearity, feedback). The 3 DGPs described are from the v1 tautological simulation and are not reported in the current paper body. Appendix E needs a complete rewrite to describe the actual simulation families used in Section 5. | Facto (-5) |
| 7 | 995 | `The full simulation code is available in the companion file \texttt{sim\_ivb\_completa.R}.` | `sim_ivb_completa.R` is the old v1 simulation. The Section 5 simulations use multiple files: `sim_mechC_adl.R`, `sim_nl_collider.R`, `sim_nl_interact.R`, `sim_nl_carryover.R`, `sim_direct_feedback.R`, etc. Update to list the correct companion files, or reference the `simulations/` directory as a whole. | Facto (counted with #6) |
| 8 | 481 | "The decomposition $\beta_1^{\star} - \beta_1 = -\beta_2^{\star} \times \phi_1$ is an \textbf{algebraic identity}" | The Caveats section (4.6) uses cross-section notation ($\beta_2^*$, $\phi_1$), but the footnote on line 70 states: "we use the TSCS notation throughout the paper as it is the more general form." In Section 4.6, which comes after the ADL extensions (Sections 4.3-4.5), the TSCS notation ($\theta^*$, $\pi$) should be used for consistency. Change to: "The decomposition $\beta^{\star} - \beta = -\theta^{\star} \times \pi$" (and similarly throughout Section 4.6). | Consistencia (-2) |
| 9 | 337 | "The decomposition $\beta_1^{\star} - \beta_1 = -\beta_2^{\star} \times \phi_1$ is an algebraic identity" (in the Remark) | This Remark appears between the CS derivation (4.1) and OVB-vs-IVB (4.2), so CS notation is contextually defensible. However, since it discusses the formula's "generality" across all specifications, using the TSCS notation ($\theta^*$, $\pi$) would be more consistent with the footnote on line 70. Lower-priority than #8. | Consistencia (-2) |
| 10 | 70 | "we use the TSCS notation throughout the paper as it is the more general form" | If corrections #8 and #9 are NOT applied, this footnote is misleading because the paper uses CS notation in Sections 4.1-4.2 and 4.6. In that case, revise to: "we use the TSCS notation in the general discussion; the cross-sectional notation ($\beta_2^*$, $\phi_1$) appears in Section 4.1 and related passages." | Consistencia (counted with #8-#9) |

---

## Score Calculation

| Category | Items | Deduction |
|----------|-------|-----------|
| Facto incorreto: "57" should be "55" (#1) | 1 distinct error | -5 |
| Facto incorreto: repeated "57" in two more locations (#2, #3) | 2 repetitions | -2 |
| Facto incorreto: Appendix E says sims are embedded in Rmd (#4-5) | 1 distinct error | -5 |
| Facto incorreto: Appendix E describes wrong DGPs (#6-7) | 1 distinct error | -5 |
| Consistencia de notacao: CS notation in Section 4.6 (#8) | 1 | -2 |
| Consistencia de notacao: CS notation in Remark (#9) | 1 | -2 |
| Footnote inaccuracy (#10) | dependent on #8-9 | -1 |
| **Total deduction** | | **-22** |

**Score: 100 - 22 = 78**

---

## Observations

### Strengths

1. **Writing quality is high.** The prose is clear, precise, and reads well as academic English. No grammatical errors, typos, or spelling mistakes were found in the 1207-line manuscript.

2. **Cross-references are clean.** All `\ref{}` targets have corresponding `\label{}` definitions (either explicit or auto-generated by knitr). No broken cross-references were found. The `\ref{tab:ivb-full-table}` target is auto-generated by knitr from the chunk name `ivb-full-table` with a caption, which is correct.

3. **Citation keys are complete.** All 46 cited keys exist in `references.bib`. The natbib syntax (`\citep[e.g.,][]{...}`, `\citealt{...}`, etc.) is correctly used throughout.

4. **LaTeX formatting is correct.** Math environments, theorem/proposition/corollary environments, TikZ figures, and table formatting are all syntactically correct. No orphaned braces, unmatched environments, or broken math mode.

5. **Terminology is consistent in the body text.** The paper consistently uses "covariate" for the variable being assessed, "control" for the selection decision, "collider/confounder/mediator" for causal roles, and "CET" for the estimand.

6. **Factual claims about the empirical applications are accurate.** The "14 collider candidates" count matches the R code (7 study-specifications with 14 total collider candidates). The "six studies" count is correct. The total-effect calculation ($1.2 = 1.0 + 0.5 \times 0.4$) is correct.

### Critical Issues

1. **Appendix E is stale (lines 985-995).** This is the most significant issue. Appendix E describes 3 DGPs from the old v1 simulation (`sim_ivb_completa.R`), which are NOT the simulations reported in Section 5. The paper body reports results from 238 DGP configurations across multiple simulation families (collider/dual-role, mediator, nonlinearity, feedback), none of which are described in Appendix E. The claim that simulations are "embedded in the R Markdown source file" is false -- the Rmd contains only replication code for Section 6 applications. This appendix needs a complete rewrite to match the current paper.

2. **"57 study-control combinations" should be "55" (lines 559, 634, 1167).** The CSV `replication/standardized_ivb_metrics.csv` contains exactly 55 data rows. This number appears three times in the manuscript and is incorrect in all three.

3. **Notation inconsistency in Section 4.6 and the Remark.** The footnote on line 70 promises TSCS notation ($\theta^*$, $\pi$) "throughout the paper," but Section 4.6 (Caveats) and the Remark after Section 4.1 use cross-section notation ($\beta_2^*$, $\phi_1$). This should be harmonized.

### No Issues Found In

- Grammar and spelling (zero typos in 1207 lines)
- Subject-verb agreement
- Article usage (a/an/the)
- Punctuation and sentence structure
- Em-dash and en-dash usage
- LaTeX math mode syntax
- Figure captions and labels
- Table formatting
- Bibliography style and citation syntax
- Factual claims about empirical applications
- Factual claims about simulation results in Section 5

---

*Report generated by Proofread Agent, 2026-03-22*
