# Gate 0 — inventário documental

**Snapshot:** 2026-09-14, no repositório `/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper`. **Base declarada:** commit `731cd6570651ea0f602d5c7cdff89ab43ecdb962`. **Escopo de escrita:** somente este diretório `quality_reports/execution/2026-09-15_refine_contribution/gate_00/inventory/`.

Este memo deixa uma trilha para quem retomar o paper depois de seis meses. O resultado principal é uma fronteira testável: o repositório contém uma identidade base congelada, materiais formais e resultados registrados para Tasks 10–13, e uma seleção de 14 candidatos que pode ser reconciliada com o código e o CSV. A evidência não fecha a revisão inteira. Task14 tem apenas checkpoints e log inicial, e as tarefas de inferência aplicada, DAGs concorrentes, tabelas revisadas, pipeline integral e QA final continuam incompletas. O CSV `task_inventory.csv` é o índice completo das 26 tarefas; os outros CSVs tornam auditáveis a seleção, as comparações de Rogowski, os quatro números pedidos e os hashes.

## 1. Identidade, fonte e limites

- `CLAUDE.md`, o Gate 0 de `quality_reports/plans/2026-09-15_refine_contribution/plan.md:101-115`, o plano de julho inteiro e os documentos integrais de feedback foram lidos.
- A fonte ativa continua sendo `ivb_paper_pa.Rmd`; o PDF ativo é `ivb_paper_pa.pdf`. O `baseline_manifest.json` registra, para a fonte ativa, SHA256 `12493a67133f988c5e6a13933bf2b89c0d9880e96bae329248a207b3aeaf7b5e` e, para o PDF, `5375d3c27ac1b75ca7246f0e7483470d98a69cf129a853560ae84cfe107d447c`. Os mesmos hashes estão em `input_sha256.csv`.
- O manifesto de base informa status inicial sem mudanças rastreadas. No snapshot atual, o Git mostra a árvore de execução como não rastreada, inclusive os artefatos deste inventário; não há edição rastreada do manuscrito, dos scripts ou dos resultados.
- O feedback original foi preservado e hasheado (`quality_reports/Referee-Style Feedback.pdf` e `quality_reports/plans/2026-09-15_refine_contribution/evidence/refine_feedback_original.md`). A adjudicação integral `quality_reports/adjudication/ivb-pa-refine/5375d3c27ac1/adjudication_round1.md:9-30` classifica os 17 achados como 7 `CONFIRMED`, 10 `PARTIAL`, 0 `REFUTED` e 0 `UNRESOLVED`. Isso é o registro de adjudicação existente, não uma decisão causal nova desta tarefa.
- A convenção deste memo é: “observado” significa presente em um arquivo ou relatório; “teste registrado” significa que um relatório/manifesto afirma o teste; “executado agora” só aparece quando foi realizado nesta passagem. Não houve execução analítica nesta passagem.

## 2. Como ler o inventário das 26 tarefas

`task_inventory.csv` tem exatamente 26 linhas, `T01`–`T26`, com o localizador do plano de julho, objetivo, arquivos e outputs realmente localizados, testes registrados, status, validade para a pergunta atual e retrabalho. Os status não são um novo gate editorial; são rótulos documentais para não confundir código existente com entrega concluída.

Os pontos que mais afetam a retomada são:

- **T01–T03:** matriz de resposta, separação `Delta_Z`/viés e checklist de timing têm artefatos identificáveis. A matriz reúne 35 itens únicos das seções relevantes do parecer; a adjudicação separa 5 comentários gerais e 12 detalhados.
- **T04–T09:** há notas e scripts de derivação, incluindo FE na nota ADL e testes registrados para as identidades multivariadas/alocação. A nota de incerteza é apenas maquinaria preliminar: declara que ainda não produz bootstrap, IC, coverage ou inferência aplicada.
- **T06:** a Table 3, intitulada “Standardized scope conditions for using ADL + FE with lagged state variables as a CET baseline”, existe nos bytes atuais de `ivb_paper_pa.Rmd:479-499` e contém oito condições. O status parcial de T06 registra a suficiência, a consistência com as hipóteses e a auditoria das ocorrências residuais como questões ainda abertas nos gates 2–3/6; não registra ausência da tabela.
- **T10–T12:** o inventário de simulações, a Figura 2/firewall e a auditoria de boundary conditions possuem CSVs, manifests ou validações históricas. `dual_role_varyT` permanece marcado como output declarado ausente no inventário de simulações; isso não deve ser preenchido por inferência.
- **T13:** é o pacote com resultados completos localizados. O relatório de reprodutibilidade confere 54 células principais por estimador, 108 células exibidas, 500 repetições por célula e coverage mínima de 0.700. A revisão Terra/high registrada é `PASS` pré-execução do pacote; a auditoria posterior dos outputs também está registrada. Task13 não deve ser misturada ao estado incompleto de Task14.
- **T14:** o README anuncia a forma esperada de outputs, mas a árvore atual contém apenas `results/checkpoints/L1_RD20_CO00.csv`, `results/checkpoints/L1_RD20_CO25.csv`, `results/full_console.log` vazio e `results/run_log.txt` com a mensagem inicial de uma execução full. Não foram localizados `raw_replications.csv`, sumários finais, manifests, session info ou PDF final. O PASS de `independent_review_terra_high.md` é pré-execução; os pareceres externos e o rereview são `REPAIR`. A inspeção dos bytes atuais confirma que `metrics.R:131-179` monta a tabela `validation` sem abortar no retorno falso, que `metrics.R:7-42` grava `n_success` mas não `n_acf_finite`, e que `metrics.R:76-111` filtra shifts finitos sem gravar contagens de pares. Portanto o conflito histórico deve ser preservado, e o retrabalho deve reparar/validar esses pontos antes da bateria integral.
- **T15–T18:** não há pacote de simulação dedicado para múltiplos controles/intervalos; há somente o exemplo de alocação da Task08. Existem um script e CSV de diagnóstico de heterogeneidade, mas nenhum memo go/no-go para T17, e nenhum pacote dedicado a fatores comuns para T18. Os rótulos `sequence_pending`/`gate_pending` registram a sequência e os gates do plano de julho; não são uma solicitação de aprovação adicional nesta passagem.
- **T19–T23:** a lista de seleção e os outputs padronizados existem, mas não foram localizados protocolo completo, codebook, dois codificadores, seis fichas PASS/FAIL, DAGs concorrentes ou tabela com CI pareado de `Delta_Z`. As tabelas atuais mantêm point shifts e comparação de escala com SE de endpoint.
- **T24–T26:** o manuscrito PA ativo já usa parte da linguagem condicional, porém não há changelog argumental da nova arquitetura, pipeline mestre end-to-end ou checklist final desta revisão. Revisões históricas não equivalem ao gate final.

## 3. Universo de aplicações e intuição dos denominadores

O código do PA define a seleção em `ivb_paper_pa.Rmd:141-148`, filtra o CSV em `:151-166` e calcula `n_candidates` e as métricas em `:168-175`. O filtro e o `replication/standardized_ivb_metrics.csv` concordam nos 14 rows listados em `application_candidates.csv`:

| grupo de estudo | composição selecionada | contagem |
|---|---|---:|
| Claassen (FE) | Log GDP p.c. | 1 |
| Leipziger (SEI) | Log GDP p.c. | 1 |
| Leipziger (SEI ext.) | Civil war; GDP growth | 2 |
| Blair et al. | Foreign Aid; GDP per capita; Refugees/IDPs | 3 |
| Albers et al. | Hyperinflation; GDP growth (YoY); Liberal democracy | 3 |
| Rogowski et al. | Log GDP p.c. | 1 |
| Ballard-Rosa et al. | Inflation crisis; IMF program; Sov. debt crisis | 3 |
| **Total** | **seis grupos de estudos** | **14** |

O script `replication/compute_standardized_ivb.R` produz um universo maior de rows (inclui especificações, controles e estudos alternativos). A seleção do PA é um filtro explícito desse output, não o total de linhas do CSV. Em particular, `Rogowski et al.` tem quatro controles na construção em `ivb_paper_pa.Rmd:761-768` e no loop do script padronizado `compute_standardized_ivb.R:272-290`. O GDP é o único Rogowski dentro dos 14; população, urbanização e Polity2 são as três comparações adicionais, listadas separadamente em `rogowski_additional_comparisons.csv`. A Tabela 8 do PA (`ivb_paper_pa.Rmd:799-820`) mostra os quatro, mas isso não transforma os três extras no universo selecionado.

Dos 14 candidatos, 11 têm `SE_beta` e `IVB_over_SE` observáveis. As três linhas de Albers (C08–C10) têm `SE_beta=NA` no CSV e, portanto, não entram em uma estatística que usa `na.rm=TRUE`. A recontagem documental dá:

- denominador de candidatos: **14**;
- denominador de razões `|IVB/SE|`: **11**;
- mediana de `abs(IVB_over_SE)` entre as 11 razões: **0.126873193968874**;
- máximo de `abs(IVB_over_SE)`: **2.1075941609384**;
- número de razões acima de 1: **1** (Rogowski, Log GDP p.c.).

Esse é o motivo para não escrever “mediana sobre 14” ou “todas as aplicações” ao reutilizar o resumo. A estatística é de escala do endpoint; o PA declara em `ivb_paper_pa.Rmd:646` e `:732,822` que não há intervalo pareado para `Delta_Z` e que a interpretação causal exige timing, DAG e hipóteses.

## 4. Proveniência dos quatro números pedidos

`number_provenance.csv` traz os locators e os limites; a intuição curta é:

- **0.700** é a menor proporção de cobertura empírica de 95% do **CET** na grade principal da Task13, no estimador HPJ FE-ADL, com 54 células e 500 repetições por célula. É uma característica do DGP/grade registrada no output auditado, não coverage de uma CI de `Delta_Z`.
- **1.023** e **1.016** são arredondamentos do intervalo `1.016–1.023` reportado para `adl_DYlag_Z` no desenho linear `mediator_confounder`. As linhas exatas do CSV agregado são `1.02279289983417` (`rho_Z=0.5`, baseline) e `1.01623698228499` (`rho_Z=0.7`, baseline). Cada linha informa 500 válidos e zero descartados. O relatório também registra alvos linear direto 1.000 e total 1.030; esses números devem permanecer ligados ao DGP, sem transformar o valor em CI ou decisão causal.
- **14** é a contagem do filtro de candidatos no código do PA, confirmada pelos 14 rows selecionados no CSV e pela soma 1+1+2+3+3+1+3. O denominador de razões disponíveis é 11, porque três Albers não têm SE.

## 5. Comandos e fronteira executado/não executado

### Comandos de inspeção executados nesta passagem

Foram usados comandos somente de leitura e `apply_patch` para escrever os artefatos deste diretório:

```text
git status --short --untracked-files=all
git log -1 --format='%H %s'
find .../gate_00 -maxdepth 2 -type f -print
nl -ba quality_reports/plans/2026-07-10_referee_feedback_revision_plan.md | sed -n '30,360p'
nl -ba quality_reports/plans/2026-09-15_refine_contribution/plan.md | sed -n '101,115p'
nl -ba ivb_paper_pa.Rmd | sed -n '130,180p;630,840p'
nl -ba replication/compute_standardized_ivb.R | sed -n '25,350p'
nl -ba simulations/lag_misspecification_persistence/R/metrics.R | sed -n '1,190p'
nl -ba simulations/lag_misspecification_persistence/run_lag_misspecification_persistence.R | sed -n '115,220p'
rg -n -C 2 '0\.700|min_coverage|54|500|coverage' quality_reports/task13_finite_T_dynamic_panel/... simulations/finite_T_dynamic_panel/results/...
python3 (leitura CSV, contagem dos 14/11, localização dos rows de Rogowski e dos valores 1.016/1.023)
python3 (hashlib.sha256 para input_sha256.csv)
ls -l simulations/lag_misspecification_persistence/results ...
wc -c simulations/lag_misspecification_persistence/results/full_console.log ...
shasum -a 256 simulations/lag_misspecification_persistence/results/full_console.log
```

Uma tentativa auxiliar de `find -printf` não é suportada pelo `find` desta máquina; ela não editou nada. Os hashes finais usados no inventário foram calculados com `hashlib.sha256`; `input_sha256.csv` contém 102 entradas, todas existentes e com digest de 64 caracteres.

### Comandos deliberadamente não executados

Não foram executados `Rscript`, `rmarkdown::render`, runners de simulação, bootstrap, estimação ou reestimação das aplicações, Stata `.do`, geração de novo PDF do manuscrito, nem qualquer push/commit/publicação. Também não foram editados `ivb_paper_pa.Rmd`, `ivb_paper_pa.pdf`, scripts, CSVs ou resultados existentes. Os PASS de Task11–Task14, os smoke tests e os audits citados acima são evidência observada nos registros anteriores; não são testes novos desta passagem.

## 6. Pendências para a retomada

1. Usar `task_inventory.csv` como índice de dependências, começando pela reconciliação T02–T04 e pelos DAGs/timing T03/T05.
2. Tratar Task13 como pacote de outputs existentes auditados e Task14 como preparação incompleta. Reexaminar e reparar o bloqueio de validação e os denominadores efetivos de Task14 antes de qualquer resultado full.
3. Fechar seleção/coding e fichas de reprodução dos seis estudos; preservar a tabela dos 14 e as três comparações extras de Rogowski em universos distintos.
4. Implementar incerteza pareada de `Delta_Z`, tabelas e gates condicionais somente dentro da sequência do plano; não preencher lacunas por extrapolação dos números registrados.
5. Só após a integração e o pipeline end-to-end executar o QA visual, a auditoria numérica e o gate editorial final.

## 7. Arquivos entregues

- `task_inventory.csv`: 26 tarefas, com estado e retrabalho.
- `application_candidates.csv`: 14 candidatos selecionados, valores e denominador 11 para `IVB/SE`.
- `rogowski_additional_comparisons.csv`: três controles extras de Rogowski, separados do universo 14.
- `number_provenance.csv`: 0.700, 1.023, 1.016 e 14, com locators, denominadores e limites.
- `input_sha256.csv`: 102 entradas SHA256 de fontes, outputs e registros usados.
- `memo.md`: este registro de escopo, proveniência, intuição, comandos e pendências.
