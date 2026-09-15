# Confronto bibliográfico do Gate 1

**Data:** 15 de setembro de 2026  
**Responsável:** leitor bibliográfico do Gate 1  
**Escopo:** contribuição metodológica do diagnóstico de deslocamento de especificação e seu uso em TSCS; nenhuma análise foi executada e nenhum arquivo do manuscrito foi alterado.

## Resultado principal

**A literatura lida não sustenta, no estado atual, a originalidade matemática ou inferencial do núcleo apresentado no manuscrito.** A identidade escalar, sua forma vetorial, a decomposição conjunta de uma mudança entre modelos aninhados, a alocação condicional que soma exatamente ao deslocamento, a exigência de amostra comum e uma matriz de covariância robusta ou agrupada já aparecem na documentação e no código primário de `b1x2`, de Jonah Gelbach. Com a convenção de sinais do manuscrito,

\[
\widehat\Delta_Z=\widehat\beta_{\mathrm{long}}-
\widehat\beta_{\mathrm{short}}=-\widehat\theta'\widehat\pi;
\]

com a convenção de `b1x2`,

\[
\widehat d=\widehat\beta_{\mathrm{base}}-
\widehat\beta_{\mathrm{full}}=\widehat\Gamma\widehat b_2.
\]

Para o coeficiente focal de $D$, $X_1=(D,W)$, $X_2=Z$, $\widehat b_2=\widehat\theta$ e a linha de $\widehat\Gamma$ correspondente a $D$ é $\widehat\pi'$. As duas expressões são a mesma identidade com sinal invertido.

O material lido tampouco sustenta que nomear o deslocamento, separar “outcome association” e “treatment association”, usar vários controles ou preservar a dependência entre os coeficientes constitua, por si, um novo objeto metodológico. Gelbach já oferece a decomposição condicional; Cinelli, Forney e Pearl já mostram que o significado causal do deslocamento depende do estimando e da estrutura causal; Blackwell e Glynn, Imai e Kim e Bellemare, Masaki e Pepinsky já mostram por que a informação temporal e a história condicionante são necessárias em painéis.

Resta uma rota **operacional** plausível: transformar essas peças em um procedimento explícito que obrigue o usuário de TSCS a declarar estimando, relógio causal, história pré-exposição, conjunto comum de linhas, comparação aninhada e ação diante do resultado. Essa rota ainda não passou o teste do Gate 1. Para passar, precisa demonstrar uma decisão correta ou uma perda evitada que um comparador Gelbach/FWL, munido do mesmo DAG, timing e histórico, não reproduza. A leitura atual encontra equivalência no núcleo e não encontra ainda esse resultado adicional.

**Estado deste módulo:** `NÃO LIBERADO PARA AFIRMAÇÃO DE NOVIDADE`. O artigo integral de Gelbach (2016) continua indisponível; por isso, este relatório não atribui ao artigo limites que foram observados apenas na interface computacional. A evidência do software é suficiente para rejeitar afirmações de que as capacidades que ele implementa não existiam, mas não é suficiente para caracterizar toda a contribuição conceitual do artigo.

## 1. Pergunta de contribuição e comparador forte

### Problema e decisão do usuário

O usuário do procedimento é o pesquisador que estima o efeito contemporâneo de $D_{it}$ sobre $Y_{it}$ em dados de séries temporais seccionais e precisa decidir como tratar uma covariável observada em torno do mesmo período. A decisão concreta pode ser: manter $Z_{it}$ contemporâneo, usar uma medida comprovadamente anterior à exposição, omitir $Z$, reconhecer que nenhuma das opções identifica o alvo, ou mudar de desenho/estimador.

O procedimento proposto calcula quanto a escolha move o coeficiente de $D$ e usa estimando, DAG, relógio causal e histórico para interpretar o movimento. A equação, sozinha, mede uma mudança de projeção. Ela não determina se essa mudança é remoção de confundimento, sobrecontrole, viés de colisor, mudança do estimando ou uma combinação desses casos.

### Comparador que recebe a mesma informação

O comparador forte combina:

1. a decomposição condicional FWL/Gelbach;
2. exatamente o mesmo DAG, timing, histórico e estimando fornecidos à proposta;
3. a mesma amostra e as mesmas convenções de ponderação;
4. inferência pareada ou a matriz de covariância conjunta;
5. as restrições dinâmicas já expostas por Blackwell e Glynn, Imai e Kim e Bellemare et al.

Para a comparação em que uma variável sai do conjunto defasado e entra no conjunto contemporâneo, os modelos não são aninhados entre si. Defina

\[
B=(D,W,L),\qquad C=(D,W,Z),\qquad U=(D,W,L,Z),
\]

onde $L$ é a versão defasada e $Z$ a contemporânea. O comparador calcula dois deslocamentos aninhados, $B\rightarrow U$ e $C\rightarrow U$, e usa

\[
\widehat\beta_C-\widehat\beta_B
=
(\widehat\beta_U-\widehat\beta_B)
-(\widehat\beta_U-\widehat\beta_C).
\]

Cada parcela admite a decomposição Gelbach/FWL. A covariância entre todas as parcelas pode ser preservada por estimação conjunta ou reamostragem pareada. Se os dois procedimentos recebem o mesmo DAG e a mesma história, também recebem os mesmos rótulos causais. Logo, uma vantagem não pode ser produzida impedindo artificialmente o comparador de estimar os modelos de união ou de aplicar as hipóteses fornecidas.

## 2. O que cada fonte estabelece

### 2.1 Gelbach: decomposição, alocação e covariância

O texto integral do artigo de Gelbach (2016), *When Do Covariates Matter? And Which Ones, and How Much?*, DOI `10.1086/683668`, não foi obtido. Foram lidos integralmente os 457 versos da ajuda oficial de `b1x2` e inspecionadas as partes relevantes dos 1.352 versos do código oficial, versão 4.1.0, escrito pelo autor.

**Fatos observados na fonte primária computacional:**

- A ajuda descreve explicitamente o programa como decomposição condicional das diferenças entre especificações, alternativa à inclusão sequencial de covariáveis, e afirma que calcula erro-padrão consistente da diferença (`gelbach_b1x2.sthlp`, versos 35–42).
- O modelo usa $X_1$ em base e full e $X_2$ apenas no full. A diferença é definida como base menos full (`sthlp`, 120–158).
- A identidade $\widehat d=(X_1'X_1)^{-1}X_1'X_2\widehat b_2$ aparece nos versos 164–168.
- Covariáveis de $X_2$ podem ser divididas em grupos mutuamente exclusivos. Os componentes condicionais $\widehat d_g$ somam exatamente ao deslocamento total (`sthlp`, 180–203). Isso já trata uma alocação conjunta para controles correlacionados sem depender da ordem de inclusão.
- A opção `robust` é heterocedasticity robust; `cluster()` permite dependência arbitrária dentro do grupo (`sthlp`, 79–82).
- `gamma0` impõe ortogonalidade; `cov0` ignora a covariância entre componentes estimados de $b_2$ e de $\Gamma$, sendo apropriado somente sob condições remetidas ao Apêndice B (`sthlp`, 225–236). Portanto, ignorar esses termos é uma opção restritiva, não o padrão documentado.
- O programa exige a mesma amostra nas duas especificações (`sthlp`, 242–251).
- A versão 4.1.0 dá suporte a pesos, variáveis endógenas e IV/2SLS (`gelbach_b1x2.ado`, 1–24). Esse escopo computacional é mais amplo que a proposição atual do manuscrito, declarada para OLS não ponderado.
- O código calcula $\widehat\Gamma$, $\widehat b_2$ e $\widehat\delta=\widehat b_2\widehat\Gamma'$ (`ado`, 472–483); implementa versões robusta e agrupada (`ado`, 731–805); e, no padrão irrestrito, forma a covariância como soma da incerteza da regressão auxiliar, da incerteza de $\widehat b_2$ e dos dois termos cruzados (`ado`, 920–959).
- A soma total é construída por uma matriz $R$, que também transforma a covariância (`ado`, 1035–1056), e `Delta`/`Covdelta` são devolvidas ao usuário (`ado`, 1194–1226).
- O aviso nos versos 1230–1233 diz que a covariância **reportada** entre a linha agregada `__TC` e os demais componentes é zero e incorreta. Esse aviso não autoriza dizer que a matriz entre componentes ou os termos cruzados do produto são ignorados: ambos são calculados no código anterior.

**Inferência limitada pelas fontes disponíveis:** a interface não recebe DAG, estimando ou timestamps como entradas. Isso mostra que a ferramenta computacional não força essas declarações. Não mostra que o artigo integral ignore interpretação causal, tempo ou desenho; essa caracterização exige o texto que falta.

### 2.2 Cinelli, Forney e Pearl: o deslocamento não classifica o controle

O manuscrito dos autores, datado de 21 de março de 2022, foi lido nas 30 páginas. Ele estabelece que “bom” ou “ruim” não é uma propriedade dada pelo rótulo pré/pós-tratamento. Há controles pré-tratamento que abrem caminhos de colisor, mediadores que mudam o alvo de efeito total para direto, controles pós-tratamento neutros em alguns grafos e casos em que incluir e omitir falham. Com vários controles, a classificação de uma variável também pode mudar conforme o conjunto condicionado.

Os critérios formais e os exemplos gráficos aparecem nas pp. 1–14; a definição por modelo causal estrutural, intervenções, efeito médio e efeito direto controlado está nas pp. 20–24; a forma de regressão parcial usada nos exemplos lineares está nas pp. 25–30.

**Implicação para a proposta:** sinal, magnitude ou significância de $\widehat\Delta_Z$ não revelam a função causal de $Z$. Duas estruturas podem gerar o mesmo deslocamento observacional e recomendar ações opostas. O ganho possível é disciplinar o registro da informação causal externa; o cálculo não cria essa informação.

### 2.3 Blackwell e Glynn: CET, história e pós-tratamento em TSCS

O artigo publicado de 16 páginas foi lido integralmente. Blackwell e Glynn definem efeitos contemporâneos e defasados em histórias de tratamento, formulam ignorabilidade sequencial e comparam ADL, modelos estruturais marginais e modelos estruturais aninhados.

A Eq. (17) aparece ao final da p. 1072. Na p. 1073, os autores explicam que, sob ignorabilidade sequencial, forma funcional correta e a condição de erro declarada, um ADL com $Y_{t-1}$, $X_t$, $X_{t-1}$ e $Z_t$ estima consistentemente o efeito contemporâneo $\beta_1$. O problema de condicionamento pós-tratamento atinge diretamente a interpretação dos efeitos defasados quando $Z_t$ pode ser afetado por tratamento passado. As pp. 1073–1075 mostram a alternativa de g-estimation sequencial, que inclui somente variáveis causalmente anteriores ao tratamento cujo efeito se estima. As pp. 1075–1077 apresentam IPTW/MSM, positividade e inferência por block bootstrap; as pp. 1077–1079 documentam os padrões em simulação.

**Implicação para a proposta:** o caso básico “ADL para CET sob seleção em observáveis e ordem causal correta” é conhecido. A proposta usa ADL + efeitos fixos, portanto precisa declarar quais restrições adicionais tornam válida essa combinação e o que ela acrescenta ao resultado conhecido. Blackwell e Glynn observam que o papel de efeitos fixos sob ignorabilidade sequencial exige desenvolvimento; isso não transforma automaticamente a combinação em contribuição, pois Imai e Kim mostram as restrições causais próprias dos efeitos fixos.

### 2.4 Imai e Kim (2019): efeitos fixos compram controle invariante com restrições dinâmicas

O artigo publicado de 24 páginas foi lido integralmente. As pp. 467–474 mostram que a interpretação causal do modelo com efeitos fixos de unidade depende, além de ausência de confundimento não observado variante no tempo, de restrições sobre relações dinâmicas: tratamento passado não pode afetar diretamente o desfecho corrente e desfecho passado não pode afetar tratamento corrente no modelo básico. Incluir defasagens relaxa algumas restrições, mas o número de defasagens costuma ser escolhido sem fundamento substantivo e introduz outras exigências. Os autores contrastam essa estratégia com seleção em observáveis e desenvolvem uma representação por matching nas pp. 475–483.

**Implicação para a proposta:** chamar $H_{t-1}$ de “história” não o torna suficiente, e um rótulo defasado não estabelece ordem substantiva. Uma justificativa para $Y_{t-1}\rightarrow D_t$ compatível com seleção em observáveis não pode ser simplesmente importada para o argumento causal padrão de efeitos fixos de unidade. A proposta deve explicitar qual estimando e qual conjunto de restrições sustentam a combinação ADL + FE.

### 2.5 Imai e Kim (2021): efeitos fixos de duas vias e o alvo da projeção

O artigo publicado em *Political Analysis*, 12 páginas de PDF, foi lido integralmente. As pp. 405–410 mostram que o modelo linear com efeitos fixos de unidade e tempo depende de aditividade e separabilidade e não equivale, em geral, a ajuste não paramétrico conjunto para confundidores não observados de unidade e tempo. As pp. 410–413 conectam 2FE a diferenças-em-diferenças e mostram que a regressão padrão pode usar comparações e pesos que não entregam o estimando desejado, inclusive pesos negativos em certos desenhos.

**Implicação para a proposta:** um deslocamento exato de coeficientes continua sendo uma mudança entre projeções. Efeitos fixos e um vetor de controles não asseguram interpretação causal para qualquer dos coeficientes, nem que eles correspondam ao mesmo estimando. O relatório aplicado deve declarar o alvo causal de referência e, separadamente, se cada coeficiente identifica esse alvo, identifica outro estimando ou não possui interpretação causal identificada; também deve explicitar as comparações e, quando pertinente, os pesos implícitos. A álgebra descritiva do deslocamento permanece válida em todos esses casos e não resolve essa classificação.

### 2.6 Bellemare, Masaki e Pepinsky: defasar não resolve endogeneidade

O artigo publicado de 16 páginas de PDF foi lido integralmente. Nas pp. 949–954, os autores distinguem uma defasagem exigida pela teoria, uma defasagem estatística e o uso de defasagem como resposta à endogeneidade. Nesse terceiro uso, defasar $X$ apenas move o canal do viés: a identificação requer persistência em $X$ e ausência de dinâmica relevante nos não observados, ou ausência da endogeneidade que motivou a defasagem. As simulações e extensões nas pp. 955–959 mostram viés e erro de tipo I sob persistência de $U$, inclusive com desfecho defasado, FE ou GMM em vários cenários.

Na p. 961, os autores propõem dois testes de falsificação diretamente próximos ao procedimento em exame: (i) incluir $X_t$ com $X_{t-1}$, pois um coeficiente contemporâneo diferente de zero rejeita o cenário em que apenas a defasagem é causal e a endogeneidade decorre de causalidade reversa contemporânea; (ii) incluir $Y_{t-1}$ com $X_t$, pois um coeficiente defasado de $Y$ diferente de zero rejeita a hipótese de ausência de dinâmica do desfecho. Os testes podem rejeitar as condições; não confirmam identificação quando não rejeitam.

**Implicação para a proposta:** esses testes precisam ser citados como resultados existentes se forem incorporados. A recomendação de defender timestamps é consistente com a literatura, mas não basta diante de confundimento persistente não observado.

## 3. Confronto por dimensão

### Álgebra multivariada

Gelbach já fornece a forma multivariada e a decomposição por grupos. A proposição atual do manuscrito é uma especialização com $X_1=(D,W)$ e $X_2=Z$, usando a convenção full menos base. A correlação entre controles não invalida a decomposição conjunta de Gelbach. Portanto, “múltiplos controles” ou “controles correlacionados” não distinguem a proposta.

### Alocação

O endpoint base–full é único. Parcelas sequenciais dependem da ordem; leave-one-out responde a comparações condicionais diferentes e não soma em geral; Shapley calcula uma média simétrica sobre ordens. Essas afirmações são corretas, mas não geram um novo resultado causal. `b1x2` já oferece uma alocação condicional por grupos que soma exatamente ao endpoint, estimada no modelo completo. Uma defesa de LOO ou Shapley precisa especificar qual decisão melhora e por que a alocação Gelbach não atende à mesma finalidade.

### Covariância

Não é correto apresentar Gelbach como iid ou como método que ignora a dependência entre $\widehat\theta$ e $\widehat\pi$. A ajuda oferece `robust` e `cluster()`; o código irrestrito inclui os termos cruzados da incerteza de $b_2$ e $\Gamma$. A diferença pareada $\widehat\beta_L-\widehat\beta_S$, o delta do produto e a decomposição Gelbach são representações do mesmo objeto quando modelos, amostra, pesos e VCE coincidem. Block bootstrap por unidade pode ser uma implementação conveniente para painéis, mas é preciso mostrar uma propriedade inferencial ou uma classe de dependência que o comparador, configurado de modo adequado, não reproduza.

### Informação temporal e hipóteses

Aqui existe a diferença mais clara de ênfase: `b1x2` aceita matrizes de regressão, não um relógio causal. A informação necessária, porém, já está desenvolvida em Cinelli et al. para o papel causal dos controles e em Blackwell–Glynn, Imai–Kim e Bellemare et al. para a ordem temporal e as restrições dinâmicas. Dar essas mesmas informações ao comparador elimina uma vantagem baseada apenas em acesso desigual à DAG ou à história. O acréscimo defensável teria de ser um protocolo operacional verificável que coordena essas peças, ou um resultado formal que diga algo que as peças combinadas não dizem.

### Hipóteses que precisam acompanhar qualquer resultado

Pelo menos as seguintes condições devem ser separadas, porque nenhuma é garantida pela identidade FWL:

- alvo causal de referência da pergunta e relação de cada coeficiente com esse alvo, explicitando se o coeficiente identifica o alvo, corresponde a outro estimando ou carece de interpretação causal identificada; a identidade descritiva permanece válida nos três casos;
- consistência, ausência de interferência e ausência de antecipação pertinentes ao alvo;
- relógio dentro do período e definição de $H_{it}^{-}$ anterior à exposição;
- exchangeability/ignorabilidade condicional para o tratamento corrente, quando essa for a rota;
- positividade/suporte para o contraste;
- ausência das relações dinâmicas incompatíveis com a justificativa de FE usada;
- forma funcional e heterogeneidade compatíveis com o coeficiente reportado;
- mesma amostra, pesos e transformação para a identidade e para a comparação;
- dependência temporal e entre unidades contemplada pela inferência;
- ausência de interpretação causal automática do sinal de $\Delta$.

## 4. Dois exemplos para o teste de contribuição

### Exemplo 1 — substituição com cancelamento: benefício de organização, ausência de ganho contra o comparador forte

Suponha que o pesquisador compare $B=(D,W,L)$ e $C=(D,W,Z)$. O coeficiente de $D$ quase não muda entre $B$ e $C$, mas isso resulta de dois deslocamentos grandes e de sinais opostos: adicionar $Z$ a $B$ move o coeficiente para baixo; adicionar $L$ a $C$ também move o coeficiente para baixo, de modo que a diferença líquida entre os modelos mascara os canais.

O procedimento proposto pode ajudar o leitor a ver o cancelamento e exigir a classificação temporal de $L$ e $Z$. Esse é um benefício de organização. Porém, o comparador com $U=(D,W,L,Z)$ calcula os dois deslocamentos aninhados, decompõe cada um por Gelbach e recebe o mesmo DAG/timing. Ele reproduz a álgebra, a incerteza e a interpretação. Este exemplo força o reconhecimento de equivalência, salvo se a proposta produzir uma ação correta adicional claramente especificada.

### Exemplo 2 — mesmo deslocamento, papéis causais diferentes: ambiguidade obrigatória

Considere duas estruturas com o mesmo ajuste linear e o mesmo $\widehat\Delta_Z$. Na primeira, $Z$ é causa comum de $D$ e $Y$, e o deslocamento pode refletir remoção de confundimento. Na segunda, $Z$ é mediador do efeito contemporâneo ou colisor afetado por $D$, e a mesma mudança pode representar troca do efeito total pelo direto ou abertura de caminho não causal. Uma terceira estrutura pode tornar incluir e omitir insuficientes.

Nenhum dos procedimentos decide apenas com covariâncias observadas. Com a DAG correta, ambos recebem a mesma classificação; sem ela, a resposta correta é “ambíguo/inconclusivo” e possivelmente mudar de desenho. O exemplo mostra o limite do diagnóstico e impede que magnitude ou sinal sejam tratados como validação causal.

## 5. Ataque exigido: “isto é Gelbach mais um checklist já conhecido?”

### O que o ataque derruba

- **Objeto nomeado e estimável:** a mudança base–full e sua decomposição já são objetos estimáveis em Gelbach.
- **Dois fatores:** associação de $X_2$ com o desfecho no full e projeção de $X_2$ em $X_1$ já geram o produto de Gelbach.
- **Vários controles e controles correlacionados:** já cobertos pela decomposição conjunta e por grupos.
- **Soma exata e independência de uma sequência de entrada:** já cobertas pela alocação condicional de Gelbach.
- **Amostra comum:** requisito explícito do software existente.
- **Dependência entre estimativas e clustering:** contemplados pela matriz conjunta; o software oferece VCE robusta/agrupada e inclui termos cruzados por padrão.
- **DAGs, controles bons/ruins e timing:** conteúdos conhecidos em Cinelli et al. e na literatura longitudinal lida.
- **Dois testes de dinâmica:** já apresentados por Bellemare et al. como testes de falsificação.

### O que pode sobreviver, mas ainda exige demonstração

1. **Organização operacional:** uma ficha que liga o deslocamento ao relógio causal e impede interpretação automática pode reduzir erros de uso. Isso é uma contribuição operacional ou pedagógica até que exista evidência mais forte.
2. **Extensão formal específica:** poderia existir se o projeto desenvolver um resultado que combine substituição não aninhada, histórico temporal e inferência sob dependência de painel de modo não reproduzível por dois deslocamentos Gelbach/FWL. O resultado atual não faz isso.
3. **Aplicação substantiva reveladora:** uma aplicação pode mostrar por que a disciplina do protocolo altera uma decisão importante. Isso sustenta valor aplicado; não retroage para tornar nova a identidade.

### Evidência mínima para mudar o diagnóstico

- leitura integral de Gelbach (2016) antes de qualquer afirmação de novidade;
- proposição ou capacidade formulada sem nomes internos;
- implementação do comparador $(B,C,U)$ com mesma amostra, DAG, timing, histórico e VCE;
- caso pré-especificado em que os dois procedimentos recomendam ações distintas;
- critério de acerto ou perda independente do tamanho/significância de $\Delta$;
- explicação de qual insumo ou resultado exclusivo produz a diferença;
- se o ganho for de compreensão/adoção, evidência apropriada a esse ganho, sem chamá-lo automaticamente de avanço metodológico.

## 6. Recomendação para o Gate 1

O confronto bibliográfico deve ser incorporado à ficha congelada com a seguinte classificação:

| Dimensão pretendida | Classificação após a leitura | Razão |
|---|---|---|
| Matemática | **equivalente no núcleo** | identidade e decomposição multivariada já implementadas por Gelbach |
| Inferencial | **equivalente em grande parte; diferença não demonstrada** | covariância conjunta, robust e cluster já existem; bootstrap por unidade é uma implementação possível |
| Computacional | **sem vantagem demonstrada e atualmente mais estreita** | `b1x2` suporta grupos, pesos e IV/2SLS |
| Causal | **depende de informação externa conhecida** | DAG, estimando e timing classificam o deslocamento; a fórmula não o faz |
| Operacional | **candidato plausível, ainda sem teste distintivo** | integração disciplinada pode ajudar, mas o comparador forte recebe a mesma informação |

Assim, este módulo não recomenda congelar frases como “the paper's originality lies” em um objeto “named and estimable” enquanto o objeto for apenas a decomposição base–full. A rota cientificamente defensável é estreitar a reivindicação para integração operacional/aplicada, ou desenvolver e provar uma capacidade adicional. A escolha entre essas rotas é decisão do autor.

## 7. Cobertura, versões e limites

| Fonte | Versão lida | Cobertura | Localizadores centrais |
|---|---|---|---|
| Blackwell & Glynn (2018) | PDF publicado, APSR 112(4), DOI `10.1017/S0003055418000357` | 16/16 páginas | pp. 1067–1071; Eq. 17 p. 1072; discussão de consistência p. 1073; pp. 1073–1079 |
| Cinelli, Forney & Pearl | PDF dos autores, 21 mar. 2022 | 30/30 páginas | pp. 1–14; 20–30 |
| Imai & Kim (2019) | artigo publicado, AJPS 63(2), DOI `10.1111/ajps.12417` | 24/24 páginas do PDF; artigo pp. 467–490 | pp. 467–483 |
| Imai & Kim (2021) | artigo publicado, *Political Analysis* 29(3), DOI `10.1017/pan.2020.33` | 12/12 páginas do PDF; artigo pp. 405–415 | pp. 405–413 |
| Bellemare, Masaki & Pepinsky (2017) | artigo publicado, JOP 79(3), DOI `10.1086/690946` | 16/16 páginas do PDF; artigo pp. 949–963 | pp. 949–961 |
| Gelbach (2016) | artigo publicado, JLE 34(2), DOI `10.1086/683668` | **texto integral não obtido**; resumo editorial conhecido | resumo apenas; não usado como leitura integral |
| Gelbach, `b1x2.sthlp` | ajuda oficial do SSC/RePEc | 457/457 versos | 35–65, 79–89, 114–203, 222–251 |
| Gelbach, `b1x2.ado` | versão 4.1.0, 20 jan. 2010 | inspeção dirigida; não leitura integral verso a verso | 1–24, 472–483, 731–805, 920–959, 1035–1056, 1194–1233 |

Os SHA-256, caminhos e estados de leitura estão em `reader_manifest.json`. A matriz claim a claim, com evidência exigida, está em `reader_claim_comparison.csv`.

### Limites deliberados

- Não se inferiu o conteúdo integral de Gelbach (2016) a partir do resumo, da ajuda ou do código.
- Não se testou `b1x2`, Stata, R, os exemplos do manuscrito ou propriedades de cobertura dos intervalos.
- Não se avaliou se uma aplicação específica é documentalmente viável; essa é a frente separada de triagem do Gate 1.
- Não se afirma que a integração operacional não possa ter valor. Afirma-se que esse valor ainda não foi distinguido de um comparador forte com a mesma informação.

## Referências confrontadas

- Bellemare, Marc F., Takaaki Masaki, and Thomas B. Pepinsky. 2017. “Lagged Explanatory Variables and the Estimation of Causal Effect.” *The Journal of Politics* 79(3): 949–963. DOI: `10.1086/690946`.
- Blackwell, Matthew, and Adam N. Glynn. 2018. “How to Make Causal Inferences with Time-Series Cross-Sectional Data under Selection on Observables.” *American Political Science Review* 112(4): 1067–1082. DOI: `10.1017/S0003055418000357`.
- Cinelli, Carlos, Andrew Forney, and Judea Pearl. “A Crash Course in Good and Bad Controls.” PDF dos autores datado de 21 de março de 2022.
- Gelbach, Jonah B. 2016. “When Do Covariates Matter? And Which Ones, and How Much?” *Journal of Labor Economics* 34(2): 509–543. DOI: `10.1086/683668`. Artigo integral não lido; capacidades computacionais verificadas na ajuda e no código oficiais de `b1x2`.
- Imai, Kosuke, and In Song Kim. 2019. “When Should We Use Unit Fixed Effects Regression Models for Causal Inference with Longitudinal Data?” *American Journal of Political Science* 63(2): 467–490. DOI: `10.1111/ajps.12417`.
- Imai, Kosuke, and In Song Kim. 2021. “On the Use of Two-Way Fixed Effects Regression Models for Causal Inference with Panel Data.” *Political Analysis* 29(3): 405–415. DOI: `10.1017/pan.2020.33`.
