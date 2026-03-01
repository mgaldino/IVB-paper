# IVB Replication Report: Hegre et al. (2001)

**Paper**: Hegre, Håvard, Tanja Ellingsen, Scott Gates, and Nils Petter Gleditsch. 2001. "Toward a Democratic Civil Peace? Democracy, Political Change, and Civil War, 1816–1992." *American Political Science Review* 95(1): 33–48.

**Data source**: https://havardhegre.net/wp-content/uploads/2013/09/civpeacereplicationdata.zip

**Date**: 2026-03-01

---

## Context

This paper is the running example used in Sections 2.2–2.3 of the IVB paper to motivate collider bias and "foreign collider bias." The core concern is that Democracy Level (`demo`) may be a collider when included alongside Proximity of Regime Change (`prc`) in a civil war onset equation.

## Methodological Note

The original specification uses **Cox Proportional Hazards** (`stcox` in Stata), not OLS or TWFE. Since the IVB formula is derived for linear models via FWL, we approximate the original specification using a **Linear Probability Model (LPM) with Two-Way Fixed Effects** (country + year FE), restricted to post-1946 observations (matching the main specification in Table 2 of the paper). This is the MPL (Modelo de Probabilidade Linear) approximation for nonlinear models.

## Specification

- **Outcome**: `status` (civil war onset, binary 0/1)
- **Treatment**: `prc` (Proximity of Regime Change, continuous 0–1)
- **Controls**: `demo` (democracy, Polity score −10 to 10), `demosq` (democracy squared), `pcw` (proximity of civil war), `pi` (proximity of independence), `interwar`, `neighbwa` (neighboring war), `ln_energ` (log energy consumption, development proxy), `energsq`
- **FE**: Country (`ss_numbe`, COW codes) + Year
- **Sample**: Post-1946, N = 8,416 country-years, 157 countries, 39 years
- **Note**: `ethnic_h` (ethnic heterogeneity) is essentially time-invariant (within-unit SD = 0.02) and is absorbed by country FE

## Results

```
beta_long(prc) = 0.0167
SE(clustered)  = 0.0088
t-stat         = 1.89 (NOT significant at 5%)
```

### IVB Decomposition

| Collider   | β_short  | β_long   | θ*       | π       | IVB       | |IVB|/SE | IVB/β (%) |
|------------|----------|----------|----------|---------|-----------|---------|-----------|
| demo       | 0.0158   | 0.0167   | −0.0004  | 2.481   | 0.0009    | 0.10    | ---       |
| demosq     | 0.0179   | 0.0167   | −0.0002  | −6.990  | −0.0012   | 0.14    | ---       |
| pcw        | 0.0144   | 0.0167   | −0.0495  | 0.047   | 0.0023    | 0.27    | ---       |
| pi         | 0.0144   | 0.0167   | −0.0263  | 0.087   | 0.0023    | 0.26    | ---       |
| interwar   | 0.0168   | 0.0167   | 0.0085   | 0.006   | −0.0000   | 0.01    | ---       |
| neighbwa   | 0.0170   | 0.0167   | 0.0053   | 0.049   | −0.0003   | 0.03    | ---       |
| ln_energ   | 0.0173   | 0.0167   | −0.0037  | −0.151  | −0.0006   | 0.06    | ---       |
| energsq    | 0.0166   | 0.0167   | 0.0003   | −0.488  | 0.0001    | 0.02    | ---       |

**IVB/β**: All "---" because the treatment effect is not statistically significant (|t| = 1.89 < 1.96).

### FWL Identity Check

Max |IVB_formula − IVB_direct| = 5.64 × 10⁻¹⁸. Identity holds to machine precision.

## Interpretation

1. **Democracy (demo)**: The candidate collider from the paper's running example. |IVB|/SE = 0.10 — the bias from including democracy is about one-tenth of a standard error. Completely negligible. θ* = −0.0004 (democracy has virtually no partial effect on civil war onset after controlling for other variables and FE), and π = 2.48 (regime change strongly predicts democracy level, as expected).

2. **Proximity of civil war (pcw)** and **Proximity of independence (pi)**: These produce the largest IVBs (|IVB|/SE ≈ 0.27 and 0.26 respectively), but still well below 1 SE. Both have large θ* (−0.049 and −0.026) but small π (0.047 and 0.087), reflecting that regime change is only weakly associated with these variables within countries after FE.

3. **All controls**: Every |IVB|/SE < 0.30. The maximum total IVB across all controls is 0.0036, which is 0.41 SE — modest.

4. **Treatment effect**: Not significant in the LPM TWFE specification (t = 1.89). This is consistent with the paper's substantive finding that the inverted-U relationship between democracy and civil war is the main result, not a linear effect of regime change.

## Collider Classification (DAG-based)

| Control    | D→Z | Y→Z | Classification | Key references |
|------------|-----|-----|----------------|----------------|
| demo       | Regime change → democracy (direct, definitional) | Civil war → regime change → democracy | **Collider** | Hegre et al. (2001) |
| demosq     | Same mechanism (squared) | Same | **Collider** (mechanical) | --- |
| pcw        | Regime change temporally follows civil war (proximity measure) | Civil war → pcw (mechanical) | **Predetermined** (lag structure) | --- |
| pi         | Regime change near independence | Civil war near independence | **Confounder** (common cause: state formation) | --- |
| interwar   | Weak | Weak | **Predetermined** | --- |
| neighbwa   | Regime change → regional instability | Civil war → regional instability | **Collider** (weak) | Gleditsch (2002) |
| ln_energ   | Regime change → development (long run) | Civil war → destruction | **Collider + Confounder** | Acemoglu et al. (2019); Blattman & Miguel (2010) |
| energsq    | Same (squared) | Same | **Collider + Confounder** (mechanical) | --- |

**Collider candidates**: demo, demosq, neighbwa, ln_energ/energsq

## Summary

The Hegre et al. (2001) civil war study — the running example in the IVB paper — produces negligible IVBs across all controls. The candidate collider at the heart of the example (democracy level) has |IVB|/SE = 0.10. This is consistent with the pattern observed across the other six replicated studies: in TWFE panel settings with slow-moving variables, IVBs tend to be small because fixed effects absorb between-unit variation.

**Caveat**: This replication uses a LPM TWFE approximation of the original Cox PH model. The IVB formula does not directly apply to Cox models. The LPM results should be interpreted as an approximation that captures the direction and rough magnitude of the biases.
