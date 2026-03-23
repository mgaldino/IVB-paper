# Spec: Reframing do IVB Paper — v3.0

**Status**: DRAFT  
**Data**: 2026-03-22  
**Supersedes**: `2026-03-22_reframing-spec-v2.md`  
**Target journal**: Political Analysis

---

## Q&A inicial

**Q1. Qual é o recorte estratégico do paper?**  
**A:** O paper deve ser escrito como um artigo sobre **bad controls observados em painéis TSCS quando o estimando é o contemporaneous treatment effect (CET)**.

**Q2. Qual é a recomendação prática central?**  
**A:** Para esse problema, o benchmark aplicado é **ADL + FE com estados defasados**, usando covariáveis lagged quando substantivamente apropriado, e evitando condicionar em `Z_t` contemporâneo quando `Z_t` pode ser pós-tratamento.

**Q3. O paper vai vender extensão para `SCM`, `SDiD` ou `factor models`?**  
**A:** Não. Pode mencionar como agenda futura, mas não como contribuição atual.

**Q4. O paper continua dialogando com DID?**  
**A:** Sim, mas **DID entra como motivação e literatura adjacente**, não como domínio simétrico do resultado positivo.

---

## Decisão estratégica

O paper não deve ser vendido como:

- solução geral para qualquer estimador de painel causal;
- solução geral para DID, SCM, SDiD e factor models;
- substituto para IPW, DR, AIPW ou outros estimadores robustos.

O paper deve ser vendido como:

1. um **diagnóstico estimável** para decisões de inclusão de covariáveis observadas (`IVB = -theta* x pi`);
2. uma **regra prática citável** para pesquisadores aplicados interessados em `CET` em painéis TSCS:
   - usar `ADL + FE` como benchmark;
   - usar estados lagged;
   - evitar `Z_t` contemporâneo quando `Z_t` pode ser pós-tratamento;
3. uma ponte com a literatura de DID no sentido de mostrar que o problema é real e compartilhado, mas que no setting TSCS existe uma solução mais simples sob condições explícitas.

---

## Tese central

### Versão longa

Pesquisadores aplicados frequentemente precisam decidir se incluem covariáveis time-varying em regressões de painel. Essa decisão é especialmente difícil quando o estimando é o **efeito contemporâneo do tratamento**, porque a mesma covariável pode funcionar como confounder, collider ou mediador dependendo do timing. O paper oferece duas contribuições complementares:

1. uma fórmula fechada e diretamente estimável que quantifica a mudança induzida pela inclusão da covariável;
2. um benchmark simples para TSCS: para o `CET`, usar `ADL + FE` com estados lagged e evitar controles contemporâneos pós-tratamento.

### Elevator pitch

> We show that applied researchers interested in the contemporaneous treatment effect in TSCS settings should treat `ADL + FE` with lagged state variables as the benchmark specification. The IVB formula quantifies the cost of conditioning on observed covariates, while DAGs determine whether that cost reflects collider bias, over-control, or correction of omitted confounding.

---

## O que o paper entrega ao pesquisador aplicado

### Produto intelectual principal

O paper dá ao pesquisador:

1. uma forma de **classificar** controles candidatos com DAGs;
2. uma forma de **quantificar** a consequência da inclusão/exclusão;
3. uma forma de **especificar um benchmark prático** para o caso relevante de TSCS com `CET`.

### Regra prática citável

Formulação recomendada:

> When the estimand is the contemporaneous treatment effect in TSCS settings with observed time-varying covariates, researchers should use `ADL + FE` with lagged state variables as the benchmark specification and avoid conditioning on contemporaneous covariates that may be post-treatment in the period of interest.

### Qualificação essencial

Essa regra é:

- **relativa ao efeito contemporâneo** de `D_t` sobre `Y_t`;
- não uma afirmação de que `Z_{t-1}` é “sempre seguro” em sentido absoluto;
- não uma solução geral para efeitos defasados, cumulativos ou de longo prazo.

---

## Escopo substantivo e metodológico

### Dentro do escopo

- TSCS com dinâmica observável;
- estimando principal: `CET`;
- covariáveis observadas time-varying;
- casos de collider, dual role e mediador contemporâneo;
- benchmark paramétrico via `ADL + FE`.

### Fora do escopo principal

- `SCM`, `SDiD`, `factor models`;
- solução universal para DID;
- estimandos dinâmicos acumulados ou de longo prazo;
- comparação abrangente com todos os estimadores robustos da literatura.

### Como mencionar o que fica fora

Uma frase basta:

> Extending the timing logic developed here to synthetic-control-style and interactive fixed-effects estimators is an important agenda for future work.

---

## Relação com a literatura

### Caetano et al. / literatura DID

Posicionamento correto:

- essa literatura mostra que a dificuldade é real e compartilhada;
- o paper não a invalida;
- o paper mostra que, **no setting TSCS com `CET`**, existe um benchmark mais simples e mais imediatamente utilizável por pesquisadores aplicados.

Formulação recomendada:

> Recent work in DID shows that time-varying covariates create difficult identification and specification problems. Our contribution is not to replace those methods in general, but to show that in TSCS settings focused on the contemporaneous treatment effect, a dynamic benchmark based on `ADL + FE` and lagged covariates already resolves an important subset of those problems.

### BG / Imai & Kim

Tom:

- complementar, não adversarial;
- “eles já apontavam para a importância da dinâmica; nós mostramos o que isso compra no problema de bad controls observados”.

### Cinelli & Hazlett

Usar só como contexto:

- analogia com ferramenta de sensibilidade para omissão;
- aqui o foco é inclusão de covariáveis observadas.

Não fazer disso headline.

---

## Evidência já disponível

### Collider / dual role

Continuam centrais para o argumento TSCS:

- `quality_reports/dual_role_z_simulation_report.md`
- `quality_reports/nl_simulation_report.md`

### Mediador / over-control

Usar como base oficial:

- `quality_reports/overcontrol_unified_report.md`

Essa síntese permite comunicar:

1. incluir `Z_t` contemporâneo desloca a estimativa na direção do efeito direto;
2. `Z_{t-1}` não gera over-control para o `CET`;
3. se `Z_{t-1}` também for confounder, ele pode remover OVB sem bloquear o caminho contemporâneo `D_t -> Z_t -> Y_t`.

### Implicação de escrita

Para a seção empírica/simulada sobre mediador, o contraste correto é:

- `ADL total`
- `ADL bad`
- `ADL safe`

Não usar `TWFE short` como benchmark causal limpo.

---

## Estrutura proposta do paper

### Seção 1: Introduction

Objetivo:

- abrir com a dificuldade aplicada;
- prometer uma regra prática e um diagnóstico estimável;
- deixar claro que o foco é `CET` em TSCS.

Elementos:

1. pesquisadores aplicados usam covariáveis time-varying sem saber quando ajudam ou atrapalham;
2. a dificuldade é reconhecida na literatura recente;
3. o paper oferece uma solução prática para um caso central: `CET` em painéis TSCS;
4. `IVB + DAG + ADL benchmark`.

### Seção 2: The Control Variable Problem

Revisão curta do problema:

- heurísticas tradicionais são insuficientes;
- o problema é de timing e papel causal da covariável;
- a pergunta aplicada é “incluo ou não incluo `Z_t`?”.

### Seção 3: DAGs and Timing

Focar em timing:

- collider;
- mediador contemporâneo;
- dual role.

Objetivo:

- mostrar que a mesma variável muda de papel conforme o índice temporal;
- ancorar a lógica de `Z_t` versus `Z_{t-1}`.

### Seção 4: The IVB Formula

Papel da seção:

- a fórmula é a ferramenta diagnóstica;
- o DAG dá a interpretação.

O que manter:

- derivação;
- remark sobre generalidade;
- confounder como benchmark interpretativo, não como seção autônoma.

### Seção 5: Benchmarking Dynamic Specifications for the CET

Esta deve ser a seção central do paper.

Subseções recomendadas:

#### 5.1 Collider and dual-role controls in TSCS

- usar as simulações existentes para mostrar o ganho de `ADL + FE`;
- enfatizar o papel da dinâmica e do timing.

#### 5.2 Over-control with contemporaneous mediators

- usar `quality_reports/overcontrol_unified_report.md`;
- contraste `ADL total` vs `ADL bad` vs `ADL safe`;
- deixar claro que `Z_{t-1}` é pré-tratamento para o `CET`.

#### 5.3 Practical benchmark

Fechar com a recomendação operacional:

- para `CET`, comece com `ADL + FE`;
- use estados lagged;
- trate `Z_t` contemporâneo como potencial bad control até que o DAG prove o contrário.

### Seção 6: Applications

As aplicações devem servir a um propósito prático:

- ilustrar como um pesquisador realmente toma a decisão sobre controles;
- menos “catálogo de estudos”;
- mais “como aplicar o benchmark e interpretar IVB”.

Se não houver caso limpo de mediador no main text, manter mediador em simulação e deixar aplicações empíricas focadas em collider/dual role.

### Seção 7: Conclusion

Encerrar com:

1. regra prática;
2. limites explícitos;
3. agenda futura fora do escopo (`SCM/SDiD/factor models`).

---

## O que cortar ou desinflar

### Cortar

- promessas de solução geral para DID;
- qualquer frase que soe como “isto substitui Caetano et al.”;
- qualquer extensão afirmada para `SCM`, `SDiD` ou `factor models`.

### Desinflar

- “ADL resolve o problema” sem qualificador;
- “bad controls em TSCS e DID” como se a parte positiva fosse simétrica.

### Substituir por

- “Em TSCS com foco no `CET`, `ADL + FE` fornece um benchmark simples e defensável.”

---

## Título

### Opção A: mais precisa para o recorte atual

**Included Variable Bias: Diagnosing Bad Controls and Benchmarking Dynamic Panel Specifications for the Contemporaneous Treatment Effect**

### Opção B: mantém o bridge sem superprometer

**Included Variable Bias: Clarifying Time-Varying Bad Controls in TSCS and Related Panel Designs**

### Opção C: mais aplicada

**Bad Controls in Dynamic Panels: A Diagnostic Formula and a Benchmark Specification for the Contemporaneous Treatment Effect**

Recomendação:

- usar uma opção centrada em `dynamic panels` e `CET`;
- evitar um título que sugira prova direta para todos os estimadores de painel causal.

---

## Abstract: linha mestra

O abstract deve dizer explicitamente:

1. qual é a dificuldade aplicada;
2. qual é o estimando-alvo (`CET`);
3. qual é a recomendação prática;
4. qual é o papel da fórmula IVB;
5. que a evidência é TSCS-focused.

Formulação-alvo:

> We study a practical problem in time-series cross-sectional research: whether observed time-varying covariates should be included when the estimand is the contemporaneous treatment effect. We derive a closed-form included-variable-bias diagnostic, show how DAGs determine its causal interpretation, and demonstrate that in TSCS settings a benchmark `ADL + FE` specification with lagged state variables avoids conditioning on contemporaneous post-treatment covariates. Simulations covering collider, dual-role, and mediator cases show that this benchmark sharply reduces bias while preserving the contemporaneous total effect when covariates are lagged rather than contemporaneous.

---

## Riscos e mitigação

| Risco | Mitigação |
|---|---|
| Referee: “isso é só FWL” | O paper não vende a álgebra isoladamente; vende um diagnóstico operacional + benchmark aplicado para CET em TSCS. |
| Referee: “isso não vale para DID em geral” | Concordar explicitamente. DID entra como motivação; a solução positiva é TSCS-focused. |
| Referee: “ADL + FE também pode falhar” | Dizer isso de forma frontal: o resultado é condicionado ao DAG, ao timing e ao estimando contemporâneo. |
| Referee: “Z_{t-1} também pode ser pós-tratamento” | Antecipar a resposta: relativo a `D_t -> Y_t`, `Z_{t-1}` é pré-tratamento; isso não implica inocuidade para efeitos dinâmicos de longo prazo. |
| Escopo ainda amplo | Manter a seção prática centrada em `CET`, TSCS e controles observados. |

---

## Ordem de trabalho revisada

1. Atualizar a spec do paper com este recorte.
2. Reescrever introdução e abstract nesse framing.
3. Reorganizar a Seção 5 em torno de `benchmark for CET`.
4. Integrar `quality_reports/overcontrol_unified_report.md` na narrativa.
5. Rever o título para refletir o recorte TSCS/CET.
6. Só depois decidir o que mencionar da literatura DID no abstract e na conclusão.
