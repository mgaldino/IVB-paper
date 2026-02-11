# Plano: Research Pipeline — IVB Paper

**Status**: COMPLETED
**Data**: 2026-02-10

## Objetivo
Executar o pipeline completo de revisão automatizada no paper IVB e seu código de simulação.

## Arquivos sob revisão
- `sim_ivb_completa.R` — código principal de simulação (477 linhas, 3 DGPs)
- `sim.R` — simulação básica cross-section (87 linhas)
- `ivb_paper_psrm.Rmd` — manuscrito principal (~61KB, targeting PSRM)

## Pipeline

### Estágio 1: Revisão de Código
- Revisar `sim_ivb_completa.R` e `sim.R`
- Rubrica: reprodutibilidade, robustez, estilo, boas práticas
- Threshold: Score ≥ 80

### Estágio 2: Devil's Advocate
- Estressar argumentos do manuscrito `ivb_paper_psrm.Rmd`
- Identificar vulnerabilidades lógicas, empíricas, de apresentação
- Threshold: Score ≥ 80

### Estágio 3: Proofread
- Gramática, typos, consistência no manuscrito
- Threshold: Score ≥ 90

## Verificação
- [x] Cada estágio salva relatório em `quality_reports/`
- [x] Relatório final consolidado em `quality_reports/pipeline_report_2026-02-10.md`
