# Spec: Reframing do IVB Paper — v2.1

**Status**: DRAFT (atualizado com feedback do fresh agent + verificação de sims)
**Data**: 2026-03-22
**Supersedes**: 2026-03-22_reframing-spec.md (v2.0)
**Target journal**: Political Analysis

---

## Mudanças em relação à v2.0

1. **Headline clarificado**: UM headline — bad controls em TSCS/DID. A fórmula é a ferramenta, não o headline.
2. **Dual role NL: JÁ EXISTE** — sim_nl_collider.R tem gamma_D=0.15 + gamma_Y=0.2 (confounder) + delta_D + delta_Y (collider) + NL. Spec v2.0 estava errado.
3. **ADL claim qualificado**: "sob o DAG especificado" + proposição formal, não universal.
4. **IVB = efeito indireto**: explicitado que vale exatamente só sob linearidade.
5. **Aplicações**: não prometer tipos que não temos. Verificar antes.
6. **PO appendix**: fundamento conceitual referenciado no texto, não ponte passiva.
7. **Referências pendentes**: Caetano & Callaway (2024), Caetano et al. (2022) precisam entrar em references.bib ANTES da escrita.

---

## Headline único

O paper é sobre **bad controls em TSCS e DID**. A heurística "não inclua bad controls" é insuficientemente clara sobre QUANDO algo é bad control numa situação específica. O paper fornece:
1. DAGs para classificar (collider, mediador, dual role)
2. Fórmula IVB = -θ*×π para quantificar
3. ADL como solução no setting TSCS (sob condições formais)

A fórmula é a **ferramenta**; bad controls é o **problema**; o headline é o problema.

---

## Título

"Included Variable Bias: Clarifying and Quantifying Time-Varying Bad Controls in TSCS and DID"

---

## Contribuições detalhadas

### 1. Fórmula IVB = -θ*×π como diagnóstico de bad controls

- Identidade algébrica de OLS (via FWL): quantifica τ_long - τ_short
- Vale em cross-section, DID (first differences) e TSCS (within-transformation, ADL)
- Interpretação depende do DAG:
  - Collider: IVB é viés genuíno
  - Mediador contemporâneo: IVB mede efeito indireto bloqueado (over-control)
  - Dual role: trade-off líquido
  - Confounder puro: IVB = -OVB (footnote)
- **IVB = efeito indireto é exato sob linearidade.** Sob não-linearidade, IVB é a diferença entre projeções lineares — interpretação guiada por DAG + verificação numérica, não identidade causal geral.
- **Escopo**: a fórmula se aplica a qualquer variável incluída; o caso confounder aparece como benchmark interpretativo. O objeto científico do paper são bad controls (collider + over-control).

### 2. Classificação via DAGs para bad controls em painel

- Pesquisadores não sabem quando algo é bad control no seu setting. A heurística "não inclua" é vazia sem ferramentas para diagnosticar.
- DAGs permitem classificar: a mesma variável pode ser collider (quando defasada, D_{t-1}→Z_{t-1}←Y_{t-1}), mediador (quando contemporânea, D_t→Z_t→Y_t), ou dual role (confounder via lag + collider contemporâneo).
- Contribuição: operacionalizar DAGs para bad controls em TSCS/DID com exemplos substantivos.

### 3. ADL como solução em TSCS (condicionado ao DAG)

- **Claim qualificado**: "Sob o DAG especificado (Figura X), condicionar em {Y_t, Z_t, α_i} bloqueia todos os backdoor paths de D_{t+1} para Y_{t+1}." Proposição formal com proof sketch via d-separation.
- Resolve collider: d-separation (firewall). Resultado estrutural, não paramétrico.
- Evita over-control contemporâneo: usa Z_{t-1} (pré-tratamento para D_t), não Z_t.
- Verificação MC: viés < 3% de β em 170+ cenários (linear + NL).
- **Não é claim universal**: depende do DAG e da dinâmica. O paper especifica as condições.

### 4. Quantificação do over-control para mediadores contemporâneos

- Em PO: TWFE condiciona em Z(1) para tratados e Z(0) para controles. Quando Z(1)≠Z(0), assimetria contamina τ. É problema de **identificação** quando o estimando é efeito total.
- Fórmula IVB quantifica a magnitude (sob linearidade, exatamente; sob NL, como aproximação).
- Caetano et al. (2022) diagnosticam mas não quantificam com fórmula fechada estimável.

### 5. Aplicações empíricas com classificação via DAG

- Manter aplicações existentes (collider-oriented) + reclassificar onde possível.
- **NÃO prometer "3-4 tipos" sem verificar.** Verificar os 6 estudos atuais para mediador/dual role ANTES de se comprometer.
- Se não houver caso limpo de mediador/dual role nos estudos existentes, manter foco em collider + Remarks sobre outros casos.

---

## Simulações: status corrigido

| Simulação | Status | NL? | Dual role? | Ação |
|---|---|---|---|---|
| v1, v4 mechanisms | DONE | Não | Não | Manter, reinterpretar |
| NL collider (sim_nl_collider.R) | DONE, 84 cenários | **Sim** (8 tipos NL) | **Sim** (gamma_D=0.15, gamma_Y=0.2) | Manter — cobre collider NL E dual role NL |
| NL interact (sim_nl_interact.R) | DONE | Sim | Verificar | Manter |
| NL carryover (sim_nl_carryover.R) | DONE | Sim | Verificar | Manter |
| Dual role z linear | DONE, 80 cenários | Não | Sim | Manter |
| Feedback Y→D | DONE | Não | Parcial | Manter |
| Binary D (mechC_adl) | DONE | Não | Não | Manter |
| **Over-control contemporâneo** | **NÃO EXISTE** | - | - | **Criar e rodar ANTES da escrita** |
| **Over-control contemporâneo NL** | **NÃO EXISTE** | - | - | **Criar e rodar ANTES da escrita** |

**Nota**: sim_nl_collider.R JÁ tem estrutura dual role (Z é confounder via lags + collider contemporâneo + NL). O spec v2.0 estava errado ao dizer que "dual role NL não existe."

**Simulações novas necessárias**: apenas over-control contemporâneo (mediador puro, D→Z→Y, sem Y→Z). Linear + NL.

---

## Referências pendentes em references.bib

Precisam ser adicionadas ANTES da escrita:

```bibtex
@unpublished{caetano_callaway2024,
  title={Difference-in-Differences when Parallel Trends Holds Conditional on Covariates},
  author={Caetano, Carolina and Callaway, Brantly},
  year={2024},
  note={arXiv:2406.15288v2}
}

@unpublished{caetano_etal2022,
  title={Difference in Differences with Time-Varying Covariates},
  author={Caetano, Carolina and Callaway, Brantly and Payne, Stroud and Sant'Anna, Hugo},
  year={2022},
  note={arXiv:2202.02903v3}
}

@article{lin_zhang2022,
  title={Interpreting the coefficients in dynamic two-way fixed effects regressions with time-varying covariates},
  author={Lin, Lihua and Zhang, Zhengyu},
  journal={Economics Letters},
  volume={216},
  pages={110604},
  year={2022},
  publisher={Elsevier}
}
```

Cinelli & Hazlett (2020) já existe como `cinelli2020making`.
Cinelli & Pearl (2022) já existe como `cinelli2021crash`.

---

## Estrutura do paper (ordem de escrita)

```
--- FASE 0: Pré-requisitos ---
0a. Adicionar referências em references.bib
0b. Rodar simulações de over-control contemporâneo (linear + NL)
0c. Verificar aplicações existentes para mediador/dual role

--- FASE 1: Corpo do paper (nova versão .Rmd) ---
1. Seção 3: DAGs expandidos (collider, mediador contemp., dual role)
2. Seção 4: IVB Formula + Remarks (generalidade, Cinelli & Hazlett)
3. Seção 5: When Does IVB Matter?
   5.1 Linear: derivações analíticas (hook pedagógico)
   5.2 Nonlinear: proposição firewall + MC
   5.3 ADL como solução (qualificado)
4. Seção 2: Control Variable Problem (revisão com refs novas)
5. Seção 6: Applications (reclassificar, selecionar)
6. Seção 7: Conclusion (com limitações)

--- FASE 2: Appendices ---
7. Appendix A: PO derivation (Z(1)≠Z(0), conditional PT + bad control)
8. Appendix B: Full sim results

--- FASE 3: Framing ---
9. Seção 1: Introduction
10. Abstract
```

---

## Qualificações e precisões (incorporadas do DA + fresh agent)

### ADL claim
- **Dizer**: "Sob o DAG especificado, condicionar em {Y_t, Z_t, α_i} bloqueia todos os backdoor paths (Proposição X)."
- **Não dizer**: "ADL resolve o problema" (sem qualificador).

### IVB como efeito indireto
- **Dizer**: "Sob linearidade, IVB = -θ*×π corresponde exatamente ao efeito indireto bloqueado."
- **Não dizer**: "IVB = efeito indireto" (sem qualificar que é sob linearidade).
- Sob NL: "IVB é a diferença entre projeções lineares; a interpretação como efeito indireto é aproximação guiada pelo DAG, verificada numericamente via MC."

### Caso confounder
- Footnote: "Quando Z é confounder puro, IVB = -OVB. A fórmula recupera o resultado clássico."
- Não dedicar seção.

### Cinelli & Hazlett
- Remark de 2-3 frases para posicionamento.
- Não contribuição central nem tabela comparativa.

---

## Riscos e mitigações (atualizados)

| Risco | Mitigação |
|---|---|
| Sim de over-control dá resultado ruim | Rodar ANTES. Se NL over-control não funciona limpo, ajustar escopo — manter over-control linear + collider NL. |
| Aplicações não têm caso limpo de mediador | Verificar ANTES. Se não houver, manter collider + Remarks. Não prometer o que não tem. |
| Referee: "isso é só FWL" | A contribuição é: (1) ninguém aplicou FWL para diagnosticar bad controls com fórmula estimável, (2) interpretação unificada via DAG, (3) conexão com ADL como solução. |
| Referee: "por que quantificar se recomendação é não incluir?" | A heurística "não inclua" é vazia se o pesquisador não sabe identificar bad controls. Na prática, classificar é incerto, muitas variáveis são dual role, e a fórmula permite quantificar antes de decidir. |
| Referee: "over-control é estimando, não identificação" | Formalizar via PO (Appendix A): Z(1)≠Z(0), TWFE condiciona em Z observado (assimétrico), isso contamina τ. É identificação quando estimando é efeito total. |
| Espaço PA (~12k palavras) | 3-4 aplicações corpo, restante Online Appendix. Caso linear breve (hook). |
| Citações pendentes | Adicionar em references.bib na Fase 0. |
