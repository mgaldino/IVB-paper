# Resultado da execução dos exemplos do Gate 1

**Estado atual:** execução concluída com retorno zero e marcador final PASS; revisão independente dos outputs concluída com PASS. O README e `source_manifest.json` desta pasta registram a preparação congelada anterior à execução. Este documento registra o estado posterior.

## O que foi executado

Em 15/09/2026, às 12:42:58 UTC, o coordenador executou uma vez:

```bash
Rscript --vanilla quality_reports/execution/2026-09-15_refine_contribution/gate_01/numerical/verify_examples.R
```

A revisão R independente da rodada 2 recebeu PASS antes da execução. O código executado tem SHA-256 `98b4fbc20bdce3d03eaae7e1828a34a2c37e1e07c7f46cb848cc32131aff7127`; a adjudicação prévia está em `execution_authorization.json`, e o console integral em `execution_console.txt`.

## Resultados observados

- Quatro células de E1 e dois sistemas de E2 preservados.
- 168 verificações gerais registradas com PASS.
- Tabela de projeções com 106 valores reportados conferidos contra a álgebra; outras 20 linhas são campos omitidos por C0, sem penalidade.
- 20 verificações de transformação de covariância, todas dentro da tolerância.
- Maior erro absoluto de projeção: aproximadamente $6,66\times10^{-16}$; maior diferença de covariância: $5,55\times10^{-17}$. A tolerância especificada é da ordem de $10^{-10}$, escalada pelo valor de referência.
- Todas as ações pontuadas concordam com o oráculo congelado; P e C+ têm os mesmos valores e ações. Certificados causais são entradas analíticas previamente derivadas, não inferências descobertas a partir do fixture.
- E2 produz efeito sob intervenção igual a 2 em G_M e 1 em G_F, com a mesma matriz observável e deslocamento −1.

Essas contagens se referem a tabelas e verificações do mesmo teste; não são números de amostras ou repetições de Monte Carlo e não devem ser somadas como unidades independentes de evidência.

## Integridade das saídas

O marcador autoritativo é `results/primary/final_status.txt`, gravado depois das saídas obrigatórias. Ele identifica o manifesto SHA-256 `aedc8deff4e1b3ea99aa3bd7c21da3d98932d146b8e2e6a2900ff610f08a7cdc`. Os 16 arquivos cobertos por `output_manifest.csv` tiveram tamanho e hash reconferidos pelo coordenador. O manifesto exclui a si mesmo e o marcador final para evitar autorreferência; ambos serão incluídos no congelamento global do gate.

O runtime R avisou que configurações de locale não estavam disponíveis e usou locale C. Os avisos estão preservados no console. A rotina de hashing corrigida usa locale C no subprocesso e completou sem a falha prevista na primeira revisão. `sessionInfo.txt` registra o ambiente efetivo.

## Revisão independente dos resultados

O revisor conferiu os 16 hashes e tamanhos, as projeções, ações, perdas, gradientes e matrizes por fórmulas fechadas próprias, sem repetir R ou ajustar novamente OLS. A [revisão pós-execução](../review/science/postexecution_review.md) recebeu PASS e acompanha um script de auditoria reproduzível. O maior erro frente às projeções calculadas independentemente foi $9,99\times10^{-16}$; para as matrizes, $9,71\times10^{-17}$.

Em E2, os dois conjuntos finitos têm segundos momentos iguais e momentos superiores diferentes. Seus valores HC0 são 1/4 e 1/8, respectivamente. A equivalência P/C+ é verificada dentro de cada conjunto, sobre as mesmas linhas. A equivalência observacional refere-se às populações gaussianas da prova; os conjuntos determinísticos não são amostras dessas populações. Nenhuma igualdade entre HC0 de conjuntos diferentes é exigida.

## Limites para uso

Este resultado verifica a implementação das identidades e decisões nos exemplos determinísticos especificados. Não foram executados Monte Carlo, bootstrap, estimação com dados reais ou validação de cobertura. A saída não demonstra ganho humano, nova identificação causal ou novidade metodológica. Os ramos de falha foram inspecionados estaticamente; não foram exercitados por injeção de falhas nesta execução bem-sucedida.

A interpretação científica continua sendo a equivalência do procedimento testado com o comparador forte no domínio declarado. A decisão de avanço do Gate 1 é separada do PASS computacional.
