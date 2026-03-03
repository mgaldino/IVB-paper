# Plano: Simulacao Monte Carlo v2 — IVB no espaco de observaveis

**Status**: DRAFT
**Data**: 2026-02-28

## Contexto e motivacao

### O que a simulacao v1 mostrou (e por que nao e util)

A simulacao v1 (sim_ivb_twfe.R) parametrizou o DGP por (gamma_Y, gamma_D, delta) — parametros estruturais nao-observaveis. Os resultados foram tautologicos: IVB e grande quando gamma_Y e gamma_D sao grandes. Isso so reafirma a formula IVB = -theta* x pi sem gerar insight novo.

Alem disso, a variavel que deveria ser a mais interessante (R2_within) mostrou-se irrelevante para a magnitude do IVB em DGPs lineares continuos: IVB/|beta| depende apenas dos parametros estruturais, nao da decomposicao de variancia.

### O que esta simulacao deve responder

A pergunta central para o pesquisador aplicado e: **"Dado o que observo nos meus dados, devo me preocupar com IVB?"**

O pesquisador pode computar:
- theta* = coeficiente de Z no modelo longo (Y ~ D + Z | FE)
- pi = coeficiente de D na regressao auxiliar (Z ~ D | FE)
- SE(beta_long) = erro-padrao de D no modelo longo
- IVB = -theta* x pi (diretamente)

Mas NÃO sabe se o IVB e grande o suficiente para distorcer sua inferencia. Precisa de benchmarks.

## Abordagem: IVB no espaco de observaveis

### Ideia central

Em vez de parametrizar por estruturais (gamma_Y, gamma_D), parametrizar por **quantidades que o pesquisador observa**: theta* e pi. Variar N, T e R2_within como moduladores de precisao (afetam SE, portanto afetam se IVB distorce inferencia).

### O que a simulacao adiciona alem da formula

A formula IVB = -theta* x pi e deterministica. Mas a simulacao responde perguntas que a formula sozinha nao responde:

1. **IVB/SE**: dado (theta*, pi, N, T, R2_within), quantos SEs o IVB representa? Isso determina se a cobertura do IC cai.
2. **Cobertura efetiva**: qual a cobertura real do IC 95% como funcao de (theta*, pi) para diferentes tamanhos de painel?
3. **Poder distorcido**: a taxa de rejeicao de H0: beta=0 muda quanto ao incluir o collider?
4. **Benchmarks empiricos**: onde as 7 aplicacoes do paper caem no espaco (theta*, pi)?
5. **Fronteira de preocupacao**: para quais combinacoes (theta*, pi) o IVB muda a conclusao substantiva?

### DGP

Gerar dados de painel que produzam valores-alvo de theta* e pi:

```
Y_it = beta * D_it + alpha_i + lambda_t + epsilon_it
Z_it = pi_target * D_it_within + (theta_target_adj) * Y_it_within + eta_i + mu_t + nu_it
```

Onde D_it_within e Y_it_within sao os componentes within (pos-demean). O objetivo e calibrar o DGP para que, apos TWFE, os coeficientes estimados theta* e pi se aproximem dos valores-alvo.

**Abordagem pratica de calibracao:**

No caso clean (delta=0), as relacoes populacionais apos TWFE sao:
- pi = gamma_D + gamma_Y * beta (coef de D em Z ~ D | FE)
- theta* = gamma_Y * sigma2_eps / (sigma2_nu + gamma_Y^2 * sigma2_eps) (coef de Z em Y ~ D + Z | FE)

Dado (pi_target, theta_target), podemos resolver para (gamma_D, gamma_Y):
- Da segunda equacao: gamma_Y = f(theta_target, sigma2_eps, sigma2_nu)
- Da primeira: gamma_D = pi_target - gamma_Y * beta

Isso permite gerar DGPs que produzem os (theta*, pi) desejados.

### Grid de parametros

**Eixos principais (observaveis):**

| Parametro | Significado | Valores |
|-----------|-------------|---------|
| theta_star | Coef de Z no modelo longo | -0.8, -0.5, -0.3, -0.1, 0.0, 0.1, 0.3, 0.5, 0.8 |
| pi | Coef de D na reg auxiliar | -0.8, -0.5, -0.3, -0.1, 0.1, 0.3, 0.5, 0.8 |

**Eixos de precisao (afetam SE):**

| Parametro | Significado | Valores |
|-----------|-------------|---------|
| R2_within | Fracao within da var de D | 0.1, 0.5, 0.9 |
| N | Unidades | 50, 200 |
| T | Periodos | 10, 30 |

**Parametros fixos:**
- beta = 1
- sigma2_eps = sigma2_nu = 1
- sigma2_alpha = sigma2_lambda = 1
- sigma2_eta = sigma2_mu = 0.5
- Replicacoes: 500

**Total:** 9 x 8 x 3 x 2 x 2 = 864 cenarios x 500 reps
(Excluindo theta_star = 0 com pi != 0, que nao gera IVB, mantemos como baseline)

### Metricas por cenario

1. **IVB** = mean(beta_long - beta_short) — confirma -theta* x pi
2. **IVB/SE** = mean(|IVB| / SE(beta_long)) — quantos SEs o vies representa
3. **IVB/|beta|** = |IVB|/|beta| — fracao do efeito verdadeiro (analitico: theta* x pi / beta)
4. **Coverage_short** — cobertura IC 95% modelo curto (deve ser ~0.95 no caso clean)
5. **Coverage_long** — cobertura IC 95% modelo longo (cai com IVB grande)
6. **Rejection_short** — poder do modelo curto
7. **Rejection_long** — poder do modelo longo (distorcido pelo IVB)
8. **Delta_rejection** — rejection_long - rejection_short (mudanca no poder)

### Figuras planejadas

1. **Heatmap de IVB/SE** no espaco (theta*, pi), para cada combinacao (N, T)
   - Pesquisador olha seu theta* e pi, encontra quantos SEs o IVB vale
   - Overlay dos 7 estudos empiricos como pontos

2. **Heatmap de cobertura** no espaco (theta*, pi)
   - Mostra onde a cobertura do IC cai abaixo de 90%, 80%, etc.
   - Identifica "zona de perigo"

3. **Curvas de nivel ("fronteira de preocupacao")**: no espaco (theta*, pi), contornos de |IVB/SE| = 1, 2, 3
   - Isso define: "se seu theta* x pi cai fora desta regiao, o IVB e menor que 1 SE"
   - Ferramenta pratica para o pesquisador

4. **Scatter empirico**: os 7 estudos plotados no espaco (theta*, pi) com anotacao de IVB/SE
   - Mostra que todos caem na zona de "IVB < 1 SE" (confirmando que IVB e pequeno nessas aplicacoes)
   - Mas a figura mostra claramente que ha regioess grandes onde IVB >> 1 SE

5. **Line plot**: IVB/SE vs R2_within para theta* e pi fixos
   - Mostra o efeito de precisao: mesmo IVB absoluto, mas mais SEs com dados melhores
   - Conecta com a intuicao original do user sobre variancia within

### Dados empiricos para overlay

Extrair dos 7 estudos existentes:
- theta* (coef de Z no modelo longo)
- pi (coef de D na reg auxiliar)
- SE(beta_long)
- IVB = -theta* x pi

Fonte: `replication/standardized_ivb_metrics.csv` e os scripts de replicacao individuais.

## Implementacao

### Arquivo: `sim_ivb_twfe_v2.R`

```r
# 1. Funcao: calibrate_dgp(theta_target, pi_target, beta, sigma2_eps, sigma2_nu)
#    → retorna (gamma_Y, gamma_D) que produzem os (theta*, pi) desejados
# 2. Funcao: generate_panel_data(...) (reutilizar da v1 com gamma_Y, gamma_D calculados)
# 3. Funcao: run_one_scenario(params) → metricas
# 4. Grid: CJ(theta_star, pi, R2_within, N, TT)
# 5. Paralelo: future_lapply
# 6. Salvar CSV + figuras
```

### Arquivo: `sim_ivb_twfe_v2_figures.R`
- Figuras com overlay dos dados empiricos
- Depende de `standardized_ivb_metrics.csv` para posicionar os estudos

## Verificacao

- [ ] Calibracao: theta* e pi estimados coincidem com os targets (sanity check)
- [ ] IVB = -theta* x pi (identidade FWL)
- [ ] Coverage_short ~ 0.95 no caso clean
- [ ] Coverage_long cai monotonicamente com |theta* x pi|
- [ ] IVB/SE cresce com R2_within, N, T (mais precisao → IVB em mais SEs)
- [ ] Estudos empiricos corretamente posicionados no espaco (theta*, pi)
- [ ] Fronteira de preocupacao e interpretavel e util

## O que esta simulacao NAO faz (limitacoes explicitas)

1. Nao varia delta (confounding) — foca no caso clean para clareza
2. Nao usa D binario — DGP linear continuo (extensao futura)
3. Nao incorpora dinamica (ADL) — painel estatico com TWFE
4. Nao substitui a formula: o pesquisador pode calcular IVB diretamente. A simulacao fornece benchmarks de *inferencia* (cobertura, poder) que a formula sozinha nao da.
