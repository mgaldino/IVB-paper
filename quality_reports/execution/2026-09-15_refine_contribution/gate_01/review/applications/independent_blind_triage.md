# Gate 1: triagem documental independente das aplicações — Fase A

Data: 15 de setembro de 2026. Revisor: agente independente `gate1_application_review`. Estado: **congelado antes do confronto; achados candidatos à adjudicação**.

## Resultado

**Nenhuma das três candidatas está documentalmente liberada como aplicação principal ou reserva do CET na rota aprovada.** As três permitem estudar uma exposição defasada e um desfecho posterior. Isso não demonstra, por si, que permitem identificar o efeito de uma intervenção atual sobre uma resposta contemporânea. A triagem literal do protocolo resulta em `HOLD_DOCUMENTATION` para Blair, Ballard-Rosa e Claassen, por motivos discriminados abaixo. Não concluo que os estudos sejam substantivamente impossíveis de adaptar, nem que seus resultados científicos estejam incorretos.

Há uma lacuna no protocolo que deve ser adjudicada antes de qualquer seleção: seus sete critérios não contêm uma checagem independente de correspondência ao CET. O texto permite passar uma exposição datada e um desfecho posterior, embora o plano exija preservar um efeito contemporâneo e proíba resolver sua ausência renomeando índices. **PASS de E2 para uma resposta futura não é PASS para CET.**

### Intuição

Imagine que a política ocorreu em 2010, o controle foi medido em 2009 e a resposta em 2012. Há uma ordem temporal clara e uma pergunta causal potencialmente interessante. Chamar a política de “tratamento atual”, usando 2010 como origem, ainda deixa a resposta dois anos à frente. Acrescentar o controle de 2012 pode retirar uma via intermediária, abrir outro caminho ou apenas mudar uma projeção; a direção dessa mudança não se deduz do calendário. Para demonstrar o procedimento do paper, precisamos saber qual intervenção está sendo comparada, a qual horizonte a resposta pertence e o que significa reter a história ao acrescentar o controle. Os três estudos ajudam a formular essa discussão, mas não resolvem automaticamente as três perguntas.

## 1. Contrato e preservação da independência

- Plano recebido: `quality_reports/plans/2026-09-15_refine_contribution/plan.md`; SHA-256 conferido: `d2d2ea2e39102ab4193ee2f82b12b0823143867a23750c38d626aa4797eb7f5d`.
- Lidos primeiro `gate_01/applications/protocol.md` e `protocol.json`, ID `IVB-G1-APPLICATIONS-2026-09-15-v1`, além das regras comuns e Gate 1 do plano. Conferidas também as exigências temporais dos Gates 2 e 5.
- Não abri seleção, fichas da equipe, inventários do Gate 0, matriz de resposta, relatório de contribuição, manuscrito IVB, relatórios IVB de aplicações ou outputs empíricos. Uma listagem de nomes mostrou que alguns desses arquivos existem; não li seu conteúdo.
- Fontes substantivas limitadas às três publicações e aos arquivos primários expressamente autorizados. Não consultei memória nem web; não houve ampliação de fontes.
- A leitura cobriu a formulação substantiva e o desenho: Blair, pp. 1308–1318 e discussão p. 1323; Ballard-Rosa, pp. 32–50 e especificações alternativas pp. 59–62; Claassen, pp. 2–20 e extensões pp. 25–27 da versão local. Scripts foram lidos para definições, construção, modelos e dependência. Não reivindico leitura integral de apêndices que não estavam entre as fontes autorizadas.
- Resultados científicos presentes nas próprias publicações, comentários do código ou codebook apareceram incidentalmente na leitura. Não foram usados para classificar ou escolher; nenhum valor de coeficiente, erro-padrão, significância ou shift fundamenta este relatório.

Os localizadores abaixo usam páginas impressas do artigo, páginas numeradas da versão local de Claassen e linhas dos scripts originais. Os textos extraídos permanecem em `source_extracts/`; os números de linha de extração não substituem a paginação do PDF.

## 2. Critério de decisão e lacuna do protocolo

`PASS` significa que a exigência documental está sustentada; `MISSING` significa lacuna documental; `FAIL` exige evidência afirmativa de uma condição de exclusão do protocolo. Uma dificuldade de preparação ou a ausência de prova causal não se converte em `FAIL`. As classificações são do par **desenho + controle nomeado**, não de cada variável de uma bateria de resultados.

| Candidata e contraste examinado | E1 | E2 | E3 | E4 | E5 | E6 | E7 | Classe literal |
|---|---|---|---|---|---|---|---|---|
| Blair: mandato de promoção da democracia; ajuda externa | PASS | PASS | PASS | PASS | MISSING | PASS* | PASS | HOLD_DOCUMENTATION |
| Ballard-Rosa: orientação partidária; crescimento do PIB | PASS | PASS | PASS | PASS | PASS | PASS | MISSING | HOLD_DOCUMENTATION |
| Claassen: apoio difuso à democracia; desenvolvimento econômico | PASS | PASS | PASS* | PASS | PASS | PASS | MISSING | HOLD_DOCUMENTATION |

\* PASS de disponibilidade documental, com limites importantes explicitados nas fichas. Nenhum PASS afirma suporte estatístico, amostra comum suficiente, inferência adequada ou história causalmente suficiente.

O plano, §1 e Gate 1, demanda preservar um efeito contemporâneo e adverte contra a mera troca de índice. O protocolo E2 demanda apenas ordenação exposição→desfecho, e E1 chama de atual uma exposição ligada a uma unidade/período sem exigir sua correspondência com a janela contemporânea do estimando. Isso deixa passar, em princípio, efeitos futuros. A revisão não modifica retroativamente os critérios: registra **a classe literal** e **a compatibilidade adicional com a rota CET do plano** em campos separados. A correção sugerida é exigir uma declaração explícita da intervenção em tempo físico, do horizonte da resposta e das trajetórias futuras deixadas livres ou fixadas; eventuais mudanças ao protocolo devem gerar nova versão.

## 3. Blair, Di Salvatore e Smidt: mandato e ajuda externa

### Unidade, variáveis e relógio

Unidade: país-ano, países da África subsaariana afetados por conflito, janela analítica declarada 1991–2016. O desenho principal usa variação dentro dos países e efeitos fixos de país. Não confundir unidade país com missão individual. O artigo também utiliza estratégias instrumentais e subsamples definidos por conflito/paz; esta ficha fixa o desenho linear com efeitos fixos na amostra total, evitando tornar a classificação dependente dos subsamples pós-conflito.

- **D:** presença de mandato com promoção da democracia, `ipema_any_demo_assist_dum`, usada como `_2l` na tabela principal. É autorização/mandato, não execução de atividades nem número de funcionários. Uma tarefa continua mandatada até que revisão a retire; não é um indicador exclusivamente de nova adoção.
- **Y:** qualidade de democracia eleitoral V-Dem, `v2x_polyarchy`, no ano de resposta `t`.
- **Z:** ajuda externa, variável bruta `wdi_oda`, cópia imputada `iwdi_oda`, utilizada originalmente como `iwdi_oda_3l`.
- Relógio original: `Z[t−3] → D[t−2] → Y[t]`. Uma história de Y anterior ao ano de D precisa alcançar `Y[t−3]` ou antes; `Y[t−1]` é posterior a D. O código disponibiliza diversos lags de Y, mas a especificação principal não é, por isso, uma baseline completa de história para CET.

**Estimando:** associação linear ajustada entre presença do mandato dois anos antes e democracia no ano de resposta, apresentada com argumentos de identificação causal no artigo. Se causal, é uma resposta de horizonte futuro à exposição anterior. Reescrever `s=t−2` produz `Y[s+2]` em função de `D[s]`; o horizonte continua sendo dois anos. O mandato pode persistir ao longo dessa janela; intervir na autorização inicial, manter um mandato vigente e mudar a intensidade de atividades são intervenções diferentes. As fontes não fixam uma intervenção atual dentro do ano de Y nem sua ordem intraperíodo. **CET não demonstrado**, sem demonstração de impossibilidade de redesenho.

### E1–E7 e evidência

| Critério | Fundamentação e localizadores |
|---|---|
| E1 PASS | Conteúdo e persistência dos mandatos: artigo pp. 1311 e 1315; exposição principal no script `replication.do`, linha 446; construção dos lags, linhas 75–95. |
| E2 PASS | O artigo justifica defasagem de dois períodos para mandatos, pessoal e atividades: pp. 1315–1316. O resultado é posterior ao ano atribuído à exposição. Isso não estabelece CET nem identifica o efeito de uma nova adoção. |
| E3 PASS | Medidas anuais de Y e controles e sua construção são documentadas: artigo p. 1317; script linhas 42–61 e 99–133. A existência de variáveis brutas e lags anteriores fornece uma rota de história; as cópias imputadas não são automaticamente história admissível. |
| E4 PASS | Variação dentro do país de mandatos e outros atributos, comparação ao longo do tempo e amostra total: artigo pp. 1309–1310, 1315–1318; script linha 446 e `indvar_separate_ctrls.ado`, linha 13. Não certifica positividade ou elimina seleção. |
| E5 MISSING | País `gwnoloc` e tempo `year` são claros no script, linhas 35–45; entretanto, o comando principal `xtreg ..., fe` no `.ado`, linhas 13 e 23, não declara cluster ou estimador robusto da dependência. Efeitos fixos de país não equivalem a erros agrupados por país. Nas fontes autorizadas não encontrei documentação suficiente do tratamento da dependência residual necessário à rota proposta. Não afirmo ausência de painel nem poucos clusters. |
| E6 PASS documental | `metadata.json` identifica `data_replication.tab`, ID 6692645, diretório `Replication Files`, `restricted:false`, formato original Stata, no repositório primário DOI `10.7910/DVN/UOYDHN`. O código mapeia variáveis, país, ano e restrições. Acesso público é declarado no artigo p. 1324. Os dados não foram baixados/abertos nesta revisão; o PASS significa recuperabilidade documentada, não acesso live ou schema empiricamente conferido. A lacuna de dependência é registrada em E5, não ocultada. |
| E7 PASS | O artigo considera ajuda externa um confundidor variável no tempo e atrasa controles para evitar viés pós-tratamento, p. 1317. A atração de ajuda aparece na argumentação sobre mandatos, p. 1311, e a coordenação de doadores é discutida p. 1318. Comparar ajuda histórica com ajuda posterior ao mandato tem significado substantivo; não se infere disso que ela efetivamente medeia o efeito. |

### Sentido do contraste e preparação

Para a pergunta futura original, acrescentar `Z[t]` mantendo `Z[t−3]` e história admissível pergunta como muda a projeção ao condicionar também ajuda posterior ao mandato e contemporânea ao ano de resposta. `Z[t−1]` seria um controle intermediário diferente, anterior ao ano de Y; não deve ser apresentado como se fosse o mesmo contraste. Trocar `Z[t−3]` por `Z[t]` combina retirada de história com acréscimo de informação atual e exige decompor os passos em amostra comum. O sinal da mudança não distingue mediação, confusão e collider.

Duas pendências observadas no código são concretas: (i) `egen mean()` utiliza todos os anos do país antes de gerar lags (`replication.do`, 99–108), podendo inserir valores posteriores à exposição em uma observação rotulada histórica; (ii) os lags são construídos como deslocamentos de linha após `sort`, sem proteção por país ou confirmação de intervalo anual (42–61, 75–95, 112–133). Não executei os dados para saber quais observações são atingidas. Uma adaptação deve preservar as variáveis brutas, reconstruir lags por chave e calendário e verificar perdas de amostra e dependência. Nenhum desses pontos demonstra que toda história disponível seja imprópria.

## 4. Ballard-Rosa, Mosley e Wellhausen: partidarismo e crescimento

### Unidade, variáveis e relógio

Unidade: país-mês, países não membros da OCDE na análise principal, 1990–2016. O universo de emissões originais em mercados primários é agregado ao país-mês. O desfecho existe somente quando há emissão; o valor observado é resultado de negociação entre governo e credores, não preferência ideal do governo.

- **D:** orientação econômica do Executivo, `execrlc_mo`, direita/esquerda contra centro/outros; o script emprega `l.ib2.execrlc_mo`.
- **Y:** `propDom_gt1yr`, participação do valor dos títulos emitidos em moeda doméstica entre emissões da categoria de maturidade usada no estudo. O artigo a descreve como títulos com maturidade de ao menos um ano; o nome do campo contém `gt1yr`. A convenção exata no ponto de corte deve ser reconciliada antes de reproduzir a amostra.
- **Z:** crescimento econômico, `gdp_growth`, controle anual, usado como `l12.gdp_growth`.
- Relógio: orientação partidária do mês `m−1` → emissões do mês `m`. A atualização mensal usa entrada do governo em exercício, não simplesmente data da eleição (artigo p. 48, nota 91). O crescimento em `m` se refere a uma medida anual; não é uma mudança econômica mensal datada.

**Estimando:** diferença ajustada na participação doméstica de emissões do mês seguinte entre orientações partidárias, entre países-meses com emissão observada. Não é efeito sobre estoque de dívida, tamanho total de emissão ou preferência latente. A interpretação causal precisaria tratar tanto confundimento quanto seleção na emissão. O desenho documental mostra exposição defasada e resposta futura de um mês. Para interpretar orientação do Executivo como intervenção atual no mês da emissão, seria preciso documentar sua situação no momento das transações e a janela de resposta; não basta renomear a orientação do mês anterior. **CET não demonstrado; adaptação não demonstrada impossível.**

### E1–E7 e evidência

| Critério | Fundamentação e localizadores |
|---|---|
| E1 PASS | Definição de partidarismo e atualização pelas datas de posse: artigo p. 48 e nota 91; `IO replication.do`, 73–79. Exposição é composição partidária do governo, não uma política econômica específica. |
| E2 PASS | Defasagem mensal da variável partidária explicitada p. 50 e no código; Y é agregado de transações no mês subsequente. Não garante que D permaneça vigente até cada emissão. |
| E3 PASS | Painel mensal de Y e controles anuais acessíveis, artigo pp. 47–50; esquema com `ccode`, `time`, `year`, `propDom_gt1yr`, `gdp_growth`. História mais distante é construível documentalmente. O lag anual original não é certificado como anterior a D para todas as observações. |
| E4 PASS | Comparações entre categorias partidárias, variação ao longo do tempo com efeitos fixos e tendência cúbica; artigo pp. 48–50; código 66–79. A seleção na emissão é reconhecida p. 50 e abordada em extensão Heckman mencionada pelo artigo. |
| E5 PASS | País-mês, efeitos fixos de país e erros agrupados por país: artigo p. 50; código `vce(cluster ccode)`, 74–79. Isso não valida o número de clusters ou dependência global. |
| E6 PASS | Dados tabulares locais e header conferido; mapa essencial D/Y/Z/unidade/tempo e filtros em código, 9–10, 66–79. A origem/formatação Stata de `time` e metadados perdidos na exportação tabular precisam ser reconstruídos; não conferi valores, duplicidades ou cobertura. |
| E7 MISSING | O papel econômico de crescimento e sua possível relação com partidarismo está documentado p. 49. Contudo, o controle anual atual pode incluir meses posteriores ao mês de Y e não tem ordem intraperíodo especificada. A fonte não resolve qual medida atual, temporalmente apropriada, comparar à história mensal do tratamento. |

### Sentido do contraste e preparação

O contraste proposto acrescentaria crescimento atual ao histórico econômico, preservando a história de Y e D; não deve atribuir interpretação causal a uma soma de informações anuais que inclui o futuro. Há um problema já no rótulo “histórico”: se Y ocorre em janeiro de 2010 e D é dezembro de 2009, a observação anual recuperada por `l12.gdp_growth` pode representar o ano de 2009 inteiro, incluindo o mês de D. Uma medida anual mais antiga pode fornecer história genuinamente anterior, mas a suficiência e a disponibilidade após restrições precisam ser verificadas. Esse exemplo demonstra um risco lógico de alinhamento, não um cálculo sobre os dados.

O artigo p. 50 descreve controles defasados em um ano, exceto partidarismo e Treasury em um mês. O código, 66–67, utiliza Treasury com `l12` e crises sem lag; nas interações, por exemplo linhas 82 e 112, as crises aparecem com `l.`. A discrepância deve ser reconciliada sem executar diferentes versões e escolher a mais favorável. Não é necessário recuperar transações Bloomberg protegidas para constatar que há dados agregados locais; não tratei a fonte Bloomberg como impossibilidade de acesso à aplicação existente.

## 5. Claassen: apoio difuso e desenvolvimento

### Unidade, variáveis e relógio

Unidade: país-ano. A variável de apoio é uma estimativa latente nacional suavizada construída com pesquisas de opinião fragmentadas, não uma intervenção experimental nem uma medida diretamente observada em cada país-ano. O README avisa que dados e script locais incorporam correção/erratum; não transferi silenciosamente para os arquivos corrigidos os tamanhos de amostra publicados no texto anterior.

- **D:** apoio difuso à democracia, `SupDem_trim`; a equação usa seu lag de um ano.
- **Y:** democracia liberal V-Dem, `Libdem_VD`, no ano `t`.
- **Z:** desenvolvimento econômico, `lnGDP_imp`, log do PIB per capita em PPC. O codebook corrigido diz majoritariamente IMF, com imputação por WDI/PWT, enquanto o paper descreve WDI com imputação IMF/PWT. O mapa corrigido deve prevalecer para reprodução, sem presumir identidade de versões.
- Modelo original: `Y[t] ~ Y[t−1] + Y[t−2] + D[t−1] + Z[t−1] + demais controles`; versão com efeitos individuais é estimada por system GMM. Aqui `Y[t−1]` e `Z[t−1]` estão no **mesmo ano de D**, não são uma história estritamente anterior apenas porque o ano de referência de Y é t.

**Estimando:** efeito de apoio no ano anterior sobre democracia subsequente; o paper também considera efeitos futuros acumulados de mudança persistente e heterogeneidade por regime inicial. O texto assume explicitamente **ausência de efeito contemporâneo de apoio sobre democracia**, p. 15, com explicação p. 16 e hipótese p. 6. Também permite democracia atual→apoio atual. Essa é evidência positiva de que o desenho causal original não constitui uma demonstração de CET de apoio sobre democracia no mesmo ano. Sob as premissas do próprio desenho, esse efeito contemporâneo é nulo por construção. Isso não demonstra impossibilidade de um desenho diferente, que demandaria novas premissas e evidência. Reindexar `D[t−1]` como “atual” deixa `Y[t]` no futuro e não resolve o problema.

### E1–E7 e evidência

| Critério | Fundamentação e localizadores |
|---|---|
| E1 PASS | Apoio difuso separado de satisfação instrumental, paper pp. 9–12; `SupDem_trim` no codebook; R 51–53. Exposição nacional latente é definida, sem alegação de manipulabilidade ou consistência causal já provada. |
| E2 PASS | Efeito `s[t−1] → d[t]` declarado no texto, DAG e equação 1, pp. 15–17; R 51–53. Trata-se expressamente de resposta futura. |
| E3 PASS documental, com limite | Painel e campos atuais e defasados de democracia e desenvolvimento documentados no codebook e schema; medidas de anos ainda anteriores são construíveis. Não equiparo `Y[t−1], Z[t−1]` à história pré-D: para isso é necessário ao menos recuar até t−2 e tratar a causalidade intraperíodo que o DAG permite. A imputação de GDP e o uso de suavização no apoio exigem auditoria própria antes de certificar informação efetivamente disponível antes da exposição. |
| E4 PASS | Variação país/tempo, comparações condicionais e estratificação por regime inicial estão descritas pp. 15–20; script 51–73 e 311–341. Não implica que a exposição seja exógena ou que o contraste dentro do país tenha suporte suficiente. |
| E5 PASS | `pdata.frame` com `Country, Year`, R 30–31. Dependência entre países e heterocedasticidade são discutidas p. 22; pooling usa `vcovBK(..., cluster="time")`, R 78–85; GMM tem estrutura própria, 311–353. Não substituir essa estrutura automaticamente por bootstrap simples de países. |
| E6 PASS | README identifica painel corrigido suficiente para modelos principais; header local contém D/Y/Z/país/ano. Código e codebook documentam construção e modelos. CSV esperado pelo código e TAB recebido são formatos distintos que exigem importação explícita, sem reestimar apoio nesta fase. |
| E7 MISSING | O paper p. 17 trata desenvolvimento como causa de apoio e democracia e assume que apoio não afeta Z. Não documenta o valor atual de GDP como descendente de D, nem ordem intraperíodo que torne sua adição um contraste de papel temporal já estabelecido. Pode ser um caso útil de ambiguidade/ausência de ganho, mas não se deve inventar mediação. A ausência dessa hipótese não satisfaz as condições afirmativas de FAIL de E7, pois desenvolvimento é temporalmente variável e relacionado ao processo. |

### Sentido do contraste e preparação

Na notação original, acrescentar `Z[t]` mantendo `Z[t−1]` altera a equação do efeito futuro de apoio. O DAG do estudo não diz que `D[t−1]` produz `Z[t]`; impor essa seta altera suas premissas. Retirar `Z[t−1]` tampouco é simplesmente retirar uma variável pré-exposição, pois ela é contemporânea ao tratamento no relógio físico e no grafo pode causá-lo. Uma baseline formada exclusivamente por história anterior teria de ser conciliada com esse confundimento contemporâneo. Avaliar uma medida latente suavizada também requer distinguir data do construto, informação usada na estimação e incerteza de mensuração. O material lido não basta para declarar que toda informação prévia está contaminada, nem que toda ela é admissível.

## 6. Seleção, limites e próximo passo delimitado

**Principal: nenhuma. Reserva: nenhuma.** As classes literais não autorizam seleção e a correspondência ao CET permanece não demonstrada para Blair e Ballard-Rosa; no desenho causal original de Claassen, a ausência de efeito contemporâneo é expressamente assumida. O resultado desta triagem deve permanecer registrado mesmo que uma aplicação ulterior exiba shifts grandes, pequenos, nulos ou favoráveis.

Uma próxima busca documental, se mantida a rota, pode ser delimitada a: (1) esclarecer no protocolo a janela de CET exigida; (2) recuperar documentação primária de timing e dependência de Blair e documentação de frequência/referência dos controles de Ballard-Rosa, sem estimar; (3) procurar no máximo duas novas aplicações com intervenção atual datada, história anterior e resposta dentro de janela contemporânea substantivamente justificada. Para Claassen, mais detalhes de calendário não removem a hipótese original de ausência de efeito contemporâneo; seria necessária uma mudança assumida de alvo/desenho. A alternativa é uma rota explicitamente descritiva ou de efeitos futuros, cuja adoção é decisão científica do autor. Esta revisão não a implementou.

Não há evidência nesta fase sobre suporte estatístico, quantidade efetiva de clusters, duplicidades, ausências, perdas de amostra comum, identificação causal, adequação de OLS/FE/GMM ao procedimento IVB ou valor incremental sobre Gelbach. Também não se analisou estimativa de shift ou desempenho inferencial.

## 7. Operações executadas e entrega

Executados somente comandos de leitura/listagem, SHA-256, extração de texto com `pdftotext -layout`, Python 3 para ler cabeçalhos TAB e organizar trechos de texto, e gravação dos artefatos desta revisão. A tentativa inicial de `python` falhou porque esse comando não estava disponível; `python3` funcionou. As operações estão discriminadas em `commands_executed.md`. Não executei R, Stata, regressões, estatísticas descritivas calculadas dos dados, IVB, shifts, bootstrap, simulações, instalação de pacotes, downloads ou alterações dos scripts originais.

Entregas: este Markdown, `independent_blind_triage.json`, `schema_headers.json`, `commands_executed.md`, extrações textuais de fontes e `manifest_sha256.json`. O manifesto inclui hashes das fontes e entregas, excluindo apenas seu próprio hash por impossibilidade de autorreferência estável. **Ponto de parada: Fase A encerrada; nenhum relatório do implementador foi aberto.**
