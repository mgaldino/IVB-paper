# CET Timing Definition and Timestamp Checklist

## Purpose

This audit operationalizes Task 03 of the referee-feedback revision plan. It separates a variable's panel subscript from its substantive causal timestamp and records what must be known before calling a covariate pretreatment for the contemporaneous treatment effect (CET). The reader-facing definition is in `ivb_paper_pa.Rmd`; this file preserves the audit trail.

## Estimand and causal clock

Let `H_it^-` contain the state fixed immediately before the period-`t` treatment begins. For well-defined treatment levels `d` and `d'`,

`CET(d,d';h) = E[Y_it(d) - Y_it(d') | H_it^- = h]`.

The intended sequence is:

`opening state H_it^- -> treatment onset/intensity D_it -> covariate response Z_it -> outcome measurement Y_it^+`.

The CET is a total within-period effect unless a controlled direct effect is explicitly stated, so a path through a contemporaneous mediator is part of the estimand. For a continuous treatment, the scalar marginal effect is meaningful only if the recorded dose maps to a well-defined intervention. If intensity changes within the period, the treatment should instead be described as a trajectory `d_it(s)`, and the estimand should contrast trajectories.

## Minimum timestamp checklist

**Table 1. Minimum timestamp information for the CET causal clock**

| Item | Minimum record | Pass condition | Failure implication |
|---|---|---|---|
| Treatment `D` | Onset date, end date, exposure/intensity window, and whether `D` is an event, flow, period average, or cumulative stock | The intervention contrast and its exposure window are explicit | A scalar `D_t` may combine causally different exposure paths |
| Candidate control `Z` | Reference period, measurement/collection time, and whether `Z` can respond to anticipated, prior, or current treatment | The `Z` window closes before the first treatment exposure relevant to the contrast | Do not call `Z` pretreatment; classify timing as plausible or ambiguous |
| Outcome `Y` | Reference period, measurement time, and whether the measure is a stock, flow, endpoint, or average | The outcome window follows the relevant exposure window | The proposed CET may reverse the order or mix pre- and post-treatment outcomes |
| Anticipation | Earliest date actors could reasonably respond to future treatment | `Z` is fixed before that date, or no-anticipation is substantively defended | A nominal `Z_{t-1}` may already be treatment-responsive |
| Aggregation | Frequency and exact mapping from source dates to panel periods | `D`, `Z`, and `Y` have nonoverlapping or explicitly modeled windows | Annual or multi-year labels alone do not establish order |
| Prior exposure | Treatment history before the focal contrast, especially for persistent or cumulative treatment | The estimand conditions on or explicitly includes prior exposure | A baseline `Z` may mediate earlier treatment even if it precedes the current outcome |

## Classification rule

- **Known:** documentation fixes the relevant windows and establishes the ordering, including a defensible treatment-onset or anticipation boundary.
- **Plausible:** exact timestamps are incomplete, but the measurement design and substantive institutions support the ordering without an evident overlap.
- **Ambiguous:** treatment and covariate windows overlap, the variables share only a coarse period label, anticipation is unresolved, or a cumulative treatment may already have affected the candidate state.

“Pre-outcome” and “pretreatment” are separate judgments. A covariate can be measured before the outcome window yet remain post-treatment relative to prior or accumulating exposure.

## Application audit

The compact row-level audit is stored in `quality_reports/cet_application_timing_audit.csv`.

These applications audit exposure horizons adjacent to, but distinct from, the manuscript's core contemporaneous `D_t -> Y_t` CET. Leipziger indexes a lagged annual exposure against the current outcome; Rogowski indexes a baseline cumulative stock against an outcome led by one five-year panel step. Re-indexing each application by its focal exposure period makes those horizons explicit. The comparisons remain useful because they apply the same timestamp discipline to pretreatment claims and show how sensitive each published exposure contrast is to conditioning on GDP; they are not offered as direct demonstrations of the core CET.

### Leipziger (2024): democracy and ethnic inequality

- **Known:** The unit is the country-year. The published baseline regresses ethnic inequality in calendar year `t` on both democracy and latent log GDP per capita lagged one year. The article and replication do-file explicitly state that all right-hand-side variables are lagged one year. Thus the contrast is `D_{t-1} -> Y_t`, or `D_s -> Y_{s+1}` when the exposure year is re-indexed as `s = t-1`; it is not the core contemporaneous CET.
- **Plausible:** Year-`t-1` GDP is plausibly a state relevant to subsequent inequality and may capture development-related confounding.
- **Ambiguous:** Democracy and GDP have the same annual index (`t-1`). The available materials do not timestamp the democratic transition, the GDP reference window, or the V-Dem outcome assessment within the year. Anticipatory economic responses to an expected transition are not ruled out. Because both predictors are annual measures, `GDP_{t-1}` is pre-outcome but not shown to close before the treatment represented by `Democracy_{t-1}`.
- **Assessment:** `Z` is **ambiguous**, not genuinely established as pretreatment for the focal democracy contrast.
- **Minimum resolution:** Record the effective transition date; define whether democracy is status at the start/end of the year or exposure during the year; document the GDP reference window and the V-Dem coding window; state the earliest plausible anticipation date. If those cannot be recovered, the paper should retain the ambiguous classification.

### Rogowski et al. (2022): postal infrastructure and economic growth

- **Known:** The country panel advances in five-year steps (`xtset country_id trend`). The published replication code uses `F.e_migdpgro_5yr` as the outcome. The post-office stock and GDP-per-capita variables enter the same regression row; the post-office variable is a cumulative stock, and the outcome is one panel period ahead. Indexing the baseline row as `s`, the contrast is cumulative stock `D_s -> Y_{s+1}`, with `s+1` the next five-year step; it is a forward contrast rather than the core contemporaneous CET.
- **Plausible:** GDP recorded in the baseline row is a plausible initial state for growth in the subsequent outcome window and is a standard conditional-convergence covariate.
- **Ambiguous:** The codebook names the variables but does not document the opening and closing dates of their five-year constructions. More importantly, a cumulative post-office stock embodies treatment received before the baseline row. Baseline GDP may therefore already respond to earlier postal infrastructure even if it precedes the forward growth outcome. The same row does not establish whether GDP precedes the incremental treatment contrast, follows prior treatment, or overlaps its accumulation.
- **Assessment:** `Z` is **plausibly pre-outcome but ambiguous as pretreatment** for the postal-stock contrast; it is not genuinely established as pretreatment.
- **Causal role:** Unresolved. Baseline GDP may be a confounder through conditional convergence, a legacy treatment-responsive state or mediator because inherited postal infrastructure may already have affected it, or a dual-role variable. The specification shift is descriptive unless a DAG and timing evidence distinguish these possibilities.
- **Minimum resolution:** Document the source-year windows used to construct postal stock, GDP level, and GDP growth; distinguish the effect of the inherited stock from the effect of new postal investment over the next five years; and specify how prior postal exposure enters `H^-`. If the target remains the inherited cumulative stock, a claim that baseline GDP is wholly pretreatment is not supportable without additional assumptions.

## Implication for the PA manuscript

The new opening subsection of “DAGs, Timing, and Why `Z_t` Is Not `Z_{t-1}`” now defines the CET, states the within-period causal clock, supplies the minimum timestamp table, and conditions the lagged-control benchmark on substantive timing. Each detailed application also states its timing verdict. Neither application is presented as proof that a lagged GDP variable is automatically safe.

## Materials inspected

- `quality_reports/plans/2026-07-10_referee_feedback_revision_plan.md`, Task 03.
- `tmp/pdfs/referee_feedback.txt`, especially Sections 5.4, 5.10, and 6.
- `ivb_paper_pa.Rmd` and the corresponding timing/application passages in `ivb_paper_psrm.Rmd` (read only).
- Leipziger replication README, codebook, analysis do-file, article PDF, and existing IVB report.
- Rogowski replication README, codebook, main analysis do-file, data header, and existing IVB report.

No simulation was run, and no causal role was inferred from the coefficient-shift identity alone.
