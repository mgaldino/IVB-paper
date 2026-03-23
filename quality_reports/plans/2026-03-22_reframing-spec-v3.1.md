# Spec: Reframing do IVB Paper — v3.1

**Status**: APPROVED
**Data**: 2026-03-22
**Supersedes**: v2.0 e v2.1 (por este agente). Complementa v3.0 (pelo outro agente).
**Target journal**: Political Analysis

**Nota**: v3.0 e v3.1 foram escritos independentemente por agentes diferentes na mesma sessão. v3.0 foca mais no recorte estratégico (CET em TSCS como benchmark). v3.1 incorpora os resultados das simulações de over-control e a conexão com PTA condicional. Os dois são compatíveis e devem ser lidos em conjunto.

---

## O que v3.1 adiciona em relação a v3.0

1. **Resultados das simulações de over-control**: dois scripts independentes convergem. Relatório unificado em overcontrol_unified_report.md.
2. **Conexão PTA condicional formalizada**: variante med+confounder É o caso conditional PT. ADL com Z_{t-1} resolve o dilema via separação temporal.
3. **Recomendação central com 3 mecanismos**: d-separation (collider), timing (over-control), conditional PT (confounder via lag).
4. **Conjectura de generalidade sob NL**: argumentos estruturais + verificação MC. Conjectura, não prova formal.
5. **Status de simulações**: todas completas, nenhuma pendente.
6. **Tabela de referências cruzadas**: todos os documentos do projeto.

---

## Recomendação central do paper (consolidada)

> Quando o estimando é o CET (efeito contemporâneo de D_t sobre Y_t), use ADL com Z_{t-1}. Isso:
> - Evita over-control contemporâneo (Z_{t-1} não intercepta D_t → Z_t → Y_t — timing)
> - Resolve collider bias (condicionar em {Y_t, Z_t, α_i} bloqueia todos os backdoor paths — d-separation/firewall)
> - Satisfaz PTA condicional quando Z_{t-1} é confounder (remove OVB via lag)
> - Resolve o caso dual role (collider + confounder) por combinação dos mecanismos acima
>
> Sob linearidade, a fórmula IVB = -θ*×π quantifica exatamente o viés de incluir/excluir Z.
> Sob NL, os argumentos estruturais (d-separation, timing) são não-paramétricos; verificação MC em 200+ cenários confirma viés residual < 3% de β.
> A conjectura é que o resultado é geral.

---

## Conexão com PTA condicional

### O dilema
Quando PT só vale condicional em Z e Z é bad control: excluir Z viola PT, incluir Z gera bad control bias.

### Solução no TSCS
A estrutura temporal separa os dois papéis de Z:
- **Z_{t-1}** satisfaz conditional PT (remove confounding)
- **Z_t** (que seria bad control) não é incluído no ADL

### Evidência
Variante med+confounder das simulações:
- adl_all(Z_lag) = 1.03 (correto: PT satisfeita, sem over-control)
- adl_DYlag(sem Z) = 1.09-1.11 (PT violada: OVB)
- adl_DYlag_Z(Z contemp) = 1.00-1.02 (over-control: bloqueia indireto)

### Contraste com DID
No DID de 2 períodos, a separação temporal não existe. O dilema é inescapável → motiva Caetano et al.

---

## Simulações: status final

| Simulação | Status | NL? | Papel | Cenários |
|---|---|---|---|---|
| v1, v4 mechanisms | DONE | Não | Collider linear, mecanismos | 400+ |
| NL collider (sim_nl_collider.R) | DONE | Sim (8 tipos) | Collider NL + dual role NL | 84 |
| NL interact | DONE | Sim | NL em interação | var |
| NL carryover | DONE | Sim | NL com carryover | var |
| Dual role z linear | DONE | Não | Dual role linear | 80 |
| Feedback Y→D | DONE | Não | Feedback | 7 |
| Binary D (mechC_adl) | DONE | Não | Tratamento binário | 48 |
| Over-control (sim_overcontrol.R) | DONE | Sim (8 tipos) | Med puro + med+confounder | 36 |
| Over-control (sim_overcontrol_contemporaneous.R) | DONE | Sim (4 tipos) | Med puro, calibração forte | 26 |

**Todas as simulações completas. Nenhuma pendente.**

---

## Qualificações (consolidadas de v3.0 e v3.1)

### O que dizer
- "Sob o DAG especificado, o ADL com Z_{t-1} evita over-control (timing), resolve collider bias (d-separation), e satisfaz PTA condicional (confounding via lag)."
- "Para o CET, Z_{t-1} é pré-tratamento."
- "Sob linearidade, IVB = -θ*×π é exato. Sob NL, é aproximação verificada numericamente."
- Conjectura de generalidade: razoável mas não provada formalmente.

### O que NÃO dizer
- "ADL resolve o problema" (sem qualificador)
- "ADL resolve todos os problemas de Caetano et al." (resolve para TSCS, não DID 2 períodos)
- "Z_{t-1} é sempre pré-tratamento" (é para CET, não para efeitos defasados)
- TWFE short como benchmark causal limpo em setting dinâmico
- "IVB = efeito indireto" sem qualificar linearidade

---

## Referências pendentes

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

---

## Documentos de referência

| Documento | Localização |
|---|---|
| Spec v3.0 (outro agente) | quality_reports/plans/2026-03-22_reframing-spec-v3.md |
| Spec v3.1 (este) | quality_reports/plans/2026-03-22_reframing-spec-v3.1.md |
| Spec v2.1 | quality_reports/plans/2026-03-22_reframing-spec-v2.md |
| Spec v2.0 | quality_reports/plans/2026-03-22_reframing-spec.md |
| Plano original | quality_reports/plans/2026-03-22_reframing-bridge-literatures.md |
| Derivação PO | derivations/ivb_potential_outcomes.md |
| Relatório over-control unificado | quality_reports/overcontrol_unified_report.md |
| Relatório over-control (agente 1) | quality_reports/overcontrol_simulation_report.md |
| Relatório over-control (agente 2) | quality_reports/overcontrol_contemporaneous_simulation_report.md |
| Script over-control (agente 1) | simulations/overcontrol/sim_overcontrol.R |
| Script over-control (agente 2) | simulations/nonlinearity/sim_overcontrol_contemporaneous.R |
