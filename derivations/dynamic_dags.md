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

where the opening history $H_t^-$ is fixed before the first exposure represented by $D_t$, and $Y_t$ is measured after the relevant within-period responses. Unless a controlled direct effect is stated, the target is the total CET. The lagged variables shown in a graph belong to $H_t^-$ only if their substantive timestamps pass the Task 03 checklist. The graphs do not assert that a calendar lag is automatically pretreatment, that the displayed history is sufficient, or that a within estimator is unbiased at finite $T$.

A path is evaluated using the usual d-separation rules. An unconditioned noncollider transmits association; conditioning on a noncollider blocks the path. An unconditioned collider blocks a path; conditioning on that collider or one of its descendants opens the path. These path statements concern the displayed DAG and do not rule out omitted common causes, interference, simultaneity, misspecified lag order, or treatment-effect heterogeneity.

# Graph 1: contemporaneous collider with an inherited lag path

## Edges and target

The graph contains the causal edge $D_t\rightarrow Y_t$, the contemporaneous collider $D_t\rightarrow Z_t\leftarrow Y_t$, persistence $D_{t-1}\rightarrow D_t$, $Y_{t-1}\rightarrow Y_t$, and $Z_{t-1}\rightarrow Z_t$, and the lagged collider $D_{t-1}\rightarrow Z_{t-1}\leftarrow Y_{t-1}$. The target is the total CET along $D_t\rightarrow Y_t$.

## Open and closed paths

- With neither $Z_t$ nor $Z_{t-1}$ conditioned on, $D_t\rightarrow Z_t\leftarrow Y_t$ is closed at $Z_t$, and $D_t\leftarrow D_{t-1}\rightarrow Z_{t-1}\leftarrow Y_{t-1}\rightarrow Y_t$ is closed at $Z_{t-1}$.
- Conditioning on $Z_t$ opens the contemporaneous noncausal path $D_t\rightarrow Z_t\leftarrow Y_t$.
- Because $Z_t$ is a descendant of $Z_{t-1}$, conditioning on $Z_t$ also opens the inherited path through the lagged collider: $D_t\leftarrow D_{t-1}\rightarrow Z_{t-1}\leftarrow Y_{t-1}\rightarrow Y_t$.
- Conditioning on $Y_{t-1}$ blocks that inherited path because $Y_{t-1}$ is a noncollider on it. It does not block the contemporaneous path opened by conditioning on $Z_t$.

## Conditioning set

For the displayed pure-collider graph, the CET adjustment set should not contain $Z_t$ or $Z_{t-1}$. Lagged outcomes or treatments may belong to $H_t^-$ for assignment or dynamic-mean reasons, but that decision requires the Task 04 sequential-exchangeability and specification conditions. In particular, adding $Y_{t-1}$ is not a cure for conditioning on $Z_t$.

# Graph 2: dual-role control

## Edges and target

At period $t$, $Z_{t-1}$ is a joint cause of treatment and outcome: $Z_{t-1}\rightarrow D_t$ and $Z_{t-1}\rightarrow Y_t$. It is therefore a confounder for the CET if its timestamp is genuinely pretreatment. The current variable is a collider, $D_t\rightarrow Z_t\leftarrow Y_t$, with $Z_{t-1}\rightarrow Z_t$. The lagged state also preserves the preceding-period collider $D_{t-1}\rightarrow Z_{t-1}\leftarrow Y_{t-1}$, treatment persistence $D_{t-1}\rightarrow D_t$, and outcome persistence $Y_{t-1}\rightarrow Y_t$. The target remains the total CET carried by $D_t\rightarrow Y_t$.

## Open and closed paths

- Without conditioning, the backdoor path $D_t\leftarrow Z_{t-1}\rightarrow Y_t$ is open. The inherited path $D_t\leftarrow D_{t-1}\rightarrow Z_{t-1}\leftarrow Y_{t-1}\rightarrow Y_t$ is closed at the collider $Z_{t-1}$.
- Conditioning on $Z_{t-1}$ blocks the confounding fork because $Z_{t-1}$ is a noncollider on $D_t\leftarrow Z_{t-1}\rightarrow Y_t$.
- The same conditioning opens the inherited path because $Z_{t-1}$ is a collider on $D_t\leftarrow D_{t-1}\rightarrow Z_{t-1}\leftarrow Y_{t-1}\rightarrow Y_t$.
- Conditioning additionally on $Y_{t-1}$ blocks the inherited path at $Y_{t-1}$, which is a noncollider on that path. This is the precise d-separation result represented by the manuscript's “firewall” language.
- Conditioning on $Z_t$ would separately open $D_t\rightarrow Z_t\leftarrow Y_t$. The set $\{Z_{t-1},Y_{t-1}\}$ does not close that contemporaneous path if $Z_t$ is included.

## Conditioning set and scope

For the displayed dual-role graph, $\{Z_{t-1},Y_{t-1}\}$ blocks the lagged-confounding path and the cited inherited path while leaving $D_t\rightarrow Y_t$ open. This is not a universal sufficient adjustment set. Its interpretation requires that both lags are fixed before $D_t$, that no other backdoor path remains, that the dynamic conditional mean is correctly specified, and that the remaining Task 04 conditions hold. It is a population d-separation claim, not a statement that the conventional within estimator is unbiased at finite $T$.

# Graph 3: contemporaneous mediator with lagged confounding and state

## Edges and target

The graph contains a direct effect $D_t\rightarrow Y_t$ and an indirect effect $D_t\rightarrow Z_t\rightarrow Y_t$. The opening state $Z_{t-1}$ affects $D_t$, $Z_t$, and $Y_t$, while $D_{t-1}\rightarrow D_t$, $D_{t-1}\rightarrow Z_{t-1}$, and $Y_{t-1}\rightarrow Y_t$ encode persistence and prior exposure. The target is the total CET, so both current causal paths belong to the estimand.

## Open and closed paths

- Before adjustment, $D_t\leftarrow Z_{t-1}\rightarrow Y_t$ is an open backdoor path. A longer path through prior treatment, $D_t\leftarrow D_{t-1}\rightarrow Z_{t-1}\rightarrow Y_t$, is also open unless its noncolliders are conditioned on.
- Conditioning on a genuinely pretreatment $Z_{t-1}$ blocks both displayed backdoor paths at $Z_{t-1}$ and does not block $D_t\rightarrow Z_t\rightarrow Y_t$.
- Conditioning on $Z_t$ blocks the indirect causal path because $Z_t$ is a noncollider on $D_t\rightarrow Z_t\rightarrow Y_t$. The coefficient on $D_t$ then targets a direct rather than total effect only under the additional assumptions needed for mediation analysis.
- Conditioning on $Y_{t-1}$ can be appropriate when it is part of the sufficient opening history or dynamic conditional mean, but it is not what distinguishes the total from the direct CET in this graph.

## Conditioning set

For the displayed graph and the total CET, the candidate lagged adjustment set includes $Z_{t-1}$ and any additional pretreatment history required for assignment and dynamics, such as $D_{t-1}$ or $Y_{t-1}$. It excludes $Z_t$. This recommendation is conditional on defended timestamps, no anticipation, no unobserved contemporaneous confounding, and a correctly specified history; lagging does not by itself guarantee identification.

# Manuscript mapping and reproducibility

The collider and mediator DAGs replace the elementary DAG figure in the timing section of `ivb_paper_pa.Rmd`. The dual-role DAG appears immediately before the existing dual-role simulation figure. All three diagrams are defined directly in the manuscript with TikZ; no external image or simulation is required to reproduce them. The legacy label `fig:three_structures_pa` is retained on the dynamic collider figure, and the new labels are `fig:dynamic_collider_pa`, `fig:dynamic_mediator_pa`, and `fig:dynamic_dual_role_pa`.

No simulation was run to produce or validate these graphs. Their arrows were matched to the mechanisms in the existing dual-role and over-control data-generating processes, while the causal interpretation was constrained by the Task 03 timing checklist and Task 04 CET identification conditions.
