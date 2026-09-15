# Gate 1 — triagem documental de aplicações

## Resultado corrigido após adjudicação

A rodada corrigida não aprova aplicação principal ou reserva para o **efeito contemporâneo (CET)** do plano. Os dois julgamentos relevantes são mantidos separados:

| candidata | classe literal E1–E7 | adequação adicional ao CET | papel CET |
|---|---|---|---|
| Blair, Di Salvatore e Smidt | `ELIGIBLE_DOCUMENTARY` | `NOT_ESTABLISHED` | nenhum |
| Ballard-Rosa, Mosley e Wellhausen | `HOLD_DOCUMENTATION` (`E7 = MISSING_TIMING`) | `NOT_ESTABLISHED` | nenhum |
| Claassen | `HOLD_DOCUMENTATION` (`E7 = MISSING_NOT_FAIL`) | `ORIGINAL_ASSUMPTIONS_EXCLUDE_CONTEMPORANEOUS_SUPPORT_EFFECT` | nenhum |

Blair passa os sete critérios documentais para comparar uma projeção futura: mandato em `t-2` e democracia em `t`. Esse resultado não vira CET pela troca dos nomes dos índices. Ballard-Rosa permanece em HOLD porque a frequência e o intervalo de referência da crise inflacionária não foram reconciliados nas fontes primárias lidas. Claassen permanece em HOLD porque a ausência da seta apoio → PIB impede presumir mediação, mas não satisfaz a regra afirmativa de inelegibilidade do protocolo.

“Elegível documentalmente” atesta apenas que a comparação literal do protocolo pode ser reconstruída. Não estabelece identificação, inferência, suporte estatístico, amostra comum, estimador ou correspondência com o CET. Nenhuma execução empírica foi autorizada ou realizada.

## Estado dos artefatos

- `protocol.md`, `protocol.json` e `protocol_freeze.md` são os bytes congelados da versão 1 e permanecem inalterados.
- `cet_correspondence_addendum.md` registra, depois da triagem e da adjudicação, a correspondência adicional com o CET já exigida pelo plano. O adendo não é apresentado como preespecificação anterior às leituras e não altera E1–E7.
- Os 12 artefatos da rodada inicial estão preservados em `gate_01/review/snapshots/applications_round1/`. As fichas e decisões correntes substituem as conclusões iniciais sem apagar o histórico.
- `repair_round3.md` registra a correção editorial do localizador de Blair; `repair_round2.md` preserva a rodada substantiva anterior.
- `manifest_round3.json` identifica os bytes correntes. `manifest_round2.json` permanece como registro histórico dos bytes da rodada anterior.

## Ordem de leitura

1. `protocol.md`, `protocol.json` e `protocol_freeze.md`: protocolo e recibo congelados.
2. `cet_correspondence_addendum.md`: teste adicional, posterior, de correspondência com CET.
3. `selection.md`: conclusão corrigida e matriz harmonizada.
4. As três fichas `candidate_*.md`: evidência, limites e trabalho necessário por caso.
5. `archive_disposition.md`: disposição de todo o acervo e opções ainda não escolhidas.
6. `decision_log.md` e `inspection_log.md`: cronologia, incidente de cegamento e fronteira do executado.
7. `sources_manifest.csv`, `repair_round3.md` e `manifest_round3.json`: fontes, reparo corrente e identidade dos bytes; os artefatos `*_round2` preservam a rodada anterior.

## Limite de cegamento

O roster do Gate 0 foi aberto antes da criação e do congelamento do protocolo e exibiu colunas numéricas proibidas. Não há evidência de uso intencional desses valores, mas a cegueira inicial não pode ser certificada. A revisão independente posterior oferece sustentação documental adicional e registra concordâncias e divergências; ela não reconstrói o estado cognitivo anterior nem elimina a possibilidade de influência. Este diretório não aprova seus próprios bytes.
