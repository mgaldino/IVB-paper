# Plano: Pipeline de revisao — sim_ivb_twfe_v4

**Status**: APPROVED
**Data**: 2026-02-28

## Objetivo

Rodar pipeline simplificado (codigo-only) nos arquivos da simulacao v4:
- `sim_ivb_twfe_v4.R` (simulacao)
- `sim_ivb_twfe_v4_figures.R` (figuras)

Pergunta de pesquisa: quais fatores estruturais induzem IVB alto ou baixo em TWFE?

## Pipeline

### Estagio 1: Code Review (max 3 rounds)
1. Agente Reviewer avalia ambos os arquivos com rubrica quality-gates.md
2. Se score < 80 → Agente Implementador corrige
3. Re-review ate score >= 80

### Sem Estagio 2 (DA) nem Estagio 3 (proofread) — nao ha manuscrito

## Referencia
- v1 validado: sim_ivb_twfe.R
- Plano v4: quality_reports/plans/2026-02-28_sim-ivb-twfe-v4.md
