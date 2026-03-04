# Systematic Literature Review: Collider Bias from Lagged Controls in TSCS/Panel Regressions

**Date**: 2026-03-03
**Question**: Has anyone articulated the specific problem that including a lagged control variable Z_{t-1} in a TSCS/panel regression, when Z is caused by both treatment D and outcome Y (creating the collider structure D_{t-1} -> Z_{t-1} <- Y_{t-1}), opens a collider path that biases the contemporaneous treatment effect (CET)?

## Executive Summary

After a systematic review of literature across political science methodology, epidemiology/biostatistics, econometrics, and statistics/causal inference, I find that **no prior paper has articulated this specific claim in the form presented by the IVB paper**. The key novelty lies in the *combination* of five elements:

1. Identifying lagged *control variables* (not lagged dependent variables) as colliders in TSCS
2. Focusing on bias to the *contemporaneous* treatment effect specifically
3. Providing a closed-form *quantification formula* (IVB = -theta* x pi) using estimable quantities
4. Extending the result from cross-sectional DAGs to ADL/TWFE specifications
5. Showing structurally why the bias tends to be small in typical panel applications

Individual pieces of this argument exist scattered across multiple literatures, but nobody has assembled them into this specific claim with an operational formula. Below I detail what each relevant literature contributes and where the gaps are.

---

## 1. Political Science Methodology

### 1.1. Blackwell & Glynn (2018) APSR — "How to Make Causal Inferences with TSCS Data"

**What they identify**: Post-treatment bias for *lagged* treatment effects when conditioning on time-varying confounders Z_t. Their central trade-off: you must condition on Z_t to remove confounding for the contemporaneous effect of D_t, but conditioning on Z_t introduces post-treatment bias for the lagged effect of D_{t-1}, because Z_t is post-treatment relative to D_{t-1}.

**Estimand**: Both contemporaneous and lagged effects, but the bias discussion focuses on *lagged* effects.

**Lagged controls as colliders?**: They do NOT use the term "collider" or draw the specific DAG structure D_{t-1} -> Z_{t-1} <- Y_{t-1}. Their framing is "post-treatment bias," not "collider bias." They frame the problem as Z_t being post-treatment to D_{t-1}, not as Z_{t-1} being a collider created by D_{t-1} and Y_{t-1}.

**Quantification formula?**: No closed-form formula for the magnitude of the bias. They propose MSM/IPTW and SNMM as solutions rather than quantifying the bias.

**Proposed solution**: Inverse probability weighting (marginal structural models) and structural nested mean models (g-estimation).

**Gap relative to IVB paper**: Blackwell & Glynn (i) focus on lagged effects rather than CET, (ii) do not provide a quantification formula, (iii) do not use the collider framing, and (iv) do not discuss conditions under which the bias is small enough to tolerate. The IVB paper's "bridge" contribution is precisely to show that BG's post-treatment bias IS collider bias IS IVB, and to quantify it.

### 1.2. Imai & Kim (2019 AJPS, 2021 Political Analysis) — Unit and Two-Way Fixed Effects

**What they identify**: Strict exogeneity violations in TWFE. The key insight is that TWFE is *not identified* when there is dynamic causal feedback (past outcomes affecting current treatment, or past treatment affecting current outcomes beyond the contemporaneous effect). They show this is a permanent bias, not vanishing with T.

**Estimand**: Weighted average of contemporaneous treatment effects.

**Lagged controls as colliders?**: Not discussed. Their framework is about the assumptions needed for FE identification, not about specific control variable choices creating collider paths. They discuss ADL as a parametric solution (Table 1) but do not frame the inclusion of lagged controls through a DAG lens.

**Quantification formula?**: No formula for collider bias. They provide matching-based estimators as alternatives to parametric models.

**Gap**: Imai & Kim's argument is about identification under dynamic causal relationships, not about the specific mechanism of collider bias from included lagged controls. The IVB paper reinterprets the strict exogeneity violation as the same phenomenon seen from a different angle.

### 1.3. Montgomery, Nyhan & Torres (2018) AJPS — "How Conditioning on Posttreatment Variables Can Ruin Your Experiment"

**What they identify**: Post-treatment bias in *experimental* settings from conditioning on variables affected by treatment. Uses DAGs to show collider structures.

**Estimand**: Treatment effects in experiments (cross-sectional).

**Lagged controls as colliders?**: No. The paper is about experiments, not panel/TSCS data. No temporal structure.

**Quantification formula?**: No.

**Gap**: Cross-sectional only. Does not extend to TSCS/panel settings or provide quantification.

### 1.4. De Boef & Keele (2008) AJPS — "Taking Time Seriously"

**What they identify**: The importance of correctly specifying dynamics (ECM/ADL models) in time series analysis. They focus on lag structure specification, long-run vs. short-run effects.

**Lagged controls as colliders?**: Not discussed. The paper is about specifying dynamic models correctly, not about collider bias from control variable selection.

**Gap**: No causal inference framework. Purely about model specification.

### 1.5. Beck & Katz (2011) Annual Review — "Modeling Dynamics in TSCS"

**What they identify**: The equivalence of different dynamic model specifications (LDV, ECM, ADL) and the role of speed of adjustment. Shows that FE with LDV performs well for typical TSCS data.

**Lagged controls as colliders?**: Not discussed. No DAG framework.

**Gap**: No causal inference framework applied to control variable selection.

### 1.6. Liu, Wang & Xu (2024) AJPS — "Practical Guide to Counterfactual Estimators for TSCS"

**What they identify**: Counterfactual imputation methods (IFE, matrix completion) as alternatives to TWFE for estimating ATT in panel data.

**Lagged controls as colliders?**: Not discussed. Focus is on treatment effect estimation without covariates, or with pre-treatment covariates only.

**Gap**: Does not address control variable selection or collider bias.

### 1.7. Acharya, Blackwell & Sen (2016) APSR — "Explaining Causal Findings Without Bias"

**What they identify**: Post-treatment bias from conditioning on mediators when trying to estimate controlled direct effects. Proposes sequential g-estimation for causal mediation.

**Estimand**: Controlled direct effects.

**Lagged controls as colliders?**: Not in a TSCS context. Focus is on mediation in cross-sectional or experimental settings.

**Quantification formula?**: Sequential g-estimation approach, but not a simple bias formula.

**Gap**: Cross-sectional mediation, not TSCS collider bias.

---

## 2. Epidemiology / Biostatistics

### 2.1. Robins (1986, 1997) — G-methods

**What they identify**: The fundamental problem of treatment-confounder feedback in longitudinal studies. Standard regression cannot simultaneously adjust for time-varying confounders and avoid collider-stratification bias. Introduced g-computation, MSM/IPTW, and SNMM/g-estimation.

**Estimand**: Causal effects of time-varying treatments.

**Lagged controls as colliders?**: Robins' work is the *origin* of the insight that a time-varying confounder affected by prior treatment creates a "collider-like" problem. However, his framing is "treatment-confounder feedback" — the variable is simultaneously a confounder for future treatment and a post-treatment variable for past treatment. He does NOT specifically isolate the case of a lagged control variable Z_{t-1} being a collider with respect to D_{t-1} and Y_{t-1} biasing the CET.

**Quantification formula?**: No simple closed-form formula. The g-methods provide *estimators* that avoid the bias, rather than *quantifying* the bias from standard regression.

**Gap**: Robins' framework is general and nonparametric. It identifies the *existence* of the problem but does not provide an estimable bias formula, does not focus on the CET specifically, and does not characterize when the bias is small enough to tolerate standard regression.

### 2.2. Daniel, Cousens, De Stavola, Kenward & Sterne (2013) Statistics in Medicine — "Methods for Dealing with Time-Dependent Confounding"

**What they identify**: A tutorial covering g-computation, IPTW/MSM, and g-estimation as solutions to time-dependent confounding with treatment-confounder feedback. Clearly explains how standard adjustment induces collider-stratification bias.

**Lagged controls as colliders?**: Yes, implicitly. The paper explains that conditioning on a time-varying confounder affected by prior treatment induces "collider-stratification bias." But this is framed as a general problem of longitudinal causal inference, not specific to TSCS/panel settings with FE.

**Quantification formula?**: No. Tutorial focuses on implementation of g-methods.

**Gap**: General longitudinal setting. No FE/TWFE context, no ADL extension, no bias quantification formula, no characterization of when standard regression is adequate.

### 2.3. Hernan & Robins (2020) — "Causal Inference: What If" Textbook

**What they identify**: Part III covers time-varying treatments with treatment-confounder feedback. Chapters on g-formula, IP weighting, and g-estimation. Clearly explains that standard regression conditioning on time-varying confounders affected by prior treatment creates collider-stratification bias.

**Lagged controls as colliders?**: The textbook explains the general mechanism but does not isolate the specific case of lagged controls in TSCS panel models with FE. The focus is on the general longitudinal causal inference framework.

**Quantification formula?**: No simple bias formula. The approach is to use g-methods to avoid the bias entirely.

**Gap**: Same as Robins' work generally — identifies the existence of the problem but does not quantify it or characterize when it is negligible.

### 2.4. Greenland (2003) Epidemiology — "Quantifying Biases in Causal Models"

**What they identify**: Compares the magnitude of classical confounding bias vs. collider-stratification bias in simple causal models. Shows that collider-stratification bias "may often be comparable in size with bias from classical confounding."

**Estimand**: Cross-sectional treatment effects.

**Lagged controls as colliders?**: No. Purely cross-sectional.

**Quantification formula?**: Yes, but parameterized in structural LSEM coefficients (unobserved), not in estimable regression coefficients. The formulas are for specific DAG structures, not general.

**Gap**: Cross-sectional only. Not expressed in terms of estimable quantities. Not extended to panel/TSCS.

### 2.5. Loh & Ren (2023) — "G-Estimation Tutorial"

**What they identify**: A tutorial on g-estimation for time-varying confounding in longitudinal data. Clearly explains collider-stratification bias from adjusting for intermediate confounders.

**Gap**: Tutorial for implementing g-estimation in psychology. No bias formula, no TSCS/FE context.

### 2.6. Wodtke (2020) — "Regression-Based Adjustment for Time-Varying Confounders"

**What they identify**: The "regression-with-residuals" method as a way to handle treatment-induced confounders. Explains that conditioning on a time-varying confounder affected by treatment induces collider-stratification bias.

**Quantification formula?**: No closed-form bias formula. Proposes a modified regression approach.

**Gap**: Focused on proposing a solution (regression with residuals), not on quantifying the bias from standard regression.

### 2.7. Penning de Vries & Groenwold (2022) — "Bias from Time-Varying Covariate Measurement"

**What they identify**: "Butterfly bias" — where a measured covariate is simultaneously a confounder on one path and a collider on another. Explores how measurement timing affects bias direction.

**Gap**: About measurement timing and differential misclassification, not about lagged controls in TSCS per se.

---

## 3. Econometrics

### 3.1. Angrist & Pischke (2009) — "Mostly Harmless Econometrics"

**What they identify**: "Bad controls" — variables that are themselves outcomes of the treatment. Discussion at pp. 64-68. They distinguish between "bad controls" (post-treatment) and "proxy controls."

**Lagged controls as colliders?**: Not specifically. The discussion is primarily cross-sectional. They do not draw temporal DAGs or discuss lagged controls in panel settings.

**Quantification formula?**: No.

**Gap**: Brief, cross-sectional treatment. No extension to panel/TSCS, no quantification.

### 3.2. Klosin (2024) — "Dynamic Biases of Static Panel Data Estimators"

**What they identify**: "Dynamic bias" — the bias from omitting lagged outcomes in FE estimation. When past Y affects current Y but the model omits Y_{t-1}, the estimation of FE generates confounding. This bias can be larger than Nickell bias.

**Estimand**: Contemporaneous treatment effect in panel FE models.

**Lagged controls as colliders?**: No. Klosin's mechanism is about *omitting* the lagged outcome, not about *including* a lagged control that is a collider. The bias comes from the FE transformation creating correlation between the error and regressors when dynamics are ignored.

**Quantification formula?**: Yes — Klosin provides bias formulas for the dynamic bias, but these are about omission of lagged Y, not inclusion of collider Z.

**Gap**: Different mechanism entirely. Klosin addresses omitted variable bias from ignoring dynamics, not included variable bias from collider conditioning. However, the work is relevant because it shows another source of bias in static panel models.

### 3.3. Millimet & Bellemare (2023/2025) — "Fixed Effects and Causal Inference" / "On the (Mis)Use of the Fixed Effects Estimator"

**What they identify**: That the set of time-invariant attributes shrinks as T grows, making the strict exogeneity assumption harder to satisfy. FE may not solve confounding for long panels.

**Lagged controls as colliders?**: Not discussed. Focus is on the FE assumptions, not on control variable selection.

**Gap**: Different focus (FE identification assumptions vs. control variable selection).

### 3.4. Jung, Corbett-Davies, Gaebler, Shroff & Goel (2024) — "Mitigating Included- and Omitted-Variable Bias"

**What they identify**: The term "included variable bias" in the context of disparate impact estimation. IVB arises when including irrelevant covariates biases treatment effect estimates.

**Lagged controls as colliders?**: No. Cross-sectional application (police stops).

**Quantification formula?**: Not a simple bias formula in our sense. They develop sensitivity analysis methods.

**Gap**: Uses the same term "included variable bias" but in a different context (disparate impact, cross-sectional). No TSCS, no collider DAG structure, no FWL-based formula.

---

## 4. Statistics / Causal Inference

### 4.1. Pearl (2009) — "Causality" (Textbook)

**What they identify**: The general theory of collider bias via d-separation in DAGs. Conditioning on a collider opens a spurious path between its parents.

**Lagged controls as colliders?**: Not specifically in a temporal/panel setting. Pearl's DAGs are typically presented in cross-sectional form. While the theory generalizes to temporal DAGs, Pearl does not specifically discuss the TSCS case of lagged controls as colliders.

**Quantification formula?**: Pearl (2013) provides path-analytic expressions for linear models, but parameterized in structural coefficients, not estimable regression coefficients.

**Gap**: General theory. Not applied to TSCS/panel settings. No estimable formula.

### 4.2. Elwert & Winship (2014) Annual Review of Sociology — "Endogenous Selection Bias"

**What they identify**: A comprehensive taxonomy of endogenous selection bias from conditioning on colliders. Uses DAGs to show multiple scenarios: conditioning on outcome, post-outcome variable, post-treatment variable, and even pre-treatment colliders.

**Lagged controls as colliders?**: Not in a temporal panel setting. The examples are cross-sectional.

**Quantification formula?**: No. The contribution is qualitative (DAG-based diagnosis), not quantitative.

**Gap**: Does not extend to TSCS settings, no temporal DAGs, no quantification.

### 4.3. Cinelli, Forney & Pearl (2022) SMR — "A Crash Course in Good and Bad Controls"

**What they identify**: A comprehensive catalogue of 18 control variable configurations, classifying each as good, bad, or neutral. Cases include colliders, mediators, M-bias structures, etc.

**Lagged controls as colliders?**: NOT discussed. The paper explicitly operates in a cross-sectional framework. It does not address temporal/longitudinal structures, panel data, or lagged variables. The paper provides no guidance for TSCS settings.

**Quantification formula?**: No. The contribution is a qualitative classification system.

**Gap**: A major gap. The paper is highly influential for control variable selection, but entirely cross-sectional. Practitioners must independently extend the logic to temporal contexts — and the IVB paper does precisely this.

### 4.4. Ding & Miratrix (2015) — "To Adjust or Not to Adjust? M-Bias"

**What they identify**: M-bias (from conditioning on a pre-treatment collider) tends to be small relative to confounding bias. The M-bias is a product of four structural coefficients and is typically higher-order.

**Lagged controls as colliders?**: No. Cross-sectional M-structure.

**Quantification formula?**: Yes — formulas for M-bias magnitude in LSEMs, but parameterized in unobserved structural coefficients. Not directly estimable from data.

**Gap**: Cross-sectional, and the formula requires knowledge of structural parameters, unlike IVB = -theta* x pi which uses estimable quantities.

### 4.5. Rosenbaum (1984) — "Consequences of Adjustment for a Concomitant Variable Affected by Treatment"

**What they identify**: The seminal result that adjusting for a post-treatment variable generally biases treatment effect estimates. Decomposes the bias into two components.

**Lagged controls as colliders?**: No. The framework is general (not temporal/panel specific) and does not use DAG language.

**Quantification formula?**: A general bias decomposition, but not in the specific FWL form of IVB = -theta* x pi.

**Gap**: Foundational but general. Not specific to TSCS, not in DAG language, not providing an easily estimable formula.

### 4.6. Schneider (2020) — "Collider Bias in Economic History Research"

**What they identify**: Collider bias as a unifying framework for understanding various biases in economic history (sample selection, attrition, truncation). Uses Pearl's DAG framework.

**Lagged controls as colliders?**: Partially. The paper discusses collider bias in longitudinal/historical settings, including attrition as a collider. But it focuses on sample selection colliders, not on included lagged control variables as colliders in regression.

**Quantification formula?**: No.

**Gap**: Addresses collider bias in historical research but not the specific mechanism of lagged controls biasing the CET.

### 4.7. Loh & Ren (2023, Collabra: Psychology) — "The Unfulfilled Promise of Longitudinal Designs"

**What they identify**: That adjusting for previous measurements in longitudinal studies can induce "butterfly bias" — where a covariate is simultaneously a non-collider on one non-causal path and a collider on another. This is the closest conceptual match to the IVB paper's "dual-role Z" concept.

**Lagged controls as colliders?**: YES, implicitly. The paper discusses how a lagged covariate can be a confounder on one path and a collider on another, creating a bias trade-off. However:
- The focus is on psychology (cross-lagged panel models with 2-3 waves)
- They do not provide a quantification formula
- They do not discuss TSCS/FE/ADL settings
- They do not isolate the CET as the estimand
- They recommend g-methods rather than characterizing when standard regression suffices

**Quantification formula?**: No. They recommend researchers use g-methods.

**Gap**: Closest to the IVB paper's insight about "dual-role Z" but without (i) the TSCS/FE context, (ii) the quantification formula, (iii) the characterization of when IVB is small enough to tolerate, (iv) the ADL extension.

### 4.8. Frake, Hagemann & Uribe (2024) SMJ — "Collider Bias in Strategy and Management Research"

**What they identify**: Collider bias in management research, illustrated with an example of women CEOs' effects on other women's careers.

**Lagged controls as colliders?**: Uses panel data but focuses on sample selection/compositional colliders, not lagged control variables creating collider structures.

**Gap**: Panel data application but different mechanism (sample composition, not lagged controls).

---

## 5. The Closest Predecessors and Remaining Gaps

### 5.1. What IS known before the IVB paper

| Concept | Known by | Source |
|---|---|---|
| Collider bias in cross-sectional settings | Pearl (2009), Elwert & Winship (2014) | DAG theory |
| Post-treatment bias from conditioning on variables affected by treatment | Rosenbaum (1984), Montgomery et al. (2018) | Experimental design |
| Treatment-confounder feedback in longitudinal data | Robins (1986, 1997), Daniel et al. (2013) | Epidemiology |
| The trade-off: conditioning needed for CET but creates bias for lagged effects | Blackwell & Glynn (2018) | TSCS methodology |
| Strict exogeneity violations in TWFE with dynamics | Imai & Kim (2019, 2021) | Panel causal inference |
| ADL as parametric solution with O(1/T) residual bias | Imai & Kim (2019), Beck & Katz (2011) | Panel econometrics |
| Dynamic bias from omitting lagged outcomes | Klosin (2024) | Panel econometrics |
| "Butterfly bias" from covariate that is simultaneously confounder and collider | Loh & Ren (2023, Collabra) | Longitudinal psychology |
| Quantification of M-bias in structural parameters | Ding & Miratrix (2015) | Causal inference theory |
| Collider-stratification bias magnitude in structural parameters | Greenland (2003) | Epidemiology |
| "Included variable bias" as a term (in disparate impact) | Jung et al. (2024 PNAS) | Statistics |
| Bad controls as post-treatment variables | Angrist & Pischke (2009), Cinelli et al. (2022) | Econometrics/Stats |

### 5.2. What is NOT known before the IVB paper

| Novel Contribution | What specifically is new |
|---|---|
| **Lagged controls as colliders for the CET** | No prior paper draws the specific DAG where Z_{t-1} is a collider of D_{t-1} and Y_{t-1} and shows this biases the CET in a TSCS regression. Blackwell & Glynn focus on lagged effects; Robins/Daniel on general longitudinal g-methods; Pearl/Elwert/Cinelli on cross-sectional DAGs. |
| **Estimable quantification formula** | IVB = -theta* x pi uses regression coefficients the researcher already has. Prior formulas (Greenland 2003, Ding & Miratrix 2015, Pearl 2013) are parameterized in structural/unobserved coefficients. |
| **Extension to ADL/TWFE** | No prior paper derives the collider bias formula for ADL models with FE, showing the FWL decomposition carries through. |
| **"Foreign collider bias" concept** | The specific mechanism where lagging a control creates a *new* collider structure absent in the contemporaneous DAG has not been named or formalized. |
| **Structural conditions for small IVB** | No prior paper characterizes the conditions (FE absorbing between-unit variation, few switchers, bounded nonlinearity, moderate feedback) under which the collider bias from lagged controls is negligible. |
| **Bridge across three literatures** | No prior paper explicitly unifies IVB (FWL), post-treatment bias (Blackwell & Glynn), and strict exogeneity violation (Imai & Kim) as three perspectives on the same mechanism. |
| **Practical diagnostic** | No prior paper provides researchers with an immediately computable diagnostic (estimate theta* and pi from your data) to decide whether a specific control variable creates worrisome collider bias. |

---

## 6. Specific Search Terms — Results

| Search terms | Result |
|---|---|
| "collider bias" AND "panel data" / "longitudinal" / "TSCS" | Found: Schneider (2020) for economic history; Frake et al. (2024) for management; general epidemiology tutorials. None specific to lagged controls biasing CET. |
| "included variable bias" AND "panel" / "time series" | Found: Jung et al. (2024) in disparate impact context. No panel/TSCS application. |
| "post-treatment bias" AND "contemporaneous effect" | Found: Blackwell & Glynn (2018) discusses the trade-off but focuses on bias to *lagged* effects, not CET. |
| "time-varying collider" | Very few hits. General epidemiology discussion of time-varying confounders creating collider structures when conditioned on. No TSCS-specific results. |
| "lagged control" AND "collider" | Minimal results. Some general discussion of lagged dependent variables as colliders (Allison 2022, Loh & Ren 2023) but not lagged *control variables* specifically. |
| "bad control" AND "panel data" | Found: Cinelli et al. (2022) catalogue is cross-sectional; Angrist & Pischke (2009) brief mention. No TSCS-specific application. |
| "conditioning on descendant" AND "longitudinal" | Found: General epidemiology results about descendants of colliders. No TSCS-specific results. |

---

## 7. Assessment of Novelty

### The specific claim IS novel

The claim that **lagged controls can be colliders biasing the CET in TSCS** has NOT been made before in this specific form. The closest predecessors are:

1. **Blackwell & Glynn (2018)**: Identify the trade-off (condition for CET vs. bias for lagged effects) but focus on the *lagged effect* bias, not the CET bias from the collider path. Their solution (MSM/SNMM) avoids the problem entirely rather than quantifying it.

2. **Robins (1986, 1997) and the epidemiology literature**: Identify treatment-confounder feedback as a general problem but do not isolate the TSCS case, do not provide an estimable bias formula, and do not characterize when the bias is small.

3. **Loh & Ren (2023, Collabra)**: Come closest to the "dual-role Z" insight (simultaneously confounder and collider) but in a psychology/SEM context without FE, without a formula, and without the TSCS application.

4. **Cinelli, Forney & Pearl (2022)**: Provide the most comprehensive catalogue of good/bad controls but entirely cross-sectional — the temporal extension is the gap the IVB paper fills.

### What makes the IVB contribution distinctive

The IVB paper's contribution is best described as a **synthesis + extension + quantification**:

- **Synthesis**: Unifying insights from Pearl (collider bias), Blackwell & Glynn (post-treatment bias in TSCS), and Imai & Kim (strict exogeneity in FE) as three views of the same mechanism.
- **Extension**: Taking cross-sectional collider theory (Pearl, Cinelli) and extending it to the ADL/FE specifications that are the workhorse of TSCS analysis.
- **Quantification**: Providing an estimable formula (IVB = -theta* x pi) that lets researchers compute the bias magnitude from their own data, analogous to how the OVB formula lets researchers assess omission bias.

The formula itself is "mechanically simple" (FWL identity), but its *application* to the collider problem in TSCS, its connection to the three literatures, and the characterization of when it is small represent genuine novelty.

---

## 8. Key References (Organized by Relevance)

### Tier 1: Most directly relevant (must cite and position against)

- Blackwell, M., & Glynn, A. N. (2018). How to Make Causal Inferences with Time-Series Cross-Sectional Data under Selection on Observables. *APSR*, 112(4), 1067-1082.
- Imai, K., & Kim, I. S. (2019). When Should We Use Unit Fixed Effects Regression Models for Causal Inference with Longitudinal Data? *AJPS*, 63(2), 467-490.
- Imai, K., & Kim, I. S. (2021). On the Use of Two-Way Fixed Effects Regression Models for Causal Inference with Panel Data. *Political Analysis*, 29(3), 405-415.
- Cinelli, C., Forney, A., & Pearl, J. (2022). A Crash Course in Good and Bad Controls. *Sociological Methods & Research*, 53(3), 1071-1104.
- Robins, J. M. (1986). A New Approach to Causal Inference in Mortality Studies. *Mathematical Modelling*, 7, 1393-1512.

### Tier 2: Important conceptual foundations

- Pearl, J. (2009). *Causality: Models, Reasoning, and Inference* (2nd ed.). Cambridge University Press.
- Elwert, F., & Winship, C. (2014). Endogenous Selection Bias. *Annual Review of Sociology*, 40, 31-53.
- Rosenbaum, P. R. (1984). The Consequences of Adjustment for a Concomitant Variable that Has Been Affected by the Treatment. *JRSS-A*, 147(5), 656-666.
- Daniel, R. M., et al. (2013). Methods for Dealing with Time-Dependent Confounding. *Statistics in Medicine*, 32(9), 1584-1618.
- Hernan, M. A., & Robins, J. M. (2020). *Causal Inference: What If*. Chapman & Hall/CRC.
- Montgomery, J. M., Nyhan, B., & Torres, M. (2018). How Conditioning on Posttreatment Variables Can Ruin Your Experiment. *AJPS*, 62(3), 760-775.

### Tier 3: Quantification and adjacent results

- Greenland, S. (2003). Quantifying Biases in Causal Models: Classical Confounding vs. Collider-Stratification Bias. *Epidemiology*, 14(3), 300-306.
- Ding, P., & Miratrix, L. W. (2015). To Adjust or Not to Adjust? Sensitivity Analysis of M-Bias. *Journal of Causal Inference*, 3(1), 41-57.
- Jung, J., Corbett-Davies, S., Gaebler, J. D., Shroff, R., & Goel, S. (2024). Mitigating Included- and Omitted-Variable Bias. *PNAS*.
- Klosin, S. (2024). Dynamic Biases of Static Panel Data Estimators. Working paper (MIT).
- Wodtke, G. T. (2020). Regression-Based Adjustment for Time-Varying Confounders. *Sociological Methods & Research*, 49(4), 1069-1101.

### Tier 4: Context and broader literature

- Angrist, J. D., & Pischke, J.-S. (2009). *Mostly Harmless Econometrics*. Princeton University Press.
- Beck, N., & Katz, J. N. (2011). Modeling Dynamics in Time-Series-Cross-Section Political Economy Data. *Annual Review of Political Science*, 14, 331-352.
- De Boef, S., & Keele, L. (2008). Taking Time Seriously. *AJPS*, 52(1), 184-200.
- Acharya, A., Blackwell, M., & Sen, M. (2016). Explaining Causal Findings Without Bias. *APSR*, 110(3), 512-529.
- Schneider, E. B. (2020). Collider Bias in Economic History Research. *Explorations in Economic History*, 78, 101356.
- Loh, W. W., & Ren, D. (2023). The Unfulfilled Promise of Longitudinal Designs for Causal Inference. *Collabra: Psychology*, 9(1), 89142.
- Millimet, D. L., & Bellemare, M. F. (2025). On the (Mis)Use of the Fixed Effects Estimator. *Oxford Bulletin of Economics and Statistics*.
- Frake, J., Hagemann, A., & Uribe, J. (2024). Collider Bias in Strategy and Management Research. *Strategic Management Journal*.
- Vansteelandt, S., & Sjolander, A. (2016). Revisiting g-estimation. *Epidemiologic Methods*, 5(1), 37-56.
- Liu, L., Wang, Y., & Xu, Y. (2024). A Practical Guide to Counterfactual Estimators for Causal Inference with TSCS Data. *AJPS*.
- Homola, J., Pereira, M. M., & Tavits, M. (2024). Fixed Effects and Post-Treatment Bias in Legacy Studies. *APSR*.

---

## 9. Conclusion

The systematic review confirms that the IVB paper fills a genuine gap at the intersection of four literatures. The specific claim — that lagged controls in TSCS regressions create collider structures that bias the contemporaneous treatment effect, quantifiable via IVB = -theta* x pi — has not been made before. The individual ingredients exist:

- **Pearl/Elwert/Cinelli**: Collider theory (cross-sectional)
- **Robins/Daniel/Hernan**: Treatment-confounder feedback (general longitudinal)
- **Blackwell & Glynn**: Post-treatment bias in TSCS (focused on lagged effects)
- **Imai & Kim**: Strict exogeneity violations (FE identification)
- **Greenland/Ding**: Collider bias magnitude (structural parameters)

But nobody has (i) drawn the specific temporal DAG for lagged controls as colliders in TSCS, (ii) derived an estimable bias formula, (iii) extended it to ADL/FE, (iv) characterized when it is small, and (v) applied it as a practical diagnostic. This combination constitutes the paper's novelty.
