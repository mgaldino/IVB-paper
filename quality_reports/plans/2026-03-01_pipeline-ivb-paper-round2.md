# Plano: Pipeline de qualidade — IVB Paper (Round 2 pós-reestruturação)

**Status**: COMPLETED
**Data**: 2026-03-01

## Contexto

O DA Round 1 (28/Feb, score 62/100) identificou 13 vulnerabilidades. As mudanças implementadas em 01/Mar endereçaram diretamente:
- **Issue #4c** (diluição por controles irrelevantes): tabela-resumo agora mostra apenas ~14 collider candidates
- **Issue #6** (todos controles como colisores sem justificativa): DAG-based classification por estudo, Appendix F
- **Issue #7** (Claassen 104% enganoso): métrica dupla IVB/SE + IVB/β, "—" quando β n.s.
- **Issue #4b** (narrativa "typically modest" muito forte): conclusão e abstract atualizados com linguagem calibrada

Outras issues do DA Round 1 NÃO foram endereçadas nesta rodada (por design ou porque requerem trabalho futuro):
- Issue #1 (trivialidade da fórmula) — defesa já presente no paper, não foi alvo desta rodada
- Issue #2 (simulações v4 não-validadas) — pipeline de v4 separado
- Issue #3 (nenhum critério operacional colisor vs. confounder) — parcialmente endereçado pelo Step 0 + Appendix F
- Issue #5 (foreign collider bias mal definido) — não foi alvo desta rodada

## Pipeline

### Estágio 1: Code Review (novo código R nos chunks)
- Foco: chunks `ivb-summary-table` (redesenhado), `ivb-full-table` (novo, Appendix F), `leipziger-ivb-table` (com IVB/SE), `rogowski-ivb-table` (com IVB/SE)
- Verificar: lógica de filtragem collider_candidates, cálculo de significância, formatação IVB/β como "—"

### Estágio 2: Devil's Advocate (re-review pós-mudanças)
- Re-avaliar issues #4, #6, #7 do DA Round 1 — foram resolvidas ou são band-aids?
- Avaliar se as novas classificações DAG são defensáveis
- Verificar se a métrica dupla IVB/SE + IVB/β é coerente em todo o paper
- Verificar se o Appendix F é completo e útil

### Estágio 3: Proofread
- Consistência de notação (IVB/SE vs |IVB|/SE, etc.)
- Referências cruzadas (\ref{app:classification})
- Novas citações (bermeo2016, hibbs1977, alesina1987, sargent_wallace1981)
- Gramática do texto novo

## Ordem de execução

1. Stage 1 (code review) e Stage 2 (DA) em paralelo — são independentes
2. Stage 3 (proofread) após ambos completarem
