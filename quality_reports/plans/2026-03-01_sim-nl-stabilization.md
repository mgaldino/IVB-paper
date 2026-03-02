# Plano: Estabilizar simulações de não-linearidade (collider + carryover)

**Status**: COMPLETED
**Data**: 2026-03-01
**Execução**: 2026-03-02

## Contexto

As simulações NL-1a/1c (`sim_nl_collider.R`) e NL-2 (`sim_nl_carryover.R`) explodem com não-linearidades polinomiais (D^2) devido ao feedback loop D → Z → D no DGP. O termo D^2 cria ganho multiplicativo ilimitado que gera divergência quando |D| excede um limiar.

Resultados atuais:
- **poly2 collider**: explode em nl_strength >= 0.5 (18-100% descartados)
- **carryover D^2**: explode em k >= 0.25 (13-100% descartados)
- **log4** e **interação D*H**: totalmente estáveis (0% descartados)

## Objetivo

Adicionar não-linearidades estabilizadas que:
1. Se comportam como D^2 perto da origem (capturam o efeito não-linear)
2. São limitadas ou sub-quadráticas para |D| grande (evitam explosão)
3. São calibradas para serem comparáveis ao poly2 em D = sd_D_within

## Abordagem: duas novas funções + grid refinado

### Novas não-linearidades

| Tipo | f(D) | Comportamento | Limitada? |
|------|------|--------------|-----------|
| **softpoly2** | D^2 / (1 + (D/c)^2), c=2*sd_D | ~D^2 perto de 0, → c^2 para D grande | Sim |
| **power1.5** | sign(D) * \|D\|^1.5 | Super-linear, sub-quadrático | Não (mas derivada cresce como sqrt) |

**Calibração**: Todas as funções são calibradas para que, em D = sd_D_within, a contribuição não-linear = nl_strength × delta_D × sd_D_within. Isso garante comparabilidade direta.

- `delta_softpoly2 = nl_strength * delta_D * 1.25 / sd_D_within`
- `delta_power15 = nl_strength * delta_D / sqrt(sd_D_within)`

Para carryover:
- `beta_nl_softclamp = k * beta * 1.25 / sd_D_within`

### Grid refinado

Também adicionamos nl_strength = {0.1, 0.2} para poly2 (mapear fronteira de estabilidade) e k = {0.05, 0.1} para carryover raw.

## Arquivos modificados

### 1. `sim_nl_collider.R`

- [x] **Header** (L1-22): documentar 4 nl_types
- [x] **Calibração** (após L47): adicionar `c_soft`, `softpoly2_adj`
- [x] **Função** (L50-99): novos params `delta_softpoly2`, `delta_power15`, `c_soft`; novos termos na equação Z
- [x] **Grid** (L102-128): expandir para 4 tipos + nl_strength finos para poly2 + nl_Y=TRUE para softpoly2
- [x] **Loop** (L149-215): extrair novos params do grid, passar para função
- [x] `set.seed(2026100)` antes do loop principal (isolar RNG do piloto)
- [x] `stopifnot` assertion para exclusividade de NL terms no grid

### 2. `sim_nl_carryover.R`

- [x] **Header** (L1-23): documentar 2 carryover_types
- [x] **Calibração** (após L46): adicionar `c_soft`, `softclamp_adj`
- [x] **Função** (L49-96): novo param `carryover_type`, `c_soft`; condicional softclamp na equação Y
- [x] **Grid** (L98-113): expandir para 2 tipos + k finos
- [x] **Loop + Sumário**: adicionar `carryover_type` em todos os `by=.()`, `res_g`, `scale_stats`, `disc_dt`
- [x] `set.seed(2026200)` antes do loop principal
- [x] `k` adicionado ao `res_g` para rastreabilidade no CSV raw
- [x] `use_softclamp` hoisted fora do inner loop

### 3. Sem mudanças em:
- `sim_nl_utils.R` (genérico, funciona com novas não-linearidades)
- `sim_nl_interact.R` (totalmente estável, não precisa de mudanças)

## Resultados

### Collider (42 cenários × 500 reps, 802.1s = ~13.4 min)

#### Estabilidade

| Tipo | nl_Y | Cenários estáveis | Cenários explosivos |
|------|------|-------------------|---------------------|
| **softpoly2** | FALSE | 6/6 (0% discarded) | — |
| **softpoly2** | TRUE | 0/6 (ALL discarded) | 6/6 |
| **log4** | FALSE | 6/6 (0% discarded) | — |
| **power1.5** | FALSE | 4/6 (0% discarded) | 2/6 (nl_str≥1.0/rho=0.7, nl_str=2.0/rho=0.5) |
| **poly2** | FALSE | 3-4/6 | nl_str≥0.5/rho=0.7; fronteira em 0.2/rho=0.7 (22.8%) |
| **poly2** | TRUE | 0/6 | ALL |

**Achado inesperado**: softpoly2 nl_Y=TRUE (Y^2 no canal Y→Z) explode em TODOS os cenários. O clamping no canal D não protege contra explosão pelo canal Y. Isso acontece porque Y = beta*D + rho_Y*Y_lag + eps, portanto Y herda a escala de D amplificada pelo AR(1), e Y^2 pode divergir mesmo com D limitado.

#### Viés (cenários estáveis, nl_Y=FALSE)

| Tipo | nl_strength | rho_Z | ADL_all bias | |IVB/beta| TWFE | IVB ratio vs baseline |
|------|-------------|-------|-------------|---------------|-----------------------|
| **baseline** | 0 | 0.5 | 0.0002 | 0.180 | 1.00 |
| **baseline** | 0 | 0.7 | -0.0012 | 0.270 | 1.00 |
| **softpoly2** | 2.0 | 0.5 | -0.0022 | 0.187 | 1.04 |
| **softpoly2** | 2.0 | 0.7 | -0.0021 | 0.277 | 1.03 |
| **log4** | 2.0 | 0.5 | -0.0024 | 0.203 | 1.12 |
| **log4** | 2.0 | 0.7 | -0.0045 | 0.296 | 1.10 |
| **power1.5** | 1.0 | 0.5 | -0.0025 | 0.337 | 1.87 |
| **power1.5** | 0.5 | 0.7 | -0.0047 | 0.377 | 1.40 |

**ADL_all é o melhor modelo em 23/24 cenários estáveis** (exceção: power1.5 nl_str=1.0/rho=0.7 com apenas 86 reps sobreviventes).

### Carryover (18 cenários × 500 reps, 432.8s = ~7.2 min)

#### Estabilidade

| Tipo | k | rho_Z=0.5 | rho_Z=0.7 |
|------|---|-----------|-----------|
| **softclamp** | 0.25 | 0% disc. | 0% disc. |
| **softclamp** | 0.50 | 0% disc. | 0% disc. |
| **softclamp** | 1.00 | 0% disc. | 0% disc. |
| raw | 0.05 | 0% disc. | 0% disc. |
| raw | 0.10 | 0% disc. | 8.8% disc. |
| raw | 0.25 | 11% disc. | ALL disc. |
| raw | ≥0.50 | ALL disc. | ALL disc. |

**softclamp: 0% discarded em TODOS os 6 cenários.** Sucesso total.

#### Viés (softclamp)

| k | rho_Z | ADL_all bias | |bias|/|beta| |
|---|-------|-------------|--------------|
| 0.25 | 0.5 | -0.0019 | 0.19% |
| 0.25 | 0.7 | -0.0025 | 0.25% |
| 0.50 | 0.5 | -0.0006 | 0.06% |
| 0.50 | 0.7 | -0.0028 | 0.28% |
| 1.00 | 0.5 | 0.0004 | 0.04% |
| 1.00 | 0.7 | -0.0005 | 0.05% |

**ADL_all |bias| < 0.3% de beta em todos os cenários softclamp.**

## Verificação

1. [x] Rodar ambas as simulações — OK
2. [x] Sanity checks:
   - [x] Baseline bias compatível (TWFE_s ≈ 0.43/0.51, ADL_all ≈ 0) — OK
   - [x] softpoly2 nl_Y=FALSE: 0% discarded — OK
   - [x] softclamp: 0% discarded — OK
   - [x] poly2 nl_str=0.1: 0% discarded; nl_str=0.2/rho=0.7: 22.8% — OK (fronteira mapeada)
3. [x] Calibração: softpoly2 bias ≈ baseline para nl_str baixo — OK (ratio 1.00-1.01)
4. [x] CSVs salvos corretamente — OK (collider: 24 rows results, 11185 raw; carryover: 14 rows results)

## Tempo real

- Collider: 802.1s = 13.4 min (42 cenários, muitos explosivos terminaram rápido)
- Carryover: 432.8s = 7.2 min (18 cenários)
- Wall-clock (em paralelo): ~13.4 min
- Estimativa original: ~25 min — real foi quase metade
