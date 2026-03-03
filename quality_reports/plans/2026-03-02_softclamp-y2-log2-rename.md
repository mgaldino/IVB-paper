# Plano: Softclamp Y² + renomear poly2→log2 em sim_nl_collider.R

**Status**: COMPLETED
**Data**: 2026-03-02

## Contexto

Dois problemas nas simulações NL-1a/1c:

1. **softpoly2 nl_Y=TRUE**: 100% descartados (6/6 cenários) porque Y² na equação de Z não tinha clamping. Y herda escala de D amplificada pelo AR(1), Y² diverge via feedback Z→D→Y→Z.
2. **poly2 nl_Y=TRUE**: 100% descartados porque D² é unbounded. Mesmo com softclamp em Y², o D² cru continuaria causando explosão.

## Mudanças implementadas

### 1. Renomear poly2 → log2

`D[t]^2` (unbounded) substituído por `log(1 + D[t]^2)` (log-bounded).

- Comportamento: ~D² perto da origem, ~2·log|D| longe
- Diferencia de softpoly2 que satura em c_D²
- Nome consistente com log4 (= log(1+D⁴))

### 2. Softclamp Y²

`Y[t]^2` substituído por `Y[t]^2 / (1 + (Y[t]/c_Y)^2)` com `c_Y = 2·sd_Y_within`.

### Equação de Z completa (após mudanças)

```
Z[t] = α_Z[i] + δ_D · D[t]
     + δ_D2       · log(1 + D[t]²)                           ← log2 (era D² cru)
     + δ_log4     · log(1 + D[t]⁴)                           ← inalterado
     + δ_softpoly2 · D[t]² / (1 + (D[t]/c_D)²)              ← inalterado
     + δ_power15  · sign(D[t]) · |D[t]|^1.5                  ← inalterado
     + δ_Y · Y[t]
     + δ_Y2 · Y[t]² / (1 + (Y[t]/c_Y)²)                     ← softclamped (era Y² cru)
     + ρ_Z · Z[t-1] + ν
```

### Calibração

| Coeficiente | Fórmula | Mudança |
|---|---|---|
| `δ_D2` (log2) | `nl_str · δ_D · sd_D / log(1 + sd_D²)` | **nova fórmula** (era `nl_str · δ_D / sd_D`) |
| `δ_Y2` | `nl_str · δ_Y · 1.25 / sd_Y` | **+fator 1.25** (compensa denominador softclamp) |
| demais | inalterados | — |

Constantes: `c_D = 2·sd_D_within`, `c_Y = 2·sd_Y_within`, `softpoly2_adj_Y = 1.25`.

## Arquivo modificado: `sim_nl_collider.R`

- [x] Header: documentar log2, atualizar equação Z com softclamp Y²
- [x] Assinatura: adicionar parâmetro `c_soft_Y`
- [x] DGP (L79-85): `D[t]^2` → `log(1 + D[t]^2)`; `Y[t]^2` → `Y[t]^2/(1+(Y[t]/c_soft_Y)^2)`
- [x] Calibração: `c_soft_Y`, `softpoly2_adj_Y`, nova fórmula δ_D2, fator 1.25 em δ_Y2
- [x] Grid: `"poly2"` → `"log2"` em CJ, filtros e comentários
- [x] Loop: passar `c_soft_Y` na chamada da função
- [x] Print header: `poly2` → `log2`

## Verificação — RESULTADOS (rodado 2026-03-02, 1402s ≈ 23 min)

1. [x] **log2 nl_Y=TRUE**: 0% discarded em todos 6 cenários (antes poly2: 100%)
2. [x] **softpoly2 nl_Y=TRUE**: 0% discarded em todos 6 cenários (antes: 100%)
3. [x] **log2 nl_Y=FALSE**: 0% discarded (antes poly2: 22-100% em nl_str≥0.2)
4. [x] log4, softpoly2 nl_Y=FALSE: inalterados (0%)
5. [x] power1.5: continua instável em nl_str≥1.0/rho=0.7 (426/500) e nl_str=2.0 (182-500) — esperado, unbounded
6. [x] **ADL_all é melhor modelo em 41/41 cenários** (|bias| < 0.005)
7. [x] IVB ratio (nl/baseline): log2 e softpoly2 ficam em 1.00-1.25 mesmo com nl_strength=2.0 e nl_Y=TRUE

### Plots de funções gerados

- `plots/nl_functions_D_raw.png` — funções f(D) raw (sem calibração)
- `plots/nl_functions_D_calibrated.png` — contribuição calibrada δ_nl·f(D) com nl_strength=1
- `plots/nl_functions_Y_softclamp.png` — Y² raw vs softclamped

## Resultado substantivo: impacto da não-linearidade no IVB

### Pergunta central
Quanto a não-linearidade no canal collider (D→Z e Y→Z) aumenta o IVB?

### IVB ratio = IVB(nl) / IVB(baseline linear)

**TWFE (|IVB/beta| e ratio vs baseline):**

| Tipo | nl_Y | nl_str=0.5 | nl_str=1.0 | nl_str=2.0 |
|---|---|---|---|---|
| **log2** | FALSE | 1.00–1.01 | 1.01–1.02 | 1.04–1.05 |
| **log2** | TRUE | 1.00–1.03 | 1.00–1.07 | 0.99–1.23 |
| **softpoly2** | FALSE | 0.99–1.00 | 1.00–1.01 | 1.02–1.04 |
| **softpoly2** | TRUE | 0.99–1.02 | 0.99–1.07 | 0.93–1.22 |
| **log4** | FALSE | 0.99–1.01 | 1.01–1.04 | 1.10–1.13 |
| **power1.5** | FALSE | 1.38–1.40 | 1.87–2.47 | 3.51+ (instável) |

**ADL (max |IVB/beta| em %):**

| Tipo | nl_Y=FALSE | nl_Y=TRUE |
|---|---|---|
| **log2** | 3.9% | 4.6% |
| **softpoly2** | 3.9% | 4.6% |
| **log4** | 4.1% | — |
| **power1.5** | 47.2% (instável) | — |

### Interpretação

1. **Para não-linearidades bounded (log2, softpoly2, log4)**: o IVB aumenta no máximo ~25% vs baseline linear, mesmo com nl_strength=2.0 e nl_Y=TRUE. Em termos absolutos, |IVB_ADL| < 5% de beta. A conclusão "IVB é pequeno" **sobrevive à não-linearidade**.

2. **Para power1.5 (unbounded, sub-quadrática)**: o IVB cresce substancialmente — ratio 1.4–3.5x no TWFE. Cenários com nl_str≥1.0 e rho_Z=0.7 são instáveis (85-100% descartados). A conclusão "IVB é pequeno" **não se sustenta** para não-linearidades unbounded fortes.

3. **Efeito de nl_Y (não-linearidade no canal Y→Z)**: adicionar Y² softclamped aumenta o IVB em ~20% no caso extremo (nl_str=2.0), mas o efeito é modesto para nl_str≤1.0 (~5-7%).

4. **ADL_all continua sendo o melhor modelo em 41/41 cenários** — a inclusão de todos os lags minimiza o viés mesmo sob não-linearidade.

### Conclusão para o paper

> Sob não-linearidades realistas (bounded), o IVB permanece pequeno (<5% de beta no ADL). A formula IVB = −θ*·π continua sendo um bom diagnóstico. O resultado só falha para não-linearidades unbounded severas (power1.5 com nl_str≥1), que são implausíveis na maioria das aplicações em CP (onde variáveis são tipicamente bounded ou log-transformadas).
