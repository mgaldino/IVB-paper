# Plano: Mech C ADL (binary D) + Feedback Y→D simulation

**Status**: DRAFT
**Data**: 2026-03-02

## Parte 1: sim_mechC_adl.R (EM IMPLEMENTAÇÃO)

### Objetivo
Testar se ADL(all lags) reduz o IVB grande observado com D binário no v4 Mechanism C.

### DGP
```
D_it = 1(t >= T_i*)   — staggered binary (exógeno)
Y_it = α^Y_i + β D_it + γ_Y Z_{i,t-1} + ρ_Y Y_{i,t-1} + e_it
Z_it = α^Z_i + δ_D D_it + δ_Y Y_it + ρ_Z Z_{i,t-1} + ν_it
```

### Grid: 32 cenários × 500 reps
- prob_switch ∈ {0.1, 0.3, 0.5, 0.7}
- delta_D ∈ {0.1, 0.3}
- delta_Y ∈ {0.1, 0.3}
- rho_Z ∈ {0.5, 0.7}

### 9 modelos estimados
Mesmos do sim_nl_collider: TWFE short/long + 7 ADL variantes + IVB components.

### Status
- [x] Script escrito (sim_mechC_adl.R)
- [x] Review-r #1 completo — issues identificados
- [ ] Fixes aplicados (lag do burn-in, check multicolinearidade, delta_Y no grid)
- [ ] Review-r #2
- [ ] Rodar simulação
- [ ] Incluir resultados no relatório unificado

---

## Parte 2: sim_feedback_Y_to_D.R (PLANEJADO, NÃO IMPLEMENTADO)

### Objetivo
Testar o cenário onde o outcome passado Y_{t-1} influencia o tratamento D_t (violação de strict exogeneity). Este é o cenário (C) identificado por um agente revisor como ausente do battery de simulações.

### Motivação teórica
Quando políticas respondem a desempenho passado (ex.: inflação → mudança de política monetária, violência → intervenção), o tratamento é endógeno ao outcome defasado. Isso viola strict exogeneity:

```
E[ε_it | X_i1, ..., X_iT, α_i] = 0
```

Com Y_{t-1} → D_t e Y_{t-1} contendo ε_{t-1}, o tratamento D_t fica correlacionado com erros passados.

### DGP proposto

**Variante A — Tratamento contínuo com feedback:**
```
D_it = α^D_i + φ Y_{i,t-1} + ρ_D D_{i,t-1} + γ_D Z_{i,t-1} + u_it
Y_it = α^Y_i + β D_it + γ_Y Z_{i,t-1} + ρ_Y Y_{i,t-1} + e_it
Z_it = α^Z_i + δ_D D_it + δ_Y Y_it + ρ_Z Z_{i,t-1} + ν_it
```

- φ ≠ 0 é o feedback: Y_{t-1} → D_t
- Z continua dual-role (collider + confounder)
- Sem feedback (φ=0): reduz ao DGP dual_role_z padrão

**Variante B — Tratamento binário com feedback:**
```
D_it = 1{η_it + φ Y_{i,t-1} + ρ D_{i,t-1} + λ U_i > 0}
Y_it = α_i + β D_it + κ Y_{i,t-1} + ε_it
```
Versão simplificada sem Z para isolar o efeito do feedback.

### Grid proposto (Variante A — principal)
- phi ∈ {0, 0.05, 0.1, 0.2, 0.3} — intensidade do feedback
- rho_Z ∈ {0.5, 0.7}
- Com/sem Z no modelo (para ver interação feedback × IVB)

### Predições
1. φ=0: ADL_all bias ≈ 0.008-0.010 (reproduz dual_role_z baseline)
2. φ > 0: TWFE bias cresce (strict exogeneity violada)
3. ADL com Y_lag deve absorver parte do feedback (Y_lag captura Y_{t-1})
4. ADL_all deve ser relativamente robusto se φ é moderado
5. Com φ grande, nenhum modelo OLS salva — motivação para GMM/IV

### Variações úteis
1. Feedback puro sem inércia do outcome: κ=0
2. Feedback + outcome persistente: κ>0 (amplifica problemas)
3. Interação feedback × IVB: φ>0 com Z dual-role

### Relevância para o paper
- Complementa o argumento sobre quando ADL+FE funciona vs quando não funciona
- Se ADL_all é robusto a feedback moderado (φ ≤ 0.1), isso fortalece a claim
- Se ADL_all falha com feedback forte (φ ≥ 0.2), é uma boundary condition honesta
- Conecta diretamente com Imai & Kim (strict exogeneity) e com aplicações reais em CP

### Arquivos a criar
- [ ] sim_feedback_Y_to_D.R — DGP + estimação + grid
- [ ] (resultados e relatório após rodar)

### Verificação
- [ ] φ=0 reproduz resultados do dual_role_z
- [ ] Bias de TWFE cresce monotonicamente com |φ|
- [ ] ADL com Y_lag reduz bias relativo a TWFE

---

## Ordem de execução
1. ✅ sim_mechC_adl.R — fixes + review-r + rodar
2. Incluir resultados mechC_adl no relatório unificado
3. sim_feedback_Y_to_D.R — implementar após mechC_adl completo
