# Spec: IVB Extension to SDiD and Factor Models

**Date**: 2026-03-25
**Status**: DRAFT
**Type**: New paper (potentially companion or extension of IVB paper — TBD)

## Research question

When a researcher has a time-varying covariate Z that may be both a confounder (Z affects D and/or Y, including via time fixed effects) and post-treatment (D affects Z), and the temporal ordering is ambiguous, what is the bias from including Z in modern panel estimators (SDiD, SC, Factor Models), and how can it be diagnosed?

## Core contribution

A decomposition of the bias from including Z ("bad control") into two estimable components:

```
IVB = Coefficient Effect (CE) + Reweighting Effect (RE)
```

- **Coefficient Effect**: bias from conditioning on a collider/mediator, holding weights/factors fixed.
- **Reweighting Effect**: additional bias from Z distorting the synthetic weights or latent factors. New and specific to adaptive-weight estimators.

### Definition of bias

For each estimator, define:
- τ̂_short(ω_short, λ_short) = ATT estimate without Z, using weights/factors from the no-Z specification
- τ̂_long(ω_long, λ_long) = ATT estimate with Z, using weights/factors from the with-Z specification
- IVB = τ̂_long - τ̂_short (difference in ATT estimates from including Z)

This is the **estimator-level** difference, not a population bias. Both specifications target the ATT under their respective identifying assumptions. The IVB captures how much the point estimate changes from including Z — which is what the researcher needs to know for decision-making.

Note: including Z may change not just the estimate but the identifying assumptions themselves (e.g., the implicit parallel trends condition in SDiD). The decomposition helps the researcher understand WHERE the change comes from (coefficient channel vs weight distortion).

### Proof sketch: why the decomposition is well-defined (SDiD case)

The decomposition follows from adding and subtracting a hybrid estimator:

```
τ̂_hybrid = τ̂(ω_short, λ_short, with Z)
```

This is the ATT from running SDiD with Z included as covariate, but FORCING the weights (ω, λ) to equal those from the no-Z specification (i.e., skipping the joint re-optimization and only estimating β and τ in the weighted regression step).

Then:
```
IVB = [τ̂_hybrid - τ̂_short]     +  [τ̂_long - τ̂_hybrid]
       ─────────────────────         ────────────────────
       CE: same weights,             RE: effect of weight
       Z added to regression         re-optimization
```

- **CE**: Given fixed weights, the second step of SDiD is a weighted least squares regression. FWL applies to WLS, so CE = -θ̂*_ω × π̂_ω, where:
  - θ̂*_ω = coefficient of Z in the WLS regression Y ~ D + Z + (unit intercepts) + (time intercepts), weighted by W = ω_short ⊗ λ_short. This is "how much does Z predict Y, conditional on D, in the weighted regression."
  - π̂_ω = coefficient of D in the auxiliary WLS regression Z ~ D + (unit intercepts) + (time intercepts), same weights W. This is "how much does D predict Z, conditional on unit/time structure, in the weighted regression."
  - The intercept terms follow from the SDiD specification (unit and time dummies, or equivalently the demeaning structure implied by ω and λ).
- **RE**: This term captures how much the ATT changes when we allow the weights to re-optimize in the presence of Z. It is computable (run both τ̂_long and τ̂_hybrid), but may not have a closed-form expression.

**Feasibility check needed**: This sketch assumes (1) that fixing ω, λ from the no-Z model and adding Z to the WLS step yields a well-defined estimator, and (2) that FWL applies to the penalized WLS in SDiD (the regularization terms on ω, λ are absent when weights are fixed, so the regression step IS standard WLS). Point (2) seems solid; point (1) needs formal verification.

### Why it matters

The bad controls literature (Angrist & Pischke, Caetano et al., Lin & Zhang) operates in TWFE. Researchers using SDiD/SC/IFE have no tools to diagnose whether a covariate is helping (reducing OVB) or hurting (introducing collider bias + distorting weights).

### Key clarification

Z has a dual role: it is potentially both confounder AND post-treatment. The researcher does not know a priori whether including Z helps or hurts. The decomposition provides a diagnostic to answer this question with estimable quantities.

## Estimators covered

Progression from simple (RE=0) to complex:

| Estimator | How Z enters | Reweighting Effect |
|---|---|---|
| **DiD/TWFE** | Linear covariate | **= 0** (OLS weights fixed) → IVB = -θ*×π |
| **SC classical** (Abadie et al.) | Predictor in matching (pre-treatment Z) or covariate adjustment | ω changes with Z. Note: standard SC uses pre-treatment predictors only; post-treatment Z requires modified framework (e.g., SCM with covariates à la Botosaru & Ferman 2019). May be dropped if framework doesn't apply cleanly. |
| **SDiD** (Arkhangelsky et al. 2021) | Partially linear model | ω and λ change with Z (joint optimization over ω, λ, β) |
| **IFE/GSC** (Bai 2009, Xu 2017) | Covariate + latent factors | Factors λ_i'f_t re-estimated conditionally on Z |

### Technical detail: SDiD with covariates

Verified from `synthdid` R package source code: when covariates X are supplied, the package performs joint alternating optimization over (ω, λ, β). Weights are computed on residualized Y (Y - Xβ), not raw Y. Therefore, including/excluding Z changes the weights — the Reweighting Effect is non-zero in general.

## Analytical strategy

### Step 0 — Feasibility check: hybrid estimator for SDiD

**Prerequisite before any derivation.** The entire decomposition rests on the hybrid estimator τ̂_hybrid being computable. This requires:

1. Run `synthdid_estimate` WITHOUT Z → extract ω_short, λ_short
2. Run a weighted least squares regression of Y on (D, Z, unit/time intercepts) using weights (ω_short ⊗ λ_short) → this is τ̂_hybrid

The `synthdid` package does NOT support step 2 natively (it always jointly optimizes weights). Custom code is needed: extract the weight vectors from step 1, construct the weight matrix, run WLS manually. This is a ~50-line R script, not a package modification.

**If this works**: the decomposition is computationally feasible and the project proceeds.
**If this fails** (e.g., the SDiD intercept structure makes the WLS ill-defined): the decomposition approach needs rethinking.

### Step 1 — Derive the decomposition for each estimator

For each family (TWFE, SC, SDiD, IFE):
1. Write τ̂_short and τ̂_long in closed form (or semi-closed form)
2. Decompose IVB = τ̂_long - τ̂_short into the two terms
3. Express the Coefficient Effect via FWL (under fixed weights)
4. Characterize the Reweighting Effect — conditions for it to be large/small, bound if possible

### Step 2 — Special case: when Reweighting Effect = 0

Identify sufficient conditions (e.g., Z orthogonal to the space that determines weights, or Z with no additional predictive power for pre-treatment Y).

### Step 3 — Estimable diagnostic

Show that the researcher can estimate both terms with available quantities:
- Coefficient Effect: run the estimator with Z but forcing weights from the model without Z
- Reweighting Effect: difference between total IVB and Coefficient Effect

### Step 4 — Applied illustration

Apply the decomposition to real data (RDD-Trade case). Not a Monte Carlo simulation — application of the formula to actual data.

## Applied case: RDD-Trade (author's own paper)

The author's own paper, currently in R&R, on foreign policy impact when China overtakes the US as top trade partner. Full data and code access available.

- **Treatment**: moment China becomes top trade partner
- **Outcome**: voting distance from China in UNGA
- **Problematic covariate**: current account deficit
  - Confounder channel: deficit → trade patterns → treatment; deficit → 2008 crisis response → alignment
  - Post-treatment channel: treatment → trade flow changes → deficit
- **Estimator**: SDiD (`synthdid` package)
- **Code location**: `/Users/manoelgaldino/Documents/DCP/Papers/RDD Trade/red_trade/`

### Use in the paper

After deriving the decomposition, apply to the concrete case:
1. Estimate SDiD with and without current account deficit
2. Compute total IVB
3. Decompose into CE + RE
4. Answer: is including the deficit helping (removing OVB from 2008 shock) or hurting (introducing collider bias + distorting weights)?

## Paper structure (tentative)

1. **Introduction** — Ambiguous Z (confounder + post-treatment), researchers lack diagnostic tools for SDiD/IFE
2. **Framework** — General decomposition: IVB = CE + RE. TWFE as benchmark (RE=0)
3. **SDiD** — Derivation for joint optimization (ω, λ, β). Core of the paper.
4. **IFE/GSC** — Derivation for latent factors (extension, if tractable)
5. **Diagnostic** — How the researcher estimates CE and RE in practice
6. **Application** — RDD-Trade: current account deficit
7. **Conclusion**

Note: SC classical dropped from main structure. Standard SC uses pre-treatment predictors only, so post-treatment Z doesn't enter the framework without substantial modifications. Can be added back as appendix/extension if a clean formulation emerges.

## Relationship to existing IVB paper

TBD — depends on what emerges from the formal derivations. Possibilities:
- Separate paper (IVB paper follows its own path as bridge DID/TSCS)
- IVB paper absorbed as a section (TWFE as special case in a broader paper)
- Companion papers

## Key references

- Arkhangelsky, Athey, Hirshberg, Imbens & Wager (2021) — SDiD
- Abadie, Diamond & Hainmueller (2010) — SC
- Bai (2009) — Interactive Fixed Effects
- Xu (2017) — Generalized Synthetic Control
- Caetano & Callaway (2024) — Bad controls in DID
- Lin & Zhang (2022) — Covariate effect bias in dynamic TWFE
- Angrist & Pischke (2009) — Bad controls (original formulation)
- Blackwell & Glynn (2018) — ADL and post-treatment bias in TSCS

## Minimum viable paper

**Core (must have)**: SDiD decomposition (CE + RE) + applied illustration (RDD-Trade). This is the smallest publishable unit and the highest-priority deliverable.

**Extensions (nice to have)**:
- TWFE as benchmark (largely exists in IVB paper — can be summarized)
- IFE/GSC derivation
- SC classical (may not apply cleanly — see note in estimators table)

## Open risks

1. **Reweighting Effect may not have closed-form bound** for SDiD/IFE — may require case-specific numerical estimation. If RE is just a residual with no structure, diagnostic value is limited.
2. **Feasibility of the hybrid estimator**: the proof sketch assumes fixing weights from the no-Z model and adding Z to WLS is well-defined. Needs formal verification (especially: does the `synthdid` objective function separate cleanly into weight-optimization and regression steps?).
3. **SC classical**: uses pre-treatment predictors only — post-treatment Z doesn't enter the standard framework. May need to be dropped or treated as a special case.
4. **IFE**: number of factors is chosen by the researcher — decomposition may depend on factor specification.
5. **Scope creep**: four estimators × formal derivations is ambitious. Mitigated by "minimum viable paper" definition above.
