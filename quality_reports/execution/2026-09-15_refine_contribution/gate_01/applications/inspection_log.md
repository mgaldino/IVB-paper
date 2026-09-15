# Log de inspeção e validação

## Fronteira

Esta frente leu documentação, fontes primárias locais já selecionadas e os pareceres/adjudicação da rodada 1. Escreveu somente `gate_01/applications/`. Não editou manuscrito, scripts, dados ou outputs. Não executou R, Stata, regressões, IVB, shifts, bootstrap, p-valores ou estatísticas substantivas dos dados. Não abriu novas candidaturas na correção.

## Sequência auditável original

1. Foram lidos `CLAUDE.md`, o Gate 1 do plano, o recibo de aprovação do Gate 0 e o roster do acervo.
2. **Nesse primeiro acesso, o roster exibiu colunas numéricas proibidas.** Isso ocorreu antes da escrita e do congelamento do protocolo.
3. `protocol.json` e `protocol.md` foram então escritos com E1–E7, classes e regras de parada/seleção e hasheados em `protocol_freeze.md`.
4. Depois do congelamento, foram lidas integralmente as três candidatas escolhidas e feitas as classificações da rodada inicial.
5. PDFs primários foram convertidos com `pdftotext -layout` para arquivos temporários em `/tmp`; os temporários não foram incorporados ao repositório.
6. Scripts primários foram lidos com `sed`, `rg` e `nl -ba`, somente para variáveis, timing, amostra, FE, lags e covariância.
7. Cabeçalhos TAB foram lidos sem observações. Metadados DTA foram acessados com `pandas.io.stata.StataReader.variable_labels()`; nenhuma linha foi carregada para análise.
8. SHA-256 das fontes foram calculados e registrados em `sources_manifest.csv`.

O protocolo foi congelado antes da classificação, mas não antes da exposição incidental ao roster. A sequência impede certificar cegamento estrito. Não há evidência de seleção intencional por resultados.

## Sequência de reparo da rodada 2

1. Foram lidos `applications/review_round1.md/json`, `application_adjudication_round1.json` e `coordinator_findings.md`.
2. Os três hashes congelados foram reconferidos antes da edição e mantidos inalterados.
3. As três fichas, `README.md`, `selection.md`, `archive_disposition.md`, `decision_log.md` e este log foram corrigidos.
4. Foi acrescentado `cet_correspondence_addendum.md`, datado depois da triagem/adjudicação e explicitamente não preespecificado.
5. Foram acrescentados `repair_round2.md` e `manifest_round2.json` para permitir revisão byte a byte.
6. Não foram relidos outros papers do acervo e não foram executados dados, R ou Stata.

## Incidentes técnicos originais, preservados

- `jq` não estava instalado; o JSON foi validado com a biblioteca padrão do Python.
- `pyreadstat` não estava instalado; a tentativa falhou antes de ler qualquer DTA. O fallback com `pandas.io.stata.StataReader` leu apenas metadados.
- Uma primeira chamada ao leitor Stata tentou um método `close()` inexistente após imprimir rótulos do primeiro arquivo; nenhum dado foi alterado.
- Alguns arquivos `.pdf` do acervo eram snapshots HTML e não foram usados como fonte primária das fichas.

## Cegamento e revisão independente

A concordância posterior fornece evidência adicional de que há fundamentos documentais para algumas conclusões. Ela não reconstrói o processo mental anterior, não valida a priorização do universo completo e não elimina possível influência dos números vistos. Foram preservadas as divergências sobre Ballard-Rosa e Claassen e a retratação do revisor quanto a E5 de Blair.

## Verificações finais desta correção

Executadas após a escrita dos artefatos correntes:

```text
protocol.json: SHA-256 congelado preservado
protocol.md: SHA-256 congelado preservado
protocol_freeze.md: SHA-256 preservado
JSON: protocol.json e manifest_round2.json válidos; 14 arquivos não circulares conferidos
CSV: sources_manifest.csv válido; 25 fontes e respectivos hashes conferidos
consistência: nenhuma principal/reserva CET; classes e adequação CET em campos separados
escopo: somente gate_01/applications/ nesta frente
execução empírica: nenhuma
resultado: todas as verificações passaram
```

Os bytes corrigidos exigem nova revisão independente. O implementador não autoaprova a rodada nem o Gate 1.
