# Plan: Steps 1-3 — Formal Derivation of IVB Decomposition for SDiD

**Status**: COMPLETED (Steps 1 + 2 + 3)
**Date**: 2026-03-26 (updated 2026-03-27)

## Objective

Write formal mathematical derivation of IVB = CE + RE for the SDiD estimator (Step 1), derive sufficient conditions for RE = 0 (Step 2), and present a practical diagnostic procedure (Step 3).

## Deliverable

`derivations/sdid_ivb_decomposition.Rmd` — standalone derivation note (~8 sections, compiles to PDF).

## Content

1. Setup and notation (panel, SDiD weights, collapsed form, notation bridge to TWFE)
2. SDiD estimator with covariates (joint optimization, beta from D=0 variation)
3. Three estimators (short, long, hybrid) and IVB decomposition (Definition)
4. **Proposition 1**: CE = -beta_h x tau_Z (FWL-like identity, with proof)
   - Remark: identity is purely algebraic (holds for any beta)
5. Fixed weights imply RE = 0 (Corollary + TWFE Remark)
6. Characterization of RE:
   - No closed form (Shapley-like path dependence)
   - **Proposition 2** (Step 2): Additive Z (Z_it = a_i + b_t) implies RE = 0
     - Proof via two mechanisms: simplex cancellation + intercept absorption
     - Special cases: time-invariant Z, unit-invariant Z
   - Approximate RE ≈ 0 when within-variation of Z is small
   - When RE is large (interactive variation + strong beta + heterogeneity)
7. **Diagnostic procedure** (Step 3):
   - R² pre-diagnostic for RE magnitude
   - 4-step protocol (pre-diagnostic → compute → decompose → report)
   - Interpretation guide (IVB small, CE-dominated, RE-dominated, cancellation)
   - What the diagnostic does NOT do (sensitivity analysis, not specification test)
   - Inference (placebo-based, jackknife)
   - Reporting table template

## Mathematical review (2026-03-26)

- [x] Proposition 1 proof: correct (algebraic identity)
- [x] Collapsed form remark: verified (4 blocks)
- [x] TWFE corollary: CORRECTED (SDiD uniform ≠ TWFE with covariates; β_h ≠ θ*)
- [x] Multi-covariate generalization: correct
- [x] Proposition 2 proof: verified (4 cases: a_i×{ω,λ} + b_t×{ω,λ})

## Verification

- [x] Algebra: CE identity proof self-contained and correct
- [x] Algebra: RE=0 conditions proof rigorous (4-case structure)
- [x] Notation: consistent with IVB paper (theta* -> beta_h, pi -> tau_Z)
- [x] Numerical: matches Step 0 results (CE = -0.311, RE = -0.211)
- [ ] Compile: Rmd -> PDF (pending user approval)
- [ ] Review: review-r or equivalent (pending)
