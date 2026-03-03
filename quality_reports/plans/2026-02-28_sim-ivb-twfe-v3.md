# Plano: Ferramenta Analitica IVB + Validacao de Amostra Finita (v3)

**Status**: APPROVED (DA score 90/100 — EXCELENTE, Round 3)
**Data**: 2026-02-28

## Por que v2 foi rejeitado

O plano v2 (`2026-02-28_sim-ivb-twfe-v2.md`) recebeu score 25/100 (REPROVADO) na revisao Devil's Advocate. As criticas centrais foram:

1. **Erro matematico na calibracao**: Com sigma2_eps = sigma2_nu = 1, a funcao theta*(gamma_Y) = gamma_Y / (1 + gamma_Y^2) atinge maximo em |theta*| = 0.5. Os valores theta* = +-0.8 do grid sao inalcancaveis -- a funcao `calibrate_dgp()` falharia em 28-44% dos cenarios.
2. **Tautologia nao resolvida**: A reparametrizacao (gamma_Y, gamma_D) -> (theta*, pi) e uma bijecao que preserva toda a informacao. Os heatmaps de IVB/SE apenas ilustram hiperboles |theta* x pi / SE| = constante, computaveis analiticamente via `pnorm()` sem simulacao.
3. **Simulacao desnecessaria para N*T grande**: IVB/SE, cobertura e poder sao funcoes deterministicas dos parametros, computaveis em forma fechada. Nenhuma das 5 perguntas do plano requer Monte Carlo.
4. **Dados empiricos incompletos**: O CSV `standardized_ivb_metrics.csv` contem apenas IVB (o produto -theta* x pi), nao theta* e pi separadamente. Overlay no espaco bidimensional (theta*, pi) e impossivel sem extrair esses valores.
5. **Cenarios redundantes**: 96 cenarios com theta* = 0 (IVB = 0 por construcao) desperdicam custo computacional.

## O que mudou na v3

A v3 adota uma **abordagem hibrida em 3 partes**, seguindo a recomendacao do DA:

- **Parte 1**: Ferramenta analitica (contribuicao principal) -- sem simulacao
- **Parte 2**: Overlay empirico (requer extracao de theta* e pi dos estudos)
- **Parte 3**: Validacao de amostra finita (unico uso legitimo de simulacao)

---

## Parte 1: Ferramenta Analitica (contribuicao principal)

### Motivacao

A pergunta central do pesquisador aplicado e: "Dado o que observo nos meus dados, devo me preocupar com IVB?"

O pesquisador ja pode computar:
- theta* = coeficiente de Z no modelo longo (Y ~ D + Z | FE)
- pi = coeficiente de D na regressao auxiliar (Z ~ D | FE)
- SE(beta_long) = erro-padrao de D no modelo longo
- beta_long = coeficiente de D no modelo longo

Com essas quantidades, **tudo** e computavel analiticamente:

```
IVB = -theta* x pi
IVB/SE = IVB / SE(beta_long)           (signed; coverage is symmetric in sign)
Coverage(95%) = Phi(1.96 - IVB/SE) - Phi(-1.96 - IVB/SE)
Power = 1 - Phi(1.96 - (beta + IVB)/SE) + Phi(-1.96 - (beta + IVB)/SE)
```

onde Phi e a CDF da normal padrao. Nenhuma simulacao e necessaria.

### Derivacao

A formula IVB = -theta* x pi segue do teorema de Frisch-Waugh-Lovell. O vies do estimador beta_long em relacao a beta_short e exatamente -theta* x pi, onde theta* e o coeficiente parcial de Z em Y dado D (e FE), e pi e o coeficiente parcial de D em Z (e FE).

Em amostras grandes (N*T -> infinito), beta_long se distribui aproximadamente como:

```
beta_long ~ N(beta + IVB, SE^2)
```

Portanto, o IC 95% centrado em beta_long cobre beta verdadeiro com probabilidade:

```
P(beta in CI) = P(|beta_long - beta| / SE < 1.96)
              = P(|(beta_long - beta - IVB) / SE + IVB/SE| < 1.96)
              = Phi(1.96 - IVB/SE) - Phi(-1.96 - IVB/SE)
```

Note: IVB/SE aqui preserva o sinal. Quando IVB > 0, a cobertura cai porque o centro do IC esta deslocado para cima.

### Funcao R: `ivb_diagnostic()`

```r
#' Diagnostico analitico de IVB
#'
#' Computa IVB, IVB/SE, cobertura e flag a partir de quantidades
#' que o pesquisador observa diretamente nos seus dados.
#'
#' @param theta Coeficiente de Z no modelo longo (Y ~ D + Z | FE)
#' @param pi Coeficiente de D na regressao auxiliar (Z ~ D | FE)
#' @param se_beta_long Erro-padrao de D no modelo longo
#' @param beta_long Coeficiente de D no modelo longo (para poder distorcido)
#' @param alpha Nivel de significancia (default 0.05)
#' @param df Graus de liberdade para valor critico (default Inf = normal;
#'           usar df = N - 1 para correcao de amostra finita com t-distribution)
#' @return Lista com: ivb, ivb_over_se, coverage, power_nominal, power_actual, flag
ivb_diagnostic <- function(theta, pi, se_beta_long, beta_long, alpha = 0.05, df = Inf) {
  if (is.finite(df)) {
    crit <- qt(1 - alpha / 2, df)
  } else {
    crit <- qnorm(1 - alpha / 2)
  }

  ivb <- -theta * pi
  ivb_over_se <- ivb / se_beta_long

  # Cobertura do IC (1-alpha) em relacao ao beta verdadeiro
  # beta_true = beta_long - ivb (pois beta_long = beta + ivb)
  coverage <- pnorm(crit - ivb_over_se) - pnorm(-crit - ivb_over_se)

  # Poder: probabilidade de rejeitar H0: beta=0

  # Sob H0 falsa (beta != 0), o estimador tem E[beta_long] = beta + ivb = beta_long
  # Poder nominal (sem ivb): P(reject | beta_true)
  beta_true <- beta_long - ivb
  if (se_beta_long > 0 && !is.na(beta_true)) {
    power_nominal <- 1 - pnorm(crit - abs(beta_true) / se_beta_long) +
                         pnorm(-crit - abs(beta_true) / se_beta_long)
    power_actual  <- 1 - pnorm(crit - abs(beta_long) / se_beta_long) +
                         pnorm(-crit - abs(beta_long) / se_beta_long)
  } else {
    power_nominal <- NA_real_
    power_actual  <- NA_real_
  }

  # Flag baseado em |IVB/SE|
  abs_ratio <- abs(ivb_over_se)
  flag <- if (abs_ratio < 0.5) {
    "negligible"
  } else if (abs_ratio < 1.0) {
    "minor"
  } else if (abs_ratio < 2.0) {
    "moderate"
  } else {
    "severe"
  }

  list(
    ivb          = ivb,
    ivb_over_se  = ivb_over_se,
    abs_ivb_se   = abs_ratio,
    coverage     = coverage,
    power_nominal = power_nominal,
    power_actual  = power_actual,
    flag         = flag
  )
}
```

### Figuras analiticas (sem Monte Carlo)

Todas computadas via `pnorm()` e funcoes analiticas. Sem ruido MC.

**Figura 1: Heatmap de |IVB/SE| no espaco (theta*, pi)**

Mostrar |theta* x pi| / SE como heatmap com **4 paineis**, um para cada SE em {0.01, 0.05, 0.10, 0.20}. Esses valores cobrem o range empirico observado nos estudos replicados (Rogowski SE=0.005 ate Claassen FE SE=0.22). Os eixos sao theta* (de -1 a 1) e pi (de -1 a 1). As curvas de nivel sao hiperboles.

**Figura 2: Heatmap de cobertura no espaco (theta*, pi)**

Coverage = Phi(1.96 - |theta* x pi| / SE) - Phi(-1.96 - |theta* x pi| / SE), computada para cada ponto (theta*, pi) com **4 paineis** para SE em {0.01, 0.05, 0.10, 0.20}. Identificar zonas onde cobertura < 90%, < 80%, < 50%. Note que para SE pequeno (0.01), a zona de cobertura < 90% e muito maior, ilustrando que dados mais precisos tornam o IVB mais perigoso em termos de inferencia.

**Figura 3: Fronteira de preocupacao ("worry frontier")**

Contornos analiticos de |theta* x pi / SE| = c, para c = 0.5, 1, 2, 3. Sao hiperboles:

```
|pi| = c * SE / |theta*|
```

Para cada c, tracar a hiperbole no espaco (theta*, pi). Mostrar com **4 paineis** para SE em {0.01, 0.05, 0.10, 0.20}, cobrindo o range empirico dos estudos.

Interpretacao para o pesquisador: "se seu ponto (theta*, pi) cai dentro da hiperbole c = 1, o IVB e menor que 1 SE -- provavelmente inofensivo."

**Figura 4: Overlay empirico sobre a fronteira de preocupacao**

Plotar os pontos (theta*, pi) dos 7 estudos empiricos sobre os contornos da Figura 3. Requer dados da Parte 2.

**Figura 5: IVB/SE vs SE (efeito de precisao)**

Para theta* e pi fixos (ex: theta* = 0.1, pi = 0.3), mostrar como IVB/SE cresce quando SE diminui (paineis maiores, mais variacao within). Ilustra o insight contra-intuitivo: "dados melhores tornam o vies mais perigoso em termos de inferencia."

Computavel analiticamente: IVB/SE = |theta* x pi| / SE, que e monotonicamente decrescente em SE.

### Implementacao

**Arquivo**: `ivb_analytical_tool.R`

```r
# 1. ivb_diagnostic(theta, pi, se_beta_long, beta_long)
#    -> retorna IVB, IVB/SE, coverage, power, flag
#
# 2. ivb_worry_frontier(se_values, thresholds = c(0.5, 1, 2, 3))
#    -> retorna data.frame com coordenadas das hiperboles para plot
#
# 3. ivb_heatmap_data(theta_grid, pi_grid, se)
#    -> retorna data.frame com IVB/SE e coverage para cada (theta*, pi)
```

**Arquivo**: `ivb_analytical_figures.R`

```r
# Gera Figuras 1-3 e 5 diretamente via pnorm()
# Figura 4 depende dos dados da Parte 2
#
# Dependencias: ggplot2, scales
# Nao depende de fixest, data.table, ou future.apply
```

---

## Parte 2: Overlay Empirico (extracao de theta* e pi)

### Problema

O arquivo `replication/standardized_ivb_metrics.csv` contem apenas:

```
paper, collider, IVB, beta_long, SE_beta, SD_Y, IVB_pct_beta, IVB_over_SE, IVB_over_SDY, abs_IVB_SDY
```

**Nao ha colunas `theta` nem `pi`**. O CSV armazena IVB = -theta* x pi (o produto), mas nao os fatores individuais. Com apenas o produto, e impossivel posicionar um ponto no espaco bidimensional (theta*, pi).

### Solucao

A funcao `compute_ivb_multi()` em `replication/ivb_utils.R` ja retorna theta e pi separadamente no campo `results`:

```r
res <- compute_ivb_multi(data, y, d_vars, z, w, fe, vcov)
res$theta    # coef de Z no modelo longo
res$results$pi  # coef de D na regressao auxiliar, por treatment term
```

Portanto, basta modificar `replication/compute_standardized_ivb.R` para tambem armazenar theta e pi no CSV.

### Estudos a processar

| # | Paper | Script | Theta/Pi acessiveis? |
|---|-------|--------|---------------------|
| 1 | Claassen (OLS) | `claassen_replication_ivb.R` | Sim via `compute_ivb_multi()` |
| 2 | Claassen (FE) | `claassen_replication_ivb.R` | Sim via `compute_ivb_multi()` |
| 3 | Leipziger | `leipziger_replication_ivb.R` | Sim via `compute_ivb_multi()` |
| 4 | Blair et al. | `peacekeeping_replication_ivb.R` | Sim via `compute_ivb_multi()` |
| 5 | Albers et al. | `fiscal_state_replication_ivb.R` | Parcial: SE_beta e NA, mas theta e pi provavelmente disponiveis via `fiscal_state_ivb_results.csv` |
| 6 | Rogowski et al. | via `compute_standardized_ivb.R` | Sim via `compute_ivb_multi()` |
| 7 | Ballard-Rosa et al. | via `compute_standardized_ivb.R` | Sim via `compute_ivb_multi()` |

**Nota sobre Albers et al.**: O CSV `standardized_ivb_metrics.csv` tem NA em SE_beta, SD_Y e metricas derivadas para este estudo. Verificar se o script original computa theta e pi e se e possivel obter SE_beta. Se nao, excluir do overlay ou marcar como incompleto.

### Implementacao

**Arquivo a modificar**: `replication/compute_standardized_ivb.R`

Adicionar ao loop de cada estudo:

```r
# Dentro de cada iteracao:
r <- res$results
# Ja existente: add_row(..., r$ivb_formula, r$beta_long, se_b, sd_y)
# Adicionar: theta e pi ao data.frame
```

Modificar a funcao `add_row()` para incluir `theta` e `pi`:

```r
add_row <- function(paper, collider_label, ivb, beta_long, se_beta, sd_y,
                    theta, pi_val) {
  all_results[[length(all_results) + 1]] <<- data.frame(
    paper = paper,
    collider = collider_label,
    IVB = ivb,
    beta_long = beta_long,
    SE_beta = se_beta,
    SD_Y = sd_y,
    theta_star = theta,         # NOVO
    pi = pi_val,                # NOVO
    IVB_pct_beta = 100 * ivb / beta_long,
    IVB_over_SE = ivb / se_beta,
    IVB_over_SDY = ivb / sd_y,
    stringsAsFactors = FALSE
  )
}
```

Para cada estudo, na chamada `add_row()`, passar `res$theta` e `r$pi` (onde `r <- res$results`).

**Output atualizado**: `replication/standardized_ivb_metrics.csv` com colunas adicionais `theta_star` e `pi`.

Caso o Albers et al. nao permita extrair theta e pi (dados pre-computados em `fiscal_state_ivb_results.csv`), verificar se esse CSV ja contem essas colunas. Se nao, rodar `compute_ivb_multi()` novamente para esse estudo.

---

## Parte 3: Validacao de Amostra Finita (simulacao restrita)

### Proposito

O unico uso legitimo de simulacao e verificar se as formulas assintoticas (Parte 1) sao acuradas em paineis pequenos. Em amostras finitas, a distribuicao de beta_long pode nao ser normal e SE pode ser viesado, levando a cobertura diferente da formula analitica.

**Pergunta**: "Para paineis com N < 50 e T < 10, qual e a discrepancia entre cobertura simulada e cobertura analitica?"

Se a discrepancia for < 2 pontos percentuais, concluir que as formulas analiticas bastam. Se a discrepancia for relevante, **este e o resultado genuinamente novo**: uma correcao de amostra finita que a formula sozinha nao fornece.

### DGP

Identico ao da v1 (`sim_ivb_twfe.R`), mas apenas no caso clean (delta = 0):

```
Y_it = beta * D_it + alpha_i + lambda_t + epsilon_it
Z_it = (gamma_D + gamma_Y * beta) * D_it + (eta_i + gamma_Y * alpha_i)
       + (mu_t + gamma_Y * lambda_t) + (nu_it + gamma_Y * epsilon_it)
```

### Calibracao corrigida: grid no espaco (theta*, pi)

**Correcao do erro matematico**: Com sigma2_eps = sigma2_nu = 1:

```
theta*(gamma_Y) = gamma_Y / (1 + gamma_Y^2)
```

O maximo e |theta*| = 0.5 em gamma_Y = +-1. Para o grid, restringir |theta*| <= 0.45 (margem de seguranca para inversao numerica estavel).

Inversao: dado theta_target, resolver gamma_Y^2 - gamma_Y/theta_target + 1 = 0:

```
gamma_Y = (1 / (2 * theta_target)) * (1 - sqrt(1 - 4 * theta_target^2))
```

Discriminante real requer |theta_target| <= 0.5. Com |theta*| <= 0.45, discriminante = 1/(0.45^2) - 4 = 4.94 - 4 = 0.94 > 0. OK.

Depois, gamma_D = pi_target - gamma_Y * beta.

**Alternativa**: Para expandir o range de theta*, usar sigma2_eps = 4, sigma2_nu = 1. Entao:

```
theta*(gamma_Y) = 4 * gamma_Y / (1 + 4 * gamma_Y^2)
```

Maximo em gamma_Y = 0.5, onde theta* = 1.0. Isso permitiria |theta*| ate ~0.9. **Recomendacao**: usar sigma2_eps = sigma2_nu = 1 com |theta*| <= 0.45. A restricao de range nao e problema porque os estudos empiricos tem theta* pequenos.

### Grid de parametros (reduzido)

**Eixos principais (observaveis):**

| Parametro | Significado | Valores |
|-----------|-------------|---------|
| theta_star | Coef de Z no modelo longo | -0.45, -0.3, -0.1, 0.1, 0.3, 0.45 |
| pi | Coef de D na reg auxiliar | -0.5, -0.2, 0.2, 0.5 |

**Nota**: theta* = 0 excluido (IVB = 0 trivialmente para qualquer pi). O grid cobre 6 x 4 = 24 combinacoes de (theta*, pi).

**Eixos de tamanho de amostra (foco em paineis pequenos):**

| Parametro | Significado | Valores |
|-----------|-------------|---------|
| N | Unidades | 20, 50, 200 |
| T | Periodos | 5, 10, 30 |

N = 200 e T = 30 servem como referencia "grande" onde assintotico deve funcionar.

**Parametros fixos:**
- beta = 1
- delta = 0 (caso clean apenas)
- sigma2_eps = sigma2_nu = 1
- sigma2_alpha = sigma2_lambda = 1
- sigma2_eta = sigma2_mu = 0.5
- R2_within = 0.5 (fixo; variacao de R2w nao e o foco desta validacao)
- Replicacoes: 1000 (mais reps que v1/v2 para reduzir ruido MC na estimativa de cobertura)

**Total**: 6 (theta*) x 4 (pi) x 3 (N) x 3 (T) = 216 cenarios x 1000 reps

Muito menor que os 864 x 500 da v2. Tempo estimado: ~20 min (com 4 workers paralelos).

### Metricas por cenario

1. **IVB_simulado** = mean(beta_long - beta_short)
2. **IVB_analitico** = -theta_target x pi_target (confirmar identidade)
3. **SE_medio** = mean(SE(beta_long)) ao longo das reps
4. **IVB_over_SE_simulado** = mean(|IVB| / SE(beta_long))
5. **Coverage_simulada** = fracao de reps onde IC 95% contem beta verdadeiro
6. **Coverage_analitica** = mean over reps r of [Phi(crit - IVB_analitico/SE_r) - Phi(-crit - IVB_analitico/SE_r)], onde crit = qt(0.975, N-1) e SE_r e o erro-padrao da replicacao r
7. **Discrepancia_coverage** = Coverage_simulada - Coverage_analitica (em pontos percentuais)
8. **Power_simulado** = fracao de reps que rejeitam H0: beta=0
9. **Power_analitico** = mean over reps r of [1 - Phi(crit - |beta + IVB|/SE_r) + Phi(-crit - |beta + IVB|/SE_r)], onde crit = qt(0.975, N-1) e SE_r e o erro-padrao da replicacao r
10. **Discrepancia_power** = Power_simulado - Power_analitico

### Resultado esperado

- Para N >= 50 e T >= 10: discrepancia < 2pp -> formulas analiticas bastam
- Para N = 20 e T = 5: discrepancia possivelmente > 2pp -> resultado genuinamente novo
- Se discrepancia sistematica: documentar e propor correcao (ex: usar t-distribution com df ajustados em vez de normal)

### Decomposicao da discrepancia

Quando houver discrepancia entre cobertura simulada e analitica, reportar uma decomposicao em tres componentes para tornar os resultados mais informativos:

1. **Nao-normalidade de beta_long**: A distribuicao de beta_long em amostras finitas pode nao ser normal (ex: caudas pesadas, assimetria). Medir via teste de Shapiro-Wilk ou comparacao de quantis empiricos vs. teoricos.

2. **Vies na estimacao de SE**: O erro-padrao estimado SE_r pode ser sistematicamente viesado em relacao ao desvio-padrao verdadeiro de beta_long. Medir como E[SE_r] vs. sd(beta_long_vec). Se E[SE_r] < sd(beta_long), os ICs sao sistematicamente estreitos demais.

3. **Residuo**: A parcela da discrepancia nao explicada por (1) e (2). Captura interacoes entre nao-normalidade e vies de SE, bem como outros efeitos de amostra finita.

Essa decomposicao permite diagnosticar a **causa** da falha assintotica, nao apenas sua magnitude.

### Implementacao

**Arquivo**: `sim_ivb_twfe_v3_validation.R`

```r
# 1. calibrate_dgp(theta_target, pi_target, beta = 1,
#                   sigma2_eps = 1, sigma2_nu = 1)
#    -> retorna list(gamma_Y, gamma_D)
#    -> ERRO se |theta_target| > 0.5
#
# 2. generate_panel_data(N, TT, beta, gamma_Y, gamma_D, delta = 0,
#                         R2_within, ...)
#    -> reutilizar funcao da v1 (sim_ivb_twfe.R)
#
# 3. run_validation_scenario(params)
#    -> roda nsim reps, computa metricas simuladas E analiticas
#    -> IMPORTANTE: usar df = N - 1 tanto na construcao do IC simulado
#       (t_crit = qt(0.975, N-1)) quanto na cobertura analitica
#       (ivb_diagnostic(..., df = N - 1)), garantindo valores criticos
#       identicos entre simulacao e formula analitica.
#    -> Cobertura analitica: computar per-replication usando SE_r de cada rep,
#       depois tirar a media (evita artefato de Jensen)
#    -> retorna data.table com 1 linha: params + todas as metricas + discrepancias
#
# 4. Grid: CJ(theta_star, pi, N, TT) com parametros fixos
# 5. Paralelo: future_lapply
# 6. Salvar: sim_ivb_validation_results.csv
```

**Estilo de codigo**: Seguir o estilo da v1 (`sim_ivb_twfe.R`) -- `data.table`, `fixest`, `future.apply`, SEs iid, t-crit com N-1 df.

---

## Figuras finais planejadas (resumo)

| # | Titulo | Fonte | Requer simulacao? |
|---|--------|-------|-------------------|
| 1 | Heatmap |IVB/SE| no espaco (theta*, pi) | Parte 1 (analitico) | Nao |
| 2 | Heatmap cobertura no espaco (theta*, pi) | Parte 1 (analitico) | Nao |
| 3 | Fronteira de preocupacao (worry frontier) | Parte 1 (analitico) | Nao |
| 4 | Overlay empirico sobre worry frontier | Parte 2 (dados) | Nao |
| 5 | IVB/SE vs SE (efeito de precisao) | Parte 1 (analitico) | Nao |
| 6 | Discrepancia cobertura: simulada vs analitica por (N, T) | Parte 3 (simulacao) | Sim |

A Figura 6 e a unica que depende de simulacao e e potencialmente a contribuicao mais original: mostra **quando** as formulas assintoticas falham.

---

## Ordem de implementacao

1. **Parte 1**: `ivb_analytical_tool.R` + `ivb_analytical_figures.R` (Figuras 1-3, 5)
2. **Parte 2**: Modificar `compute_standardized_ivb.R`, re-rodar, atualizar CSV com theta/pi. Gerar Figura 4.
3. **Parte 3**: `sim_ivb_twfe_v3_validation.R`. Gerar Figura 6.

Partes 1 e 2 sao independentes e podem ser implementadas em paralelo. Parte 3 depende de Parte 1 (precisa da funcao `ivb_diagnostic()` para computar cobertura analitica).

---

## Verificacao

### Parte 1
- [ ] `ivb_diagnostic(theta=0.1, pi=0.3, se=0.05, beta_long=1.03)` retorna IVB=-0.03, IVB/SE=-0.6, coverage~0.91, flag="minor"
- [ ] Figuras 1-3 produzidas sem erro; hiperboles simetricas; cores corretas
- [ ] Fronteira de preocupacao: para |theta* x pi / SE| = 1, verificar que a hiperbole passa por (theta*=1, pi=SE) e (theta*=SE, pi=1)

### Parte 2
- [ ] CSV atualizado tem colunas `theta_star` e `pi` para todos os 7 estudos (exceto possivelmente Albers et al.)
- [ ] Verificar identidade: IVB = -theta_star x pi (max discrepancia < 1e-10)
- [ ] Pelo menos 6 dos 7 estudos posicionados no overlay
- [ ] Verificar quantos estudos caem fora de |IVB/SE| = 1. Esperado: ao menos Rogowski (Log GDP p.c.) com |IVB/SE| = 2.11 cai fora, indicando que IVB pode ser inferencialmente relevante em estudos reais. Este e um achado empirico interessante, nao um erro.

### Parte 3
- [ ] Calibracao funciona: theta* e pi estimados coincidem com targets (max discrepancia < 0.01 para N=200, T=30)
- [ ] IVB_simulado ~ IVB_analitico (max discrepancia < 0.005 para N=200, T=30)
- [ ] Para N=200, T=30: discrepancia_coverage < 2pp (confirma assintotico)
- [ ] Para N=20, T=5: documentar discrepancia (resultado genuinamente novo se > 2pp)
- [ ] Nenhum cenario com |theta_target| > 0.5 (grid corrigido)
- [ ] Coverage do modelo short ~ 0.95 em todos os cenarios (sanity check, pois delta=0)
- [ ] Total de cenarios = 216 (nao 864)

---

## O que esta abordagem NAO faz (limitacoes explicitas)

1. **Nao varia delta** (confounding) -- foca no caso clean. No caso dirty (delta != 0), beta_long - beta_short = IVB - OVB_removed, e a interpretacao muda. Extensao futura.
2. **Nao usa D binario** -- DGP linear continuo. Com D binario, pi pode ser estruturalmente diferente.
3. **Nao testa robustez a nao-linearidade** -- O DA identificou que testar se a ferramenta diagnostica funciona sob violacoes de linearidade (Z binario, erros heteroscedasticos, clustering) seria genuinamente informativo. Nao incluido nesta versao.
4. **Nao incorpora dinamica** (ADL) -- painel estatico com TWFE.
5. **Nao e um pacote R** -- a funcao `ivb_diagnostic()` sera um script avulso, nao um pacote instalavel. Se a contribuicao se mostrar util, empacotar futuramente.
