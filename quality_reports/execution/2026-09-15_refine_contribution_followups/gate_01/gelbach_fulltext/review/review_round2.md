# Gelbach integral: revalidação dos reparos, rodada 2

**Data:** 15/09/2026. **Revisor:** `gelbach_full_review`. **Escopo:** somente R1-GF001, R1-GF002 e dependências dos arquivos reparados.

## Resultado

**Veredicto documental: PASS.** Os dois findings adjudicados foram corrigidos no escopo autorizado. **Nenhum novo finding. `gate_approved: false`.** O resultado permite fechar a incorporação documental de Gelbach; não demonstra contribuição científica adicional, não aprova aplicação CET e não escolhe nova rota.

| ID | Decisão anterior | Resultado da revalidação | Evidência |
|---|---|---|---|
| R1-GF001 | PARTIAL: ambiguidade documental; mudança operacional efetiva refutada | **CLOSED_VERIFIED** | Relatório linha13, §§3.1–3.2, 3.6, 4–5; matriz L01/L02/L04/L05/L10/L12/L17; manifesto e registro de reparo. A nova redação declara capacidades e informações já congeladas e atribuição bibliográfica fortalecida, mantendo IV/Hausman/pesos/instrumentos fora do teste OLS sem pesos |
| R1-GF002 | CONFIRMED: número da equação populacional | **CLOSED_VERIFIED** | Adendo linha21 e PDF p.1 §2 item1 agora citam eq.(3), preservando eq.(11). Comparação direta contra snapshot comprova exatamente uma substituição textual `(4)` → `(3)` |

Os diffs do leitor ficaram restritos à cronologia e ao escopo da atribuição, com harmonização de campos relacionados no CSV. A descrição das duas bases B/U e C/U, a origem deduzida de sua covariância, os exemplos e a conclusão científica permanecem. Não foi identificado acréscimo retroativo de operação ou novo teste. O registro de reparo distingue a parte adjudicada da alegação ampla refutada.

## Identidade e dependências

Freeze da rodada2: `review_input_freeze_round2.json`, SHA-256 **`aca2e52ed6b61158916f1883bfc7ed6a982772386b42a417576941cd3aa977bc`**. Foram conferidos os **12 hashes** e a igualdade byte a byte com suas **12 cópias em `snapshots/round2/`**. A lista completa dos hashes examinados está no JSON desta revisão.

| Produto principal revisto | SHA-256 |
|---|---|
| `reading/full_read_report.md` | `2737dcab2c8a66baea836c4c751e7ea745b128ca43ce4bf0aeeba36d5f3b0c33` |
| `reading/claim_comparison.csv` | `e3413815890a91a3508474b08dc52e2911cfa6126c1619c6e07f62b8a91241dc` |
| `reading/read_manifest.json` | `cae6c66279a70e732bedd9c29c6f3b385eb318c4528c5d32c657882c3b6c5c8f` |
| `reading/repair_round1.md` | `7f91a6a0032390d7c35919a4d812fe511d7eefa22ed0903d5a6306dd56486ffa` |
| `gelbach_addendum.md` | `60961506d6400160e140f29a4fa1e2f185593e71f54976abd62e99405d4d4067` |
| `gelbach_addendum.pdf` | `76da384c52e1dbde4ce5d09c97ab5ed161a2bfa606f70fed04df7ed886f8015f` |

O manifesto aponta para os quatro outputs atuais e para o registro de reparo com hashes corretos. Seus seis inputs antigos preservam os hashes, incluindo ficha v2 e derivação. A fonte PDF/texto/mapa também preserva os hashes. `page_coverage.csv` e `review_scope.md` são byte a byte idênticos à rodada1. O CSV de claims mantém L01–L17 ordenados, sem duplicação. Os hashes de MD/PDF nos registros do coordenador e no QA correspondem aos produtos recebidos.

## Verificações executadas

1. Leitura da adjudicação e dos registros de reparo/QA; leitura integral dos diffs relatório, matriz, manifesto e adendo contra `snapshots/round1/`. As alterações verificadas cumprem as disposições da adjudicação, sem reabrir os claims científicos aprovados documentalmente na rodada anterior.
2. SHA-256 e comparação de snapshots; conferência dos hashes derivados e dos inputs antigos; validação da sequência L01–L17 e preservação de cobertura/escopo.
3. Comparação dos textos integrais extraídos dos PDFs antigo e novo por `pdftotext -layout`: **a única diferença textual foi a mesma substituição de número de equação**. Nenhuma outra diferença de texto foi encontrada.
4. Nova renderização e inspeção independente da **página1 do PDF reparado**, verificando o item corrigido e a legibilidade sem corte/sobreposição. O QA do coordenador, vinculado ao hash atual, registra inspeção das **3/3 páginas**; esta rodada independente não repete a alegação de ter visualizado as três páginas novas. A rodada1 já havia visualizado as três páginas anteriores, e a extração atual foi comparada integralmente.

A cobertura independente da fonte científica permanece a declarada na Fase A: 29 páginas textuais e 12 visuais; nenhuma página da fonte foi relida nesta rodada. Não houve R, Stata, análise, bootstrap, reconstrução do adendo pelo revisor, reescrita do manuscrito, mudança do comparador ou de rota. Os únicos produtos desta tarefa são `review_round2.md/json`; as imagens temporárias ficaram em `/tmp/ivb_gelbach_review_round2/`.

## Encaminhamento

O coordenador pode registrar a adjudicação final e atualizar estado, índice e manifesto, citando este PASS documental e mantendo `gate_approved=false`. Esses registros posteriores não foram antecipadamente revisados por este parecer; não devem alterar os produtos científicos/documentais cujos hashes estão acima sem nova verificação da alteração pertinente. Não há reparo adicional solicitado nesta rodada.
