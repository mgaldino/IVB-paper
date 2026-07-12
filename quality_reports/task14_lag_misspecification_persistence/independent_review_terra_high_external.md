# Revisão independente e adversarial — Task 14

**Data:** 2026-07-12  
**Escopo:** revisão somente leitura da implementação pré-execução em `simulations/lag_misspecification_persistence/`. Foram lidos o plano canônico, protocolo, README, os cinco arquivos em `R/`, runner, smoke test e Rmd do relatório. Não foi executado `--mode full`; scripts, dados, manuscrito e resultados não foram alterados. Este é um parecer externo e não substitui o arquivo canônico consultado pelo gate.

## Verdict: REPAIR

Não autorizar a bateria completa ainda. A implementação acerta a maior parte do desenho e os testes leves passaram, mas o burn-in fixo é incompatível com a célula estável porém quase unitária do grid. Isso deixa uma fonte material de transiente de inicialização exatamente no canto em que a Task 14 pretende interpretar persistência e especificação de lags. Há também duas lacunas de QA/denominadores que devem ser reparadas antes do full run.

## Evidência de verificação limitada

| Verificação | Resultado | Evidência |
|---|---|---|
| Preflight e grid | PASS | 27 células; todos os invariantes lógicos passaram. |
| Estabilidade espectral | PASS assintótico, mas insuficiente como gate de inicialização | Raios calculados para todas as 27 células: mínimo 0,678289808; máximo 0,987669369 em `L2_RD80_CO50`. |
| DGP, timing e CET | PASS | `D_t` e `Y_t` usam `Z_{t-1}`; `Z_t` é gerado somente após ambos. O CET numérico é o coeficiente contemporâneo fixado em 1. |
| Within versus `fixest` | PASS | O smoke passou a comparação do coeficiente de `D` com tolerância menor que `1e-10` nos três DGPs. |
| Regras, IC e falhas de seleção | PASS | ADL(1), ADL(2), oracle, AIC e BIC são retidos; uma falha em qualquer candidato com `Z_lag` impede a seleção AIC/BIC. |
| Seeds, checkpoints e hashes | PASS no smoke | Seeds são função de cenário e repetição; checkpoints/CSVs são atômicos. No smoke renderizado, 214/214 hashes de simulações pré-existentes ficaram inalterados. |
| Smoke e PDF | PASS | `smoke_test.R` passou integralmente. O render limitado abriu em PDF de 5 páginas, sem criptografia; texto, tabelas e páginas 1 e 5 foram inspecionados. |
| Gate | PASS como bloqueio | Sem `--approved`, o runner recusa antes de draws. Com `--approved`, o gate canônico existente, cujo veredito não é PASS, também recusou antes de qualquer cenário. |

## Achados que exigem reparo

### F-01 — Burn-in não elimina o transiente no cenário mais persistente

**Severidade:** crítica — bloqueia a execução full.

**Arquivos/linhas:** `R/config.R:24-55`, `R/config.R:95-176`, `R/dgp.R:20-44`, `task14_protocol.md:10-14`, `task14_protocol.md:26-38`.

O DGP inicializa `D`, `Y` e `Z` com efeitos unitários mais inovações, e não com a distribuição estacionária condicional aos efeitos fixos. O único requisito atual é raio espectral menor que um. Isso prova estabilidade assintótica, não que os dados retidos após 100 períodos já não dependem materialmente do estado inicial.

O cálculo independente para as 27 células encontrou `rho(A)=0,987669368666` em `L2_RD80_CO50`. Nesse modo lento, a meia-vida é 55,87 períodos e a fração remanescente após o burn-in de 100 é `rho(A)^100 = 0,289173`. Para tolerância declarada de 0,001, o descarte mínimo seria 557 períodos. Assim, o canto de alta persistência e carryover pode misturar misspecification de lags com transientes de inicialização.

**Reparo exigido:** antes de qualquer `--approved`, (a) inicializar o vetor de estado pela distribuição estacionária condicional aos efeitos unitários, ou definir um burn-in específico por cenário a partir de uma tolerância pré-especificada; (b) salvar para cada célula o raio, burn-in e peso máximo remanescente; (c) transformar esse limite em invariante que falha quando violado; e (d) adicionar ao smoke uma comparação pré-especificada contra inicialização estacionária ou burn-in maior, com critério de equivalência e MCSE. Atualizar protocolo, README, manifesto e testes; então repetir preflight, smoke e render limitado antes de nova revisão independente.

### F-02 — A validação final é registrada, mas não é um bloqueio de sucesso

**Severidade:** alta.

**Arquivos/linhas:** `run_lag_misspecification_persistence.R:147-207`, especialmente `:157-179` e `:277-283`; `R/metrics.R:131-173`; `task14_protocol.md:44-46`.

`lmp_write_outputs()` produz `validation <- lmp_output_validation(...)` e grava o CSV, mas não interrompe se algum `passed` for falso. Em seguida, o runner pode renderizar o relatório e emitir “run complete”. Logo, uma violação de schema, contagem, sementes, coeficientes/SEs ou lags selecionados pode gerar uma saída final e PDF aparentemente completos, embora o protocolo descreva essas verificações como validação final.

**Reparo exigido:** depois de gravar um registro diagnóstico atômico (ou antes de promover os artefatos finais), interromper se `!all(validation$passed)`. O manifesto deve registrar o estado `failed_validation`; a renderização só pode ocorrer quando a validação e a comparação de hashes forem integralmente PASS. Acrescentar ao smoke um input sintético inválido que confirme a recusa.

### F-03 — Denominadores efetivos de ACF e dos shifts pareados não são auditáveis

**Severidade:** média.

**Arquivos/linhas:** `R/metrics.R:7-43`, `R/metrics.R:76-100`; `task14_protocol.md:22-24`.

No sumário principal, `mean_residual_acf1` remove NAs, mas somente `n_success` é salvo; portanto não se sabe quantas ACFs finitas constituem a média/MCSE. No sumário de shifts, `n_success` conta êxitos em `Z_lag`, embora cada shift exija o par `no_Z`/`Z_lag` e o shift contemporâneo exija adicionalmente o ajuste `Z_contemporaneous`. Não há `n_attempted`, `n_failed` ou denominador de pares válidos nesse arquivo.

Isso não contaminou o smoke corrente (todas as linhas eram válidas), mas contradiz a disciplina declarada de relatar o denominador de toda proporção/métrica baseada em fits bem-sucedidos e dificultará interpretar células com falhas parciais.

**Reparo exigido:** salvar, por grupo, `n_attempted`, `n_success_z_lag`, `n_acf_finite`, `n_delta_lag_pairs` e `n_delta_contemporaneous_pairs`; calcular cada média e MCSE com seu denominador correspondente. Documentar esses denominadores no dicionário de outputs e testar uma falha parcial sintética.

## Itens auditados sem falha material

- **DGP ADL(1/2/3):** o grid é exatamente `3 x 3 x 3`; os vetores de lags de `Y` e a sequência geométrica dos lags de `D` correspondem ao protocolo (`R/config.R:24-93`, `R/dgp.R:26-58`).
- **Timing de `Z`:** `Z_lag` é colocado no tratamento e no desfecho antes de `Z_t`; `Z_t` recebe `D_t` e `Y_t` depois, logo é coerente como diagnóstico pós-tratamento, não estimador admissível do CET (`R/dgp.R:26-58`, `R/estimators.R:48-60`).
- **Within e inferência:** a transformação de duas vias pressupõe painel balanceado e o smoke confirmou o coeficiente frente a `fixest::feols()` (`R/estimators.R:1-35`, `smoke_test.R:55-64`). O erro-padrão é clusterizado por unidade, coerente com o DGP sem choque temporal comum; cobertura continua sendo métrica numérica, não prova de identificação causal.
- **AIC/BIC:** todos os candidatos usam a mesma amostra residualizada, os mesmos FE e `Z_lag`; só variam os regressors dinâmicos e a penalidade. A omissão da parte constante de FE da penalidade não altera o ranking entre candidatos (`R/estimators.R:48-90`, `R/estimators.R:112-128`).
- **Retenção de falhas:** falha do DGP produz as 15 linhas previstas; uma falha de candidato impede AIC/BIC de selecionar subconjunto favorável; regras não afetadas continuam (`R/simulation.R:15-58`, `R/simulation.R:114-219`).
- **Seeds/checkpoints/hashes:** as sementes são únicas por cenário-repetição; checkpoints são escritos por cenário. A comparação de hashes detecta adição, remoção ou alteração fora do novo pacote (`R/config.R:179-195`, `run_lag_misspecification_persistence.R:58-67`, `:104-113`, `:263-275`).
- **Claims do Rmd:** o relatório se mantém, em geral, dentro do desenho: chama `Z_t` de diagnóstico e afirma que critérios de informação não estabelecem timing/identificação. A frase de scope condition deve continuar condicionada aos reparos acima e jamais ser apresentada como validação causal geral (`lag_misspecification_persistence_report.Rmd:186-202`).

## Limites desta revisão e handoff

Não existem resultados full a auditar, como esperado para um pacote pré-execução. Portanto, não foi possível conferir 500 repetições por célula, CSVs finais do grid integral, hashes antes/depois da bateria integral ou o PDF integral. O parecer canônico atualmente presente no caminho que o runner consulta também não contém `## Verdict: PASS`; este parecer externo, por solicitação, está em outro caminho e não deve ser copiado para o gate sem uma nova revisão após os reparos.

Até F-01 e F-02 serem resolvidos e F-03 ser tornado auditável, não executar `--mode full --approved` nem usar resultados para atualizar o manuscrito.
