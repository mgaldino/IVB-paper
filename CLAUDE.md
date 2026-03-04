# IVB Paper — Contexto para Claude Code

## O que e este projeto

Paper academico sobre **Included Variable Bias (IVB)** — o vies que surge quando se inclui um colisor (collider) como controle em regressao. Aplicado a paineis com TWFE (two-way fixed effects) em Ciencia Politica.

**Formula central**: IVB = beta_long - beta_short = -theta* x pi (identidade FWL)
- theta* = coeficiente de Z no modelo longo
- pi = coeficiente de D na regressao auxiliar Z ~ D + FE

## Framing do paper — STATUS: INVALIDADO (2026-03-03)

### O que aconteceu

Simulacoes MC + analise de d-separation mostraram que o ADL completo (Y ~ D + D_lag + Y_lag + Z_lag | FE) da vies < 3% de beta em TODOS os 170 cenarios testados, incluindo NL unbounded (power1.5, Dlog), feedback, carryover, binary D. Nenhuma excecao.

### Resultado-chave: o argumento do "firewall"

Os UNICOS pais de Y_{t+1} no DAG sao {D_{t+1}, Y_t, Z_t}. Condicionar em {Y_t, Z_t} bloqueia TODOS os backdoor paths, independente de:
- Cascatas de colliders abertos no passado (Z_{t-2}, Z_{t-3}, ...)
- Persistencia de Z (Z_{t-1} -> Z_t nao muda nada)
- Y_t ser collider de {D_t, Z_{t-1}, Y_{t-1}} — os paths abertos nao chegam em Y_{t+1} sem passar por {Y_t, Z_t}
- Forma funcional da equacao de Z (resultado estrutural de d-separation, nao parametrico)

### Tabela-resumo (todas as simulacoes)

| Simulacao | max |adl_all_bias| | % de beta |
|---|---|---|
| mechC_adl (binary D) | 0.0285 | 2.9% |
| nl_collider (incl. power1.5) | 0.0229 | 2.3% |
| nl_carryover | 0.0112 | 1.1% |
| feedback_Y_to_D | 0.0103 | 1.0% |
| feedback_carryover | 0.0075 | 0.8% |
| direct_carryover | 0.0035 | 0.4% |
| nl_interact | 0.0031 | 0.3% |

### Consequencias

- BG (2018) ja mostraram que beta_1 e consistente no ADL (p. 1073). Nossas simulacoes confirmam universalmente.
- O frame "ninguem viu que controles defasados viesam o CET" so vale para TWFE sem Y_{t-1}. Mas ai a solucao e "use ADL" — que BG ja recomendam.
- O plano de reescrita para APSR (quality_reports/plans/2026-03-03_rewrite-apsr.md) esta **ON HOLD**.
- O paper precisa de repensar fundamental da contribuicao.

### NAO fazer (erros a evitar)

- **NAO dizer** "NL unbounded e boundary condition para o ADL" — NAO E. ADL funciona em todos os cenarios.
- **NAO dizer** "BG nao viram o problema do collider para o CET" — BG mostraram beta_1 consistente no ADL.
- **NAO confundir** adl_Ylag (parcial, PODE ter vies ate 41%) com adl_all (completo, vies < 3%).
- **NAO confundir** adl_all_nofe (sem FE, vies 8-13%) com adl_all (com FE, vies < 3%). FE sao essenciais.

### O que sobrevive (potencialmente)

- A formula IVB em si (identidade algebrica, quantifica vies de incluir collider)
- Diagnostico para TWFE (muitos pesquisadores usam TWFE, nao ADL)
- Aplicacoes empiricas (mediana IVB ~ 0.13 SE)

### Imai & Kim (2019) — leitura correta (ainda valida)

- O argumento de Imai & Kim e sobre **identificacao** (strict exogeneity), NAO sobre "Nickell bias"
- TWFE basico e **nao-identificado** quando ha dinamica causal — vies permanente (nao O(1/T))
- ADL+FE e a solucao parametrica (Table 1, rows 2-4) com vies residual O(1/T) do estimador within com LDV
- NAO usar "Nickell bias" para descrever o argumento central de Imai & Kim

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

## Simulacoes — TODAS COMPLETAS (2026-03-03)

Todas as simulacoes rodaram. 170 cenarios, 8 arquivos de resultados. Ver MEMORY.md para detalhes.
Resultado principal: adl_all com FE tem vies < 3% de beta em todos os cenarios.

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
