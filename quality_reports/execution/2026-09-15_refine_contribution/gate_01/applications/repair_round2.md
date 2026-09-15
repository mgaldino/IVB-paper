# Nota de reparo — aplicações, rodada 2

**Data:** 15 de setembro de 2026  
**Base:** revisão independente da rodada 1 e adjudicação do coordenador  
**Estado:** bytes corrigidos entregues para nova revisão; sem autoaprovação

## Preservação e escopo

Os 12 arquivos originais estão preservados em `gate_01/review/snapshots/applications_round1/`. Esta rodada alterou somente `gate_01/applications/`. Os três artefatos congelados permaneceram byte a byte intactos:

| artefato | SHA-256 congelado |
|---|---|
| `protocol.json` | `2cdd660814ea3951ff7ede8603d8df96ecd43630279b39c6ecfdc9c754ad442e` |
| `protocol.md` | `57e59f01ab55263e05d5e191a0ac88020c7893bd3cc61bec056d87f5c916f8f4` |
| `protocol_freeze.md` | `593526407b8c135d4b0feb2c91722df5b8d8d5f42694d43880746ca5cc5d1763` |

Não houve nova candidata, leitura de outra aplicação, execução de R/Stata, regressão, IVB, shift, p-valor ou estatística dos dados.

## Achados adjudicados e correções

| achado | adjudicação | correção nos bytes correntes |
|---|---|---|
| R1-F001 | CONFIRMED | classe E1–E7 e adequação CET foram separadas; Blair permanece elegível literal, mas nenhuma principal/reserva CET foi aprovada; adendo posterior explicita a correspondência |
| R1-F002 | CONFIRMED | Ballard-Rosa passou a `HOLD_DOCUMENTATION`, E7 `MISSING_TIMING`; foram retiradas as afirmações de crise mensal e história `t-2` certificada |
| R1-F003 | CONFIRMED | Claassen passou de FAIL/inelegível para `HOLD_DOCUMENTATION`, E7 `MISSING_NOT_FAIL`; o limite contemporâneo foi mantido em campo separado |
| R1-F004 | CONFIRMED | logs agora registram que o roster precedeu o protocolo; a revisão posterior adiciona suporte, mas não elimina influência possível |
| R1-F005 | REFUTED | Blair mantém E5 `PASS_DOCUMENTARY_WITH_RISK`; foi registrada a retratação do revisor, sem aprovar inferência |
| R1-F006 | CONFIRMED | Ballard-Rosa usa estado partidário em exercício, esquerda vs. centro/outros; referências a nova transição foram removidas |

## Harmonização realizada

- `README.md`, `selection.md`, `archive_disposition.md`, `decision_log.md` e `inspection_log.md` apresentam a mesma decisão.
- As três fichas usam campos separados para classe literal, adequação CET e papel CET.
- `cet_correspondence_addendum.md` é explicitamente posterior e não modifica o protocolo v1.
- `sources_manifest.csv` inclui os documentos de revisão e adjudicação que fundamentaram o reparo.
- `manifest_round2.json` contém hashes dos artefatos correntes; o próprio manifesto é excluído para evitar autorreferência circular.

## Decisão corrente

| candidata | classe literal | adequação CET | papel CET |
|---|---|---|---|
| Blair | `ELIGIBLE_DOCUMENTARY` | `NOT_ESTABLISHED` | nenhum |
| Ballard-Rosa | `HOLD_DOCUMENTATION` | `NOT_ESTABLISHED` | nenhum |
| Claassen | `HOLD_DOCUMENTATION` | `ORIGINAL_ASSUMPTIONS_EXCLUDE_CONTEMPORANEOUS_SUPPORT_EFFECT` | nenhum |

A busca adicional delimitada e a rota descritiva/futura estão descritas como opções para o autor. Nenhuma foi escolhida nesta rodada. Os bytes corrigidos seguem para revisão independente; esta nota não aprova o Gate 1.
