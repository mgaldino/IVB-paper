# Stage 1: Code Review Report (Round 1)

**Reviewer**: Claude Code (Automated Review Agent)
**Date**: 2026-02-10
**Files Reviewed**:
1. `sim_ivb_completa.R` (477 lines) -- main simulation
2. `sim.R` (87 lines) -- basic/exploratory simulation
3. `ivb_paper_psrm.Rmd` -- manuscript with embedded R chunks

---

## 1. Executive Summary

The simulation code for the IVB paper is **methodologically sound and well-structured**. The core statistical logic -- validating that IVB = -theta* x pi matches the empirical bias across cross-sectional, ADL(1,0), and civil war DGPs -- is correctly implemented in both the standalone script (`sim_ivb_completa.R`) and the embedded Rmd chunks. The code is organized into clearly labeled sections, uses `set.seed()` at critical points, pre-allocates result data frames, and the DGP functions are cleanly parameterized. However, there is **one genuine bug** in `sim.R` (a reference to an undefined variable `bias_IVB`), **relative paths for `ggsave()` calls** that would fail if the working directory is not set to the project root, and the exploratory `sim.R` file has several incomplete/dead-end code patterns. The Rmd file duplicates the simulation code cleanly and is the authoritative source. Overall, this is solid academic simulation code with a few issues to note.

---

## 2. Score Calculation

| # | Severity | Deduction | File | Description |
|---|----------|-----------|------|-------------|
| 1 | Critical | -20 | `sim.R` L41 | **Bug: undefined variable `bias_IVB`**. Line 41 references `bias_IVB` but only `hat_bias_IVB` is defined (L40). This line will throw an `Error: object 'bias_IVB' not found`. |
| 2 | Major | -10 | `sim_ivb_completa.R` | **Relative paths in `ggsave()` calls**. All 8 `ggsave()` calls use `"plots/..."` as a relative path. If the working directory is not `/Users/.../IVB-paper/`, these will fail. Since this is a standalone `.R` script (not sourced from within the project), this is fragile. |
| 3 | Major | -10 | `sim.R` | **No error handling and incomplete output**. Lines 84-87 have commented "Output results" with no actual output. The second simulation (Sim 2) computes `cov_DZ_OVB` but never uses it. The file appears to be a scratch/exploratory script that was never finished, yet it is present in the project alongside the authoritative code. |
| 4 | Minor | -2 | `sim_ivb_completa.R` | **Inconsistent variable naming across files**. In `sim_ivb_completa.R`, the cross-section bias column is `bias_empirico`; in the Rmd, it is `bias_empirical`. Similarly, `beta_sem_dem`/`beta_com_dem` vs. `beta_no_dem`/`beta_with_dem`. While each file is internally consistent, the inconsistency between files could cause confusion during maintenance. |
| 5 | Minor | -2 | `sim_ivb_completa.R` L84-98 | **`rowwise() %>% mutate()` with complex simulation inside curly braces** in section 1B. This is a creative but non-idiomatic use of `dplyr`. The `{...}` block inside `mutate()` with `rowwise()` works but is fragile -- it relies on the non-standard evaluation of variables `gamma1`, `gamma2` from the grouped row, and the external variable `n`. A simple `for` loop or `purrr::pmap()` would be clearer. |
| 6 | Minor | -2 | `sim_ivb_completa.R` | **Magic numbers without explanation**. Several numeric values appear without comment: `nsim <- 200` (inner loop of section 2C, vs. `nsim <- 500` elsewhere), `N <- 200`, `T_periods <- 20`. While these are standard MC choices, the reason for using 200 inner replications vs. 500 outer replications in section 2C is not explained. |
| 7 | Minor | -2 | `sim.R` L40-41 | **Incorrect IVB computation approach**. Line 40 computes `hat_bias_IVB <- -coef(model_long)[3]*cov_DZ_IVB`, using `cov(D,Z)` rather than `cov(D,Z)/var(D)`. The formula should use `phi1 = cov(D,Z)/var(D)` (the regression coefficient), not the raw covariance. The correct formula as shown in the paper and `sim_ivb_completa.R` is `-theta_star * phi1`. This is a **formula error** in the exploratory file (though the file is not used for paper results). |
| 8 | Minor | -2 | `sim.R` | **Unused variables**: `beta0`, `gamma0`, `alpha0` are defined but serve no functional purpose (they are zero and added to expressions where they have no effect). `cov_DZ_OVB` is computed but never used. `model_DZ` is fitted but its coefficients are never extracted. |
| 9 | Style | -1 | `sim_ivb_completa.R` | **Several lines exceed 100 characters**. E.g., lines 61-62 (subtitle paste0), lines 229-231, etc. |
| 10 | Style | -1 | `sim_ivb_completa.R` | **Mixed language in comments/labels**. Section headers and plot labels are in Portuguese (e.g., "Vies empirico vs formula"), while the Rmd uses English. This is not a bug but a style inconsistency between the standalone script and the paper. |

**Starting score**: 100
**Total deductions**: -20 -10 -10 -2 -2 -2 -2 -2 -1 -1 = **-52**

---

## 3. Issues by Severity

### Critical Issues

#### C1: Undefined variable `bias_IVB` in `sim.R` (line 41)

**File**: `/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/sim.R`
**Line**: 41

```r
hat_bias_IVB <- -coef(model_long)[3]*cov_DZ_IVB   # line 40 -- defines hat_bias_IVB
coef(summary(model_short))[2] + bias_IVB            # line 41 -- references bias_IVB (UNDEFINED)
```

The variable `hat_bias_IVB` is defined on line 40, but line 41 references `bias_IVB` (without the `hat_` prefix). This will produce a runtime error. It appears to be a typo.

**Impact**: This script will crash at line 41 if run. However, this file does not appear to be used for any paper results -- the authoritative simulations are in the Rmd and `sim_ivb_completa.R`.

### Major Issues

#### M1: Relative `ggsave()` paths in `sim_ivb_completa.R`

**File**: `/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/sim_ivb_completa.R`
**Lines**: 68, 115, 139, 237, 262, 308, 426, 441

All `ggsave()` calls use relative paths like:
```r
ggsave("plots/cs_bias_scatter.png", p1a, width = 7, height = 6, dpi = 150)
```

These will fail unless `getwd()` returns the project root directory. For a standalone `.R` script, this is fragile. The `plots/` directory does exist and contains the expected 8 PNG files, so these paths have been used successfully at least once. But they would fail on another machine without first setting the working directory.

#### M2: Incomplete `sim.R` with dead code

**File**: `/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/sim.R`

This file appears to be an early exploratory draft that was never completed:
- Lines 84-87: "Output results" section is empty
- `cov_DZ_OVB` is computed but never used
- `model_DZ` is fitted but never used
- The IVB computation on line 40 uses the wrong formula (raw covariance instead of regression coefficient)
- There is no documentation of its purpose or status (draft/deprecated)

The file's presence in the project directory alongside the authoritative `sim_ivb_completa.R` could cause confusion.

### Minor Issues

#### m1: Inconsistent column naming between files

`sim_ivb_completa.R` uses Portuguese-style names (`bias_empirico`, `beta_sem_dem`, `beta_com_dem`), while `ivb_paper_psrm.Rmd` uses English names (`bias_empirical`, `beta_no_dem`, `beta_with_dem`). This is not a bug (each file is internally consistent), but it increases maintenance burden.

#### m2: Non-idiomatic `rowwise() + mutate()` with complex simulation

**File**: `/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/sim_ivb_completa.R`, lines 81-100

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

While functional, this pattern hides a full simulation inside a `mutate()` call with curly braces. It depends on `rowwise()` providing `gamma1` and `gamma2` from the current row, and on the external variable `n`. This is a creative but fragile pattern.

#### m3: Unexplained difference in inner loop count (200 vs 500)

**File**: `/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/sim_ivb_completa.R`, section 2C (lines 273-276)

The rho-sensitivity analysis uses 200 inner replications (`for (i in 1:200)`), while the main simulations use 500 (`nsim <- 500`). This may be intentional (the inner loop aggregates means, so fewer replications suffice), but it is not explained.

#### m4: Incorrect IVB formula in `sim.R`

**File**: `/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/sim.R`, line 40

```r
hat_bias_IVB <- -coef(model_long)[3]*cov_DZ_IVB
```

This uses the raw covariance `cov(D, Z)` instead of the regression coefficient `phi1 = cov(D, Z) / var(D)`. The correct formula (as used in `sim_ivb_completa.R` and the Rmd) is:
```r
-coef(model_long)["Z"] * coef(model_ZD)["D"]
```

Since `var(D) ~ 1` for standard normal D with n=10000, the numerical error would be small, but the formula is conceptually wrong.

#### m5: Unused variables in `sim.R`

Variables `beta0`, `gamma0`, `alpha0` are set to 0 and used in expressions where they have no effect. `cov_DZ_OVB` and `model_DZ` are computed but never referenced again.

### Style Issues

#### S1: Long lines

Several lines in `sim_ivb_completa.R` exceed 100 characters, particularly `paste0()` calls in plot subtitles and `scale_fill_manual()` calls.

#### S2: Mixed-language comments and labels

`sim_ivb_completa.R` uses Portuguese for section headers and plot labels ("Vies empirico vs formula", "Distribuicao dos estimadores"), while the Rmd uses English. This is expected for a standalone development script vs. an English-language paper, but it is a stylistic inconsistency.

---

## 4. Positive Aspects

### Statistical Methodology

1. **The IVB formula is correctly implemented**. In all three DGPs (cross-section, ADL, civil war), the bias formula `-theta_star * phi1` (or `-theta_star * pi_hat`) is correctly computed as the negative product of the collider coefficient in the long regression and the treatment coefficient in the auxiliary regression. This matches the paper's Propositions 1-3.

2. **The DGP designs are appropriate**. Each DGP tests a different aspect of the IVB formula:
   - DGP 1 (cross-section): validates the basic formula
   - DGP 2 (ADL): validates the FWL extension to dynamic models
   - DGP 3 (civil war): validates with a richer, substantive DGP including confounders (Income), persistence, and an unobserved common cause (U)

3. **The collider structure is correctly specified**. In all DGPs, Z (or Dem) is generated as a function of the outcome (Y or CW) and either the treatment directly or an unobserved variable, which is the correct collider structure.

4. **The auxiliary regression specification is correct**. The auxiliary regression always includes the same controls as the short model (minus the collider), which is the correct application of the FWL theorem for computing the partial association.

### Code Quality

5. **`set.seed()` is used at all critical points**. Seeds are set before each major simulation block (lines 18, 78, 190, 269, 367 in `sim_ivb_completa.R`; and corresponding places in the Rmd). This ensures full reproducibility.

6. **Pre-allocation of result data frames**. Results are stored in pre-allocated data frames (e.g., `results_cs <- data.frame(sim = 1:nsim, ...)`) rather than growing vectors, which is efficient.

7. **Matrix-based panel simulation**. The `sim_adl_panel()` and `sim_civil_war()` functions use matrix pre-allocation for panel data, which is much faster than row-by-row data frame operations.

8. **Clean function design**. Both `sim_adl_panel()` and `sim_civil_war()` are well-parameterized with named arguments and default values. They include inline documentation of parameters.

9. **Consistent code structure**. The `sim_ivb_completa.R` file follows a clear pattern for each DGP: (a) set parameters, (b) run MC loop, (c) compute bias, (d) generate plots. This makes the code easy to follow.

10. **The Rmd code is self-contained and reproducible**. The manuscript embeds all simulation code directly, meaning the paper can be compiled from scratch with `knit()` and all results will be reproduced. This is excellent practice for academic reproducibility.

11. **Good use of `cache = TRUE`** in Rmd chunks, which prevents unnecessary re-computation during manuscript editing.

### Validation Design

12. **The scatter plot (empirical vs. formula bias) is the correct validation tool**. If all points fall on the 45-degree line, the formula is exact. This is a clean, visual proof.

13. **The rho-sensitivity analysis (section 2C/appendix C) is a valuable robustness check**. It shows that the formula works across different persistence levels.

14. **The civil war DGP includes realistic complexity**: multiple confounders, an unobserved common cause, and multiple autoregressive processes. This strengthens the paper's claims about applicability.

---

## 5. Detailed Assessment of Statistical Correctness

### Cross-Section IVB Formula

The paper claims: IVB = beta1* - beta1 = -beta2* x phi1

In the code:
```r
theta_star <- coef(mod_long)["Z"]       # = beta2* in paper notation
phi1       <- coef(mod_aux)["D"]         # = phi1 in paper notation
bias_formula <- -theta_star * phi1       # = -beta2* x phi1
bias_empirical <- coef(mod_long)["D"] - coef(mod_short)["D"]  # = beta1* - beta1
```

**Verdict**: Correctly implemented. The FWL theorem guarantees this is an algebraic identity (not an approximation), so the scatter plot should show exact correspondence.

### ADL(1,0) IVB Formula

The paper claims: IVB(beta) = beta* - beta = -theta* x pi, where pi is from Z ~ D + Y_lag.

In the code:
```r
mod_short <- lm(Y ~ D + Y_lag, data = df)          # correct short model
mod_long  <- lm(Y ~ D + Y_lag + Z, data = df)      # long model with collider
mod_aux   <- lm(Z ~ D + Y_lag, data = df)           # auxiliary regression
theta_star <- coef(mod_long)["Z"]
pi_hat     <- coef(mod_aux)["D"]
bias_formula <- -theta_star * pi_hat
```

**Verdict**: Correctly implemented. The auxiliary regression includes Y_lag (= y_{t-1}), which is the legitimate control set W_t. By FWL, pi_hat is the partial association between D and Z controlling for Y_lag, which is exactly what the formula requires.

### Civil War DGP

The DGP correctly implements:
- CW_t = rho_cw * CW_{t-1} + beta_pc * PC_t + alpha_inc * Inc_t + gamma_u_cw * U_t + noise
- Dem_t = gamma_cw_dem * CW_t + gamma_u_dem * U_t + noise (collider: caused by CW and U)
- U also causes CW (through gamma_u_cw), so conditioning on Dem opens the CW <- U -> Dem path

The estimation correctly compares:
- Correct model: CW ~ PC + CW_lag + Inc
- Collider model: CW ~ PC + CW_lag + Inc + Dem
- Auxiliary: Dem ~ PC + CW_lag + Inc

**Verdict**: Correctly implemented. The DGP faithfully represents the DAG in the paper (Figure 3), and the IVB formula should hold by FWL.

### One Subtle Note on the ADL Panel Construction

In `sim_adl_panel()`, the data frame drops `t=1` and uses `t >= 2` to have lagged values. The matrices are filled column-by-column (time dimension), and `as.vector()` on `Y[, 2:T_periods]` stacks columns, giving the data in unit-by-unit order (unit 1 all times, then unit 2 all times, etc.). The `id` and `t` columns are constructed with `rep(1:N, each = (T_periods - 1))` and `rep(2:T_periods, times = N)`, which matches this ordering. **This is correct.**

---

## 6. Final Score

| Category | Count | Deduction | Subtotal |
|----------|-------|-----------|----------|
| Critical | 1 | -20 each | -20 |
| Major | 2 | -10 each | -20 |
| Minor | 5 | -2 each | -10 |
| Style | 2 | -1 each | -2 |
| **Total** | | | **-52** |

**Final Score: 48/100**

---

## 7. Verdict

**REPROVADO 48**

---

## 8. Contextual Assessment and Recommendations

The low score is heavily driven by the `sim.R` file, which appears to be an **abandoned exploratory draft** that should either be deleted or moved to an `archive/` folder. If `sim.R` is excluded from the review (on the grounds that it is not used for any paper results), the score would be:

| Without sim.R | Deductions |
|----------------|-----------|
| M1: Relative ggsave paths | -10 |
| m1: Inconsistent naming | -2 |
| m2: Non-idiomatic rowwise | -2 |
| m3: Unexplained 200 vs 500 | -2 |
| S1: Long lines | -1 |
| S2: Mixed language | -1 |
| **Total without sim.R** | **-18** |
| **Score without sim.R** | **82/100** |

This would yield a **APROVADO 82**.

### Priority Recommendations

1. **[HIGH]** Remove or archive `sim.R`. It contains a bug (undefined variable), a formula error (raw covariance vs. regression coefficient), and dead code. Its presence risks confusion.

2. **[MEDIUM]** Consider using `here::here()` or a project-root mechanism for `ggsave()` paths in `sim_ivb_completa.R` to ensure portability.

3. **[LOW]** Add a brief comment in section 2C explaining why 200 inner replications are used instead of 500.

4. **[LOW]** The Rmd is the authoritative source. Consider noting in `sim_ivb_completa.R` that it is a standalone companion script for development/exploration, and that the paper's results come from the Rmd.
