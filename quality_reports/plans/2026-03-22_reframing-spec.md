# Spec: Reframing do IVB Paper — v2

**Status**: APPROVED
**Data**: 2026-03-22
**Target journal**: Political Analysis

---

## Título

"Included Variable Bias: Clarifying and Quantifying Time-Varying Bad Controls in TSCS and DID"

---

## Problema que o paper resolve

A heurística "não inclua bad controls" é insuficientemente clara sobre QUANDO algo é bad control numa situação específica. Pesquisadores de CP/RI rotineiramente incluem covariáveis time-varying em painéis (TWFE, ADL) sem saber se essas covariáveis são confounders (inclusão correta), colliders (inclusão abre caminho espúrio), mediadores (inclusão bloqueia efeito indireto), ou combinações dessas categorias (dual role). A literatura recente de DID (Caetano & Callaway 2024, Lin & Zhang 2022) identifica problemas com covariáveis time-varying em TWFE, mas assume strict exogeneity (D não afeta X) — não aborda bad controls. O companion paper de Caetano et al. sobre bad controls ainda é work in progress sem draft público.

O paper preenche esse gap com três contribuições:
1. Uma fórmula fechada (IVB = -θ*×π) que quantifica o viés de incluir qualquer variável, com quantidades diretamente estimáveis
2. DAGs que permitem ao pesquisador classificar a variável e interpretar o número da fórmula
3. O resultado de que o ADL — já recomendado na literatura de TSCS — resolve o collider bias por d-separation e evita over-control contemporâneo por construção (usa lags)

---

## Contribuições detalhadas

### 1. Fórmula IVB = -θ*×π como diagnóstico de bad controls

- Identidade algébrica de OLS (via FWL) que vale em cross-section, DID e TSCS
- Quantifica a diferença entre regressão com e sem Z: τ_long - τ_short = -θ*×π
- Ambos os componentes são diretamente estimáveis dos dados
- A interpretação depende da estrutura causal (DAG):
  - Collider (D→Z←Y): IVB é viés genuíno (caminho espúrio)
  - Mediador contemporâneo (D→Z→Y): IVB mede efeito indireto bloqueado (over-control) — é problema de identificação quando o estimando é efeito total, pois Z(1)≠Z(0) para tratados vs. controles
  - Dual role (collider + confounder): IVB captura trade-off líquido
  - Confounder puro (Z→D, Z→Y): IVB = -OVB (inclusão é correta) — footnote para completude

### 2. Ponte entre literaturas DID e TSCS

- DID/TWFE (Caetano et al.): identifica problemas com covariáveis, propõe AIPW/DR. Não usa ADL.
- TSCS/ADL (BG 2018, Imai & Kim 2019): recomenda ADL por identificação. Não pensa em termos de bad controls.
- IVB paper conecta: a fórmula quantifica o que Caetano et al. diagnosticam qualitativamente; o ADL resolve o que a literatura DID ainda busca resolver com métodos mais complexos.

### 3. ADL como solução em TSCS

- Resolve collider bias por d-separation: condicionar em {Y_t, Z_t} bloqueia TODOS os backdoor paths (argumento do "firewall"). Resultado estrutural, não paramétrico.
- Evita over-control contemporâneo por timing: usa Z_{t-1} (pré-tratamento para D_t), não Z_t (pós-tratamento).
- Verificado em 170+ cenários MC incluindo não-linearidade (power1.5, interactions), feedback, carryover, binary D. Viés < 3% de β em todos os cenários.

### 4. Quantificação do over-control para mediadores contemporâneos

- Quando D afeta Z contemporaneamente (D→Z→Y) e pesquisador inclui Z no TWFE: over-control bias
- Em PO: unidades tratadas têm Z(1), controles têm Z(0). TWFE condiciona em Z observado, que é Z(1) para tratados e Z(0) para controles — assimetria que contamina τ
- Fórmula IVB quantifica a magnitude: -θ*×π = efeito indireto bloqueado
- Caetano et al. (2022) diagnosticam esse problema mas não fornecem fórmula fechada estimável

### 5. Aplicações empíricas com classificação via DAG

- 3-4 estudos no corpo principal, cada um ilustrando caso diferente (collider, mediador, dual role)
- Restante em Online Appendix
- Para cada controle: DAG justificado pela literatura → classificação → fórmula IVB → interpretação
- Transparência sobre incerteza na classificação: discutir classificações alternativas e como mudariam a interpretação

---

## Estrutura do paper (ordem de escrita)

### Seção 2: The Control Variable Problem

**O que muda**: adicionar motivação com bad controls em TSCS/DID.

**Conteúdo**:
- Heurísticas de seleção de controles (control checking, confounding checking) — já existe
- Gap: heurísticas não dizem quando algo é bad control. "Não inclua bad controls" é vazio se o pesquisador não sabe identificar bad controls no seu setting. Isto não é um problema resolvido — Cinelli & Pearl (2022) mostram que mesmo textos canônicos (Angrist & Pischke 2008) são insuficientemente claros sobre bad controls.
- Novo: referenciar que TWFE com covariáveis time-varying é reconhecidamente problemático (Caetano & Callaway 2024, Lin & Zhang 2022). Mas esses papers assumem strict exogeneity — não tratam o caso bad control.
- Quantification gap: DAGs dizem SE uma variável é bad control, mas não QUANTO viés resulta. Prior work (Greenland 2003, Ding & Miratrix 2015, Pearl 2013) parametriza em coeficientes estruturais não observáveis. A fórmula IVB preenche esse gap com quantidades estimáveis.

### Seção 3: DAGs and Variable Inclusion

**O que muda**: expandir de "collider bias" para "collider, mediador contemporâneo, dual role".

**Conteúdo**:
- Preliminares de DAGs (chain, fork, collider) — já existe
- Running example: Political Change → Civil War com controles — já existe
- **Expandir**: mostrar que no TSCS, a mesma variável pode ser:
  - Collider quando defasada: D_{t-1} → Z_{t-1} ← Y_{t-1}
  - Mediador quando contemporânea: D_t → Z_t → Y_t
  - Dual role: Z_{t-1} é confounder de Y_t (via Z_{t-1} → Y_t) E collider (D_{t-1} → Z_{t-1} ← Y_{t-1})
- DAGs para cada caso com figuras TikZ
- Foreign collider bias — já existe, manter

### Seção 4: The IVB Formula

**O que muda**: adicionar Remarks sobre generalidade e caso mediador.

**Conteúdo**:
- Cross-section derivation — já existe
- OVB vs IVB table — já existe, expandir com caso mediador e dual role
- TWFE extension — já existe
- ADL extension (FWL) — já existe
- ADL(p,q) generalization — já existe
- Nickell bias interaction — já existe
- Lag substitution — já existe
- Practical recipe — já existe, atualizar
- **NOVO Remark**: "A fórmula IVB é uma identidade algébrica de OLS. Ela quantifica a diferença entre regressão com e sem Z independente da estrutura causal de Z. O que muda é a interpretação: collider → viés genuíno; mediador → over-control (efeito indireto bloqueado, problema de identificação quando estimando é efeito total); confounder → correção legítima (-OVB, footnote). A fórmula fornece o número; o DAG fornece a interpretação."
- **NOVO Remark**: Cinelli & Hazlett (2020) como contexto (2-3 frases, não tabela). "Assim como Cinelli & Hazlett (2020) reformularam OVB como ferramenta de sensibilidade para omissão de variáveis, a fórmula IVB pode ser vista como ferramenta de sensibilidade para inclusão. A vantagem é que ambos os componentes (θ* e π) são diretamente estimáveis."

### Seção 5: When Does the IVB Matter?

**O que muda**: reestruturar completamente. Dividir em analítico (linear) e MC (não-linear).

**5.1 Linear case: derivações analíticas (pedagógico, hook)**

Motivação: sob linearidade, a fórmula IVB é exata — não precisa de simulação. Derivar analiticamente para cada caso:
- Collider linear: IVB exato, tamanho determinado por γ_D, γ_Y, θ
- Mediador contemporâneo linear: IVB = efeito indireto bloqueado
- Dual role linear: IVB = trade-off collider bias vs. OVB removido
- FE absorvem between-unit variation → reduzem π → reduzem IVB

Valor pedagógico: começar pelo caso simples, construir intuição antes do caso NL.

**5.2 Nonlinear case: d-separation + MC verification**

Motivação: DAG é não-paramétrico, fórmula IVB é paramétrica linear. Gap entre os dois frameworks precisa de verificação empírica sob não-linearidade.

**Proposição formal (firewall)**:
"Proposition: Under the DAG in Figure X, conditioning on {Y_t, Z_t, α_i} blocks all backdoor paths from D_{t+1} to Y_{t+1}, regardless of the functional form of the Z equation."
Proof sketch via d-separation rules (enumerar caminhos, mostrar bloqueio).

**Simulações MC** para verificar quantitativamente:

| Caso | Existe? | Ação |
|---|---|---|
| Collider NL (power1.5, interaction, etc.) | Sim, 170 cenários | Manter, reinterpretar |
| Over-control contemporâneo NL | NÃO | **Criar e rodar ANTES de escrever** |
| Dual role NL | NÃO | **Criar e rodar ANTES de escrever** |

Resultado esperado: viés residual < 3% de β confirma previsão de d-separation.

**5.3 ADL como solução em TSCS**

- Resolve collider: d-separation (firewall) — proposição formal
- Evita over-control contemporâneo: usa Z_{t-1}, não Z_t — feature de timing
- Precisão: "ADL resolve collider por d-separation; evita over-control por construção (timing dos lags)"
- Nota: se Z_{t-1} media efeito defasado D_{t-1} → Z_{t-1} → Y_t, incluir Z_{t-1} bloqueia esse caminho. Mas no ADL completo com D_{t-1} explícito, o efeito de D_{t-1} é capturado diretamente.
- Simulações confirmam: viés < 3% em todos os 170 cenários.

### Seção 6: Applications

**O que muda**: reduzir para 3-4 no corpo, restante em Online Appendix. Reclassificar via DAG expandido.

**Conteúdo por aplicação**:
1. DAG completo (com figuras) justificado pela literatura publicada
2. Classificação de cada controle: collider / mediador / dual role / confounder
3. Cálculo do IVB: θ* e π
4. Interpretação: o que o IVB significa dado a classificação
5. Discussão de classificações alternativas e como mudariam a interpretação
6. Seleção: um exemplo claro de collider, um de mediador/over-control, um de dual role

### Seção 7: Conclusion

**Conteúdo**:
- Resumo das contribuições
- Recomendações para practitioners:
  1. Use DAGs para classificar controles candidatos
  2. Calcule IVB para quantificar consequências da inclusão/exclusão
  3. Em TSCS, use ADL completo — protege contra collider bias e evita over-control
- **Limitações explícitas** (1-2 parágrafos):
  - Fórmula IVB é linear (FWL). Não se aplica diretamente a logit, probit, Cox. LPM como aproximação.
  - Fórmula assume que outros controles são legítimos. Com múltiplos bad controls, IVB de cada um é condicional nos demais.
  - Classificação via DAG é subjetiva e baseada em conhecimento substantivo.

### Seção 1: Introduction (penúltimo a escrever)

**Elementos**:
- Hook: pesquisadores incluem controles time-varying em painéis rotineiramente, mas não sabem se estão ajudando ou atrapalhando
- Problem: "não inclua bad controls" é insuficientemente claro. Ninguém sabe o que é bad control no seu setting específico.
- Gap: DAGs dizem se é bad control; nenhuma fórmula estimável diz quanto viés resulta. Literatura DID (Caetano & Callaway 2024) identifica problemas com covariáveis em TWFE mas assume strict exogeneity.
- Contribution: fórmula IVB = -θ*×π (diagnóstico estimável) + DAGs (interpretação) + ADL resolve em TSCS
- Elevator pitch: "Derivamos uma fórmula fechada que quantifica o viés de incluir bad controls em regressões de painel. A fórmula usa quantidades já estimadas pelo pesquisador. Combinada com DAGs, permite diagnosticar se inclusão de um controle melhora ou piora a estimativa e em quanto. Mostramos que o ADL resolve o problema no setting TSCS."

### Abstract (último a escrever)

Após todo o paper estar escrito. ~200 palavras.

### Appendix A: Derivação em Potential Outcomes

**Conteúdo** (baseado em derivations/ivb_potential_outcomes.md, com melhorias):

- Setup em PO: Y(1), Y(0), Z(1), Z(0), ATT
- **Formalização da assimetria Z(1) vs. Z(0)**: TWFE com Z contemporâneo condiciona em Z(1) para tratados e Z(0) para controles. Quando D afeta Z, Z(1)≠Z(0), e isso contamina τ. Mostrar formalmente.
- Derivação do IVB via FWL em first differences: mesma álgebra, notação PO
- **Caso critical: conditional PT com bad control**: PT vale apenas condicional em Z, mas Z é bad control. Excluir Z viola PT; incluir Z gera IVB. A fórmula quantifica um lado do dilema. Formalizar.
- Conexão com decomposição de Caetano & Callaway (2024): IVB se soma aos hidden linearity bias terms (A)-(B)-(C) quando strict exogeneity é violada
- Por que o ADL funciona em PO: sequential exogeneity (BG 2018), condicionar em (Y_{t-1}, Z_{t-1}) → pré-tratamento para CET

**Foco do Appendix PO**: não é "mesma coisa com notação diferente" — a notação PO revela:
1. A assimetria Z(1)≠Z(0) que a notação estrutural esconde
2. O dilema conditional PT + bad control
3. A conexão formal com a decomposição de Caetano & Callaway

### Appendix B: Full simulation results

Todas as tabelas e figuras das 170+ simulações existentes + novas (over-control NL, dual role NL).

---

## Posicionamento vs. literatura

| Paper | Relação | Como citar |
|---|---|---|
| BG (2018) | Complementar. β₁ consistente no ADL (p.1073) como resultado secundário. Não quantificaram viés de TWFE nem conectaram com bad controls. | "BG showed β₁ is consistent in ADL under linearity. We provide a formula to quantify the bias when TWFE is used instead, and show via d-separation why ADL works." |
| Caetano & Callaway (2024) | Complementar. Hidden linearity bias em TWFE com covariáveis. Assumem strict exogeneity. | "Caetano & Callaway identify additional biases in TWFE with covariates under strict exogeneity. When strict exogeneity fails (bad controls), the IVB formula quantifies the additional bias." |
| Caetano et al. (bad controls) | Complementar. Work in progress. | Citar como forthcoming se possível, senão referenciar Caetano et al. (2022) original. |
| Lin & Zhang (2022) | Tangencial. Covariate effect bias (efeitos time-varying de covariáveis). | Citação na Seção 2 como evidência adicional de que TWFE com covariáveis é problemático. |
| Imai & Kim (2019) | Complementar. Strict exogeneity, ADL+FE como solução paramétrica. | "Imai & Kim showed TWFE is not identified under causal dynamics. ADL+FE solves identification; our formula shows it also solves bad control bias." |
| Cinelli & Hazlett (2020) | Contexto. OVB sensitivity via partial R². | Remark de 2-3 frases: "analogous sensitivity tool for inclusion rather than omission." |
| Cinelli & Pearl (2022) | Contexto. Crash course on bad controls. | Citação na Seção 2: ilustra que bad controls são mal entendidos mesmo em textos canônicos. |
| Angrist & Pischke (2008) | Background. "Don't include bad controls." | "The standard recommendation is to exclude bad controls. But this presupposes that the researcher can identify bad controls in their specific setting — which is precisely the gap our paper fills." |

---

## Simulações: status e ações

| Simulação | Status | Ação |
|---|---|---|
| Collider linear (v1, v4) | DONE | Manter, reinterpretar narrativa |
| Collider NL (power1.5, interact, carryover) | DONE | Manter |
| Feedback Y→D | DONE | Manter |
| Binary D (mechC_adl) | DONE | Manter |
| **Over-control contemporâneo NL** | NÃO EXISTE | **Criar DGP e rodar ANTES da escrita** |
| **Dual role NL** | NÃO EXISTE | **Criar DGP e rodar ANTES da escrita** |

**DECISÃO**: não escrever Seção 5.2 até ter resultados das simulações novas. Se resultados forem problemáticos, ajustar escopo.

---

## Ordem de trabalho

1. **Rodar simulações novas** (over-control NL, dual role NL) — pré-requisito
2. Seção 3 (DAGs expandidos — collider, mediador, dual role)
3. Seção 4 (IVB formula + Remarks de generalidade)
4. Seção 5 (analítico + proposição firewall + MC reinterpretado + sims novas)
5. Seção 2 (Control Variable Problem — revisão com referências novas)
6. Seção 6 (Applications — reclassificar via DAG, selecionar 3-4 para corpo)
7. Seção 7 (Conclusion — com limitações)
8. Appendix A (PO derivation — com Z(1)≠Z(0) e conditional PT)
9. Appendix B (Full sim results)
10. Seção 1 (Introduction)
11. Abstract

---

## Riscos e mitigações

| Risco | Mitigação |
|---|---|
| Simulações novas dão resultado ruim | Rodar ANTES de se comprometer. Se NL over-control/dual role não funciona, ajustar escopo. |
| Referee: "isso é só FWL, trivial" | A contribuição é a interpretação unificada via DAG + operacionalização para bad controls. Mesma lógica de Cinelli & Hazlett para OVB. |
| Referee: "por que quantificar se a recomendação é não incluir?" | A heurística "não inclua" é vazia se o pesquisador não sabe identificar bad controls no seu setting. Na prática, classificar é incerto, muitas variáveis são dual role, e a fórmula permite quantificar consequências antes de decidir. |
| Referee: "over-control é estimando, não identificação" | Formalizar via PO: quando estimando é efeito total, over-control viesa. TWFE condiciona em Z(1) para tratados e Z(0) para controles — assimetria que contamina τ. É problema de identificação. |
| Espaço PA (~12k palavras) | 3-4 aplicações no corpo, restante em Online Appendix. Caso linear como hook breve, não seção longa. |
| Argumento firewall parece empírico | Proposição formal com proof sketch via d-separation. |
