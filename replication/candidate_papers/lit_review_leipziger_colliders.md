# Revisão de Literatura: Controles como Candidatos a Collider em Leipziger (2024, AJPS)

**Objetivo:** Avaliar a evidência causal de que a desigualdade étnica (Y no modelo de Leipziger) causa cada variável controle (Z). Se Y → Z, incluir Z como controle gera collider bias (Included Variable Bias).

**Modelo de Leipziger:** `Ethnic_Inequality_{i,t} = β Democracy(0,1)_{i,t-1} + θ GDP_pc_{i,t-1} + δ_i + γ_t + ε_{i,t}`

---

## Parte 1: Desigualdade Étnica → PIB per capita / Crescimento Econômico

### 1.1 Visão geral do campo

A relação entre desigualdade (especialmente desigualdade horizontal/étnica) e crescimento econômico é uma das questões centrais em economia do desenvolvimento. A literatura evoluiu de um foco em desigualdade individual (Gini de renda) para reconhecer que desigualdade entre grupos étnicos tem efeitos distintos e potencialmente mais nocivos sobre o crescimento. O consenso emergente é que desigualdade étnica reduz crescimento, mas os mecanismos são indiretos — via conflito, redução de bens públicos, e subinvestimento em capital humano de grupos excluídos.

### 1.2 Trabalhos seminais

| Autor(es) | Ano | Journal | Argumento | Método | Achado |
|-----------|-----|---------|-----------|--------|--------|
| Easterly & Levine | 1997 | QJE | Diversidade étnica explica políticas ruins e baixo crescimento na África | Cross-country OLS, 1960-89 | Fragmentação étnica explica grande parte da divergência africana; canais via políticas, instabilidade, baixa escolaridade |
| Alesina et al. | 2003 | JEG | Fragmentação étnica reduz crescimento via menor provisão de bens públicos | Cross-country panel | Efeito negativo confirmado com dados atualizados; fragmentação religiosa e linguística também relevante |
| Alesina, Michalopoulos & Papaioannou | 2016 | JPE | Desigualdade *entre* grupos étnicos (não apenas diversidade) é negativamente correlacionada com desenvolvimento | Cross-section, nightlight data por homelands étnicos | Forte associação negativa entre ethnic inequality (Gini de luminosidade entre grupos) e desenvolvimento contemporâneo |
| **Gründler & Link** | **2024** | **CESifo WP 11034** | **Desigualdade étnica causa redução do crescimento econômico** | **Panel com dados harmonizados de satélite; IV usando artificialidade de fronteiras sub-nacionais na África** | **Efeito causal: ir de distribuição igualitária a concentração total reduz PIB per capita em 12-15%** |
| Doucouliagos & Ulubasoglu | 2008 | AJPS | Meta-análise: efeitos indiretos da democracia sobre crescimento via capital humano, inflação, liberdade econômica | Meta-regressão de 483 estimativas | Efeito direto ambíguo, mas canais indiretos robustos |

### 1.3 Mecanismos documentados

1. **Conflito e instabilidade social:** Desigualdade étnica gera grievances que podem escalar para violência (Cederman, Gleditsch & Buhaug 2013), desestabilizando economias.
2. **Redução de bens públicos:** Grupos étnicos polarizados concordam menos sobre alocação de bens públicos (Easterly & Levine 1997; Alesina et al. 2003).
3. **Subinvestimento em capital humano:** Grupos excluídos têm menos acesso a educação e saúde, reduzindo produtividade agregada.
4. **Rent-seeking:** Polarização entre grupos leva a comportamento rent-seeking em vez de investimento produtivo.

### 1.4 Consenso atual

**Há evidência moderada a forte de que desigualdade étnica reduz crescimento econômico e PIB per capita**, especialmente após o trabalho de Gründler & Link (2024) que usa IV para identificação causal:

- O efeito é substancial: 12-15% de redução no PIB per capita para níveis extremos de concentração
- Os canais incluem conflito, redução de bens públicos, e subinvestimento em capital humano
- A evidência é mais forte para países em desenvolvimento e contextos africanos
- A relação reversa (crescimento → redução de ethnic inequality) é menos documentada

### 1.5 Implicações para o IVB

**GDP per capita como collider:** Se ethnic inequality (Y) causa redução no GDP per capita (Z), e se democracy (D) também afeta GDP per capita (via Acemoglu et al. 2019), então GDP per capita é um collider: D → Z ← Y. Incluir GDP per capita como controle abre um caminho não-causal.

**Magnitude do IVB:** No nosso cálculo para o Leipziger (2024), GDP per capita produziu o **maior IVB**: +0.006, que corresponde a 16% do efeito estimado. O IVB é positivo, significando que incluir GDP p.c. *atenua* o efeito da democracia sobre ethnic inequality. Sem este controle, o efeito da democracia seria -0.041 em vez de -0.035.

**Direção do viés:** A atenuação faz sentido intuitivamente:
- θ (efeito de GDP p.c. sobre ethnic inequality) = -0.050 (negativo: países mais ricos têm menor desigualdade étnica)
- π (efeito de democracy sobre GDP p.c.) = +0.112 (positivo: democracia aumenta renda)
- IVB = -θ × π = -(-0.050)(0.112) = +0.006 (positivo: atenua o efeito negativo)

---

## Parte 2: Desigualdade Étnica → Guerra Civil

### 2.1 Visão geral do campo

A relação entre desigualdade horizontal (horizontal inequalities, HIs) e conflito civil é uma das áreas mais ativas e bem-documentadas da literatura de conflito. O conceito de HIs foi desenvolvido por Frances Stewart (2002, 2008) e refere-se a desigualdades entre grupos culturalmente definidos (étnicos, religiosos, regionais). A literatura evoluiu de debate "greed vs. grievance" (Collier & Hoeffler 2004 vs. Stewart 2002) para um consenso de que HIs são preditores robustos de conflito civil, especialmente quando combinadas com exclusão política.

### 2.2 Trabalhos seminais

| Autor(es) | Ano | Journal | Argumento | Método | Achado |
|-----------|-----|---------|-----------|--------|--------|
| Stewart | 2002/2008 | Livro (Palgrave) | Desigualdades horizontais entre grupos são causa fundamental de conflito civil | Case studies (Uganda, Sri Lanka, Brasil, Côte d'Ivoire) + theory | HIs em múltiplas dimensões (econômica, social, política) provocam conflito; efeito mais forte quando dimensões se reforçam |
| Østby | 2008 | JCR | HIs econômicas e sociais aumentam probabilidade de conflito | Panel 55 países em desenvolvimento, 1986-2003; DHS data | Relação significativa entre HIs econômicas/sociais e onset de conflito; mais forte quando grupos definidos por etnia |
| **Cederman, Gleditsch & Buhaug** | **2013** | **Livro (Cambridge)** | **Desigualdades entre grupos étnicos geram grievances que motivam guerra civil** | **Panel global, EPR data, grupo como unidade de análise** | **Grupos politicamente excluídos e economicamente desfavorecidos têm risco significativamente maior de conflito; medidas tradicionais (Gini individual) falham porque não capturam dimensão horizontal** |
| Buhaug, Cederman & Gleditsch | 2014 | ISQ | HIs predizem conflito melhor que indicadores tradicionais | Panel global, comparação de modelos | Perfis de HIs (político + econômico) são melhores preditores de onset de civil war que indicadores convencionais |
| **Wucherpfennig et al.** | **2016** | **AJPS** | **Exclusão étnica causa conflito civil (evidência causal via IV)** | **IV usando estratégias coloniais (British vs. French) como instrumento para exclusão política** | **Efeito causal: estudos anteriores *subestimavam* o impacto da inclusão política; identificação limpa via variação exógena colonial** |
| Hillesund | 2023 | JPR / JES | Review: HIs afetam tanto conflito violento quanto mobilização não-violenta | Revisão sistemática da literatura | Consenso: HIs políticas e econômicas associadas a civil war; evidência mais fraca para conflito de nível médio (riots) |
| Radatz | 2025 | ROIW | Desigualdade multidimensional prediz civil war onset em 193 países, 1810-2010 | Panel histórico longo, medidas multidimensionais | Efeito robusto de HI multidimensional sobre onset de civil war; horizonte temporal mais longo confirma padrão |

### 2.3 Consenso atual

**Há forte evidência de que desigualdade étnica (horizontal inequality) causa conflito civil:**

- O efeito é robusto a múltiplas especificações e períodos temporais
- A exclusão política é o canal mais documentado, mas HIs econômicas também importam
- A evidência causal é fortalecida pelo IV de Wucherpfennig et al. (2016) usando variação colonial
- Os mecanismos incluem: grievances coletivas, custos de recrutamento mais baixos, fortalecimento de identidades grupais
- O efeito é mais forte quando HIs em múltiplas dimensões se reforçam (Stewart 2008)

### 2.4 Implicações para o IVB

**Civil war como collider:** Se ethnic inequality (Y) causa civil war (Z), e se democracy (D) também afeta civil war (democracias tendem a ter menos conflito civil, embora transições democráticas possam ser desestabilizadoras), então civil war pode ser um collider.

No entanto, no cálculo de IVB para o Leipziger (Table A11, outcome SEI), civil war produziu um IVB modesto de +0.0002. Isso se deve a:
- θ (efeito de civil war sobre ethnic inequality) = 0.011 (positivo, mas pequeno)
- π (efeito de democracy sobre civil war) = -0.021 (negativo, democracia reduz conflito)
- IVB = -θ × π = -(0.011)(-0.021) = +0.0002

A magnitude pequena se explica porque (a) o efeito de civil war sobre ethnic inequality condicional ao resto é pequeno, e (b) a amostra (com todos os 5 controles) é menor. Mas o *argumento teórico* para collider é forte.

---

## Parte 3: Desigualdade Étnica → Renda de Petróleo per capita

### 3.1 Avaliação

**Provavelmente NÃO é um collider.** Não há canal causal direto plausível de ethnic inequality para oil income per capita:

- Renda petrolífera é determinada por dotação geológica e preços internacionais
- Ethnic inequality não afeta a quantidade de petróleo extraída ou seus preços
- A direção causal provável é reversa: oil → inequality (via "resource curse"), não inequality → oil
- O IVB calculado é essencialmente zero (~-0.00005)

### 3.2 Nota sobre "resource curse"

A literatura sobre resource curse (Ross 2001, 2012) argumenta que oil → autocracia e oil → desigualdade, mas não ethnic inequality → oil. Portanto, oil income não é um collider neste contexto.

---

## Parte 4: Desigualdade Étnica → Fracionamento Étnico

### 4.1 Avaliação

**NÃO é um collider.** Fracionamento étnico é uma variável estrutural/demográfica:

- Mede a probabilidade de dois indivíduos aleatórios pertencerem a grupos étnicos diferentes
- É determinado pela composição demográfica histórica, não pela desigualdade entre grupos
- Muda muito lentamente ao longo do tempo (décadas/séculos)
- Ethnic inequality (diferenças de renda *entre* grupos) não causa mudanças no *número* de grupos ou sua composição demográfica

O IVB calculado foi +0.0007 (negligível).

### 4.2 Distinção conceitual importante

É crucial distinguir:
- **Ethnic fractionalization** (diversidade): quantos grupos existem e quão grandes são → estrutural
- **Ethnic inequality** (desigualdade): quão diferentes são as condições econômicas entre os grupos → pode variar no curto/médio prazo

A confusão entre esses conceitos é um problema documentado na literatura (Posner 2004, AJPS; Alesina et al. 2016, JPE).

---

## Parte 5: Desigualdade Étnica → Crescimento do PIB

### 5.1 Avaliação

**Mesma lógica que Parte 1, com nuances.** Os mecanismos são os mesmos (conflito, bens públicos, capital humano), mas aplicados à *taxa de crescimento* em vez do *nível* do PIB:

- Gründler & Link (2024) mostram efeito sobre crescimento, não apenas nível
- Easterly & Levine (1997) focam especificamente em crescimento
- O canal conflito (Parte 2) opera via crescimento: desigualdade → conflito → destruição → baixo crescimento

No cálculo de IVB, GDP growth produziu IVB essencialmente zero (~-0.00001), por combinar um θ modesto (0.022) com um π muito pequeno (0.0006). Na prática, democracy tem efeito mínimo sobre GDP growth condicional ao resto dos controles.

---

## 3. Síntese: Evidência para Collider Bias no Leipziger (2024)

| Controle | Y → Z documentado? | Mecanismo | Magnitude IVB (Table 1) | Magnitude IVB (Table A11, SEI) |
|----------|-------------------|-----------|-----------------------|-------------------------------|
| **GDP per capita** | **Sim** (moderado-forte, Gründler & Link 2024) | Ethnic ineq. → conflito/bens públicos → reduz PIB | **+0.006 (16% do efeito)** | +0.005 |
| Civil war | **Sim** (forte, Cederman et al. 2013; Wucherpfennig et al. 2016) | Ethnic ineq. → grievances → conflito civil | — | +0.0002 |
| GDP growth | Sim (mesmos canais que GDP p.c.) | Ethnic ineq. → conflito/bens públicos → baixo crescimento | — | ~0 |
| Oil income p.c. | Não | Sem canal causal direto | — | ~0 |
| Ethnic frac. | Não (estrutural) | Composição demográfica, não afetada por inequality | — | +0.0007 |

### Conclusão para o paper do IVB

A revisão da literatura fornece **evidência sólida** de que o principal controle no Leipziger (2024) — GDP per capita — é um candidato plausível a collider:

1. **GDP per capita**: A literatura mostra que ethnic inequality reduz crescimento e PIB per capita (Gründler & Link 2024 com IV; Easterly & Levine 1997; Alesina et al. 2016). Como democracy também causa crescimento (Acemoglu et al. 2019), GDP per capita é um collider. O IVB é substancial: +0.006, atenuando o efeito da democracia em 16%.

2. **Civil war**: A literatura de horizontal inequalities (Stewart 2008; Cederman et al. 2013; Wucherpfennig et al. 2016) documenta fortemente que ethnic inequality causa conflito civil. O argumento teórico para collider é forte, embora a magnitude do IVB no Leipziger seja pequena.

**Nota importante:** Leipziger (2024) deliberadamente exclui controles adicionais do modelo baseline, citando "the risk of posttreatment bias" (p. 1347). Esta decisão é consistente com a preocupação de IVB/collider bias, e nosso cálculo confirma que o controle retido (GDP p.c.) de fato introduz um viés mensurável.

O caso do Leipziger é particularmente interessante para o paper do IVB porque:
- O autor *reconhece* o risco de post-treatment bias nos controles adicionais
- Mas *retém* GDP per capita como controle, que produz o maior IVB
- A fórmula IVB = -θ*π quantifica exatamente o custo dessa escolha
- A direção do viés (atenuação) significa que o efeito "verdadeiro" da democracia sobre ethnic inequality pode ser **maior** do que o reportado

---

## Referências-chave

- Alesina, A., Devleeschauwer, A., Easterly, W., Kurlat, S., & Wacziarg, R. (2003). Fractionalization. *Journal of Economic Growth*, 8(2), 155-194.
- Alesina, A., Michalopoulos, S., & Papaioannou, E. (2016). Ethnic Inequality. *Journal of Political Economy*, 124(2), 428-488.
- Buhaug, H., Cederman, L.-E., & Gleditsch, K. S. (2014). Square Pegs in Round Holes: Inequalities, Grievances, and Civil War. *International Studies Quarterly*, 58(2), 418-431.
- Cederman, L.-E., Gleditsch, K. S., & Buhaug, H. (2013). *Inequality, Grievances, and Civil War*. Cambridge University Press.
- Easterly, W. & Levine, R. (1997). Africa's Growth Tragedy: Policies and Ethnic Divisions. *Quarterly Journal of Economics*, 112(4), 1203-1250.
- Gründler, K. & Link, A. (2024). Ethnic Inequality and Economic Growth: Evidence from Harmonized Satellite Data. *CESifo Working Paper* No. 11034.
- Hillesund, S. (2023). Horizontal Inequalities, Political Violence, and Nonviolent Conflict Mobilization: A Review of the Literature. *Journal of Economic Surveys*, 37(3), 1107-1141.
- Østby, G. (2008). Polarization, Horizontal Inequalities and Violent Civil Conflict. *Journal of Peace Research*, 45(2), 143-162.
- Posner, D. N. (2004). Measuring Ethnic Fractionalization in Africa. *American Journal of Political Science*, 48(4), 849-863.
- Radatz, T. (2025). Measuring Multidimensional Inequality and Its Impact on Civil War Outbreak in 193 Countries, 1810-2010. *Review of Income and Wealth*.
- Ross, M. L. (2001). Does Oil Hinder Democracy? *World Politics*, 53(3), 325-361.
- Stewart, F. (2008). *Horizontal Inequalities and Conflict: Understanding Group Violence in Multiethnic Societies*. Palgrave Macmillan.
- Wucherpfennig, J., Hunziker, P., & Cederman, L.-E. (2016). Who Inherits the State? Colonial Rule and Postcolonial Conflict. *American Journal of Political Science*, 60(4), 882-898.
