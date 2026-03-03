# Dual-Role Z Simulation Report v2

**Data**: 2026-03-01
**Status**: COMPLETE — 7 simulacoes, 80 cenarios, 500 reps cada

## 1. Motivacao

O paper sobre IVB trata Z como **puro collider**. Um referee (DA) questionou: e quando Z e **simultaneamente confounder e collider** (butterfly/bow-tie structure)?

Em paineis TSCS, isso acontece naturalmente quando:
- Z_{t-1} -> D_t e Z_{t-1} -> Y_t (confounder via lag)
- D_t -> Z_t e Y_t -> Z_t (collider contemporaneo)
- Z_{t-1} -> Z_t (persistencia cria cadeia de colliders herdados)

A variavel GDP em relacoes internacionais e o exemplo canonico: GDP passado afeta decisoes (confounder), mas decisoes e outcomes afetam GDP contemporaneo (collider).

### Conexao Imai & Kim (2019)

O relatorio v1 tratou Imai & Kim como uma "preocupacao com Nickell bias" — uma caricatura. O argumento central de Imai & Kim e sobre o **trade-off entre confounders time-invariant e dinamica causal**, articulado via 4 assumptions:

| Assumption | Conteudo | Violacao no DGP base | Violacao no DGP estendido |
|---|---|---|---|
| **(a)** No unobserved time-varying confounders | Nenhum confounder variavel no tempo nao-observado | Violada (Z_{t-1} confounds se omitido) | Idem |
| **(b)** No outcome persistence: Y_{t-1} -/-> Y_t | O outcome nao tem persistencia temporal | Violada (rho_Y > 0) | Idem |
| **(c)** No feedback: Y_{t-1} -/-> D_t | O outcome passado nao afeta o tratamento | Indireta (via Z: Y -> Z -> D) | **Direta (phi Y_{t-1} -> D_t)** |
| **(d)** No treatment carryover: D_{t-1} -/-> Y_t | O tratamento passado nao afeta o outcome | Indireta (via rho_D e Z) | **Direta (beta_2 D_{t-1} -> Y_t)** |

O DGP base viola (a) e (b) diretamente, e (c)/(d) apenas indiretamente (via Z). As simulacoes novas (Sims 1-3) testam violacoes **diretas** de (c) e (d), que sao os casos mais relevantes para Imai & Kim.

## 2. DGPs

### 2.1 DGP Base (violacoes indiretas)

```
D_{it} = alpha^D_i + gamma_D Z_{i,t-1} + rho_D D_{i,t-1} + u_{it}
Y_{it} = alpha^Y_i + beta D_{it} + gamma_Y Z_{i,t-1} + rho_Y Y_{i,t-1} + e_{it}
Z_{it} = alpha^Z_i + delta_D D_{it} + delta_Y Y_{it} + rho_Z Z_{i,t-1} + nu_{it}
```

Parametros fixos: beta=1, rho_Y=0.5, rho_D=0.5, gamma_D=0.15, gamma_Y=0.2, delta_D=0.1, delta_Y=0.1, N=100, T=30, T_burn=100.

### 2.2 DGP + Direct Feedback (Sim 1 — assumption (c) violada)

```
D_{it} = alpha^D_i + gamma_D Z_{i,t-1} + rho_D D_{i,t-1} + phi Y_{i,t-1} + u_{it}   <-- NEW
Y_{it} = alpha^Y_i + beta D_{it} + gamma_Y Z_{i,t-1} + rho_Y Y_{i,t-1} + e_{it}
Z_{it} = alpha^Z_i + delta_D D_{it} + delta_Y Y_{it} + rho_Z Z_{i,t-1} + nu_{it}
```

phi > 0 introduz feedback direto do outcome para o tratamento — violacao classica de strict exogeneity.

### 2.3 DGP + Direct Carryover (Sim 2 — assumption (d) violada)

```
D_{it} = alpha^D_i + gamma_D Z_{i,t-1} + rho_D D_{i,t-1} + u_{it}
Y_{it} = alpha^Y_i + beta D_{it} + beta_2 D_{i,t-1} + gamma_Y Z_{i,t-1} + rho_Y Y_{i,t-1} + e_{it}   <-- NEW
Z_{it} = alpha^Z_i + delta_D D_{it} + delta_Y Y_{it} + rho_Z Z_{i,t-1} + nu_{it}
```

beta_2 > 0 introduz efeito direto do tratamento passado no outcome — o efeito de D nao se esgota em um periodo.

### 2.4 DGP + Feedback + Carryover (Sim 3 — ambas (c) e (d) violadas)

```
D_{it} = alpha^D_i + gamma_D Z_{i,t-1} + rho_D D_{i,t-1} + phi Y_{i,t-1} + u_{it}
Y_{it} = alpha^Y_i + beta D_{it} + beta_2 D_{i,t-1} + gamma_Y Z_{i,t-1} + rho_Y Y_{i,t-1} + e_{it}
Z_{it} = alpha^Z_i + delta_D D_{it} + delta_Y Y_{it} + rho_Z Z_{i,t-1} + nu_{it}
```

Cenario "mais realista" para CP: feedback + carryover + dual-role Z simultaneamente.

### 2.5 Estacionariedade

Todos os DGPs foram verificados via autovalores da matriz companion do VAR(1) reduzido. Restricoes:
- DGP base: estavel para rho_Z <= 0.85
- DGP + feedback: max phi estavel ≈ 0.17 (rho_Z=0.5), ≈ 0.13 (rho_Z=0.7), ≈ 0.02 (rho_Z=0.85)
- DGP + carryover: estavel para beta_2 <= 0.5 (rho_Z <= 0.7); rho_Z=0.85 instavel com beta_2 >= 0.34
- DGP + ambos: restricoes combinadas; phi=0.10 + beta_2=0.3 + rho_Z=0.7 e marginalmente instavel

A restricao de estacionariedade e informativa: **feedback forte (phi > 0.15) e fisicamente dificil em sistemas estacionarios** — um mecanismo natural pelo qual Nickell bias de feedback tende a ser pequeno.

### Nota de interpretacao dos resultados

Em todas as tabelas deste relatorio:

- **Bias** = E[hat(beta)] - beta_true. Como beta_true = 1, um bias de 0.01 significa que a media das estimativas e 1.01 (superestimacao de 1%). Um bias de -0.34 significa que a media e 0.66 (subestimacao de 34%).
- **Bias positivo** = superestimacao do efeito causal; **bias negativo** = subestimacao.
- **RMSE** = sqrt(mean((hat(beta) - beta_true)^2)). Combina bias e variancia: um modelo com bias zero mas alta variancia pode ter RMSE maior que um modelo com bias pequeno e baixa variancia.
- **MCSE** = Monte Carlo standard error = sd / sqrt(N_reps). Mede a precisao da estimativa de bias na simulacao (com 500 reps, MCSE tipico e ~0.001).

## 3. Resultados — DGP Base

### 3.1 Os 8 modelos

Os 8 modelos comparados cruzam tres dimensoes: (i) inclusao de efeitos fixos (FE) de unidade e tempo, (ii) inclusao de Y_{t-1} como controle (ADL), e (iii) inclusao de Z_{t-1} como controle ("long" vs "short"):

| # | Nome | Especificacao | FE | Lags |
|---|------|--------------|-----|------|
| 1 | Pooled_s | Y ~ D | Nao | — |
| 2 | Pooled_l | Y ~ D + Z_lag | Nao | Z_lag |
| 3 | TWFE_s | Y ~ D \| id + time | Sim | — |
| 4 | TWFE_l | Y ~ D + Z_lag \| id + time | Sim | Z_lag |
| 5 | ADL_s_noFE | Y ~ D + Y_lag | Nao | Y_lag |
| 6 | ADL_l_noFE | Y ~ D + Z_lag + Y_lag | Nao | Z_lag, Y_lag |
| 7 | ADL_s_FE | Y ~ D + Y_lag \| id + time | Sim | Y_lag |
| 8 | ADL_l_FE | Y ~ D + Z_lag + Y_lag \| id + time | Sim | Z_lag, Y_lag |

A comparacao short vs long (e.g., modelo 3 vs 4, ou 7 vs 8) isola o **IVB liquido**: a diferenca de bias causada por incluir Z_lag. Se incluir Z_lag reduz |bias|, o papel de confounder domina; se aumenta, o papel de collider domina.

### 3.2 Parametros do grid

O DGP base fixa todos os parametros exceto dois:

- **rho_Z** (autocorrelacao de Z): controla a persistencia temporal de Z. Valores altos (0.7, 0.85) criam cadeias mais longas de colliders herdados (Z_{t-1} -> Z_t -> Z_{t+1} -> ...), amplificando o vies em modelos sem Y_lag.
- **sigma_aZ** (desvio-padrao dos efeitos fixos de Z): controla a variacao entre unidades em Z. Valores altos (2.0 vs 0.5) aumentam o confounding between-unit que os FE de unidade absorvem.

Grid: rho_Z in {0.1, 0.3, 0.5, 0.7, 0.85} x sigma_aZ in {0.5, 2.0} = 10 cenarios x 500 reps.

### 3.3 Hierarquia de estimadores

**Bias por modelo — cenarios representativos (N=100, T=30):**

| rho_Z | sigma_aZ | Pooled_s | Pooled_l | TWFE_s | TWFE_l | ADL_s_noFE | ADL_l_noFE | ADL_s_FE | **ADL_l_FE** |
|-------|----------|----------|----------|--------|--------|------------|------------|----------|------------|
| 0.1 | 0.5 | 1.019 | 0.737 | 0.369 | 0.271 | -0.322 | -0.343 | 0.041 | **0.010** |
| 0.5 | 0.5 | 1.186 | 0.613 | 0.432 | 0.251 | -0.325 | -0.342 | 0.043 | **0.009** |
| 0.5 | 2.0 | 1.462 | 0.800 | 0.432 | 0.252 | -0.354 | -0.334 | 0.042 | **0.009** |
| 0.7 | 0.5 | 1.476 | 0.529 | 0.509 | 0.239 | -0.334 | -0.349 | 0.045 | **0.008** |
| 0.85 | 0.5 | 2.166 | 0.473 | 0.716 | 0.237 | -0.341 | -0.345 | 0.054 | **0.008** |
| 0.85 | 2.0 | 2.297 | 0.785 | 1.034 | 0.241 | -0.394 | -0.338 | 0.066 | **0.008** |

**Leitura da tabela**: ADL_l_FE (modelo 8) tem bias ≈ 0.008-0.010 em todos os cenarios — a media das estimativas de beta e 1.008 a 1.010, praticamente sem vies. Os demais modelos tem bias de 0.04 a 2.30 (4% a 230% de beta_true).

**Hierarquia estavel em todos os 10 cenarios**:
```
ADL_l_FE (0.008-0.010)  <<  ADL_s_FE (0.041-0.066)  <<  TWFE_l (0.237-0.271)
  <<  ADL_l_noFE (-0.334 a -0.349)  <<  TWFE_s (0.369-1.034)  <<  Pooled (0.473-2.297)
```

**Observacoes**:
- Incluir Z_lag sempre reduz bias (short -> long), confirmando que o papel de **confounder domina** no DGP base.
- O IVB liquido do TWFE (TWFE_l - TWFE_s) varia de -0.10 (rho_Z=0.1) a -0.48 (rho_Z=0.85): mais negativo com maior persistencia de Z, mas sempre negativo (Z ajuda).
- FE de unidade sao essenciais: ADL_l_noFE tem bias ≈ -0.34 vs ADL_l_FE com bias ≈ 0.01.
- sigma_aZ afeta pooled e ADL_noFE (confounding between-unit) mas nao TWFE nem ADL_FE (FE absorvem).

### 3.4 Convergencia com T (VaryT)

Testado com rho_Z in {0.5, 0.85} e T in {10, 20, 30, 50, 100}:

**rho_Z = 0.50:**

| T | Pooled_s | Pooled_l | TWFE_s | TWFE_l | ADL_s_noFE | ADL_l_noFE | ADL_s_FE | **ADL_l_FE** |
|---|----------|----------|--------|--------|------------|------------|----------|------------|
| 10 | 1.188 | 0.621 | 0.201 | 0.113 | -0.325 | -0.341 | 0.042 | **0.014** |
| 30 | 1.186 | 0.615 | 0.429 | 0.251 | -0.324 | -0.341 | 0.043 | **0.010** |
| 100 | 1.190 | 0.619 | 0.523 | 0.302 | -0.326 | -0.344 | 0.037 | **0.003** |

**rho_Z = 0.85:**

| T | Pooled_s | Pooled_l | TWFE_s | TWFE_l | ADL_s_noFE | ADL_l_noFE | ADL_s_FE | **ADL_l_FE** |
|---|----------|----------|--------|--------|------------|------------|----------|------------|
| 10 | 2.163 | 0.470 | 0.220 | 0.107 | -0.340 | -0.345 | 0.037 | **0.011** |
| 30 | 2.166 | 0.478 | 0.714 | 0.236 | -0.343 | -0.347 | 0.053 | **0.008** |
| 100 | 2.179 | 0.471 | 1.296 | 0.280 | -0.342 | -0.346 | 0.062 | **0.003** |

**Padroes**:
- **ADL_l_FE -> 0 com T**: bias cai de 0.014 (T=10) para 0.003 (T=100). O vies residual e Nickell bias, que e O(1/T) e desaparece assintoticamente. ADL_l_FE e **consistente**.
- **TWFE_s e TWFE_l crescem com T**: TWFE_s sobe de 0.20 para 1.30 (rho_Z=0.85). O vies e **estrutural** (collider herdado se acumula com mais periodos), nao artefato amostral. TWFE e **inconsistente** neste DGP.
- **ADL_s_FE tambem cresce com T**: de 0.037 para 0.062 (rho_Z=0.85). Sem Z_lag, o ADL com FE tambem e inconsistente — Z omitido causa OVB que se acumula.
- **Pooled e ADL_noFE sao estaveis em T**: o vies e por confounding between-unit (FE omitidos), que nao depende de T.

### 3.5 Firewall (rho_Y = 0)

Quando rho_Y = 0: TWFE_long tem vies ≈ 0. O inherited collider bias **requer rho_Y > 0** para existir. O mecanismo: Y_{t-1} -> Y_t transmite a contaminacao do collider Z_{t-1} para periodos futuros. Sem persistencia do outcome (rho_Y = 0), essa cadeia se quebra.

### 3.6 Assimetria (gamma_D x delta_Y)

ADL_l_FE e melhor modelo em 17/20 cenarios. Incluir Z_lag quase sempre ajuda. Excecao: gamma_D = 0 e delta_Y > 0 (Z e quase puro collider, sem papel de confounder), onde ADL_s_FE ganha por margem minima — nesse caso, incluir Z introduz IVB sem compensacao de OVB.

## 4. Resultados — Direct Feedback (Sim 1)

**Pergunta**: Quando Y afeta D diretamente (violacao de strict exogeneity), o Nickell bias fica substantivo? O ADL+FE+Z ainda domina?

**Grid**: phi in {0, 0.05, 0.10} x rho_Z in {0.5, 0.7} = 6 cenarios x 500 reps.

**6 modelos**:

| # | Nome | Especificacao |
|---|------|--------------|
| 1 | TWFE_s | Y ~ D \| id + time |
| 2 | TWFE_l | Y ~ D + Z_lag \| id + time |
| 3 | ADL_Ylag | Y ~ D + Y_lag \| id + time |
| 4 | ADL_full | Y ~ D + Z_lag + Y_lag \| id + time |
| 5 | Pooled_l | Y ~ D + Z_lag + Y_lag (sem FE) |
| 6 | ADL_Dlag | Y ~ D + D_lag + Z_lag + Y_lag \| id + time |

### 4.1 Bias por modelo

Todos os valores sao bias = E[hat(beta)] - 1 (ver nota de interpretacao na Secao 3).

**rho_Z = 0.50:**

| phi | TWFE_s | TWFE_l | ADL_Ylag | **ADL_full** | Pooled_l | **ADL_Dlag** |
|-----|--------|--------|----------|------------|----------|------------|
| 0.00 | 0.432 | 0.253 | 0.043 | **0.010** | -0.342 | **-0.002** |
| 0.05 | 0.557 | 0.349 | 0.041 | **0.007** | -0.353 | **-0.004** |
| 0.10 | 0.686 | 0.457 | 0.039 | **0.005** | -0.366 | **-0.006** |

**rho_Z = 0.70:**

| phi | TWFE_s | TWFE_l | ADL_Ylag | **ADL_full** | Pooled_l | **ADL_Dlag** |
|-----|--------|--------|----------|------------|----------|------------|
| 0.00 | 0.508 | 0.241 | 0.045 | **0.009** | -0.344 | **-0.003** |
| 0.05 | 0.657 | 0.333 | 0.045 | **0.007** | -0.355 | **-0.004** |
| 0.10 | 0.804 | 0.436 | 0.039 | **0.003** | -0.367 | **-0.008** |

**RMSE (bias + variancia combinados):**

| phi | rho_Z | TWFE_s | ADL_full | Pooled_l | **ADL_Dlag** |
|-----|-------|--------|----------|----------|------------|
| 0.00 | 0.5 | 0.434 | 0.020 | 0.344 | **0.020** |
| 0.05 | 0.5 | 0.559 | 0.020 | 0.355 | **0.020** |
| 0.10 | 0.5 | 0.687 | 0.019 | 0.368 | **0.020** |
| 0.00 | 0.7 | 0.509 | 0.021 | 0.346 | **0.021** |
| 0.05 | 0.7 | 0.658 | 0.020 | 0.357 | **0.020** |
| 0.10 | 0.7 | 0.805 | 0.018 | 0.369 | **0.020** |

### 4.2 Efeito do feedback no ADL_full

| phi | rho_Z | ADL_full bias | Delta vs phi=0 |
|-----|-------|---------------|----------------|
| 0.00 | 0.5 | 0.010 | — |
| 0.05 | 0.5 | 0.007 | -0.003 |
| 0.10 | 0.5 | 0.005 | -0.004 |
| 0.00 | 0.7 | 0.009 | — |
| 0.05 | 0.7 | 0.007 | -0.001 |
| 0.10 | 0.7 | 0.003 | -0.006 |

### 4.3 Achados

1. **ADL_full e ADL_Dlag sao os melhores modelos em todos os 6 cenarios**, com |bias| < 0.01. ADL_Dlag (com D_lag) tem performance marginalmente melhor em 4/6 cenarios, ADL_full em 2/6.

2. **O feedback direto (phi) nao piora o ADL_full** — na verdade, o vies *diminui* levemente com phi. Isso ocorre porque Y_{t-1} ja esta incluido no modelo: ao controlar Y_lag, o canal phi Y_{t-1} -> D_t e parcialmente absorvido.

3. **O TWFE piora com phi**: TWFE_short sobe de 0.43 para 0.69 (rho_Z=0.5) porque o feedback amplifica a correlacao D_{t-1} <-> Y_{t-1} que contamina o estimador sem controle por lags.

4. **FE beneficia mais que Nickell prejudica** em todos os cenarios: ADL_full (com FE) tem bias ~0.005 vs Pooled_l (sem FE) tem bias ~-0.36. O Nickell bias e O(1/T) ≈ 0.03 com T=30, amplamente compensado pelo ganho de absorver confounding between-unit.

5. **Restricao de estacionariedade limita phi**: valores de phi > 0.15-0.17 geram sistemas explosivos. Isso significa que o feedback direto nao pode ser arbitrariamente forte em sistemas estacionarios — um bound natural sobre o Nickell bias por feedback.

### 4.4 Conexao Imai & Kim

Imai & Kim Figure 2(c) mostra que feedback Y -> D viola strict exogeneity, causando Nickell bias quando FE + LDV sao usados. Nossos resultados confirmam a direcao mas mostram que a **magnitude e trivial**: com phi=0.10 e T=30, o vies do ADL_full e < 0.01 (< 1% de beta). A preocupacao e valida em principio, mas quantitativamente negligivel no DGP testado.

A restricao de estacionariedade fornece uma explicacao parcial: feedback forte gera sistemas explosivos, entao em processos estacionarios phi tende a ser pequeno.

## 5. Resultados — Direct Carryover (Sim 2)

**Pergunta**: Quando D tem carryover direto, omitir D_lag causa vies? O modelo "fully dynamic" e necessario?

**Grid**: beta_2 in {0, 0.2, 0.5} x rho_Z in {0.5, 0.7} = 6 cenarios x 500 reps.

**8 modelos**: Os 4 originais + 4 com D_lag (ADL_Dlag, ADL_DYlag, ADL_DZlag, ADL_all).

### 5.1 Vies por modelo

**rho_Z = 0.50, modelos originais (sem D_lag):**

| beta_2 | TWFE_s | TWFE_l | ADL_Ylag | ADL_full |
|--------|--------|--------|----------|----------|
| 0.0 | 0.432 | 0.253 | 0.043 | 0.010 |
| 0.2 | 0.570 | 0.345 | 0.093 | 0.061 |
| 0.5 | 0.783 | 0.483 | 0.181 | 0.151 |

**rho_Z = 0.50, modelos com D_lag (NOVOS):**

| beta_2 | ADL_Dlag | ADL_DYlag | ADL_DZlag | **ADL_all** |
|--------|----------|-----------|-----------|-----------|
| 0.0 | 0.048 | 0.034 | -0.025 | **-0.002** |
| 0.2 | 0.048 | 0.033 | -0.036 | **-0.003** |
| 0.5 | 0.052 | 0.033 | -0.050 | **-0.003** |

**rho_Z = 0.70, modelos originais (sem D_lag):**

| beta_2 | TWFE_s | TWFE_l | ADL_Ylag | ADL_full |
|--------|--------|--------|----------|----------|
| 0.0 | 0.508 | 0.241 | 0.045 | 0.009 |
| 0.2 | 0.663 | 0.332 | 0.096 | 0.062 |
| 0.5 | 0.898 | 0.467 | 0.177 | 0.149 |

**rho_Z = 0.70, modelos com D_lag (NOVOS):**

| beta_2 | ADL_Dlag | ADL_DYlag | ADL_DZlag | **ADL_all** |
|--------|----------|-----------|-----------|-----------|
| 0.0 | 0.087 | 0.043 | -0.026 | **-0.003** |
| 0.2 | 0.096 | 0.044 | -0.035 | **-0.003** |
| 0.5 | 0.113 | 0.042 | -0.045 | **-0.003** |

### 5.2 Beneficio de incluir D_lag

| beta_2 | rho_Z | ADL_full (sem D_lag) | ADL_all (com D_lag) | Melhoria |
|--------|-------|---------------------|--------------------|---------:|
| 0.0 | 0.5 | 0.010 | -0.002 | 0.007 |
| 0.2 | 0.5 | 0.061 | -0.003 | 0.057 |
| 0.5 | 0.5 | 0.151 | -0.003 | 0.148 |
| 0.0 | 0.7 | 0.009 | -0.003 | 0.006 |
| 0.2 | 0.7 | 0.062 | -0.003 | 0.059 |
| 0.5 | 0.7 | 0.149 | -0.003 | 0.146 |

### 5.3 Achados

1. **ADL_all (Y~D+D_lag+Y_lag+Z_lag|FE) e o melhor modelo em TODOS os 6 cenarios**, com vies ≈ 0.003 independente de beta_2 e rho_Z.

2. **Omitir D_lag quando beta_2 > 0 causa vies substancial**: o ADL_full (sem D_lag) tem vies 0.06 quando beta_2=0.2 e 0.15 quando beta_2=0.5. Isso e 6x e 15x o vies de beta respectivamente — **nao e negligivel**.

3. **O vies de omitir D_lag no ADL_full cresce linearmente com beta_2**: de ~0.01 (beta_2=0) para ~0.15 (beta_2=0.5). A omissao de D_lag causa OVB classico.

4. **Quando beta_2 = 0, ADL_full e ADL_all tem performance similar** (0.010 vs -0.002), confirmando que D_lag nao prejudica quando nao pertence ao DGP — apenas adiciona leve ruido.

5. **ADL_DZlag (D_lag + Z_lag sem Y_lag) tem vies negativo**, sugerindo que omitir Y_lag causa vies na direcao oposta. Todos os tres lags sao necessarios quando o DGP os inclui.

### 5.4 Conexao Imai & Kim

Imai & Kim Table 1 (rows 3-4) discutem modelos com D_lag. Assumption (d) — no treatment carryover — e violada quando beta_2 > 0. Nossos resultados mostram que:

- Quando (d) e violada, **D_lag e essencial, nao opcional**
- O modelo "fully dynamic" (row 4 da Table 1: Y ~ D + D_lag + Y_lag + Z_lag | FE) domina
- ADL_full (sem D_lag) que dominava no DGP base agora tem vies substancial

## 6. Resultados — Feedback + Carryover Combinados (Sim 3)

**Pergunta**: No cenario "mais realista" (feedback + carryover + dual-role Z), qual modelo domina?

**Grid**: 5 cenarios (grid irregular por restricoes de estacionariedade — phi=0.10 + beta_2=0.3 + rho_Z=0.7 e marginalmente instavel) x 500 reps.

**9 modelos**: Os mesmos da Sim 2 (8 com FE + ADL_all_noFE para medir Nickell cost).

### 6.1 Bias por modelo

Todos os valores sao bias = E[hat(beta)] - 1.

| phi | beta_2 | rho_Z | TWFE_s | TWFE_l | ADL_full | ADL_DYlag | ADL_DZlag | **ADL_all** | ADL_all_noFE |
|-----|--------|-------|--------|--------|----------|-----------|-----------|-----------|------------|
| 0.05 | 0.2 | 0.5 | 0.754 | 0.485 | 0.058 | 0.032 | 0.025 | **-0.004** | -0.115 |
| 0.05 | 0.2 | 0.7 | 0.873 | 0.459 | 0.056 | 0.039 | 0.022 | **-0.006** | -0.117 |
| 0.10 | 0.2 | 0.7 | 1.700 | 0.730 | 0.052 | 0.052 | 0.136 | **-0.003** | -0.127 |
| 0.10 | 0.3 | 0.5 | 1.095 | 0.736 | 0.076 | 0.028 | 0.099 | **-0.008** | -0.135 |
| 0.05 | 0.3 | 0.7 | 0.992 | 0.521 | 0.082 | 0.039 | 0.025 | **-0.006** | -0.125 |

**RMSE (bias + variancia combinados):**

| phi | beta_2 | rho_Z | TWFE_s | ADL_full | **ADL_all** | ADL_all_noFE |
|-----|--------|-------|--------|----------|-----------|------------|
| 0.05 | 0.2 | 0.5 | 0.755 | 0.060 | **0.020** | 0.117 |
| 0.05 | 0.2 | 0.7 | 0.874 | 0.059 | **0.021** | 0.119 |
| 0.10 | 0.2 | 0.7 | 1.701 | 0.055 | **0.020** | 0.129 |
| 0.10 | 0.3 | 0.5 | 1.096 | 0.078 | **0.021** | 0.137 |
| 0.05 | 0.3 | 0.7 | 0.994 | 0.084 | **0.020** | 0.127 |

### 6.2 Ranking de modelos

ADL_all e o melhor modelo (menor |bias|) em **todos os 5 cenarios**. O cenario phi=0.10/beta_2=0.3/rho_Z=0.5 e o mais exigente:

| Rank | Modelo | |Bias| |
|------|--------|-------|
| 1 | ADL_all | 0.008 |
| 2 | ADL_DYlag | 0.028 |
| 3 | ADL_full | 0.076 |
| 4 | ADL_DZlag | 0.099 |
| 5 | ADL_Ylag | 0.108 |
| 6 | ADL_Dlag | 0.216 |
| 7 | TWFE_l | 0.736 |
| 8 | TWFE_s | 1.095 |

Nota: com phi alto (0.10), ADL_DZlag (sem Y_lag) cai para 4o lugar — Y_lag se torna mais importante que Z_lag quando o feedback e forte.

### 6.3 Comparacao ADL_full vs ADL_all

| phi | beta_2 | rho_Z | ADL_full | ADL_all | Melhoria | % Melhoria |
|-----|--------|-------|----------|---------|----------|-----------:|
| 0.05 | 0.2 | 0.5 | 0.058 | -0.004 | 0.054 | 93% |
| 0.05 | 0.2 | 0.7 | 0.056 | -0.006 | 0.050 | 90% |
| 0.10 | 0.2 | 0.7 | 0.052 | -0.003 | 0.049 | 94% |
| 0.10 | 0.3 | 0.5 | 0.076 | -0.008 | 0.068 | 90% |
| 0.05 | 0.3 | 0.7 | 0.082 | -0.006 | 0.076 | 92% |

### 6.4 Valor marginal de cada lag

Valor marginal = |bias sem lag| - |bias com lag|, medido a partir do ADL_all (modelo completo). Valores positivos significam que o lag reduz |bias|.

| phi | beta_2 | rho_Z | +Z_lag | +Y_lag | +D_lag |
|-----|--------|-------|--------|--------|--------|
| 0.05 | 0.2 | 0.5 | 0.028 | 0.021 | 0.054 |
| 0.05 | 0.2 | 0.7 | 0.033 | 0.017 | 0.050 |
| 0.10 | 0.2 | 0.7 | 0.049 | 0.133 | 0.049 |
| 0.10 | 0.3 | 0.5 | 0.020 | 0.092 | 0.068 |
| 0.05 | 0.3 | 0.7 | 0.033 | 0.018 | 0.076 |

Todos os tres lags contribuem positivamente. D_lag e Y_lag tem os maiores valores marginais; com phi alto (0.10), Y_lag se torna especialmente importante.

### 6.5 Achados

1. **ADL_all domina todos os 5 cenarios** (|bias| ≈ 0.003-0.008), com melhoria de 90-94% sobre ADL_full.

2. **D_lag e o lag com maior valor marginal na maioria dos cenarios** (0.049-0.076), mas com phi=0.10 o Y_lag assume a lideranca (0.092-0.133).

3. **ADL_full, que dominava no DGP base, cai para 2o-3o lugar** quando carryover e feedback estao presentes.

4. **TWFE e dramaticamente pior**: TWFE_short chega a 1.70 de bias (170% de beta) no cenario phi=0.10/beta_2=0.2/rho_Z=0.7.

5. **Nickell cost e amplamente negativo** (FE ajuda): ADL_all com FE tem |bias| ≈ 0.006, vs ADL_all sem FE tem |bias| ≈ 0.12. FE reduz bias em ~95%.

## 7. Sintese

### 7.1 Quando ADL+FE+Z (sem D_lag) e suficiente

O ADL_full (Y ~ D + Z_lag + Y_lag | FE) domina quando:
- **Apenas (b) e violada**: Y tem persistencia (rho_Y > 0) mas sem feedback direto ou carryover
- **Apenas (c) e violada (indiretamente ou diretamente com phi pequeno)**: feedback Y -> D via Z ou phi <= 0.10

Nessas condicoes, o vies e < 0.01 (< 1% de beta) e converge a zero com T.

### 7.2 Quando ADL_all (com D_lag) e necessario

O ADL_all (Y ~ D + D_lag + Y_lag + Z_lag | FE) e necessario quando:
- **(d) e violada**: D tem carryover direto (beta_2 > 0). Omitir D_lag causa vies de ate 15% de beta
- **Ambas (c) e (d) sao violadas**: cenario mais realista em CP

O ADL_all tem vies ≈ 0.003-0.009 em TODOS os cenarios testados.

### 7.3 Trade-offs IVB vs OVB por modelo

| Modelo | IVB (de Z) | OVB (omitir lags/FE) | Net | Quando preferir |
|--------|-----------|---------------------|-----|-----------------|
| TWFE_short | 0 | 0.4-1.3 | Pior | Nunca |
| TWFE_long | -0.18 a -0.48 | 0.43-1.3 | Ruim | Nunca |
| ADL_full (sem D_lag) | -0.03 a -0.04 | Nickell ~0.01 | Bom | Sem carryover |
| **ADL_all** | -0.03 a -0.05 | Nickell ~0.003 | **Melhor** | **Robusto em todos os cenarios testados** |

### 7.4 Mapeamento completo: Assumptions de Imai & Kim

| Assumption violada | Modelo que corrige | Evidencia |
|---|---|---|
| (a) Time-varying confounders | +Z_lag | Sim Base: net benefit TWFE +0.18 a +0.48 |
| (b) Y persistence | +Y_lag (+ FE para Nickell) | Sim Base: firewall gain +0.23 a +0.39 |
| (c) Y -> D feedback | +Y_lag (ja incluido) | Sim 1: ADL_full vies < 0.01 com phi=0.10 |
| (d) D -> Y carryover | **+D_lag** | Sim 2: sem D_lag vies=0.15; com D_lag vies=0.003 |
| (c)+(d) combinadas | +Y_lag + D_lag + Z_lag | Sim 3: ADL_all vies < 0.01; ADL_full vies=0.06-0.08 |

### 7.5 Resultado principal

**O modelo "fully dynamic" (Y ~ D + D_lag + Y_lag + Z_lag | FE) e a especificacao mais robusta em todos os cenarios testados.** Quando D nao tem carryover (beta_2=0), ele tem performance equivalente ao ADL_full (bias ≈ 0.003 vs 0.010). Quando D tem carryover, ele e dramaticamente superior.

O custo de incluir D_lag desnecessariamente e mínimo (leve aumento de variancia). O custo de omiti-lo quando necessario e alto (vies de ate 15% de beta).

## 8. Limitacoes

1. **Estacionariedade restringe parametros**: feedback forte (phi > 0.15) e carryover forte (beta_2 > 0.5 com rho_Z alto) geram sistemas explosivos. Os resultados so valem dentro da regiao estacionaria.

2. **DGP linear e homogeneo**: efeitos constantes no tempo, sem heterogeneidade de tratamento.

3. **Erros i.i.d.**: sem heteroscedasticidade ou correlacao serial.

4. **N=100, T=30 fixos**: nao testamos micro panels (N grande, T pequeno) onde Nickell e mais severo.

5. **Uma variavel Z**: multiplos Z dual-role nao foram explorados.

6. **Identificacao de beta vs beta_total**: quando beta_2 > 0, o efeito "total" de D e beta + beta_2 (sum de contemporaneo e defasado). O ADL_all estima beta (efeito contemporaneo) corretamente, mas o pesquisador pode estar interessado no efeito total.

## 9. Implicacoes para o paper

### O que incluir

1. **Tabela de mapping Imai & Kim** (Secao 7.4): mostra que cada assumption violada tem um controle correspondente, e o modelo fully dynamic cobre todas.

2. **Resultado de carryover**: quando D_{t-1} afeta Y_t diretamente, D_lag e essencial. Isso conecta com a Tabela 1 de Imai & Kim e justifica o ADL_all como recomendacao robusta.

3. **Restricao de estacionariedade como bound natural**: phi forte gera instabilidade, o que naturalmente limita a magnitude do Nickell bias por feedback.

### O que NAO dizer

1. ~~"Imai & Kim se preocupam com Nickell bias"~~ -> Imai & Kim articulam um trade-off entre assumptions (a)-(d). O Nickell bias e consequencia, nao a preocupacao central.

2. ~~"ADL+FE+Z sempre domina"~~ -> Qualificar: domina quando (d) nao e violada. Se D tem carryover, D_lag e necessario.

3. ~~"Nickell bias e sempre negligivel"~~ -> Qualificar: com T=30 e phi <= 0.10. Com T muito pequeno ou phi muito grande, pode ser relevante (embora estacionariedade limite phi).

## 10. Arquivos Produzidos

### Simulacoes base (v1)

| Arquivo | Cenarios | Reps | Modelos |
|---------|----------|------|---------|
| `sim_dual_role_z_8models.R` | 10 | 500 | 8 |
| `sim_dual_role_z_varyT_8models.R` | 10 | 500 | 8 |
| `sim_dual_role_z_firewall.R` | 12 | 500 | 4 |
| `sim_dual_role_z_asymmetry.R` | 20 | 500 | 4 |

### Simulacoes novas (v2)

| Arquivo | Cenarios | Reps | Modelos | O que testa |
|---------|----------|------|---------|-------------|
| `check_stationarity_extended.R` | — | — | — | Estabilidade dos DGPs estendidos |
| `sim_direct_feedback.R` | 6 | 500 | 6 | phi Y_{t-1} -> D_t (assumption (c)) |
| `sim_direct_carryover.R` | 6 | 500 | 9 | beta_2 D_{t-1} -> Y_t (assumption (d)) |
| `sim_feedback_carryover.R` | 5 | 500 | 9 | Ambas (c) + (d) |

CSVs: `*_results.csv` (sumarios), `*_raw.csv` (500 reps x cenarios x modelos).

## 11. Resumo Executivo

**Pergunta v2**: Como feedback direto (Y->D) e carryover direto (D->Y) impactam a interpretacao do IVB e OVB no contexto dual-role Z?

**Resposta**:

1. **Feedback direto (phi Y_{t-1} -> D_t)**: ADL_full (sem D_lag) continua dominante. O Nickell bias adicional e trivial (< 0.01), limitado pela restricao de estacionariedade.

2. **Carryover direto (beta_2 D_{t-1} -> Y_t)**: ADL_full NAO e suficiente — D_lag e essencial. Sem D_lag, vies de ate 15% de beta. O modelo fully dynamic (ADL_all) domina com vies ≈ 0.003.

3. **Combinados**: ADL_all (Y ~ D + D_lag + Y_lag + Z_lag | FE) e a especificacao mais robusta em todos os cenarios testados, com bias < 1% de beta.

**Implicacao pratica**: A recomendacao do paper deve ser o modelo fully dynamic, nao apenas ADL+FE+Z. O custo de incluir D_lag desnecessariamente e mínimo; o custo de omiti-lo quando necessario e alto.
