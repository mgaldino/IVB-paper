# Nota de reparo editorial — aplicações, rodada 3

**Data:** 15 de setembro de 2026  
**Achado:** `R2-N01`, confirmado pela coordenação  
**Estado:** correção entregue para revisão pontual independente; sem autoaprovação

## Problema e evidência

A passagem de Blair sobre respostas “no primeiro ano” ou “um ou dois anos depois” estava localizada na p. 1324 em dois registros. A extração primária `gate_01/review/applications/source_extracts/blair.txt:1190–1250` mostra a passagem nas linhas 1215–1223 e o número de página 1323 na linha 1250.

## Correções delimitadas

| arquivo | antes | depois |
|---|---|---|
| `candidate_blair_peacekeeping.md` | passagem localizada na p. 1324 | passagem localizada na p. 1323 |
| `sources_manifest.csv`, fonte S10 | `article pp. 1314-1318 and 1324` | `article pp. 1314-1318 and 1323` |
| `README.md` | índice apontava o manifesto da rodada 2 como corrente | índice aponta `manifest_round3.json`; a rodada 2 permanece histórica |

Não houve alteração de protocolo, fonte primária, classe de elegibilidade, adequação CET, seleção, decisão ou interpretação. Nenhum outro registro histórico foi editado.

## Relação com a rodada 2

- `manifest_round2.json` permanece no lugar, sem mudança, SHA-256 `ea3140977b67f4d6a485a8ed9be8ac255d1e7743e11d7ef8c6bc801acc32ffe0`.
- Os bytes anteriores dos dois arquivos corrigidos e do manifesto estão preservados em `gate_01/review/snapshots/applications_round2/`.
- `manifest_round3.json` registra o inventário corrente, os deltas de hash e sua relação com o manifesto anterior.
- S41 em `sources_manifest.csv` conserva o hash do `coordinator_findings.md` observado na rodada 2. O arquivo vivo recebeu bytes posteriores em outras frentes; seu hash não foi atualizado neste reparo editorial delimitado. A validação corrente do CSV cobre estrutura, identidade do PDF S10 e o localizador corrigido.

## Fronteira de execução

Foram usados apenas leitura textual, correção dos localizadores, SHA-256, validação estrutural de JSON/CSV e inspeção de diff. Não houve R, Stata, regressão, IVB, shift ou análise de dados. A rodada requer revisão independente dos bytes corrigidos.
