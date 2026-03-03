# Plano: Simulações de Não-Linearidade para IVB

**Status**: DRAFT
**Data**: 2026-03-01

## Contexto

O resultado central do paper é que sob linearidade, o IVB de incluir Z dual-role é pequeno (<1% de β). Isso sustenta que ADL+FE domina MSM/IPTW em CP. Precisamos delimitar **quando** esse resultado quebra — i.e., quando a não-linearidade no DGP torna o IVB substantivo.

O pesquisador sempre estima modelos lineares (TWFE, ADL). FWL ainda funciona (linearidade nos parâmetros). O IVB = β_long - β_short é bem-definido. A pergunta: a **magnitude** do IVB muda quando o DGP verdadeiro tem termos não-lineares que o pesquisador não modela?

## Arquivos a criar

| Arquivo | Simulação | Cenários | O que testa |
|---------|-----------|----------|-------------|
| `sim_nl_collider.R` | Polinomial D→Z (± Y→Z) | ~16 | IVB com collider não-linear |
| `sim_nl_interact.R` | Interação D×H→Z | ~10 | IVB com heterogeneidade no collider |
| `sim_nl_carryover.R` | Carryover D→Y não-linear | ~10 | Misspecification no carryover × IVB |

**Total**: ~36 cenários × 500 reps. Runtime estimado: ~20 min.

Todos em `/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/`.

## Template: `sim_direct_carryover.R`

Todos os arquivos seguem a mesma estrutura:
- DGP function → estimation function → grid (CJ) → for-loop com lapply → summary → print → CSV save + sessionInfo
- Sem future_lapply (lapply sequencial)
- feols com vcov = "iid"
- set.seed(2026)
- Parâmetros fixos: N=100, T=30, T_burn=100, β=1, ρ_Y=0.5, ρ_D=0.5, γ_D=0.15, γ_Y=0.2, δ_D=0.1, δ_Y=0.1, σ_aZ=0.5

## Calibração dos coeficientes não-lineares

**Problema**: D² e D³ precisam de coeficientes calibrados para contribuir de forma comparável ao termo linear.

**Solução**: Pilot run (10 reps do DGP linear baseline) para medir sd(D_within) e sd(Y_within). Depois calibrar:

- `δ_D2 = k × δ_D / sd_D_within` — no ponto D = sd(D), termo quadrático = k × termo linear
- `δ_D3 = k × δ_D / sd_D_within²` — idem para cúbico
- `δ_Y2 = k × δ_Y / sd_Y_within` — idem para canal Y→Z
- `β_nl = k × β / sd_D_within` — idem para carryover

Onde k = {0.5, 1.0, 2.0} representa força fraca/moderada/forte da não-linearidade.

O pilot run é a **primeira coisa** em cada arquivo de simulação.

## DGPs

### sim_nl_collider.R — Polinomial D→Z (± Y→Z)

Combina NL-1a e NL-1c num único arquivo/DGP:

```
D_t = α_D + γ_D × Z_{t-1} + ρ_D × D_{t-1} + u_t
Y_t = α_Y + β × D_t + γ_Y × Z_{t-1} + ρ_Y × Y_{t-1} + ε_t
Z_t = α_Z + δ_D × D_t + δ_D2 × D_t² [+ δ_D3 × D_t³]
      + δ_Y × Y_t + δ_Y2 × Y_t²
      + ρ_Z × Z_{t-1} + ν_t
```

**Grid**:

```r
grid <- CJ(
  degree   = c(2, 3),              # grau do polinômio em D
  nl_strength = c(0, 0.5, 1.0, 2.0),  # k (0 = baseline linear)
  nl_Y     = c(FALSE, TRUE),       # não-linearidade também em Y→Z?
  rho_Z    = c(0.5, 0.7)
)
# Remover combinações redundantes:
# - degree irrelevante quando nl_strength=0
# - nl_Y irrelevante quando nl_strength=0
# Baseline: nl_strength=0, nl_Y=FALSE → 2 rows (uma por rho_Z)
# NL-1a: nl_Y=FALSE, nl_strength>0 → 6 combinações × 2 rho_Z = 12 rows
# NL-1c: nl_Y=TRUE, nl_strength>0, degree=2 apenas → 3 × 2 = 6 rows
# Total: ~16-20 cenários
```

Quando nl_strength=0: δ_D2=δ_D3=δ_Y2=0 (baseline linear, deve reproduzir resultados existentes).

### sim_nl_interact.R — Interação D×H→Z

```
H_it ~ N(0,1)   [exógena, iid, NÃO aparece na eq. de Y]
D_t = α_D + γ_D × Z_{t-1} + ρ_D × D_{t-1} + u_t
Y_t = α_Y + β × D_t + γ_Y × Z_{t-1} + ρ_Y × Y_{t-1} + ε_t
Z_t = α_Z + δ_D × D_t + δ_DH × D_t × H_t + δ_Y × Y_t + ρ_Z × Z_{t-1} + ν_t
```

**Grid**:

```r
grid <- CJ(
  delta_DH = c(0, 0.05, 0.1, 0.2, 0.4),  # 0 = baseline
  rho_Z    = c(0.5, 0.7)
)
# 5 × 2 = 10 cenários
```

H é iid N(0,1), não persistente. O pesquisador não observa H e não inclui D×H.

**Predição**: Como E[D×H|D] = 0, o IVB médio pode permanecer similar ao baseline. A interação aumenta a variância do "erro efetivo" de Z, o que pode atenuar θ* (efeito semelhante a measurement error). Se confirmado, resultado positivo para o paper.

### sim_nl_carryover.R — Carryover não-linear D→Y

```
D_t = α_D + γ_D × Z_{t-1} + ρ_D × D_{t-1} + u_t
Y_t = α_Y + β × D_t + β_nl × D_{t-1}² + γ_Y × Z_{t-1} + ρ_Y × Y_{t-1} + ε_t
Z_t = α_Z + δ_D × D_t + δ_Y × Y_t + ρ_Z × Z_{t-1} + ν_t
```

**Grid**:

```r
grid <- CJ(
  beta_nl = c(0, 0.125, 0.25, 0.5),  # k ≈ 0, 0.25, 0.5, 1.0
  rho_Z   = c(0.5, 0.7)
)
# 4 × 2 = 8 cenários (+ 2 baseline = 10)
```

O pesquisador inclui D_lag linear no ADL_all, mas o DGP tem D_lag². Misspecification do carryover.

## Modelos estimados (iguais em todos os arquivos)

Os mesmos 9 modelos lineares de `sim_direct_carryover.R`:

| # | Nome | Especificação |
|---|------|--------------|
| 1 | twfe_s | Y ~ D \| FE |
| 2 | twfe_l | Y ~ D + Z_lag \| FE |
| 3 | adl_Ylag | Y ~ D + Y_lag \| FE |
| 4 | adl_full | Y ~ D + Z_lag + Y_lag \| FE |
| 5 | adl_Dlag | Y ~ D + D_lag \| FE |
| 6 | adl_DYlag | Y ~ D + D_lag + Y_lag \| FE |
| 7 | adl_DZlag | Y ~ D + D_lag + Z_lag \| FE |
| 8 | adl_all | Y ~ D + D_lag + Y_lag + Z_lag \| FE |
| 9 | adl_all_nofe | Y ~ D + D_lag + Y_lag + Z_lag (sem FE) |

## Estacionariedade

Não é possível usar companion matrix (sistema não-linear). Abordagem empírica:

1. **Guard por replicação**: Se max(|D|, |Y|, |Z|) > 1e6, retorna NULL (descartada)
2. **Contagem**: Reportar quantas reps foram descartadas por cenário
3. **Regra**: Se >10% descartadas, flag no output. Se >50%, marcar cenário como "instável"

## Output (por arquivo)

4 arquivos cada:
1. `sim_nl_XXX_results.csv` — sumário (bias, MCSE, sd, RMSE por cenário × modelo)
2. `sim_nl_XXX_raw.csv` — todas as 500 reps
3. `sim_nl_XXX_timing.csv` — tempo por cenário
4. `sim_nl_XXX_sessioninfo.txt`

**Console output** — mesmas decomposições das sims existentes + seção nova:

```
F. EFEITO DA NÃO-LINEARIDADE (comparação com baseline linear)
   Delta_bias = bias(nl) - bias(linear)
   Delta_IVB  = IVB(nl) - IVB(linear)
   IVB_ratio  = IVB(nl) / IVB(linear)
```

**Sanity checks**:
1. Quando nl_strength=0 (ou equivalente), resultados devem bater com baseline linear
2. Reportar mean/sd de D, Y, Z por cenário para verificar escala razoável

## Ordem de implementação

1. `sim_nl_collider.R` — mais diretamente ligado ao argumento do paper
2. `sim_nl_interact.R` — extensão simples
3. `sim_nl_carryover.R` — mecanismo diferente

## Predições teóricas

| Sim | Predição | Se confirmado |
|-----|----------|--------------|
| NL-1a (poly D→Z) | IVB ↑ com nl_strength | Delimita quando ADL+FE funciona |
| NL-1b (interação) | IVB ≈ estável (E[D×H\|D]=0) | Reforça robustez do resultado |
| NL-1c (poly ambos) | IVB > NL-1a (caso adverso) | Bound superior para IVB |
| NL-2 (carryover) | Misspecification ⊥ IVB? | D_lag linear absorve parcialmente |

## Verificação

- [ ] Pilot run calibra sd(D_within) e sd(Y_within) corretamente
- [ ] Baseline (nl_strength=0) reproduz resultados lineares existentes
- [ ] Nenhum cenário com >50% de reps descartadas
- [ ] Decomposição F (efeito da não-linearidade) reportada
- [ ] Arquivos CSV e sessioninfo salvos
