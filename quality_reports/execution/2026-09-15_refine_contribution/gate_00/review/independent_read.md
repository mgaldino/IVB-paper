# Gate 0 — leitura independente anterior ao confronto

**Revisor:** agente `gate0_reviewer`, separado dos implementadores.  
**Data:** 2026-09-15 UTC.  
**Estado:** leitura independente concluída; parecer do Gate 0 pendente do congelamento dos novos artefatos.  
**Limite de escrita:** este diretório `review/`. Nenhum inventário, matriz, fonte, código ou output analítico do implementador foi alterado.

## 1. O que precisa estar demonstrado

O Gate 0 deve tornar verificáveis o argumento efetivo do paper, as críticas recebidas e o estado dos materiais existentes. Não precisa resolver já a contribuição, corrigir provas, escolher aplicação ou calibrar inferência. Deve, porém, impedir que essas etapas partam de uma leitura errada, de números sem origem ou de uma alegação indevida de trabalho concluído.

A regra de aprovação vem de `quality_reports/plans/2026-09-15_refine_contribution/plan.md:99-113`: cobertura das seções e comentários, origem de números reutilizados e ausência de desacordo sobre o conteúdo do paper que impeça o próximo gate. A separação entre implementar e revisar vem de `CLAUDE.md`, seção Workflow obrigatório, e do plano, seção 3.1.

## 2. Identidade e independência

- Commit de entrada declarado no baseline: `731cd6570651ea0f602d5c7cdff89ab43ecdb962`, checkout inicialmente limpo conforme manifesto do coordenador. O estado inicial não foi observado por este revisor antes de outros agentes escreverem; a declaração é atribuída ao manifesto.
- Todos os 17 arquivos do `baseline_manifest.json` foram re-hashados por este revisor e coincidiram com o SHA-256 registrado.
- PDF PA: `5375d3c27ac1b75ca7246f0e7483470d98a69cf129a853560ae84cfe107d447c`.
- Fonte PA: `12493a67133f988c5e6a13933bf2b89c0d9880e96bae329248a207b3aeaf7b5e`.
- Contrato reutilizado: `ivb-pa-refine:5375d3c27ac1:round1`, em `quality_reports/argument_contracts/ivb-pa-refine/5375d3c27ac1/`. A identidade de todas as fontes editáveis listadas nele foi confirmada pelo baseline re-hashado. O validador oficial retornou `VALID`.
- Fonte e PDF são os mesmos bytes locais da preparação. Isso não prova identidade do arquivo originalmente enviado ao Refine: não há recibo/hash desse upload.
- Foram lidos fontes, contrato e evidências históricas antes de qualquer relatório novo dos implementadores de Gate 0. A adjudicação histórica foi consultada depois da leitura própria dos pontos controversos.
- A consulta curta a `MEMORY.md` não encontrou entrada relevante; nenhuma conclusão usa memória pessoal.

## 3. Cobertura reaproveitada e ampliada

A skill `argument-fidelity-gate` permite reutilização mediante identidade, cobertura e disponibilidade dos registros. O contrato histórico cobre sete seções, corpo, figuras/tabelas e derivações vinculadas; seu PASS é de fidelidade no escopo de planejamento, não de validade científica. Há sete registros de seção, produzidos historicamente por quatro agentes em turnos delimitados; não são sete contextos independentes.

A leitura atual percorreu o corpo da fonte e o código das tabelas/figuras nos trechos relevantes: introdução e problema (`178-207`), relógios e DAGs (`208-386`), diagnóstico e condições (`387-502`), simulações (`503-643`), aplicações (`644-823`) e conclusão (`824-836`). O registro histórico continua cobrindo a leitura renderizada. **Não foi feita nova inspeção visual integral do PDF**, nem se reivindica um novo PASS visual.

A cobertura foi ampliada para:

1. lista programada de candidatos (`ivb_paper_pa.Rmd:141-175`), CSV completo e distinção das comparações adicionais (`762-796`);
2. todas as 26 tarefas do plano de julho, com leitura dos objetivos, entregáveis e validações;
3. cinco comentários gerais, 12 detalhados e texto integral complementar;
4. rastreamento da cobertura a `metrics.R`, `simulation.R`, phase-map data e sumário de Task 13;
5. identificação das condições na nota ADL (`63-145`), prova vetorial (`35-160`) e limites da nota de incerteza (`230-264`);
6. estado documental do pacote Task 14, incluindo README, arquivos disponíveis, log e pareceres históricos conflitantes.

## 4. Reconstrução independente do argumento

| Objeto | O que a fonte efetivamente afirma | Localizador e limite |
|---|---|---|
| Deslocamento amostral | OLS aninhado, amostra comum e regressoras comuns dão `Delta_hat = -theta_hat' pi_hat`. | Rmd `389-420`; não classifica causalmente os controles. |
| Alocação entre controles | O deslocamento conjunto é único; incrementos sequenciais dependem da ordem; leave-one-out não soma necessariamente ao conjunto. | Rmd `408-422`; atribuição de projeção, não de mecanismo causal. |
| CET | Efeito de exposição atual com história prévia definida e outcome pertinente ao relógio. | Rmd `214-238`; mediador e collider requerem relógios diferentes. |
| ADL + FE | Baseline condicional à história suficiente, identificação, suporte, forma funcional e estimação adequados. | Rmd `457-501`; não é solução universal, nem o calendário certifica admissibilidade. |
| Inferência do deslocamento | Preservar covariância entre estimadores; propõe bootstrap de unidades e sandwich empilhado. | Rmd `424-438`; implementação documentada é escalar e não foi calibrada nas aplicações. |
| Simulações | Comparações delimitadas aos DGPs e grades exibidos. | Rmd `551-642`; intervalos MC de média, cobertura do coeficiente longo e IC de Delta são objetos diferentes. |
| Aplicações | Diagnósticos descritivos intencionais, com contrastes defasado/prospectivo e timing ambíguo. | Rmd `646-650`, `732-736`, `822`; não instanciam a aplicação central CET. |
| Fronteiras | O paper não estabelece resultados para SDiD, fatores, regimes ou links não lineares. | Rmd `444`, `828-832`; PSRM e IVB-SDiD devem permanecer preservados. |

Intuição: duas regressões podem produzir uma diferença exata e perfeitamente reproduzível sem que essa diferença indique qual identifica o efeito desejado. A álgebra registra a mudança; o relógio causal e as hipóteses dizem o que ela significa. O Gate 0 precisa preservar essa distinção inclusive ao classificar o que já foi desenvolvido.

## 5. Tensões que o novo registro deve preservar

Estes são pontos candidatos para confronto, não uma nova adjudicação final do Gate 0.

| Ponto | Evidência própria | Critério de correção do registro |
|---|---|---|
| Inclusão versus substituição | Rmd `408-420` define inclusão aninhada; `451` diz “moved”; workflow `635-637` não explicita retenção dos lags. | Registrar ambiguidade operacional sem invalidar a identidade; encaminhar decomposição da troca e escolha do contraste ao Gate 2. |
| Intercambialidade com FE | Rmd `465` abrevia o condicionamento; nota ADL `63-73` inclui história, alfa e tau. | Não afirmar ausência global da condição ou prova inexistente; rechecagem formal é trabalho posterior. |
| Efeito direto | Rmd `315` reconhece hipóteses adicionais; `442` diz “Only the DAG”. | Preservar inconsistência localizada; não atribuir tese universal ao paper. O contrato antigo aponta `441`, linha vazia atual; novo localizador preciso é `442`. |
| Relógio do collider | Rmd `222` diz “any within-period responses”; `238` diferencia explicitamente o collider. | Distinguir tensão local de incoerência geral dos DAGs. |
| Pós-tratamento conhecido | Rmd `250` oferece apenas “plausible or ambiguous” fora da anterioridade. | Encaminhar categoria temporal documentadamente posterior, mantendo papel causal separado. |
| Figura 4 | Caption Rmd `551`: quatro modelos, nenhum inclui Z contemporâneo. | Não apresentá-la como evidência direta da inclusão de collider contemporâneo; conservar a evidência de estado defasado/dinâmica. |
| Figura 5 | Rmd `583` usa “isolates”; comparação é entre viés de long e média da diferença. | Separar deslocamento populacional e viés de estimação; não dizer que o phase map já faz essa decomposição. |
| Tabela 6 | Alvos mistos 1.03/1.00; estimativas 1.023/1.016. Distâncias para total são .007/.014 e para direto .023/.016. | Registrar limitação da caracterização “near direct”, sem modificar alvos ou inventar ICs. |
| Aplicação e roadmap | Rmd `194` promete interação com baseline; `650` e `736` dizem que os casos não mostram CET diretamente. | Registrar lacuna da aplicação central e ressalvas existentes simultaneamente. |

## 6. Conferências numéricas independentes e denominadores

### 6.1 Candidatos e linhas exibidas

Reproduzindo em Python apenas o filtro literal da fonte sobre o CSV salvo, encontrei **14 pares únicos estudo-especificação/controle**, correspondentes a **seis estudos**, mas **sete rótulos de especificação** porque Leipziger aparece em versão SEI e SEI estendida:

- Claassen (FE): Log GDP p.c. (1).
- Leipziger (SEI): Log GDP p.c.; Leipziger (SEI ext.): Civil war, GDP growth (3 no estudo).
- Blair et al.: Foreign Aid, GDP per capita, Refugees/IDPs (3).
- Albers et al.: Hyperinflation, GDP growth (YoY), Liberal democracy (3).
- Rogowski et al.: Log GDP p.c. (1).
- Ballard-Rosa et al.: Inflation crisis, IMF program, Sov. debt crisis (3).

A tabela Leipziger exibe GDP. A tabela Rogowski exibe GDP e **três comparações adicionais**: Log population, Urbanization e Polity2 (`762-768`). Portanto, cinco linhas exibidas equivalem a dois candidatos selecionados mais três extras; não são cinco dos 14.

As três razões de Albers em `IVB_over_SE` são `NA`. Entre os **11 candidatos com razão disponível**, a mediana absoluta é `0.126873193968874`, o máximo é `2.1075941609384` e um excede 1. O CSV completo tem 55 linhas e 43 razões disponíveis; o máximo nele também é Rogowski/GDP com o mesmo valor. Esses universos não são intercambiáveis, nem constituem amostra representativa. `na.rm=TRUE` na fonte não autoriza escrever que a mediana usa 14 valores observados.

Houve uma tentativa inicial de conversão numérica que falhou ao encontrar `NA`; a conferência foi refeita com exclusão explícita e contagem das ausências. Não foram estimados modelos.

### 6.2 Cobertura 0.700

- O sumário salvo registra 54 células por estimador, 0 e 6 células satisfazendo o phase condition, máximo de viés `0.0454296317922152`, máximo da média absoluta do shift `0.0381323662151438`, cobertura mínima `0.7`, 500 replicações por célula.
- `simulations/finite_T_dynamic_panel/R/metrics.R:57` calcula a média de `covered_long` entre linhas bem-sucedidas.
- `simulation.R:70-111` verifica se `beta_true` está no intervalo do coeficiente longo; `150-158` conecta esse alvo ao CET.
- O mínimo no phase-map data é a célula `P_N250_T08_RY50`, estimador `hpj_fe_adl`, N=250, T=8, rhoY=.5; não é uma célula de cobertura do IC de Delta.
- A auditoria histórica de Task 13 tem sete checks PASS de números e universo de 108 células. Isso é evidência documental de execução anterior; esta revisão não rerodou Monte Carlo nem avaliou nova cobertura.

## 7. O que verificarei no inventário das 26 tarefas

Cada ID Task 01–26 deve aparecer exatamente uma vez, com arquivo(s), output(s), evidência de teste observada, validade para a pergunta atual e retrabalho. Exijo diferença entre planejado, implementado, execução parcial, execução concluída, inspeção estática e validação científica. Arquivo não localizado deve ser descrito como não localizado no escopo pesquisado, não como impossibilidade de existência.

Agrupamentos para cobertura: 01 matriz; 02–06 álgebra/alvo/identificação/DAGs/linguagem; 07–09 múltiplos controles/alocação/inferência; 10–12 acervo de simulações e integração; 13 painéis curtos; 14 escolha de lags; 15 controles correlacionados; 16 calibração de Delta; 17–18 gates condicionais de heterogeneidade/dependência; 19–23 seleção/reprodução/DAGs/aplicações/inferência; 24–26 reescrita/pipeline/QA final.

Checagens críticas:

- Task 09: `derivations/specification_shift_uncertainty.Rmd:260-264` declara que não houve bootstrap, CI, simulação ou cobertura; escopo é controle escalar, OLS sem pesos, amostra comum, clustering por unidade. Existência do script não encerra Task 16.
- Task 13: outputs e auditoria numérica existem; o significado científico de “isolates” continua pendente. Não reduzir tudo a inexistente nem promover o resultado a calibração de Delta.
- Task 14: o README descreve um pacote amplo de outputs; a árvore de `results/` observada contém somente dois checkpoints (`L1_RD20_CO00.csv`, `L1_RD20_CO25.csv`) e um log de início de full em 2026-07-12. Não localizei outputs finais da grade nesse diretório. Há um PASS pré-execução e um REPAIR externo com F-02/F-03. Os registros precisam ser conciliados com os bytes atuais antes de reutilizar execução. A presença do REPAIR não prova, sozinha, que os defeitos ainda existam; o PASS não prova conclusão da bateria.
- Tasks condicionais 17–18: ausência de bateria não equivale automaticamente a falha; procurar decisão go/no-go e fronteira de escopo.
- Tasks 24–26: o Rmd contém estimação nas aplicações (`752-781` e bloco Leipziger), logo um pipeline que apenas importe resultados não pode ser declarado já integralmente satisfeito.

## 8. Matriz: critérios mínimos de aceitação

A matriz deve cobrir **17 comentários originais (5 gerais + 12 detalhados) e quatro eixos complementares**, preservando a distinção de suas fontes. Os quatro eixos são: valor diagnóstico distinto; aplicação central compatível com CET; baseline operacional; reconciliação de substituição e nesting. Eles podem apontar para os mesmos problemas dos 17 comentários, mas não desaparecer por deduplicação.

Para cada entrada: ID estável; trecho/localizador; diagnóstico distinto da solução sugerida; classificação CONFIRMED/PARTIAL/REFUTED/UNRESOLVED; evidência e contrapeso; gate responsável; dependências; critério observável de encerramento. Itens de desenho seguem abertos para o gate competente. O Gate 0 pode aprovar a identificação da lacuna sem aprovar antecipadamente a solução científica.

A adjudicação histórica registra 7 confirmados e 10 parciais para os 17. Os totais não são um alvo a preservar por conveniência: mudanças requerem justificação localizada. A resposta complementar contém otimismo editorial, mas não evidência que certifique novidade ou publicabilidade.

## 9. Próximo confronto e fronteiras

Quando o coordenador congelar os novos artefatos, verificarei seus hashes, cobertura, consistência cruzada e amostras de proveniência contra os pontos acima. Se aparecer um achado, ele será candidato com localização e critério de correção; o implementador fará eventual mudança. A rechecagem posterior será dos bytes corrigidos e dependências afetadas.

Nesta fase executei leitura de arquivos, busca de caminhos, SHA-256, validação estrutural do contrato e aritmética sobre CSVs existentes com Python. **Não executei R, não reestimei modelos, não renderizei o paper, não fiz nova QA visual, não pesquisei novidade na web, não editei o manuscrito e não revisei artefatos novos de Gate 0.** A leitura integral da literatura pertence ao Gate 1.
