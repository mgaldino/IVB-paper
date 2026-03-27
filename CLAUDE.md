# IVB-SDiD Extension — Contexto para Claude Code

## O que e este projeto

**Novo paper** (ou extensao do IVB paper — TBD) estendendo o framework de Included Variable Bias (IVB) para estimadores de painel modernos: SDiD, Factor Models (IFE/GSC).

**Problema**: Pesquisadores usando SDiD/IFE com covariadas time-varying Z que sao ambiguas (potencialmente confounder E post-treatment) nao tem ferramentas para diagnosticar se incluir Z ajuda ou prejudica.

**Contribuicao central**: Decomposicao do vies de incluir Z em dois componentes estimaveis:

```
IVB = Coefficient Effect (CE) + Reweighting Effect (RE)
```

- **CE**: vies de condicionar em collider/mediador, mantendo pesos fixos. FWL se aplica → CE = -theta*_omega x pi_omega
- **RE**: vies adicional pela distorcao dos pesos sinteticos/fatores latentes ao incluir Z. Novo e especifico de estimadores com pesos adaptativos.

## Formula central (TWFE como benchmark)

IVB = beta_long - beta_short = -theta* x pi (identidade FWL)

No TWFE, RE = 0 (pesos OLS fixos). No SDiD, RE != 0 porque incluir Z muda os pesos (omega, lambda) via otimizacao conjunta.

## Caso aplicado motivante

Paper do autor em R&R (RDD-Trade): impacto de politica externa quando China ultrapassa EUA como principal parceiro comercial.
- Covariada problematica: deficit em conta corrente (confounder via crise 2008 + post-treatment via fluxos comerciais)
- Estimador: SDiD (pacote `synthdid`)
- Codigo: `/Users/manoelgaldino/Documents/DCP/Papers/RDD Trade/red_trade/`

## Spec do projeto

**Arquivo**: `quality_reports/plans/2026-03-25_ivb-sdid-factor-models-spec.md`

## Roadmap analitico

### Step 0 — Feasibility check (PROXIMO PASSO)
Verificar que o hybrid estimator e computavel:
1. Rodar `synthdid_estimate` SEM Z → extrair omega_short, lambda_short
2. Rodar WLS manual de Y sobre (D, Z, intercepts) com pesos (omega_short x lambda_short)
3. Se funcionar: decomposicao e factivel. Se nao: repensar abordagem.

### Step 1 — Derivar decomposicao para SDiD
Escrever tau_short e tau_long em forma fechada, decompor, provar CE = -theta*_omega x pi_omega

### Step 2 — Quando RE = 0?
Condicoes suficientes para o Reweighting Effect ser zero/pequeno

### Step 3 — Diagnostico estimavel
Como o pesquisador computa CE e RE na pratica

### Step 4 — Ilustracao aplicada (RDD-Trade)

## Minimum viable paper

SDiD decomposicao (CE + RE) + aplicacao RDD-Trade. Extensao para IFE/GSC se tratavel.

## Branch

`feature/ivb-sdid-factor-models` (worktree isolado de main)

## Workflow obrigatorio

1. **Plano em disco** antes de implementar (quality_reports/plans/)
2. **Review de codigo** via skill `review-r` antes de rodar — SEMPRE, sem excecao
3. **NAO rodar** codigo R sem aprovacao do usuario E sem review-r previo
4. **NAO commitar** sem instrucao explicita
5. **O agente que implementa NAO revisa. Quem revisa NAO implementa.**
6. **Sequencia obrigatoria**: escrever script → review-r → usuario aprova → rodar

## Convencoes de codigo

- R, data.table, fixest::feols com vcov = "iid"
- future_lapply com future.seed = TRUE, 4 workers
- Resultados em CSV (fwrite)
- Figuras em ggplot2, salvos em plots/ como PNG 150 dpi
- sessionInfo() salvo em *_sessioninfo.txt
