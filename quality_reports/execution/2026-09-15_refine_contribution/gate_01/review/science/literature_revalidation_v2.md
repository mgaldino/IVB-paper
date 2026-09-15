# Revalidação bibliográfica independente, rodada 2

Data: 2026-09-15. Revisor: `gate1_scientific_review`. Escopo: correções SCI-01–03 adjudicadas pelo coordenador como CONFIRMED, CONFIRMED e PARTIAL, respectivamente, e suas passagens dependentes.

**SCI-01, SCI-02 e SCI-03: reparos verificados, PASS nesse escopo.** Comparei os três novos arquivos com `review/snapshots/literature_round1/`, li integralmente os diffs e reli as passagens afetadas. Não houve alteração de álgebra, exemplos, regra de novidade ou extensão das fontes bibliográficas.

| Arquivo | SHA-256 recalculado |
|---|---|
| literature/reader_report.md | 554110c8664b04f25bde2758629dd564607a0ad05e6df39693d08c7bbd37d818 |
| literature/reader_claim_comparison.csv | bd4ac603ff321a74ae05129260ed8e09ca46b60e446cec4ebff8445aaa4b1336 |
| literature/reader_manifest.json | 75360ac300f85c97906def841864c119822385a6596f403324535eea6e755770 |

## Evidência dos reparos

- **SCI-01:** `reader_report.md:18–23` restaura `\\widehat` na convenção base−full e os delimitadores das definições. Os demais trechos matemáticos corrigidos no diff mantêm seus sinais e significado. Não foi renderizado PDF nesta revisão.
- **SCI-02:** `reader_report.md:100,218`, CSV L10 e manifesto Blackwell distinguem Eq.(17) na página 1072 da discussão de consistência na 1073. A correção corresponde à extração primária já conferida. CSV L10 também evita resumir a especificação com uma referência imprecisa a covariáveis correntes/defasadas.
- **SCI-03:** `reader_report.md:114,146` e CSV L12 agora fixam um alvo causal de referência e explicitam se cada coeficiente identifica esse alvo, outro estimando ou nenhum efeito causal identificado. A identidade descritiva permanece válida nesses três casos. A revisão resolve a ambiguidade sem exigir que endpoints distintos tenham interpretação causal idêntica.

## Observação editorial adicional candidata

**SCI-04, reader_report.md:161:** a frase descreve “dois deslocamentos grandes e de sinais opostos”, mas em seguida enumera adicionar Z a B e adicionar L a C, ambos para baixo. As duas inclusões B→U e C→U têm o mesmo sinal no E1; os passos B→U e U→C têm sinais opostos. A equação do relatório e a ficha estão corretas. Proponho apenas alinhar a prosa ao percurso: inclusão Z preservando L desloca para baixo, e retirada L de U desloca para cima. Achado candidato comunicado para adjudicação, sem alteração pelo revisor.

O status bibliográfico permanece “não liberado para afirmação de novidade”, pois o artigo integral de Gelbach não foi obtido. Esta revalidação não reivindica nova leitura integral dos PDFs, execução estatística ou aprovação global do Gate 1. A revisão numérica permanece REPAIR nos bytes da rodada 1 até novo freeze e revisão.
