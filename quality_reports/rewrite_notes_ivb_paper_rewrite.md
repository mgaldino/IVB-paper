# Editorial Notes: Introduction Rewrite v3

**Original file**: `ivb_paper_rewrite.Rmd`
**Date**: 2026-03-27 (v3)

## Diagnosis of v2

V2 was structurally sound and the author approved it. The problems are at the sentence level: (1) Paragraph 1 ends with a list of variables that reads like padding. (2) Paragraph 3 has a near-repetition ("mirror image of OVB" restated two sentences later). (3) Paragraph 4 is overloaded with six distinct points in one block. (4) "SCM, SDiD, and related methods" uses undefined acronyms. (5) Roadmap paragraph names section labels rather than content.

## Changes from v2

1. **Paragraph 1 split.** The list of variables (GDP, trade, aid...) moved to the start of paragraph 2 where it serves as the bridge from the specific example to the general problem. The first paragraph now ends cleanly on the dilemma statement. "The same tension arises with..." became "This is not a special case." followed by the list. Sharper transition.

2. **Paragraph 2 tightened.** Added "the decision can move the point estimate" to make the stakes concrete before stating the gap. Removed "defended informally in footnotes or robustness tables" (too specific a claim about current practice without evidence).

3. **Paragraph 3 (formula) compressed.** Removed "The formula is the mirror image of OVB:" because the next sentence already says "Where OVB measures... IVB measures..." One statement of the mirror, not two. Changed "omitted variable bias, or over-control of a mediator" to "confounding removal, or over-control of a mediator" to avoid using the term "omitted variable bias" in two different senses within one paragraph.

4. **Paragraph 4 (adaptive weights) restructured.** Removed "SCM, SDiD, and related methods" at the end (undefined acronyms). Replaced "The Reweighting Effect has no analogue in standard regression estimators and arises specifically from the adaptive weighting in SCM, SDiD, and related methods" with nothing (the point was already made by "which captures weight distortion from covariate inclusion"). Three sentences cut, zero information lost.

5. **Paragraph 5 (applications) compressed.** Merged "For each study, we identify..." into the first sentence. Replaced "The applications illustrate" with "The applications show."

6. **Roadmap compressed.** Replaced section-label references ("TWFE, and ADL models") with content descriptions. Shorter.

## What was preserved

- Opening question and peacekeeping example (paragraph 1, near-verbatim)
- Gap statement and OVB comparison (paragraph 2)
- IVB formula with equation (paragraph 3)
- Conditional parallel trends framing for adaptive-weight estimators (paragraph 4)
- Applications preview (paragraph 5)
- Roadmap (paragraph 6)

## Anti-LLM check

- Em dashes: 0
- Pivot words (however, indeed, crucially, etc.): 0
- Contrastive formulas ("not X but Y"): 0
- Generic smart phrases: 0
- Performative paragraph endings: 0 (each paragraph ends on a concrete claim or transition)
- Bold emphasis: 0
- Symmetry triads: 0

## Points for author verification

1. **"This is not a special case."** Direct and short. Verify this tone is appropriate for the target journal (PA/PSRM).

2. **"the decision can move the point estimate"** replaces "defended informally in footnotes or robustness tables." The original was more vivid but also more assertive about current practice. Verify preference.

3. **Removal of "SCM, SDiD, and related methods" from paragraph 4.** The acronyms were undefined in the intro. If the author wants to name the estimators explicitly, they should be written out (synthetic control method, synthetic difference-in-differences). Alternatively, "estimators with adaptive weights" covers them all without acronyms.

4. **"confounding removal" vs "omitted variable bias"** in paragraph 3. Changed to avoid using OVB in two senses (the formula name and a type of bias). Verify the rewording preserves the intended meaning.
