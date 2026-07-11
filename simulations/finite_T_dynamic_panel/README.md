# Task 13 finite-T dynamic-panel simulation package

This directory prepares the new Monte Carlo study requested in Task 13. It is isolated from all existing simulations and results. The main runner is `run_finite_T_dynamic_panel.R`; computation is separated into scripts under `R/`, and the RMarkdown report only reads completed CSV outputs.

## Design

The principal grid is exactly:

- `N = {50, 100, 250}`;
- `T = {8, 10, 15, 20, 30, 50}`;
- `rho_Y = {0.2, 0.5, 0.8}`.

The stress grid fixes `N = 100` and `rho_Y = 0.5`, varies `T = {10, 20, 30}` and `rho_D = {0.2, 0.5, 0.8}`, and uses the existing dual-role unit-effect heterogeneity levels `sigma_alpha_Z = {0.5, 2.0}`. All other structural parameters reproduce the inventoried dual-role DGP: `beta = 1`, `rho_Z = 0.5`, `gamma_D = 0.15`, `gamma_Y = 0.2`, `delta_D = delta_Y = 0.1`, and burn-in `100`.

The only construction change is documented and tested: a lag from the final burn-in period is retained so the declared `T` is exactly the number of estimation periods. The structural equations and parameter values do not change.

## Estimators

- FE-ADL within, with unit and time fixed effects and unit-clustered inference;
- split/half-panel jackknife FE-ADL, with time-share weights for odd `T` and a joint cluster-sandwich variance that preserves covariance among the full and half-panel estimates;
- Arellano-Bond only as a sensitivity benchmark, using one-step difference GMM, collapsed instruments, lags 2--3, an instrument cap of 12, and recorded AR(2) and Hansen diagnostics. It is never described as bias-corrected FE.

Each estimator is run in a short specification (`D + Y_lag`) and a long specification (`D + Y_lag + Z_lag`). The contemporaneous effect is the coefficient on `D`; `Delta_Z` is the long-minus-short coefficient within the same replication and estimator.

## Commands

Preflight only:

```bash
Rscript simulations/finite_T_dynamic_panel/run_finite_T_dynamic_panel.R --mode preflight
```

Deterministic bounded smoke test:

```bash
Rscript simulations/finite_T_dynamic_panel/tests/smoke_test.R
```

The full grid is deliberately gated. After independent review, the exact command is:

```bash
Rscript simulations/finite_T_dynamic_panel/run_finite_T_dynamic_panel.R --mode full --reps 500 --approved --render-report
```

Without `--approved`, a full run stops before drawing data. Existing final outputs are not overwritten unless `--overwrite` is explicitly supplied. Per-scenario checkpoints are written before final aggregation.

## Full-run outputs

The runner will create these files under `results/`:

- `design_grid.csv`;
- `raw_replications.csv`;
- `scenario_estimator_summary.csv`;
- `stability_checks.csv`;
- `failures.csv`;
- `parameter_manifest.csv`;
- `code_manifest.csv`;
- `run_manifest.csv`;
- `session_info.txt`;
- `finite_T_dynamic_panel_report.pdf`;
- `phase_map.pdf` and `phase_map.png`;
- `checkpoints/<scenario_id>.csv`.

Every requested estimator attempt remains in the raw file. Failures are rows rather than silently dropped replications. Summary denominators, failure rates, Monte Carlo standard errors, and first-half/second-half stability checks are explicit.
