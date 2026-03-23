# IVB Formula under Conditional Parallel Trends — Draft Derivation

**Status**: RASCUNHO
**Data**: 2026-03-22
**Objetivo**: Reescrever a derivação da fórmula IVB em notação de potential outcomes, compatível com o framework de Caetano & Callaway (2024) e a literatura de DID.

---

## 1. Setup em Potential Outcomes

Considere dois períodos: $t^* - 1$ (pré-tratamento) e $t^*$ (pós-tratamento). Cada unidade $i$ tem:

- Tratamento binário: $D_i \in \{0, 1\}$ (ninguém tratado em $t^* - 1$)
- Outcome observado: $Y_{it}$
- Potential outcomes: $Y_{it}(1)$ (se tratado), $Y_{it}(0)$ (se não tratado)
- Covariável time-varying: $Z_{it}$
- $Y_{it^*} = D_i Y_{it^*}(1) + (1-D_i) Y_{it^*}(0)$; $Y_{it^*-1} = Y_{it^*-1}(0)$

Estimando: $ATT = \mathbb{E}[Y_{t^*}(1) - Y_{t^*}(0) | D = 1]$

### Premissa sobre Z

$Z$ é uma covariável time-varying com potential covariates:
- $Z_{it^*}(1)$: valor de Z se a unidade é tratada
- $Z_{it^*}(0)$: valor de Z se a unidade não é tratada
- Em $t^* - 1$: $Z_{it^*-1} = Z_{it^*-1}(0)$ para todos (ninguém tratado)

**Caso geral**: $D$ pode afetar $Z$, i.e., $Z_{it^*}(1) \neq Z_{it^*}(0)$. Isso viola strict exogeneity — o caso dos "bad controls" de Caetano et al. (2022).

A fórmula IVB se aplica **independente** da estrutura causal de Z:
- **Collider** (D → Z ← Y): IVB é viés genuíno (caminho espúrio)
- **Mediador** (D → Z → Y): IVB quantifica o efeito indireto bloqueado (over-control)
- **Confounder** (Z → D, Z → Y): IVB = -OVB (inclusão de Z é correta)
- **Dual role** (collider + confounder): IVB captura o trade-off líquido

---

## 2. TWFE com Z como Covariável

O pesquisador estima:

$$Y_{it} = \alpha_i + \lambda_t + \tau D_{it} + \beta Z_{it} + e_{it} \tag{1}$$

Com 2 períodos, tomando first differences:

$$\Delta Y_{it^*} = \tau D_i + \beta \Delta Z_{it^*} + \Delta e_{it^*} \tag{2}$$

onde $\Delta Y_{it^*} = Y_{it^*} - Y_{it^*-1}$ e $\Delta Z_{it^*} = Z_{it^*} - Z_{it^*-1}$.

O pesquisador espera que $\tau$ capture o ATT. A questão é: o que $\tau$ de fato captura quando $Z$ é um collider?

---

## 3. O Modelo Sem Z (Referência)

A regressão curta (sem Z) é:

$$\Delta Y_{it^*} = \tau_S D_i + \Delta \varepsilon_{it^*} \tag{3}$$

Sob parallel trends incondicional ($\mathbb{E}[\Delta Y_{t^*}(0) | D=1] = \mathbb{E}[\Delta Y_{t^*}(0) | D=0]$), temos:

$$\tau_S = \mathbb{E}[\Delta Y_{t^*} | D=1] - \mathbb{E}[\Delta Y_{t^*} | D=0] = ATT$$

**Nota**: se Z é collider ou mediador, esta é a regressão "correta" para o efeito total. Se Z é confounder, a regressão longa (com Z) é a correta. A fórmula IVB quantifica a diferença entre as duas em todos os casos.

---

## 4. Derivação do IVB via FWL (em first differences)

A equação (2) é uma regressão de $\Delta Y$ em $D$ e $\Delta Z$. Pelo FWL, o coeficiente $\tau$ na regressão longa (2) e $\tau_S$ na curta (3) satisfazem:

$$\tau - \tau_S = -\beta \cdot \frac{\text{Cov}(D, \Delta Z)}{\text{Var}(D)}$$

Definindo a **regressão auxiliar**:

$$\Delta Z_{it^*} = \pi D_i + \eta_{it^*} \tag{4}$$

onde $\pi = \text{Cov}(D, \Delta Z) / \text{Var}(D)$, obtemos:

$$\boxed{IVB = \tau - \tau_S = -\beta \times \pi} \tag{5}$$

**Esta é exatamente a fórmula IVB**, agora derivada no framework de potential outcomes / DID com first differences.

### Interpretação dos componentes

- $\beta$: coeficiente de $\Delta Z$ na regressão longa (2) — mede a associação parcial entre mudanças no collider e mudanças no outcome, controlando por $D$
- $\pi$: coeficiente de $D$ na regressão auxiliar (4) — mede quanto o tratamento afeta a mudança no collider

Ambos são **diretamente estimáveis** dos dados.

---

## 5. A Fórmula IVB como Ferramenta Geral de Sensibilidade

### 5.0 Resultado central: a fórmula é agnóstica à estrutura causal

A fórmula (5) é uma **identidade algébrica de OLS** (via FWL). Ela quantifica:

$$\hat{\tau}_{long} - \hat{\tau}_{short} = -\hat{\beta} \times \hat{\pi}$$

Isso vale **sempre**, para qualquer Z, independente de Z ser collider, mediador, ou confounder. O que muda é a **interpretação causal** do número:

| Estrutura causal de Z | O que $IVB = -\beta \times \pi$ mede | Incluir Z é... |
|---|---|---|
| **Collider** (D → Z ← Y) | Collider bias: caminho espúrio aberto | Errado (IVB é viés genuíno) |
| **Mediador** (D → Z → Y) | Efeito indireto bloqueado (over-control) | Depende: total vs. direto |
| **Confounder** (Z → D, Z → Y) | OVB removido: $IVB = -OVB$ | Correto (IVB é correção) |
| **Dual role** (collider + confounder) | Trade-off líquido: IVB + OVB | Depende da magnitude |

**A fórmula fornece o número. O DAG fornece a interpretação.** Juntos, são uma ferramenta completa de sensibilidade à inclusão/exclusão de covariáveis.

### 5.1 Analogia com Cinelli & Hazlett (2020)

Cinelli & Hazlett (2020) reformularam o OVB em termos de partial $R^2$, criando uma ferramenta de sensibilidade para o caso de **omissão** de variáveis. A fórmula IVB faz o análogo para o caso de **inclusão**:

| | Cinelli & Hazlett (2020) | IVB formula |
|---|---|---|
| Pergunta | "Quanto mudaria $\hat\beta$ se eu **incluísse** um confounder omitido?" | "Quanto muda $\hat\beta$ se eu **incluir/excluir** Z?" |
| Parametrização | Partial $R^2$ (não observável) | $-\theta^* \times \pi$ (diretamente estimável) |
| Aplicação | Sensibilidade a confounders não observados | Diagnóstico para variáveis observadas |
| Requer | Benchmarking com confounders conhecidos | DAG para interpretar o sinal |

A vantagem prática da fórmula IVB sobre Cinelli & Hazlett é que **ambos os componentes são estimáveis diretamente** — o pesquisador não precisa especular sobre confounders não observados.

### 5.2 Quando Z é estritamente exógeno (Cov-Exogeneity)

Se $D$ não afeta $Z$, então $\Delta Z(1) = \Delta Z(0)$, e portanto:

$$\pi = \frac{\text{Cov}(D, \Delta Z)}{\text{Var}(D)} = 0$$

Logo $IVB = 0$. Incluir $Z$ não gera collider bias nem over-control bias. Porém, pode haver hidden linearity bias (Caetano & Callaway 2024) — isso é uma fonte de viés diferente, não capturada pela fórmula IVB.

### 5.3 Quando Z é collider (D → Z ← Y)

Se $D$ afeta $Z$ (e $Y$ também), então $\pi \neq 0$ e geralmente $\beta \neq 0$, produzindo $IVB \neq 0$. A fórmula quantifica o collider bias com dados em mão.

### 5.4 Quando Z é mediador puro (D → Z → Y, sem Y → Z)

Se $D$ causa $Z$ e $Z$ causa $Y$, mas $Y$ não causa $Z$:
- $\pi \neq 0$ (D afeta Z)
- $\beta \neq 0$ (Z afeta Y)
- $IVB = -\beta \times \pi \neq 0$

O IVB aqui mede o **efeito indireto** $D \to Z \to Y$ que está sendo bloqueado pela inclusão de Z. Se o pesquisador quer o efeito **total** de D sobre Y, incluir Z é over-control. A fórmula diz exatamente **quanto** de efeito indireto está sendo perdido.

No framework de Caetano et al. (2022), este é o caso "bad control" mais simples: $D$ afeta $Z$ contemporaneamente, e incluir $Z_{t^*}$ na regressão bloqueia o caminho indireto. A fórmula IVB quantifica a magnitude desse over-control — algo que Caetano et al. diagnosticam mas não quantificam com uma fórmula fechada estimável.

### 5.5 Quando Z é confounder (Z → D, Z → Y)

Se $Z$ causa tanto $D$ quanto $Y$ (fork), incluir $Z$ é **correto** — remove OVB. Neste caso:
- A regressão curta (sem Z) tem OVB
- A regressão longa (com Z) é correta
- $IVB = \tau_{long} - \tau_{short} = -OVB$

A fórmula IVB quantifica **quanto OVB é removido** pela inclusão de Z. O sinal é oposto ao do OVB: se omitir Z viesa para cima, incluí-lo corrige para baixo.

### 5.6 Caso dual (Z é collider E confounder)

Na prática, muitas variáveis são simultaneamente confounders e colliders (especialmente em TSCS, onde lags criam ambas as estruturas). Neste caso:

- Excluir Z: sofre OVB (por ser confounder)
- Incluir Z: sofre IVB (por ser collider)
- A decisão depende de $|OVB|$ vs. $|IVB|$

A fórmula IVB permite ao pesquisador **calcular ambas as quantidades**: o IVB de incluir Z (diretamente) e o OVB de omitir Z (pela fórmula clássica, se possível). Isso é o dual-role trade-off já discutido no paper.

### 5.7 Relação com os termos de viés de Caetano & Callaway (2024)

Na Proposição 1 de Caetano & Callaway (2024), $\alpha$ do TWFE é decomposto em:

$$\alpha = \mathbb{E}[w(\Delta X_{t^*}) ATT(X_{t^*}, X_{t^*-1}, Z) | D=1] + \text{Term (A)} + \text{Term (B)} + \text{Term (C)}$$

- **Term (A)**: viés de ignorar covariáveis time-invariant
- **Term (B)**: paths dependem de níveis, não só mudanças
- **Term (C)**: não-linearidade em $\mathbb{E}[\Delta Y | \Delta X, D=0]$

Caetano & Callaway (2024) assumem strict exogeneity de X (Assumption 3), então $\pi = 0$ e o IVB não aparece na decomposição deles. Quando $D$ afeta $Z$ (violando strict exogeneity), o IVB se **soma** aos termos (A)-(C):

$$\alpha = ATT + IVB + \text{hidden linearity bias terms}$$

onde $IVB = -\beta \times \pi$ captura o bad control bias (collider ou over-control) e os hidden linearity bias terms capturam (A)-(C). A fórmula IVB quantifica o primeiro; os diagnósticos de Caetano & Callaway quantificam os segundos.

---

## 6. Extensão para T > 2 (TSCS)

Com múltiplos períodos, o TWFE:

$$Y_{it} = \alpha_i + \lambda_t + \tau D_{it} + \beta Z_{it} + e_{it}$$

é estimado via within-transformation (double demeaning). Pelo FWL, a mesma álgebra se aplica às variáveis double-demeaned $\ddot{Y}$, $\ddot{D}$, $\ddot{Z}$:

$$IVB = \tau^{long} - \tau^{short} = -\theta^* \times \pi$$

onde $\theta^*$ e $\pi$ são os coeficientes double-demeaned. Isso é exatamente o Corollary 1 (IVB under TWFE) já no paper.

### ADL como solução

No setting TSCS com dinâmica, o modelo correto é o ADL:

$$Y_{it} = \alpha_i + \lambda_t + \beta D_{it} + \rho Y_{i,t-1} + \delta D_{i,t-1} + e_{it}$$

Se o pesquisador adiciona $Z_{i,t-1}$ (defasado, como é prática em TSCS), a fórmula IVB se aplica com $\pi$ agora refletindo a associação within-unit, condicional nos lags.

**Resultado das simulações**: o ADL completo ($Y \sim D + D_{lag} + Y_{lag} + Z_{lag} | FE$) tem viés < 3% do efeito verdadeiro em todos os 170 cenários testados. Isso porque condicionar em $\{Y_{t-1}, Z_{t-1}\}$ bloqueia todos os backdoor paths por d-separation (argumento do "firewall").

---

## 7. Em Termos de Potential Outcomes: Por Que o ADL Funciona

No framework de potential outcomes, o ADL condiciona em $Y_{i,t-1}$ e $Z_{i,t-1}$. Note que:

- $Y_{i,t-1}$ e $Z_{i,t-1}$ são valores **pré-tratamento** para o efeito contemporâneo de $D_t$
- Sob sequential exogeneity (Assumption 4 de BG 2018): $Y_t(d) \perp D_t | Y_{t-1}, Z_{t-1}, \alpha_i$
- Condicionar em $Y_{t-1}$ e $Z_{t-1}$ bloqueia todos os backdoor paths, incluindo os que passam pelo collider

Em termos de potential outcomes: o ATT condicional em $(Y_{t-1}, Z_{t-1})$ é identificado, e o IVB do collider é absorvido pelo condicionamento.

Isso é diferente do caso DID puro (2 períodos), onde $Z_{t-1}$ pode não estar disponível ou não ser suficiente para bloquear todos os paths.

---

## 8. Resumo da Contribuição

### A fórmula IVB como diagnóstico unificado

| Pergunta do pesquisador | Fórmula | O que usar para interpretar |
|---|---|---|
| "Quanto viés de collider estou introduzindo?" | $IVB = -\theta^* \times \pi$ | DAG mostra Z como collider |
| "Quanto efeito indireto estou bloqueando?" | $IVB = -\theta^* \times \pi$ (= efeito indireto) | DAG mostra Z como mediador |
| "Quanto OVB estou removendo?" | $IVB = -\theta^* \times \pi$ (= -OVB) | DAG mostra Z como confounder |
| "Qual o trade-off líquido?" | $IVB = -\theta^* \times \pi$ (= -OVB + collider bias) | DAG mostra Z dual role |

### Por framework de identificação

| Framework | Problema | Diagnóstico | Solução |
|---|---|---|---|
| Cross-section | Inclusão de collider/mediador/confounder | Fórmula $IVB = -\beta^*_2 \times \phi_1$ | DAG + decisão informada |
| DID (2+ períodos, TWFE) | Bad controls contemporâneos | Fórmula $IVB = -\beta \times \pi$ | Excluir Z, ou métodos DR/AIPW (Caetano et al.) |
| TSCS (ADL + FE) | Bad controls defasados (collider) | Mesma fórmula | ADL completo bloqueia collider paths |

A fórmula IVB é **agnóstica ao framework de identificação** — é uma identidade algébrica de OLS/FWL que vale em cross-section, DID e TSCS. O que muda é:
- A **interpretação** (determinada pelo DAG)
- A **solução disponível** (determinada pelo setting)

---

## Notas para implementação no paper

1. **Seção 4 (IVB formula)**: após a derivação cross-section, adicionar uma Remark ou subsection mostrando que a fórmula se aplica a colliders, mediadores e confounders — a diferença é a interpretação via DAG.

2. **Seção 2 (Control Variable Problem)**: adicionar referências a Caetano & Callaway (2024), Lin & Zhang (2022). Motivar o problema como "TWFE com covariáveis time-varying é reconhecidamente problemático — nós fornecemos um diagnóstico quantitativo."

3. **Nova subsection ou Remark**: "IVB como ferramenta de sensibilidade" — analogia com Cinelli & Hazlett (2020) para OVB. IVB faz o complementar para inclusão.

4. **Tabela OVB vs IVB (já existente)**: expandir para incluir o caso mediador e o caso dual role.

5. **Seção de aplicações empíricas**: reinterpretar — para cada controle, o DAG determina se o IVB calculado é viés (collider), over-control (mediador), ou correção legítima (confounder). A fórmula é a mesma; a interpretação muda.

6. **Potential outcomes derivation**: pode ir como Appendix ou como Remark, conectando a fórmula ao framework de DID para dialogar com o público de economia.
