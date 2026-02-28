# Plano: Simulacao Monte Carlo — Quando o IVB e grande?

**Status**: COMPLETED (v4 — simulacao rodada com sucesso)
**Data**: 2026-02-27

## Contexto

As 7 aplicacoes empiricas do IVB paper mostram IVBs modestos (max |IVB/SD(Y)| ~ 0.04). Isso ecoa Ding & Miratrix (2015) sobre M-bias ser geralmente pequeno. Em vez de buscar papers aleatoriamente, queremos entender **sob quais condicoes do DGP o IVB seria grande**, para depois buscar papers com essas caracteristicas de maneira informada.

Intuicao-chave: em TSCS com TWFE, os FE absorvem variacao between-unit, e o IVB depende da variacao **within-unit** de D e Z. Se D varia pouco within (ex: democratizacao binaria), pi e pequeno e IVB e pequeno.

As simulacoes existentes no paper (`sim_ivb_completa.R`) NAO tem unit+time FE nem variam within/between variance.

### Nota teorica importante (do devil's advocate)

Em DGPs lineares continuos, R2_within **nao afeta a magnitude do IVB em populacao** (IVB/|beta|). Isso porque pi e theta* sao coeficientes de regressao populacionais que dependem da relacao linear entre variaveis, nao de suas variancias. R2_within afeta apenas a **precisao** dos estimadores (SEs maiores com menos variacao within). Portanto:
- IVB/|beta| deve ser constante em R2_within (a confirmar)
- IVB/SE(beta_long) deve crescer com R2_within (mais variacao within -> SEs menores -> IVB em mais SEs)
- Esta e uma descoberta importante por si so: mostra que em DGPs lineares, IVB depende apenas dos parametros estruturais

## Objetivo

Identificar sistematicamente as condicoes do DGP (forca do collider, confounding, variacao within vs between de D) sob as quais o IVB e substancial em paineis com TWFE.

## DGP

### Estrutura do Painel
- i = 1,...,N unidades; t = 1,...,T periodos
- Unit FE: alpha_i ~ N(0, sigma2_alpha)
- Time FE: lambda_t ~ N(0, sigma2_lambda)

### Tratamento D
```
D_it = mu_i^D + tau_t^D + d_it
```
- mu_i^D ~ N(0, sigma2_D_between) — componente between-unit
- tau_t^D ~ N(0, sigma2_D_time) — componente temporal comum
- d_it ~ N(0, sigma2_D_within) — componente within-unit/within-time
- **Parametro-chave**: R2_within = sigma2_D_within / (sigma2_D_between + sigma2_D_time + sigma2_D_within)
- **Normalizacao**: sigma2_D_total = 1 (fixo). Dado R2_within:
  - sigma2_D_within = R2_within
  - sigma2_D_between = (1 - R2_within) / 2
  - sigma2_D_time = (1 - R2_within) / 2

### Caso Clean (delta = 0): Z e so collider, nao causa Y

**Estrutural:**
```
Y_it = beta * D_it + alpha_i + lambda_t + epsilon_it
Z_it = gamma_D * D_it + gamma_Y * Y_it + eta_i + mu_t + nu_it
```

Substituindo Y em Z:
```
Z_it = gamma_D * D_it + gamma_Y * (beta * D_it + alpha_i + lambda_t + epsilon_it) + eta_i + mu_t + nu_it
     = (gamma_D + gamma_Y * beta) * D_it + (eta_i + gamma_Y * alpha_i) + (mu_t + gamma_Y * lambda_t) + (nu_it + gamma_Y * epsilon_it)
```

O pesquisador roda:
- Short: Y ~ D | unit_FE + time_FE -> **sem vies** (beta_short ~ beta)
- Long: Y ~ D + Z | unit_FE + time_FE -> **com IVB** (beta_long != beta)
- IVB = beta_long - beta_short

### Caso Dirty (delta != 0): Z e collider E confounder

**Estrutural (equacoes simultaneas):**
```
Y_it = beta * D_it + delta * Z_it + alpha_i + lambda_t + epsilon_it
Z_it = gamma_D * D_it + gamma_Y * Y_it + eta_i + mu_t + nu_it
```

**Forma reduzida** (resolvendo o sistema, requer |delta * gamma_Y| < 1):
```
Y_it = [(beta + delta * gamma_D) / (1 - delta * gamma_Y)] * D_it
      + [(alpha_i + delta * eta_i) / (1 - delta * gamma_Y)]
      + [(lambda_t + delta * mu_t) / (1 - delta * gamma_Y)]
      + [(epsilon_it + delta * nu_it) / (1 - delta * gamma_Y)]

Z_it = [(gamma_D + gamma_Y * beta) / (1 - delta * gamma_Y)] * D_it
      + [(eta_i + gamma_Y * alpha_i) / (1 - delta * gamma_Y)]
      + [(mu_t + gamma_Y * lambda_t) / (1 - delta * gamma_Y)]
      + [(nu_it + gamma_Y * epsilon_it) / (1 - delta * gamma_Y)]
```

O pesquisador roda:
- Short: Y ~ D | FE -> **com OVB** (porque Z confunde mas nao esta incluido)
- Long: Y ~ D + Z | FE -> **com IVB** (collider) mas **menos OVB** (deconfounding)
- Net bias = IVB - OVB_removed

## Grid de Parametros

### Parametros que variam:

| Parametro | Significado | Valores |
|-----------|-------------|---------|
| gamma_Y | Y -> Z (forca do collider) | 0.0, 0.2, 0.5, 0.8 |
| gamma_D | D -> Z (D causa Z) | -0.8, -0.5, -0.2, 0.2, 0.5, 0.8 |
| delta | Z -> Y (confounding; 0=clean) | -0.6, -0.3, 0.0, 0.3, 0.6 |
| R2_within | fracao within da variancia de D | 0.1, 0.3, 0.5, 0.7, 0.9 |

### Parametros fixos:
- beta = 1 (efeito verdadeiro)
- N = 200 (unidades)
- T = 30 (periodos)
- sigma2_alpha = sigma2_lambda = 1 (FEs)
- sigma2_epsilon = sigma2_nu = 1 (erros)
- sigma2_eta = sigma2_mu = 0.5 (FEs do collider Z)
- sigma2_D_total = 1 (variancia total de D fixada)
- Replicacoes: 500

### Total de cenarios:
4 (gamma_Y) x 6 (gamma_D) x 5 (delta) x 5 (R2_within) = 600 cenarios x 500 reps

### Restricao de estabilidade:
Cenarios onde |delta * gamma_Y| >= 1 sao descartados. No grid atual, max |delta * gamma_Y| = |0.6 * 0.8| = 0.48 < 1, portanto nenhum cenario e descartado. A verificacao e mantida como safety check.

## Metricas por Cenario

Para cada cenario, computar sobre as 500 replicacoes:
1. **mean(beta_short)** — media do estimador sem Z
2. **mean(beta_long)** — media do estimador com Z
3. **mean(IVB)** = mean(beta_long - beta_short) — IVB empirico medio
4. **mean(IVB_formula)** = mean(-theta* x pi) — verificacao da formula
5. **mean(|IVB|/|beta|)** — IVB como % do efeito verdadeiro
6. **mean(|IVB|/SE(beta_long))** — IVB em unidades de SE
7. **mean(|IVB|/SD(Y))** — IVB padronizado (Cohen's d analog)
8. **bias_short** = mean(beta_short) - beta — vies absoluto sem Z
9. **bias_long** = mean(beta_long) - beta — vies absoluto com Z
10. **RMSE_short** e **RMSE_long** — para comparar qual modelo e melhor
11. **coverage_short** — fracao de reps onde IC 95% do modelo short contem beta
12. **coverage_long** — fracao de reps onde IC 95% do modelo long contem beta
13. **rejection_short** — taxa de rejeicao de H0: beta=0 no modelo short
14. **rejection_long** — taxa de rejeicao de H0: beta=0 no modelo long

### Erros-padrao:
Usar SEs clusterizados por unidade na estimacao (como fazem pesquisadores aplicados), mesmo com DGP iid.

## Output Esperado

### Tabelas
1. **Tabela de resultados completa**: todas as 600 combinacoes com metricas
2. **Tabela resumo**: condicoes onde |IVB/beta| > 10%, > 25%, > 50%

### Figuras
1. **Heatmap**: |IVB/beta| em funcao de (gamma_Y, gamma_D) para cada nivel de R2_within e delta
2. **Line plot**: |IVB/beta| e |IVB/SE| vs R2_within, facetado por (gamma_Y, gamma_D), coloreado por delta
3. **Scatter**: bias_short vs bias_long (qual modelo e melhor?) para clean vs dirty
4. **Boxplot**: distribuicao de IVB/SD(Y) nos cenarios, comparavel com os dados empiricos

## Implementacao

### Arquivo: `sim_ivb_twfe.R`
Localizacao: `/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/sim_ivb_twfe.R`

Estrutura:
```r
# 1. Funcao DGP: generate_panel_data(N, TT, beta, gamma_Y, gamma_D, delta,
#                                     R2_within, sigma2_alpha, sigma2_lambda, ...)
# 2. Funcao de simulacao: run_one_sim(params) -> data.frame com metricas
# 3. Grid de parametros: expand.grid(...)
# 4. Loop paralelo: future.apply::future_lapply
# 5. Salvamento: data.table::fwrite(results, "sim_ivb_twfe_results.csv")
```

### Arquivo: `sim_ivb_twfe_figures.R`
Localizacao: `/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/sim_ivb_twfe_figures.R`

Gera as 4 figuras a partir do CSV de resultados.

Dependencias: `fixest`, `data.table`, `ggplot2`, `future.apply`

## Verificacao

- [x] Rodar simulacao completa sem erros (17.3 min, 600 cenarios x 500 reps)
- [x] Verificar que IVB_formula ~ IVB_empirico (max discrepancia = 0.000000)
- [x] Caso clean (delta=0): max |bias_short| = 0.0033, coverage_short = 0.950
- [x] Caso dirty (delta!=0): RMSE comparado (ver figuras)
- [x] IVB/|beta| constante em R2_within CONFIRMADO (39.98%-40.08% para gY=0.5, gD=0.5)
- [x] IVB/SE cresce com R2_within (75 a 156 para mesmos parametros)
- [x] 220/600 cenarios com |IVB/beta| > 25%, 105/600 com > 50%
- [x] 8 figuras geradas em plots/

## Previsoes Teoricas (a confirmar)

1. IVB cresce com |gamma_Y| e |gamma_D| (mais forte Y->Z e D->Z)
2. **IVB/|beta| e constante em R2_within** (DGP linear continuo — parametros estruturais determinam IVB, nao variancia)
3. **IVB/SE cresce com R2_within** (mais variacao within -> SEs menores -> IVB pesa mais em unidades de SE)
4. No caso clean, incluir Z sempre piora (bias_long > bias_short em valor absoluto)
5. No caso dirty, incluir Z pode ser benefico se deconfounding > IVB
6. Sinais negativos de gamma_D e delta podem inverter a direcao do IVB
7. gamma_Y = 0 e baseline util: sem collider, IVB ~ 0 no caso clean; no caso dirty, incluir Z sempre ajuda
