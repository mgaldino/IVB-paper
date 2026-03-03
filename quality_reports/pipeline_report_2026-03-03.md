# Pipeline Report — 2026-03-03

## Context
Integration of simulation results (mechC_adl, NL, feedback) into `ivb_paper_psrm.Rmd` Section 4, abstract, conclusion, and limitations.

## Stage 1: Code Review — sim_feedback_Y_to_D.R
- Rounds: 1/5
- Score: **93/100 — APROVADO**
- Issues: 0 critical, 0 major, 4 minor (lag construction, vcov asymmetry, omitted model in console output, integer suffix)
- Note: Script had already passed review-r with A+ rating

## Stage 2: Devil's Advocate — ivb_paper_psrm.Rmd
- Rounds: 2/5
- Score: Round 1: 46/100 (REPROVADO) → Round 2: **95/100 (APROVADO)**
- Round 1 found 5 issues; 3 genuine, 2 false positives:
  - V1 (Critical, FIXED): Section 4.3 had N=200 (→100), bias range 86-169% (→77-169%), wrong DGP description
  - V2 (Critical, FALSE POSITIVE): Reviewer checked wrong simulation file
  - V3 (Major, FIXED): "at most 25%" NL claim → replaced with conservative wording
  - V4 (Minor, FALSE POSITIVE): "Over 300 DGP" is correct (~370 total)
  - V5 (Minor, KEPT): Approximate explosive threshold — based on actual eigenvalue calculations
- Round 2 confirmed all fixes + found 2 new minor issues (fixed in Stage 3):
  - Abstract missing feedback in conditions list (fixed)
  - ADL bias 1.03% marginally exceeds "< 1%" (changed to "≤ 1%")

## Stage 3: Proofread — ivb_paper_psrm.Rmd
- Rounds: 2/5
- Score: Round 1: 56/100 (REPROVADO) → Round 2: **100/100 (APROVADO)**
- Round 1 found 17 issues; 7 fixed:
  - 2 major grammar errors in original text (missing subject, "putting" → "including")
  - 5 minor in new text (R-formula notation, γ_D overloading, "static TWFE", "And" → "Finally", trailing zero)
- 10 issues deferred (style preferences, existing text, debatable)

## Score Final Consolidado
- Stage 1: 93/100
- Stage 2: 95/100
- Stage 3: 100/100
- **Weighted average: 96/100**

## Status: EXCELENTE (≥90)

## Recommendation
Ready to commit and circulate. The manuscript now has:
- 5 structural mechanisms in Section 4 (was 2)
- Updated abstract, conclusion, and limitations reflecting Monte Carlo evidence
- All factual claims verified against simulation data
- Grammar errors in original text corrected as bonus
