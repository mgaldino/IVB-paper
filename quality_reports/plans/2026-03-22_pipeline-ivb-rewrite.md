# Pipeline: Revisão pós-reescrita do IVB Paper

**Status**: COMPLETED
**Data**: 2026-03-22

## Objetivo

Rodar pipeline de qualidade completo (code review → devil's advocate → proofread) na versão reescrita do paper após reframing para "Bad Controls in Dynamic Panels" / CET benchmark.

## Contexto

- Paper reescrito seção por seção segundo spec v3
- Edmans review já realizado (Contribution 6, Execution 7, Exposition 7)
- Correções pós-Edmans implementadas (duplicação, Nickell→appendix, terminologia)
- PDF compila sem erros (590K)

## Arquivos

- Manuscrito: `ivb_paper_psrm.Rmd` (código R embutido nos chunks)
- Dados: `replication/standardized_ivb_metrics.csv`, datasets de replicação
- Utils: `replication/ivb_utils.R`

## Estágios

1. **Code Review**: R chunks no Rmd (replicação, formatação de tabelas)
2. **Devil's Advocate**: Estressar o argumento do manuscrito
3. **Proofread**: Gramática, typos, consistência

## Thresholds

- Code: ≥ 80
- Devil's Advocate: ≥ 80
- Proofread: ≥ 90
