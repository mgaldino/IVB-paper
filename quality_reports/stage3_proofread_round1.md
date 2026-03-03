# Stage 3: Proofread Review -- Round 1 (Post-Integration)

**Reviewer:** Proofread Reviewer Agent (Claude Opus 4.6)
**Date:** 2026-03-03
**File reviewed:** `ivb_paper_psrm.Rmd` (1239 lines) and `references.bib` (572 lines)
**Focus:** Newly integrated sections (4.3--4.5, updated Summary, abstract, conclusion, limitations)

---

## Summary

The manuscript is well written overall, with clear prose and rigorous mathematical exposition. The newly integrated sections (ADL, nonlinearity, feedback subsections; updated Summary; revised abstract; revised conclusion and limitations paragraphs) are substantively strong and well integrated with the existing text. The main issues found are: (a) a clear grammar error in the Introduction (missing subject in a sentence), (b) an incomplete verb phrase in the Introduction ("putting a collider" instead of "putting in" or "including"), (c) minor notation and style inconsistencies between new and existing text, and (d) a few points where cross-referencing or wording could be improved. No broken references, missing citation keys, or factual errors were found.

The "five mechanisms" count is internally consistent across the Section 5 intro (line 576), the five subsections (5.1--5.5), the Summary subsection (line 608), the abstract (line 33), and the conclusion (line 908).

---

## Issue Table

| # | Line(s) | Current Text | Proposed Correction | Category | Severity |
|---|---------|-------------|---------------------|----------|----------|
| 1 | 76 | "We show that is primarily cross-sectional (e.g., richer countries have better governance in levels), fixed effects remove this association, and the residual within-unit IVB is small." | Missing subject. Should read: "We show that **when the association between treatment and collider** is primarily cross-sectional (e.g., richer countries have better governance in levels), fixed effects remove this association, and the residual within-unit IVB is small." (Or a similar repair that supplies the missing subject clause.) | Grammar | Major (-10) |
| 2 | 74 | "IVB quantifies the cost of putting a collider." | Incomplete verb phrase. Should read: "IVB quantifies the cost of **including** a collider." (Alternatively: "putting **in** a collider.") The existing paper uses "including" consistently elsewhere (lines 67, 87, 288, 345, etc.). | Grammar | Major (-10) |
| 3 | 33 | Abstract: "We characterize structural conditions---fixed effects absorbing between-unit variation, few treatment switchers, ADL specifications blocking collider paths, bounded nonlinearities, and moderate outcome-to-treatment feedback---that explain why IVB tends to be modest in typical panel applications." | The phrase "moderate outcome-to-treatment feedback" could be misread as claiming that moderate feedback *explains* why IVB is modest, when the actual claim is that moderate feedback *does not break* the ADL's ability to keep IVB small. Consider: "...bounded nonlinearities, and moderate (rather than explosive) outcome-to-treatment feedback---" or simply noting that these are conditions under which the result holds. This is a clarity issue, not strictly a grammar error. | Style/Clarity | Minor (-2) |
| 4 | 592 | "The ADL specification with all lags ($Y \sim D + Y_{t-1} + D_{t-1} + Z_{t-1}$) reduces bias to less than 3\% of $\beta$ in every scenario." | The R-formula notation `$Y \sim D + Y_{t-1} + D_{t-1} + Z_{t-1}$` is informal and inconsistent with the LaTeX equation style used elsewhere in the paper (e.g., equations 7--12). Consider: "$Y_t = \beta D_t + \rho Y_{t-1} + \gamma_D D_{t-1} + \delta Z_{t-1} + \text{FE} + e_t$" or simply describe it in prose: "the ADL specification including $Y_{t-1}$, $D_{t-1}$, and $Z_{t-1}$". | Notation | Minor (-2) |
| 5 | 576 | "The remaining four are documented with Monte Carlo simulations spanning over 300 DGP configurations and 500 replications each." | The count "over 300 DGP configurations" is consistent with the abstract (line 33) and conclusion (line 908). However, the paper earlier (lines 578--586) describes only Mechanisms A/B (the FE absorption argument, which is analytical) and C (the few-switchers mechanism). The new sections add Mechanisms D (ADL, 48 scenarios), E (NL, unspecified count), and F (feedback, unspecified count). The reader cannot verify the "300" claim from the text alone. Consider adding a brief parenthetical with the total: e.g., "(48 ADL + X nonlinearity + Y feedback + Z earlier dual-role scenarios = 300+ configurations)". | Verifiability | Minor (-2) |
| 6 | 604 | "$D_{it} = \alpha^D_i + \phi Y_{i,t-1} + \rho_D D_{i,t-1} + \gamma_D Z_{i,t-1} + u_{it}$" | The coefficient $\gamma_D$ was previously used on line 580 and in Corollary 2 (line 353) to refer to the association between D and Z in the collider equation, not the coefficient on $Z_{t-1}$ in the treatment equation. Consider using a distinct symbol (e.g., $\delta_D$ or $\kappa$) to avoid overloading $\gamma_D$. | Notation | Minor (-2) |
| 7 | 596 | "(i)~concave transformations ($\log(1 + |D|)$, soft-clamped polynomial), (ii)~polynomial terms ($D^2$), and (iii)~interaction terms ($D \times H$ with $H$ exogenous)." | Strictly, $\log(1 + |D|)$ is concave but NOT bounded from above (it grows without bound as $D \to \infty$). The next paragraph (line 598) draws a distinction between "bounded" and "unbounded" nonlinearities and places concave/saturating transformations in the "bounded" category. Logarithmic growth is extremely slow, so the practical claim is correct, but calling it "bounded" is technically imprecise. Consider: "slowly growing" or "sublinear" instead of grouping $\log(1 + |D|)$ with "bounded" transformations. | Precision | Minor (-2) |
| 8 | 580 | "treatment variables like democratization or peacekeeping deployment vary primarily across countries in levels, and their within-country variation is modest." | The claim that "democratization varies primarily across countries in levels" is slightly imprecise. Democratization is a *change* variable (transition from autocracy to democracy), so it varies primarily *within* countries over time. What varies primarily across countries in levels is the *treatment-collider association* (e.g., richer countries have both more democracy and higher GDP). The sentence should clarify that it is the D-Z and Y-Z associations that are primarily cross-sectional, not the treatment itself. | Precision/Clarity | Minor (-2) |
| 9 | 608 | "## Summary: When Is IVB Small?" | This subsection has no `\label{}`. If this section is cross-referenced elsewhere, it will produce a "??" in the PDF. No current cross-reference was found, but adding a label (e.g., `\label{sec:ivb_summary}`) would be good practice for future-proofing. | LaTeX | Minor (-2) |
| 10 | 602 | "This feedback violates the strict exogeneity assumption that underpins TWFE \citep{imai_kim2021}" | The strict exogeneity assumption underpins TWFE *without* lagged dependent variables. With an ADL specification (which includes $Y_{t-1}$), the relevant assumption is *sequential exogeneity*, as Imai & Kim (2021) themselves discuss. The sentence is not wrong (TWFE does require strict exogeneity), but since the next paragraph discusses how ADL *solves* this problem, the sentence could more precisely say: "This feedback violates the strict exogeneity assumption required by static TWFE" or "...that underpins TWFE without dynamic controls". | Precision | Minor (-2) |
| 11 | 610 | "And moderate feedback from outcomes to treatment ($Y_{t-1} \to D_t$) is absorbed by the ADL specification, with IVB remaining at approximately 1\% of $\beta$." | Beginning a sentence with "And" is stylistically informal for an academic paper. The rest of the paper avoids this construction. Consider: "Finally, moderate feedback..." or "Moreover, moderate feedback..." | Style | Minor (-2) |
| 12 | 908 | "...ADL specifications with lagged controls block collider paths and reduce bias to less than 3\% of $\beta$; bounded nonlinearities in the collider channel do not qualitatively change the IVB picture; and moderate outcome-to-treatment feedback is absorbed by the lagged dependent variable, keeping bias at approximately 1\% of $\beta$." | This sentence in the conclusion is 110+ words (the entire sentence starting "We identify five mechanisms" is even longer). Consider breaking it into two sentences after the semicoloned list, e.g., ending the first sentence at "...reduce bias to less than 3\% of $\beta$." and starting a new sentence: "Additionally, bounded nonlinearities..." | Style/Readability | Minor (-2) |
| 13 | 33 (abstract) | "Monte Carlo simulations across over 300 DGP configurations confirm that these conditions keep IVB below 3\% of the treatment effect." | Slight tension with the body text: Section 4.5 (line 604) reports "$|\text{bias}| \leq 1\%$ of $\beta$" for the ADL under feedback, and Section 4.3 (line 592) reports "less than 3\% of $\beta$" for ADL. The abstract uses "below 3\%", which is correct as an upper bound across all simulations but could mislead readers into thinking the typical bias is close to 3\%. Consider "below 3\%" with a qualifier: "typically well below 3\%". | Precision | Minor (-2) |
| 14 | 914 | "Our Monte Carlo simulations (Section~\ref{sec:mech_nl}) show that bounded nonlinearities in the collider channel preserve the formula's practical relevance---bias remains small---but unbounded nonlinearities can generate substantial deviations." | The parenthetical references only Section 5.4 (nonlinearity), but the limitations paragraph is discussing all the Monte Carlo results. Consider referencing the parent section: "(Section~\ref{sec:ivb_magnitude})" or "(Sections~\ref{sec:mech_adl}--\ref{sec:mech_feedback})". However, since this specific sentence is about nonlinearities only, the current reference is defensible. No change required, but flagged for consideration. | Cross-reference | Minor (-2) |
| 15 | 584 | "reducing the fraction of switchers from 70\% to 10\% increases the standard error by a factor of 2--3" | The phrase "a factor of 2--3" uses an en-dash, which is correct for ranges. However, elsewhere in the paper, ranges use "--" (e.g., "20--30 periods" on line 447). This is consistent. No issue. | --- | (no deduction) |
| 16 | 592 | "Across 48 scenarios ($N = 100$, $T = 30$, 500 replications)" | Note the change from the earlier simulations described in Section 5.2 (line 584) which use $N = 200$. The switch to $N = 100$ is not explained. Consider adding a brief note: "We use $N = 100$ (rather than 200) to..." or simply noting this is a different simulation design. | Consistency | Minor (-2) |
| 17 | 604 | "with $\phi \in \{0, 0.05, 0.10, 0.15\}$" | Using 0.10 (with trailing zero) is slightly unusual but not incorrect. The rest of the paper uses $0.5$, $0.95$, $0.77$, $0.13$ without trailing zeros. For consistency, consider $0.1$ instead of $0.10$. Very minor. | Formatting | Minor (-2) |

---

## Issues NOT Found (Verification)

The following potential issues were checked and found to be correct:

1. **Citation keys**: All `\citet{}`, `\citep{}`, and `\citealt{}` keys in the newly added sections (`imai_kim2021`, `ding2015adjust`, `blackwell2018make`, `cinelli2020making`, `cinelli2021crash`, `rogowski_etal2022`) exist in `references.bib`.

2. **Cross-references**: All `\ref{}` labels in the newly added sections point to existing `\label{}` targets:
   - `\ref{cor:ivb_twfe}` (line 344)
   - `\ref{sec:ivb_magnitude}` (line 572)
   - `\ref{sec:mech_nl}` (line 594)
   - `\ref{sec:caveats}` (line 551)
   - `\ref{app:classification}` (line 1049)

3. **"Five mechanisms" count**: Consistent across abstract (line 33), section intro (line 576), five subsections (5.1--5.5), Summary (line 608), and conclusion (line 908).

4. **"14 collider candidates" count**: Consistent across abstract (line 33), body (line 703), and conclusion (line 908).

5. **"0.13" median and "2.11 / 58%" outlier**: Consistent across abstract (line 33), body (lines 703, 885), and conclusion (line 908).

6. **"over 300 DGP configurations"**: Consistent across abstract (line 33), section intro (line 576), and conclusion (line 908).

7. **Math notation**: The new sections consistently use `$\beta$`, `$\theta^{\star}$`, `$\pi$`, `$\phi$` in LaTeX notation (not plain-text "beta", "theta*", etc.).

8. **Hyphenation**: Compounds like "outcome-to-treatment", "between-unit", "within-unit", "standard-error" are consistently hyphenated throughout.

9. **`\ref{tab:ivb-full-table}`** (line 1199): This resolves correctly because R Markdown with `kable()` auto-generates `\label{tab:chunk-name}` from the chunk name `ivb-full-table` when a caption is provided.

---

## Score Calculation

Starting score: **100**

| # | Category | Deduction |
|---|----------|-----------|
| 1 | Grammar (missing subject -- ungrammatical sentence) | -10 |
| 2 | Grammar (incomplete verb phrase) | -10 |
| 3 | Style/Clarity | -2 |
| 4 | Notation consistency | -2 |
| 5 | Verifiability | -2 |
| 6 | Notation consistency | -2 |
| 7 | Precision | -2 |
| 8 | Precision/Clarity | -2 |
| 9 | LaTeX practice | -2 |
| 10 | Precision | -2 |
| 11 | Style | -2 |
| 12 | Style/Readability | -2 |
| 13 | Precision | -2 |
| 14 | Cross-reference (flagged, no deduction) | 0 |
| 15 | (No issue) | 0 |
| 16 | Consistency | -2 |
| 17 | Formatting | -2 |

**Final Score: 100 - 10 - 10 - 2 - 2 - 2 - 2 - 2 - 2 - 2 - 2 - 2 - 2 - 2 - 2 - 2 = 56 / 100**

---

## Priority Recommendations

### Must Fix (Issues 1--2)

These are unambiguous grammar errors that would be caught by any reviewer:

1. **Line 76**: Restore the missing subject in "We show that is primarily cross-sectional..."
2. **Line 74**: Change "putting a collider" to "including a collider"

### Should Fix (Issues 4, 6, 8, 10, 16)

These are notation/precision issues that could confuse careful readers:

- **Issue 4 (line 592)**: Replace R-formula notation with LaTeX equation or prose description
- **Issue 6 (line 604)**: Use a distinct symbol for $\gamma_D$ in the treatment equation to avoid overloading
- **Issue 8 (line 580)**: Clarify that the D-Z association (not the treatment itself) varies across countries in levels
- **Issue 10 (line 602)**: Specify "static TWFE" or "TWFE without dynamic controls"
- **Issue 16 (line 592)**: Explain or acknowledge the switch from $N=200$ to $N=100$

### Consider (Issues 3, 5, 7, 9, 11, 12, 13, 17)

These are style and minor precision points that improve the manuscript but are not essential.
