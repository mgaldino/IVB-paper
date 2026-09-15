# Gate 1 — revisão pontual do reparo editorial R2-N01

**Veredicto: PASS técnico delimitado.** O localizador de Blair foi corrigido para a p. 1323, os deltas são os esperados, os 16 artefatos do manifesto correspondem aos hashes e a proveniência histórica de S41 está resolvida. Não há achado material remanescente neste reparo.

Data: 15/09/2026. Revisor: `gate1_application_review`. Esta revisão encerra apenas R2-N01 e verifica a integridade de seus arquivos dependentes. Não reabre a triagem, não aprova uma aplicação CET e não decide o Gate 1 global.

## Identidade e deltas verificados

| Artefato | SHA-256 atual conferido |
|---|---|
| `applications/manifest_round3.json` | `c3a996aea6eab960e1c4000deabe999689726025eb91aa96c91bb7f5f88f12cb` |
| `applications/candidate_blair_peacekeeping.md` | `234a81c359dbec46f8a73f2f33b736cf37d6fb6f2b5244782196ebaa2d044dd3` |
| `applications/sources_manifest.csv` | `397c2283963f72f15c159d28ccd53d8e569a9c847279d2dbf96b379f8f1233bb` |
| `applications/repair_round3.md` | `8f59530fa4a6e8e483af4647fd29d715658f536045892d769e15efe1f0a08e55` |
| `applications/manifest_round2.json`, histórico | `ea3140977b67f4d6a485a8ed9be8ac255d1e7743e11d7ef8c6bc801acc32ffe0` |

A comparação com `review/snapshots/applications_round2/` confirmou por igualdade textual após substituição única:

- Ficha Blair: somente `(p. 1324)` → `(p. 1323)`.
- CSV: somente o localizador de S10, `article pp. 1314-1318 and 1324` → `article pp. 1314-1318 and 1323`.

O trecho sobre respostas no primeiro ano ou um/dois anos depois está em `review/applications/source_extracts/blair.txt:1215–1223`, na página impressa 1323, indicada ao final da página, linha 1250. O hash da extração também corresponde ao manifesto: `8e1d6e11cae074e063760405eeccf79e3ddb084104388edcaad1a0023449b995`. O reparo corrige a localização, sem alterar a interpretação do horizonte.

O README corrente foi lido: suas mudanças indexam a rodada 3 e preservam a rodada 2 como histórica. A matriz de classificação, as limitações do CET e a cronologia do cegamento permanecem iguais às verificadas na rodada anterior.

## Integridade e preservação

- **16/16 hashes** do manifesto da rodada 3 correspondem aos arquivos correntes; o inventário é completo, com exclusão apenas do próprio manifesto de seu auto-hash.
- Os três arquivos preservados no snapshot da rodada 2 correspondem ao manifesto do snapshot.
- `manifest_round2.json` permanece intacto no diretório corrente e é idêntico à cópia histórica.
- Onze artefatos constantes do manifesto da rodada 2 que não receberam edição continuam com os mesmos hashes: protocolos JSON/Markdown, recibo, seleção, disposição do acervo, fichas Ballard-Rosa e Claassen, adendo CET, logs de decisão/inspeção e nota de reparo da rodada 2.
- Na ficha Blair, a comparação textual exata garante que a classificação e E5 não mudaram. Na seleção e demais fichas, a identidade de bytes preserva a decisão já revisada: Blair elegível literal, Ballard-Rosa e Claassen em HOLD, nenhuma principal/reserva CET aprovada.

## S41: fonte histórica localizável, sem alegação de hash atual

S41 registra o hash observado na rodada 2 de `review/coordinator_findings.md`. O arquivo vivo recebeu conteúdo posterior. A nota `applications/repair_round3.md`, seção “Relação com a rodada 2”, declara expressamente que S41 é histórico e limita a validação corrente; não apresenta o digest como hash atual do registro vivo.

O coordenador preservou os bytes correspondentes em:

`review/snapshots/coordinator_findings_before_round2_closure.md`

SHA-256 conferido: `403bdee60b1893e6c8a3ac782d55aeea84521b5a3f6693210533b98ff2b4e31d`, **exatamente o digest S41**. A resolução está registrada em `review/historical_source_resolution.json`, SHA-256 `17764bc215bc10a5c4fc6d3aaf6f3065032672af4e859592346eaa43a2b12169`, com caminho vivo, caminho preservado, método de recuperação do prefixo anterior e escopo histórico.

Portanto, a cobertura correta é **24 fontes correntes com hashes correspondentes + uma fonte histórica S41 com bytes recuperados e hash correspondente**. Não se afirma que as 25 fontes apontem todas para arquivos vivos ainda idênticos. Não é necessário atualizar recursivamente manifestos a cada acréscimo ao registro vivo; o snapshot e a resolução fornecem a referência estável pertinente à rodada avaliada.

## Verificações executadas e encerramento

Executados somente leitura pontual dos documentos, extração textual já existente, SHA-256, parsing JSON/CSV e comparações de bytes/texto em Python. Os datasets e o roster foram processados apenas como bytes para hashes, sem exibir valores. Escrita limitada a `review/applications/review_round3.md` e `.json`.

Não houve R, Stata, regressão, shift, análise empírica, nova candidatura ou revisão exaustiva repetida. Este PASS não acrescenta evidência sobre identificação, amostra comum, suporte, inferência ou adequação ao CET.

**R2-N01 encerrado tecnicamente.** Mantém-se o resultado científico-documental anterior: nenhuma aplicação principal/reserva CET aprovada. O congelamento global e a decisão do Gate 1 permanecem com o orquestrador. Fase encerrada após esta entrega.
