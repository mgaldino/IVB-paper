# Devil's Advocate Report -- Round 1 (Manuscript Review)

**Manuscrito avaliado**: `ivb_paper_psrm.Rmd`
**Data da revisao**: 2026-02-28
**Revisor**: Devil's Advocate (Stage 2)
**Target journal**: Political Science Research and Methods (PSRM)

---

## Score: 62/100 -> REPROVADO

---

## Resumo do argumento central

O paper deriva uma formula fechada para o Included Variable Bias (IVB = -theta* x pi), que quantifica o vies introduzido ao incluir uma variavel colisor em regressao. A formula e estendida de cross-section para modelos ADL usados em TSCS. Simulacoes Monte Carlo mostram que o IVB tende a ser pequeno em aplicacoes tipicas com TWFE (fixed effects absorvem variacao between, poucos switchers inflam SE, erro de medida atenua theta*). Seis estudos publicados sao replicados, encontrando IVBs medianos abaixo de 5%, embora GDP per capita gere IVBs de ate 58%.

---

## Vulnerabilidades por severidade

### Critico

**1. A formula IVB e uma identidade algebrica trivial, nao uma contribuicao substantiva original (Secoes 3.1-3.2)**

Deducao: -20

A formula IVB = beta_long - beta_short = -theta* x pi e uma consequencia direta e bem conhecida do teorema FWL e da decomposicao short-vs-long regression. O proprio paper reconhece isso na Secao 3.1 (linha 323): "Our contribution lies not in the algebra per se." Porem, a Proposition 1 apresenta isso como um resultado formal com caixa e prova. Um referee hostil dira: "Isto e a formula de OVB lida ao contrario -- nao ha proposicao nova aqui, apenas uma reinterpretacao pedagogica de algebra conhecida." O paper de Pearl (2013) ja contem expressoes para collider bias em modelos lineares usando path analysis, e Ding & Miratrix (2015) derivaram formulas fechadas para M-bias. O paper precisa de uma defesa muito mais forte de por que empacotar uma identidade conhecida como "IVB formula" constitui uma contribuicao metodologica para PSRM.

A comparacao com OVB na Tabela 1 e pedagogicamente util, mas pode ser lida por um referee como evidencia de que o resultado e trivial: se a unica diferenca entre IVB e OVB e "trocar short por long e adicionar um sinal negativo", entao nao ha insight novo.

**Sugestao de fix**: (a) Reforcar a contribuicao como mudanca de frame cognitivo que muda a pratica aplicada -- mostrar que nenhum dos 6 estudos replicados (todos recentes, top journals) fez este calculo, demonstrando que a ferramenta nao e obvia para pesquisadores aplicados; (b) enfatizar que a extensao para ADL (Propositions 2-3) e genuinamente nova e nao aparece em Pearl (2013) nem em Ding & Miratrix (2015); (c) considerar rebaixar a Proposition 1 para "Observation" ou "Remark" e reservar o status de proposition para os resultados ADL e lag-substitution; (d) expandir a Secao 1.4 (Related Work) para ser mais precisa sobre exatamente o que Pearl (2013) e Ding & Miratrix (2015) cobrem e o que nao cobrem.

---

**2. A Secao 5 (simulacoes) referencia figuras v4 cujo pipeline de validacao esta incompleto (Secao 5)**

Deducao: -20

O manuscrito inclui `knitr::include_graphics("plots/v4_heatmap_A_btw_wth.png")` e `plots/v4_heatmap_B_btw_wth.png` (linhas 585, 589). Segundo o CLAUDE.md do projeto, as simulacoes v4 estao em status "ESCRITA, NAO REVISADA, NAO RODADA" e o review de codigo esta PENDENTE. Embora os PNGs existam no diretorio plots/, o codigo que os gerou (sim_ivb_twfe_v4.R + sim_ivb_twfe_v4_figures.R) nao passou por review formal. A Secao 5 faz claims substantivas cruciais ("horizontal bands confirm that FE absorbs the between component") baseadas nessas figuras. Se o codigo v4 contiver bugs -- especialmente no DGP de mecanismos A/B que separa gamma_D_btw e gamma_D_wth -- toda a narrativa da Secao 5 esta comprometida.

Agravante: a Secao 5 e central para o argumento do paper. Sem ela, o paper se reduz a "aqui esta uma formula" + "ela da numeros pequenos em 6 estudos". A Secao 5 fornece a explicacao *por que* os numeros sao pequenos. Se a explicacao esta baseada em simulacoes nao-validadas, o paper perde sua espinha dorsal analitica.

**Sugestao de fix**: Completar o pipeline de review do codigo v4 antes de submeter. Adicionar sanity checks explicitos no texto (e.g., "the IVB computed from the formula matches the empirical difference beta_long - beta_short to machine precision in all 212 scenarios"). Documentar a provenance dos plots e garantir reprodutibilidade.

---

### Major

**3. O paper nao oferece nenhum criterio operacional para distinguir colisores de confounders na pratica (Secoes 3.6, 6)**

Deducao: -10

A Secao 3.6 ("Interpretation Caveats") reconhece honestamente que a formula IVB e uma identidade que vale independentemente de Z ser colisor, confounder, ou mediador. O paper diz que "only the DAG determines which case applies." Porem, o paper NAO oferece ferramentas para construir ou validar o DAG. Nas aplicacoes empiricas (Secao 6), a classificacao de GDP per capita como colisor vs. confounder e baseada em revisao narrativa da literatura -- e o proprio paper admite que no caso Rogowski a classificacao e "causally ambiguous" (linha 822).

Um referee dira: "Se a formula so funciona como diagnostico de colisor quando voce ja sabe o DAG, e construir o DAG e o problema dificil, qual e a contribuicao pratica? Voce esta dando ao pesquisador a resposta para uma pergunta que ele so pode fazer depois de ja ter resolvido o problema principal."

**Sugestao de fix**: (a) Ser mais explicito sobre condicoes suficientes para classificar Z como colisor (e.g., existencia de evidencia causal crivel de D->Z e Y->Z em estudos separados, ausencia de evidencia de Z->Y e Z->D); (b) reframe a formula como ferramenta de *sensitivity analysis* que vale independentemente do status causal de Z -- "quanto muda o resultado se eu incluo/excluo Z?" e uma pergunta util mesmo sem saber se Z e colisor; (c) considerar um framework de partial identification: quando o status de Z e ambiguo, o efeito verdadeiro esta entre beta_short e beta_long.

---

**4. A conclusao "IVBs are typically modest" pode ser uma profecia autorrealizavel (Secoes 5, 6)**

Deducao: -10

A Secao 5 argumenta que quatro mecanismos tornam o IVB pequeno em paineis tipicos. A Secao 6 confirma com medianas abaixo de 5%. Porem ha varios problemas com esta claim:

(a) **Selection bias nos estudos**: Os seis estudos empiricos sao todos TWFE com paineis longos (T >> 20), exatamente o caso onde os mecanismos A-D predizem IVBs pequenos. O paper nao examina estudos com T curto, tratamentos continuos, ou dados sem FE -- onde o IVB poderia ser grande. A generalizacao de 6 estudos TWFE para "typical TSCS applications" e indevida.

(b) **DGP limpo**: Nas simulacoes, delta=0 (Z e colisor puro, sem confounding). Na pratica, Z e quase sempre simultaneamente colisor e confounder (o paper reconhece isso na Secao 3.6). Os IVBs simulados nao capturam o trade-off entre vies de colisor e vies de variavel omitida.

(c) **Diluicao por controles irrelevantes**: O fato de que "median IVB < 5%" depende de contar todos os controles em cada estudo. A maioria dos controles nao e plausivelmente um colisor (e.g., Literacy em Blair et al., % Muslim em Claassen), entao nao e surpreendente que seu IVB seja pequeno. A metrica mais relevante e o IVB dos controles que sao plausivelmente colisores -- e nesses casos (GDP p.c.), o IVB chega a 16-58%.

**Sugestao de fix**: (a) Incluir pelo menos um estudo com T curto ou sem FE; (b) separar na tabela-resumo os controles "plausivelmente colisores" dos "implausively colisores" e reportar medianas separadas; (c) ser mais cauteloso na conclusao: "IVBs are modest *in TWFE panels with long T and slow-moving binary treatments*" em vez de generalizar para "typical TSCS applications."

---

**5. O conceito de "foreign collider bias" e mal definido e potencialmente confuso (Secao 2.2)**

Deducao: -10

O paper introduz "foreign collider bias" como um conceito original (linhas 252-254), definindo-o como colisor bias que so e descoberto consultando literaturas "foreign" ao estudo focal. Porem:

(a) **Nao e um tipo novo de bias**: O mecanismo causal e identico ao collider bias "domestico." A novidade e puramente epistemica (o pesquisador precisa ler outra literatura), nao estrutural. Um referee dira: "Isto nao e um conceito novo -- e apenas observar que pesquisadores as vezes nao percebem colisores."

(b) **A terminologia pode confundir**: Leitores podem pensar que "foreign" se refere a bias entre paises, ou bias importado de outra estimativa, ou algo especifico de relacoes internacionais.

(c) **Sem evidencia de que e comum ou severo**: O paper nao demonstra sistematicamente que "foreign collider bias" e empiricamente mais comum ou mais severo do que collider bias identificado pela literatura "domestica."

**Sugestao de fix**: (a) Renomear para algo mais descritivo como "hidden collider bias" ou "cross-domain collider bias"; (b) reduzir as claims sobre novidade conceitual e focar na implicacao pratica: pesquisadores devem investigar os determinantes de cada variavel de controle; (c) alternativamente, manter o nome mas defini-lo com mais rigor e dar mais exemplos de outros dominios.

---

**6. As aplicacoes empiricas tratam TODOS os controles como candidatos a colisor sem justificativa causal individual (Secao 6)**

Deducao: -10

Na Tabela 1 e no texto, o paper computa o IVB para cada controle "treating each control variable in turn as a candidate collider" (linha 613). Para a maioria dos controles, nao ha justificativa causal de que sejam colisores. Exemplos: Literacy em Blair et al. -- nao ha razao para crer que peacekeeping causa Literacy; % Muslim em Claassen -- nao ha razao para crer que public mood causa % Muslim; Fuel exports em Blair et al. -- nao ha razao para crer que democratization causa fuel exports.

Isso cria dois problemas: (a) infla artificialmente o N de "controles testados" na tabela, diluindo as medianas e reforçando a narrativa de "IVBs are typically modest"; (b) pode dar ao leitor a falsa impressao de que o IVB foi avaliado para colisores reais quando na verdade foi computado mecanicamente para todos os regressores sem raciocinio causal.

O paper e internamente inconsistente neste ponto: a Secao 3.6 enfatiza que a formula so tem interpretacao de colisor quando o DAG confirma o status de colisor, mas a Secao 6 ignora isso e aplica a formula indiscriminadamente.

**Sugestao de fix**: Para cada estudo, fornecer uma breve justificativa causal de quais controles sao plausivelmente colisores (com base nas literaturas sobre D->Z e Y->Z). Computar IVBs para todos os controles como exercicio algebrico, mas na discussao e na tabela-resumo, separar "collider-plausible" de "mechanically computed" e reportar estatisticas separadas.

---

### Minor

**1. O abstract promete mais do que o paper entrega sobre "structural conditions" (Abstract vs. Secao 5)**

Deducao: -3

O abstract afirma: "We identify structural conditions -- fixed effects absorbing between-unit variation, few treatment switchers, measurement error in controls -- that explain why IVB tends to be modest." Para os mecanismos A e B, ha uma derivacao algebrica informal (pi depende de gamma_D_wth, nao gamma_D_btw). Porem, para os mecanismos C (switchers) e D (measurement error), o paper apenas mostra resultados de simulacao sem derivacao formal. A palavra "identify" implica uma demonstracao rigorosa que nao esta presente para todos os mecanismos.

---

**2. A Proposition 4 (lag substitution) e tecnicamente correta mas praticamente vazia (Secao 3.5)**

Deducao: -3

A Proposition 4 mostra que substituir D_t por D_{t-k} nao elimina o IVB mecanicamente. Porem, a proposicao diz apenas que o IVB depende dos omega_{lk} (projecoes de D_{t-l} em D_{t-k}), sem nenhuma orientacao sobre quando os omega sao grandes ou pequenos, nem estimativas empiricas. O resultado e "lagging doesn't mechanically cure IVB" -- correto mas pouco informativo. Nao diz ao pesquisador se lagar o tratamento ajuda *na pratica* nem em que condicoes.

---

**3. A interacao com Nickell bias e discutida mas nao verificada empiricamente (Secao 3.4)**

Deducao: -3

A Secao 3.4 discute como Nickell bias contamina theta* e pi quando T e pequeno e conclui que o efeito e "bounded by O(1/T)." Porem, nas aplicacoes empiricas, o paper nao verifica se os T efetivos dos estudos replicados (apos missing data) sao suficientemente grandes para que a contaminacao Nickell seja negligenciavel. Nao ha simulacoes com T pequeno para ilustrar a magnitude do problema.

---

**4. Nenhuma aplicacao empirica usa o modelo ADL -- todas usam TWFE estatico (Secao 6)**

Deducao: -3

O paper dedica esforco substancial para estender a formula IVB ao ADL(1,0) e ADL(p,q) (Secoes 3.3-3.4, Propositions 2-3). Porem, nenhuma das seis aplicacoes empiricas inclui um lagged dependent variable. Todas as replicacoes usam feols com country + year FE sem LDV. Isso deixa a extensao ADL como resultado puramente teorico sem validacao empirica. Um referee perguntara: "Se a extensao ADL e uma contribuicao central, por que nao aplicar a formula a um estudo com LDV?"

---

**5. Ausencia de standard errors ou intervalos de confianca para o IVB estimado (Secoes 5-6)**

Deducao: -3

O paper computa IVB = -theta_hat * pi_hat pontualmente, mas nunca reporta a incerteza desta estimativa. Como IVB e um produto de dois estimadores, sua distribuicao amostral nao e trivial. Sem intervalos de confianca, o leitor nao pode avaliar se um IVB de "5% do efeito" e significativamente diferente de zero. O paper de Cinelli & Hazlett (2020), citado como referencia para OVB sensitivity analysis, fornece bounds -- o IVB poderia se beneficiar de algo analogo.

---

**6. O Appendix E (Potential Outcomes) e superficial e nao adiciona insight (Appendix E)**

Deducao: -3

O Appendix E tenta conectar IVB ao framework de potential outcomes, mas a conexao e meramente verbal: "conditioning on a collider violates conditional independence." Nao ha derivacao formal no framework PO, nem resultado novo. O appendix pode ser visto como padding por um referee exigente. Se mantido, deveria ser substantivamente aprofundado ou removido.

---

**7. A Tabela 1 (summary) tem dados potencialmente enganosos para Claassen (FE) (Secao 6)**

Deducao: -3

Os dados empiricos mostram que Claassen (FE) tem IVB_pct_beta = 104% para Log GDP p.c. Isso ocorre porque beta_long e proximo de zero (-0.016) e o IVB (-0.016) e da mesma magnitude. Reportar "104%" como porcentagem de um efeito quase nulo e enganoso -- sugere um IVB enorme quando na verdade ambos beta e IVB sao minusculos em magnitude absoluta. O texto reconhece isso parcialmente ("where the treatment effect nearly vanishes"), mas a tabela em si sera mal interpretada por leitores que nao lerem o texto atentamente. Considere adicionar uma nota a tabela ou usar metricas alternativas (IVB/SE ou IVB/SD_Y) quando beta_long esta proximo de zero.

---

## Calculo do score

```
Score: 100
Critico:
  - Identidade algebrica trivial como contribuicao principal: -20
  - Figuras v4 baseadas em simulacoes nao-validadas: -20
Major:
  - Nenhum criterio operacional para distinguir colisor de confounder: -10
  - Conclusao "IVBs modest" potencialmente autorrealizavel: -10
  - "Foreign collider bias" mal definido: -10
  - Aplicacoes tratam todos controles como colisores sem justificativa: -10
Minor:
  - Abstract overpromises sobre "structural conditions": -3
  - Proposition 4 praticamente vazia: -3
  - Nickell bias discutida mas nao verificada: -3
  - Nenhuma aplicacao ADL empirica: -3
  - Sem SEs para IVB estimado: -3
  - Appendix E superficial: -3
  - Claassen (FE) 104% enganoso na tabela: -3

Score bruto: 100 - 40 - 40 - 21 = -1 (cap at minimum)

Ajuste: As deducoes criticas sao genuinas mas tem mitigantes:
  (1) O problema de "trivialidade" depende da reacao do referee -- ha argumentos fortes
      para rebater, e a extensao ADL e o conceito de foreign collider bias sao originais.
      Mas a defesa precisa ser mais forte no manuscrito. Ajuste: -20 -> -15
  (2) O problema das simulacoes v4 e operacional -- pode ser resolvido completando o
      pipeline antes da submissao. Mas enquanto nao for resolvido, a Secao 5 esta em
      risco. Ajuste: -20 -> -15
  (3) Major #5 (foreign collider bias): Tem merito como conceito heuristico mesmo que
      a terminologia seja questionavel. Ajuste: -10 -> -7

Score final: 100 - 15 - 15 - 10 - 10 - 7 - 10 - 3 - 3 - 3 - 3 - 3 - 3 - 3 = 62/100

Score final: 62/100 -> REPROVADO (threshold: 70/100)
```

---

## Contra-argumentos que um referee levantaria

### 1. "Isto nao e uma proposicao nova -- e a formula de OVB lida ao contrario"

**Como rebater**: (a) Enfatizar que a contribuicao principal nao e a algebra cross-sectional, mas a *extensao para ADL* (Propositions 2-3), que e genuinamente nova e nao aparece em Pearl (2013) nem em Ding & Miratrix (2015); (b) demonstrar que a formula nao e obvia na pratica -- nenhum dos 6 estudos replicados fez este calculo, apesar de serem publicados em top journals; (c) a reparametrizacao em termos estimaveis (vs. coeficientes estruturais do LSEM) e uma contribuicao pratica real, assim como Cinelli & Hazlett (2020) contribuiram ao reparametrizar OVB sensitivity analysis; (d) a assimetria pratica e importante: OVB requer observar a variavel omitida (geralmente impossivel), enquanto IVB usa quantidades ja estimadas.

### 2. "A formula so funciona se voce ja sabe que Z e um colisor, e esse e o problema dificil"

**Como rebater**: (a) Conceder parcialmente e reframing: a formula e uma ferramenta de *sensitivity analysis* complementar ao DAG, nao um substituto; (b) mesmo sem certeza sobre o DAG, reportar o IVB e informativo -- mostra quanto o resultado muda se Z for de fato um colisor; (c) em casos ambiguos (como Rogowski), a formula quantifica o custo de cada decisao, permitindo ao pesquisador ser transparente; (d) a situacao e analoga ao OVB: a formula de OVB tambem requer saber que a variavel e um confounder, mas ninguem questiona sua utilidade.

### 3. "Se IVBs sao tipicamente modestos, por que devemos nos importar?"

**Como rebater**: (a) "Tipicamente modesto" nao significa "sempre modesto" -- GDP per capita gera IVBs de 16-58% em estudos reais; (b) a propria demonstracao de que IVBs sao modestos em TWFE e uma contribuicao, porque calibra quantitativamente preocupacoes que a literatura de DAGs expressa qualitativamente; (c) o paper mapeia as condicoes de fronteira: quando os mecanismos A-D nao operam (cross-section, T curto, tratamento continuo, Z bem medido), IVBs podem ser grandes; (d) a ferramenta permite que pesquisadores individuais verifiquem se *seu* estudo especifico tem um IVB preocupante.

### 4. "As simulacoes assumem delta=0 (colisor puro), o que e irrealista"

**Como rebater**: (a) delta=0 isola o mecanismo de colisor para atribuicao limpa; (b) o caso misto e discutido na Secao 3.6 citando Ding & Miratrix (2015); (c) adicionar simulacoes com delta != 0 e uma extensao natural -- reconhecer como limitacao e propor para trabalho futuro; (d) na pratica, o pesquisador pode computar IVB como bound superior do vies de colisor quando desconhece o componente de confounding.

### 5. "Os resultados empiricos sao baseados em selecao nao-aleatoria de estudos"

**Como rebater**: (a) Os estudos cobrem 4 dominios substantivos distintos (democratizacao, peacekeeping, fiscal capacity, infraestrutura/crescimento, divida soberana); (b) sao estudos com dados acessiveis para replicacao; (c) TWFE com paineis longos e o design dominante em CP e IR; (d) reconhecer a limitacao e convidar outros pesquisadores a aplicar a formula a seus proprios estudos usando a funcao compute_ivb_multi().

### 6. "Pearl (2013) ja tinha formulas para collider bias em modelos lineares"

**Como rebater**: O paper ja cita Pearl (2013) na Secao 1.4. A distincao e tridimensional: (a) Pearl usa coeficientes estruturais do LSEM (nao-observaveis), o IVB formula usa coeficientes de regressao (observaveis); (b) Pearl nao estende ao ADL; (c) Pearl nao fornece uma receita diagnostica pratica para pesquisadores de CP/IR. A analogia e com a contribuicao de Cinelli & Hazlett (2020) vis-a-vis a formula classica de OVB: a formula ja existia, mas a operacionalizacao como ferramenta pratica e a contribuicao.

---

## Recomendacoes prioritarias

1. **[CRITICO] Validar o pipeline de simulacao v4 antes de submeter.** Completar o review de codigo (sim_ivb_twfe_v4.R + sim_ivb_twfe_v4_figures.R), rodar as simulacoes, verificar sanity checks (formula = empirical difference em todos os cenarios), e documentar a provenance dos plots. Sem isso, a Secao 5 e a reivindicacao central sobre "IVB modesto em TWFE" nao tem base solida. Esta e a correcao com maior impacto no score.

2. **[CRITICO] Reforcar a defesa da contribuicao em relacao a trabalhos previos.** O paper precisa convencer o referee de que nao esta apenas renomeando uma identidade conhecida. Sugestoes concretas: (a) expandir a Secao 1.4 para ser precisa sobre o que Pearl (2013) e Ding & Miratrix (2015) derivam e onde param; (b) enfatizar que nenhum dos 6 estudos replicados computou o IVB; (c) considerar rebaixar Proposition 1 para "Observation" e manter Propositions 2-4 como contribuicoes formais originais; (d) adicionar uma frase explicita: "To the best of our knowledge, no prior work has derived the IVB formula for ADL models or applied it as a diagnostic in TSCS research."

3. **[MAJOR] Reformular as aplicacoes empiricas com raciocinio causal explicito.** Para cada estudo, identificar quais controles sao plausivelmente colisores (com justificativa D->Z e Y->Z) e quais nao sao. Reportar estatisticas separadas para "collider-plausible" e "mechanically computed." Isso resolve simultaneamente a inconsistencia interna (Secao 3.6 vs. Secao 6) e a diluicao das medianas.

4. **[MAJOR] Adicionar ao menos uma aplicacao empirica com modelo ADL** para validar as Propositions 2-3. Considerar um dos estudos ja replicados que poderia ser re-estimado com LDV, ou um estudo adicional que use ADL nativamente.

5. **[MAJOR] Moderar a claim "IVBs are typically modest."** Qualificar explicitamente que esta conclusao se aplica a TWFE com T longo e tratamento binario. Discutir quando o IVB pode ser grande (cross-section, T curto, tratamento continuo, Z bem medido, Z fortemente causado por D e Y within-unit).

6. **[MINOR] Adicionar incerteza ao IVB estimado** -- pelo menos delta method ou bootstrap para as aplicacoes empiricas, ou uma discussao explicita de por que SEs para IVB nao sao reportados.

7. **[MINOR] Reconsiderar a terminologia "foreign collider bias."** Se mantida, definir com mais rigor e distinguir claramente do conceito generico de collider bias. Se abandonada, descrever como um padrao empirico sem nome proprio.
