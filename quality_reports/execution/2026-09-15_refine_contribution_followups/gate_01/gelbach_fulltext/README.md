# Gelbach integral: complemento ao Gate 1

## Resultado e estado

**Fonte identificada, leitura integral concluída e incorporação encerrada após revisão independente.** O autor indicou `683668.link.pdf` na pasta Downloads. É Jonah B. Gelbach (2016), *When Do Covariates Matter? And Which Ones, and How Much?*, *Journal of Labor Economics* 34(2), pp. 509–543, DOI 10.1086/683668. O PDF tem 35 páginas e SHA-256 `77392b7b09815f291f0ca55aa965786c59c4ca46a9ac1da44df0395dff96de2f`.

O resultado revisado mantém o **Gate 1 não aprovado**, pois a rotina testada não demonstrou ganho sobre o comparador forte e a triagem não estabeleceu aplicação CET. A pendência bibliográfica está resolvida. A ficha v2, as regras do teste, as hipóteses comuns e as análises já executadas permanecem. A escolha de nova rota continua reservada ao autor. O [estado corrente](current_state.json) separa esses critérios.

O parecer final deu **PASS documental** e verificou o fechamento de dois reparos: esclarecer a atribuição bibliográfica sem sugerir ampliação posterior de C+; corrigir o localizador da identidade populacional de eq. (4) para eq. (3). Os registros anteriores e seus bytes permanecem disponíveis. Esse PASS não aprova a contribuição científica.

## Documentos para retomar o trabalho

| Documento | O que permite rastrear |
|---|---|
| [Adendo em PDF](gelbach_addendum.pdf) e [fonte](gelbach_addendum.md) | Síntese do que o artigo estabelece e efeito sobre a avaliação da contribuição |
| [Relatório integral](reading/full_read_report.md) | Leitura fiel seguida do confronto com a literatura e a rotina anteriores |
| [Cobertura por página](reading/page_coverage.csv) | As 35 páginas, incluindo tabelas, notas, apêndices A–D e referências; 22 páginas com conferência visual |
| [Matriz de claims](reading/claim_comparison.csv) | Comparação L01–L17, com localizadores e limites de atribuição |
| [Manifesto do leitor](reading/read_manifest.json) | Fonte, entradas anteriores, comandos, cobertura, saídas e hashes |
| [Leitura independente inicial](review/independent_source_read.md) | 29 páginas textuais e 12 visuais examinadas antes do novo relatório, com derivação própria |
| [Escopo da revisão](review_scope.md) | Critérios, ficha preservada e decisões que pertencem ao autor |
| [Congelamento para a primeira revisão](review_input_freeze_round1.json) | Sete artefatos revistos e cópias recuperáveis em `snapshots/round1/` |
| [Primeira revisão](review/review_round1.md) e [adjudicação](adjudication_round1.md) | Dois findings, evidência, classificação e encaminhamento aos autores dos arquivos |
| [Revisão final](review/review_round2.md) e [fechamento da adjudicação](adjudication_round2.md) | Reparos CLOSED_VERIFIED, ausência de novos findings e limites do PASS documental |
| [Segundo congelamento](review_input_freeze_round2.json) | Doze artefatos após os reparos, com cópias recuperáveis em `snapshots/round2/` |
| [Verificação documental](verification.json) e [QA visual](visual_qa.json) | Integridade da fonte, leitura registrada, snapshots, build, preservação da base e inspeção das três páginas do adendo |
| [Manifesto final](delivery_manifest.json) | Hash e tamanho de cada arquivo desta complementação, inclusive fontes e versões anteriores |
| [Aquisição](acquisition.json) | Arquivo original, cópia idêntica, identificação e momento em que o acesso foi resolvido |

`sources/` preserva o PDF, a extração textual e o mapa de páginas. O leitor integral é `gelbach_full_reader` (Sol xhigh); o revisor é `gelbach_full_review` (Astra high); o coordenador escreve o adendo e adjudica os findings. O revisor não implementa correções.

## Relação com a entrega anterior

A [entrega original](../../../2026-09-15_refine_contribution/README.md) continua como snapshot histórico. Seus 194 arquivos e os 17 arquivos de base foram conferidos sem alteração. A [decisão anterior do Gate 1](../../../2026-09-15_refine_contribution/gate_01/decision.md) registra as opções científicas e os resultados que motivaram a decisão do autor. As notas individuais dos Gates 2–7 seguem naquele pacote.

As frases de acesso/leitura pendente da entrega original descrevem a situação anterior ao fornecimento deste PDF. O `full_read_status` de `acquisition.json` é o estado no momento da aquisição; não é o estado final da complementação. O primeiro README foi preservado em `snapshots/acquisition/README.md`. As revisões e os registros finais acrescentados a este índice informam a situação corrente sem reescrever o histórico.

Da mesma forma, os estados de espera por revisão nos manifestos do leitor e nos registros de reparo descrevem o momento em que foram entregues ao revisor. Seu fechamento está no parecer da rodada 2 e em `current_state.json`. A atualização de estado, este índice e o manifesto final são registros posteriores do coordenador; não se apresentam como arquivos antecipadamente revistos pelo parecer, nem alteram os produtos cujos hashes ele verificou.

## Reprodução documental

Execute a partir da raiz do repositório:

```sh
python3 quality_reports/execution/2026-09-15_refine_contribution/build_delivery_manifest.py --verify
python3 quality_reports/execution/2026-09-15_refine_contribution/validate_execution.py
python3 quality_reports/execution/2026-09-15_refine_contribution_followups/gate_01/gelbach_fulltext/verify_documents.py
python3 quality_reports/execution/2026-09-15_refine_contribution_followups/gate_01/gelbach_fulltext/build_manifest.py --verify
```

Os comandos verificam os artefatos salvos e não executam análises. `render_addendum.py` reproduz apenas o PDF do adendo a partir de Markdown usando Pandoc e XeLaTeX; versões, comando e hashes ficam em `build.json`. Recriar o PDF pode alterar seus metadados e hash: preserve uma entrega congelada antes de renderizá-la novamente.

Nesta complementação não foram executados R, Stata, estimação, Monte Carlo, bootstrap ou testes de cobertura. A leitura de resultados publicados não é sua reprodução. A extensão IV e o resultado de Hausman são registrados nos limites do artigo de 2016; as provas remetidas a Gelbach (2009) não foram examinadas.
