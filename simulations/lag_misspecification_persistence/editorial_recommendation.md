# Recommendation for later editorial integration

This is a proposed insertion for the separate manuscript-integration task. It does not modify the paper.

## Candidate main-text sentence

“The ADL(1) benchmark is therefore a conditional baseline: when treatment is persistent or direct treatment carryover and outcome dynamics extend beyond one period, the required pretreatment history must include a lag structure supported by substantive timing and diagnostic evidence rather than be fixed mechanically at one lag.”

## Candidate scope-condition table row

| Scope condition | Diagnostic evidence | Consequence if not credible | Reporting location |
|---|---|---|---|
| Sufficient dynamic history | Substantive timing, residual serial correlation, and pre-specified AIC/BIC lag-selection sensitivity | ADL(1) can omit persistent outcome or treatment carryover; its coefficient need not recover the CET | Main text: compact scope table; appendix: full Task 14 grid |

The main text should not say that AIC or BIC validates the causal timing. They are empirical diagnostics for conditional-mean lag order, reported separately, while substantive timing determines whether the candidate lag vector is pre-exposure history.
