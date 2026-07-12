# Revisão independente e adversarial — Task 14

**Data:** 2026-07-12  
**Escopo:** revisão pré-execução do pacote `simulations/lag_misspecification_persistence/`; verificações limitadas apenas. Não executei `--mode full`, não modifiquei o pacote, não editei manuscritos e não fiz commit.

Uma tentativa anterior de iniciar o CLI configurado como Terra/high falhou antes de começar por permissões. Por isso, este documento **não** afirma uma identidade de modelo Terra/high que não é verificável; registra uma revisão independente do código e dos testes disponíveis.

## Verdict: FAIL

Não libere a bateria completa ainda. Há um bloqueador de estabilidade/inicialização no cenário pré-especificado mais persistente. Os demais componentes fundamentais estão bem encaminhados, mas não eliminam esse risco de que parte do resultado atribuído a misspecification reflita transientes de inicialização.

## Escopo verificado

Li a Task 14 no [plano canônico](../plans/2026-07-10_referee_feedback_revision_plan.md), a nota de identificação do CET em [adl_cet_identification_conditions.Rmd](../../derivations/adl_cet_identification_conditions.Rmd), o protocolo e a revisão independente da Task 13, o inventário/DGP dual-role anterior e todos os arquivos atuais da Task 14. A comparação foi feita contra o requisito de que a ordem de lag seja uma scope condition do CET, não uma escolha mecânica de especificação.

## Bloqueador

### F-01 — O burn-in de 100 não é suficiente para o canto mais persistente do grid

O DGP inicializa cada série em `alpha + inovação`, e não a partir da distribuição estacionária condicional aos efeitos unitários. [dgp.R](../../simulations/lag_misspecification_persistence/R/dgp.R#L20-L44). O grid fixa `burn_in = 100`, inclui `rho_D = 0.8` e carryover de até `0.50`, e a única condição de estabilidade atualmente exigida é raio espectral estritamente menor que um. [config.R](../../simulations/lag_misspecification_persistence/R/config.R#L24-L55) [config.R](../../simulations/lag_misspecification_persistence/R/config.R#L95-L176).

No preflight limitado, o cenário `L2_RD80_CO50` teve o maior raio de transição, `0.9876694`. Isso implica meia-vida de aproximadamente `55.87` períodos e peso remanescente do componente inicial lento de `0.9876694^100 = 0.2892` quando começa a janela retida de apenas 30 períodos. Portanto, `raio < 1` prova estabilidade assintótica, mas não prova que a amostra usada já se desligou da condição inicial. O protocolo fixa justamente esse burn-in de 100 para todo o grid, sem uma validação de convergência ou sensibilidade. [task14_protocol.md](../../simulations/lag_misspecification_persistence/task14_protocol.md#L10-L14) [task14_protocol.md](../../simulations/lag_misspecification_persistence/task14_protocol.md#L26-L38).

Isso é material para o objetivo da Task 14: o canto de alto `rho_D` e alto carryover é precisamente onde se quer interpretar diferenças entre ADL(1), ordens maiores e critérios de informação. Sem eliminar o transiente, a bateria completa não identifica nitidamente se a diferença vem da estrutura de lags ou da inicialização.

**Reparo obrigatório antes do `--approved`:**

1. Inicializar o vetor de estado a partir da distribuição estacionária condicional aos efeitos unitários, **ou** aumentar o burn-in por cenário conforme o raio e uma tolerância declarada. Por exemplo, com tolerância de 0.001, o cenário de raio 0.9876694 requer ao menos 557 períodos de descarte (`ceiling(log(0.001)/log(radius))`), não 100.
2. Acrescentar ao preflight um invariante que salve raio, burn-in e contribuição remanescente máxima; ele deve falhar quando exceder a tolerância.
3. Acrescentar ao smoke test uma verificação explícita de ausência de dependência material da inicialização (comparação com inicialização estacionária ou burn-in maior, com critério e MCSE pré-especificados). Atualizar protocolo/README/manifests e repetir preflight, smoke e renderização limitada antes de nova revisão.

## Achados que passaram a revisão

| Item | Resultado | Evidência |
|---|---|---|
| CET e papel de `Z` | PASS — o estimando é o efeito contemporâneo `beta_cet = 1`; `Z[t-1]` entra antes de `D[t]` e `Y[t]`, enquanto `Z[t]` é gerado depois de ambos e é explicitamente diagnóstico pós-tratamento. Isso respeita a distinção da Task 04 entre história pré-exposição e controle contemporâneo. | [dgp.R](../../simulations/lag_misspecification_persistence/R/dgp.R#L26-L58); [README.md](../../simulations/lag_misspecification_persistence/README.md#L5-L33); [identificação](../../derivations/adl_cet_identification_conditions.Rmd#L18-L39) |
| DGP ADL(1/2/3), persistência e carryover | PASS — o grid é exatamente `3 x 3 x 3 = 27`; a equação de resultado contém os lags correspondentes de `Y` e de `D`, e o carryover decai geometricamente. Assim, omitir lags de tratamento é parte do DGP e não um artefato da estimação. | [config.R](../../simulations/lag_misspecification_persistence/R/config.R#L28-L32); [config.R](../../simulations/lag_misspecification_persistence/R/config.R#L59-L93); [dgp.R](../../simulations/lag_misspecification_persistence/R/dgp.R#L26-L43) |
| Regras de lag e informação | PASS — ADL(1), ADL(2), oracle, AIC e BIC são todos retidos; AIC/BIC usam candidatos 1--3 na mesma especificação com `Z[t-1]`, FE de unidade e tempo, e penalidade que muda apenas com os regressores dinâmicos. Nenhum critério é escolhido ex post. | [simulation.R](../../simulations/lag_misspecification_persistence/R/simulation.R#L1-L12); [estimators.R](../../simulations/lag_misspecification_persistence/R/estimators.R#L48-L90); [estimators.R](../../simulations/lag_misspecification_persistence/R/estimators.R#L112-L128); [task14_protocol.md](../../simulations/lag_misspecification_persistence/task14_protocol.md#L16-L20) |
| TWFE, inferência e cobertura | PASS, com escopo — há transformação within de duas vias, sandwich com cluster por unidade, IC normal de 95% e cobertura da constante CET registrada para cada regra/controle. Em uma verificação limitada independente nos três DGPs, o coeficiente coincidiu com `fixest::feols()` e a razão entre o erro-padrão próprio e o de `fixest` foi 0.99497--0.99498. A escolha de cluster por unidade é adequada ao DGP sem choque temporal comum, mas a cobertura continua uma propriedade numérica a ser relatada, não uma garantia causal. | [estimators.R](../../simulations/lag_misspecification_persistence/R/estimators.R#L1-L90); [simulation.R](../../simulations/lag_misspecification_persistence/R/simulation.R#L61-L111); [smoke_test.R](../../simulations/lag_misspecification_persistence/smoke_test.R#L55-L64) |
| Métricas e denominadores | PASS — summaries retêm bias, relative bias assinado, RMSE, cobertura, ACF(1) residual e MCSEs; seleção informa taxas de recuperação e as três probabilidades de lag; deslocamentos `Z[t-1]-no Z` e `Z[t]-no Z` são gravados separadamente. Falhas ficam no denominador auditável, sem filtragem favorável. | [metrics.R](../../simulations/lag_misspecification_persistence/R/metrics.R#L7-L74); [metrics.R](../../simulations/lag_misspecification_persistence/R/metrics.R#L76-L129); [simulation.R](../../simulations/lag_misspecification_persistence/R/simulation.R#L15-L58) |
| Seeds, falhas, checkpoints e hashes | PASS — seeds são indexados por cenário e repetição; falhas de DGP produzem as 15 linhas previstas; falhas de candidato bloqueiam aquele AIC/BIC em vez de selecionar o subconjunto favorável; checkpoints e CSVs são atômicos. O runner também compara hashes de todas as simulações anteriores antes/depois. | [config.R](../../simulations/lag_misspecification_persistence/R/config.R#L179-L195); [simulation.R](../../simulations/lag_misspecification_persistence/R/simulation.R#L114-L248); [runner](../../simulations/lag_misspecification_persistence/run_lag_misspecification_persistence.R#L58-L67); [runner](../../simulations/lag_misspecification_persistence/run_lag_misspecification_persistence.R#L104-L113); [runner](../../simulations/lag_misspecification_persistence/run_lag_misspecification_persistence.R#L147-L207) |
| Gate de execução | PASS — `--mode full` exige `--approved` e, então, um arquivo de revisão contendo literalmente `## Verdict: PASS`; sem isso, a parada ocorre antes dos draws. Este FAIL mantém o gate fechado. | [runner](../../simulations/lag_misspecification_persistence/run_lag_misspecification_persistence.R#L115-L133); [runner](../../simulations/lag_misspecification_persistence/run_lag_misspecification_persistence.R#L224-L245); [smoke_test.R](../../simulations/lag_misspecification_persistence/smoke_test.R#L161-L174) |
| Relatório e recomendação editorial | PASS para preparação — o Rmd lê resultados já salvos, apresenta tabelas de recuperação, CET/ACF, deslocamentos `Z[t]` versus `Z[t-1]`, heatmaps e validações; o PDF limitado abriu em cinco páginas sem clipping ou sobreposição visível. A frase e a linha de scope condition são explicitamente propostas para integração posterior, sem editar o manuscrito. | [report](../../simulations/lag_misspecification_persistence/lag_misspecification_persistence_report.Rmd#L15-L47); [report](../../simulations/lag_misspecification_persistence/lag_misspecification_persistence_report.Rmd#L67-L193); [editorial recommendation](../../simulations/lag_misspecification_persistence/editorial_recommendation.md#L1-L15) |

## Observações não bloqueadoras

1. O smoke de caso-base passou o limiar pré-especificado de recuperação BIC (ao menos 80% nos três DGPs grandes); ele também revelou e imprimiu as recuperações AIC de 0.05, 0.25 e 1.00 para ADL(1), ADL(2) e ADL(3), respectivamente. Essa assimetria é precisamente uma falha de seleção que a execução completa deve mostrar separadamente, sem rebatizar BIC como vencedor universal. [smoke_test.R](../../simulations/lag_misspecification_persistence/smoke_test.R#L108-L159).
2. A medida residual é ACF(1). Ela atende ao requisito mínimo de autocorrelação, mas, antes da redação final, convém acrescentar ACF(2)--ACF(3) ou um diagnóstico conjunto, pois o experimento contém ADL(3). Isso é melhoria de diagnóstico, não a causa do FAIL.
3. Não há resultados completos ainda, como esperado em uma revisão pré-execução. Logo não foi possível auditar CSVs finais, contagens de 500 repetições, hashes antes/depois da bateria, ou o PDF do grid integral. A validação limitada cobriu apenas preflight, `smoke_test.R`, um PDF de smoke em diretório temporário fora do repositório e a comparação pontual com `fixest`.

## Verificações efetivamente executadas

- `Rscript simulations/lag_misspecification_persistence/run_lag_misspecification_persistence.R --mode preflight`: PASS; 27 cenários e todos os invariantes lógicos passaram; raio máximo reportado foi 0.987669.
- `Rscript simulations/lag_misspecification_persistence/smoke_test.R`: PASS; DGPs ADL(1/2/3) determinísticos e balanceados, cinco regras e três controles, ACF/deslocamentos/cobertura, CSV round trip, recuperação-base e recusa de full sem gate.
- `--mode smoke --reps 1 --render-report` em diretório temporário: PASS; PDF aberto, cinco páginas, texto extraído contendo Tables 1--5 e Figures 1--3; PNGs das cinco páginas foram inspecionados visualmente. Os temporários foram removidos.
- `git diff --check`: PASS. O status restrito a `simulations/` mostrou apenas o novo pacote não rastreado; esta revisão é o único arquivo novo produzido por mim fora dele.

## Limite de autoridade e handoff

Não implementei alterações. O executor deve reparar F-01 e atualizar os testes/documentação; então uma nova revisão independente deverá decidir se substitui este veredito por `PASS`. Até isso ocorrer, não execute `--mode full --approved` e não integre resultados no paper.
