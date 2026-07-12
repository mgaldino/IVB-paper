# Task 14 protocol and validation gate

**Date:** 2026-07-12  
**Status:** pre-execution package; full Monte Carlo is blocked pending an independent Terra/high review.

## Scope and protected boundaries

This package operationalizes Task 14 in `quality_reports/plans/2026-07-10_referee_feedback_revision_plan.md`. It writes only under `simulations/lag_misspecification_persistence/` unless an explicit output directory is supplied. It does not edit the manuscript, `ivb_paper_psrm.*`, or prior simulations. Before and after the run, the runner hashes every existing file under `simulations/` outside this new package and fails if any hash changes.

## Design fixed before execution

The 27 full-grid cells are the Cartesian product of true ADL order `{1, 2, 3}`, `rho_D in {0.2, 0.5, 0.8}`, and direct first-lag carryover `{0, 0.25, 0.50}`. The retained panel has `N = 100`, `T = 30`, and burn-in 100; every cell receives 500 order-invariant seeded replications. The outcome-lag vectors are `(0.50)`, `(0.35, 0.25)`, and `(0.26, 0.18, 0.12)` for true ADL(1), ADL(2), and ADL(3), respectively. The lagged treatment coefficients equal `carryover * 0.5^(lag - 1)`.

These choices preserve the inherited dual-role timing where `Z_{t-1}` affects both current treatment and outcome, while `Z_t` responds after current treatment and outcome. The target remains the contemporaneous CET, not the sum of direct lagged treatment effects.

## Estimation and selection

The five reported rules are fixed ADL(1), fixed ADL(2), oracle true order, AIC-selected order, and BIC-selected order. Every ADL order includes the matching lags of both `Y` and `D`; every candidate for AIC/BIC includes `Z_{t-1}` and two-way fixed effects. The information criteria are computed from the within-model residual sum of squares with the same fixed effects in each candidate, so their penalty differs only by the dynamic regressors. AIC and BIC are not compared after results are observed and no criterion is promoted because it happens to work in a cell.

Each selected order is fit with no `Z`, with `Z_{t-1}`, and with `Z_t`. The recorded shifts are `beta(Z_{t-1}) - beta(no Z)` and `beta(Z_t) - beta(no Z)`. The `Z_t` fit is a post-treatment diagnostic, not an admissible estimator of the CET.

## Required metrics and denominators

The scenario-estimator-control summary reports bias, signed relative bias, RMSE, 95% CI coverage of the numerical CET, residual lag-one autocorrelation, MCSEs, and failure counts. Coverage for no-`Z` and `Z_t` specifications is a numerical diagnostic against the known DGP value; only the `Z_{t-1}` specification has the intended pre-exposure conditioning set. The selection-recovery file reports AIC and BIC separately, including the probability assigned to each candidate lag and the rate at which the selected order equals the true DGP order. All proportions use successful fits as their denominator and record the number of failed attempts beside them.

## Smoke-test approval gate

Before the full run, `smoke_test.R` must pass all of the following:

1. exact grid, parameter-range, balanced-panel, finite-value, and spectral-radius invariants;
2. bitwise deterministic draws for true ADL(1), ADL(2), and ADL(3);
3. agreement between the custom two-way-within coefficient and `fixest::feols()` below `1e-10`;
4. all five lag rules, all three control specifications, residual ACF, two shifts, and coverage indicators retained;
5. deterministic replication-level output and CSV round trip;
6. BIC correct-lag recovery of at least 80% in each large, pre-specified base DGP (`N = 300`, `T = 60`, 20 replications, `rho_D = 0.5`, carryover `0.25`) and complete retention of the separate AIC selection frequencies;
7. refusal of an ungated full command before any data are drawn.

The large-base check establishes that the estimator/selection code can recover the deliberately strong DGP signal. BIC provides the recovery sanity check because its stronger complexity penalty targets exact finite-order recovery; AIC is retained separately because it can over-select dynamic lags even in a correctly specified DGP. This distinction is a pre-specified reporting rule, not a license to promote BIC as the preferred applied criterion or to filter low-recovery full-grid cells.

## Full-run gate and failure discipline

The runner requires both `--approved` and `quality_reports/task14_lag_misspecification_persistence/independent_review_terra_high.md` containing the line `## Verdict: PASS`. It saves an atomic checkpoint after each scenario. A DGP failure generates 15 retained failed rows; a failure of any AIC/BIC candidate makes that criterion fail rather than selecting among a favorable remaining subset. Other estimator rules continue. Final CSVs are written atomically, and the report is rendered only from saved outputs.

## Post-run validation

The final validation checks the raw schema, expected row count, unique scenario-replication-estimator-control keys, exact grid values, seed completeness and uniqueness, finite successful coefficients, positive cluster-robust standard errors, binary coverage values, admissible selected lags, CSV readability, and pre-existing-simulation hashes. The final handoff also requires PDF openability, extracted-text inspection, and `git diff --check`.
