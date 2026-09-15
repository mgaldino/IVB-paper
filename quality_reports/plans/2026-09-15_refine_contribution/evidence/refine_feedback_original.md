# From Specification Shifts to Included Variable Bias in Dynamic Panels: A Diagnostic for Time-Varying Controls and a Benchmark for the Contemporaneous Treatment Effect

**Date**: 14/09/2026, 22:28:55
**Domain**: social_sciences/political_science
**Taxonomy**: academic/research_paper
**Filter**: Active comments

---

## Overall Feedback

**The analytic value of the specification-shift identity**

Sections 1 and 4 identify the exact decomposition $\widehat{\beta}^{\star}-\widehat{\beta}=-\widehat{\theta}^{\star} \widehat{\pi}$ as a primary contribution. Because this identity and its interpretation across nested regressions rely on established omitted-variable bias and Frisch-Waugh-Lovell algebra, readers will look for the distinct diagnostic value it adds to existing practices.

Neither $\widehat{\pi}$ nor $\widehat{\theta}^{\star}$ inherently diagnoses treatment responsiveness. The quantity $\widehat{\pi}$ can reflect confounding as much as a treatment effect, and $\widehat{\theta}^{\star}$ remains a conditional projection coefficient. The paper accurately notes that directed acyclic graphs and timing judgments are necessary, but this advice intersects heavily with existing literatures on bad controls and sequential identification. It will be highly effective to explicitly demonstrate what new inferential decisions this formulation enables that conventional coefficient comparisons do not already provide.


**Nested comparisons versus variable substitution**

Proposition 1 is constructed around common observations and regressors, mapping the addition of a candidate control $Z$ to a nested long model. However, the applied workflow introduces a structural divergence from this theorem.

Section 4 discusses moving a variable from the lagged-state set into the contemporaneous set, and Sections 5.1 and 5.2 compare specifications containing $Z_t$, $Z_{t-1}$, or neither. Replacing $Z_{t-1}$ with $Z_t$ constitutes a non-nested change, meaning the resulting coefficient difference is not generally equivalent to $-\widehat{\theta}^{\star} \widehat{\pi}$. The framework could reconcile this divergence by either retaining a justified $Z_{t-1}$ while adding $Z_t$ to preserve nesting, or by formally decomposing replacement comparisons into ordered additions and deletions to account for path dependence.


**Operationalizing the dynamic baseline**

The paper advocates for ADL + FE as a comparison baseline, provided the conditions in Table 3 are met. These conditions demand that the included history and transformations be sufficient for assignment and span the dynamic conditional outcome mean.

Readers will require a defined principle for selecting that history, lag order, or functional form; otherwise, the benchmark remains operationally underdetermined. Under the stated assumptions, a correctly specified linear outcome model identifies the homogeneous coefficient by construction. This setup leaves open the question of why ADL + FE serves as a uniquely privileged baseline rather than one potential implementation of the assumed conditional mean. Furthermore, while $Y_{t-1}$ plays a favorable role in Figure 3, this dynamic is specific to that particular graph and does not universally establish its admissibility. Supplying an operational procedure for history selection or a narrower theorem for explicit graph classes would solidify this baseline.


**Simulation structures and interval coverage**

Section 5 presents extensive numerical findings but relies on references to artifacts like "Task 12" and "Task 13." This presentation leaves the reader without the structural DGP equations, complete parameterizations, stability restrictions, and exact estimator implementations required to independently verify the findings.

Moreover, Figure 5 notes a minimum empirical 95% coverage of 0.700 without a corresponding diagnosis of this interval failure in the main text. To validate the proposed diagnostic and inferential workflow, the simulations must transparently separate causal misspecification, finite-$T$ estimation bias, and the coverage properties of the paired intervals for $\Delta_Z$.


**Alignment between applications and the core estimand**

The theoretical framework is meticulously developed around the contemporaneous treatment effect (CET), defined by the causal clock $D_t \rightarrow Y_t$. The empirical applications diverge from this target.

Both applications in Section 6 focus on non-contemporaneous contrasts: $D_{t-1} \rightarrow Y_t$ in Leipziger (2024) and $D_s \rightarrow Y_{s+1}$ in Rogowski et al. (2022). Additionally, the text classifies the timing in these cases as ambiguous and reports endpoint-SE scale ratios rather than the paired confidence intervals for $\Delta_Z$ introduced in Section 4.1. Showcasing an application that exercises a true CET target with defensible exposure windows, genuinely nested sample-comparable specifications, and paired uncertainty calculations will powerfully anchor the manuscript's core claims.

**Status**: [Pending]

---

## Detailed Comments (12)

### 1. Simulation boundaries rely on undefined artifacts

**Status**: [Pending]

**Quote**:
> The additional existing designs delimit, rather than generalize, this comparison. Table 4 records the main boundaries: each row describes a tested family of DGPs and should not be read as evidence that the conditional baseline is robust or identified outside its stated assumptions. Detailed grids, outcome measures, retained replication counts, and provenance are recorded in the static audit.

Table 4: Boundary conditions represented by existing Monte Carlo artifacts. Each row is a design-specific result, not a general robustness or identification claim. Exact grids and provenance are in the Task 12 audit.

**Feedback**:
Table 4 appears insufficient to assess the reported simulation boundaries: it names broad DGP families but does not provide their equations, parameter grids, or stability and retention rules. The supporting “static audit” and “Task 12 audit” are not formally identified in the document, so it is unclear whether the information needed to interpret and verify these design-specific claims is available as part of the paper’s supporting record.

---

### 2. Applications do not instantiate the CET baseline

**Status**: [Pending]

**Quote**:
> Rogowski et al. (2022) provide the complementary case. Their panel is organized in five-year steps, the outcome is led one panel period, and the postal-stock and GDP measures enter the same regression row. Letting $s$ index the baseline five-year row, the estimated exposure contrast relates the cumulative postal stock $D_{s}$ to forward growth $Y_{s+1}$, where $s+1$ is the next five-year panel step. This application is therefore an audit of a forward exposure contrast, not a direct demonstration of the manuscript's core contemporaneous $D_{t} \rightarrow Y_{t}$ CET. It remains useful for timing and sensitivity because a cumulative stock makes prior exposure explicit and because the coefficient shift reveals how strongly the forward contrast depends on conditioning on baseline GDP.

**Feedback**:
The empirical applications illustrate the descriptive specification-shift diagnostic and timing ambiguity, but neither estimates the Section 5 ADL + FE baseline for a contemporaneous $D_t \rightarrow Y_t$ effect: one studies $D_{t-1} \rightarrow Y_t$, and the other studies $D_s \rightarrow Y_{s+1}$. They therefore do not substantiate the roadmap’s claim that Section 6 shows the diagnostic and CET baseline interacting in published studies; at most, they illustrate why that baseline is inapplicable to these contrasts.

---

### 3. Section 6 omits most of the announced applications

**Status**: [Pending]

**Quote**:
> claimed. GDP's causal role is unresolved: conditional convergence makes it a possible confounder; inherited postal infrastructure may make it a legacy treatment-responsive state or mediator; and both channels could give it a dual role. The large point shift is therefore descriptive until a DAG and evidence on the relevant measurement and exposure windows establish more. The lesson is not "drop GDP." The lesson is that a large specification shift demands explicit causal reasoning about timing and role. This is the use case for a diagnostic paired with a conditional baseline rather than an automatic decision rule.

## 7 Conclusion

**Feedback**:
Section 6 states that the replication outputs cover 14 candidate controls in six studies, but the displayed applications appear to report only five controls from two studies. Because the paper neither identifies these as a selected subset nor accounts for the remaining cases, corpus-wide comparisons—such as the claim that 2.11 is the largest endpoint-SE ratio among the published applications—cannot be verified from the article, and the evidentiary scope of the applications is unclear.

---

### 4. Unit resampling does not cover general TSCS dependence

**Status**: [Pending]

**Quote**:
> Because the short and long coefficients are estimated from the same observations, uncertainty for $\widehat{\Delta}_{Z}=$ $\widehat{\beta}_{L}-\widehat{\beta}_{S}$ must preserve their dependence. Our primary procedure resamples whole units and, on every paired resample, re-estimates the short, long, and auxiliary equations on exactly the same rows. A complementary delta calculation uses

$$
\widehat{\operatorname{Var}}\left(\widehat{\Delta}_{Z}\right)=\widehat{\operatorname{Var}}\left(\widehat{\beta}_{L}\right)+\widehat{\operatorname{Var}}\left(\widehat{\beta}_{S}\right)-2 \widehat{\operatorname{Cov}}\left(\widehat{\beta}_{L}, \widehat{\beta}_{S}\right),
$$

with the cross-estimator covariance obtained from a stacked cluster sandwich. Treating the nested estimates as independent is not justified.

**Feedback**:
The whole-unit paired bootstrap preserves covariance between the short and long estimates and allows within-unit serial dependence, but it requires independent or sufficiently weak dependence across resampled units unless a broader cluster design is used. It does not by itself provide inference under general cross-sectional dependence, and the stacked covariance calculation has the same limitation if clustered only by unit.

---

### 5. CET outcome timing conflicts with the collider clock

**Status**: [Pending]

**Quote**:
> where $Y_{i t}(d)$ is measured after the period- $t$ intervention and any within-period responses it induces. Thus,
unless a controlled direct effect is explicitly targeted, the CET includes paths such as $D_{i t} \rightarrow Z_{i t} \rightarrow Y_{i t}$. In a constant linear model with a scalar treatment, $\beta_{\mathrm{CET}}$ is the corresponding unit contrast, or marginal effect for a continuous dose.

The substantive clock underlying this definition is

$$
H_{i t}^{-} \longrightarrow D_{i t} \longrightarrow Z_{i t} \longrightarrow Y_{i t}^{+},
$$

where $H_{i t}^{-}$is the state at the opening of the causal period, $D_{i t}$ records the onset and intensity of treatment, $Z_{i t}$ is allowed to respond, and $Y_{i t}^{+}$is measured after the relevant exposure window. This ordering is an empirical claim, not a consequence of notation. Table~1 states the minimum timestamp information needed to assess it.

This displayed chain is the candidate clock when $Z_{t}$ is a mediator. It is not imposed on every graph below. A contemporaneous-collider claim $D_{t} \rightarrow Z_{t} \leftarrow Y_{t}$ instead requires the outcome process represented by $Y_{t}$ to precede the measurement of $Z_{t}$ within the causal period, while $D_{t}$ can affect both. Thus the common subscript denotes a panel period, not simultaneity or a universal within-period order; each application must defend the mechanism-specific clock.

**Feedback**:
The CET timing statement is potentially inconsistent with the collider clock: saying that $Y_{it}(d)$ is measured after “any” treatment-induced within-period response appears to place it after $Z_t$, whereas $D_t \rightarrow Z_t \leftarrow Y_t$ requires the outcome process represented by $Y_t$ to precede $Z_t$. These statements are compatible only if “any” is restricted to responses incorporated into the outcome window, or if the earlier outcome process and the subsequently measured outcome are carefully distinguished.

---

### 6. Missing fixed effects in exchangeability assumption

**Status**: [Pending]

**Quote**:
> together with consistency, no interference, no anticipation, sequential mean exchangeability of $D_{i t}$ given $H_{i t}^{-}$, and conditional positivity for the treatment contrast.

**Feedback**:
The exchangeability condition omits $\alpha_i$ and $\tau_t$, although both enter the potential-outcome conditional mean and the fixed-effects projection. As stated, exchangeability given $H_{it}^{-}$ alone does not ensure the within-projection orthogonality needed to identify $\beta_{\mathrm{CET}}$; the identifying restriction must apply to the full conditioning set or directly impose the equivalent orthogonality condition.

---

### 7. Figure 4 leaves collider conditioning untested

**Status**: [Pending]

**Quote**:
> ![](/documents/0cc57960-bcb8-40c6-af38-fad083624f8d/images/image_004.jpg)
Error bars in the bias panel are 95\% Monte Carlo uncertainty intervals for the simulated mean bias (not estimator confidence interval
Figure 4: Dual-role DGP: bias relative to the true contemporaneous treatment effect and RMSE across collider persistence. The DGP has $Z_{t-1}$ as a confounder and $Z_{t}$ as a contemporaneous collider; the estimand is $\beta=1$. The displayed subset sets $\sigma_{\alpha_{Z}}=0.5$, with $N=100, T=30$, a burn-in of 100 periods, and 500 Monte Carlo replications per scenario. Models are TWFE short, TWFE plus $Z_{t-1}$, ADL+FE, and ADL+FE plus $Z_{t-1}$; FE models include unit and time effects. Error bars are 95\% Monte Carlo uncertainty intervals for simulated mean bias, not estimator confidence intervals.

**Feedback**:
Figure 4 does not evaluate conditioning on the contemporaneous collider $Z_t$: all four displayed specifications omit it. The figure can assess omitted dynamics, adjustment for $Z_{t-1}$, and the inherited collider path opened by conditioning on $Z_{t-1}$, but it does not show the included-variable bias caused by conditioning on $D_t \rightarrow Z_t \leftarrow Y_t$.

---

### 8. Figure 5 does not isolate finite-T bias

**Status**: [Pending]

**Quote**:
> Figure 5 isolates finite- $T$ estimation from the specification shift in the pre-specified principal grid. In this dual-role design, absolute Monte Carlo bias is at least as large as the absolute mean $\Delta_{Z}$ in 0 of 54 FE-ADL cells and 6 of 54 split-panel jackknife cells. Across the 108 displayed cells, the maximum absolute bias is 0.0454, the maximum absolute mean shift is 0.0381, and the minimum empirical 95\% coverage is 0.700. These finite-grid comparisons neither establish a universal acceptable- $T$ cutoff nor demonstrate causal robustness. The full estimator comparison, Arellano-Bond diagnostics, stress grid, and exact provenance are reported in the Task 13 report/online appendix.

**Feedback**:
The statement that Figure 5 “isolates” finite-$T$ estimation from the specification shift appears too strong. Since $E[\widehat{\Delta}_Z]$ equals the difference between the endpoint estimators’ Monte Carlo biases, comparing its magnitude with the long estimator’s bias does not itself decompose finite-sample bias from population specification movement. The short and long specifications underlying $\Delta_Z$ also need to be identified for the displayed comparison to have a clear causal interpretation.

---

### 9. A DAG alone does not identify a direct-effect shift

**Status**: [Pending]

**Quote**:
> Two interpretive points matter. First, the formula is diagnostic rather than self-justifying. If $Z$ is a confounder, the same arithmetic difference reflects deconfounding rather than harm. If $Z$ is a mediator, the difference reflects movement from the total to the direct effect (Acharya, Blackwell and Sen, 2016). Only the DAG tells the researcher which interpretation applies. Second, the formula remains useful precisely because it converts a vague modeling dispute into two estimable components: how strongly $Z$ predicts the outcome in the long model, and how strongly $D$ predicts $Z$ once admissible controls have been partialled out.

**Feedback**:
Identifying $Z$ as a mediator in a DAG does not by itself make the long-regression coefficient an identified direct effect. Without the requisite timing, exchangeability, support, and mediation or functional-form assumptions, the shift remains a difference between conditional projections rather than an identified movement from the total to the direct effect.

---

### 10. Timestamp table omits known post-treatment controls

**Status**: [Pending]

**Quote**:
> Table 1: Minimum timestamp record for defining the contemporaneous treatment effect. A lag label is not evidence that a covariate is pretreatment.
| Variable | Minimum timestamp record | Requirement for the CET clock |
| :--- | :--- | :--- |
| $D$ | Onset, end, and intensity window; whether the measure is a stock, flow, event, or period average | Defines the intervention or exposure contrast within period $t$ |
| $Z$ | Reference and measurement window; whether it can respond to anticipated, prior, or current treatment | Must close before the first relevant exposure to be called pretreatment; otherwise classify its timing as plausible or ambiguous |
| $Y$ | Reference window and measurement time; whether any part is recorded before treatment begins | Must follow the relevant exposure window for the stated CET; overlapping aggregates require a finer estimand |


Three complications are common in annual and other aggregated panels. First, anticipation can make a recorded $Z_{t-1}$ treatment-responsive before the formal onset of $D_{t}$.

**Feedback**:
The timestamp rule for $Z$ omits documented post-treatment timing. If nonoverlapping windows establish that $Z$ occurs after exposure begins, its timing is known to be post-treatment rather than merely plausible or ambiguous, although its specific role as mediator, collider, or other descendant still requires a DAG.

---

### 11. Workflow and Section 4.1 leave the diagnostic's nesting unclear

**Status**: [Pending]

**Quote**:
> 3. If those conditions are defended, use ADL + FE with the required lagged state variables as a baseline and state the exact lag order and transformations.
4. Compare that baseline with the specification containing a candidate contemporaneous $Z_{t}$ and report the resulting specification shift $\widehat{\Delta}_{Z}$.
5. Interpret $\widehat{\Delta}_{Z}$ as causal bias only when the DAG, timing, and identifying assumptions establish the CET interpretation; otherwise retain the descriptive specification-shift language.

**Feedback**:
Steps 3–4 do not specify whether the comparison specification adds $Z_t$ while retaining every required lagged state variable, including any required $Z_{t-1}$, or replaces $Z_{t-1}$ with $Z_t$. This ambiguity is reinforced in Section 4.1, where the word "moved" suggests replacing $Z_{i,t-1}$ with $Z_{it}$, which produces non-nested specifications. Only the former is the nested comparison to which the stated identity $\widehat{\Delta}_Z=-\widehat{\theta}\widehat{\pi}$ directly applies, as the one-product identity applies only when the contemporaneous variable is added while the remaining regressors are held fixed; a replacement comparison combines multiple specification changes, and their coefficient difference is generally a combination of two nested FWL shifts, not a single $-\widehat{\theta}\widehat{\pi}$ term.

---

### 12. Table 6 does not separate the mixed-design targets

**Status**: [Pending]

**Quote**:
> Table 6: Over-control simulations for the CET. In both the pure-mediator and mediator-plus-confounder designs, the displayed ADL specification with contemporaneous $Z_{t}$ produces a coefficient near the directeffect target, whereas the displayed specification with $Z_{t-1}$ produces a coefficient near the total-effect target. These are design-specific comparisons.
| Scenario | Target total | Target direct | ADL, no $Z$ | $\mathrm{ADL}+Z_{t}$ | $\mathrm{ADL}+Z_{t-1}$ |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Pure mediator, $\rho_{Z}=0.3$ | 1.20 | 1 | 1.201 | 0.998 | 1.199 |
| Pure mediator, $\rho_{Z}=0.7$ | 1.20 | 1 | 1.199 | 0.992 | 1.197 |
| Mediator + confounder, $\rho_{Z}=0.5$ | 1.03 | 1 | 1.091 | 1.023 | 1.031 |
| Mediator + confounder, $\rho_{Z}=0.7$ | 1.03 | 1 | 1.111 | 1.016 | 1.028 |

**Feedback**:
Table 6’s mediator-plus-confounder rows appear to support only the claim that conditioning on $Z_t$ moves the estimates toward the direct-effect target, not that it produces estimates distinctly near that target. The estimates 1.023 and 1.016 are numerically closer to the total-effect target of 1.03 than to the direct-effect target of 1.00. Without Monte Carlo uncertainty intervals, the stronger proximity characterization is not established.

---
