# Revisao de Literatura: Time-Varying Covariates, Bad Controls e Post-Treatment Bias em DiD/TSCS/SCM/ADL

**Data**: 2026-03-22
**Periodo coberto**: 2015-2026
**Escopo**: Vies de pos-tratamento, collider bias e covariaveis time-varying em modelos de painel (DiD, TWFE, TSCS, SCM, ADL/LDV)

---

## 1. Visao geral do campo

O problema de condicionar em variaveis pos-tratamento (ou "bad controls") e reconhecido ha decadas na literatura de inferencia causal, mas ganhou atencao renovada a partir de ~2018 no contexto especifico de modelos de painel. Tres correntes convergiram: (i) a "revolucao DiD" (2019-2024) revelou que TWFE com timing escalonado e efeitos heterogeneos produz estimativas com pesos negativos, e que covariaveis time-varying agravam o problema; (ii) a literatura de TSCS em ciencia politica (Blackwell & Glynn 2018, Imai & Kim 2019) formalizou quando modelos com LDV/FE identificam efeitos causais e quando falham por condicionar em pos-tratamento; (iii) a literatura de DAGs e controles (Cinelli, Forney & Pearl 2022) sistematizou graficamente por que certos controles introduzem vies por collider/mediador.

O estado atual e de intensa atividade metodologica, com novos estimadores robustos (doubly robust DiD, imputation estimators, intersection DiD) e uma consciencia crescente de que controles time-varying em TWFE nao sao inofensivos.

---

## 2. Trabalhos seminais

| Autor(es) | Ano | Journal | Argumento central | Metodo |
|---|---|---|---|---|
| Robins, Hernan & Brumback | 2000 | Epidemiology | Abordagens padrao sao viesadas quando ha confounders time-varying afetados por tratamento anterior; propoem marginal structural models (MSM) com IPW | IPW, MSM |
| Angrist & Pischke | 2009 | Livro (MHE) | Definem "bad controls" como variaveis que sao elas proprias outcomes; controles pre-tratamento sao seguros, pos-tratamento podem viesar | Conceitual |
| Acharya, Blackwell & Sen | 2016 | APSR | Controlar por mediadores pos-tratamento viesa estimativas de efeito total; propoem controlled direct effect via sequential g-estimation | Sequential g-estimation |
| Bellemare, Masaki & Pepinsky | 2017 | JoP | Usar variaveis explicativas defasadas para resolver endogeneidade apenas substitui "selection on observables" por "no dynamics among unobservables" | DAGs + MC |
| Blackwell & Glynn | 2018 | APSR | Modelos padrao para TSCS (incluindo ADL) podem produzir estimativas viesadas por condicionar em pos-tratamento; propoem IPW e structural nested mean models | IPW, SNMM |
| Montgomery, Nyhan & Torres | 2018 | AJPS | Pesquisadores frequentemente distorcem efeitos de tratamento ao condicionar em variaveis pos-tratamento em estudos experimentais; documentam a pratica generalizada | Reanalises empiricas |
| Imai & Kim | 2019 | AJPS | FE unitarios so identificam efeitos causais sob strict exogeneity (sem dinamica causal); quando ha dinamica, TWFE basico e nao-identificado; propoem matching nao-parametrico | DAGs, matching, wfe |
| Ding & Li | 2019 | Political Analysis | DiD e LDV adjustment tem relacao de "bracketing": se um esta correto, o outro viesa na direcao oposta | Nao-parametrico |

---

## 3. Debates centrais

### Debate 1: TWFE com efeitos heterogeneos e timing escalonado

**Contexto**: A partir de 2019-2021, uma serie de papers mostrou que o estimador TWFE padrao e uma media ponderada de efeitos 2x2, com pesos potencialmente negativos quando ha heterogeneidade temporal.

**Contribuicoes-chave**:
- **Goodman-Bacon (2021, JoE)**: Decomposicao do estimador TWFE em DDs 2x2; pesos proporcionais ao tamanho dos grupos e variancia do tratamento; pesos negativos quando tratados anteriormente servem de controle. Ferramenta: `ddtiming` (Stata).
- **De Chaisemartin & D'Haultfoeuille (2020, AER; 2023, EJ)**: Mostram que TWFE estima soma ponderada de ATTs com pesos negativos; estendem para multiplos tratamentos. Theorem S4 do apendice web trata de covariaveis time-varying em TWFE.
- **Sun & Abraham (2021, JoE)**: Coeficientes de event-study em TWFE sao contaminados por efeitos de outros periodos; propoem estimador interaction-weighted. Ferramenta: `eventstudyweights` (Stata).
- **Callaway & Sant'Anna (2021, JoE)**: Framework para DiD com multiplos periodos e timing escalonado; permitem parallel trends condicional em covariaveis; estimadores DR, IPW, e outcome regression. Pacote R: `did`.
- **Borusyak, Jaravel & Spiess (2024, ReStud)**: Estimador de imputacao eficiente para event studies com tratamento escalonado e efeitos heterogeneos; funciona com controles time-varying.
- **Athey & Imbens (2022, JoE)**: Perspectiva de design para DiD com adocao escalonada; discutem papel de covariaveis pre-tratamento.
- **Wooldridge (2021/2025, Empirical Economics)**: Equivalencia entre TWFE e regressao Two-Way Mundlak; extensao natural para heterogeneidade via interacoes com covariaveis; adaptavel a modelos nao-lineares.

**Estado atual**: Consenso de que TWFE padrao e inadequado com efeitos heterogeneos. Multiplos estimadores robustos disponiveis. A questao de covariaveis time-varying dentro desses novos frameworks e a fronteira ativa.

### Debate 2: Covariaveis time-varying em DiD — quando se tornam "bad controls"

**Contexto**: Mesmo nos novos estimadores robustos, incluir covariaveis time-varying pode introduzir vies se essas covariaveis sao afetadas pelo tratamento.

**Contribuicoes-chave**:
- **Caetano, Callaway, Payne & Sant'Anna Rodrigues (2022/2024, arXiv 2202.02903)**: Paper central. Mostram que TWFE com covariaveis time-varying nao e robusto quando: (a) covariaveis sao afetadas pelo tratamento, (b) efeitos do tratamento dependem do nivel das covariaveis, (c) efeitos das covariaveis variam no tempo. Propoem estimadores DR e regressao adjustment. Pacotes R: `pte`, `twfeweights`. Paper dividido em dois companions: um sobre covariaveis time-varying na parallel trends assumption (arXiv 2406.15288) e outro sobre "bad controls" em DiD.
- **Caetano & Callaway (2024, arXiv 2406.15288)**: "Difference-in-Differences when Parallel Trends Holds Conditional on Covariates" — tratam o caso em que parallel trends so vale apos condicionar, mas as covariaveis podem mudar ao longo do tempo.
- **Karim & Webb (2024, arXiv 2412.14447)**: "Good Controls Gone Bad" — introduzem a two-way common causal covariates (CCC) assumption; mostram que TWFE e CS-DID sao viesados quando CCC e violada; propoem Intersection DID (DID-INT) baseado em parallel trends dos residuos apos ajuste por covariaveis.
- **Nick Huntington-Klein (2023, blog)**: "Controls in Difference-in-Differences Don't Just Work" — explica pedagogicamente por que bad controls sao mais comuns em DiD do que em cross-section.

**Estado atual**: Area em rapida evolucao. Os papers de Caetano et al. e Karim & Webb estao entre os mais recentes e ainda em working paper. A mensagem central e que covariaveis time-varying em DiD requerem cuidado especial — nao basta "jogar no modelo".

### Debate 3: LDV vs. FE vs. ADL em modelos dinamicos de painel

**Contexto**: Debate classico em TSCS sobre quando usar FE, LDV, ou ambos (ADL), e quais as implicacoes causais.

**Contribuicoes-chave**:
- **Blackwell & Glynn (2018, APSR)**: Formalizam que ADL padrao (Y ~ D + D_lag + Y_lag + Z | FE) pode viesar o contemporaneous effect (CET) por condicionar em pos-tratamento (Y_lag e collider de D_{t-1} e Z_{t-1}); propoem IPW e SNMM como alternativas. Mostram que beta_1 (efeito de D_{t-1}) e consistente no ADL (p. 1073).
- **Imai & Kim (2019, AJPS)**: TWFE basico exige strict exogeneity — past treatments nao afetam current outcome E past outcomes nao afetam current treatment. Quando ha dinamica causal, FE unitario e inconsistente. Propoem matching via wfe.
- **Ding & Li (2019, Political Analysis)**: Relacao de bracketing — DiD e LDV adjustment fornecem limites opostos do efeito verdadeiro sob premissas alternativas.
- **Kropko & Kubinec (2020, PLoS ONE)**: TWFE combina variacao within-unit e cross-sectional de forma nao-interpretavel; modelo nao e identificado sob a interpretacao usual.
- **Klosin (2024, WP/arXiv)**: Identifica "dynamic bias" em FE estaticos quando ha feedback (Y_{t-1} -> Y_t) e a equacao de estimacao omite Y_lag; vies pode ser maior que Nickell bias. Propoe correcao de vies para T fixo.

**Estado atual**: A tensao entre FE (que controla para time-invariant confounders mas exige strict exogeneity) e LDV/ADL (que permite dinamica mas condiciona em pos-tratamento) persiste. Blackwell & Glynn (2018) mostraram que ADL completo produz beta_1 consistente; simulacoes recentes (projeto IVB) confirmam vies < 3% em todos os cenarios testados. O ADL completo com FE parece ser robusto quando todos os lags relevantes sao incluidos, mas a questao de covariaveis time-varying adicionais permanece.

### Debate 4: Controles bons e ruins — a perspectiva de DAGs

**Contribuicoes-chave**:
- **Cinelli, Forney & Pearl (2022/2024, Sociological Methods & Research)**: "A Crash Course in Good and Bad Controls" — sistematizam via DAGs 18 configuracoes de controles; mostram que colliders, descendentes de mediadores, e M-bias podem todos introduzir vies. Referencia essencial para qualquer discussao sobre "included variable bias".
- **Diegert, Masten & Poirier (2022, arXiv)**: "Assessing Omitted Variable Bias when the Controls are Endogenous" — sensitivity analysis quando controles sao eles proprios endogenos; bounds sobre parametros de interesse. Pacote: `regsensitivity` (Stata/R).

### Debate 5: SCM e covariaveis

**Contribuicoes-chave**:
- **Abadie (2021, JEL)**: Aviso sobre overfitting em SCM com poucos periodos pre-tratamento; covariaveis podem ser redundantes quando todos os lags do outcome sao usados como preditores.
- **Arkhangelsky, Athey, Hirshberg, Imbens & Wager (2021, AER)**: Synthetic DiD — combina DiD e SCM; permite covariaveis time-varying, mas nao aborda diretamente o problema de bad controls.

---

## 4. Evolucao metodologica

**Pre-2015**: A literatura era dominada por TWFE padrao e modelos ADL/Arellano-Bond em economia, e por FE/LDV em ciencia politica. O conceito de "bad controls" existia (Angrist & Pischke 2009) mas era pouco formalizado para painel.

**2016-2018**: Papers seminais em CP formalizaram o problema. Acharya, Blackwell & Sen (2016) introduziram o controlled direct effect para mediadores. Blackwell & Glynn (2018) e Montgomery, Nyhan & Torres (2018) mostraram que condicionar em pos-tratamento e generalizado e problematico em TSCS e experimentos.

**2019-2021**: A "revolucao DiD" explodiu. Goodman-Bacon (2021), de Chaisemartin & D'Haultfoeuille (2020), Sun & Abraham (2021), Callaway & Sant'Anna (2021) mostraram que TWFE padrao falha com heterogeneidade. Imai & Kim (2019) formalizaram as premissas de identificacao de FE.

**2022-2024**: Foco migrou para covariaveis. Caetano et al. (2022/2024) mostraram que covariaveis time-varying em DiD sao problematicas mesmo nos novos estimadores. Karim & Webb (2024) propoem DID-INT. Klosin (2024) identifica dynamic bias em FE estaticos. Borusyak et al. (2024) publicam o estimador de imputacao.

**2025-2026**: Consolidacao. Papers de survey (Roth et al. 2023, JoE) sintetizam a literatura. Novos practitioners' guides aparecem (e.g., arXiv 2503.13323). O campo esta convergindo para um "toolkit" de estimadores robustos, mas a questao de *quais* covariaveis incluir (e como) permanece incompletamente resolvida.

---

## 5. Gaps identificados

### Gaps teoricos

1. **Collider bias em modelos dinamicos de painel com covariaveis time-varying**: A formula IVB (included variable bias) quantifica o vies de incluir um collider em TWFE, mas a extensao para ADL com multiplos lags e covariaveis nao esta completamente formalizada. A conexao entre a identidade FWL (IVB = -theta* x pi) e os resultados de d-separation para ADL completo e um territorio pouco explorado.

2. **Condicoes necessarias e suficientes para que covariaveis time-varying sejam "safe" em ADL+FE**: Blackwell & Glynn (2018) mostraram que beta_1 e consistente no ADL, e simulacoes sugerem que ADL completo com FE tem vies < 3%. Mas nao ha um resultado formal geral sobre quando covariaveis adicionais Z podem ser incluidas sem introduzir collider bias.

3. **Ponte entre a literatura de DiD/TWFE e a de ADL/TSCS**: Os papers de Caetano et al. tratam covariaveis em DiD, e Blackwell & Glynn tratam pos-tratamento em TSCS, mas a conexao formal entre os dois frameworks (e.g., quando o ADL e equivalente a um DiD com covariaveis) e sub-explorada.

### Gaps empiricos

4. **Prevalencia de IVB na pratica**: Quantos estudos publicados em top journals sofrem de included variable bias por controlar em covariaveis time-varying em TWFE? Nao ha survey sistematico.

5. **Comparacao empirica dos novos estimadores**: CS-DID, DID-INT, imputacao (Borusyak et al.), Wooldridge's extended TWFE — como se comparam em aplicacoes empiricas reais com covariaveis potencialmente pos-tratamento?

### Gaps metodologicos

6. **Diagnosticos para collider bias em painel**: Os testes existentes (e.g., pre-trends, bacon decomposition) nao foram desenhados para detectar collider bias de covariaveis time-varying. Um diagnostico especifico seria valioso.

7. **Sensitivity analysis para bad controls em DiD/TSCS**: Diegert, Masten & Poirier (2022) tratam OVB com controles endogenos em cross-section. A extensao para painel com time-varying bad controls e uma lacuna.

8. **ADL completo como solucao "universal"**: Simulacoes sugerem que ADL+FE com todos os lags relevantes e robusto (vies < 3%), mas falta um resultado formal (alem de BG 2018 Prop. 1) que explique *por que* — o argumento de d-separation ("firewall") precisa de formalizacao rigorosa.

---

## 6. Sugestoes para pesquisa futura

1. **Formalizar o "firewall" do ADL completo**: Demonstrar via d-separation que condicionar em {Y_t, Z_t} bloqueia todos os backdoor paths para Y_{t+1}, independente de forma funcional — transformando o resultado de simulacao em teorema.

2. **Desenvolver um diagnostico de IVB para TWFE**: Uma ferramenta pratica (tipo bacon decomposition) que quantifique o vies potencial de covariaveis time-varying em especificacoes TWFE publicadas.

3. **Survey de prevalencia**: Quantificar o IVB em estudos publicados nos top journals de CP (APSR, AJPS, JoP) e economia (AER, QJE, ReStud) que usam TWFE com controles time-varying.

4. **Conectar formalmente DiD com covariaveis (Caetano et al.) e ADL/TSCS (Blackwell & Glynn)**: Mostrar as condicoes sob as quais os dois frameworks produzem estimativas equivalentes ou divergentes.

5. **Sensitivity analysis para included variable bias em painel**: Estender Diegert et al. (2022) para o caso de controles time-varying em TWFE/ADL, com bounds parcialmente identificados.

---

## 7. Referencias-chave

Abadie, Alberto. 2021. "Using Synthetic Controls: Feasibility, Data Requirements, and Methodological Aspects." *Journal of Economic Literature* 59(2): 391-425.

Acharya, Avidit, Matthew Blackwell, and Maya Sen. 2016. "Explaining Causal Findings Without Bias: Detecting and Assessing Direct Effects." *American Political Science Review* 110(3): 512-529.

Angrist, Joshua D., and Jorn-Steffen Pischke. 2009. *Mostly Harmless Econometrics*. Princeton University Press.

Arkhangelsky, Dmitry, Susan Athey, David A. Hirshberg, Guido W. Imbens, and Stefan Wager. 2021. "Synthetic Difference-in-Differences." *American Economic Review* 111(12): 4088-4118.

Athey, Susan, and Guido W. Imbens. 2022. "Design-based Analysis in Difference-In-Differences Settings with Staggered Adoption." *Journal of Econometrics* 226(1): 62-79.

Bellemare, Marc F., Takaaki Masaki, and Thomas B. Pepinsky. 2017. "Lagged Explanatory Variables and the Estimation of Causal Effect." *Journal of Politics* 79(3): 949-963.

Blackwell, Matthew, and Adam N. Glynn. 2018. "How to Make Causal Inferences with Time-Series Cross-Sectional Data under Selection on Observables." *American Political Science Review* 112(4): 1067-1082.

Borusyak, Kirill, Xavier Jaravel, and Jann Spiess. 2024. "Revisiting Event-Study Designs: Robust and Efficient Estimation." *Review of Economic Studies* 91(6): 3253-3285.

Caetano, Carolina, Brantly Callaway, Stroud Payne, and Hugo Sant'Anna Rodrigues. 2022/2024. "Difference in Differences with Time-Varying Covariates." arXiv:2202.02903.

Caetano, Carolina, and Brantly Callaway. 2024. "Difference-in-Differences when Parallel Trends Holds Conditional on Covariates." arXiv:2406.15288.

Callaway, Brantly, and Pedro H.C. Sant'Anna. 2021. "Difference-in-Differences with Multiple Time Periods." *Journal of Econometrics* 225(2): 200-230.

Cinelli, Carlos, Andrew Forney, and Judea Pearl. 2022. "A Crash Course in Good and Bad Controls." *Sociological Methods & Research* (publicado online 2022, print 2024).

De Chaisemartin, Clement, and Xavier D'Haultfoeuille. 2020. "Two-Way Fixed Effects Estimators with Heterogeneous Treatment Effects." *American Economic Review* 110(9): 2964-2996.

De Chaisemartin, Clement, and Xavier D'Haultfoeuille. 2023. "Two-Way Fixed Effects and Differences-in-Differences with Heterogeneous Treatment Effects: A Survey." *Econometrics Journal* 26(3): C1-C30.

Diegert, Paul, Matthew Masten, and Alexandre Poirier. 2022. "Assessing Omitted Variable Bias when the Controls are Endogenous." arXiv:2206.02303.

Ding, Peng, and Fan Li. 2019. "A Bracketing Relationship between Difference-in-Differences and Lagged-Dependent-Variable Adjustment." *Political Analysis* 27(4): 605-615.

Freyaldenhoven, Simon, Christian Hansen, and Jesse M. Shapiro. 2019. "Pre-event Trends in the Panel Event-Study Design." *American Economic Review* 109(9): 3307-3338.

Goodman-Bacon, Andrew. 2021. "Difference-in-Differences with Variation in Treatment Timing." *Journal of Econometrics* 225(2): 254-277.

Imai, Kosuke, and In Song Kim. 2019. "When Should We Use Unit Fixed Effects Regression Models for Causal Inference with Longitudinal Data?" *American Journal of Political Science* 63(2): 467-490.

Karim, Sunny, and Matthew Webb. 2024. "Good Controls Gone Bad: Difference-in-Differences with Covariates." arXiv:2412.14447.

Klosin, Sylvia. 2024. "Dynamic Biases of Static Panel Data Estimators." arXiv:2410.16112.

Kropko, Jonathan, and Robert Kubinec. 2020. "Interpretation and Identification of Within-Unit and Cross-Sectional Variation in Panel Data Models." *PLoS ONE* 15(4): e0231349.

Montgomery, Jacob M., Brendan Nyhan, and Michelle Torres. 2018. "How Conditioning on Posttreatment Variables Can Ruin Your Experiment and What to Do about It." *American Journal of Political Science* 62(3): 760-775.

Robins, James M., Miguel Angel Hernan, and Babette Brumback. 2000. "Marginal Structural Models and Causal Inference in Epidemiology." *Epidemiology* 11(5): 550-560.

Roth, Jonathan, Pedro H.C. Sant'Anna, Alyssa Bilinski, and John Poe. 2023. "What's Trending in Difference-in-Differences? A Synthesis of the Recent Econometrics Literature." *Journal of Econometrics* 235(2): 2218-2244.

Sun, Liyang, and Sarah Abraham. 2021. "Estimating Dynamic Treatment Effects in Event Studies with Heterogeneous Treatment Effects." *Journal of Econometrics* 225(2): 175-199.

Wooldridge, Jeffrey M. 2021/2025. "Two-Way Fixed Effects, the Two-Way Mundlak Regression, and Difference-in-Differences Estimators." *Empirical Economics* (publicado online 2025).
