# Reproducibility Audit: Task 13 Integration in `ivb_paper_pa`

**Date:** 2026-07-12  
**Manuscript:** `ivb_paper_pa.Rmd` and rendered `ivb_paper_pa.pdf`  
**Output:** `simulations/finite_T_dynamic_panel/results/scenario_estimator_summary.csv`  
**Scope:** principal-grid FE-ADL within and split-panel jackknife FE-ADL cells only

## Summary

| Status | Count |
|---|---:|
| PASS | 7 |
| FAIL | 0 |
| UNMATCHED | 0 |
| **Overall verdict** | **PASS** |

## Claim checks

| Claim | Reported | Computed from completed output | Difference | Tolerance | Status |
|---|---:|---:|---:|---:|---|
| FE-ADL phase cells | 0/54 | 0/54 | 0 | exact | PASS |
| Split-panel jackknife phase cells | 6/54 | 6/54 | 0 | exact | PASS |
| Displayed principal-grid cells | 108 | 108 | 0 | exact | PASS |
| Maximum absolute bias | 0.0454 | 0.0454296317922152 | 0.0000296317922152 | 0.01 | PASS |
| Maximum absolute mean shift | 0.0381 | 0.0381323662151438 | 0.0000323662151438 | 0.01 | PASS |
| Minimum empirical 95% coverage | 0.700 | 0.700 | 0 | 0.01 | PASS |
| Monte Carlo replications per displayed cell | 500 | 500 | 0 | exact | PASS |

The computed comparison is `abs(bias) >= abs(mean_delta_z)`. The audit uses all 108 completed principal-grid cells for `fe_adl` and `hpj_fe_adl`; no scenario or replication is filtered according to estimator performance.
