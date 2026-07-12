# Revisão independente atualizada — Task 14

**Data:** 2026-07-12  
**Escopo:** revisão pré-execução do pacote `simulations/lag_misspecification_persistence/`, incluindo a correção de inicialização e a regressão de apresentação. Executei somente verificações limitadas; não rodei `--mode full`, não modifiquei `simulations/`, não editei manuscritos e não fiz commit.

Uma tentativa anterior de iniciar o CLI configurado como Terra/high falhou antes de começar por permissões. Portanto, este documento **não** afirma uma identidade de modelo Terra/high que não é verificável; registra uma revisão independente do código, testes e artefatos acessíveis.

## Verdict: PASS

F-01 (inicialização) e F-02 (legibilidade do PDF) foram resolvidos. O pacote está liberado para a bateria pré-especificada, desde que ela seja executada pelo comando aprovado do protocolo. Este PASS não é resultado da bateria completa e não valida resultados que ainda não existem.

## Estimando, DGP e inicialização

O pacote preserva o CET como efeito contemporâneo `beta_cet = 1`; `Z[t-1]` é pré-exposição e `Z[t]` permanece diagnóstico pós-tratamento. Os DGPs ADL(1), ADL(2) e ADL(3) incluem lags correspondentes de resultado e tratamento, com persistência de `D` e carryover variando no grid de 27 células. [dgp.R](../../simulations/lag_misspecification_persistence/R/dgp.R#L41-L73); [config.R](../../simulations/lag_misspecification_persistence/R/config.R#L24-L93); [task14_protocol.md](../../simulations/lag_misspecification_persistence/task14_protocol.md#L10-L26).

A correção de F-01 é substantiva e correta: a matriz de transição, as inovações estruturais e a covariância estacionária são construídas explicitamente; a covariância resolve a equação discreta de Lyapunov e a média é condicionada aos efeitos unitários. [config.R](../../simulations/lag_misspecification_persistence/R/config.R#L95-L198). O estado é mapeado na ordem correta para `D`, `Y`, `Z` e os lags antes das transições, e a geração falha se o resíduo de Lyapunov ultrapassar `1e-10`. [dgp.R](../../simulations/lag_misspecification_persistence/R/dgp.R#L15-L59).

No cenário mais lento, `L2_RD80_CO50`, o raio continua `0.987669369`, mas não há mais dependência de uma inicialização arbitrária seguida de burn-in. Preflight das 27 células passou com resíduo máximo `7.82e-14`; o smoke testa as identidades de média e covariância justamente nesse cenário. [config.R](../../simulations/lag_misspecification_persistence/R/config.R#L200-L276); [smoke_test.R](../../simulations/lag_misspecification_persistence/smoke_test.R#L23-L55). Uma checagem independente adicional com 50.000 draws condicionais teve erro relativo de Frobenius de 0.00461 para a covariância inicial, 0.00513 após uma transição, e diferença entre ambas de 0.00065, compatível com erro amostral e invariância estacionária.

O runner escreve `initialization_manifest.csv` com raio, método, burn-in pós-draw, resíduo e status por célula; a validação final também exige essa condição. [runner](../../simulations/lag_misspecification_persistence/run_lag_misspecification_persistence.R#L147-L188); [metrics.R](../../simulations/lag_misspecification_persistence/R/metrics.R#L131-L180).

## Estimação, inferência e rastreabilidade

| Item | Resultado | Evidência |
|---|---|---|
| Regras de lag e AIC/BIC | PASS — ADL(1), ADL(2), oracle, AIC e BIC são todos retidos; AIC/BIC comparam ordens 1--3 sob a especificação pré-exposição com `Z[t-1]`, sem escolha ex post entre critérios. | [simulation.R](../../simulations/lag_misspecification_persistence/R/simulation.R#L1-L12); [estimators.R](../../simulations/lag_misspecification_persistence/R/estimators.R#L48-L128) |
| TWFE, SE e cobertura | PASS — transformação within de duas vias, sandwich clusterizado por unidade, IC de 95% e cobertura numérica do CET são implementados. O smoke confirmou o coeficiente customizado contra `fixest::feols()` abaixo de `1e-10`. | [estimators.R](../../simulations/lag_misspecification_persistence/R/estimators.R#L1-L90); [smoke_test.R](../../simulations/lag_misspecification_persistence/smoke_test.R#L84-L94) |
| Métricas exigidas | PASS — bias, relative bias, RMSE, cobertura, ACF(1) residual, MCSEs, recuperação de seleção e os deslocamentos de `Z[t-1]` e `Z[t]` são mantidos com denominadores e falhas explícitos. | [metrics.R](../../simulations/lag_misspecification_persistence/R/metrics.R#L7-L129); [simulation.R](../../simulations/lag_misspecification_persistence/R/simulation.R#L15-L111) |
| Seeds, falhas, checkpoints e hashes | PASS — seeds são determinísticos por cenário/repetição; falhas de DGP e de seleção são retidas, sem escolher subconjunto favorável; checkpoints/CSVs são atômicos e os artefatos preexistentes em `simulations/` são hashados antes/depois. | [config.R](../../simulations/lag_misspecification_persistence/R/config.R#L279-L296); [simulation.R](../../simulations/lag_misspecification_persistence/R/simulation.R#L114-L248); [runner](../../simulations/lag_misspecification_persistence/run_lag_misspecification_persistence.R#L58-L67); [runner](../../simulations/lag_misspecification_persistence/run_lag_misspecification_persistence.R#L104-L113) |
| Gate | PASS — o full requer `--approved` e este parecer com a linha literal de PASS; o smoke confirmou a recusa de full sem aprovação antes de draws. | [runner](../../simulations/lag_misspecification_persistence/run_lag_misspecification_persistence.R#L115-L133); [runner](../../simulations/lag_misspecification_persistence/run_lag_misspecification_persistence.R#L224-L245); [smoke_test.R](../../simulations/lag_misspecification_persistence/smoke_test.R#L190-L205) |

## Regressão de PDF resolvida

A Table 5 voltou a caber integralmente na margem após encurtar a descrição de `stationary_initialization` para `stationary initialization and Lyapunov residual pass`, preservando o critério substantivo no protocolo e manifest. [metrics.R](../../simulations/lag_misspecification_persistence/R/metrics.R#L154-L177); [task14_protocol.md](../../simulations/lag_misspecification_persistence/task14_protocol.md#L28-L48). O smoke renderizado depois da correção produziu PDF aberto de cinco páginas; texto extraído contém Tables 1--5 e Figures 1--3, e a página 5 foi inspecionada visualmente sem corte, sobreposição ou texto ilegível. O Rmd lê outputs salvos, e não reexecuta Monte Carlo. [report](../../simulations/lag_misspecification_persistence/lag_misspecification_persistence_report.Rmd#L15-L49); [report](../../simulations/lag_misspecification_persistence/lag_misspecification_persistence_report.Rmd#L186-L202).

## Verificações limitadas executadas

- Preflight: PASS — 11 invariantes, incluindo `stationary_covariance`, nas 27 células; resíduo máximo `7.82e-14`.
- `smoke_test.R`: PASS — ADL(1/2/3), determinismo, balanceamento, todos os estimadores/controles, ACF/deslocamentos/cobertura, CSV round trip, recuperação-base BIC, retenção das frequências AIC e recusa de full sem aprovação. As frequências AIC de base (0.05, 0.35, 1.00) foram preservadas como diagnóstico, não usadas para promover ex post um critério.
- `--mode smoke --reps 1 --render-report` em diretório temporário: PASS — `initialization_manifest.csv` gravado, `stationary_initialization = TRUE`, PDF aberto e inspeção visual aprovada. Os temporários foram removidos.
- `git diff --check`: PASS.

## Handoff

O executor pode rodar a bateria predefinida de 500 repetições com `--mode full --reps 500 --approved --render-report`. Depois dela, ainda será necessário auditar resultados completos, CSVs, hashes antes/depois, PDF integral e texto extraído; esta revisão não substitui essa validação pós-execução.
