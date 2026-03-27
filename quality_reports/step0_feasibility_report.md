# Step 0 — Feasibility Check Report

**Date**: 2026-03-25
**Status**: COMPLETED
**Branch**: feature/ivb-sdid-factor-models

## Objective

Verify that the IVB decomposition IVB = CE + RE is computationally feasible for SDiD by constructing the hybrid estimator.

## DGP

Simple panel: N=40 (30 control), T=20 (15 pre-treatment).

```
Y_t = 1.0*D_t + 0.5*Z_t + mu_i + xi_t + eps
Z_t = 0.8*D_t + 0.3*Y_{t-1} + 0.3*mu_i + nu
```

**Z is purely post-treatment/mediator, NOT a confounder.** D→Z (gamma=0.8), Z→Y (delta=0.5), Y_lag→Z (gamma=0.3). Z does not cause D. Shared mu_i absorbed by unit FE.

Including Z is overcontrol: removes D→Z→Y indirect effect without compensating any confounding.

## True estimand

Total ATT (reduced form): ATT_t = beta + delta*gamma_D + dynamic accumulation via Y_lag→Z→Y.

| Period | ATT_t |
|---|---|
| T0+1 | 1.400 |
| T0+2 | 1.610 |
| T0+3 | 1.642 |
| T0+4 | 1.646 |
| T0+5 (steady state) | 1.647 |
| **Average** | **~1.589** |

Steady state: ATT_ss = 1.4 / (1 - delta*gamma_Yl) = 1.4/0.85 = 1.647.

## Results

| Estimator | Value | Target | Approx bias |
|---|---|---|---|
| tau_short (SDiD without Z) | 1.673 | Total ATT (~1.59) | +0.08 (small, finite sample) |
| tau_long (SDiD with Z) | 1.151 | Direct effect (~1.0) | +0.15 |
| tau_hybrid (fixed weights + Z) | 1.362 | -- | Intermediate |

### Decomposition

```
IVB = tau_long - tau_short = -0.522
  CE = tau_hybrid - tau_short = -0.311  (59.6% of IVB)
  RE = tau_long - tau_hybrid  = -0.211  (40.4% of IVB)
```

IVB is overcontrol bias: including Z removes ~0.52 of the indirect D→Z→Y effect.

### SDiD FWL-like identity

```
CE = -beta_h * tau_Z
   = -0.285 * 1.089
   = -0.311  (matches CE exactly, error ~4e-16)
```

- beta_h: Z→Y coefficient from collapsed form (D=0 variation)
- tau_Z: SDiD double-difference of Z (captures D→Z effect)

### Weight comparison

- max |omega_long - omega_short| = 0.007 (small unit weight change)
- max |lambda_long - lambda_short| = 0.111 (larger time weight change)

### WLS vs synthdid

beta_hybrid (collapsed form) = 0.285 vs theta_wls (full panel) = 0.557. Difference = 0.271.

Collapsed-form beta is estimated from D=0 variation (controls + pre-treatment). Full-panel WLS uses all N×T observations. Different optimization objectives → different beta → different tau.

### TWFE benchmarks

| Benchmark | IVB | RE |
|---|---|---|
| TWFE (SDiD weights) | -0.606 | 0 (PASS) |
| TWFE (uniform weights) | -0.671 | 0 (PASS) |
| SDiD | -0.522 | -0.211 |

TWFE always has RE=0 (OLS weights fixed). SDiD's adaptive weights attenuate IVB relative to TWFE.

## Checks (all passed)

| Check | Status |
|---|---|
| [1] Decomposition identity (IVB = CE + RE) | PASS |
| [2] SDiD FWL-like (CE = -beta_h * tau_Z) | PASS |
| [3] WLS FWL (tautological, validates code) | PASS |
| [4] WLS vs synthdid hybrid | DIFFER by 0.295 (expected) |
| [5] RE != 0 (weights changed) | PASS |
| [6] TWFE RE = 0 (SDiD weights) | PASS |
| [7] TWFE RE = 0 (uniform weights) | PASS |

## Key findings

1. **Decomposition is computationally feasible.** `synthdid_estimate` natively supports the hybrid estimator via `weights` + `update.omega/lambda = FALSE`.

2. **CE satisfies an FWL-like identity**: CE = -beta_h * tau_Z, with machine precision. This maps directly to the TWFE formula IVB = -theta* * pi, with SDiD-native quantities.

3. **RE is substantial** (40% of IVB). In SDiD, unlike TWFE, including Z changes the weights — this matters.

4. **Collapsed-form beta differs from full-panel WLS beta.** synthdid estimates beta from D=0 variation (collapsed form). This is actually desirable: captures "clean" Z→Y relationship without treatment contamination.

5. **CE and RE are estimable from observables.** Three calls to `synthdid_estimate` (short, long, hybrid) suffice. No latent quantities needed.

## Implication for the paper

The feasibility check confirms the project can proceed. The decomposition works, the FWL-like identity holds, and both CE and RE are computable from standard output. Step 1 (formal derivation) can build on this computational foundation.

## Note on DGP limitation

This DGP has Z as purely post-treatment (no confounding). To test the dual-role scenario (Z is confounder AND mediator), a future DGP should add a confounder channel (e.g., a shock W that causes both Z and Y, not absorbed by FE).

## Files

- Script: `scripts/step0_feasibility_check.R`
- Results CSV: `scripts/step0_feasibility_results.csv`
- Session info: `scripts/step0_feasibility_sessioninfo.txt`
- Discussion notes: `notes/2026-03-25_discussion-sdid-collapsed-form-dual-role.md`
