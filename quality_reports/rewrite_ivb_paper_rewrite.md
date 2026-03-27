# Rewritten Introduction: Dual-Role Controls in Dynamic Panels

**Original file**: `ivb_paper_rewrite.Rmd`
**Date**: 2026-03-27 (v3)

---

# Introduction

Should a time-varying covariate be included in a panel regression? Consider a scholar estimating the effect of UN peacekeeping on democratization. Conflict intensity predicts both the deployment of peacekeeping missions and the prospects for democratic transition, so omitting it risks confounding bias. But peacekeeping can itself reduce violence, making realized conflict a consequence of treatment. Including it opens a different source of bias. The researcher must choose: omit the covariate and risk omitted variable bias, or include it and risk what we call included variable bias.

This is not a special case. GDP, trade flows, foreign aid, inflation, and dozens of other variables evolve alongside treatment and outcome in panel data. Researchers routinely decide whether to condition on them, and the decision can move the point estimate. The Omitted Variable Bias formula gives researchers a way to assess the cost of excluding a confounder. No analogous tool exists for the cost of including a covariate that may be post-treatment, a collider, or a mediator. We provide one.

We introduce the Included Variable Bias (IVB) formula:
\begin{equation}
\text{IVB} = -\theta^{\star} \times \pi
\end{equation}
where $\theta^{\star}$ is the coefficient on the covariate in the augmented regression and $\pi$ is the coefficient on the treatment in an auxiliary regression of the covariate on the treatment and legitimate controls. Both quantities come from regressions the researcher has already run. Where OVB measures the cost of leaving a variable out, IVB measures the change from putting one in. Combined with a causal graph, the formula tells the researcher whether the change represents collider bias, confounding removal, or over-control of a mediator, and how large it is. We derive the formula for two-way fixed effects, autoregressive distributed lag, and difference-in-differences specifications with time-varying covariates.

A growing literature on difference-in-differences, synthetic control, and synthetic difference-in-differences recognizes that parallel trends often hold only conditionally on covariates. When a covariate needed for identification may also respond to treatment, the dual-role dilemma reappears in a setting where no diagnostic exists. Estimators that construct counterfactuals using adaptive weights compound the problem: including a covariate changes which units and periods form the comparison group, not just the regression coefficients. We extend IVB to this class of estimators by decomposing the total sensitivity into a Coefficient Effect, which preserves the product structure of the formula above, and a Reweighting Effect, which captures weight distortion from covariate inclusion.

We apply the diagnostic to [NUMBER] published studies in [FIELDS], identify covariates with plausible dual roles, and assess whether the specification choice is consequential. The applications show when IVB is small enough to ignore and when the decomposition reveals offsetting forces invisible from comparing point estimates alone.

Section~\ref{sec:ivb} derives the IVB formula and discusses dual-role covariates in dynamic settings. Section~\ref{sec:sdid} extends the decomposition to estimators with adaptive weights. Section~\ref{sec:applications} applies the diagnostic to published studies. Section~\ref{sec:conclusion} concludes.
