# Stage 2: Devil's Advocate -- ivb_paper_psrm.Rmd (Round 1)

**Date**: 2026-03-03
**Manuscript**: `ivb_paper_psrm.Rmd` (1238 lines)
**Focus**: Newly added Sections 4.3--4.5, updated abstract/conclusion/limitations.
**Prior version**: This file overwrites the 2026-02-28 round 1 report with a new review focused on the new sections.

---

## Score: 46/100

| # | Severity | Deduction | Section | Issue |
|---|----------|-----------|---------|-------|
| 1 | Critical | -20 | 4.3 | Multiple factual mismatches between text and simulation code/data |
| 2 | Critical | -20 | 4.5 | Reports results for phi=0.15 that was never simulated |
| 3 | Major | -10 | 4.4 / Conclusion | "at most 25%" TWFE IVB increase claim contradicted by data (actual: up to 40%) |
| 4 | Minor | -2 | Abstract / Sec 4 / Conclusion | "over 300 DGP configurations" not verifiable from cited sims (~168) |
| 5 | Minor | -2 | 4.5 | "phi >= 0.18 explosive" threshold not derivable from simulations |

**Total deductions: -54. Score: 46/100**

## Status: REPROVADO

---

## Critical Vulnerabilities

### V1 (Critical, -20): Section 4.3 -- Multiple factual mismatches with simulation code and data

**Location**: Line 592, Section 4.3 "ADL Specifications Reduce Residual IVB"

The text states:
> "Across 48 scenarios with binary staggered treatment ($N = 200$, $T = 30$, 500 replications), TWFE without $Z$ exhibits bias of 86--169% of $\beta$"

Three factual errors verified against the code and data:

**1. N=200 is wrong.** The simulation code (`simulations/v4_mechanisms/sim_mechC_adl.R`, line 43) sets `N = 100`:
```r
P <- list(N = 100, TT = 30, T_burn = 100, beta = 1, ...)
```
The text says N=200. This is a simple factual error.

**2. Bias lower bound 86% is wrong.** The actual minimum TWFE short bias across 48 mechC_adl scenarios is **77.3%** (prob_switch=0.7, delta_D=0.1, delta_Y=0, rho_Z=0.5). The five smallest values are:
- 77.3%, 78.5%, 81.8%, 82.1%, 83.7%

The correct range is **77--169%**, not 86--169%.

**3. DGP description doesn't match the simulation.** The text describes:
> "a dual-role $Z$ that is simultaneously a confounder ($Z_{t-1} \to D_t$, $Z_{t-1} \to Y_t$) and a collider"

But the mechC_adl simulation has **exogenous binary D** with no $Z \to D$ feedback. The code header (line 14) explicitly states: "D is exogenous binary -- no Z -> D feedback." The treatment equation is simply `D_it = 1(t >= T_i*)` (staggered adoption). There is no $Z_{t-1} \to D_t$ channel. The confounding operates only through $Z_{t-1} \to Y_t$.

This matters for interpretation: the text claims to simulate a "dual-role Z" (both confounder and collider), but the actual DGP has Z as a one-way confounder (via $Z_{t-1} \to Y_t$) and collider (via $D_t \to Z_t \leftarrow Y_t$), without the Z-to-D feedback that would make it a "full" dual-role variable. The separate `sim_dual_role_z_8models.R` DOES have Z-to-D feedback, but that has 10 scenarios (not 48) with continuous D (not binary staggered).

**Recommendation**: REESCREVER.
- Fix N to 100
- Fix bias range to 77--169%
- Accurately describe the DGP: Z is a confounder via $Z_{t-1} \to Y_t$ only (not $Z_{t-1} \to D_t$), and D is exogenous binary with staggered adoption


### V2 (Critical, -20): Section 4.5 -- Reports results for phi=0.15 that was never simulated

**Location**: Lines 600--606, Section 4.5 "Feedback from Outcomes to Treatment"

The text states:
> "with $\phi \in \{0, 0.05, 0.10, 0.15\}$"

and:

> "TWFE bias grows monotonically with $\phi$: from 43% of $\beta$ at $\phi = 0$ to 80% at $\phi = 0.15$ (with $\rho_Z = 0.5$)"

**Problems verified against code and data:**

1. **phi=0.15 was never simulated.** The simulation grid (`simulations/dynamics/sim_direct_feedback.R`, line 98-99):
```r
grid <- CJ(
  phi   = c(0, 0.05, 0.1),
  rho_Z = c(0.5, 0.7)
)
```
The code header (line 11) states: "phi=0.2 and rho_Z=0.85 excluded -- VAR system is non-stationary." Only 6 scenarios were simulated, not 8.

2. **The "80% at phi=0.15 with rho_Z=0.5" number is not in the data.** The actual TWFE short biases are:

| phi | rho_Z | TWFE short bias |
|-----|-------|----------------|
| 0 | 0.5 | 43.2% |
| 0 | 0.7 | 50.8% |
| 0.05 | 0.5 | 55.7% |
| 0.05 | 0.7 | 65.7% |
| 0.10 | 0.5 | **68.6%** |
| 0.10 | 0.7 | **80.4%** |

The 80% figure comes from phi=0.1, rho_Z=**0.7** -- not phi=0.15, rho_Z=0.5 as claimed. The text attributes a specific result to the wrong parameter combination.

3. **The claim "for phi >= 0.18 approximately, the system becomes explosive"** cannot be verified. The sim only tested phi in {0, 0.05, 0.1}. The specific threshold 0.18 appears to be interpolated or guessed.

**Recommendation**: REESCREVER.
- Correct phi grid to {0, 0.05, 0.10}
- Report actual numbers: "from 43% at phi=0 to 69% at phi=0.1 (rho_Z=0.5), and from 51% to 80% at phi=0.1 (rho_Z=0.7)"
- Change explosive threshold to: "For phi=0.2, the system becomes non-stationary" (matching the code comment) or compute the eigenvalue threshold analytically


## Major Vulnerabilities

### V3 (Major, -10): Section 4.4 and Conclusion -- "at most 25%" TWFE IVB increase claim is wrong

**Location**: Line 598 (Section 4.4) and Line 908 (Conclusion)

The text states:
> "Even TWFE IVB grows by at most 25% relative to the linear case" (Section 4.4)

And the conclusion repeats:
> "bounded nonlinearities in the collider channel increase IVB by at most 25%"

**This claim is contradicted by the NL simulation data** (`simulations/nonlinearity/results/sim_nl_collider_results.csv`). For bounded nonlinearities at T=30:

| NL type | Bounded? | Strength | rho_Z | TWFE IVB change vs linear baseline |
|---------|----------|----------|-------|------------------------------------|
| invlogit | Yes (0 to 1) | 2 | 0.5 | **+40.1%** |
| tanh | Yes (-1 to 1) | 2 | 0.5 | **+37.4%** |
| invlogit | 2 | 0.7 | | **+27.5%** |
| tanh | 1 | 0.5 | | +17.6% |
| log4 | Yes (concave) | 2 | 0.5 | +12.5% |
| softpoly2 | Yes (bounded) | 2 | 0.5 | +21.7% |

Both invlogit (inverse logistic, bounded by [0,1]) and tanh (bounded by [-1,1]) are unambiguously "bounded" nonlinearities. At strength=2, they produce TWFE IVB increases of **37--40%** -- well above 25%.

The ADL-all-lags result (< 3% bias) IS correct across all NL types and IS well-supported. The error is specifically in the TWFE IVB percentage claim.

**Note**: The 25% figure may hold for specific NL types (e.g., log2, log4 at moderate strengths) but not universally for all bounded nonlinearities at all tested strengths.

**Recommendation**: REESCREVER.
- Option A: Change "at most 25%" to "typically less than 40% for bounded nonlinearities" (actual worst case across bounded types)
- Option B: Qualify which bounded NL types and strengths the 25% applies to
- Option C (recommended): Drop the TWFE percentage claim entirely and focus on the ADL result, which is the stronger and more policy-relevant finding: "For bounded nonlinearities, the ADL model with all lags remains robust: bias stays below 3% of beta"


## Minor Vulnerabilities

### V4 (Minor, -2): Abstract / Section 4 / Conclusion -- "over 300 DGP configurations" not verifiable

**Location**: Lines 33 (abstract), 576 (Section 4 intro), 908 (conclusion)

The simulations directly cited in Sections 4.2--4.5 total approximately 168 configurations:
- mechC_adl (Section 4.2-4.3): 48
- dual_role_z_8models (Section 4.3): 10
- nl_collider (Section 4.4): 81
- nl_interact (Section 4.4): 10
- nl_carryover (Section 4.4): 13
- direct_feedback (Section 4.5): 6

Reaching 300 requires counting diagnostic simulations, sensitivity analyses, and dual_role_z variants not discussed in the paper body. The v1 simulation (600 configs) is explicitly described as "tautological."

**Recommendation**: REESCREVER. Either (a) report the precise number from cited simulations ("approximately 170 DGP configurations") or (b) specify what "over 300" includes, e.g., "including sensitivity analyses in the online appendix."


### V5 (Minor, -2): Section 4.5 -- "phi >= 0.18 approximately, explosive" threshold imprecise

**Location**: Line 604

> "For $\phi \geq 0.18$ (approximately), the joint dynamic system $(D, Y, Z)$ becomes explosive"

The simulation only tested phi in {0, 0.05, 0.1}. The code excludes phi=0.2 with a comment about non-stationarity. The specific threshold 0.18 is not derived from any eigenvalue computation in the code, nor tested in simulation. It appears to be interpolated or asserted without verification.

**Recommendation**: REESCREVER. Either compute the companion matrix eigenvalue threshold analytically and report it precisely, or soften to: "For $\phi = 0.2$, the system becomes non-stationary, defining the boundary of our simulation grid."


---

## Strengths

### S1: Strong theoretical core (Sections 2--3)
The IVB formula derivation, OVB/IVB comparison table, extensions to ADL(p,q), and the lag-substitution proposition are clean, well-structured, and genuinely novel in their combination. The FWL-based approach is elegant.

### S2: Honest interpretation caveats (Section 3.8)
The three-case discussion (collider vs. confounder vs. mediator) is unusually careful. The butterfly-structure discussion connecting to Ding & Miratrix (2015) and the future-work paragraph on simultaneous collider-confounder under TWFE show intellectual honesty.

### S3: ADL robustness result is robust and well-supported
Across ALL simulation families -- mechC_adl (48 configs), 8models (10 configs), nl_collider (81 configs), and direct_feedback (6 configs) -- the ADL with all lags keeps bias below 3% of beta. This is verified against the data and is the paper's strongest new empirical finding.

### S4: Empirical applications are well-executed
The six-study replication with DAG-based classification tables (Appendix E) is thorough. The Leipziger deep dive (modest IVB, well-supported collider interpretation) and Rogowski deep dive (large IVB, causally ambiguous) are effective contrasts that demonstrate intellectual honesty.

### S5: "Foreign collider bias" concept
The naming and framing -- requiring consultation of literatures "foreign" to the researcher's domain -- is a genuine conceptual contribution that will resonate with applied researchers.

### S6: Section 4.1 (FE absorption) is clean algebra
The argument follows directly from Corollary 1 with no simulation needed. This is the most defensible mechanism in Section 4.

### S7: Appropriate caveats on few-switchers (Section 4.2)
The text correctly warns that small |IVB/SE| does not mean the bias is harmless, since the population IVB is constant regardless of switcher count. This prevents misinterpretation.


---

## Parsimony Assessment

### Should any section be CUT?

**Section 4.2 (few switchers)**: The weakest of the five mechanisms. The insight ("few switchers inflate SE relative to constant IVB") is straightforward, and the caveat ("but population IVB is constant, so this doesn't mean bias is harmless") largely undermines the reassurance. Consider CUTTING or folding into a single paragraph within Section 4.1. Current contribution does not justify a standalone subsection.

**Section 4.4 (NL robustness)**: Keep but rewrite. The ADL robustness result is valuable; the TWFE percentage claim must be corrected. Focus on the ADL finding.

**Section 4.5 (feedback)**: Keep but rewrite with correct numbers. Connects well to Imai & Kim framework.

**Appendix C (simulation code)**: Currently describes v1 DGPs (cross-section, ADL, civil war) that do not match the Section 4 simulations. Should be updated or removed.


---

## Consistency Check: Abstract -- Body -- Conclusion

| Claim | Abstract | Body | Conclusion | Verified? |
|-------|----------|------|------------|-----------|
| IVB = -theta* x pi | Yes | Yes | Yes | CORRECT |
| >300 DGP configs | Yes (L33) | Yes (L576) | Yes (L908) | **WRONG** (~168 from cited sims) |
| ADL bias < 3% of beta | Yes | Yes | Yes | CORRECT (verified against data) |
| Bounded NL: at most 25% | -- | Yes (L598) | Yes (L908) | **WRONG** (up to 40%) |
| phi in {0,.05,.10,.15} | -- | Yes (L604) | -- | **WRONG** (phi=0.15 not simulated) |
| TWFE 43% to 80% at phi=0.15 | -- | Yes (L604) | -- | **WRONG** (80% is at phi=0.1, rho_Z=0.7) |
| N=200, T=30 for Sec 4.3 sim | -- | Yes (L592) | -- | **WRONG** (N=100 in code) |
| 14 collider candidates | Yes | Yes | Yes | CORRECT |
| Median IVB/SE ~ 0.13 | Yes | Yes | Yes | CORRECT |
| Only Rogowski > 1 SE | Yes | Yes | Yes | CORRECT |
| Five mechanisms | -- | Yes (L576) | Yes (L908) | CORRECT |
| Bias < 1% for feedback (ADL) | -- | Yes (L604) | Yes (L908) | CORRECT (verified) |


---

## Recommendations Summary (Priority Order)

1. **URGENT -- V1**: Fix Section 4.3 factual errors (N=100, bias range 77--169%, DGP description)
2. **URGENT -- V2**: Fix Section 4.5 fabricated phi=0.15 results (correct grid, numbers, and threshold)
3. **HIGH -- V3**: Fix "at most 25%" TWFE IVB claim in Section 4.4 and Conclusion
4. **MEDIUM -- V4**: Verify "over 300 DGP" count or change to actual number
5. **LOW -- V5**: Soften or verify explosive threshold claim
6. **LOW**: Update Appendix C to describe actual Section 4 DGPs
7. **OPTIONAL**: Consider cutting Section 4.2 for parsimony
