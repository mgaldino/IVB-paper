# Recibo de congelamento do protocolo

O protocolo foi escrito e hasheado antes da leitura integral e da classificação das três candidatas. Depois do congelamento, `protocol.json` e `protocol.md` não foram editados.

| arquivo | SHA256 congelado |
|---|---|
| `protocol.json` | `2cdd660814ea3951ff7ede8603d8df96ecd43630279b39c6ecfdc9c754ad442e` |
| `protocol.md` | `57e59f01ab55263e05d5e191a0ac88020c7893bd3cc61bec056d87f5c916f8f4` |

Comando de conferência: `shasum -a 256 quality_reports/execution/2026-09-15_refine_contribution/gate_01/applications/protocol.json quality_reports/execution/2026-09-15_refine_contribution/gate_01/applications/protocol.md`, executado na raiz do repositório.

O congelamento fixa critérios, classes, informação proibida, número máximo de leituras e regra de seleção. Não congela as fichas, que são o resultado da aplicação posterior do protocolo.

O campo `created_at` usa a data civil do gate ancorada em `00:00:00-03:00`; ele não é um carimbo forense da hora de escrita. A evidência operacional do momento de congelamento é a sequência documentada neste recibo e no log de inspeção.
