# IVB Paper — Contexto para Claude Code

## O que e este projeto

Paper academico sobre **Included Variable Bias (IVB)** — o vies que surge quando se inclui um colisor (collider) como controle em regressao. Aplicado a paineis com TWFE (two-way fixed effects) em Ciencia Politica.

**Formula central**: IVB = beta_long - beta_short = -theta* x pi (identidade FWL)
- theta* = coeficiente de Z no modelo longo
- pi = coeficiente de D na regressao auxiliar Z ~ D + FE

## Framing central do paper (2026-03-01)

### Tres perspectivas sobre o mesmo fenomeno

O IVB de controlar por Z dual-role e o **mesmo mecanismo** visto de tres angulos:
1. **IVB** (nossa formula): vies = -theta* x pi ao incluir collider
2. **Post-treatment bias** (Blackwell & Glynn 2018): condicionar em Z pos-tratamento abre back-door via U_i
3. **Strict exogeneity violation** (Imai & Kim 2019): TWFE basico nao-identificado quando ha dinamica causal

### Argumento-chave

Blackwell & Glynn mostram que ADL tem post-treatment bias e recomendam SNMM/MSM. Porem:
- SNMM/MSM **nao controlam** por confounders time-invariant (alpha_i)
- Em CP, alpha_i (country effects, institutions, geography) e **ubiquo**
- A formula do IVB **quantifica** o post-treatment bias e mostra que e pequeno sob linearidade + caso misto

**Portanto**: ADL+FE e a escolha pratica. O pesquisador aceita IVB pequeno (<1% de beta) em troca de controle por alpha_i.

### Por que a formula "trivial" e importante

A formula IVB = -theta* x pi e FWL puro — mecanicamente simples. Mas o **uso** e novo:
1. **Diagnostico quantitativo**: permite calcular |IVB| com dados reais e decidir se incluir Z vale a pena
2. **Bridge entre literaturas**: unifica IVB (nosso) + post-treatment bias (Blackwell) + collider bias (Pearl)
3. **Resultado substantivo**: sob linearidade e caso misto, |IVB| < 1% de beta — o problema de Blackwell & Glynn e negligivel
4. **Delimitacao**: collider **puro** (Z so causado por D/Y, nao causa nada) => IVB e vies puro, Blackwell & Glynn estao certos. Caso **misto** (Z tambem e confounder via lags) => incluir Z cria IVB mas remove OVB maior, net favoravel

### Collider puro vs caso misto

- **Collider puro**: IVB e puro vies, sem compensacao. Nao condicione em Z. Blackwell & Glynn 100% corretos.
- **Caso misto**: incluir Z cria IVB mas remove OVB. A formula mostra que o net e quase sempre favoravel sob linearidade.
- A formula permite **distinguir os dois casos empiricamente** — basta estimar theta* e pi.

### Imai & Kim (2019) — leitura correta

- O argumento de Imai & Kim e sobre **identificacao** (strict exogeneity), NAO sobre "Nickell bias"
- TWFE basico e **nao-identificado** quando ha dinamica causal — vies permanente (nao O(1/T))
- ADL+FE e a solucao parametrica (Table 1, rows 2-4) com vies residual O(1/T) do estimador within com LDV
- NAO usar "Nickell bias" para descrever o argumento central de Imai & Kim

### Blackwell & Glynn (2018) — leitura correta

- ADL tem post-treatment bias para efeitos defasados quando Z e afetado pelo tratamento
- SNMM/MSM evitam o post-treatment bias, mas exigem todos confounders observados
- FE nao e compativel com MSM/IPTW facilmente (BG footnote 13)
- Sob linearidade, o post-treatment bias (= IVB) e pequeno — o custo de perder alpha_i >> IVB

### Simulacoes de nao-linearidade (PLANEJADAS)

O resultado "IVB pequeno" depende de linearidade. Simulacoes planejadas para delimitar:

| ID | Nao-linearidade | Equacao | O que testa |
|---|---|---|---|
| NL-1a | Polinomial D->Z (grau 1,2,3) | Z = ... + d_D2*D^2 [+ d_D3*D^3] | IVB quando collider e nao-linear |
| NL-1b | Interacao D*H->Z (H exogena) | Z = ... + d_DH*D*H | IVB com heterogeneidade no canal collider |
| NL-1c | Polinomial D->Z + Y->Z | Z = ... + d_D2*D^2 + d_Y2*Y^2 | Caso adverso: dois canais nao-lineares |
| NL-2 | Carryover D->Y nao-linear | Y = ... + b2*D_lag^2 | Interacao especificacao errada x IVB |

Predicao: IVB aumenta com grau de nao-linearidade no canal D->Z (NL-1a/c). Se confirmado, delimita quando ADL+FE funciona vs quando MSM/IPTW valem o custo.

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
