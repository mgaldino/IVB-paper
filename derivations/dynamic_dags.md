---
title: "Dynamic DAGs for the Contemporaneous Treatment Effect"
author: "Technical note for the IVB paper"
date: "July 11, 2026"
output:
  pdf_document:
    latex_engine: pdflatex
    number_sections: true
geometry: margin=1in
fontsize: 11pt
---

# Purpose and conventions

This note documents the three time-indexed causal DAGs embedded as reproducible TikZ in `ivb_paper_pa.Rmd`. Their target is the contemporaneous treatment effect (CET),

\[
\tau_{\mathrm{CET}}(d,d';h)
=
\mathbb{E}[Y_t(d)-Y_t(d')\mid H_t^-=h],
\]

where the opening history $H_t^-$ is fixed before the first exposure represented by $D_t$, and $Y_t$ is measured after the relevant within-period responses. Unless a controlled direct effect is stated, the target is the total CET. The Task 03 sequence $H_t^-\rightarrow D_t\rightarrow Z_t\rightarrow Y_t$ is the candidate clock for the mediator mechanism, not a universal order. The required collider $D_t\rightarrow Z_t\leftarrow Y_t$ instead places the outcome process represented by $Y_t$ before the measurement of $Z_t$ within the period. The lagged variables shown in a graph belong to $H_t^-$ only if their substantive timestamps pass the Task 03 checklist. The graphs do not assert that a calendar lag is automatically pretreatment, that the displayed history is sufficient, or that a within estimator is unbiased at finite $T$.

A path is evaluated using the usual d-separation rules. An unconditioned noncollider transmits association; conditioning on a noncollider blocks the path. An unconditioned collider blocks a path; conditioning on that collider or one of its descendants opens the path. These path statements concern the displayed DAG and do not rule out omitted common causes, interference, simultaneity, misspecified lag order, or treatment-effect heterogeneity.

# Graph 1: contemporaneous collider with an inherited lag path

## Edges and target

The graph contains the causal edges $D_{t-1}\rightarrow Y_{t-1}$ and $D_t\rightarrow Y_t$, the contemporaneous collider $D_t\rightarrow Z_t\leftarrow Y_t$, persistence $D_{t-1}\rightarrow D_t$, $Y_{t-1}\rightarrow Y_t$, and $Z_{t-1}\rightarrow Z_t$, and the lagged collider $D_{t-1}\rightarrow Z_{t-1}\leftarrow Y_{t-1}$. The target is the current total CET along $D_t\rightarrow Y_t$.

## Open and closed paths

- With neither $Z_t$ nor $Z_{t-1}$ conditioned on, $D_t\rightarrow Z_t\leftarrow Y_t$ is closed at $Z_t$, and $D_t\leftarrow D_{t-1}\rightarrow Z_{t-1}\leftarrow Y_{t-1}\rightarrow Y_t$ is closed at $Z_{t-1}$.
- Conditioning on $Z_t$ opens the contemporaneous noncausal path $D_t\rightarrow Z_t\leftarrow Y_t$.
- Because $Z_t$ is a descendant of $Z_{t-1}$, conditioning on $Z_t$ also opens the inherited path through the lagged collider: $D_t\leftarrow D_{t-1}\rightarrow Z_{t-1}\leftarrow Y_{t-1}\rightarrow Y_t$.
- Independently of collider conditioning, $D_t\leftarrow D_{t-1}\rightarrow Y_{t-1}\rightarrow Y_t$ is an open ordinary dynamic backdoor path unless the relevant lagged treatment or outcome history is conditioned on.
- Conditioning on $Y_{t-1}$ blocks both cited lag paths because $Y_{t-1}$ is a noncollider on each. It does not block the contemporaneous path opened by conditioning on $Z_t$.

## Conditioning set

For the displayed pure-collider graph, the minimal set for the collider mechanisms excludes both $Z_t$ and $Z_{t-1}$. The contemporaneous $Z_t$ remains inadmissible for the total CET because it opens $D_t\rightarrow Z_t\leftarrow Y_t$. The lag $Z_{t-1}$ is not intrinsically inadmissible under every joint set: if it is needed for another documented path, conditioning jointly on $Y_{t-1}$ blocks the inherited path that conditioning on $Z_{t-1}$ opens. Lagged outcomes or treatments may likewise belong to $H_t^-$ for assignment or dynamic-mean reasons, subject to the Task 04 conditions. Adding $Y_{t-1}$ does not cure conditioning on $Z_t$.

# Graph 2: dual-role control

## Edges and target

At period $t$, $Z_{t-1}$ is a joint cause of treatment and outcome: $Z_{t-1}\rightarrow D_t$ and $Z_{t-1}\rightarrow Y_t$. It is therefore a confounder for the CET if its timestamp is genuinely pretreatment. The current variable is a collider, $D_t\rightarrow Z_t\leftarrow Y_t$, with $Z_{t-1}\rightarrow Z_t$. The lagged state also preserves the preceding-period collider $D_{t-1}\rightarrow Z_{t-1}\leftarrow Y_{t-1}$, the preceding-period causal edge $D_{t-1}\rightarrow Y_{t-1}$, treatment persistence $D_{t-1}\rightarrow D_t$, and outcome persistence $Y_{t-1}\rightarrow Y_t$. The target remains the total CET carried by $D_t\rightarrow Y_t$.

## Open and closed paths

- Without conditioning, the backdoor path $D_t\leftarrow Z_{t-1}\rightarrow Y_t$ is open. The inherited path $D_t\leftarrow D_{t-1}\rightarrow Z_{t-1}\leftarrow Y_{t-1}\rightarrow Y_t$ is closed at the collider $Z_{t-1}$.
- Conditioning on $Z_{t-1}$ blocks the confounding fork because $Z_{t-1}$ is a noncollider on $D_t\leftarrow Z_{t-1}\rightarrow Y_t$.
- The same conditioning opens the inherited path because $Z_{t-1}$ is a collider on $D_t\leftarrow D_{t-1}\rightarrow Z_{t-1}\leftarrow Y_{t-1}\rightarrow Y_t$.
- The distinct path $D_t\leftarrow D_{t-1}\rightarrow Y_{t-1}\rightarrow Y_t$ remains open without lag adjustment and does not depend on conditioning at $Z_{t-1}$.
- Conditioning additionally on $Y_{t-1}$ blocks both the inherited collider path and the ordinary dynamic path at $Y_{t-1}$, which is a noncollider on each. The simulation comparison cannot decompose the improvement between those two closures.
- Conditioning on $Z_t$ would separately open $D_t\rightarrow Z_t\leftarrow Y_t$. The set $\{Z_{t-1},Y_{t-1}\}$ does not close that contemporaneous path if $Z_t$ is included.

## Conditioning set and scope

For the displayed dual-role graph, $\{Z_{t-1},Y_{t-1}\}$ blocks the lagged-confounding path, the cited inherited path, and the displayed ordinary dynamic path while leaving $D_t\rightarrow Y_t$ open. This is not a universal sufficient adjustment set. Its interpretation requires that both lags are fixed before $D_t$, that no other backdoor path remains, that the dynamic conditional mean is correctly specified, and that the remaining Task 04 conditions hold. It is a population d-separation claim, not a statement that the conventional within estimator is unbiased at finite $T$.

# Graph 3: contemporaneous mediator with lagged confounding and state

## Edges and target

The graph contains direct and mediated effects in both displayed periods: $D_s\rightarrow Y_s$ and $D_s\rightarrow Z_s\rightarrow Y_s$ for $s\in\{t-1,t\}$. The opening state $Z_{t-1}$ also affects $D_t$, $Z_t$, and $Y_t$, while $D_{t-1}\rightarrow D_t$ and $Y_{t-1}\rightarrow Y_t$ encode persistence. The target is the current total CET, so both current causal paths belong to the estimand.

## Open and closed paths

- Before adjustment, $D_t\leftarrow Z_{t-1}\rightarrow Y_t$ is an open backdoor path. A longer path through prior treatment, $D_t\leftarrow D_{t-1}\rightarrow Z_{t-1}\rightarrow Y_t$, is also open unless its noncolliders are conditioned on.
- The ordinary dynamic path $D_t\leftarrow D_{t-1}\rightarrow Y_{t-1}\rightarrow Y_t$ is also open before lag adjustment.
- Conditioning on a genuinely pretreatment $Z_{t-1}$ blocks the first two backdoor paths at $Z_{t-1}$ and does not block $D_t\rightarrow Z_t\rightarrow Y_t$. It does not by itself block the path through $Y_{t-1}$; that requires $D_{t-1}$, $Y_{t-1}$, or another sufficient history representation.
- Conditioning on $Z_t$ blocks the indirect causal path because $Z_t$ is a noncollider on $D_t\rightarrow Z_t\rightarrow Y_t$. The coefficient on $D_t$ then targets a direct rather than total effect only under the additional assumptions needed for mediation analysis.
- Conditioning on $Y_{t-1}$ can be appropriate when it is part of the sufficient opening history or dynamic conditional mean, but it is not what distinguishes the total from the direct CET in this graph.

## Conditioning set

For the displayed graph and the total CET, the candidate lagged adjustment set includes $Z_{t-1}$ and any additional pretreatment history required for assignment and dynamics, such as $D_{t-1}$ or $Y_{t-1}$. It excludes $Z_t$. This recommendation is conditional on defended timestamps, no anticipation, no unobserved contemporaneous confounding, and a correctly specified history; lagging does not by itself guarantee identification.

# Manuscript mapping and reproducibility

The collider and mediator DAGs replace the elementary DAG figure in the timing section of `ivb_paper_pa.Rmd`. The dual-role DAG appears immediately before the existing dual-role simulation figure. All three diagrams are defined directly in the manuscript with TikZ; no external image or simulation is required to reproduce them. The legacy label `fig:three_structures_pa` is retained on the dynamic collider figure, and the new labels are `fig:dynamic_collider_pa`, `fig:dynamic_mediator_pa`, and `fig:dynamic_dual_role_pa`.

No simulation was run to produce or validate these graphs. Their arrows were matched to the mechanisms in the existing dual-role and over-control data-generating processes, while the causal interpretation was constrained by the Task 03 timing checklist and Task 04 CET identification conditions.
