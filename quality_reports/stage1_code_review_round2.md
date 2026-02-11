# Stage 1: Code Review Report (Round 2)

**Reviewer**: Claude Code (Automated Review Agent)
**Date**: 2026-02-10
**Round 1 Score**: 48/100 (REPROVADO)
**Files Reviewed**:
1. `sim_ivb_completa.R` (487 lines) -- main simulation (with fixes)
2. `sim_DEPRECATED.R` (93 lines) -- archived exploratory draft (renamed from `sim.R`)
3. `ivb_paper_psrm.Rmd` (1018 lines) -- manuscript with embedded R chunks (unchanged)

---

## 1. Executive Summary

Round 1 identified 10 issues totaling -52 points, driven primarily by the buggy `sim.R` file (-20 critical, -10 major for dead code) and fragile relative paths (-10 major). Four fixes were applied:

1. `sim.R` renamed to `sim_DEPRECATED.R` with a deprecation header
2. Working directory comment added to `sim_ivb_completa.R` explaining the `ggsave()` path convention
3. Comment added explaining 200 vs 500 inner replications in section 2C
4. Header added noting Rmd is the authoritative source

These fixes resolve the most impactful issues. The **core simulation code remains methodologically sound and statistically correct**, as established in Round 1. The remaining deductions are minor/style-level and do not affect correctness or reproducibility.

---

## 2. Round 1 Issue Disposition

| R1 # | Severity | R1 Deduction | Description | Status | R2 Deduction |
|-------|----------|-------------|-------------|--------|-------------|
| 1 | Critical | -20 | Undefined variable `bias_IVB` in `sim.R` | **RESOLVED**: File renamed to `sim_DEPRECATED.R` with deprecation header clearly stating "should NOT be used" and pointing to `sim_ivb_completa.R`. | 0 |
| 2 | Major | -10 | Relative `ggsave()` paths in `sim_ivb_completa.R` | **MITIGATED**: Comment block (lines 8-11) documents the working directory assumption and explains the RStudio `.Rproj` convention. The `IVB-paper.Rproj` file exists. Paths remain relative but are now explicitly documented. | -2 (downgraded to Minor) |
| 3 | Major | -10 | Incomplete `sim.R` with dead code | **RESOLVED**: File deprecated and clearly labeled. | 0 |
| 4 | Minor | -2 | Inconsistent column naming between files | **UNCHANGED**: `sim_ivb_completa.R` uses `bias_empirico` / `beta_sem_dem`; Rmd uses `bias_empirical` / `beta_no_dem`. Each file is internally consistent. | -2 |
| 5 | Minor | -2 | Non-idiomatic `rowwise() + mutate()` | **UNCHANGED**: Still present (lines 89-108). Works correctly but is a fragile pattern. | -2 |
| 6 | Minor | -2 | Unexplained 200 vs 500 inner replications | **RESOLVED**: Comment added at lines 281-282 explaining the choice. | 0 |
| 7 | Minor | -2 | Incorrect IVB formula in `sim.R` | **RESOLVED**: File deprecated. | 0 |
| 8 | Minor | -2 | Unused variables in `sim.R` | **RESOLVED**: File deprecated. | 0 |
| 9 | Style | -1 | Long lines (>100 chars) | **UNCHANGED**: Still present in subtitle `paste0()` calls and `scale_fill_manual()` calls. | -1 |
| 10 | Style | -1 | Mixed-language comments/labels | **UNCHANGED**: Portuguese in `.R`, English in `.Rmd`. | -1 |

---

## 3. Verification of Applied Fixes

### Fix 1: Deprecation of `sim.R`

**Verified**: The file `/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/sim_DEPRECATED.R` exists with a 5-line deprecation header:

```r
# =============================================================================
# DEPRECATED: This file is an abandoned exploratory draft and should NOT be used.
# It contains bugs (undefined variable on line 44) and incomplete code.
# The authoritative simulation file is: sim_ivb_completa.R
# =============================================================================
```

The header is clear, specific about the bugs, and directs the reader to the correct file. The original bugs (undefined `bias_IVB`, incorrect formula, unused variables) remain in the file but are now clearly marked as known issues in deprecated code. This is an acceptable archival approach.

### Fix 2: Working Directory Comment

**Verified**: Lines 8-11 of `sim_ivb_completa.R`:

```r
# IMPORTANT: This script assumes the working directory is the project root
# (where the .Rproj file lives). When opened in RStudio via the .Rproj file,
# the working directory is set automatically. All ggsave() calls use relative
# paths under "plots/".
```

The `IVB-paper.Rproj` file exists at `/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/IVB-paper.Rproj`, and the `plots/` directory contains all 8 expected PNG files. The relative paths work correctly within the intended RStudio workflow. The comment makes the dependency explicit. Downgraded from Major (-10) to Minor (-2) because:
- The assumption is now documented rather than implicit
- The `.Rproj` file provides automatic working directory setup
- All output files exist, confirming the workflow works
- The remaining risk is only for users running the script outside RStudio without reading the header

### Fix 3: 200 vs 500 Comment

**Verified**: Lines 281-282 of `sim_ivb_completa.R`:

```r
  # Using 200 inner replications (instead of 500) to keep runtime manageable,
  # since this loop runs once per value in rho_grid (10 values total).
```

The explanation is clear and placed directly above the relevant code block. Issue fully resolved.

### Fix 4: Authoritative Source Header

**Verified**: Lines 5-6 of `sim_ivb_completa.R`:

```r
# NOTE: The authoritative source for paper results is the Rmd file.
# This script is a standalone version of the simulations for convenience.
```

This clarifies the relationship between the two files. Issue fully resolved.

---

## 4. Remaining Issues

### Minor Issues (carried over from Round 1)

#### m1: Inconsistent column naming between files (-2)

**File**: `sim_ivb_completa.R` vs `ivb_paper_psrm.Rmd`

The standalone R script uses Portuguese naming (`bias_empirico`, `beta_sem_dem`, `beta_com_dem`, `bias_medio`, `bias_formula_medio`), while the Rmd uses English naming (`bias_empirical`, `beta_no_dem`, `beta_with_dem`, `bias_mean`, `formula_mean`). Each file is internally consistent, and the header in `sim_ivb_completa.R` clarifies that the Rmd is authoritative. The risk is limited to confusion during maintenance but does not affect correctness.

#### m2: Non-idiomatic `rowwise() + mutate()` with simulation (-2)

**File**: `sim_ivb_completa.R`, lines 89-108

```r
grid_results <- grid_params %>%
  rowwise() %>%
  mutate(
    bias = {
      D <- rnorm(n)
      ...
    }
  )
```

This works correctly but is a fragile pattern that relies on `rowwise()` scoping of `gamma1`/`gamma2` from the grouped row and the external variable `n`. The Rmd uses the identical pattern (lines 894-910), so it is intentional. Not a bug, but a style concern.

### Style Issues (carried over from Round 1)

#### S1: Long lines (-1)

Several lines in `sim_ivb_completa.R` exceed 100 characters, particularly `paste0()` calls in plot subtitles (e.g., lines 69-70, 237-239) and `scale_fill_manual()` calls (e.g., lines 144-145).

#### S2: Mixed-language comments and labels (-1)

`sim_ivb_completa.R` uses Portuguese for section headers and plot labels ("Vies empirico vs formula"), while the Rmd uses English. The header now clarifies this is a standalone convenience script, which somewhat justifies the language choice for the intended audience.

---

## 5. Score Calculation

| Category | Count | Deduction | Subtotal |
|----------|-------|-----------|----------|
| Critical | 0 | -20 each | 0 |
| Major | 0 | -10 each | 0 |
| Minor | 3 | -2 each | -6 |
| Style | 2 | -1 each | -2 |
| **Total** | | | **-8** |

**Starting score**: 100
**Total deductions**: -2 -2 -2 -1 -1 = **-8**

---

## 6. Final Score

**Final Score: 92/100**

---

## 7. Verdict

**APROVADO 92**

---

## 8. Summary of Improvement

| Metric | Round 1 | Round 2 | Change |
|--------|---------|---------|--------|
| Score | 48 | 92 | +44 |
| Critical issues | 1 | 0 | -1 |
| Major issues | 2 | 0 | -2 |
| Minor issues | 5 | 3 | -2 |
| Style issues | 2 | 2 | 0 |

The four targeted fixes addressed 100% of the Critical and Major issues and 40% of the Minor issues. The remaining deductions (-8 total) are non-functional concerns: naming conventions, an unusual-but-working dplyr pattern, line length, and bilingual comments. None affect statistical correctness, reproducibility, or runtime behavior.

---

## 9. Optional Recommendations (non-blocking)

These are suggestions for future improvement. None are required for the APROVADO verdict.

1. **[LOW]** Consider adopting `here::here("plots", "cs_bias_scatter.png")` for `ggsave()` paths. This would make the script fully portable without any working directory assumptions.

2. **[LOW]** Align column naming conventions between `sim_ivb_completa.R` and the Rmd (either all Portuguese or all English) to reduce maintenance burden.

3. **[LOW]** Replace the `rowwise() + mutate()` simulation pattern with a `for` loop or `purrr::pmap()` for clarity. The current pattern works but may confuse collaborators unfamiliar with `rowwise()` scoping.

4. **[LOW]** Consider deleting `sim_DEPRECATED.R` entirely rather than keeping it in the project. Its deprecation header is excellent, but the simplest way to prevent confusion is removal. If historical preservation is desired, the git history already contains the original `sim.R`.
