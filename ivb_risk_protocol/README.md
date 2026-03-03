# IVB Risk Protocol

Pasta dedicada ao protocolo de decisão para classificar quando é seguro assumir que o IVB é pequeno e quando não é seguro.

## Objetivo

Definir e calibrar (por simulação) uma regra prática com 3 componentes:

1. teste de crescimento marginal no canal `D -> Z`;
2. teste de amplificação no loop `Z -> D -> Z`;
3. stress test de cauda para sensibilidade do IVB.

## Estrutura

- `docs/`: especificação do protocolo, esquema de dados e critérios de decisão.
- `R/`: scripts para calibração de thresholds e aplicação da regra.
- `data_raw/`: insumos brutos para calibração (simulações).
- `data_processed/`: features e labels prontos para estimação dos thresholds.
- `outputs/`: resultados da calibração (thresholds, métricas, tabelas).

## Pipeline

1. Produzir arquivo de features em `data_processed/protocol_features.csv`.
2. Rodar `R/01_calibrate_thresholds.R`.
3. Inspecionar `outputs/threshold_candidates.csv` e `outputs/threshold_selected.csv`.
4. Travar thresholds finais para uso empírico.

## Observação

Este diretório foi criado para separar claramente o desenvolvimento do protocolo de testes do restante do paper.
