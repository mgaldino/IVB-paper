# Registro de operações — triagem cega, Fase A

Diretório de trabalho: `/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper`.
Diretório de saída, abreviado abaixo como `OUT`: `quality_reports/execution/2026-09-15_refine_contribution/gate_01/review/applications/`.

Este registro discrimina operações efetivamente executadas; não é um script que reproduza o julgamento científico. Leituras adaptativas foram repetidas para evitar truncamento dos retornos. Nenhum comando abaixo executou modelos.

## Entradas e regras

- `pwd`.
- `rg --files -g 'AGENTS.md' -g 'CLAUDE.md' -g 'protocol*' -g 'plan.md' quality_reports .agents 2>/dev/null`.
- `shasum -a 256 quality_reports/plans/2026-09-15_refine_contribution/plan.md`; hash correspondeu ao recebido.
- `cat` de `gate_01/applications/protocol.md` e `protocol.json`.
- `rg -n -A 110 -B 12 'Gate 1|Gate 0|E1|E2|elegib|blind|cego|adjud'` no plano, seguido de `sed -n '66,140p'` para leitura das regras e Gate 1 sem depender do retorno truncado.
- `ls -l` dos três PDFs principais e `rg --files` nos três diretórios de candidatas. A listagem revelou nomes de resultados IVB, sem abrir seu conteúdo.

## Extração de documentos

- `mkdir -p OUT/source_extracts` e `command -v pdftotext` (executável `/opt/homebrew/bin/pdftotext`).
- `pdftotext -layout replication/candidate_papers/un-peacekeeping-and-democratization-in-conflict-affected-countries.pdf OUT/source_extracts/blair.txt`.
- `pdftotext -layout replication/candidate_papers/BallardRosa-ComingTerms-2022.pdf OUT/source_extracts/ballard_rosa.txt`.
- `pdftotext -layout replication/candidate_papers/Claassen_2020_AJPS_democracy_support.pdf OUT/source_extracts/claassen.txt`.
- `pdftotext -layout replication/candidate_papers/claassen_2020/codebook_support_democracy_ajps_correct.pdf OUT/source_extracts/claassen_codebook.txt`.
- `wc -l` das extrações, somente para tamanho dos documentos: 1443, 2214, 1321 e 1043 linhas, respectivamente.
- `rg -n` e `sed -n` nas extrações para localizar e ler teoria, definições, desenho, janelas, identificação, extensões e limitações. As faixas centrais foram: Blair, páginas PDF 1–11 e 16–18; Ballard-Rosa, linhas 1–1100 e 1605–1775; Claassen, linhas 116–480, 548–757, 930–970 e 1008–1055, além de buscas sobre mensuração e dependência. Referências e resultados que apareceram no mesmo trecho não serviram à classificação.
- Python utilizado apenas para leitura/organização de texto: `Path(...).read_text().split('\f')` e impressão de páginas com `lstrip()` em Blair. Tentativa inicial com `python` retornou `command not found`; repetição com `python3` funcionou. Uma tentativa de localizar linhas do codebook usando `splitlines()` deslocou contagens por causa dos form feeds; os localizadores foram reconferidos com `sed` e os relatos usam nomes dos verbetes/páginas.

## Código e documentação de replicação: somente leitura

- `cat replication/candidate_papers/peacekeeping/metadata.json`.
- `nl -ba replication/candidate_papers/peacekeeping/replication.do | sed -n '1,240p'`, buscas por `xtset`, `ctrl`, `cluster`, `vce`, `laggedDV` e leituras adicionais das linhas 285–394; chamadas principais localizadas nas linhas 446–462.
- `nl -ba replication/candidate_papers/peacekeeping/indvar_separate_ctrls.ado | sed -n '1,230p'`.
- `nl -ba 'replication/candidate_papers/ballard_rosa_2022/IO replication.do' | sed -n '1,280p'` (arquivo com 154 linhas).
- `cat replication/candidate_papers/claassen_2020/readme.txt`.
- `nl -ba replication/candidate_papers/claassen_2020/supdem_democracy_ajps_replication_correct.R | sed -n '1,275p'`; buscas por `pgmm`, `vcov`, `index`, `twosteps`, `effect=`, e leitura de 305–345.
- `python3` com módulo padrão `csv`, leitura somente da primeira linha de `Coming_to_Terms_data.tab` e `Support_democracy_ajps_correct.tab`, usando `next(csv.reader(f, delimiter='\t'))`. Os cabeçalhos foram registrados em `schema_headers.json`. Nenhuma linha de observação foi lida por esse comando; não foram inferidos tipos a partir de valores, calculadas frequências nem examinadas estatísticas de amostra.

## Gravação e verificação

- `apply_patch` para gravar relatório independente Markdown, JSON e este registro no diretório permitido.
- SHA-256 de todas as entradas utilizadas e entregas; manifesto estruturado gravado em `manifest_sha256.json`. O manifesto não contém seu próprio hash.
- Validação sintática dos JSONs e conferência mecânica de que `HOLD_DOCUMENTATION` corresponde a ao menos um critério `MISSING`, nenhum `FAIL`, e que principal/reserva permanecem nulas.
- A tentativa de validação com `jq empty` retornou `command not found`; os arquivos gravados foram então lidos por Python 3 com `json.load`, sem processamento empírico. A consistência das classes também foi conferida em JavaScript no orquestrador de ferramentas. Uma chamada JavaScript teve erro de sintaxe antes de executar qualquer operação e foi corrigida.

## Operações não executadas

Não houve R, Stata, regressões, extração de coeficientes estimados, IVB, shift, bootstrap, simulação, cálculos descritivos sobre as observações, downloads, instalação, alteração de fonte científica, commit ou publicação. Não houve abertura de relatórios, seleção ou fichas do implementador. As operações de escrita ficaram em `OUT`.
