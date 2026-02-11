# Plan: Next Steps for IVB Paper — Strengthening for PSRM Submission

**Status**: DRAFT
**Date**: 2026-02-10

---

## Honest Assessment

The paper is well-written, the algebra is correct, and the OVB/IVB framing is genuinely clever. After the pipeline revisions (related work, interpretation caveats, Nickell bias, honest novelty framing), the manuscript is in solid shape. But "solid shape" and "publishable at PSRM" are different things.

### The core tension

The main result is an algebraic identity that follows from the Frisch-Waugh-Lovell theorem. The paper now acknowledges this (Section 4.1, line 314), which is good — but it means the contribution rests almost entirely on **packaging, pedagogy, and the TSCS extension**. PSRM referees are methodologically sophisticated. The likely Referee 2 objection is: *"This is the short-long regression decomposition with a new name. The simulations confirm an algebra that holds by construction. The formula doesn't apply to the specifications most commonly used in the target literature."*

That objection is fair. The question is whether the paper provides enough value *around* the algebra to justify publication.

### What works in the paper's favor

1. **The OVB/IVB parallel is genuinely pedagogical gold.** Table 1 will be taught in methods courses. That alone has publication value.
2. **The TSCS extension is non-trivial in practice.** The "foreign collider bias" concept, even if underdeveloped, identifies a real blind spot in applied TSCS research.
3. **Direct estimability is underappreciated.** OVB is famous but usually uncomputable (the confounder is unobserved). IVB is always computable. That asymmetry is worth pointing out.
4. **The paper is clearly written.** Reviewers notice this. A clean paper gets better reviews than a sloppy one, all else equal.
5. **The Interpretation Caveats section (new) is honest and adds credibility.** Referees respect authors who acknowledge limits.

### What works against it

1. **Novelty.** Greenland (2003), Ding & Miratrix (2015), and especially Gaebler et al. (2024) — who use the exact term "included variable bias" — are now cited, but their existence weakens the novelty claim. A referee may say: "This has been done."
2. **Simulations prove nothing new.** Scatter plots showing formula = empirical bias are confirming an algebraic identity. Every point falls on the 45-degree line by construction. A referee will ask: "What do the simulations teach us?"
3. **Linearity only.** The civil war literature uses logit/probit. The formula doesn't apply. This is the biggest substantive gap.
4. **No inference.** Applied researchers need confidence intervals, not just point estimates. Without standard errors for IVB, the "diagnostic tool" is incomplete.
5. **The formula requires prior DAG knowledge.** The hardest part of the problem (is Z a collider?) isn't addressed. The formula only helps after the hard work is done.

### Bottom line

| Scenario | Estimated probability |
|----------|----------------------|
| Desk rejection | 20–30% |
| Sent to referees, rejected | 30–40% |
| R&R | 25–35% |
| Ultimate acceptance | **20–25%** |

These are not bad odds for a top methods journal. But they're not comfortable either. The revisions below could push acceptance probability to 35–45%.

---

## Priority 1: Changes that meaningfully improve PSRM chances

### 1A. Add simulations that test practical utility, not algebra

**Why**: This is the single most impactful revision. Current simulations confirm an identity. New simulations should answer questions referees will actually ask.

**What to add**:

1. **Confounder DGP**: Generate Z as a confounder (Z causes D and Y). Compute the IVB formula. Show that the formula returns a non-zero value — but in this case, the "bias" is actually OVB in the short regression, and the long regression is correct. This demonstrates the interpretive ambiguity from Section 4.6 with concrete numbers. The punch line: the formula decomposes correctly in both cases, but the *interpretation* depends on knowing the DAG.

2. **Binary outcome DGP**: Generate Y as binary (e.g., logit), with a collider Z. Compute IVB from a linear probability model. Show how much the linear IVB deviates from the true bias in the logistic model. If the deviation is small when the outcome is rare, say so — this would partially address the linearity limitation. If the deviation is large, say that too — honesty builds credibility.

3. **Small-sample performance**: Run the cross-section DGP with n = 100, 500, 1000 (not just 10,000). Show the distribution of estimated IVB across replications. Report coverage rates if you derive standard errors (see 1B). Applied political science samples are often small.

**Effort**: Medium. 2–3 days of simulation coding and writing.

### 1B. Derive standard errors for IVB via delta method

**Why**: IVB = -theta* x pi is a product of two OLS coefficients. The delta method gives an asymptotic standard error immediately. Without SEs, the diagnostic is a point estimate floating in a vacuum.

**What to add**:

- Derive Var(IVB) = pi^2 Var(theta*) + theta*^2 Var(pi) + 2 theta* pi Cov(theta*, pi) using the joint covariance matrix of the two regressions.
- Report IVB with 95% CI in the civil war application (Section 6).
- Optionally offer bootstrap as an alternative.

**Effort**: Low. 1 day. The delta method for products is textbook.

### 1C. Add a real empirical application (not just illustrative)

**Why**: The civil war example in Section 6 is illustrative — the authors choose the DGP, so the "application" is just another simulation dressed up as data. A referee may say: "Show me this works on real data where you didn't design the answer."

**What to add**: Pick a published paper in comparative politics or IR that includes a plausible collider in its specification. Compute IVB. Show what happens when the collider is dropped. Discuss whether the sign and magnitude of IVB are consistent with the DAG.

Candidates:
- Any paper from the Hegre et al. (2001) literature that includes Democracy as a control
- A paper from the foreign aid literature (Dietrich 2016 is already cited)
- A paper from the democratic peace literature

**Effort**: Medium. 2–3 days (requires data access, replication, and writing).

---

## Priority 2: Changes that moderately improve PSRM chances

### 2A. Develop the sensitivity analysis angle

**Why**: The Conclusion already mentions this as future work. Moving it from "future work" to "current paper" would be a genuine extension. The question: "How large would gamma_1 and gamma_2 need to be for the IVB to change my conclusions?" is the IVB analog of Cinelli & Hazlett (2020) for OVB.

**What to add**: Even a simple partial sensitivity analysis (e.g., bounding IVB as a function of R^2 of the collider equation) would add value. If a full sensitivity framework is too much, a figure showing IVB as a function of gamma_1 and gamma_2 (the heatmap from sim_ivb_completa.R already does this) could be moved from supplementary to main text.

**Effort**: Medium-High. 3–5 days if done rigorously.

### 2B. Package as R software

**Why**: Methods papers with software get more citations and are viewed more favorably by editors. An R package implementing the three-step recipe would make the paper immediately actionable.

**What to add**: A minimal R package (e.g., `ivb`) with:
- `ivb(long_model, short_model)` → returns IVB estimate, SE, CI
- `ivb_plot()` → visualization
- Vignette using the civil war example

**Effort**: Medium. 2–3 days for a minimal package.

### 2C. Strengthen "foreign collider bias" as a concept

**Why**: This is the most original conceptual contribution in the paper, but it's currently underdeveloped (just one paragraph in Section 3.3). If developed properly, it could be the paper's unique selling point relative to Greenland/Ding/Gaebler.

**What to add**: Formalize the concept. Show that TSCS-specific practices (lagging controls, including variables from adjacent literatures) systematically create collider risk. Maybe provide a typology of TSCS collider scenarios.

**Effort**: Medium. 2–3 days of writing.

---

## Priority 3: Nice-to-have improvements

### 3A. Strengthen or remove Appendix E (Potential Outcomes)
Currently superficial. Either connect formally to ATE/selection bias decomposition in the Rubin framework, or drop it. A weak appendix hurts more than no appendix.

### 3B. Add citations for heuristic prevalence
Section 2 claims "control checking" and "confounding checking" are widespread but cites only one paper each. Add 3–5 recent examples from APSR/AJPS/JOP for each heuristic.

### 3C. Non-Gaussian simulation
Add one DGP with t-distributed or heteroskedastic errors. The formula holds (it's algebraic), but showing it explicitly with non-normal data preempts the objection.

---

## Alternative venues (if PSRM doesn't work out)

| Journal | Fit | Notes |
|---------|-----|-------|
| **Political Analysis** | High | Similar scope, slightly more welcoming to pedagogical contributions |
| **Journal of Causal Inference** | High | Pearl-adjacent audience, on-topic, appreciates DAG-based work |
| **Sociological Methods & Research** | Medium | Cross-disciplinary, values accessible methodology |
| **Journal of the Royal Statistical Society, Series A** | Medium | Values applied statistics, international audience |
| **Statistics & Public Policy** | Medium | If framed around policy-relevant diagnostics |

Political Analysis is the natural backup. JCI would be a strong fit if PSRM referees think the contribution is too narrow for a general methods audience.

---

## Recommended revision sequence

1. **1B** (delta method SEs) — 1 day, high impact/effort ratio
2. **1A** (new simulations: confounder, binary, small-sample) — 2–3 days, most impactful
3. **1C** (real empirical application) — 2–3 days, strongly recommended
4. **2C** (develop foreign collider bias) — 2–3 days, differentiates from prior work
5. **2B** (R package) — 2–3 days, good for citations
6. Everything else as time permits

Total estimated effort for Priority 1: **5–7 days of focused work**.

---

## Verification
- [ ] Delta method SEs derived and implemented
- [ ] Confounder DGP simulation added
- [ ] Binary outcome simulation added
- [ ] Small-sample simulation added
- [ ] Real empirical application added
- [ ] Re-run pipeline after revisions
