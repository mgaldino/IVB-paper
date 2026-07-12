# Task 14: lag misspecification and treatment persistence

This isolated package implements Task 14 of the canonical IVB revision plan. It tests the scope of the ADL(1) benchmark when the true conditional outcome process contains one, two, or three lags and treatment is persistent.

## Estimand and DGP

The target is the contemporaneous effect `beta_CET = 1`. For true lag order `p`, the outcome equation is

\[
Y_{it}=\alpha_i^Y+\beta_{CET}D_{it}+\sum_{\ell=1}^{p}\psi_\ell D_{i,t-\ell}+\sum_{\ell=1}^{p}\phi_\ell Y_{i,t-\ell}+\gamma_YZ_{i,t-1}+e_{it}.
\]

`carryover` is the direct first-lag treatment effect `psi_1`; higher treatment-lag coefficients decline geometrically at rate 0.5. Treatment follows the inherited dual-role assignment equation

\[
D_{it}=\alpha_i^D+\gamma_DZ_{i,t-1}+\rho_DD_{i,t-1}+u_{it},
\]

and contemporaneous `Z_it` is generated after `D_it` and `Y_it`. Thus `Z_{t-1}` is the pre-exposure control used in the primary estimators; `Z_t` is post-treatment and appears only in the descriptive specification-shift diagnostic.

## Pre-specified grid

The full grid has 27 cells:

- true ADL order: `1`, `2`, `3`;
- treatment persistence `rho_D`: `0.2`, `0.5`, `0.8`;
- carryover `psi_1`: `0`, `0.25`, `0.50`.

Each cell uses `N = 100`, `T = 30`, burn-in `100`, and 500 replications. Task 13 separately maps finite-`T` estimator bias; this package holds `N` and `T` fixed so its contrasts isolate lag misspecification, treatment persistence, and carryover.

For each replication the package estimates five pre-specified lag rules: fixed ADL(1), fixed ADL(2), oracle true order, AIC-selected order, and BIC-selected order. AIC and BIC compare candidate orders one through three using the `Z_{t-1}` specification only. They are reported separately and neither is selected ex post.

Each lag rule is then fit with no `Z`, with `Z_{t-1}`, and with `Z_t`. The latter is not treated as a CET estimator.

## Outputs

`results/` contains the raw replication file, scenario summaries, lag-selection recovery, the two specification shifts, residual-ACF summaries, failures, stability checks, validation, manifests, session information, logs, checkpoint files, and before/after hashes for every pre-existing simulation artifact. The PDF report reads these files; it never reruns the Monte Carlo.

## Commands

Preflight and logical invariants:

```bash
Rscript simulations/lag_misspecification_persistence/run_lag_misspecification_persistence.R --mode preflight
```

Bounded smoke test (including deterministic DGPs, all estimators, BIC correct-lag recovery in large base cases, fully retained AIC selection frequencies, residual autocorrelation, coverage, CSV round trip, and gate refusal):

```bash
Rscript simulations/lag_misspecification_persistence/smoke_test.R
```

The full run is intentionally blocked until an independent Terra/high review is saved at `quality_reports/task14_lag_misspecification_persistence/independent_review_terra_high.md` with exactly `## Verdict: PASS`. After that gate:

```bash
Rscript simulations/lag_misspecification_persistence/run_lag_misspecification_persistence.R \
  --mode full --reps 500 --approved --render-report
```

The runner refuses a full grid without `--approved`, refuses it without the review record, and refuses to overwrite final files without `--overwrite`. All failure rows remain in `raw_replications.csv`; no scenario or replication is filtered for estimator performance.
