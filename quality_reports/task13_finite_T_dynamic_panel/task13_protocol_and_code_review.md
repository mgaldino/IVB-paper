# Task 13 preparation protocol and code-review gate

**Date:** 2026-07-11

**Scope:** preparation only; no full Monte Carlo run and no manuscript integration

**Status:** implementation and bounded smoke testing passed; independent second-model review remains a hard gate before the full command may be used.

## 1. Canonical requirement and protected boundaries

This protocol implements the preparation phase of Task 13 in `quality_reports/plans/2026-07-10_referee_feedback_revision_plan.md`. It creates a new, isolated package under `simulations/finite_T_dynamic_panel/`.

Protected files and directories are outside the write path of the runner:

- `ivb_paper_pa.Rmd`;
- `ivb_paper_psrm.*`;
- all pre-existing files under `simulations/`;
- all pre-existing simulation results.

The full runner requires the explicit `--approved` flag and refuses to overwrite its own final outputs unless `--overwrite` is also supplied.

## 2. Inherited dual-role DGP

For unit $i$ and period $t$:

\[
D_{it}=\alpha_i^D+\gamma_D Z_{i,t-1}+\rho_D D_{i,t-1}+u_{it},
\]

\[
Y_{it}=\alpha_i^Y+\beta_i D_{it}+\gamma_Y Z_{i,t-1}+\rho_Y Y_{i,t-1}+e_{it},
\]

\[
Z_{it}=\alpha_i^Z+\delta_D D_{it}+\delta_Y Y_{it}+\rho_Z Z_{i,t-1}+\nu_{it}.
\]

The package inherits `beta_CET = 1`, `rho_D = 0.5`, `rho_Z = 0.5`, `gamma_D = 0.15`, `gamma_Y = 0.2`, `delta_D = 0.1`, `delta_Y = 0.1`, Gaussian innovations with unit variance, Gaussian `alpha_D` and `alpha_Y` with unit standard deviation, `sigma_alpha_Z = 0.5`, and burn-in 100. These values match `simulations/dual_role_z/sim_dual_role_z_8models.R`, its finite-T variant, and the Task 10 inventory.

One deviation in data construction is pre-specified: the last burn-in observation supplies the lag for the first retained period. Therefore every declared `T` contributes exactly `T` estimation observations per unit rather than `T - 1`. This makes the finite-$T$ axis literal without altering any structural equation or parameter.

## 3. Exact grids

### Principal grid

The Cartesian product contains 54 scenarios:

- `N = {50, 100, 250}`;
- `T = {8, 10, 15, 20, 30, 50}`;
- `rho_Y = {0.2, 0.5, 0.8}`.

All other parameters remain at the inherited baseline.

### Stress grid

The Cartesian product contains 18 scenarios:

- `N = 100`;
- `T = {10, 20, 30}`;
- `rho_D = {0.2, 0.5, 0.8}`;
- `sigma_alpha_Z = {0.5, 2.0}`;
- `rho_Y = 0.5` and all remaining parameters at baseline.

The two `sigma_alpha_Z` levels are the existing low/high unit-effect heterogeneity levels from the inventoried eight-model dual-role DGP. No treatment-effect heterogeneity is introduced in Task 13.

Logical validation requires positive panel dimensions and scales, persistence parameters strictly inside $(-1,1)$, unique scenario IDs, the exact Cartesian products above, and companion-matrix spectral radius below one. Scenarios are never removed according to estimator performance.

## 4. Estimands, estimators, and inference

The target is the homogeneous contemporaneous effect `beta_CET = 1`. Every method estimates:

- short ADL: `Y ~ D + Y_lag`;
- long ADL: `Y ~ D + Y_lag + Z_lag`.

Both within models absorb unit and time effects. Standard errors cluster by unit to accommodate serial dependence. The split-panel jackknife is

\[
\widehat\beta_{HPJ}=2\widehat\beta_F-w_1\widehat\beta_{H1}-w_2\widehat\beta_{H2},
\]

where $w_h=T_h/T$. These weights retain the first-order cancellation when odd $T$ creates unequal halves. Its standard error combines the three unit-cluster influence functions before forming the sandwich variance, so covariance among full- and half-panel estimates is not discarded.

Arellano-Bond is a sensitivity benchmark under separate moment conditions. It uses one-step difference GMM, individual effects, robust standard errors, collapsed instruments, and lags 2--3 for the lagged outcome, treatment, and (in the long model) lagged control. The instrument count may not exceed 12. AR(2) and Hansen $p$-values are retained for both specifications. Because the DGP has no common time shocks, this sensitivity implementation does not add a growing set of time-dummy instruments. It is not a bias-corrected FE estimator and must never be labeled as one.

## 5. Pre-specified metrics

For every scenario-estimator cell, using the long specification unless stated otherwise:

- bias: `mean(beta_hat_long - beta_CET)`;
- relative bias: `bias / beta_CET`;
- RMSE: `sqrt(mean((beta_hat_long - beta_CET)^2))`;
- 95% coverage of `beta_CET`;
- `Delta_Z`: `mean(beta_hat_long - beta_hat_short)`;
- displacement magnitude: `abs(Delta_Z)` plus `mean(abs(delta_z_hat))`;
- phase indicator: `abs(bias) >= abs(Delta_Z)`.

Monte Carlo standard errors are reported for bias, RMSE (delta method applied to squared error), coverage (binomial MCSE), and `Delta_Z`. The raw file also retains replication-level estimates, standard errors, coverage indicators, errors, diagnostics, seeds, and displacement estimates.

Stability checks are pre-specified rather than used for selection:

- estimator failure rate at most 5%;
- bias MCSE at most 0.01;
- coverage MCSE at most 0.015;
- first-half versus second-half replication bias difference inside a two-sided 99% Monte Carlo interval;
- Arellano-Bond instrument count at or below 12.

A failed stability check is reported; it does not cause a scenario, replication, or estimator to be filtered.

## 6. Seeds, execution, and failure handling

The base seed is `13072026`. Replication seeds are order-invariant:

```text
seed = base_seed + 100000 * scenario_number + replication
```

Each DGP call sets `L'Ecuyer-CMRG` with its assigned integer seed. Rerunning a scenario or changing loop order therefore does not alter its draws.

The requested full repetition count is 500, matching the established dual-role simulation battery. A DGP failure creates failed rows for all requested estimators. An estimator failure creates a retained row with `status`, `error_stage`, and `error_message`; other estimators continue. Scenario-level checkpoint CSVs are written atomically. Final CSVs are also written atomically, and the runner checks the exact raw schema before saving.

## 7. Expected output schema

`raw_replications.csv` has one row per scenario, replication, and estimator. Its field groups are:

| Group | Fields |
|---|---|
| Design and seed | `scenario_id`, `design_family`, `scenario_number`, `replication`, `seed`, `N`, `T`, `rho_Y`, `rho_D`, `rho_Z`, `sigma_alpha_Z` |
| Estimator | `estimator_id`, `estimator`, `beta_true` |
| Short model | `beta_short`, `se_short`, `covered_short`, `nobs_short` |
| Long model | `beta_long`, `se_long`, `covered_long`, `nobs_long`, `estimation_error` |
| Shift | `delta_z_hat` |
| GMM diagnostics | short/long instrument counts, AR(2) $p$-values, and Hansen $p$-values |
| Failure audit | `estimator_warnings`, `status`, `error_stage`, `error_message` |

The summary file has one row per scenario-estimator cell and includes denominators, failures, all metrics and MCSEs. Separate files contain stability checks, failures, design, parameters, code hashes, run metadata, and session information.

## 8. Code-review checklist

| Review item | Preparation status | Evidence or required action |
|---|---|---|
| Canonical principal grid exact | Implemented | `task13_validate_grid()` requires 54 exact scenarios |
| Stress grid exact | Implemented | `task13_validate_grid()` requires 18 exact scenarios |
| DGP parameters traced to inventory/source | Implemented | Parameter manifest and this protocol |
| DGP date/value logic and stability checks | Implemented | dimensions, ranges, balance, finite values, spectral radius |
| FE-ADL coefficient verified against `fixest` | **PASS** | bounded test gap below `1e-10` |
| HPJ handles odd $T$ and covariance | **PASS** | tested 7/8 split at `T = 15`; time-share weights and joint cluster influence function |
| Arellano-Bond clearly sensitivity-only | Implemented | labels, report language, and README |
| Instruments collapsed and limited | Implemented | lag window 2--3, `collapse = TRUE`, cap 12 |
| AR(2)/Hansen diagnostics retained | Implemented | raw and summary schemas |
| Metrics and MCSEs pre-specified | Implemented | `R/metrics.R` |
| Failures retained, no favorable filtering | Implemented | failed raw rows and `failures.csv` |
| Deterministic rerun | **PASS** | exact equality across repeated one-replication runs |
| Output writer and PDF report | **PASS** | two-replication temporary run; PDF rendered and text extracted |
| Existing simulations/results untouched | **PASS** | final Git inspection shows only new Task 13 paths |
| Independent second-model review | **Pending hard gate** | must be completed before `--approved` full run |

## 9. Commands and execution gate

Preflight:

```bash
Rscript simulations/finite_T_dynamic_panel/run_finite_T_dynamic_panel.R --mode preflight
```

Bounded deterministic smoke test:

```bash
Rscript simulations/finite_T_dynamic_panel/tests/smoke_test.R
```

Exact full-grid command after independent review:

```bash
Rscript simulations/finite_T_dynamic_panel/run_finite_T_dynamic_panel.R --mode full --reps 500 --approved --render-report
```

Until the independent review is recorded, `--approved` must not be used.

## 10. Bounded verification record

The preparation phase completed the following bounded checks on 2026-07-11:

- preflight passed all 14 grid, value, and stability invariants; the largest companion-matrix spectral radius was `0.924319`;
- the DGP reproduced bitwise under the same `L'Ecuyer-CMRG` replication seed and produced a balanced, finite panel with exactly `N * T` rows;
- the custom long FE-ADL within coefficient matched `fixest::feols()` within `1e-10`;
- clustered FE-ADL and joint-influence HPJ standard errors were finite and positive;
- the odd-`T` HPJ test produced the intended 7/8 split at `T = 15`, with weights summing to one;
- bounded Arellano-Bond fits at `T = 8` and at the `T = 50`, `rho_Y = 0.8` grid edge produced finite estimates and diagnostics while retaining the collapsed-instrument cap;
- repeated one-replication runs were exactly identical across all three estimators;
- a two-replication temporary runner test retained six raw rows, three summary rows, three stability rows, and zero failures;
- the temporary report rendered through XeLaTeX as a three-page, openable PDF and created standalone PDF and PNG phase maps; extracted text and page images were inspected;
- the full-grid command without `--approved` stopped before drawing data;
- `git diff --check` passed, and repository status showed only the two new Task 13 directories.

R emitted macOS locale startup warnings for unavailable locale categories in this shell, but all scripts, CSV headers, Markdown, and rendered text passed their substantive checks. This is not a blocker for the reviewed full run.
