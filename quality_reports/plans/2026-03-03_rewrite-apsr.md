# Plano: Reescrita do Paper IVB para APSR

**Status**: ON HOLD — Framing invalidado por resultados de simulacao (ADL da vies ≈ 0 em todos os cenarios, incluindo NL unbounded; BG ja mostraram beta_1 consistente no ADL)
**Data**: 2026-03-03

## Contexto

O paper IVB passou por uma grande mudança de framing. A contribuição central foi rearticulada:

**Antes**: "IVB = post-treatment bias = strict exogeneity violation — três perspectivas sobre o mesmo fenômeno"
**Agora**: "Ninguém percebeu que controles defasados em TSCS podem ser colliders que viésam o CET. O ADL resolve sob linearidade. NL unbounded é o limite."

A revisão de literatura (quality_reports/lit_review_collider_bias_tscs.md) confirmou que a claim é **nova**: nenhum paper anterior articulou que incluir Z_{t-1} como controle em TSCS, quando Z é causado por D e Y, abre um caminho collider que viésa o CET.

O paper atual (~22,000 palavras, 1238 linhas) é longo demais para APSR (<12,000 palavras). Precisa de reescrita substancial com o novo framing.

## Target: APSR

- **Limite de palavras**: <12,000 (texto + notas de rodapé + referências)
- **Abstract**: ≤150 palavras
- **Formato**: 12pt, double-spaced, footnotes (não endnotes)
- **Online appendix**: Permitido e encorajado para derivações e simulações detalhadas

## Nova Estrutura Proposta

**Elevator pitch**: "Todo mundo sabe que omitir variáveis gera viés. Ninguém percebeu que incluir variáveis defasadas como controle em painel — prática universal em CP — pode gerar viés por abrir um caminho collider. Derivamos uma fórmula fechada para esse viés, mostramos que o ADL o resolve sob linearidade, e demonstramos que nas aplicações típicas o viés é negligível. O limite é não-linearidade forte na equação do collider."

### Word Budget (~10,500 palavras corpo + ~1500 referências)

```
Abstract                                            150 palavras
1. Introduction                                   1,200 palavras
2. Lagged Controls as Colliders in TSCS           1,500 palavras
3. The IVB Formula                                2,500 palavras
4. The ADL Solution and Its Limits                1,800 palavras
5. Empirical Applications                         2,500 palavras
6. Conclusion                                       800 palavras
                                         Total: ~10,450 palavras
Online Appendix: derivações, MC details, classificação de controles
```

### Detalhamento por Seção

(Ver plano completo no plan file)

## Ordem de implementação

1. Abstract + Introduction (novo framing)
2. Sections 2-4 (core teórico, condensar/reescrever)
3. Sections 5-6 (empírico + conclusão)
4. Appendix + polish + word count check
