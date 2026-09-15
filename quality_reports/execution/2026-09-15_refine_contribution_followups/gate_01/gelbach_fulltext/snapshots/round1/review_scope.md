# Escopo do confronto e decisões preservadas

Este é um complemento bibliográfico localizado ao Gate 1. Não é nova revisão transformativa do manuscrito. Seu argumento e seu contrato continuam sujeitos aos registros aprovados do Gate 0; os 17 arquivos de entrada mantêm os hashes originais. O relatório do leitor é confrontado com a fonte primária e com a ficha abaixo, não usado como substituto delas.

## Entradas governantes

| Entrada | SHA-256 |
|---|---|
| Gelbach (2016), PDF de 35 páginas | `77392b7b09815f291f0ca55aa965786c59c4ca46a9ac1da44df0395dff96de2f` |
| Plano autorizado | `d2d2ea2e39102ab4193ee2f82b12b0823143867a23750c38d626aa4797eb7f5d` |
| Ficha do teste, versão 2 | `37562fccf615793d0b589b58303e0afeb225edd73ea85e44a7bb1b7688be7097` |
| Decisão histórica do Gate 1 | `f4eb96cb79d35535d159e2e90ef14c5f387fe54a834d498a7b0eb16f911fd7b3` |

Os caminhos das entradas antigas partem de `quality_reports/`: `plans/2026-09-15_refine_contribution/plan.md`, `execution/2026-09-15_refine_contribution/gate_01/contribution/test_prespec_v2.md` e `execution/2026-09-15_refine_contribution/gate_01/decision.md`. O PDF está em `sources/` neste pacote.

## Critérios do confronto

1. Confirmar identidade e cobertura da fonte. Distinguir leitura integral do leitor, cobertura localizada do revisor e inspeção do coordenador. Leitura de uma tabela não é reprodução empírica.
2. Distinguir identidade amostral, alvo de projeção populacional, teoria inferencial e interpretação causal. Conferir sinais, bases das auxiliares e localizadores no PDF quando a extração perder símbolos.
3. Preservar literalmente as operações, dados, regras e limites da ficha v2. C+ já estava autorizado a executar regressões intermediárias, aplicar as mesmas hipóteses causais e usar a mesma covariância conjunta. O novo acesso não reespecifica o teste depois de ver seus resultados.
4. Atribuir ao artigo o que ele apresenta. As duas aplicações com bases B e C e a covariância entre os respectivos contrastes são deduções para o teste; não se confundem com a alocação única de Gelbach em uma base comum. OLS sem pesos delimita o teste antigo; IV e outras generalizações são conteúdo bibliográfico para uma eventual proposta futura.
5. Preservar timing reconhecido na nota 3, limites de causalidade, quatro termos de covariância e degenerescência da nota 14. Não converter robust/cluster, IV ou Hausman em garantias fora das condições pertinentes.
6. O artigo pode alterar a atribuição ou o diagnóstico de novidade. Uma discordância deve ser examinada contra a fonte, sem exigir que o leitor ratifique a decisão anterior. O critério global do Gate 1 continua exigindo ganho demonstrável e aplicação viável; a nova leitura isolada não aprova esses critérios.

## Autoria, revisão e decisão

`gelbach_full_reader` produz a leitura integral e corrige seus próprios arquivos após adjudicação. `gelbach_full_review` congelou primeiro sua síntese independente, sem ler os novos produtos, e só depois confronta os bytes recebidos. O coordenador prepara o adendo, recebe revisão independente e adjudica findings como CONFIRMED, PARTIAL, REFUTED ou UNRESOLVED. O revisor não implementa reparos.

**Decisão preservada do autor:** implementação interna do plano autorizada. Nenhuma nova rota científica escolhida nesta complementação. A chegada do PDF resolve a solicitação de fonte; não responde à escolha entre contribuição aplicada/pedagógica, extensão específica, ferramenta operacional ou suspensão. Não é necessária autorização rotineira adicional para ler, documentar, corrigir o registro e renderizar o adendo.
