# Carta Editorial -- Framework Edmans (Contribution, Execution, Exposition)

## Decisao: R&R Major

## Scores consolidados

| Dimensao     | Score | Rating          |
|-------------|-------|-----------------|
| Contribution | 7/10  | Forte           |
| Execution    | 6/10  | Adequada        |
| Exposition   | 7/10  | Boa             |
| **Global**   | 7/10  | **Promissor**   |

## Sintese editorial

Este manuscrito aborda um problema genuino e pratico na pesquisa observacional em Ciencia Politica: a quantificacao do vies introduzido ao incluir uma variavel colisor em uma regressao. A contribuicao central -- a formula IVB = -theta* x pi, derivada via FWL e estendida para modelos ADL -- e algebricamente simples, operacionalmente imediata e preenche uma lacuna real entre o diagnostico qualitativo dos DAGs e a necessidade quantitativa do pesquisador aplicado. A extensao para ADL e a demonstracao de que lagar o tratamento nao elimina mecanicamente o IVB sao resultados novos e relevantes para a pesquisa TSCS. As seis aplicacoes empiricas fornecem evidencia de que o IVB tende a ser modesto em paineis tipicos de politica comparada, o que e um resultado substantivamente importante.

No entanto, a execucao apresenta lacunas significativas. A principal e a tensao nao resolvida entre o IVB como identidade algebrica (que vale para qualquer variavel, independentemente de ser colisor, confundidor ou mediador) e o uso retorico da formula como diagnostico de "vies por colisor". O paper reconhece isso na Secao 4.7, mas as aplicacoes empiricas frequentemente deslizam entre a descricao algebrica e a interpretacao causal sem manter a distincao com rigor suficiente. A classificacao DAG dos controles nas seis aplicacoes -- essencial para dar interpretacao causal a formula -- e feita de maneira relativamente informal, sem discussao sistematica das premissas identificadoras subjacentes. Alem disso, a ausencia de uma analise de sensibilidade formal (reconhecida como limitacao) enfraquece a utilidade pratica do diagnostico. A exposicao e geralmente clara e bem organizada, com algumas oportunidades de enxugamento e maior precisao.

## Hierarquia Edmans aplicada

A contribuicao e o ponto mais forte deste paper e justifica o investimento em revisao. O resultado principal -- uma formula operacional para IVB que espelha a OVB formula -- e genuinamente util e nao trivial em sua extensao para ADL. A contribuicao nao e o gargalo. O gargalo e a execucao: a tensao entre identidade algebrica e interpretacao causal precisa ser resolvida de forma mais rigorosa, e as aplicacoes empiricas precisam de maior transparencia sobre as premissas das classificacoes DAG. Se essas questoes forem abordadas, o paper tem potencial para publicacao em um journal de primeira linha em metodologia politica (PSRM, PA, BJPS).

## Prioridades para revisao

1. **Resolver a tensao identidade/causalidade de forma sistematica.** O paper precisa de um framework mais explicito para quando a formula tem interpretacao causal vs. quando e meramente descritiva. A Secao 4.7 (Caveats) e insuficiente -- esta discussao precisa permear as aplicacoes empiricas de forma mais disciplinada.

2. **Fortalecer as classificacoes DAG.** As tabelas de classificacao no Apendice F sao o elo critico entre a algebra e a interpretacao causal. Elas precisam de maior rigor: discutir premissas, reconhecer ambiguidades, e possivelmente usar um framework de classificacao mais formal (e.g., critérios explicitos e reproduziveis).

3. **Adicionar simulacoes que validem o diagnostico como ferramenta de decisao.** As simulacoes atuais confirmam a formula (tautologicamente), mas nao demonstram quando o diagnostico leva a melhores decisoes. Um exercicio de simulacao onde o pesquisador usa a formula para decidir incluir/excluir um controle e mostra que isso melhora a inferencia seria muito mais convincente.

4. **Discutir o caso colisor+confundidor com mais profundidade.** O caso Rogowski et al. mostra que o caso misto e empiricamente prevalente. A referencia a Ding & Miratrix (2015) e insuficiente. O paper se beneficiaria de um resultado analitico (mesmo parcial) para o caso misto sob TWFE.

5. **Reduzir a extensao do paper.** A introducao pode ser encurtada (principalmente a revisao de heuristicas, que e longa para o publico-alvo). Algumas appendices podem ser consolidadas.

## Recomendacao estrategica ao autor

O paper tem contribuicao clara e relevante para o publico de PSRM ou PA. Recomendo fortemente a revisao, nao a submissao a outro journal. O problema central nao e a contribuicao (que e forte) nem a exposicao (que e boa), mas sim lacunas especificas na execucao que sao corrigiveis. Uma revisao focada nas cinco prioridades acima -- especialmente na tensao identidade/causalidade e no fortalecimento das classificacoes DAG -- elevaria substancialmente a publicabilidade. O prazo para revisao deveria ser de 4-6 meses, dado o escopo das alteracoes necessarias.

---

## Parecer completo -- Contribution

# Parecer de Contribution (Framework Edmans)

## Score: 7/10

## Resumo da contribuicao alegada

O paper deriva uma formula fechada para o Included Variable Bias (IVB) -- o vies que surge ao incluir uma variavel colisor em uma regressao -- mostrando que IVB = -theta* x pi, onde ambos os componentes sao diretamente estimaveis a partir dos dados. A formula e estendida de modelos cross-section para modelos ADL usados em pesquisa TSCS, e e aplicada como ferramenta diagnostica a seis estudos publicados em Ciencia Politica.

## Avaliacao por dimensao

### Novidade [Adequada]

A novidade deste paper e real mas matizada. O resultado central -- que o vies por incluir um colisor pode ser expresso como um produto de dois coeficientes de regressao -- e, em essencia, uma consequencia algebrica do teorema FWL e da decomposicao curta-versus-longa da regressao. Os autores reconhecem isso (Secao 4.1, nota apos Proposicao 1). Contribuicoes anteriores de Greenland (2003), Pearl (2013) e Ding & Miratrix (2015) ja derivaram formulas para vies por colisor em modelos estruturais lineares. O que e genuinamente novo e: (1) a reparametrizacao em termos de coeficientes de regressao que o pesquisador ja tem em maos (em contraste com coeficientes estruturais nao observados), o que e analogo a contribuicao de Cinelli & Hazlett (2020) para OVB; (2) a extensao para ADL(p,q), que e relevante porque modelos ADL sao onipresentes em TSCS; (3) o resultado sobre lag substitution (Proposicao 4 e Corolario 1), mostrando que lagar o tratamento nao elimina mecanicamente o IVB; e (4) o conceito de "foreign collider bias". A Bayesian update do leitor apos ler o paper e moderada: a formula em si e intuitiva uma vez derivada, mas a extensao para ADL e o resultado sobre lags sao nao-obvios e praticamante uteis.

### Importancia [Forte]

O problema abordado -- selecao de variaveis de controle em estudos observacionais -- e absolutamente central para a pesquisa empirica em Ciencia Politica. A enorme maioria dos papers TSCS em CP e RI usa TWFE com variaveis de controle selecionadas por heuristicas informais. A formula IVB preenche uma lacuna pratica real: os DAGs dizem *se* ha problema, mas nao *quanto*. Um survey paper sobre identificacao causal em CP mencionaria este resultado. A relevancia pratica e alta: a "receita diagnostica" (Secao 4.6) e diretamente implementavel por pesquisadores aplicados. O resultado empirico de que IVBs medianos sao ~0.13 desvios-padrao e substantivamente importante e tranquilizador para a disciplina. Um pesquisador mudaria suas decisoes sobre especificacao com base nesta ferramenta.

### Adequacao ao escopo [Adequada]

A bibliografia e predominantemente de Ciencia Politica (Beck, Blackwell, Montgomery, Hegre, Acemoglu, Claassen, Leipziger, etc.) e metodologia (Pearl, Cinelli, Ding). O paper e claramente posicionado para journals de metodologia em CP (PSRM, PA) ou journals generalistas com secao de metodologia (AJPS, BJPS). O publico-alvo sao pesquisadores aplicados em CP e RI que usam TWFE/ADL. A adequacao ao escopo e clara.

### Generalizabilidade [Adequada]

A formula e muito geral dentro do universo de modelos lineares: vale para OLS, TWFE, ADL(p,q), e (como mencionado em nota de rodape) para 2SLS. A extensao para modelos nao-lineares (logit, probit) e reconhecida como limitacao. As seis aplicacoes empiricas cobrem dominios variados (democratizacao, peacekeeping, capacidade fiscal, infraestrutura, divida soberana), o que demonstra aplicabilidade ampla. A limitacao principal de generalizabilidade e que a interpretacao causal da formula depende da classificacao DAG, que e especifica a cada aplicacao.

### Trade-offs [Parcial]

O paper reconhece na Secao 4.7 que a formula e uma identidade algebrica e que o mesmo numero pode representar vies por colisor OU vies por variavel omitida confundidora, dependendo da estrutura causal. O caso Rogowski et al. ilustra isso bem. No entanto, o paper nao desenvolve formalmente o trade-off colisor vs. confundidor: quando a classificacao e ambigua, que criterio o pesquisador deve usar? A referencia a Ding & Miratrix (2015) e breve e nao oferece orientacao pratica para o caso misto. Este e o trade-off mais importante que o paper deveria desenvolver mais.

### Hipoteses [Claras e direcionais]

O paper e metodologico, nao substantivo, entao "hipoteses" tradicionais nao se aplicam. No entanto, as "previsoes" teoricas sao claras e direcionais: (1) a formula deve valer exatamente (e vale, por ser identidade algebrica); (2) efeitos fixos devem absorver canais between-unit (Secao 5.1); (3) poucos switchers devem inflacionar SEs relativo ao IVB (Secao 5.2); (4) IVBs empiricos devem ser modestos em paineis tipicos (Secao 6). Todas essas previsoes sao derivadas de principios algebricos ou de intuicao economica clara.

## Veredicto geral sobre contribution

A contribuicao e solida e relevante. O paper identifica um problema pratico genuino (quantificacao do vies por colisor), oferece uma solucao simples e operacional (a formula IVB), e demonstra empiricamente que o problema tende a ser modesto em aplicacoes tipicas de CP. A extensao para ADL e o resultado sobre lag substitution sao contribuicoes genuinas. O conceito de "foreign collider bias" e uma contribuicao conceitual util. A principal fraqueza e que a formula em si e uma identidade algebrica relativamente simples -- o "delta" em relacao a literatura anterior (Greenland, Pearl, Ding & Miratrix) e primariamente a reparametrizacao e a extensao para ADL, nao uma nova descoberta fundamental. Mas este e exatamente o tipo de contribuicao que um journal metodologico valoriza: tornar acessivel e operacional um resultado que existia em forma mais abstrata.

## Sugestoes construtivas

1. Fortalecer a secao sobre novidade relativa a Ding & Miratrix (2015): a contribuicao de 2015 ja derivou formulas de vies por colisor em LSEMs e analisou o trade-off colisor/confundidor. O paper precisa ser mais explicito sobre exatamente o que acrescenta alem da reparametrizacao FWL e da extensao ADL.

2. Desenvolver formalmente (mesmo que em apendice) o caso colisor+confundidor sob TWFE, em vez de relegar a "trabalho futuro".

3. Considerar adicionar uma aplicacao onde o IVB *e* grande e substantivamente relevante (nao apenas o caso ambiguo de Rogowski), para demonstrar que a ferramenta tem poder diagnostico em ambas as direcoes.

---

## Parecer completo -- Execution

# Parecer de Execution (Framework Edmans)

## Score: 6/10
## Tipo de paper: Misto (Teorico + Empirico)

## Resumo da estrategia

O paper combina derivacoes algebricas (formula IVB via FWL para cross-section e ADL), simulacoes Monte Carlo (para ilustrar magnitude do IVB sob condicoes estruturais), e replicacoes empiricas de seis estudos publicados (para demonstrar a relevancia pratica da formula). A estrategia e essencialmente: derivar a formula --> mostrar que ela e "pequena" em condicoes tipicas --> confirmar empiricamente.

## Principio "Dados vs. Evidencia"

Os dados apresentados constituem evidencia para a validade algebrica da formula (que e uma identidade e portanto trivialmente verdadeira) e para a magnitude empirica do IVB em seis estudos. No entanto, os dados nao constituem evidencia forte para a questao mais importante: *quando o pesquisador deve usar esta ferramenta e como ela melhora a inferencia*. A demonstracao de que "IVBs sao tipicamente pequenos" e informativa, mas nao e evidencia de que a formula e um bom diagnostico -- e possivel que IVBs sejam pequenos *e* que a formula seja pouco util (se os casos onde importa sao raros e identificaveis por outros meios).

## Avaliacao por dimensao

### E.1 Mensuracao [Adequada]

As variaveis sao bem definidas e os conceitos claramente operacionalizados. O IVB e definido como a diferenca entre coeficientes de regressao curta e longa, o que e preciso e nao ambiguo. As metricas de comparacao (|IVB/SE| e IVB/beta%) sao bem motivadas e complementares. A decisao de reportar IVB/beta% apenas quando o efeito do tratamento e significativo e sensata. Uma preocupacao menor: a formula usa vcov = "iid" para os coeficientes pontuais (corretamente, pois e uma identidade) mas usa SEs clusterizados para comparacao (|IVB/SE|), o que e apropriado mas merece explicacao mais transparente no texto.

### E.2 Robustez [Fraca]

Esta e uma das principais fraquezas do paper. As simulacoes Monte Carlo confirmam que a formula vale (o que e trivialmente verdadeiro, ja que e uma identidade algebrica) e que os mecanismos discutidos na Secao 5 operam como previsto. Mas faltam testes de robustez *substantivos*:

- **Nao ha variacao nas classificacoes DAG.** Cada controle recebe uma unica classificacao (colisor, confundidor, etc.) com base em julgamento dos autores. Nao ha analise de sensibilidade a classificacoes alternativas. O que aconteceria se GDP per capita em Leipziger fosse classificado como confundidor em vez de colisor? O resultado principal (IVBs sao pequenos) depende criticamente de quais controles sao classificados como colidores.

- **Nao ha variacao nas especificacoes.** As replicacoes usam a especificacao principal de cada paper. E se especificacoes alternativas (mais/menos controles, diferentes lags) produzissem IVBs substancialmente diferentes?

- **As simulacoes confirmam a algebra mas nao testam o diagnostico.** Um teste de robustez relevante seria: gerar dados com colisores de magnitude conhecida, aplicar o diagnostico IVB, e verificar se ele leva a melhores decisoes de especificacao (em termos de MSE, cobertura, etc.).

### E.3 Selecao amostral [Adequada]

Os seis estudos cobrem dominios variados e representam aplicacoes tipicas de TSCS em CP. A selecao nao parece ser cherry-picked (inclui casos com IVB grande como Rogowski). No entanto, todos os seis estudos usam TWFE com variaveis relativamente similares (GDP per capita aparece em quase todos), o que levanta a questao de se o resultado "IVBs sao pequenos" generalizaria para estudos com variaveis de controle menos padronizadas.

### E.4 Explicacoes alternativas [Parcial]

O paper reconhece a principal explicacao alternativa na Secao 4.7: que a formula nao distingue entre vies por colisor, vies por variavel omitida, e mediacao. O caso Rogowski et al. ilustra isso. No entanto, o paper nao leva esta observacao a sua conclusao logica: se a formula e uma identidade algebrica que vale para qualquer variavel incluida, *independentemente* de ser colisor, entao chamar o resultado de "Included Variable Bias" e potencialmente enganoso. O "bias" so existe se Z e de fato um colisor -- mas a formula nao pode determinar isso. O paper precisa ser mais cuidadoso em distinguir a *formula* (sempre valida) do *diagnostico* (valido apenas com classificacao DAG correta).

Uma segunda explicacao alternativa nao discutida: os IVBs empiricos sao pequenos em parte porque os *efeitos causais estimados* nos estudos selecionados sao eles proprios imprecisos. Em Claassen (2020), o SE e 0.216 e o coeficiente e -0.016 -- qualquer IVB pareceria pequeno relativo a este SE. O resultado "IVBs sao pequenos em unidades de SE" e parcialmente um artefato da imprecisao das estimativas.

### E.5 Variaveis instrumentais [N/A]

Nao se aplica diretamente. O paper menciona em nota de rodape a extensao para 2SLS mas nao a desenvolve.

### Avaliacao Teorica

### T.1 Distancia premissas-conclusoes [Adequada]

As derivacoes sao corretas e transparentes. A Proposicao 1 (cross-section) e uma consequencia direta de FWL. A extensao para ADL (Proposicao 2) requer a premissa adicional de que os controles "legitimos" sao corretamente especificados, o que e razoavel. A Proposicao 4 (lag substitution) e o Corolario 1 (IVB decay sob AR(1)) sao resultados genuinamente informativos. A distancia entre premissas e conclusoes e pequena para os resultados algebricos (o que e esperado de identidades) e moderada para os resultados sobre magnitude (que dependem de premissas sobre o DGP).

### T.2 Parcimonia [Forte]

O mecanismo e parcimonioso: IVB = -theta* x pi. Dois numeros. Tres passos na receita. A simplicidade e uma das principais virtudes do paper.

### T.3 Caminho causal [Adequado com ressalvas]

O caminho causal esta livre de circularidade nas derivacoes algebricas. No entanto, nas aplicacoes empiricas, ha um problema de circularidade potencial: a formula usa coeficientes do modelo "longo" (que inclui o colisor) para estimar o vies de incluir o colisor. Isso nao e um erro algebrico (a identidade e valida), mas pode ser confuso para o leitor: estamos usando o modelo errado para diagnosticar o quanto ele e errado. O paper poderia esclarecer esta questao.

## Veredicto geral sobre execution

A execucao e competente no nivel algebrico e nas replicacoes, mas insuficiente no nivel do diagnostico. O paper demonstra convincentemente que a formula e algebricamente correta (trivialmente, ja que e uma identidade) e que IVBs empiricos sao modestos em seis estudos. No entanto, nao demonstra que a formula e um *bom diagnostico* -- ou seja, que usa-la leva a melhores decisoes de especificacao. A principal fraqueza e a falta de testes de robustez substantivos: sensibilidade das classificacoes DAG, variacao nas especificacoes, e simulacoes que validem o uso da ferramenta como regra de decisao. A tensao entre a formula como identidade algebrica e como diagnostico causal precisa de resolucao mais rigorosa.

## Sugestoes construtivas

1. **Adicionar simulacoes de "decision-making".** Gerar dados com DGP conhecido (incluindo colisores de magnitude variavel), aplicar o diagnostico IVB, e mostrar que pesquisadores que seguem a receita (excluir controles com IVB grande) obteem estimativas com menor MSE ou melhor cobertura do que pesquisadores que incluem tudo.

2. **Analise de sensibilidade das classificacoes DAG.** Para pelo menos um estudo, considerar classificacoes alternativas (e.g., GDP como confundidor puro vs. colisor puro vs. misto) e mostrar como o diagnostico muda.

3. **Ser mais explicito sobre a limitacao fundamental.** A formula nao pode distinguir colisor de confundidor. Esta limitacao deve ser parte da narrativa principal, nao apenas um caveat na Secao 4.7.

4. **Considerar adicionar o delta-method SE formal para o IVB** (referenciado no Apendice E) nas aplicacoes empiricas, nao apenas o upper bound Cauchy-Schwarz.

---

## Parecer completo -- Exposition

# Parecer de Exposition (Framework Edmans)

## Score: 7/10

## Avaliacao por dimensao

### Clareza [Boa]

#### Qualidade da escrita

A escrita e clara, profissional e tecnicamente precisa. Nao identifiquei typos significativos no texto principal. A notacao e consistente (com a excepcao menor de usar beta_2* na cross-section e theta* no ADL para o mesmo conceito -- os autores explicam isso na nota de rodape 1, mas a troca e desnecessaria e levemente confusa). Os DAGs sao bem desenhados e as tabelas bem formatadas.

#### Significancia substantiva

O abstract contem numeros memoraveis: "median IVBs are approximately 0.13 standard errors" e "only one candidate exceeds one standard error (|IVB/SE| = 2.11, corresponding to 58% of the treatment effect)." Estes numeros sao efetivos e ancoram a contribuicao empirica. A Secao 6 (aplicacoes) mantem esta pratica com numeros concretos para cada decomposicao. A distincao entre significancia estatistica e substantiva e bem feita na discussao de Claassen (IVB pequeno em unidades de SE mesmo quando IVB/beta seria grande).

#### Precisao da linguagem

Geralmente precisa. Uma excecao importante: o titulo usa "bias" (Included Variable *Bias*), mas a formula e uma identidade algebrica que nao necessariamente mede vies no sentido causal. O paper reconhece isso na Secao 4.7, mas o framing geral (incluindo titulo, abstract, e grande parte da narrativa) assume que Z e um colisor, o que e a premissa menos robusta do paper. Sugestao: considerar um titulo alternativo como "Included Variable Bias: A Diagnostic Formula for Collider Bias in Cross-Sectional and Time-Series Cross-Sectional Regressions" que capture melhor a natureza diagnostica (vs. afirmativa) da ferramenta.

Outra imprecisao: a expressao "foreign collider bias" e cativante mas potencialmente confusa. "Foreign" nao e o melhor adjetivo -- sugere algo internacional. "Cross-literature collider bias" ou "cross-domain collider bias" seria mais preciso.

### Extensao [Longo]

#### Introducao

A introducao tem aproximadamente 5 paginas (linhas 59-118), o que esta no limite superior do aceitavel. Os dois primeiros paragrafos (contexto e motivacao) sao efetivos. A secao sobre heuristicas (Control Checking e Confounding Checking, com citacoes longas) poderia ser condensada -- o publico de PSRM ja conhece estas heuristicas. A subsecao "Related Work on Collider Bias Quantification" (linhas 111-118) e essencial mas longa; poderia ser integrada mais concisamente na intro com detalhes movidos para uma nota de rodape ou apendice.

A introducao contem todos os elementos essenciais: motivacao, formula, extensao ADL, resultado sobre lags, mecanismos para IVB pequeno, resultados empiricos. A estrutura e clara. A principal critica e que ha muita "real estate" gasta em dizer que controlar e importante (algo que o leitor de PSRM ja sabe) e pouca em preview dos resultados empiricos (que sao o atrativo do paper).

#### Notas de rodape

Conto aproximadamente 3 notas de rodape no texto principal (autoria, notacao, extensao 2SLS). Isso esta dentro do aceitavel. As notas sao informativas e nao parecem conter material que deveria estar no texto principal.

#### Extensoes desnecessarias

O Apendice C (Additional Simulation Plots) contem tres figuras que basicamente confirmam a formula -- dado que a formula e uma identidade, estas figuras sao de valor marginal. O scatter plot (Figura A1, formula vs. empirico) e util como sanity check mas poderia estar no texto principal ou ser removido. As figuras de densidade e efeito de rho sao illustrativas mas nao essenciais.

O Apendice F (classificacao completa + tabela de todos os 57 controles) e longo mas necessario para transparencia. A Tabela A7 com todos os 57 controles e um bom complemento ao texto principal.

### Citacoes [Algumas problematicas]

#### Problemas especificos

1. **Citacao de Pearl (2009) para DAGs**: Adequada, pois Pearl e a referencia canonica.

2. **Citacao de fatos institucionais**: A citacao de Dietrich (2016) e Hegre et al. (2001) como exemplos de heuristicas e efetiva e bem usada. No entanto, a frase "The selection of control variables is a critical step in observational studies" (linha 61) nao precisa de citacao -- e um fato de conhecimento comum.

3. **Citacoes nas classificacoes DAG**: As tabelas de classificacao no Apendice F citam papers para justificar as classificacoes (e.g., Acemoglu et al. 2019 para D-->Z, Grundler & Link 2024 para Y-->Z). Estas citacoes sao essenciais e bem usadas. No entanto, algumas classificacoes nao tem citacao ("---" na coluna de referencias), o que levanta a questao de como foram justificadas.

4. **Citacao de Beck (1995)**: "TSCS settings... are ubiquitous in comparative politics (Beck 1995)." Isso e um fato de conhecimento geral e a citacao e discutivel, embora Beck seja efetivamente a referencia canonica para PCSE/TSCS.

5. **Auto-citacoes**: Nao ha auto-citacoes excessivas.

No geral, a lista de referencias e razoavelmente enxuta e focada. Nao identifiquei citacoes estrategicas ou mis-citacoes significativas.

## Veredicto geral sobre exposition

A exposicao e boa: clara, bem organizada e com numeros memoraveis. O paper segue uma estrutura logica (problema --> DAGs --> formula --> mecanismos --> aplicacoes --> conclusao) que e facil de seguir. As principais oportunidades de melhoria sao: (1) encurtar a introducao, especialmente a revisao de heuristicas; (2) resolver a tensao entre o framing como "bias" e a natureza de identidade algebrica da formula; (3) considerar se "foreign collider bias" e o melhor termo. A qualidade da exposicao nao impede a avaliacao da contribuicao ou da execucao.

## Top 5 sugestoes de melhoria

1. **Encurtar a Secao 2 (Control Variable Problem).** O publico de PSRM ja sabe que selecao de controles importa. As subsecoes 2.1 e 2.2 poderiam ser condensadas em um unico paragrafo com as citacoes de Dietrich e Hegre como exemplos. A subsecao 2.3 (Quantification Gap) poderia ser integrada a introducao.

2. **Unificar a notacao cross-section/ADL.** Usar theta* e pi desde o inicio (em vez de beta_2* e phi_1 na cross-section e depois trocar) eliminaria uma fonte de confusao desnecessaria. A nota de rodape 1 ja sinaliza a preferencia pela notacao ADL -- entao use-a desde o inicio.

3. **Reescrever o titulo ou adicionar subtitulo esclarecedor.** O titulo atual sugere que a formula mede "bias" em sentido causal, quando na verdade e uma decomposicao algebrica cuja interpretacao como vies depende do DAG. "A Diagnostic Formula for Collider Bias..." seria mais preciso.

4. **Mover o scatter plot formula-vs-empirico (Figura A1) para o texto principal.** E a unica figura de simulacao que agrega valor real (mostrando que a formula vale empiricamente). As outras figuras do Apendice C podem ser removidas sem perda.

5. **Considerar renomear "foreign collider bias" para "cross-domain collider bias" ou "extra-literature collider bias".** O termo "foreign" e ambiguo e pode confundir leitores que associam a palavra com relacoes internacionais.
