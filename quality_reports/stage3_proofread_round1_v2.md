# Stage 3: Proofread Review -- Round 1 v2

**Reviewer:** Proofread Reviewer Agent
**Date:** 2026-03-01
**Files reviewed:** `ivb_paper_psrm.Rmd` (1389 lines) and `references.bib` (572 lines)
**Focus sections:** Abstract, Introduction, Section 6 intro, Leipziger, Rogowski, Conclusion, Appendix F

---

## Summary

The manuscript is in very good shape. The prose is clear and polished, the LaTeX compiles correctly, and all citation keys resolve to entries in `references.bib`. No critical issues were found (no broken citations, no equation typos). The issues identified are all minor-to-major: notation inconsistencies, one formatting error in a table column header, and a few minor items.

---

## Issues Table

| # | Line | Current text | Proposed correction | Category | Severity |
|---|------|-------------|---------------------|----------|----------|
| 1 | 32 | `median IVBs are below 0.15 standard errors` | `median IVBs are approximately 0.13 standard errors` | notation | Minor (-1) |
| 2 | 621 | Within the same sentence: `$\|\text{IVB}\|/\text{SE}(\hat\beta)$` (first mention) then `$\|\text{IVB}/\text{SE}\| > 1$` (second mention) | Use one notation consistently. Recommend `$\|\text{IVB}/\text{SE}\|$` throughout (matching the rest of the paper) or `$\|\text{IVB}\|/\text{SE}$` throughout. | notation | Major (-3) |
| 3 | 604 | `$\|\text{IVB}\|/\text{SE}$` | `$\|\text{IVB}/\text{SE}\|$` (to match the dominant notation used on lines 32, 77, 701, 797, 883, 906) | notation | Major (-3) |
| 4 | 878 | `"$\|\\text{IVB}\|$/SE"` (column header in Rogowski table) | `"$\|\\text{IVB}\|/\\text{SE}$"` -- the `/SE` is currently outside math mode, which will render as mixed math/text. Should be fully inside math mode. | notation/formatting | Major (-3) |
| 5 | 878 vs 682 vs 779 | Rogowski table header: `$\|\\text{IVB}\|$/SE`; Summary table header: `IVB/SE` (plain); Leipziger table header: `$\\lvert\\text{IVB}\\rvert / \\text{SE}(\\hat\\beta)$` | Standardize column headers across all IVB tables. Recommend `$\|\\text{IVB}/\\text{SE}\|$` for all three tables. | formatting | Minor (-1) |
| 6 | 806 | `\mathbf{Z}'_{it}\gamma + \delta_i + \gamma_t` | `\mathbf{Z}'_{it}\boldsymbol{\gamma} + \delta_i + \mu_t` (or another letter for time FE). The symbol `\gamma` is used for both the control coefficient vector and the time fixed effect subscript `\gamma_t` in the same equation, creating a notation clash. | notation | Major (-3) |
| 7 | 1261 | `\textbf{Collider + Confdr.}` | `\textbf{Collider + Confounder}` (to match line 1308 which spells out "Confounder" in full) | formatting | Minor (-1) |
| 8 | 715 | `Alesina et al.\ nightlight income, Omoeva et al.\ education` | Consider adding formal citations: `\citealt{alesina_etal_nightlight} nightlight income, \citealt{omoeva_etal} education` -- or at minimum add year in parentheses for identification. Currently these are uncited references. | reference | Minor (-1) |
| 9 | 617 | `spanning four substantive domains` | The text then lists six distinct topics. While grouping Claassen, Leipziger, and Blair under "democratization" yields four domains, the list reads as six. Consider `spanning several substantive domains` or explicitly naming the four domains. | grammar | Minor (-1) |

---

## Checks Performed with No Issues Found

### Citation Keys
All citation keys used in `\citet{}`, `\citep{}`, and `\citealt{}` commands resolve to entries in `references.bib`. The following newly added bib entries were verified present:

- `bermeo2016` -- present (line 486)
- `hibbs1977` -- present (line 496)
- `alesina1987` -- present (line 506)
- `sargent_wallace1981` -- present (line 516)
- `vreeland2003` -- present (line 526)
- `eichengreen2005` -- present (line 533)
- `alesina_tabellini1990` -- present (line 543)
- `costalli_etal2024` -- present (line 553)
- `moore_shellman2004` -- present (line 563)

No broken citations.

### Cross-References
All `\ref{}` targets have matching `\label{}` definitions:

| Reference | Label location | Status |
|-----------|---------------|--------|
| `\ref{sec:control}` | line 82 | OK |
| `\ref{sec:dags}` | line 119 | OK |
| `\ref{sec:ivb}` | line 261 | OK |
| `\ref{sec:ivb_magnitude}` | line 557 | OK |
| `\ref{sec:applications}` | line 615 | OK |
| `\ref{sec:conclusion}` | line 900 | OK |
| `\ref{sec:recipe}` | line 509 | OK |
| `\ref{sec:caveats}` | line 536 | OK |
| `\ref{sec:app_rogowski}` | line 802 | OK |
| `\ref{sec:app_leipziger}` | line 709 | OK |
| `\ref{fig:three_structures}` | line 161 | OK |
| `\ref{fig:dag_tscs}` | line 203 | OK |
| `\ref{fig:dag_collider}` | line 251 | OK |
| `\ref{fig:fig-heatmap-A}` | knitr chunk line 588 | OK |
| `\ref{fig:fig-heatmap-B}` | knitr chunk line 592 | OK |
| `\ref{tab:ovb_ivb}` | line 334 | OK |
| `\ref{tab:ivb_summary}` | line 695 (in kable caption) | OK |
| `\ref{tab:ivb_full}` | line 1384 (in kable caption) | OK |
| `\ref{app:classification}` | line 1202 | OK |
| `\ref{prop:ivb_cs}` | line 314 | OK |
| `\ref{prop:ivb_adl}` | line 400 | OK |
| `\ref{prop:ivb_adlpq}` | line 426 | OK |
| `\ref{prop:ivb_lag_sub}` | line 454 | OK |

No broken cross-references.

### Numbers Consistency
- "14 collider candidates" -- verified by counting across all classification tables and the R code `collider_candidates` list: Claassen (1) + Leipziger SEI (1) + Leipziger ext. (2) + Blair (3) + Albers (3) + Rogowski (1) + Ballard-Rosa (3) = 14. Consistent across abstract (line 32), introduction (line 77), Section 6 (line 701), and conclusion (line 906).
- "0.13" median -- consistent on lines 77, 701, 906. Abstract uses "below 0.15" (see Issue #1).
- "2.11" IVB/SE for Rogowski -- consistent across lines 32, 77, 701, 906.
- "58%" -- consistent across lines 32, 77, 701, 887, 906.
- "six published studies" -- consistent throughout.
- "57 study-control combinations" -- consistent on lines 619, 694, 1352.

### Grammar (English)
No grammatical errors found in the target sections. The prose is clear and professional throughout.

### LaTeX/Braces
No unmatched braces detected. All `\begin{}`/`\end{}` environments are properly paired. All equation environments are well-formed.

### Appendix F Table Headers
All six classification tables use identical column structure:
```
Control & $D \to Z$ & $Y \to Z$ & Classification & Key references
```
Consistent across Claassen (line 1214), Leipziger (line 1235), Blair (line 1256), Albers (line 1278), Rogowski (line 1306), Ballard-Rosa (line 1326).

### Citation Style
- `\citet{}` used correctly for in-text author citations (e.g., "Leipziger (2024) estimates...")
- `\citep{}` used correctly for parenthetical citations (e.g., "\citep{pearl2009causality}")
- `\citealt{}` used correctly for citations without parentheses in contexts where parentheses would be redundant (e.g., inside a parenthetical remark)
- `\citep[][p.~81]{...}` correctly uses natbib optional arguments for page numbers

---

## Score Calculation

Starting score: 100

| # | Deduction | Running total |
|---|-----------|---------------|
| 1 | -1 (minor: abstract says "0.15" vs body says "0.13") | 99 |
| 2 | -3 (major: notation inconsistency within sentence on line 621) | 96 |
| 3 | -3 (major: notation inconsistency on line 604 vs dominant usage) | 93 |
| 4 | -3 (major: broken math/text formatting in table header line 878) | 90 |
| 5 | -1 (minor: inconsistent table column headers across tables) | 89 |
| 6 | -3 (major: gamma notation clash in Rogowski equation line 806) | 86 |
| 7 | -1 (minor: "Confdr." abbreviation inconsistency line 1261) | 85 |
| 8 | -1 (minor: uncited authors Alesina et al., Omoeva et al. line 715) | 84 |
| 9 | -1 (minor: "four substantive domains" phrasing line 617) | 83 |

**Final Score: 83/100**

---

## Verdict: REPROVADO [83]

The manuscript fails the 90-point threshold due to four major issues:
1. Notation inconsistency in IVB/SE formatting (Issues #2, #3) -- the paper alternates between `|IVB/SE|` and `|IVB|/SE` without a clear convention
2. Broken math/text formatting in the Rogowski table column header (Issue #4)
3. Notation clash with `\gamma` in the Rogowski equation (Issue #6)

### Recommended Priority Fixes

**To reach 90+ (approval):**

1. **Standardize IVB/SE notation** (Issues #2, #3, #4, #5). Choose one form -- recommend `$|\text{IVB}/\text{SE}|$` since it is used most frequently (abstract, introduction, Section 6, conclusion). Apply it consistently to all in-text references and table column headers. This fix alone recovers 10 points.

2. **Fix Rogowski equation** (Issue #6). Change `\gamma_t` to `\mu_t` (or `\tau_t`) for the time fixed effect in the Rogowski specification equation to avoid the clash with the controls vector coefficient `\gamma`. This recovers 3 points.

After fixing Issues #2-6, the score rises to 93, comfortably above the 90-point threshold.
