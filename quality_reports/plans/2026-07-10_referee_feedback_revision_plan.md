# Plano de revisão do IVB-paper após o Referee-Style Feedback

**Data:** 2026-07-10  
**Manuscrito-base:** `ivb_paper_pa.Rmd`  
**Feedback:** `quality_reports/Referee-Style Feedback.pdf`  
**Diagnóstico editorial:** major revision com núcleo publicável  
**Regra operacional:** nenhuma nova simulação será executada sem aprovação do autor; toda computação ficará em scripts R separados e o RMarkdown apenas lerá resultados produzidos.

## Avaliação crítica do parecer

O parecer acerta no problema central. O manuscrito ainda usa “bias” para um objeto que, sem hipóteses causais adicionais, é apenas a diferença entre duas projeções lineares aninhadas. A revisão precisa separar formalmente: (1) classificação causal do controle; (2) deslocamento descritivo do coeficiente; e (3) viés em relação ao CET. Essa mudança deve organizar o paper inteiro.

Também são essenciais as críticas sobre condições de identificação do ADL, DAGs dinâmicos, múltiplos controles, incerteza do diagnóstico e protocolo das aplicações. Esses pontos ampliam a contribuição real do paper sem mudar sua natureza.

Parte da crítica às simulações decorre de informação ausente na versão PA, não de análises inexistentes. O repositório já contém variação de `T`, RMSE, coverage, tratamento binário escalonado, não linearidades, erro de medida, feedback, carryover e confounding não observado. Antes de produzir novas evidências, será necessário auditar e integrar esses resultados.

O parecer exagera ao sugerir que a revisão deva comparar de forma abrangente ADL com MSM, g-computation, structural nested models, modelos não lineares, fatores comuns e toda a literatura de painéis heterogêneos. Isso transformaria o paper em outro projeto. A revisão atual deve fazer uma comparação conceitual de escopo e executar apenas análises diretamente ligadas às alegações centrais.

## Prioridades e gates

- **P0 — indispensável:** precisa estar concluída antes de uma nova avaliação integral do manuscrito.
- **P1 — alto retorno:** fortalece substancialmente contribuição e execução; deve ser concluída antes da submissão.
- **P2 — condicional:** executar somente se os resultados P0/P1 ou uma nova revisão mostrarem necessidade.
- **Gate A — núcleo formal:** Tasks 01–06.
- **Gate B — diagnóstico operacional:** Tasks 07–09.
- **Gate C — evidência de simulação:** Tasks 10–18.
- **Gate D — aplicações:** Tasks 19–23.
- **Gate E — integração e saída:** Tasks 24–26.

## Task 01 — Criar matriz de resposta ao parecer

**Prioridade:** P0  
**Objetivo:** transformar as recomendações do PDF em uma matriz rastreável: comentário, validade, evidência já existente, ação, arquivo responsável e status.  
**Entregáveis:** `quality_reports/referee_feedback_response_matrix.csv` e nota curta em Markdown.  
**Validação:** todo item das seções 5, 8, 9, 10 e 12 do feedback deve aparecer exatamente uma vez; nenhuma recomendação pode ficar sem decisão explícita.  
**Como entra no paper:** não entra diretamente; controla a revisão e servirá de base para uma futura carta de resposta.

## Task 02 — Separar formalmente deslocamento de especificação e viés causal

**Prioridade:** P0  
**Objetivo:** definir três objetos distintos: deslocamento populacional `Delta_Z = beta_long - beta_short`, deslocamento amostral `hat(Delta)_Z`, e viés causal `Bias(hat(beta); beta_CET)`. Reservar “included variable bias” para casos em que o DAG e as hipóteses de identificação estabelecem que a inclusão de `Z` afasta o estimador do CET.  
**Derivação:** mostrar por FWL que `hat(Delta)_Z = -hat(theta)'hat(pi)` é uma identidade de projeção. Demonstrar separadamente: collider, mediador com alvo total, confounder e papel ambíguo.  
**Entregáveis:** nota formal em `derivations/specification_shift_vs_ivb.Rmd` e PDF correspondente.  
**Validação:** checagem algébrica simbólica ou numérica em dados simulados; revisão independente da derivação; nenhuma frase deve inferir causalidade apenas da identidade FWL.  
**Como entra no paper:** abstract, final da introdução, nova abertura da seção do diagnóstico, tabela de interpretações causais e conclusão. O título deverá ser reavaliado; candidato: “From Specification Shifts to Included Variable Bias in Dynamic Panels”.

## Task 03 — Definir o CET e a ordem causal dentro do período

**Prioridade:** P0  
**Objetivo:** substituir a leitura mecânica dos subscritos por uma sequência substantiva: estado no início de `t`, tratamento, resposta da covariável e mensuração do desfecho. Explicitar antecipação, tratamentos contínuos dentro do período e agregação anual.  
**Entregáveis:** definição do CET, tabela de timestamp mínimo para `D`, `Z` e `Y`, e checklist aplicado para justificar quando `Z_{t-1}` é realmente pré-tratamento.  
**Validação:** aplicar o checklist às duas aplicações detalhadas e mostrar onde a ordem é conhecida, plausível ou ambígua.  
**Como entra no paper:** primeira subseção da seção “DAGs and Timing”, antes de qualquer regra sobre lagged controls.

## Task 04 — Derivar as condições de identificação do benchmark ADL + FE

**Prioridade:** P0  
**Dependência:** Tasks 02–03.  
**Objetivo:** enunciar uma proposição que separe identificação populacional do CET e propriedades do estimador within em amostra finita.  
**Hipóteses a tratar:** consistência e ausência de interferência; história observada `H_{i,t-1}`; ausência de antecipação; exogeneidade condicional/sequencial de `D_it`; ausência de confounding contemporâneo não observado; ausência de feedback simultâneo `Y_it -> D_it`; lag structure corretamente especificada; suporte/positividade; linearidade e homogeneidade necessárias para interpretar um único coeficiente; papel dos efeitos fixos e dos choques temporais.  
**Derivação:** mostrar quando o coeficiente populacional de `D_it` na projeção ADL corresponde a `beta_CET`; depois separar o erro de estimação de ordem finita em `T`. Não afirmar que feedback de `Y_{t-1}` para `D_t` viola identificação se `Y_{t-1}` pertence corretamente ao histórico condicionado.  
**Entregáveis:** `derivations/adl_cet_identification_conditions.Rmd`, prova no apêndice e quadro “identificação versus estimação”.  
**Validação:** revisão causal independente e verificação de consistência com Blackwell–Glynn, Imai–Kim, Nickell e Arellano–Bond.  
**Como entra no paper:** nova seção entre o diagnóstico FWL e o benchmark; enunciado curto no texto principal e prova completa no online appendix.

## Task 05 — Substituir DAGs genéricos por três DAGs dinâmicos

**Prioridade:** P0  
**Dependência:** Tasks 03–04.  
**Objetivo:** representar os mecanismos efetivamente testados, não apenas collider, fork e chain elementares.  
**DAGs exigidos:** contemporaneous collider; dual role com `Z_{t-1}` confounder e `Z_t` collider; mediator contemporâneo com confounding defasado. No dual-role, destacar o caminho herdado e mostrar por d-separation quando condicionar em `Y_{t-1}` bloqueia sua transmissão.  
**Entregáveis:** três figuras TikZ reproduzíveis e uma nota de d-separation para cada uma.  
**Validação:** conferir graficamente todos os caminhos citados no texto e obter uma revisão independente dos DAGs.  
**Como entra no paper:** substituir a atual Figura 1; colocar o DAG dual-role imediatamente antes da atual Figura 2; versões completas no apêndice.

## Task 06 — Tornar a regra prática condicional e neutralizar os rótulos

**Prioridade:** P0  
**Dependência:** Tasks 03–05.  
**Objetivo:** trocar “safe”, “bad” e “dominates” por nomes descritivos das especificações. Reformular o benchmark como baseline condicional às hipóteses, não como estimador causal geral.  
**Entregáveis:** vocabulário padronizado e tabela de scope conditions: CET, timing conhecido, `T` adequado ou correção de viés, lag structure plausível, ausência de confounding contemporâneo não observado, sem spillovers relevantes.  
**Validação:** busca textual por `safe`, `bad`, `dominates`, `solves` e equivalentes; toda ocorrência deve ser justificada ou substituída.  
**Como entra no paper:** abstract, regra prática, captions, seção de limites e conclusão.

## Task 07 — Derivar a decomposição conjunta para múltiplos controles

**Prioridade:** P1  
**Dependência:** Task 02.  
**Objetivo:** generalizar o diagnóstico para um vetor `Z`, demonstrando `Delta_Z = -theta'pi`. Distinguir deslocamento conjunto, inclusão sequencial e contribuição leave-one-control-out.  
**Derivação:** provar por FWL a forma vetorial; provar que contribuições sequenciais telescopam mas dependem da ordem; mostrar por que leave-one-out não precisa somar ao deslocamento conjunto.  
**Entregáveis:** `derivations/multivariate_specification_shift.Rmd` e testes numéricos com controles correlacionados.  
**Validação:** identidade conjunta e identidades condicionais com tolerância numérica inferior a `1e-10`; revisão independente.  
**Como entra no paper:** uma proposição curta após a identidade escalar; prova e exemplos no apêndice.

## Task 08 — Definir a alocação do deslocamento entre controles correlacionados

**Prioridade:** P1  
**Dependência:** Task 07.  
**Objetivo:** comparar três diagnósticos: one-at-a-time, leave-one-out condicional e média de Shapley sobre ordens de inclusão. A alocação de Shapley só será usada se acrescentar interpretação sem dominar o paper.  
**Entregáveis:** definição, algoritmo em R e exemplo mínimo mostrando order dependence.  
**Validação:** contribuições de Shapley devem somar exatamente ao deslocamento conjunto; testes de invariância à permutação dos nomes das variáveis.  
**Como entra no paper:** leave-one-out no texto principal; Shapley, se mantido, apenas no online appendix e no pacote de replicação.

## Task 09 — Desenvolver inferência para o deslocamento de especificação

**Prioridade:** P1  
**Dependência:** Task 02.  
**Objetivo:** substituir `|IVB/SE|` como métrica principal por `Delta_Z`, intervalo de confiança e magnitudes relativas claramente definidas.  
**Método principal:** bootstrap por unidade que reestima conjuntamente modelos short, long e auxiliar, preservando a dependência entre estimadores.  
**Método secundário:** derivar a variância de `hat(beta_long) - hat(beta_short)` com a covariância entre estimadores; usar delta method do produto apenas como verificação. Não reutilizar sem validação a aproximação informal da versão PSRM.  
**Entregáveis:** `derivations/specification_shift_uncertainty.Rmd`, função R e testes.  
**Validação:** igualdade entre diferença direta e produto em cada amostra bootstrap; comparação bootstrap/delta em DGPs simples; coverage verificada na Task 14.  
**Como entra no paper:** subseção curta após a decomposição; aplicações passam a reportar `Delta`, `CI(Delta)` e `|Delta|/|beta_benchmark|`. Detalhes no apêndice.

## Task 10 — Produzir um inventário unificado das simulações existentes

**Prioridade:** P0  
**Objetivo:** documentar cada DGP já existente com equações, DAG, estimando, parâmetros, `N`, `T`, burn-in, repetições, erros, efeitos fixos, modelos, métricas, script e arquivo de resultados.  
**Cobertura obrigatória:** dual role, firewall, mediator/over-control, nonlinearity, feedback, carryover, tratamento binário escalonado, erro de medida, Callaway-style trends e confounding contemporâneo não observado.  
**Entregáveis:** `quality_reports/simulation_design_inventory.csv` e apêndice reproduzível.  
**Validação:** cada número do manuscrito deve apontar para um script e CSV versionado; conferir datas e valores lógicos dos parâmetros; preservar todos os resultados brutos.  
**Como entra no paper:** tabela-resumo de DGPs no início da seção de simulações; especificações completas no online appendix.

## Task 11 — Refazer a Figura 2 e a tabela do mecanismo firewall

**Prioridade:** P0  
**Dependência:** Tasks 05 e 10.  
**Objetivo:** reconstruir a evidência central a partir dos resultados brutos, com incerteza Monte Carlo e informações suficientes para leitura autônoma.  
**Entregáveis:** script R separado para figura e tabela; linha zero proeminente; intervalos de Monte Carlo; `N`, `T` e número de repetições na caption; painel de bias relativo ou RMSE.  
**Validação:** reproduzir as médias atuais antes de alterar o gráfico; conferir que os intervalos são MC intervals, não intervalos inferenciais do estimador.  
**Como entra no paper:** DAG dual-role, nova Figura 2 e tabela firewall formam o centro da seção de simulações; detalhes adicionais vão ao apêndice.

## Task 12 — Integrar robustez já existente sem novas simulações

**Prioridade:** P0  
**Dependência:** Task 10.  
**Objetivo:** incorporar resultados já produzidos sobre `T`, tratamento binário, não linearidade, erro de medida, feedback, carryover, staggered absorbing treatment e confounding não observado.  
**Entregáveis:** tabela de boundary conditions com resultado, magnitude, script e interpretação; correção de inconsistências entre relatórios antigos e o manuscrito atual.  
**Validação:** rerun seletivo apenas para smoke tests e hashes; qualquer rerun completo exige aprovação do autor.  
**Como entra no paper:** uma tabela compacta após a Figura 2; resultados completos e gráficos no online appendix. Não aumentar o texto principal com uma subseção para cada robustez.

## Task 13 — Nova simulação: finite-T dynamic panel bias e escolha do estimador

**Prioridade:** P0  
**Dependência:** Tasks 04 e 10.  
**Objetivo:** identificar quando o viés de estimação dinâmica se torna comparável ou maior que o deslocamento causado pelo controle.  
**Grid principal:** `N in {50, 100, 250}`, `T in {8, 10, 15, 20, 30, 50}`, `rho_Y in {0.2, 0.5, 0.8}`; manter os demais parâmetros no DGP dual-role.  
**Stress grid:** `rho_D in {0.2, 0.5, 0.8}` e heterogeneidade dos efeitos unitários em dois níveis, para `N=100` e `T in {10, 20, 30}`.  
**Estimadores:** FE-ADL within; correção split/half-panel jackknife; Arellano–Bond apenas como sensitivity benchmark, com instrumentos colapsados, contagem limitada e diagnósticos AR(2)/Hansen documentados. Não chamar GMM de “bias-corrected FE”.  
**Métricas:** bias, relative bias, RMSE e coverage do CET; magnitude do deslocamento; indicador `|estimation bias| >= |Delta_Z|`.  
**Entregáveis:** novo script R, resultados brutos, session info, relatório PDF e phase map.  
**Validação:** seeds reprodutíveis; MCSE; checagem de estabilidade; code review antes da execução; resultados não podem ser filtrados por favorecer o benchmark.  
**Como entra no paper:** uma figura ou heatmap no texto principal delimitando o `T` em que FE-ADL é aceitável; comparação completa de estimadores no apêndice.

## Task 14 — Nova simulação: misspecification do lag e persistência do tratamento

**Prioridade:** P1  
**Dependência:** Tasks 04 e 13.  
**Objetivo:** testar se a regra ADL(1) sobrevive quando o DGP verdadeiro possui dois ou três lags e quando `D` é persistente.  
**Design:** DGPs verdadeiros ADL(1), ADL(2) e ADL(3); estimar um lag, dois lags, lag correto e lag selecionado por AIC/BIC; variar `rho_D` e carryover.  
**Métricas:** bias/RMSE/coverage do CET, residual autocorrelation e deslocamento associado a `Z_t` versus `Z_{t-1}`.  
**Entregáveis:** script R, CSVs brutos e relatório PDF.  
**Validação:** confirmar que o DGP correto é recuperado em casos-base; relatar falhas da seleção por informação sem escolher ex post o melhor critério.  
**Como entra no paper:** uma frase e tabela de scope condition no texto principal; resultados completos no apêndice.

## Task 15 — Nova simulação: múltiplos controles correlacionados com papéis causais diferentes

**Prioridade:** P1  
**Dependência:** Tasks 07–08.  
**Objetivo:** mostrar como funcionam os diagnósticos conjunto e condicionais quando há um confounder, um mediator e um collider correlacionados.  
**Design:** variar correlação entre controles, força de cada seta causal e ordem de inclusão. Comparar deslocamento conjunto, one-at-a-time, leave-one-out e Shapley.  
**Métricas:** erro das identidades, recuperação do deslocamento conjunto, order dependence e capacidade de distinguir movimento descritivo de bias causal conhecido pelo DGP.  
**Entregáveis:** script R, resultados brutos, session info e relatório PDF.  
**Validação:** identidades algébricas exatas em cada replicação; análise pré-especificada das regiões de parâmetros.  
**Como entra no paper:** exemplo compacto após a proposição vetorial; figuras e grids completos no apêndice.

## Task 16 — Nova simulação: calibração dos intervalos para `Delta_Z`

**Prioridade:** P1  
**Dependência:** Task 09.  
**Objetivo:** verificar cobertura e comprimento dos intervalos bootstrap/delta sob dependência serial e clustering por unidade.  
**Design:** DGP linear simples e dual-role; `N` e `T` baixos/moderados; erros iid e AR(1); deslocamento nulo, pequeno e grande.  
**Métricas:** coverage nominal de 95%, bias do erro-padrão, comprimento do intervalo e falhas computacionais.  
**Entregáveis:** script R, resultados brutos e relatório PDF.  
**Validação:** comparação com truth Monte Carlo; bootstrap deve reamostrar unidades inteiras.  
**Como entra no paper:** apenas o método validado e um resultado de coverage no texto principal; tabela completa no apêndice.

## Task 17 — Gate condicional para heterogeneidade dinâmica

**Prioridade:** P2  
**Dependência:** Tasks 13–14.  
**Objetivo:** decidir, antes de rodar novas baterias, se as alegações revisadas ainda exigem evidência sobre `rho_i` ou `beta_i`.  
**Procedimento:** auditar `simulations/diagnostics/diag_heterogeneous.R`; formular previamente qual claim seria testada; executar uma simulação formal apenas se o claim permanecer no texto principal.  
**Entregáveis:** memo go/no-go. Se “go”, plano de simulação separado sujeito a aprovação.  
**Validação:** nenhuma análise será adicionada apenas por constar da lista extensa do parecer.  
**Como entra no paper:** se “no-go”, scope condition e agenda futura; se “go”, resultado resumido no apêndice, salvo se alterar a conclusão principal.

## Task 18 — Gate condicional para fatores comuns e dependência transversal

**Prioridade:** P2  
**Dependência:** Tasks 13–14.  
**Objetivo:** decidir se a revisão precisa de um DGP com common shocks e loadings heterogêneos ou apenas de uma delimitação explícita do escopo inferencial.  
**Procedimento:** separar dois problemas: identificação sob fatores omitidos e inferência sob erros correlacionados entre unidades. Não abrir uma comparação geral com CCE/IFE nesta revisão.  
**Entregáveis:** memo go/no-go. Se “go”, plano separado com estimando, DGP, estimadores e inferência pré-especificados.  
**Validação:** a simulação só será autorizada se responder a uma alegação mantida no texto principal.  
**Como entra no paper:** por padrão, scope condition e agenda futura; evidência simulada apenas se o gate resultar em “go”.

## Task 19 — Formalizar o protocolo de seleção e codificação das aplicações

**Prioridade:** P0  
**Objetivo:** declarar que a amostra é purposiva, ou construir um frame sistemático defensável. Não apresentar seis estudos como representativos sem evidência.  
**Protocolo:** critérios de journal/período/design/dados públicos; log de busca e exclusões; classificação causal refeita sem acesso às magnitudes do deslocamento; dois codificadores independentes; adjudicação e registro da concordância.  
**Entregáveis:** protocolo em Markdown, planilha de coding, codebook e fluxograma de seleção.  
**Validação:** separar claramente classificação ex ante da inspeção do resultado; conferir referências usadas para cada seta causal.  
**Como entra no paper:** subseção curta de seleção/codificação antes das aplicações; detalhes, desacordos e todos os casos no apêndice.

## Task 20 — Auditar a reprodução dos seis estudos e dos 14 controles

**Prioridade:** P0  
**Dependência:** Task 19.  
**Objetivo:** verificar amostra comum, estimativa original, clustering, tratamento de missing, timing e valores impossíveis antes de recalcular diagnósticos.  
**Entregáveis:** uma ficha PASS/FAIL por estudo, tabela com `N`, períodos, coeficiente original versus replicado e motivo de qualquer discrepância.  
**Validação de dados:** datas em ordem, ausência de períodos impossíveis, faixas substantivas, tratamento binário válido, lags dentro da unidade e igualdade de amostra entre modelos aninhados.  
**Como entra no paper:** tabela completa dos seis estudos no apêndice; texto principal mantém dois casos detalhados e uma síntese honesta dos 14 controles.

## Task 21 — Construir DAGs concorrentes para Leipziger

**Prioridade:** P1  
**Dependência:** Tasks 03, 05 e 20.  
**Objetivo:** representar um DAG em que GDP é confounder legítimo e outro em que é treatment-responsive ou dual role. Explicitar por que o mesmo `Delta_Z` recebe interpretações diferentes.  
**Entregáveis:** dois DAGs time-indexed, justificativas bibliográficas para cada seta e tabela de implicações.  
**Validação:** conferir timing real dos dados e distinguir confounding, mediação acumulada e collider structure.  
**Como entra no paper:** par de DAGs na aplicação Leipziger; versões expandidas e referências no apêndice.

## Task 22 — Construir DAGs concorrentes para Rogowski

**Prioridade:** P1  
**Dependência:** Tasks 03, 05 e 20.  
**Objetivo:** representar um DAG em que GDP defasado é confounder de crescimento e outro em que incorpora resposta acumulada ao tratamento, mediação ou papel dual. Explicitar por que a grande mudança do coeficiente não decide automaticamente qual modelo identifica o CET.  
**Entregáveis:** dois DAGs time-indexed, justificativas bibliográficas para cada seta e tabela de implicações.  
**Validação:** evitar chamar GDP defasado de collider apenas porque tratamentos anteriores podem afetá-lo; verificar a janela quinquenal e o alinhamento entre tratamento, GDP e crescimento futuro.  
**Como entra no paper:** par de DAGs na aplicação Rogowski; versões expandidas e referências no apêndice.

## Task 23 — Refazer as tabelas empíricas com diagnósticos conjuntos e incerteza

**Prioridade:** P1  
**Dependência:** Tasks 07–09 e 19–22.  
**Objetivo:** abandonar a dependência exclusiva de `|IVB/SE|` e reportar um conjunto interpretável de medidas.  
**Colunas mínimas:** `beta_short`, `beta_long`, `Delta`, `CI(Delta)`, `|Delta|/|beta_benchmark|`, papel causal codificado, classificação de ambiguidade e deslocamento conjunto quando houver vários controles.  
**Entregáveis:** scripts R separados e tabelas numeradas com captions completas.  
**Validação:** modelos aninhados na mesma amostra; intervalos clusterizados por unidade; conferência manual de todos os sinais e denominadores.  
**Como entra no paper:** uma tabela-síntese no texto principal; decomposições completas e leave-one-out no apêndice.

## Task 24 — Reestruturar e reescrever o manuscrito

**Prioridade:** P0  
**Dependência:** Gates A–D.  
**Estrutura proposta:** motivação e CET; ordem temporal e DAGs dinâmicos; deslocamento de especificação; condições que transformam deslocamento em bias; identificação e estimação do benchmark ADL; simulações; aplicações; scope conditions e extensões.  
**Posicionamento:** incluir uma tabela “conhecido versus acrescentado” comparando FWL, Blackwell–Glynn, Imai–Kim e Caetano–Callaway. A contribuição principal será o workflow integrado, não a novidade da álgebra isolada.  
**Controle de escopo:** Jensen, Kronick e SDiD ficam fora do texto principal PA; MSM, g-methods, nonlinear links, IFE/GSC e long-run effects entram apenas como fronteiras conceituais.  
**Entregáveis:** nova versão do Rmd e changelog argumental por seção.  
**Validação:** cada claim causal deve apontar para hipótese, derivação, simulação ou aplicação; remover repetição entre abstract, introdução e seções intermediárias.  
**Como entra no paper:** esta task produz a nova arquitetura integral; materiais técnicos ficam no online appendix.

## Task 25 — Construir o pipeline reproduzível

**Prioridade:** P0  
**Dependência:** Task 24.  
**Objetivo:** garantir que dados, simulações, tabelas, figuras e PDF possam ser reconstruídos sem computação escondida no RMarkdown.  
**Pipeline:** scripts R numerados; outputs brutos preservados; outputs derivados separados; seeds e session info; script mestre em modo smoke/full; manifesto de arquivos; `dplyr::select` em toda seleção de colunas.  
**Testes:** unit tests das identidades escalar/vetorial; testes do bootstrap; smoke tests dos DGPs; auditoria de números do texto; renderização PDF; validação de captions, numeração e bibliografia.  
**Entregáveis:** pipeline executável, manifesto, logs, session info e relatório de reproducibilidade.  
**Como entra no paper:** gera automaticamente tabelas, figuras, manuscrito e online appendix.

## Task 26 — Executar QA visual, auditoria numérica e gate editorial final

**Prioridade:** P0  
**Dependência:** Task 25.  
**Objetivo:** verificar o produto final sem misturar implementação e avaliação.  
**Testes:** auditoria de todos os números do texto contra CSVs; inspeção visual de todas as páginas do PDF; conferência de captions, numeração, referências cruzadas e bibliografia; proofread; checagem do pacote em ambiente limpo.  
**Gate editorial:** novo parecer contribution/execution/exposition e referee cold read somente depois de todos os testes técnicos passarem.  
**Entregáveis:** PDF final, checklist PASS/FAIL, pareceres e lista residual de riscos.  
**Como entra no paper:** produz a versão pronta para circulação e o registro interno de qualidade do pacote de submissão.

## Sequência recomendada

1. Concluir Tasks 01–06 e reavaliar o argumento antes de qualquer nova simulação.
2. Concluir Tasks 07–09 para estabilizar o diagnóstico que será simulado e aplicado.
3. Executar Tasks 10–12 para aproveitar toda a evidência já existente.
4. Solicitar aprovação do autor para executar separadamente as Tasks 13–16.
5. Resolver os gates condicionais das Tasks 17–18 sem presumir novas baterias.
6. Concluir Tasks 19–23 com os coautores envolvidos na classificação causal.
7. Executar Tasks 24–26 e submeter o manuscrito a nova revisão integral.

## Critério de parada

A revisão estará pronta quando: (1) `Delta_Z` e bias causal não forem confundidos; (2) o benchmark ADL estiver acompanhado de hipóteses formais e limites de `T`; (3) múltiplos controles e incerteza tiverem tratamento operacional; (4) simulações e aplicações forem integralmente rastreáveis; (5) o texto principal permanecer concentrado no CET em TSCS linear; e (6) todas as tabelas, figuras e claims numéricos forem reproduzidos por scripts R testados.
