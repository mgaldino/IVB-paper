# Revisão de Literatura: Democracia como Causa de Crescimento Econômico e Democracia Regional

**Objetivo:** Avaliar a evidência causal de que democracia (Y no modelo de Claassen 2020) causa GDP growth e democracia regional — as duas variáveis controle com maior IVB potencial. Se Y → Z, incluir Z como controle gera collider bias (Included Variable Bias).

---

## Parte 1: Democracia → Crescimento Econômico (GDP growth)

### 1.1 Visão geral do campo

A relação entre democracia e crescimento econômico é uma das questões mais debatidas em economia política comparada. Durante décadas, o consenso era ambíguo: Barro (1996) encontrava efeito fraco e não-linear; Przeworski et al. (2000) argumentavam que democracia não afeta crescimento; e Tavares & Wacziarg (2001) questionavam a relevância empírica. O campo mudou substancialmente com Acemoglu et al. (2019, JPE), que usaram métodos de painel dinâmico mais sofisticados e concluíram que "democracy does cause growth". Ainda assim, a heterogeneidade dos efeitos e a robustez a diferentes especificações permanecem em debate.

### 1.2 Trabalhos seminais

| Autor(es) | Ano | Journal | Argumento | Método | Achado |
|-----------|-----|---------|-----------|--------|--------|
| Barro | 1996 | NBER/QJE | Efeito fraco e não-linear da democracia sobre crescimento | Panel OLS cross-country, 100 países 1960-90 | Democracia tem efeito fraco; relação não-linear (positiva em baixos níveis, negativa em altos) |
| Przeworski et al. | 2000 | Livro (Cambridge) | Democracia não causa crescimento; crescimento sustenta democracia | Panel, transições de regime | Sem efeito causal de democracia → crescimento; crescimento previne colapso democrático |
| Tavares & Wacziarg | 2001 | EER | Democracia tem canais positivos (educação) e negativos (redistribuição) que se cancelam | Cross-country 2SLS | Efeito líquido próximo de zero |
| Papaioannou & Siourounis | 2008 | EJ | Democratização causa ~1pp/ano de crescimento adicional | Before-after event study, within-country FE | +1% crescimento anual pós-democratização, com efeito crescente no médio prazo |
| **Acemoglu, Naidu, Restrepo & Robinson** | **2019** | **JPE** | **Democracia causa crescimento de ~20% no PIB per capita em 25 anos** | **ADL(4,1), dynamic panel FE, system GMM, IV (ondas regionais), propensity score matching** | **Efeito robusto: ~20% PIB per capita em 25 anos; canais via investimento, escolarização, reformas econômicas, redução de conflito** |
| Doucouliagos & Ulubasoglu | 2008 | AJPS | Meta-análise: sem efeito direto, mas efeitos indiretos robustos | Meta-regressão de 483 estimativas em 84 estudos | Efeito direto zero; efeitos indiretos via capital humano, inflação, liberdade econômica |
| Cervellati & Sunde | 2014 | AER (Comment) | Efeitos heterogêneos: positivos para não-colônias, negativos para colônias | Replicação com efeitos heterogêneos | Heterogeneidade substancial por história colonial |
| Madsen, Raschky & Skali | 2015 | EER | Democracia causa crescimento (horizonte 1500-2000) | IV usando distância linguística × democracia estrangeira | +44-98% renda per capita para 1 DP de democracia |
| Boese-Schlosser & Eberhardt | 2023 | WP (WZB/NICEP) | Efeitos heterogêneos; liberdade de expressão e eleições limpas são os drivers | DiD com interactive FE, heterogeneous treatment effects | Liberdade de expressão, eleições limpas e restrições ao executivo são os drivers centrais |

### 1.3 Consenso atual

**Há forte evidência de que democracia causa crescimento econômico**, especialmente após Acemoglu et al. (2019):

- O efeito de longo prazo é substancial (~20% PIB per capita em 25 anos)
- Os canais incluem mais investimento em educação e saúde, reformas econômicas, e redução de conflito social
- O efeito é heterogêneo: mais forte para transições pacíficas, mais forte em não-colônias
- A relação reversa (crescimento → democracia) é mais fraca: crises econômicas podem desestabilizar autocracias, mas crescimento não necessariamente causa democratização

### 1.4 Implicações para o IVB

**GDP growth como collider:** Se democracia (d_{it}) causa crescimento econômico (z_{it} = GDP growth), e se apoio público (s_{it}) também afeta crescimento (via legitimidade, estabilidade), então GDP growth é um collider no caminho d ← s → d com d → z ← s. Incluir GDP growth como controle abre um caminho não-causal e gera IVB.

A evidência de Acemoglu et al. (2019) é particularmente relevante porque usa exatamente a mesma estrutura ADL e o mesmo tipo de dados (painel cross-nacional, country-year). O fato de que democracia causa crescimento é agora o consenso dominante na literatura, o que fortalece o argumento de que GDP growth é um collider potencial.

**Magnitude relevante:** No nosso cálculo de IVB para o pooled OLS de Claassen, o GDP growth produziu um IVB de -0.001 (pequeno). No FE, o IVB foi +0.012. A magnitude pequena no OLS se explica porque θ (efeito de GDP growth sobre democracia condicional ao resto) é pequeno (0.007), mesmo que π (efeito de support sobre GDP growth) seja razoável (0.14).

---

## Parte 2: Democracia → Democracia Regional (Diffusion)

### 2.1 Visão geral do campo

A literatura sobre difusão democrática investiga se mudanças no nível de democracia de um país "contagiam" países vizinhos ou da mesma região. A ideia remonta a Huntington (1991) e suas "ondas de democratização". Desde então, uma literatura substancial demonstrou que a democracia regional é um preditor robusto de democratização doméstica — mas a questão causal (difusão genuína vs. exposição a choques comuns) permanece parcialmente em aberto.

### 2.2 Trabalhos seminais

| Autor(es) | Ano | Journal | Argumento | Método | Achado |
|-----------|-----|---------|-----------|--------|--------|
| Huntington | 1991 | Livro | Democratização ocorre em "ondas" globais, com efeito snowball | Análise histórica qualitativa | Três ondas de democratização com clustering geográfico |
| Gleditsch & Ward | 2006 | IO | Contexto internacional e vizinhança democrática importam para democratização | Panel data (Markov transition model), 1951-98 | Vizinhança democrática aumenta probabilidade de transição; vizinhança autocrática aumenta probabilidade de reversão |
| Brinks & Coppedge | 2006 | CPS | Países convergem para o nível de democracia dos vizinhos contíguos | Panel 1972-96, modelo de difusão espacial | Convergência robusta em direção à média regional; efeito EUA significativo |
| Leeson & Dean | 2009 | AJPS | "Dominós democráticos" caem, mas de forma modesta | Spatial econometrics, panel 1850-2000 | Países capturam ~11% das mudanças democráticas dos vizinhos; efeito existe mas é modesto |
| Teorell | 2010 | Livro (Cambridge) | Vizinhos democráticos e organizações regionais democráticas promovem democratização | Panel 165 países 1972-2006, ADL com controles | Difusão regional positiva; organizações regionais democráticas importam |
| Elkink | 2011 | CPS | Difusão via opinião pública e cascatas revolucionárias | Agent-based model + análise empírica | Difusão de atitudes combinada com cascading revolutions explica clustering espacial |
| Gassebner, Gutmann & Voigt | 2016 | EJPE | Democracia se difunde via redes de alianças defensivas | Panel com redes internacionais | Efeitos diretos via rede de alianças; efeitos de vizinhos-de-vizinhos presentes |
| Boese-Schlosser et al. | 2023 | PNAS | Ancestralidade cultural compartilhada prediz difusão democrática | Panel global, distância linguística e religiosa | Efeitos culturais tão importantes quanto geográficos |

### 2.3 Consenso atual

**Há evidência robusta de que democracia em um país afeta os níveis de democracia na região**, embora com nuances:

- O efeito de difusão existe, mas é **modesto** (~11% segundo Leeson & Dean 2009)
- A difusão opera via múltiplos canais: contiguidade geográfica, redes de alianças, organizações regionais, vínculos culturais
- Há debate sobre se o efeito é **difusão genuína** (causal: d_i → d_j) ou **exposição a choques comuns** (confounding: choque global → d_i e d_j simultaneamente)
- A identificação causal é difícil: a maioria dos estudos usa Granger causality ou spatial lags, não IV limpo
- No entanto, evidências de IV (usando ondas regionais como instrumento em Acemoglu et al. 2019) e redes (Gassebner et al. 2016) são consistentes com difusão causal

### 2.4 Implicações para o IVB

**Democracia regional como collider:** No modelo de Claassen, `Libdem_regUN_m1` é a média da democracia liberal na região (sub-região da ONU). Se a democracia de um país i contribui para a média regional (mecanicamente: i faz parte da média), e se apoio público em i afeta a democracia regional via difusão de valores, então a democracia regional é um collider.

Na verdade, aqui há dois efeitos:
1. **Mecânico:** d_i faz parte da média regional → d_i → z_i (regional avg) por construção
2. **Difusão:** d_i influencia d_j dos vizinhos, que por sua vez entram na média regional

O efeito mecânico torna a situação de collider quase certa: incluir a média regional como controle necessariamente introduz dependência entre d_i e z_i que não passa pelo canal causal de interesse.

**Magnitude relevante:** No cálculo de IVB para o pooled OLS de Claassen, `Libdem_regUN_m1` produziu o **maior IVB** entre os controles: -0.009 (θ = 0.008, π = 1.10). Isso significa que incluir democracia regional como controle reduz o coeficiente de support de 0.282 para 0.273 — uma redução de ~3%. O π alto (1.10) reflete a forte associação entre support e democracia regional na regressão auxiliar.

---

## 3. Síntese: Evidência para Collider Bias no Claassen (2020)

| Controle | Y → Z documentado? | Mecanismo | Magnitude IVB (OLS) | Magnitude IVB (FE) |
|----------|-------------------|-----------|--------------------|--------------------|
| GDP growth | **Sim** (forte, Acemoglu et al. 2019) | Democracia promove crescimento via investimento, educação, reformas | -0.001 (pequeno) | +0.012 |
| Democracia regional | **Sim** (moderado + mecânico) | Difusão democrática + composição mecânica da média | **-0.009** (maior IVB no OLS) | -0.002 |
| Log GDP per capita | **Sim** (forte, mesmo mecanismo) | Democracia causa acumulação de renda | -0.001 | **-0.016** (maior IVB no FE) |
| Resource dependence | Fraco/reverso | "Resource curse" afeta democracia, não o inverso | +0.008 | ~0 |
| % Muslim | Não (time-invariant) | Relação histórica, não causal contemporânea | +0.001 | (absorvido por FE) |

### Conclusão para o paper do IVB

A revisão da literatura fornece **evidência sólida** de que pelo menos dois dos cinco controles no Claassen (2020) são candidatos a collider:

1. **GDP growth / Log GDP per capita**: A literatura pós-Acemoglu et al. (2019) estabelece que democracia causa crescimento. Incluir GDP como controle pode gerar IVB.

2. **Democracia regional**: A literatura de difusão democrática (Gleditsch & Ward 2006; Brinks & Coppedge 2006; Leeson & Dean 2009) mostra que democracia se difunde regionalmente. Além disso, há um efeito mecânico (d_i compõe a média regional). Este é o controle com maior IVB no pooled OLS.

Esses achados ilustram exatamente o ponto central do paper do IVB: **controles que parecem razoáveis do ponto de vista de confounding podem ser colliders, e a direção e magnitude do viés são quantificáveis pela fórmula IVB = -θ*π.**

---

## Referências-chave

- Acemoglu, D., Naidu, S., Restrepo, P., & Robinson, J. A. (2019). Democracy Does Cause Growth. *Journal of Political Economy*, 127(1), 47-100.
- Barro, R. J. (1996). Determinants of Economic Growth: A Cross-Country Empirical Study. *NBER Working Paper* 5698.
- Boese-Schlosser, V. & Eberhardt, M. (2023). How Does Democracy Cause Growth? *WZB Discussion Paper* V 23-501.
- Brinks, D. & Coppedge, M. (2006). Diffusion Is No Illusion: Neighbor Emulation in the Third Wave of Democracy. *Comparative Political Studies*, 39(4), 463-489.
- Cervellati, M., Jung, F., Sunde, U., & Vischer, T. (2014). Income and Democracy: Comment. *American Economic Review*, 104(2), 707-719.
- Doucouliagos, H. & Ulubasoglu, M. A. (2008). Democracy and Economic Growth: A Meta-Analysis. *American Journal of Political Science*, 52(1), 61-83.
- Elkink, J. A. (2011). The International Diffusion of Democracy. *Comparative Political Studies*, 44(12), 1651-1674.
- Gassebner, M., Gutmann, J., & Voigt, S. (2016). The Contagion of Democracy Through International Networks. *Social Choice and Welfare*.
- Gleditsch, K. S. & Ward, M. D. (2006). Diffusion and the International Context of Democratization. *International Organization*, 60(4), 911-933.
- Huntington, S. P. (1991). *The Third Wave: Democratization in the Late Twentieth Century*. University of Oklahoma Press.
- Leeson, P. T. & Dean, A. M. (2009). The Democratic Domino Theory: An Empirical Investigation. *American Journal of Political Science*, 53(3), 533-551.
- Madsen, J. B., Raschky, P. A., & Skali, A. (2015). Does Democracy Drive Income in the World, 1500-2000? *European Economic Review*, 78, 175-195.
- Papaioannou, E. & Siourounis, G. (2008). Democratisation and Growth. *The Economic Journal*, 118(532), 1520-1551.
- Przeworski, A., Alvarez, M. E., Cheibub, J. A., & Limongi, F. (2000). *Democracy and Development*. Cambridge University Press.
- Tavares, J. & Wacziarg, R. (2001). How Democracy Affects Growth. *European Economic Review*, 45(8), 1341-1378.
- Teorell, J. (2010). *Determinants of Democratization: Explaining Regime Change in the World, 1972-2006*. Cambridge University Press.
