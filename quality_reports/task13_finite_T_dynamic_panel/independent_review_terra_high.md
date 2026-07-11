# Independent review — Task 13 finite-T dynamic-panel package

**Date:** 2026-07-11  
**Reviewer:** independent Terra/high gate review  
**Scope:** pre-execution code review and bounded verification only; no full Monte Carlo grid and no implementation changes.

## Verdict: PASS

The package is cleared for the protocol's approved full-grid command. No repair is required before execution.

## Findings ordered by severity

### Blocking / major / minor findings

None. The implementation matches the Task 13 protocol and revision plan on all gate-critical requirements:

| Gate item | Independent finding | Evidence |
|---|---|---|
| Exact design and stability | PASS — principal grid is 3 x 6 x 3 = 54, stress grid is 3 x 3 x 2 = 18; IDs, ranges, scales, and the companion-matrix radius are validated. | [config.R](../../simulations/finite_T_dynamic_panel/R/config.R):51-196; [protocol](task13_protocol_and_code_review.md):42-66 |
| Inherited DGP and literal T | PASS — equations and inherited parameters match the dual-role source; burn-in is 100 and the retained pre-sample lag yields exactly `N*T` estimation rows. | [config.R](../../simulations/finite_T_dynamic_panel/R/config.R):24-48; [dgp.R](../../simulations/finite_T_dynamic_panel/R/dgp.R):1-83; [dual-role source](../../simulations/dual_role_z/sim_dual_role_z_8models.R):29-67,105-114 |
| FE-ADL and HPJ | PASS — both use two-way within transformation and unit-cluster sandwich inference. HPJ uses time-share weights, retains the full/half covariance through joint unit influences, and handles odd T. | [estimators.R](../../simulations/finite_T_dynamic_panel/R/estimators.R):13-72,82-132; [smoke_test.R](../../simulations/finite_T_dynamic_panel/tests/smoke_test.R):43-68 |
| Arellano–Bond sensitivity | PASS — label is sensitivity-only; one-step difference GMM uses collapsed 2--3 lag instruments, enforces the cap of 12, and retains AR(2) and Hansen-Sargan diagnostics. | [estimators.R](../../simulations/finite_T_dynamic_panel/R/estimators.R):134-224; [README.md](../../simulations/finite_T_dynamic_panel/README.md):17-23; [report](../../simulations/finite_T_dynamic_panel/finite_T_dynamic_panel_report.Rmd):143-164 |
| Estimands, metrics, reproducibility, and failures | PASS — the CET target, long-minus-short `Delta_Z`, phase indicator, MCSEs, order-invariant seeds, retained failure rows, and explicit denominators are implemented. | [simulation.R](../../simulations/finite_T_dynamic_panel/R/simulation.R):12-211,257-268; [metrics.R](../../simulations/finite_T_dynamic_panel/R/metrics.R):1-193; [config.R](../../simulations/finite_T_dynamic_panel/R/config.R):198-204 |
| Atomic outputs and report | PASS — scenario checkpoints and final CSVs use atomic writes; the raw schema is checked before saving; the report reads outputs rather than rerunning simulations. | [runner](../../simulations/finite_T_dynamic_panel/run_finite_T_dynamic_panel.R):64-152,195-244; [report](../../simulations/finite_T_dynamic_panel/finite_T_dynamic_panel_report.Rmd):13-43,69-186 |

### Informational observation

R emitted macOS locale-startup warnings (`LC_*` unavailable) during bounded tests. This neither changed the deterministic results nor prevented CSV/PDF creation; it is already documented as non-blocking in the protocol. No repair is required. [protocol](task13_protocol_and_code_review.md):179-195

## Bounded verification performed

- `--mode preflight`: PASS; all 14 invariants passed and the maximum spectral radius was 0.924319.
- `tests/smoke_test.R`: PASS; checked deterministic DGP and estimates, literal `T`, FE coefficient agreement with `fixest` below `1e-10`, clustered FE/HPJ inference, the 7/8 split at `T=15`, GMM diagnostics/cap, output schema, and deterministic rerun.
- Temporary two-replication smoke run with `--render-report`: PASS; retained 6 raw rows across 3 estimators, produced all declared output artifacts, rendered an openable XeLaTeX PDF, and produced PDF/PNG phase maps. The temporary output was outside the repository.
- Induced invalid-DGP bounded check: PASS; all three requested estimator attempts were retained as failed raw rows with `error_stage = "dgp"`.
- Ungated full command: PASS; `--mode full --reps 1` stopped before data drawing with the required `--approved` gate. [runner](../../simulations/finite_T_dynamic_panel/run_finite_T_dynamic_panel.R):167-172

## Protected-boundary check

`git diff --check` passed. Before adding this requested review, Git showed no modified tracked files; bounded tests created no repository outputs. There are no changes to existing simulations, results, `ivb_paper_pa.Rmd`, or `ivb_paper_psrm.*`. The only new repository artifact is this review.

## Required repairs

None.
