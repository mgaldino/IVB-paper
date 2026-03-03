# Ideação v2: Lead do Paper IVB — Pós-DA

**Data**: 2026-03-02
**Inputs**: ideation_paper_lead.md (v1), da_lead_b_report.md, nl_simulation_report.md (unificado)

---

## 1. Avaliação do DA: ponto a ponto

### O que o DA acertou

**1. O "debate" é overstated (Seção 1 do DA).** O DA tem razão que não existe um "debate ativo" com Blackwell & Glynn de um lado e Imai & Kim do outro. Os dois papers abordam failure modes diferentes. Blackwell & Glynn tratam de post-treatment bias quando Z é afetado pelo tratamento; Imai & Kim tratam de strict exogeneity violation em TWFE estático. Framing como "debate" é vulnerável a um reviewer que conheça os dois papers.

**2. O manuscrito está escrito como Lead A (Seção 4.4 do DA).** Reescrever para Lead B exige reestruturação real do paper, não apenas cosmética.

**3. Collider puro vs caso misto precisa ser formalizado (Seção 4.3 do DA).** O DA tem razão que essa distinção está como caveat quando deveria ser resultado central.

**4. D binário é um problema (implícito na Seção 2.3 do DA).** O DA apontou que o paper só testava tratamento contínuo. As simulações v4 Mecanismo C agora confirmam: IVB é 16–53% de β com D binário. Isso é uma exceção real.

**5. As NL simulations deveriam estar no paper (Seção 6.7 do DA).** Correto.

### O que o DA errou

**1. "Precisa simular MSM/SNMM" (Seção 2, 4.1, 6.1, 7a do DA) — ERRADO.**

Este é o erro central do DA. A claim do paper **não é** "ADL domina MSM em RMSE". A claim é: "o post-treatment bias que motiva Blackwell & Glynn a recomendar MSM é empiricamente pequeno."

Isso é uma distinção crucial. Não precisamos comparar ADL vs MSM diretamente. Precisamos mostrar que **o problema que motivou a recomendação de MSM é negligível**.

**Verificação direta em Blackwell & Glynn (2018):**

O paper de BG2018 é explícito sobre o mecanismo:

> "The root of the bias in the ADL approach is the nature of time-varying covariates, Z_it. [...] when Z_it is post-treatment to lagged treatment, conditioning on it will induce post-treatment bias for the effect of lagged treatment, because conditioning will open a back-door path from Z_it through U_i to Y_it." (p. 1078)

> "In this setting, there is no way to estimate the direct effect of lagged treatment without bias with a single ADL model." (p. 1073)

A recomendação de MSM/SNMM segue diretamente: "We focus on two methods [...] that can estimate the effect of treatment histories without bias and under weaker assumptions than common TSCS models." (p. 1067)

**O argumento de BG é linear:** post-treatment bias no ADL → MSM/SNMM como solução. Se quantificamos esse post-treatment bias e mostramos que é pequeno (<1% de β), o **motivo** para adotar MSM/SNMM perde força. Não precisamos rodar MSM — precisamos mostrar que o problema que MSM resolve é negligível.

**Por que não simular MSM?** Razões técnicas e conceituais:
- FWL não se aplica a IPTW/MSM → não conseguimos decompor o bias em IVB vs outros componentes
- Comparar RMSE não separa bias de variância (bias-variance trade-off) → RMSE menor de ADL não prova que o bias é menor, pode ser apenas menor variância
- MSM/IPTW com FE é problemático (BG2018 footnote 13: "This requirement makes it difficult to apply IPTW to fixed-effects settings")
- O paper não claim "ADL > MSM". Claim: "o post-treatment bias do ADL é pequeno"

**2. "A fórmula não pode distinguir colliders de confounders" (Limitação 1 do DA) — PARCIALMENTE ERRADO.**

O DA está correto que a fórmula sozinha não distingue, mas o paper nunca claim isso. O paper diz explicitamente que é preciso um DAG primeiro (Step 0). A fórmula é um **complemento quantitativo** ao DAG, não um substituto. O DA trata isso como fraqueza quando é o design intencional.

**3. "Blackwell & Glynn são sobre estimands diferentes (dynamic treatment regimes)" (Seção 5.2 do DA) — PARCIALMENTE ERRADO.**

Sim, BG2018 discutem treatment histories e step response functions. Mas o **core argument sobre bias** é sobre o efeito defasado (lagged effect) do tratamento em um período, não sobre treatment regimes complexos. Citação direta: "we focus on a simple case where we are only interested in the first two lags of treatment" (p. 1073). E nas simulações de BG, o estimand é τ_l(t,1) — o lagged effect de um período, que é exatamente o que ADL estima.

O DA exagera o escopo do argumento de BG para invalidar o paper. Na prática, a maioria dos pesquisadores em CP quer estimar contemporaneous effects e lagged effects simples, não treatment regimes.

**4. "IVB é apenas uma fonte de bias" (Limitação 2 do DA) — CORRETO MAS IRRELEVANTE.**

Sim, ADL+FE tem IVB + Nickell bias + funcional form misspec. Mas as simulações MOSTRAM o bias total do ADL_all (não só o IVB), e ele é <0.5% de β. O report mede bias total, não só IVB. O DA confunde "a fórmula mede só IVB" com "as simulações medem só IVB". As simulações medem bias total do estimador.

### O que o DA não verificou

**1. A leitura de Blackwell & Glynn.** O DA não leu BG2018 para verificar se o argumento "post-treatment bias motiva MSM" está correto. Está. É a tese central do paper.

**2. Os resultados v4 Mecanismo C.** Os resultados existiam mas não estavam no report na hora do DA. Agora estão.

---

## 2. O que muda com esta análise

### Claims que sobrevivem ao DA

1. **"O post-treatment bias identificado por Blackwell & Glynn é empiricamente negligível sob linearidade e tratamento contínuo."** — Suportado por simulações (ADL_all bias < 0.5%), 6 aplicações empíricas (median |IVB/SE| = 0.13), e teoria (FE absorve between, erro de medida atenua θ*).

2. **"A fórmula IVB quantifica exatamente o post-treatment bias de Blackwell & Glynn."** — IVB = −θ*·π é a expressão FWL do post-treatment bias. O que BG chamam de "bias from conditioning on Z_it" é exatamente o que a fórmula mede.

3. **"ADL(all lags) + FE é o melhor modelo linear em bias E RMSE."** — Confirmado em todas as simulações (NL, DGP variations, feedback, carryover).

4. **"A fronteira bounded/unbounded delimita quando o resultado vale."** — 8 funções NL testadas, fronteira é abrupta.

### Claims que NÃO sobrevivem

1. ~~"Resolvemos o debate TSCS"~~ → Não há debate ativo. Reframe.
2. ~~"ADL domina MSM"~~ → Nunca simulamos MSM e não precisamos. Reframe.
3. ~~"IVB é sempre pequeno"~~ → Com D binário, IVB é 16-53% de β (Mecanismo C).

### Claims que precisam ser adicionadas

1. **"Com tratamento binário, o IVB pode ser grande."** — Mecanismo C: |IVB/SE| = 1.67-12.73. Isso delimita a claim e é honesto.
2. **"O post-treatment bias de BG é exatamente o IVB (sob linearidade)."** — Essa é a bridge formal que o paper precisa.

---

## 3. Nova sugestão de lead: B' + E (B refinado)

### Pitch em uma frase

> "Blackwell & Glynn (2018) identificaram que o ADL tem post-treatment bias quando covariáveis são afetadas pelo tratamento. Nós derivamos a fórmula exata desse bias, mostramos que é pequeno na grande maioria das aplicações em CP, e delimitamos quando não é."

### Por que B' e não B original

Lead B original dizia "resolvemos o debate TSCS". Lead B' diz algo mais preciso e defensável:

| Lead B (original) | Lead B' (refinado) |
|---|---|
| "Há um debate, nós resolvemos" | "Há um problema identificado, nós quantificamos" |
| Implica BG vs IK como antagonistas | Trata BG como precursores cujo problema quantificamos |
| Precisa rodar MSM para provar dominância | Precisa apenas mostrar que o bias é pequeno |
| Vulnerável a "que debate?" | Vulnerável apenas a "já sabíamos" (mais fácil de defender) |

### Por que E se mantém

A unificação (post-treatment bias = collider bias = strict exogeneity violation) continua sendo a contribuição teórica elegante que dá substância ao paper. Sem E, o paper é "computamos um número e ele é pequeno". Com E, o paper é "três problemas que pareciam diferentes são o mesmo, e podemos quantificá-lo".

### Estrutura proposta

| Seção | Conteúdo | Papel no argumento |
|---|---|---|
| **1. Intro** | O problema da seleção de controles em TSCS. BG2018 mostram que ADL tem post-treatment bias quando covariáveis são afetadas por tratamento. Mas quão grande é esse bias? | **Motivação: problema real, nunca quantificado** |
| **2. Framework** | DAGs + collider bias. Unificação: post-treatment bias (BG), collider bias (Pearl), strict exogeneity violation (IK) são o mesmo fenômeno. | **Contribuição teórica: bridge/unificação** |
| **3. A fórmula IVB** | Derivação cross-section + ADL+FE. IVB = −θ*·π. A fórmula quantifica exatamente o post-treatment bias de BG. | **Contribuição metodológica: a ferramenta** |
| **4. Por que o IVB é pequeno** | (a) FE absorve between (Mec A/B), (b) erro de medida atenua θ* (Mec D), (c) variáveis em CP são lentas. Álgebra + simulações v4. | **Resultado principal 1: explicação estrutural** |
| **5. Quando o IVB NÃO é pequeno** | (a) NL unbounded → IVB amplifica (8 tipos, fronteira abrupta). (b) D binário → IVB = 16-53% (Mec C). (c) Interação forte. | **Resultado principal 2: boundary conditions** |
| **6. Aplicações empíricas** | 6 estudos, 14 collider candidates. Median |IVB/SE| = 0.13. Caso Rogowski como exceção instructiva. | **Evidência empírica** |
| **7. Conclusão** | ADL+FE é a escolha prática para tratamento contínuo em painéis com T ≥ 10. O post-treatment bias de BG é negligível nesse setting. Com D binário, use a fórmula para diagnosticar. | **Take-away prático** |

### O que muda vs paper atual (Lead A)

1. **Primeiro parágrafo**: não começa com "which controls to include" — começa com "Blackwell & Glynn (2018) showed that ADL models produce biased estimates of lagged treatment effects when time-varying covariates are affected by treatment. They recommend MSM/SNMM as alternatives. But how large is this bias in practice?"

2. **Seção 2 (Framework)** ganha a unificação BG/IK/Pearl como resultado formal, não como aside.

3. **Seção 4 (novo)** incorpora os mecanismos v4 (A/B/D) como explicação de por que IVB é pequeno — sai de caveat e vira resultado.

4. **Seção 5 (novo)** incorpora as simulações NL + Mecanismo C como boundary conditions — sai de apêndice e vira seção principal.

5. **Foreign collider bias** é downweighted mas não eliminado — é um exemplo dentro da seção DAGs, não uma contribuição standalone.

6. **Cinelli & Hazlett**: o DA sugere comparar com a sensitivity analysis deles. Resposta: a fórmula IVB é o **complemento simétrico** do OVB formula que Cinelli & Hazlett usam. Eles fazem sensitivity para OVB; nós quantificamos IVB diretamente (porque o collider está **incluído**, não omitido, então temos os dados). Isso é uma contribuição clara, não uma competição.

### Como responder às objeções do DA

| Objeção DA | Resposta |
|---|---|
| "Precisa simular MSM" | Não. A claim é "o bias que motiva MSM é pequeno", não "ADL > MSM". |
| "Não há debate" | Concordo. Reframe de "resolver debate" para "quantificar um problema real". |
| "Fórmula não distingue collider de confounder" | By design. DAG primeiro, fórmula depois. |
| "BG é sobre estimands (treatment regimes)" | Parcialmente. BG focam em lagged effects simples nas simulações e aplicação. Treatment regimes é extensão. |
| "Bounded/unbounded vira contra o paper" | Não. É a **delimitação precisa** que referees querem. E em CP, variáveis são bounded. |
| "6 aplicações são TWFE com slow-moving vars" | Expandir com pelo menos 1 aplicação com T curto ou D contínuo. |
| "Comparar com Cinelli & Hazlett" | IVB é o complemento simétrico do OVB. Explicitar. |

---

## 4. Targets e riscos

### Target journals (em ordem de ambição)

1. **Political Analysis** — fit natural. Paper metodológico com aplicações empíricas. Audience: metodólogos de CP.
2. **PSRM** — backup forte. Mais espaço para simulações.
3. **AJPS** — ambicioso mas viável se a seção empírica for expandida e o bridge BG/IK/Pearl for enfatizado como contribuição para a disciplina.

### Riscos residuais

1. **"So what?" — "ADL+FE já é o default"**: Resposta: sim, mas ninguém sabia QUANTO post-treatment bias ele tem. Agora sabemos: <1% de β. Isso justifica formalmente a prática existente.

2. **"Isso é FWL, todo mundo sabe"**: Resposta: FWL é o mecanismo, o RESULTADO é que o post-treatment bias de BG é negligível. Ninguém sabia isso antes.

3. **"E o D binário?"**: Resposta: é a boundary condition honesta. Com D binário, use a fórmula. Se |IVB/SE| > 1, considere alternativas. Falta: testar se ADL(all lags) salva o cenário binário.

4. **"MSM/SNMM nunca foram testados"**: Resposta: a claim não é sobre ADL vs MSM. É sobre o tamanho do post-treatment bias. Se o bias é pequeno, a motivação para MSM é fraca. Explicitar isso no paper para antecipar o reviewer.

---

## 5. Próximos passos

1. **Rodar ADL(all lags) nos cenários v4 Mecanismo C (D binário)** — preencher a lacuna mais crítica. Se ADL_all salva, a claim se fortalece muito.

2. **Reescrever a intro com o lead B'+E** — abrir com BG2018 e o post-treatment bias, não com "which controls to include".

3. **Formalizar a unificação BG/IK/Pearl** como proposição ou resultado na Seção 2.

4. **Promover as simulações NL e v4** para seções principais (4 e 5).

5. **Explicitar no paper** que a claim NÃO é "ADL > MSM" mas sim "o post-treatment bias que motiva MSM é pequeno". Antecipar a objeção do reviewer.

6. **Considerar adicionar 1 aplicação empírica** com T curto ou tratamento contínuo para diversificar.

7. **Tratar Cinelli & Hazlett** como complemento simétrico, não como competidor.

---

## 6. O teste de uma frase

Se um reviewer perguntar "qual é a contribuição?", a resposta é:

> "Blackwell & Glynn (2018) showed that ADL models have post-treatment bias. We derive the exact formula for that bias, show it's empirically negligible in the vast majority of TSCS applications in political science, and identify the precise conditions under which it is not."

Se isso não for suficiente para Political Analysis, nada é.

Sources:
- [Blackwell & Glynn (2018)](https://mattblackwell.org/files/papers/causal-tscs.pdf)
