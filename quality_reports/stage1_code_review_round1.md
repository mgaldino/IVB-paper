# Stage 1: Code Review -- sim_feedback_Y_to_D.R (Round 1)

**Reviewer**: Claude Code (Agente Reviewer)
**Date**: 2026-03-03
**File Reviewed**: `/simulations/dynamics/sim_feedback_Y_to_D.R` (507 lines)
**Previous rating**: A+ (review-r skill)

---

## Score: 93/100

### Deductions

| # | Severity | Points | Description |
|---|----------|--------|-------------|
| 1 | Minor | -2 | Lag construction discards first observation period rather than using the last burn-in value (consistent with codebase but slightly wasteful of data; N x 1 rows lost per rep) |
| 2 | Minor | -2 | `vcov = "iid"` used throughout, including for model 9 (`lm()`), which does not accept `vcov` via fixest -- the SE from `lm()` is standard OLS, but the naming convention could mislead readers into thinking all 9 models use identical SE computation |
| 3 | Minor | -2 | The `adl_DZlag` model (model 7) is omitted from the printed bias tables in the "RESULTS: BIAS BY MODEL" section (lines 362-370), though it is computed and stored in the summary; minor inconsistency in output completeness |
| 4 | Negligible | -1 | `N_REPS <- 500L` uses integer suffix but `N_REPS` in sibling scripts (`sim_direct_feedback.R`, `sim_direct_carryover.R`) is `N_REPS <- 500` without the `L`; trivially inconsistent across family |

**Total deductions**: -7

---

## Status: APROVADO

---

## Critical Issues (affects results)

**None found.**

The script is methodologically sound. Detailed verification:

1. **DGP correctness**: The structural system (lines 79-84) correctly implements the simultaneous equations:
   - `D_t = alpha_D_i + phi * Y_{t-1} + rho_D * D_{t-1} + gamma_D * Z_{t-1} + u`
   - `Y_t = alpha_Y_i + beta * D_t + gamma_Y * Z_{t-1} + rho_Y * Y_{t-1} + e`
   - `Z_t = alpha_Z_i + delta_D * D_t + delta_Y * Y_t + rho_Z * Z_{t-1} + nu`

   The causal ordering within period is D -> Y -> Z, which is correct: D is predetermined at t (depends on lags), Y is contemporaneous in D, Z is contemporaneous in both D and Y. This avoids simultaneity bias in the DGP.

2. **Stationarity check** (lines 159-203): The reduced-form VAR(1) companion matrix is correctly derived. The substitution chain (D into Y, then both into Z) yields the correct 3x3 matrix. Eigenvalue check (`max|eig| < 1`) is the standard stationarity condition. Unstable scenarios are flagged and skipped rather than producing garbage results.

3. **FWL identity check** (lines 423-434): The sanity check verifies `IVB = b_long - b_short = -theta * pi` at both the per-replication level (numerical precision < 1e-8) and the aggregated level. This is the gold-standard validation for the IVB formula.

4. **Estimation models** (lines 112-147): All 9 models plus the auxiliary regression are correctly specified. The auxiliary regression `Z_lag ~ D | FE` correctly identifies `pi_hat` (the FWL projection of D onto Z_lag after absorbing FE). The `theta` from model 2 (`twfe_l`) is correct as the coefficient on `Z_lag` in the long regression.

5. **Burn-in period** (T_burn = 100): With T_burn = 100 periods discarded, initial conditions have negligible effect on the stationary distribution for all stable parameter combinations. This is generous and appropriate.

6. **Explosive path handling** (lines 86-91): Per-unit early termination when any variable exceeds 1e6 in absolute value, with the entire replication returned as NULL. This is correctly counted in `n_explosive` and reported in sanity checks.

---

## Major Issues (affects quality/reproducibility)

**None found.**

Detailed assessment:

1. **Seed placement**: `set.seed(2026300)` is placed at line 271, immediately before `future_lapply`. The note at line 39 explicitly documents this. Combined with `future.seed = TRUE`, this ensures full reproducibility across the parallel workers. The stationarity check section (lines 159-203) is deterministic (no RNG calls), so the seed placement after it is correct.

2. **Parallelization**: `plan(multisession, workers = 4)` with `on.exit(plan(sequential), add = TRUE)` is clean resource management. The `run_scenario` function correctly captures all needed variables from the parent scope via the `grid` and `P` objects.

3. **Output files**: All four expected output files are saved:
   - `results/sim_feedback_Y_to_D_raw.csv` (per-rep data)
   - `results/sim_feedback_Y_to_D_results.csv` (aggregated summary)
   - `results/sim_feedback_Y_to_D_timing.csv` (performance metadata)
   - `results/sim_feedback_Y_to_D_sessioninfo.txt` (environment snapshot)

4. **`dir.create("results", showWarnings = FALSE)`** at line 221 ensures the output directory exists. Uses relative path, which is consistent with the convention that the script is run from its own directory (`simulations/dynamics/`).

---

## Minor Issues

### M1: Within-window lag construction (lines 93-101)

The lag construction uses `c(NA, D[idx[-length(idx)]])` where `idx = (T_burn + 1):T_sim`. This means the lag for the first observation period (t = T_burn + 1) is set to NA and then dropped by `complete.cases()`. The actual lag value exists in the simulation (`D[T_burn]`) and could be used.

**Impact**: Loses N rows per replication (one per unit). With N=100 and TT=30, this is 100 out of 3000 rows (3.3%). Not critical for 500 reps, but slightly wasteful. This is consistent with all sibling scripts (`sim_direct_feedback.R`, `sim_direct_carryover.R`, `sim_feedback_carryover.R`) which use the same approach, so it is a deliberate design choice rather than a bug.

### M2: SE extraction asymmetry between fixest and lm (lines 136-142)

Model 9 uses `lm()` (line 123), while `se_adl_all` at line 142 comes from `se(m8)` which is a fixest model. The script does not extract the SE from the `lm()` model. The `coef(m9)["D"]` extraction is correct. However, a reader might wonder about the SE comparison between FE and no-FE models. This is a very minor documentation gap rather than a bug.

### M3: Printed tables omit adl_DZlag (lines 362-370)

The bias table in the output section lists 8 of the 9 models but omits `adl_DZlag` (model 7). The RMSE table (lines 374-380) shows only 5 models. While the full data is in the CSV output, the console output is slightly incomplete. The key comparison (lines 406-414) also omits several models but focuses on the most policy-relevant ones.

### M4: Integer suffix inconsistency

`N_REPS <- 500L` (line 51) uses the integer suffix, while the sibling scripts use `N_REPS <- 500`. Functionally identical in R but mildly inconsistent across the simulation family.

---

## Positive Points

### P1: Excellent stationarity analysis

The VAR companion matrix derivation (lines 159-198) is a standout feature. The full algebraic derivation of the reduced-form VAR(1) from the structural system is documented in comments, and the eigenvalue check is correctly implemented. The script does not simply crash on unstable scenarios -- it identifies them, flags them, skips them, and reports the boundary. The comment at line 151 correctly notes that phi >= ~0.18 destabilizes the system, which is itself a substantive finding.

### P2: Comprehensive model battery

Nine estimation models plus an auxiliary regression for the IVB decomposition. This covers the full Imai & Kim Table 1 taxonomy (TWFE, ADL with various lag combinations, with and without FE). The no-FE benchmark (model 9) correctly measures the Nickell bias cost of including FE with a lagged dependent variable.

### P3: Rich sanity checks (lines 417-483)

Six distinct sanity checks:
1. FWL identity (per-rep numerical precision)
2. Discarded replication accounting
3. Phi=0 baseline verification against dual_role_z pattern
4. Monotonicity check: TWFE bias grows with phi
5. ADL robustness check across phi values
6. ADL vs TWFE dominance count

This is exemplary verification practice for Monte Carlo simulations.

### P4: Defensive coding

- `tryCatch` wrapping all estimation (lines 113-146)
- Explosive path detection with per-unit early termination
- Null handling throughout the pipeline
- Graceful exit if no valid results (`quit(status = 1)`)
- `on.exit(plan(sequential))` for parallel resource cleanup

### P5: Parameter alignment with baseline

Fixed parameters (line 44-50) match the `sim_dual_role_z.R` defaults exactly (N=100, TT=30, T_burn=100, beta=1, rho_Y=0.5, rho_D=0.5, gamma_D=0.15, gamma_Y=0.2, delta_D=0.1, delta_Y=0.1, sigma_aZ=0.5). This ensures phi=0 correctly reproduces the baseline, as verified by sanity check 3.

### P6: Clear header documentation

The 33-line header (lines 1-33) fully documents the DGP equations, the research question, all 9 models, the grid dimensions, and the parallelization strategy. A reader can understand what the script does without reading the code.

### P7: Appropriate grid design

The phi grid {0, 0.05, 0.10, 0.15} stops before the instability boundary (~0.18), while including phi=0 as the baseline anchor. The rho_Z grid {0.5, 0.7} tests moderate and high Z persistence. 8 scenarios x 500 reps = 4000 simulation runs is computationally reasonable while providing adequate statistical power (MCSE ~ SD/sqrt(500) ~ 0.04 * SD).

---

## Summary

This is a well-crafted simulation script that extends the dynamics simulation family to the strict exogeneity violation case (Y -> D feedback). The methodological specification is correct, the stationarity analysis is rigorous, the sanity checks are comprehensive, and the code follows project conventions. The minor issues identified are stylistic and do not affect results or reproducibility.

**Confirmation of A+ rating from review-r**: The score of 93/100 is consistent with an A+ grade (90+). The deductions are all minor/negligible. No critical or major issues were found.
