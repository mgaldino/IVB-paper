# Pipeline Report — 2026-02-10

**Project**: Included Variable Bias (IVB) Paper
**Target Journal**: Political Science Research and Methods (PSRM)
**Authors**: Galdino, Moreira, Dolleans

---

## Estágio 1: Revisão de Código
- **Rounds**: 2/5
- **Score inicial**: 48/100 (REPROVADO)
- **Score final**: 92/100 (APROVADO)
- **Issues corrigidas**:
  - [Critical] Archived `sim.R` (undefined variable bug, incorrect formula, dead code) → `sim_DEPRECATED.R`
  - [Major] Documented working directory requirement for `ggsave()` relative paths
  - [Minor] Added comment explaining 200 vs 500 inner replications in section 2C
  - [Minor] Added header noting Rmd is authoritative source for paper results
- **Issues remanescentes** (non-blocking, -8 pts):
  - Inconsistent column naming between sim_ivb_completa.R and Rmd (Portuguese vs English)
  - Non-idiomatic `rowwise() + mutate()` pattern (functional but unusual)
  - A few lines exceeding 100 characters
  - Mixed-language comments (Portuguese in .R, English in .Rmd)

## Estágio 2: Devil's Advocate
- **Rounds**: 2/5
- **Score inicial**: 16/100 (REPROVADO)
- **Score final**: 83/100 (APROVADO)
- **Vulnerabilidades resolvidas**:
  - [Critical] Added "Related Work" subsection citing Greenland (2003), Ding & Miratrix (2015), Gaebler et al. (2024), Pearl (2013); articulated what is new
  - [Major] Reframed novelty: acknowledged formula follows from FWL, contribution is in packaging + TSCS extension
  - [Major] Expanded linearity limitation in Conclusion (FWL doesn't hold for logit/probit)
  - [Major] Added "Interpretation Caveats" subsection (formula is algebraic, causal interpretation requires DAG)
  - [Major] Added Nickell bias discussion for ADL models with fixed effects
  - [Minor] Fixed DAG timing (Dem_t → Dem_{t+1} for temporal consistency)
- **Vulnerabilidades remanescentes** (non-blocking, -17 pts):
  - Simulations validate algebraic identity rather than testing practical utility (reduced to -5)
  - "Foreign collider bias" concept underdeveloped (-2)
  - Appendix E (Potential Outcomes) superficial (-2)
  - No standard errors for IVB estimate (-2)
  - Missing additional citations for heuristics prevalence (-1)
  - All DGPs linear-Gaussian (-1)
  - One new minor issue from added text (-2)
  - Style issues (-2)

## Estágio 3: Proofread
- **Rounds**: 2/2 (verification rounds)
- **Score inicial**: 64/100 (REPROVADO)
- **Score final**: 91/100 (APROVADO)
- **Correções aplicadas**: 20 de 46 items propostos
  - [Critical] Fixed backdoor path description in Figure 3 caption (Dem_{t+1} is the collider, not CW_{t+1})
  - [High] Replaced 7 hard-coded section numbers with \ref{} cross-references
  - [High] Added Figure~\ref{} cross-references for Figures 1 and 3
  - [Medium] Added notation footnote mapping ADL symbols to cross-section symbols
  - [Medium] Replaced 3 instances of R formula notation (~) with proper equations
  - [Medium] Fixed non-chronological citation order
  - [Low] Added [sic] to grammatically incorrect direct quote
  - [Low] Fixed 5 style issues (informal register, ambiguous referents, awkward citation flow)
  - [Low] Removed 12 unused bibliography entries

---

## Score Final Consolidado

| Estágio | Score | Weight | Weighted |
|---------|-------|--------|----------|
| Code Review | 92 | 25% | 23.0 |
| Devil's Advocate | 83 | 50% | 41.5 |
| Proofread | 91 | 25% | 22.75 |
| **Total** | | | **87.25** |

## Status: APROVADO (≥ 80)

## Recomendação: **Circular para coautores / submeter a PSRM**

O paper está pronto para circulação. O código é reprodutível e correto. A argumentação foi fortalecida com related work, caveats de interpretação, e limitações honestas. O manuscrito foi revisado para consistência, cross-references, e estilo.

### Sugestões para futuras revisões (não-bloqueantes)
1. Adicionar simulações com DGP binário (logit) para testar robustez da fórmula
2. Adicionar simulações com fixed effects e Nickell bias
3. Derivar standard errors para o IVB via delta method
4. Fortalecer ou remover Appendix E (Potential Outcomes)
5. Adicionar mais citações sobre prevalência das heurísticas

---

## Arquivos de relatórios gerados
- `quality_reports/plans/2026-02-10_pipeline-ivb-paper.md`
- `quality_reports/stage1_code_review_round1.md`
- `quality_reports/stage1_code_review_round2.md`
- `quality_reports/stage2_devils_advocate_round1.md`
- `quality_reports/stage2_devils_advocate_round2.md`
- `quality_reports/stage3_proofread_round1.md`
- `quality_reports/stage3_proofread_round2.md`
- `quality_reports/pipeline_report_2026-02-10.md` (this file)

## Arquivos modificados
- `sim_ivb_completa.R` — added header comments (working directory, authoritative source, inner loop explanation)
- `sim.R` → `sim_DEPRECATED.R` — archived with deprecation notice
- `ivb_paper_psrm.Rmd` — related work section, novelty reframing, interpretation caveats, Nickell bias, linearity expansion, DAG fix, cross-references, notation footnote, style corrections
- `references.bib` — added 4 new entries (Greenland, Ding/Miratrix, Gaebler et al., Nickell), removed 12 unused entries
