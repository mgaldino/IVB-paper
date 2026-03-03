# IVB Paper — Contexto para Claude Code

## O que e este projeto

Paper academico sobre **Included Variable Bias (IVB)** — o vies que surge quando se inclui um colisor (collider) como controle em regressao. Aplicado a paineis com TWFE (two-way fixed effects) em Ciencia Politica.

**Formula central**: IVB = beta_long - beta_short = -theta* x pi (identidade FWL)
- theta* = coeficiente de Z no modelo longo
- pi = coeficiente de D na regressao auxiliar Z ~ D + FE

## Framing central do paper (2026-03-03)

### Contribuicao central — Lane do paper

**Estimando**: CET (contemporaneous effect of treatment, efeito de D_t sobre Y_t).

**O problema novo**: Em TSCS, pesquisadores rotineiramente defasam controles (incluem Z_{t-1}) para "evitar reverse causality". Quando Z e causado por D e Y, isso cria a estrutura D_{t-1} -> Z_{t-1} <- Y_{t-1}. Condicionar em Z_{t-1} **abre** um caminho collider que viesa o CET. **Ninguem articulou isso na literatura de TSCS.**

**A formula**: IVB = -theta* x pi quantifica esse vies com quantidades ja estimadas pelo pesquisador.

**A solucao**: O ADL com variavel dependente defasada (Y_{t-1}) **bloqueia** o caminho collider aberto, sob linearidade ou nao-linearidade bounded. Vies residual < 3% de beta.

**O limite**: Sob nao-linearidade unbounded na equacao do collider, o ADL linear nao consegue bloquear o caminho, e o vies retorna.

### Elevator pitch

"Todo mundo sabe que omitir variaveis gera vies. Ninguem percebeu que incluir variaveis defasadas como controle em painel — pratica universal em CP — pode gerar vies por abrir um caminho collider. Derivamos uma formula fechada para esse vies, mostramos que o ADL o resolve sob linearidade, e demonstramos que nas aplicacoes tipicas o vies e negligivel. O limite e nao-linearidade forte na equacao do collider."

### Lane vs Blackwell & Glynn (2018)

BG e COMPLEMENTAR, nao adversario. Lanes separados, zero conflito:

| | BG (2018) | Nosso paper |
|---|---|---|
| **Estimando** | Efeitos defasados (impulse response) | CET (efeito contemporaneo) |
| **Problema** | Post-treatment bias em beta_2 (coef. do tratamento defasado) | Collider bias em beta_1 (CET) por incluir Z_{t-1} |
| **Fonte do vies** | X_{t-1} -> Z_t (Z contemp. e pos-tratamento para efeito defasado) | D_{t-1} -> Z_{t-1} <- Y_{t-1} (Z defasado e collider) |
| **Solucao** | SNMM / MSM | ADL (sob linearidade/bounded NL) |
| **Limite** | Functional form do outcome model | NL unbounded na equacao do collider |

**Importante**: BG mostram que beta_1 (CET) e consistente no ADL sob linearidade (p. 1073). O post-treatment bias deles afeta apenas beta_2 (efeitos defasados). Nosso paper identifica um problema **diferente** no CET: collider bias de Z_{t-1}. Sob linearidade, o ADL resolve; sob NL unbounded, nao.

**NAO dizer**: "IVB = post-treatment bias de BG" (sao coisas diferentes).
**DIZER**: "BG identificaram post-treatment bias para efeitos defasados. Nos identificamos collider bias para o CET — um problema distinto que o ADL resolve sob linearidade."

### Imai & Kim (2019) — leitura correta

- O argumento de Imai & Kim e sobre **identificacao** (strict exogeneity), NAO sobre "Nickell bias"
- TWFE basico e **nao-identificado** quando ha dinamica causal — vies permanente (nao O(1/T))
- ADL+FE e a solucao parametrica (Table 1, rows 2-4) com vies residual O(1/T) do estimador within com LDV
- NAO usar "Nickell bias" para descrever o argumento central de Imai & Kim

### Collider puro vs caso misto

- **Collider puro**: IVB e puro vies, sem compensacao. Exclua Z.
- **Caso misto** (Z e collider E confounder via lags): incluir Z cria IVB mas remove OVB. A formula permite quantificar o trade-off.
- A formula permite **distinguir os dois casos empiricamente** — basta estimar theta* e pi.

### O que FICA no paper (apos reestruturacao)

1. O problema novo: controles defasados como colliders viésam o CET
2. A formula IVB = -theta* x pi (cross-section + ADL)
3. FE absorvem between-unit collider channels
4. ADL bloqueia o caminho collider sob linearidade (vies < 3% de beta)
5. Boundary condition: NL unbounded quebra o bloqueio
6. Aplicacoes empiricas: mediana IVB ~ 0.13 SE

### O que SAI do paper (apos reestruturacao)

- Tentativa de "dialogar" com BG como se resolvessem o mesmo problema
- Discussao de SNMM/MSM vs ADL+FE (irrelevante — estimandos diferentes)
- Mecanismo "few switchers" (sobre precisao, nao sobre o collider bias)
- Mecanismo "feedback Y->D" (sobre strict exogeneity, tangencial ao collider)

## Estrutura do repositorio

```
IVB-paper/
  ivb_paper_psrm.Rmd           # Paper principal (Rmd source)
  references.bib                # Bibliografia

  derivations/                  # Notas teoricas e derivacoes
    ivb_derivation.Rmd/pdf
    ivb_derivacoes_proposicoes_1_2.Rmd/pdf/tex
    ivb_adl_derivacao.md
    sintese_entrevista.Rmd

  simulations/                  # Todos os scripts de simulacao
    utils/                      # Funcoes compartilhadas
      sim_nl_utils.R
    v1_twfe/                    # Sim v1 (completa, tautologica)
      sim_ivb_twfe.R, sim_ivb_twfe_figures.R, sim_ivb_completa.R
    v4_mechanisms/              # Sim v4 — mecanismos A-D
      sim_ivb_twfe_v4.R, sim_ivb_twfe_v4_figures.R, sim_mechC_adl.R
      results/                  # CSVs: mechA-D, synthesis, mechC_adl
    dual_role_z/                # Familia dual-role Z (6 scripts)
      results/
    nonlinearity/               # NL-1a, NL-1b, NL-2
      sim_nl_collider.R, sim_nl_interact.R, sim_nl_carryover.R
      plot_nl_functions.R, plot_nl_results.R
      results/
    dynamics/                   # Feedback e carryover
      sim_direct_carryover.R, sim_direct_feedback.R, sim_feedback_carryover.R
      results/
    diagnostics/                # Scripts diag_* e check_*
      results/
    deprecated/

  plots/                        # Figuras geradas (PNGs)
  quality_reports/plans/        # Planos em disco (ver abaixo)
  references_pdfs/              # PDFs de papers citados
  misc/                         # Utilitarios avulsos (count_words.R, etc.)

  replication/
    ivb_utils.R                 # compute_ivb_multi() — ferramenta aplicada
    *_replication_ivb.R         # 4 estudos empiricos (claassen, fiscal_state, leipziger, peacekeeping)
    unified_ivb_report.Rmd      # Relatorio unificado
    standardized_ivb_metrics.csv
```

## Simulacao v1 (COMPLETA)

- **Arquivo**: simulations/v1_twfe/sim_ivb_twfe.R (350 linhas)
- **DGP**: Y = beta*D + FE + eps; Z = (gamma_D + gamma_Y*beta)*D + FE + nu
- **Grid**: gamma_Y x gamma_D x delta x R2_within = 400 cenarios x 500 reps
- **Resultado principal**: IVB/|beta| e constante em R2_within — a simulacao era tautologica, so confirmava a formula
- **Stack**: fixest, data.table, future.apply (4 workers), iid SEs

## Simulacao v4 (EM ANDAMENTO)

**Plano**: quality_reports/plans/2026-02-28_sim-ivb-twfe-v4.md (DRAFT)
**Pergunta**: Por que o IVB e pequeno em aplicacoes empiricas?
**Arquivos**: simulations/v4_mechanisms/sim_ivb_twfe_v4.R + sim_ivb_twfe_v4_figures.R

### Status atual
- [x] Plano escrito e detalhado (v4)
- [x] Codigo escrito (sim_ivb_twfe_v4.R + figures)
- [ ] **Review de codigo (review-r skill) — PENDENTE**
- [ ] Rodar simulacao
- [ ] Verificar sanity checks
- [ ] Gerar figuras

### 4 Mecanismos

| Mec | O que varia | DGP key | Grid | Predicao |
|-----|-------------|---------|------|----------|
| A | D->Z btw vs wth | gamma_D_btw, gamma_D_wth separados | 108 cen | IVB flat em gamma_D_btw |
| B | Y->Z btw vs wth | gamma_Y_btw, gamma_Y_wth separados | 72 cen | theta* flat em gamma_Y_btw |
| C | D binario escalonado | prob_switch controla switchers | 16 cen | IVB/SE cai com poucos switchers |
| D | Erro de medida em Z | sigma2_me | 16 cen | |theta*| cai (attenuation bias) |

**Total**: 212 cenarios x 500 reps. Fixos: N=200, T=30, beta=1, delta=0.

### Algebra apos TWFE (mecanismo A)
- pi = gamma_D_wth + gamma_Y*beta (gamma_D_btw absorvido pelo unit FE)
- v1 e caso especial onde gamma_D_btw = gamma_D_wth

### Figuras planejadas (7+)
1. Heatmap A: |IVB/beta| vs (btw, wth) — faixas horizontais
2. Line A: |IVB/beta| vs gamma_D_btw — flat
3. IVB vs share_within do canal D->Z
4. Heatmap B: analogo ao A para Y->Z
5. Bar C: |IVB/SE| vs prob_switch
6. Line D: |theta*| vs sigma2_me
7. Tabela sintese: condicoes para IVB < 1 SE

## Workflow obrigatorio

1. **Plano em disco** antes de implementar (quality_reports/plans/)
2. **Review de codigo** via skill `review-r` antes de rodar
3. **NAO rodar** sem aprovacao do usuario
4. **NAO commitar** sem instrucao explicita

## Subagentes e permissoes

- **Subagentes em background NAO conseguem pedir permissao ao usuario.** Se uma skill ou tool exige permissao, o prompt nao aparece e a permissao e negada silenciosamente.
- **Sempre que um subagente tiver permissao negada, avisar o usuario imediatamente.** Nao tentar contornar sem avisar.
- **Skills (edmans-review, review-r, etc.) devem ser rodadas em foreground** para que o usuario possa aprovar a permissao quando solicitado.

## Convencoes de codigo (v1 como referencia)

- R, data.table, fixest::feols com vcov = "iid"
- future_lapply com future.seed = TRUE, 4 workers
- Resultados em CSV (fwrite)
- Figuras em ggplot2, salvos em plots/ como PNG 150 dpi
- sessionInfo() salvo em *_sessioninfo.txt
- Sanity checks impressos no console apos simulacao

## Relacao entre planos

- v1 (APPROVED, COMPLETED): simulacao basica — tautologica
- v2, v3 (DRAFT): iteracoes intermediarias, nao implementadas
- v4 (DRAFT): simulacao atual — responde "por que IVB e pequeno?"
- v3 Parte 1 (ferramenta analitica ivb_diagnostic) e Parte 2 (overlay empirico): MANTIDOS, complementares ao v4
