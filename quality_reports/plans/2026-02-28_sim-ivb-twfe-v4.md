# Plano: Simulacao v4 — Por que o IVB e pequeno? Decomposicao between/within dos canais causais

**Status**: DRAFT
**Data**: 2026-02-28

## Problema

A simulacao v1 mostrou que IVB/|beta| e constante em R2_within. Isso porque gamma_D opera sobre D_total — apos TWFE, pi = gamma_D + gamma_Y*beta independentemente da decomposicao between/within de D. A simulacao era tautologica: so confirmava a formula.

A intuicao do usuario e: **variaveis com baixa variacao within tendem a ter IVB pequeno**. Mas o DGP da v1 nao captura isso porque o canal D→Z nao distingue entre efeitos between e within. Na realidade:
- D pode causar Z primariamente pelo canal between (paises democraticos tem PIB mais alto em nivel)
- Apos TWFE absorver o between, so sobra o canal within de D→Z
- Se esse canal within e fraco, pi e pequeno, e IVB e pequeno

## Abordagem: Multiplos mecanismos

Todos exploram como a estrutura do DGP interage com TWFE para reduzir pi e/ou theta*. Nao se trata de variar pi e theta diretamente (tautologico), mas de variar **caracteristicas estruturais** que fazem pi e theta serem pequenos apos absorver FE.

---

## Mecanismo A: Decomposicao between/within de D→Z

**DGP modificado** (caso clean, delta=0):
```
Y_it = beta * D_it + alpha_i + lambda_t + eps_it          [igual v1]

Z_it = gamma_D_btw * mu_i^D + gamma_D_wth * (D_it - mu_i^D)
       + gamma_Y * Y_it + eta_i + mu_t + nu_it             [NOVO]
```

- gamma_D_btw: efeito de D sobre Z pelo canal between (niveis cross-seccionais)
- gamma_D_wth: efeito de D sobre Z pelo canal within (mudancas temporais)
- Apos TWFE: gamma_D_btw * mu_i^D absorvido pelo unit FE

**Algebra apos TWFE**:
```
Z_tilde = (gamma_D_wth + gamma_Y*beta) * d_it + (nu_it + gamma_Y*eps_it)
D_tilde = d_it
```

**Resultado**: pi = gamma_D_wth + gamma_Y*beta

Quando gamma_D_btw >> gamma_D_wth (D causa Z primariamente em niveis), pi e pequeno, e IVB e pequeno. O v1 e o caso especial gamma_D_btw = gamma_D_wth.

**Insight para o pesquisador**: "Mesmo que D e Z sejam fortemente associados nos seus dados brutos, o IVB pode ser pequeno se essa associacao e cross-seccional (entre paises) e nao temporal (dentro de paises), pois TWFE absorve o canal between."

---

## Mecanismo B: Decomposicao between/within de Y→Z

**DGP modificado**:
```
Z_it = gamma_D * D_it + gamma_Y_btw * bar(Y_i) + gamma_Y_wth * (Y_it - bar(Y_i))
       + eta_i + mu_t + nu_it
```

- gamma_Y_btw: Y causa Z pelo canal between (unidades com Y alto tem Z alto em nivel)
- gamma_Y_wth: Y causa Z pelo canal within (quando Y muda, Z muda)
- Apos TWFE: gamma_Y_btw * bar(Y_i) absorvido pelo unit FE

**Resultado**: theta* depende apenas de gamma_Y_wth

Quando Y→Z e primariamente between, theta* e pequeno apos FE, e IVB e pequeno.

**Insight**: "Se a correlacao entre Y e Z e primariamente cross-seccional (paises mais desiguais tem PIB mais alto), theta* apos FE e pequeno."

---

## Mecanismo C: D binario com adocao escalonada

**DGP modificado**: D e binario (0/1), transicao irreversivel:
```
D_it = 1(t >= T_i*)     onde T_i* ~ Uniforme em {2,...,T} para switchers
```

- Fracao de "switchers" controlada por prob_switch
- Unidades never-treated (D=0 sempre) e always-treated (D=1 sempre) contribuem zero variacao within
- Apos TWFE: pi e estimado apenas com base nos switchers
- pi em populacao = gamma_D + gamma_Y*beta (mesmo valor), MAS:
  - SE e muito maior com poucos switchers
  - IVB/SE e mecanicamente menor
  - O DGP e mais realista para ciencia politica (democratizacao, peacekeeping)

---

## Mecanismo D: Erro de medida em Z (atenuacao de theta*)

**DGP modificado**: Pesquisador observa Z com erro:
```
Z_obs_it = Z_true_it + measurement_error_it
measurement_error_it ~ N(0, sigma2_me)
```

- theta* estimado com Z_obs e atenuado em direcao a zero (attenuation bias classico)
- Atenuacao e proporcional a sigma2_me / (sigma2_me + Var(Z_true_tilde))
- Se Z tem erro de medida alto, theta* → 0, e IVB → 0

**Insight**: "Variaveis de controle medidas com erro tem theta* atenuado, reduzindo o IVB. Isso e especialmente relevante para variaveis socioeconomicas em paineis longos."

---

## Grid de parametros

### Simulacao principal (Mecanismo A)

| Parametro | Significado | Valores |
|-----------|-------------|---------|
| gamma_D_btw | D→Z canal between | 0.0, 0.3, 0.6, 0.9 |
| gamma_D_wth | D→Z canal within | 0.0, 0.2, 0.5 |
| gamma_Y | Y→Z (total, como v1) | 0.0, 0.3, 0.6 |
| R2_within | fracao within de D | 0.1, 0.5, 0.9 |

**Fixos**: N=200, T=30, beta=1, delta=0, sigma2_eps=sigma2_nu=1, nsim=500.
**Total**: 4 x 3 x 3 x 3 = 108 cenarios x 500 reps.

### Simulacao complementar (Mecanismo B)

| Parametro | Significado | Valores |
|-----------|-------------|---------|
| gamma_D | D→Z total | 0.3, 0.6 |
| gamma_Y_btw | Y→Z canal between | 0.0, 0.3, 0.6, 0.9 |
| gamma_Y_wth | Y→Z canal within | 0.0, 0.2, 0.5 |
| R2_within | fracao within de D | 0.1, 0.5, 0.9 |

**Total**: 2 x 4 x 3 x 3 = 72 cenarios x 500 reps.

### Simulacao complementar (Mecanismo C — D binario)

| Parametro | Significado | Valores |
|-----------|-------------|---------|
| prob_switch | fracao que muda D | 0.1, 0.3, 0.5, 0.7 |
| gamma_D | D→Z | 0.3, 0.6 |
| gamma_Y | Y→Z | 0.3, 0.6 |

**Fixos**: N=200, T=30.
**Total**: 4 x 2 x 2 = 16 cenarios x 500 reps.

### Simulacao complementar (Mecanismo D — erro de medida)

| Parametro | Significado | Valores |
|-----------|-------------|---------|
| sigma2_me | variancia do erro de medida em Z | 0.0, 0.5, 1.0, 2.0 |
| gamma_D | D→Z | 0.3, 0.6 |
| gamma_Y | Y→Z | 0.3, 0.6 |

**Total**: 4 x 2 x 2 = 16 cenarios x 500 reps.

**Total geral**: 108 + 72 + 16 + 16 = 212 cenarios x 500 reps. Tempo estimado: ~10-15 min.

## Predicoes teoricas

### Mecanismo A:
1. IVB depende de gamma_D_wth, NAO de gamma_D_btw (faixas horizontais no heatmap)
2. IVB/|beta| constante em R2_within (confirma v1)
3. Para gamma_D_btw=0.9, gamma_D_wth=0.0: IVB ≈ -theta* * gamma_Y*beta (so via Y→Z)

### Mecanismo B:
4. theta* depende de gamma_Y_wth, NAO de gamma_Y_btw (analogo ao A)

### Mecanismo C:
5. IVB/SE diminui com prob_switch baixo (poucos switchers → SE grande)
6. pi em populacao nao muda, mas precisao cai

### Mecanismo D:
7. |theta*| diminui com sigma2_me (attenuation bias)
8. IVB diminui proporcionalmente

### Sintese:
9. Estudos empiricos do paper tem: D lento/binario (C), D→Z primariamente between (A), Y→Z possivelmente between (B), Z medido com ruido (D). Todos esses mecanismos empurram IVB para baixo.

## Figuras planejadas

1. **Heatmap A**: |IVB/beta| vs (gamma_D_btw, gamma_D_wth) — faixas horizontais
2. **Line A**: |IVB/beta| vs gamma_D_btw (flat) — FE absorve o canal between
3. **Comparacao v1 vs v4**: IVB em funcao de share_within do canal D→Z
4. **Heatmap B**: |IVB/beta| vs (gamma_Y_btw, gamma_Y_wth) — analogo
5. **Bar C**: |IVB/SE| vs prob_switch — cai com menos switchers
6. **Line D**: |theta*| vs sigma2_me — atenuacao
7. **Tabela sintese**: condicoes para IVB < 1 SE

## Implementacao

### Arquivo: `sim_ivb_twfe_v4.R`
- Reutiliza estrutura de sim_ivb_twfe.R (paralelo, metricas, etc)
- generate_panel_data_v4(): aceita gamma_D_btw, gamma_D_wth (ou gamma_Y_btw, gamma_Y_wth)
- generate_panel_data_binary(): DGP com D binario (mecanismo C)
- Secoes separadas para cada mecanismo (A, B, C, D)

### Arquivo: `sim_ivb_twfe_v4_figures.R`
- Gera figuras 1-7

## Verificacao

- [ ] gamma_D_btw = gamma_D_wth = gamma_D: resultados identicos ao v1
- [ ] pi ≈ gamma_D_wth + gamma_Y*beta (confirmar)
- [ ] IVB independente de gamma_D_btw
- [ ] theta* independente de gamma_Y_btw (Mecanismo B)
- [ ] IVB/SE cai com prob_switch baixo (Mecanismo C)
- [ ] |theta*| cai com sigma2_me (Mecanismo D)
- [ ] Coverage_short ≈ 0.95 em todos os cenarios

## Relacao com v3

O plano v3 (aprovado pelo DA, 90/100) contem:
- Parte 1: Ferramenta analitica ivb_diagnostic() — MANTEM, e complementar
- Parte 2: Overlay empirico (extrair theta*/pi dos estudos) — MANTEM
- Parte 3: Validacao amostra finita — SUBSTITUIDA por esta simulacao v4

Esta simulacao responde a pergunta original "quando o IVB e grande?" de forma nao-tautologica, enquanto a ferramenta analitica (v3 Parte 1) da ao pesquisador uma forma de diagnosticar o IVB nos seus proprios dados.
