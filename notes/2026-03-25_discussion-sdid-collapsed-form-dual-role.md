# Discussion: SDiD Collapsed Form, Beta Estimation, and Dual-Role Covariates

**Date**: 2026-03-25
**Context**: Step 0 feasibility check — review of `scripts/step0_feasibility_check.R`

## 1. What is the collapsed form?

The `synthdid` package compresses the N x T panel into an (N0+1) x (T0+1) matrix before optimizing weights and beta:

```
Original (N x T):                        Collapsed (N0+1 x T0+1):

         t1 ... t_T0  t_T0+1 ... t_T           t1 ... t_T0  [post_avg]
ctrl_1  [...............................]   ctrl_1  [unchanged]  [mean(post)]
ctrl_2  [...............................]   ctrl_2  [unchanged]  [mean(post)]
...                                         ...
ctrl_N0 [...............................]   ctrl_N0 [unchanged]  [mean(post)]
trt_1   [...............................]   [avg_trt][means by t] [grand mean]
trt_2   [...............................]
...
trt_N1  [...............................]
```

- **N0+1 rows**: N0 control units (unchanged) + 1 row = average of N1 treated units
- **T0+1 cols**: T0 pre-treatment periods (unchanged) + 1 col = average of T1 post-treatment periods

**Why**: SDiD assigns uniform weight (1/N1) to treated units and (1/T1) to post-treatment periods. For optimizing omega (control weights) and lambda (pre-treatment weights), only the variation across controls and pre-treatment periods matters. The treated/post block can be summarized by its average.

## 2. What variation is used to estimate beta (covariate coefficient)?

From the source code of `sc.weight.fw.covariates`, the objective function uses:

| | Pre-treatment (T0 cols) | Post-treatment (1 col = avg) |
|---|---|---|
| **Controls (N0 rows)** | Used for omega AND lambda | Used for lambda |
| **Treated (1 row = avg)** | Used for omega | -- |

Key insight: **in all these cells, D = 0.** Controls have D=0 always; treated units only enter in pre-treatment, where D=0. Therefore, beta is estimated from variation where the D->Z post-treatment channel is INACTIVE.

This means beta captures the "clean" Z->Y relationship, uncontaminated by treatment.

## 3. Implications for the manual WLS cross-check

The `synthdid_estimate` with fixed weights estimates beta on the collapsed form (N0+1 x T0+1 system). A manual WLS (`lm` with weights) estimates beta on the full N x T panel. These are different optimization problems, so **beta_collapsed != beta_fullpanel in general**.

Consequence: `tau_hybrid(synthdid) != tau_wls(manual)`. This is NOT a failure of the hybrid estimator — it's informative about the difference between SDiD and standard WLS.

## 4. The SDiD-native FWL identity

From the `synthdid_estimate` source code, the final estimate is:

```r
X.beta = contract3(X, weights$beta)
estimate = t(c(-omega, rep(1/N1, N1))) %*% (Y - X.beta) %*% c(-lambda, rep(1/T1, T1))
```

With fixed weights (hybrid estimator):

```
CE = tau_hybrid - tau_short
   = omega_ext' * (Y - Z*beta_h) * lambda_ext  -  omega_ext' * Y * lambda_ext
   = -beta_h * (omega_ext' * Z * lambda_ext)
   = -beta_h * tau_Z
```

where:
- **beta_h** = `attr(fit_hybrid, "weights")$beta` (coefficient of Z from collapsed form)
- **tau_Z** = `omega_ext' * Z * lambda_ext` (SDiD "treatment effect" on Z — the double-difference of Z)

This maps to the IVB formula:

| TWFE | SDiD |
|---|---|
| theta* (coef of Z in long model) | beta_h (coef of Z from collapsed form) |
| pi (coef of D in Z ~ D + FE) | tau_Z (SDiD double-diff of Z) |
| IVB = -theta* x pi | CE = -beta_h x tau_Z |

## 5. The dual-role diagnostic and "controlling for" Z in SDiD

### What SDiD covariate adjustment actually does

1. Estimates beta from controls (and pre-treatment) — variation where D=0
2. Computes Y_adj = Y - Z*beta for ALL observations (including treated post-treatment)
3. Applies SDiD double-difference to Y_adj

For the treated unit post-treatment, the adjustment uses controls' beta. This means:
- If Z->Y is homogeneous (same for treated and controls): adjustment works
- If treatment modifies the Z->Y relationship: adjustment is imperfect

**Key insight (from user)**: "We're not really controlling for the shock in Brazil. We're capturing how the shock impacts controls and residualizing Y." This is fundamentally true of any synthetic control method — the counterfactual for the treated unit ALWAYS comes from controls.

### Why imperfect adjustment for treated is actually correct

If treatment modifies Z->Y, it's because D operates THROUGH Z — making Z a mediator. Controlling for a mediator is overcontrol (removes part of the causal effect we want to estimate). Not capturing this via beta is the correct behavior, not a failure.

The "problem" only exists if the estimand is the direct effect (excluding D->Z->Y). If the estimand is the total ATT (the standard case in SDiD), then:

- **Z as mediator**: don't control (overcontrol removes indirect effect)
- **Z as confounder**: control (removes bias)
- **Z dual-role**: trade-off, and the CE + RE decomposition quantifies the net balance

### Direction of bias

The sign of CE depends on beta_h x tau_Z:

| beta_h (Z->Y) | tau_Z (D->Z) | CE | Direction |
|---|---|---|---|
| positive | positive | negative | tau_long < tau_short |
| positive | negative | positive | tau_long > tau_short |
| negative | positive | positive | tau_long > tau_short |
| negative | negative | negative | tau_long < tau_short |

If the mechanism reverses sign, the bias reverses direction.

### Generalization

This reasoning applies to ANY time-varying covariate Z in SDiD (or SC, or IFE):
1. beta estimated from D=0 variation
2. Applied to entire panel
3. Implicit assumption: beta homogeneous between treated and controls
4. If treatment modifies Z->Y, adjustment is partial (and correctly so — it would be overcontrol)
5. CE = -beta_h x tau_Z captures the net of confounder and post-treatment channels
6. RE adds the weight-distortion dimension (new vs TWFE)

## 6. Motivational implication for the paper

The researcher doesn't know a priori whether Z is more confounder or more mediator. The decomposition IVB = CE + RE provides the answer with estimable quantities:
- CE large, RE small: the bias is mainly from the coefficient channel (FWL structure, interpretable)
- CE small, RE large: the bias is mainly from weight distortion (SDiD-specific)
- Signs of beta_h and tau_Z reveal the direction and dominant channel

## 7. RDD-Trade application (current account deficit)

- Z = current account deficit
- D = China becomes top trade partner (Brazil)
- Y = voting distance from China in UNGA
- 2008 crisis creates common Z->Y shock (higher deficit -> more China trade -> more alignment)
- D->Z channel: treatment may change Brazil's deficit trajectory
- The decomposition answers: is including deficit helping (removing 2008 confound) or hurting (removing indirect effect / distorting weights)?
