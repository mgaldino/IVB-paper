# Relatório: Over-control Contemporâneo

**Data**: 2026-03-22  
**Status**: COMPLETE  
**Script**: `simulations/nonlinearity/sim_overcontrol_contemporaneous.R`  
**Resultados**: `simulations/nonlinearity/results/sim_overcontrol_contemporaneous_results.csv`

## 1. Objetivo

Validar o caso faltante do novo framing: **mediador contemporâneo puro**,

`D_t -> Z_t -> Y_t`, sem `Y_t -> Z_t`.

Perguntas:

1. Incluir `Z_t` contemporâneo gera over-control no painel?
2. O resultado é limpo sob linearidade?
3. O padrão sobrevive sob não linearidade no canal `D -> Z`?
4. Usar `Z_{t-1}` em ADL evita esse problema por timing?

## 2. DGP

O experimento usa:

```text
D_t = alpha_D + rho_D D_{t-1} + u_t
Z_t = alpha_Z + delta_D D_t + f_nl(D_t) + rho_Z Z_{t-1} + nu_t
Y_t = alpha_Y + beta D_t + theta Z_t + rho_Y Y_{t-1} + e_t
```

Parâmetros base:

- `beta = 1.0` (efeito direto)
- `theta = 0.5`
- `delta_D = 0.4`
- `rho_D = 0.5`
- `rho_Y = 0.5`
- `rho_Z in {0.3, 0.7}`
- `N = 100`, `T = 30`, `T_burn = 100`
- `500` repetições por cenário

No caso linear, o efeito total contemporâneo verdadeiro é:

`beta_total = beta + theta * delta_D = 1.2`

## 3. Modelos estimados

- `TWFE short`: `Y ~ D | FE`
- `TWFE bad`: `Y ~ D + Z | FE`
- `ADL(Y_lag)`: `Y ~ D + Y_lag | FE`
- `ADL total`: `Y ~ D + D_lag + Y_lag | FE`
- `ADL bad`: `Y ~ D + D_lag + Y_lag + Z | FE`
- `ADL safe`: `Y ~ D + D_lag + Y_lag + Z_lag | FE`
- `ADL both`: `Y ~ D + D_lag + Y_lag + Z + Z_lag | FE`

O benchmark substantivo para o efeito total no painel dinâmico foi `ADL total`.

## 4. Resultado principal

### 4.1 Linear: over-control aparece com nitidez

Nos cenários lineares:

- `ADL total` ficou em `1.199`-`1.201`, praticamente igual ao efeito total verdadeiro `1.2`
- `ADL bad` ficou em `0.992`-`0.998`, praticamente igual ao efeito direto `1.0`
- `ADL safe` ficou em `1.197`-`1.199`, colado ao benchmark total
- O shift de over-control em ADL foi `-0.203` a `-0.206`

Interpretação:

- Incluir `Z_t` contemporâneo retira exatamente o canal indireto
- Substituir `Z_t` por `Z_{t-1}` evita o over-control contemporâneo

### 4.2 A fórmula IVB funciona exatamente no caso mediador

Em todos os cenários, a diferença:

`coef(ADL bad) - coef(ADL total)`

coincide com:

`-theta_star * pi`

até precisão de máquina. O erro médio absoluto da identidade foi da ordem de `1e-16` a `1e-12`.

## 5. Não linearidade

### 5.1 Bounded NL

Nos casos `log2` e `softpoly2`, o over-control em ADL ficou muito perto do linear:

- `-0.203` a `-0.211`

Ou seja, o padrão substantivo sobrevive quase intacto.

### 5.2 Bounded mas mais forte

No caso `tanh`, o over-control cresce com a força da não linearidade:

- `-0.258` a `-0.434`

Aqui o efeito indireto bloqueado deixa de ser aproximadamente linear, mas o mecanismo continua o mesmo.

### 5.3 Unbounded

No caso `Dlog`, o over-control cresce bastante:

- `-0.406` a `-1.035`

Isto é consistente com o restante das simulações do projeto: formas unbounded podem fazer o deslocamento de projeção linear crescer muito.

### 5.4 Timing continua protegendo

Mesmo nos cenários não lineares, `ADL safe` ficou praticamente igual a `ADL total`:

- `safe_shift_adl` entre aproximadamente `-0.009` e `0.001`

Ou seja, usar `Z_{t-1}` em vez de `Z_t` continua evitando o over-control contemporâneo.

## 6. Achado metodológico importante

`TWFE short` não é um benchmark limpo neste DGP dinâmico.

Ele ficou sistematicamente acima do efeito total:

- linear: `1.552`-`1.586`
- NL forte: até `2.874`

Portanto, no painel dinâmico o contraste mais limpo para comunicar over-control não é:

- `TWFE short` vs `TWFE + Z_t`

e sim:

- `ADL total` vs `ADL + Z_t`

Isto importa para o paper porque evita misturar:

1. over-control do mediador
2. erro de especificação dinâmica por omitir `Y_{t-1}` e `D_{t-1}`

## 7. Implicações para o framing

O gate do mediador está **fechado positivamente** para TSCS:

- o caso linear funciona como previsto
- o caso NL confirma a direção e a robustez qualitativa
- o timing via lags evita o problema
- a fórmula IVB continua válida como diferença entre projeções lineares

## 8. Recomendação editorial

Para o paper:

1. Usar este experimento para sustentar a seção de over-control contemporâneo.
2. Comunicar o resultado principal via **ADL total vs ADL bad vs ADL safe**.
3. Não vender `TWFE short` como benchmark causal limpo no caso dinâmico.
4. Se quiser reforçar o lado DID do título, um experimento extra de 2 períodos seria útil, mas não é necessário para sustentar o claim TSCS do mediador.
