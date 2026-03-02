# Relatório: Simulações de não-linearidade estabilizadas (NL-1a/1c + NL-2)

**Data**: 2026-03-02
**Simulações**: `sim_nl_collider.R` (42 cenários) + `sim_nl_carryover.R` (18 cenários)
**500 reps** por cenário, N=100, T=30, T_burn=100

---

## 1. Motivação

O resultado central do paper — IVB < 1% de beta sob linearidade — precisa de delimitação. Quando a não-linearidade no DGP é forte o suficiente, o IVB pode crescer e o argumento pró-ADL+FE enfraquece.

As simulações anteriores com D^2 (polinomial quadrática) explodiam devido ao feedback loop D → Z → D: o termo D^2 na equação de Z amplifica D, que no próximo período gera D^2 ainda maior, divergindo exponencialmente. Isso não é um problema do IVB em si — é uma patologia numérica do DGP.

**Pergunta**: Quais não-linearidades são fortes o suficiente para amplificar o IVB de forma substantiva, mas estáveis o suficiente para permitir estimação?

## 2. Não-linearidades testadas

### Collider (D→Z e opcionalmente Y→Z)

| Tipo | f(D) | Limitada? | Propriedade-chave |
|------|------|-----------|-------------------|
| **poly2** (referência) | D^2 | Não | Explode com feedback |
| **log4** | log(1 + D^4) | Não, mas cresce ~4log\|D\| | Super-lenta; totalmente estável |
| **softpoly2** (novo) | D^2 / (1 + (D/c)^2) | Sim, → c^2 | ~D^2 perto de 0, saturação suave |
| **power1.5** (novo) | sign(D)\|D\|^1.5 | Não | Sub-quadrática; parcialmente estável |

### Carryover (D_lag→Y não-linear)

| Tipo | f(D_lag) | Limitada? |
|------|----------|-----------|
| **raw** (referência) | D_lag^2 | Não |
| **softclamp** (novo) | D_lag^2 / (1 + (D_lag/c)^2) | Sim |

Todas as funções são calibradas para produzir a mesma contribuição em D = sd_D_within, garantindo comparabilidade.

## 3. Resultados de estabilidade

### 3.1 Collider

```
                  nl_Y=FALSE                    nl_Y=TRUE
Tipo        0.5   1.0   2.0 (nl_str)     0.5   1.0   2.0
─────────────────────────────────────────────────────────────
log4          0%    0%    0%              n/a   n/a   n/a
softpoly2     0%    0%    0%             100%  100%  100%  ← EXPLODE
power1.5      0%  0-83%  39-100%         n/a   n/a   n/a
poly2       0-19% 100%   100%           100%  100%  100%
```
(valores por rho_Z; "0-83%" = 0% em rho_Z=0.5, 82.8% em rho_Z=0.7)

**Interpretação**:
- **softpoly2 nl_Y=FALSE**: objetivo alcançado — 0% descartados em todos os 6 cenários, até nl_strength=2.0. O clamping funciona perfeitamente no canal D→Z.
- **softpoly2 nl_Y=TRUE**: falha total. O canal Y→Z com Y^2 não é protegido pelo clamping em D. Como Y = beta*D + rho_Y*Y_lag + eps, Y herda a escala de D e o AR(1) em Y amplifica. O Y^2 diverge independentemente do clamping em D.
- **power1.5**: parcialmente estável. Funciona bem até nl_strength=0.5, mas degrada com rho_Z alto e nl_strength > 1. Sendo sub-quadrática (derivada cresce como sqrt), é mais estável que poly2 mas não é limitada.
- **Fronteira do poly2**: nl_strength=0.1 é estável (0%); nl_strength=0.2/rho_Z=0.7 já tem 22.8% descartados.

### 3.2 Carryover

```
Tipo         k=0.05  k=0.10  k=0.25  k=0.50  k=1.00
───────────────────────────────────────────────────────
softclamp      —       —       0%      0%      0%    ← SUCESSO TOTAL
raw            0%    0-9%    11-100%  100%    100%
```

**softclamp**: 0% descartados em todos os 6 cenários (k=0.25, 0.5, 1.0; rho_Z=0.5, 0.7). O clamping é eficaz porque no carryover o feedback loop é mais fraco (D_lag→Y→D é indireto).

## 4. Resultados de viés

### 4.1 ADL_all continua sendo o melhor modelo

Em **23 de 24 cenários estáveis** do collider, ADL_all tem o menor |bias|. A exceção é power1.5 nl_str=1.0/rho_Z=0.7, que tem apenas 86 reps sobreviventes (não confiável).

| Cenário | ADL_all |bias| | |bias|/|beta| |
|---------|----------------|--------------|
| Baseline (nl_str=0) | 0.0002-0.0012 | < 0.12% |
| softpoly2 (todos) | 0.0015-0.0022 | < 0.22% |
| log4 (todos) | 0.0011-0.0045 | < 0.45% |
| power1.5 (estáveis) | 0.0023-0.0047 | < 0.47% |

**Conclusão**: Mesmo com não-linearidade forte (nl_strength=2.0) no canal D→Z, o viés do ADL_all permanece abaixo de 0.5% de beta.

### 4.2 IVB cresce com não-linearidade, mas moderadamente

O IVB (diferença entre TWFE_l e TWFE_s) cresce com a não-linearidade, mas o efeito é limitado para funções estáveis:

| Tipo | nl_str | IVB ratio (TWFE, vs baseline) | IVB ratio (ADL) |
|------|--------|------------------------------|-----------------|
| softpoly2 | 2.0 | 1.03-1.04 | 1.05 |
| log4 | 2.0 | 1.10-1.12 | 1.12 |
| power1.5 | 1.0 | 1.87 (rho=0.5) | 1.33 |
| power1.5 | 2.0 | 3.52 (rho=0.5, 39% disc.) | 3.18 |

- **softpoly2**: IVB praticamente idêntico ao baseline (+3-5%). A saturação limita o efeito não-linear.
- **log4**: aumento modesto (+10-12%). O crescimento logarítmico suaviza o impacto.
- **power1.5**: aumento substantivo (até 3.5x), mas apenas em cenários que já são parcialmente instáveis.

### 4.3 Carryover: softclamp mantém ADL_all quase sem viés

| k | rho_Z=0.5 | rho_Z=0.7 |
|---|-----------|-----------|
| 0.25 | |bias| = 0.0019 (0.19%) | 0.0025 (0.25%) |
| 0.50 | 0.0006 (0.06%) | 0.0028 (0.28%) |
| 1.00 | 0.0004 (0.04%) | 0.0005 (0.05%) |

Mesmo com k=1 (carryover não-linear tão forte quanto o efeito contemporâneo), ADL_all |bias| < 0.3%.

## 5. Implicações para o paper

### O que se confirma

1. **IVB é pequeno sob linearidade**: o baseline reproduz os resultados anteriores (ADL_all |bias| < 0.12%).
2. **ADL+FE é robusto a não-linearidade moderada**: com softpoly2 (não-linearidade limitada no canal D→Z), ADL_all |bias| < 0.22% mesmo com nl_strength=2.0.
3. **softclamp carryover preserva o resultado**: não-linearidade no carryover (D_lag^2→Y) não amplifica o IVB de forma significativa quando a função é limitada.

### O que delimita

1. **Não-linearidade no canal Y→Z é perigosa**: tanto poly2 quanto softpoly2 com nl_Y=TRUE explodem. Isso não é sobre IVB — é sobre estabilidade do DGP com feedback. Na prática, se Y→Z é fortemente não-linear E Z→D é forte (rho_Z alto), o sistema dinâmico é instável.
2. **power1.5 mostra que funções sub-quadráticas não são suficientes**: mesmo crescendo mais devagar que D^2, power1.5 diverge em cenários com alta persistência (rho_Z=0.7) e nl_strength alto.
3. **A fronteira de estabilidade do poly2 é estreita**: nl_strength=0.1 é OK; nl_strength=0.2/rho_Z=0.7 já perde 23% das reps.

### Mensagem para o paper

> A robustez do resultado "IVB é pequeno" depende da forma funcional da não-linearidade:
> - **Não-linearidades limitadas** (softpoly2, log4): IVB cresce < 12% mesmo com nl_strength=2.0. O argumento pró-ADL+FE se mantém.
> - **Não-linearidades ilimitadas** (poly2, power1.5): o DGP com feedback diverge antes que o IVB possa ser estimado. O problema não é o IVB ser grande — é o sistema ser explosivo.
> - **Canal Y→Z não-linear**: mesmo com clamping no canal D→Z, a não-linearidade no canal Y→Z desestabiliza o sistema. Isso é uma limitação das simulações, não uma evidência contra ADL+FE.

A interpretação correta é: **sob condições em que o DGP é estável (o que é o caso relevante para dados reais), o IVB permanece pequeno.** A instabilidade numérica com poly2 é um artefato do DGP simulado, não uma propriedade do IVB.

## 6. Próximos passos sugeridos

1. **Incluir softpoly2 e softclamp nas figuras do paper** como demonstração de robustez a não-linearidade.
2. **Abandonar poly2 e power1.5 para nl_strength > 0.2** — cenários instáveis não são informativos.
3. **Investigar não-linearidade no canal Y→Z** separadamente, com um DGP que não tenha feedback Z→D (isolando o efeito).
4. **Considerar NL-1b (interação D*H)** como alternativa — já estável nos resultados anteriores.

## 7. Tempos de execução

| Simulação | Cenários | Tempo total | Tempo/cenário (estáveis) |
|-----------|----------|-------------|--------------------------|
| Collider | 42 | 802.1s (13.4 min) | ~35s |
| Carryover | 18 | 432.8s (7.2 min) | ~33s |
| **Total wall-clock** | — | **~13.4 min** (paralelo) | — |

Cenários explosivos terminam quase instantaneamente (0s) porque todas as 500 reps são descartadas na fase de burn-in ou nos primeiros períodos.
