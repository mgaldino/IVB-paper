# Stage 1: Code Review Report -- Rmd Table Chunks (Round 2)

**Reviewer**: Claude Code (Automated Review Agent)
**Date**: 2026-03-01
**Files Reviewed**:
1. `ivb_paper_psrm.Rmd` -- chunks: `ivb-summary-table`, `ivb-full-table`, `leipziger-ivb-table`, `rogowski-ivb-table`
2. `replication/ivb_utils.R` -- context for `compute_ivb_multi()`
3. `replication/standardized_ivb_metrics.csv` -- 57 rows, used as data source

---

## 1. Executive Summary

The four reviewed chunks implement the IVB summary and detail tables for the paper's empirical section. The code is correct in its core logic: collider candidate filtering, significance testing, NA handling, and standard error extraction all work as intended. No critical or major bugs were found. The issues identified are minor inconsistencies and one harmless but unnecessary LaTeX option.

---

## 2. Critical Checks

### Check 1: collider_candidates list vs CSV collider column

Each entry in the `collider_candidates` list (line 628--638) was verified against the `paper` and `collider` columns in `standardized_ivb_metrics.csv`. Results:

| Code (paper key) | Code (collider values) | CSV Match |
|---|---|---|
| `"Claassen (FE)"` | `"Log GDP p.c."` | EXACT MATCH |
| `"Leipziger (SEI)"` | `"Log GDP p.c."` | EXACT MATCH |
| `"Leipziger (SEI ext.)"` | `"Civil war"`, `"GDP growth"` | EXACT MATCH (both) |
| `"Blair et al."` | `"Foreign Aid"`, `"GDP per capita"`, `"Refugees/IDPs"` | EXACT MATCH (all 3) |
| `"Albers et al."` | `"Hyperinflation"`, `"GDP growth (YoY)"`, `"Liberal democracy"` | EXACT MATCH (all 3) |
| `"Rogowski et al."` | `"Log GDP p.c."` | EXACT MATCH |
| `"Ballard-Rosa et al."` | `"Inflation crisis"`, `"IMF program"`, `"Sov. debt crisis"` | EXACT MATCH (all 3) |

**Total collider candidates**: 1 + 1 + 2 + 3 + 3 + 1 + 3 = **14**, matching the paper text ("among the 14 collider candidates").

**Verdict**: PASS. No mismatches.

### Check 2: Significance test logic

Line 646: `sub$sig <- !is.na(sub$SE_beta) & abs(sub$beta_long / sub$SE_beta) >= 1.96`

This computes the t-statistic for the treatment effect in the long model (`beta_long / SE_beta`). The paper states that IVB/beta is reported "only when the treatment effect is statistically significant (|t| >= 1.96)." The treatment effect being tested is from the long (misspecified) model, which is `beta_long`. Using `SE_beta` (the SE of beta from the replication) is appropriate.

The `!is.na(sub$SE_beta)` guard correctly handles the Albers et al. case where SEs are unavailable.

**Verdict**: PASS.

### Check 3: Albers et al. NA handling

In the CSV, all 12 Albers et al. rows have `SE_beta = NA`, `IVB_over_SE = NA`, `SD_Y = NA`, `IVB_over_SDY = NA`, `abs_IVB_SDY = NA`.

- `sig` computation: `!is.na(NA)` is FALSE, so `sig = FALSE`. IVB/beta shows "---". Correct.
- `IVB_SE` display: `IVB_over_SE` is NA. `ifelse(is.na(NA), "---", ...)` returns "---". Correct.
- The table caption explicitly notes: "For Albers et al., standard errors are unavailable from the published replication, so IVB/SE is not reported."

**Verdict**: PASS.

### Check 4: ivb-full-table NA handling

Lines 1355--1365:

- `sig`: `!is.na(ivb_full$SE_beta) & ...` -- NA SEs produce `sig = FALSE`. Correct.
- `IVB_pct_fmt`: Uses `ifelse(ivb_full$sig, ...)` -- FALSE rows get "---". Correct.
- `IVB_SE_fmt`: `ifelse(is.na(ivb_full$IVB_over_SE), "---", ...)` -- NA rows get "---". Correct.
- `IVB_fmt`: `sprintf("%.4f", ivb_full$IVB)` -- IVB is never NA in the CSV (all 57 rows have numeric IVB). Correct.

**Verdict**: PASS.

### Check 5: Standard error extraction (se_lp, se_rg)

- Line 768: `se_lp <- se(mod_lp_sei)["L_lexical_index_5"]`
  - `mod_lp_sei` was estimated with `vcov = ~country_id` (line 737).
  - In fixest, `se()` returns SEs from the vcov specified at estimation time.
  - Therefore `se_lp` is the **clustered** SE. Correct.

- Line 866: `se_rg <- se(mod_rg)["upu_totalpo_ipo_ln_stock_1_5yr"]`
  - `mod_rg` was estimated with `vcov = ~country_id` (line 825).
  - Same logic: `se_rg` is the **clustered** SE. Correct.

**Verdict**: PASS.

### Check 6: longtable + hold_position compatibility

Lines 1381--1383:
```r
longtable = TRUE) %>%
  kable_styling(latex_options = c("hold_position", "repeat_header"),
                font_size = 9)
```

The `longtable` environment in LaTeX is NOT a float, so `[H]` positioning (which `hold_position` generates) does not apply. In kableExtra, `hold_position` is silently ignored when `longtable = TRUE`. The `repeat_header` option IS compatible with longtable and will correctly repeat the header row on each page.

This is not a bug -- the code compiles and produces correct output -- but the `hold_position` option is dead code in this context.

**Verdict**: Minor issue (see m1 below).

---

## 3. Issues Found

### Minor Issues

#### m1: Dead `hold_position` option in longtable context (-1)

**Severity**: Minor (style/dead code)
**File**: `ivb_paper_psrm.Rmd`, line 1382
**Chunk**: `ivb-full-table`
**Description**: The `hold_position` LaTeX option is silently ignored when `longtable = TRUE` because longtable is not a float environment. The option has no effect on the compiled output.
**Suggested fix**: Remove `"hold_position"` from the `latex_options` vector:
```r
kable_styling(latex_options = c("repeat_header"), font_size = 9)
```

#### m2: Inconsistent absolute-value convention for IVB/SE between tables (-2)

**Severity**: Minor (inconsistent presentation)
**File**: `ivb_paper_psrm.Rmd`
**Chunks**: `leipziger-ivb-table` (line 782) vs `rogowski-ivb-table` (line 867)
**Description**: The Leipziger table computes IVB/SE using absolute value: `round(abs(r_lp$ivb_formula) / se_lp, 2)` and labels it `|IVB|/SE(beta)`. The Rogowski table computes IVB/SE as signed: `round(tab_rg$IVB / se_rg, 2)` and labels it `IVB/SE`. The inline text at line 879 then applies `abs()` when displaying: `abs(tab_rg$IVB_SE[1])`. While each table is internally consistent with its column header, the different conventions across tables may confuse readers. The summary table uses signed IVB/SE from the CSV.
**Suggested fix**: Either (a) use `abs()` consistently in the Rogowski table column to match the Leipziger convention and relabel the column to `|IVB|/SE`, or (b) keep the signed convention but document the choice. Option (a) is preferred for consistency:
```r
tab_rg$IVB_SE <- round(abs(tab_rg$IVB) / se_rg, 2)
```
and update the column label to `$|\\text{IVB}|/\\text{SE}$`.

#### m3: No comment explaining the `cache=TRUE` on data-reading chunks (-1)

**Severity**: Minor (documentation)
**File**: `ivb_paper_psrm.Rmd`, lines 623 and 1350
**Chunks**: `ivb-summary-table` and `ivb-full-table`
**Description**: Both chunks that read the CSV file use `cache=TRUE`. Since the CSV is an external file, knitr's cache invalidation does not track changes to the CSV -- only changes to the chunk code trigger re-execution. If the CSV is regenerated with new values, the cached results will be stale. This is a known knitr behavior and unlikely to cause problems in practice (the CSV is generated once and not changed), but a brief comment would prevent confusion.
**Suggested fix**: Add a comment like:
```r
# cache=TRUE: safe because standardized_ivb_metrics.csv is generated once and versioned.
# If the CSV is regenerated, delete the cache or change chunk code to invalidate.
```

---

## 4. Positive Observations

1. **Robust NA handling**: The code correctly handles `NA` values in SE_beta and IVB_over_SE throughout, using both `!is.na()` guards and `ifelse()` with "---" fallbacks.

2. **Correct SE source**: Both `se_lp` and `se_rg` extract clustered standard errors from the replication models (estimated with `vcov = ~country_id`), not from the IVB diagnostic models (estimated with `vcov = "iid"`). This correctly separates inference (clustered) from the algebraic IVB identity (iid).

3. **Well-documented table captions**: The summary table caption (lines 682--693) explicitly notes the Albers et al. SE caveat and cross-references Appendix F. The full table caption (lines 1373--1378) explains the inclusion criterion and the "---" convention.

4. **Consistent formatting**: All IVB values are formatted to 4 decimal places (`%.4f`), IVB/SE to 2 decimal places (`%.2f`), and IVB/beta to 1 decimal place (`%.1f`). This is appropriate for the different magnitudes.

5. **Correct collider candidate count**: The 14 candidates match the paper text exactly, verified entry-by-entry against the CSV.

6. **compute_ivb_multi() is sound**: The utility function in `ivb_utils.R` correctly implements the FWL-based IVB identity with proper input validation, NA handling, collinearity checks, and a numeric consistency check (`diff_check = ivb_formula - ivb_direct`).

---

## 5. Score Calculation

| Category | Issue | Deduction |
|----------|-------|-----------|
| Critical | (none) | 0 |
| Major | (none) | 0 |
| Minor | m1: Dead hold_position in longtable | -1 |
| Minor | m2: Inconsistent abs-value convention | -2 |
| Minor | m3: No cache invalidation comment | -1 |
| **Total** | | **-4** |

**Starting score**: 100
**Total deductions**: -4

---

## 6. Final Score

**Final Score: 96/100**

---

## 7. Verdict

**APROVADO 96**

The four reviewed chunks are correct in all critical aspects: collider candidate filtering matches the CSV exactly (14/14), the significance test is properly guarded against NA, standard errors come from clustered models, and the longtable renders correctly despite the harmless dead option. The only deductions are for a dead LaTeX option, a minor presentation inconsistency in the abs-value convention across two different detail tables, and missing cache documentation.

---

## 8. Optional Recommendations (non-blocking)

1. **[LOW]** Consider adding `cache.extra = tools::md5sum("replication/standardized_ivb_metrics.csv")` to the `ivb-summary-table` and `ivb-full-table` chunks. This would make knitr's cache aware of CSV changes.

2. **[LOW]** The `study_labels` mapping (lines 658--666) uses LaTeX escaping (`\\`) for "et al." entries but not for the study labels used in the full table (`ivb-full-table`), which uses the raw `paper` column from the CSV. Consider applying the same label mapping for consistent formatting across tables.

3. **[LOW]** The Rogowski `pct` column (line 860) uses `round(100 * r$ivb_formula / r$beta_long, 1)` without guarding against `beta_long = 0`. While this will not happen in practice (the Rogowski treatment effect is significant), adding a guard would match the defensive style used elsewhere.
