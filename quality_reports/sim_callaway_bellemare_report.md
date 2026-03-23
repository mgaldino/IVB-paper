# Relatório: Simulações Bellemare + Callaway (2026-03-23)

## Motivação

Duas leituras levantaram a pergunta: o ADL_all resolve OUTROS problemas além do collider bias de Z_{t-1}?

1. **Bellemare, Masaki & Pepinsky (2017, JoP)**: Mostram que lagar variáveis explicativas não resolve endogeneidade quando os não-observáveis têm dinâmica temporal (φ ≠ 0). Pergunta: ADL_all resolve isso?

2. **Callaway et al. / texto sobre bad controls em DID**: Identificam que TWFE falha quando (a) Z→Y é não-linear e pesquisador modela linearmente, e (b) a evolução de Y(0) depende do nível de Z, não só de mudanças. Pergunta: ADL_all é robusto a esses problemas?

## Simulação 1: Persistent Unobserved Confounder (Bellemare)

**Arquivo**: `simulations/dynamics/sim_persistent_confounder.R`

### DGP

```
U_t = φ U_{t-1} + v_t                                         (confounder persistente)
D_t = α^D_i + γ_D Z_{t-1} + ρ_D D_{t-1} + κ U_t + u_t       (endogeneidade via κ)
Y_t = α^Y_i + β D_t + γ_Y Z_{t-1} + ρ_Y Y_{t-1} + δ_U U_t + e_t
Z_t = α^Z_i + δ_D D_t + δ_Y Y_t + ρ_Z Z_{t-1} + ν_t
```

### Grid
- κ ∈ {0, 0.3, 0.5} × φ ∈ {0, 0.3, 0.5, 0.7} × ρ_Z ∈ {0.5, 0.7} × δ_U ∈ {0.3, 1.0}
- 36 cenários × 500 reps, 4 workers, ~7 min

### Modelos extras
- Oracle ADL (Y ~ D + U + D_lag + Y_lag + Z_lag | FE) — benchmark com U observado
- Oracle TWFE (Y ~ D + U | FE)
- Lag-ID (Y ~ D_lag | FE) — abordagem de Bellemare

### Resultados principais

**ADL_all NÃO resolve OVB de confounder persistente.** O viés vem do canal contemporâneo D_t ← κ U_t → δ_U Y_t, que nenhum lag pode bloquear.

| κ | φ | δ_U | OVB (% de β) |
|---|---|-----|-------------|
| 0.3 | 0.0 | 1.0 | 27% |
| 0.3 | 0.7 | 1.0 | 38% |
| 0.5 | 0.0 | 1.0 | 40% |
| 0.5 | 0.5 | 1.0 | 46% |
| 0.5 | 0.7 | 1.0 | 53% |

- **Persistência (φ) piora o OVB** em ~13pp (de 40% a 53% com κ=0.5, δ_U=1)
- **Mesmo sem persistência (φ=0), OVB já é 40%** — a parte contemporânea domina
- **OVB escala com δ_U**: 14% com δ_U=0.3 vs 46% com δ_U=1.0 (κ=0.5, φ=0.5)
- **Oracle ADL bias < 0.5%** em todos os 36 cenários — confirma que o problema é OVB, não especificação
- **κ=0 (sanity check): ADL_all bias < 0.5%** — puro collider, sem OVB

### DAG do mecanismo

```
D_t ◄── κ ── U_t ── δ_U ──► Y_t     (backdoor contemporâneo, nenhum lag bloqueia)
              ▲
         φ U_{t-1}                    (Y_{t-1} absorve parcialmente, mas inovação v_t escapa)
```

### Take-away
ADL resolve collider bias mas NÃO substitui identificação para endogeneidade clássica. São problemas ortogonais.

---

## Simulação 2: Callaway Controls (NL em Z→Y + Level-Dependent Trends)

**Arquivo**: `simulations/dynamics/sim_callaway_controls.R`

### Mecanismo A: NL em Z→Y

DGP modifica a equação de Y para incluir g(Z_{t-1}) não-linear:
```
Y_t = α^Y_i + β D_t + γ_Y Z_{t-1} + γ_nl g(Z_{t-1}) + ρ_Y Y_{t-1} + e_t
```

g types: softpoly2 (bounded), power1.5 (unbounded), quadratic (Z²)

**Controle DA**: δ_Y ∈ {0, 0.1} para decompor misspec pura vs collider × misspec.

### Mecanismo B: Level-Dependent Trends

DGP adiciona H_i exógeno que determina nível de Z e cria trends em Y:
```
H_i ~ N(0,1)
Y_t = ... + λ H_i (t_obs/TT) + ...
Z_t = ... + δ_H H_i + ...
```

### Grid
- Mech A: 3 nl_types × 3 nl_str × 2 δ_Y × 2 ρ_Z + baselines = 40 cenários
- Mech B: 4 λ × 2 δ_Y × 2 ρ_Z + baselines = 20 cenários
- Total: 60 cenários × 500 reps

### Resultados principais

**ADL_all é robusto a AMBOS os mecanismos.** Bias < 0.3% em todos os cenários estáveis.

#### Mech A: NL em Z→Y

| nl_type | nl_str | δ_Y | rho_Z | ADL_all bias |
|---------|--------|-----|-------|-------------|
| softpoly2 | 2.0 | 0.1 | 0.7 | 0.2% |
| power1.5 | 1.0 | 0.1 | 0.5 | -0.3% |
| quadratic | 0.3 | 0.1 | 0.5 | -0.2% |

- **Collider × misspec interaction**: essencialmente zero (< 0.3pp) para todos os cenários estáveis
- **Cenários unbounded (quadratic, power1.5) com collider ativo e rho_Z=0.7**: explosivos (feedback Y→Z→Y amplifica NL). Instabilidade do DGP, não viés do ADL.
- **Sem collider (δ_Y=0)**: NL em Z→Y não cria viés no ADL_all em nenhum cenário — confirma que d-separation funciona independente de forma funcional.

#### Mech B: Level-Dependent Trends

| λ | δ_Y | rho_Z | ADL_all bias |
|---|-----|-------|-------------|
| 0.1 | 0.1 | 0.7 | -0.3% |
| 0.3 | 0.1 | 0.7 | -0.3% |
| 0.5 | 0.1 | 0.7 | -0.2% |

- **Y_lag absorve completamente os level-dependent trends**
- **Collider × trend interaction**: < 0.2pp em todos os cenários
- Zero reps explosivas em todos os 20 cenários

### Interpretação

O DA previu que os resultados seriam "trivialmente previsíveis" (linear models fail under NL). Estava parcialmente certo sobre o diagnóstico (misspec, não collider) mas errado sobre o resultado: **ADL_all NÃO falha**. O firewall de d-separation funciona — condicionar em Z_{t-1}, mesmo linearmente, bloqueia os caminhos collider independente de forma funcional no outcome.

### Take-away
ADL_all é robusto a NL em Z→Y e level-dependent trends. Estes NÃO são boundary conditions para o ADL. As únicas boundary conditions identificadas até agora são: (1) OVB de confounder não-observado (Bellemare) e (2) Nickell bias com T pequeno.

---

## Escopo do ADL: TSCS vs DID

### Por que ADL funciona em TSCS mas não é padrão em DID

| Dimensão | TSCS (nosso paper) | DID clássico |
|---|---|---|
| T típico | 20-50 | 2-10 |
| Tratamento | Contínuo, varia no tempo | Binário, absorvente |
| Nickell bias (O(1/T)) | ~2-3% (negligível) | ~10-20% (substancial) |
| Y_{t-1} como controle | Legítimo (sequential exogeneity) | Pós-tratamento (pode viesar) |
| Identificação | Sequential exogeneity | Parallel trends |
| ADL recomendado por | De Boef & Keele (2008), IK (2019), BG (2018) | Geralmente não |

### Estratégias de identificação

ADL não depende de parallel trends — depende de sequential exogeneity:
- **PTA**: E[ΔY(0)|D=1] = E[ΔY(0)|D=0]
- **Seq. exog.**: E[ε_t | D_t, Y_{t-1}, Z_{t-1}, FE] = 0

São diferentes. ADL não "viola" PTA — é uma estratégia distinta que requer T suficiente.

### Implicações para o paper

1. **Delimitar escopo**: resultados valem para TSCS com T moderado (≥ 20). Para DID com T pequeno, ADL não é recomendável por Nickell bias.

2. **Fórmula IVB útil mesmo sem ADL**: pesquisadores que usam TWFE podem calcular IVB = -θ* × π para diagnosticar se incluir Z_{t-1} viesa o CET. A fórmula funciona independente de usar ADL.

3. **ADL resolve collider bias, não endogeneidade**: o confounder persistente (Bellemare) é um problema separado que requer design-based identification (IV, experimento, etc.), não mais lags.

4. **Robustez a Callaway concerns**: ADL é robusto a NL em Z→Y e level-dependent trends, eliminando esses como boundary conditions práticas.

---

## Resumo de todas as boundary conditions testadas

| Mechanism | Sim file | ADL_all resolve? | Bias |
|---|---|---|---|
| Collider Z_{t-1} (linear) | Todas as sims existentes | SIM | < 3% |
| NL em D→Z (collider eq) | sim_nl_collider.R | SIM | < 2.3% |
| NL em Z→Y (outcome eq) | sim_callaway_controls.R | SIM | < 0.3% |
| Level-dependent trends | sim_callaway_controls.R | SIM | < 0.3% |
| Feedback Y→D | sim_direct_feedback.R | SIM | < 1% |
| Carryover D_{t-1}→Y | sim_direct_carryover.R | SIM | < 1% |
| Z persistence (AR(p)) | sim_dual_role_z.R | SIM | < 3% |
| Binary D staggered | sim_mechC_adl.R | SIM | < 3% |
| **OVB persistente (Bellemare)** | **sim_persistent_confounder.R** | **NÃO** | **40-53%** |
| **Staggered absorbing D** | **sim_staggered_posttreat.R** | **SIM** | **< 1%** |
| **OVB persistente (Bellemare)** | **sim_persistent_confounder.R** | **NÃO** | **40-53%** |
| **Nickell bias (T pequeno)** | sims com T=10 | **PARCIAL** | **~5-8%** |

---

## Simulação 3: Staggered Absorbing Treatment (Y_lag pós-tratamento)

**Arquivo**: `simulations/dynamics/sim_staggered_posttreat.R`

### Motivação

No DID escalonado com tratamento binário absorvente (D=1 uma vez ligado, fica ligado), Y_{t-1} para unidades já tratadas contém efeitos do tratamento passado. Incluir Y_lag no ADL = condicionar em variável pós-tratamento. Será que isso viesa β̂?

### DGP

```
D_it = 1{t >= T_i*}     (binário absorvente, onset uniforme em [20%, 70%] do período)
Y_t = α^Y_i + β D_t + γ_Y Z_{t-1} + ρ_Y Y_{t-1} + e_t
Z_t = α^Z_i + δ_D D_t + δ_Y Y_t + ρ_Z Z_{t-1} + ν_t
```

### Grid
- prob_never ∈ {0.3, 0.5} × ρ_Y ∈ {0, 0.3, 0.5} × δ_Y ∈ {0, 0.1} × ρ_Z ∈ {0.5, 0.7}
- 24 cenários × 500 reps, N=200, T=30

### Resultados

**ADL_all bias < 1% em todos os 24 cenários.** O "post-treatment bias" de Y_lag não se materializa.

| Modelo | rho_Y=0.5, dY=0.1, rZ=0.7, pn=0.5 |
|--------|-------------------------------------|
| TWFE_s | **+104.5%** |
| TWFE_l | **+80.8%** |
| ADL_Ylag | +9.5% |
| ADL_full | +9.0% |
| **ADL_all** | **-0.1%** |

Comparação static (ρ_Y=0) vs dynamic (ρ_Y=0.5): o "custo" de condicionar em Y_lag pós-tratamento é < 1.2pp. O benefício (absorver dinâmica) é de 80-100pp de redução de viés.

### Interpretação

Com T=30, o benefício de incluir Y_lag (capturar dinâmica, bloquear collider paths) domina esmagadoramente o custo de condicionar em pós-tratamento. O Nickell bias O(1/T) é ~3% e o post-treatment bias é indistinguível de zero.

**Caveat**: com T muito pequeno (5-10), Nickell bias cresce e este resultado pode não se manter. O escopo do resultado é TSCS com T moderado (≥ 20).
