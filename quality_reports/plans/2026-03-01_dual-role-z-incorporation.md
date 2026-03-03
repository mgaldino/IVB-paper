# Plano: Incorporar Análise Dual-Role Z (Confounder + Collider) no Paper

**Status**: DRAFT v2 (pós-DA review)
**Data**: 2026-03-01

## Objetivo

Incorporar ao paper os achados sobre Z simultaneamente confounder e collider em TSCS. A contribuição central NÃO é "IVB explode" (isso é um artefato contábil — o OVB de omitir Z também explode). A contribuição é:

**Quando Z é dual-role com persistência temporal, incluir Z_{t-1} como controle é sempre melhor que omitir (net bias positivo), mas a especificação importa: TWFE+Z_{t-1} retém collider bias residual (~0.25), enquanto ADL+Z_{t-1} (com Y_{t-1}) elimina quase todo o bias (~0.01). A razão: Y_{t-1} bloqueia os caminhos collider herdados via d-separation.**

A comparação relevante é **TWFE_long vs ADL_long** (ambos incluindo Z), não TWFE_short vs TWFE_long.

## Críticas do DA incorporadas

| # | Crítica DA | Resposta |
|---|-----------|----------|
| 1 | Narrativa "IVB explode" é misleading — twfe_net sempre positivo | **Reformular**: foco em TWFE_long vs ADL_long |
| 2 | "Firewall" pode ser apenas especificação correta | **Adicionar simulação**: ρ_Y = 0 para isolar mecanismo |
| 3 | Tensão com Section 5 ("IVB é pequeno") | **Transição explícita**: Section 5 vale para pure colliders; dual-role Z com persistência é diferente |
| 4 | Prova formal intratável no caso geral | **Caso limpo primeiro**: δ_Y = 0 (only D→Z, não Y→Z) ou ρ_D = 0 |
| 5 | Insight "acumulação" é d-separation, não FWL | **Duas provas**: d-separation no corpo (intuitiva), FWL/VAR no appendix (algébrica) |
| 6 | Conexão Imai & Kim imprecisa | **Ser preciso**: feedback indireto Y→Z→...→D, não direto Y→D |
| 7 | ADL_long ≈ DGP verdadeiro (tautológico) | **Reframing**: o ponto é que TWFE_long, apesar de incluir Z, não resolve; o mecanismo é collider paths herdados |
| 8 | Stationarity com ρ_Z=0.9 | **Verificar eigenvalores** do companion matrix do VAR |
| 9 | 200 reps insuficiente para bias ~0.01 | **Reportar MC SEs**; aumentar para 500 se necessário |
| 10 | σ_αZ e AR(1) vs AR(3) são previsíveis | **1 frase** como sanity check, não resultado |
| 11 | Paper acabou de ser cortado, +3pp é arriscado | **Corpo: máx 1 página**. Tudo mais no appendix |
| 12 | DGP paramétrico específico | **Variar γ_D/δ_D** para explorar quando net bias muda de sinal |

## Contexto atual do paper

- **Linha 569** (Caveats): Menciona butterfly structure de Ding (2015), "future work"
- **Linha 894** (Conclusion): "future work" sobre FWL para Z dual-role
- **Section 5** (linhas 572-593): IVB é pequeno — FE absorve between, few switchers
- **Section 4.6** (linhas 439-447): Nickell bias

## Achados existentes (reformulados)

### Comparação relevante: TWFE_long vs ADL_long (ambos incluem Z_{t-1})

Resultados (AR(1), σ_αZ=0.5, β_true=1):

| ρ_Z | TWFE_long bias | ADL_long bias | Diferença |
|-----|----------------|---------------|-----------|
| 0.1 | 0.272          | 0.010         | 0.262     |
| 0.5 | 0.253          | 0.010         | 0.243     |
| 0.9 | 0.248          | 0.009         | 0.239     |

Observação crucial: **TWFE_long bias é ~0.25 e estável em ρ_Z**. Não "explode". O que explode é o TWFE_short bias (OVB de omitir Z). A diferença TWFE_long - ADL_long (~0.24) é o "custo" de usar TWFE em vez de ADL quando Z é dual-role. Esse custo vem de collider paths residuais que TWFE não bloqueia.

Nota: ADL_long bias ~0.01 inclui Nickell bias O(1/T). Simulação varyT vai confirmar que → 0 quando T → ∞.

## Simulação principal: 8 modelos (decomposição completa)

### Motivação: por que 8 modelos?

A simulação atual tem 4 modelos, todos com FE. Isso não permite isolar:
- **Custo Nickell** (FE + LDV): comparar ADL+FE vs ADL sem FE
- **Benefício FE**: comparar ADL sem FE (OVB de α_i) vs ADL+FE (Nickell mas sem OVB)
- **Imai & Kim tradeoff**: quando vale a pena pagar Nickell para ter FE?

### Os 8 modelos (grid completa: {FE, no FE} × {Y_lag, no Y_lag} × {Z_lag, no Z_lag})

| # | Modelo | FE | Y_{t-1} | Z_{t-1} | O que captura |
|---|--------|----|---------|---------|---------------|
| 1 | Pooled short | não | não | não | Baseline: OVB de α_i + OVB de Z + OVB de Y_{t-1} |
| 2 | Pooled long | não | não | sim | Sem FE, com Z: troca OVB(Z) por IVB, mas retém OVB(α_i) |
| 3 | TWFE short | sim | não | não | FE remove OVB(α_i), retém OVB(Z) + OVB(Y_{t-1}) |
| 4 | TWFE long | sim | não | sim | FE + Z: collider bias residual (~0.25) |
| 5 | ADL short (no FE) | não | sim | não | Y_{t-1} corrige dinâmica, retém OVB(α_i) |
| 6 | ADL long (no FE) | não | sim | sim | Y_{t-1} + Z: bloqueia collider, retém OVB(α_i) |
| 7 | ADL short + FE | sim | sim | não | FE + Y_{t-1}: Nickell bias, sem OVB(α_i) nem Z |
| 8 | ADL long + FE | sim | sim | sim | FE + Y_{t-1} + Z: Nickell + d-sep firewall (melhor?) |

### Decomposições possíveis com 8 modelos

**A. Custo Nickell** (FE + LDV interaction):
- Nickell cost = |bias(ADL+FE long)| - |bias(ADL no-FE long)|
- Se Nickell > 0: FE piora o ADL (Imai & Kim concern)
- Se Nickell ≈ 0 (T grande): FE é gratuito

**B. Benefício FE** (remove between-unit confounding):
- FE benefit = |bias(ADL no-FE long)| - |bias(ADL+FE long)|
- Se positivo: FE ajuda (remove OVB de α_i mais que Nickell prejudica)

**C. Efeito firewall** (Y_{t-1} bloqueia collider paths):
- Firewall = |bias(TWFE long)| - |bias(ADL+FE long)|
- Mede quanto Y_{t-1} reduz collider bias residual no TWFE
- Se ~0: Y_{t-1} não faz diferença (firewall não existe)
- Se >0: Y_{t-1} bloqueia collider paths (firewall genuíno)

**D. IVB contábil** (por modelo):
- IVB = bias(long) - bias(short) para cada par {FE/noFE} × {Y_lag/noY_lag}
- 4 IVBs diferentes, cada um com interpretação causal distinta

**E. Net bias (incluir vs excluir Z)**:
- Para cada especificação: |bias(short)| - |bias(long)|
- Positivo = incluir Z ajuda; Negativo = incluir Z piora

**F. Imai & Kim tradeoff completo**:
- ADL no-FE long: sem Nickell, com OVB de α_i, firewall ativo
- ADL+FE long: Nickell, sem OVB de α_i, firewall ativo
- TWFE long: sem Nickell, sem OVB de α_i, SEM firewall
- Qual é o menor bias? Depende de T, σ_α, ρ_Z

### Simulações a rodar

#### 1. sim_dual_role_z_8models.R (NOVO — substitui simulação principal)

**DGP**: mesmo da simulação existente

**Grid principal** (exploratória, extensa):
- ρ_Z ∈ {0.1, 0.3, 0.5, 0.7, 0.9}
- σ_αZ ∈ {0.5, 2.0} (between-unit variation em Z)
- N = 100, T = 30, T_burn = 100
- 500 reps, reportar MC SEs

**8 modelos estimados por rep**

**Output**:
- Tabela com bias de cada modelo por cenário
- Decomposições A-F acima
- MC standard errors
- "Winner" (menor |bias|) por cenário

#### 2. sim_dual_role_z_varyT.R (ATUALIZAR — adicionar modelos)

**Mesmos 8 modelos**, variando T ∈ {10, 20, 30, 50, 100}
- ρ_Z ∈ {0.5, 0.9} (foco nos casos interessantes)
- 500 reps

**Perguntas**:
- ADL+FE long → 0 com T? (Nickell desaparece)
- ADL no-FE long → ? com T? (OVB de α_i é constante em T)
- TWFE long → ? com T? (collider bias residual é constante em T?)
- Para T pequeno (10-20), ADL+FE é pior que ADL no-FE? (Nickell domina?)

#### 3. sim_dual_role_z_firewall.R (NOVO — DA critique #2)

**DGP modificado**: ρ_Y = 0 (Y sem persistência própria)
- Se ADL+FE long ainda vence TWFE long: firewall é d-separation genuíno
- Se não: o ganho era especificação correta
- Grid: ρ_Z ∈ {0.3, 0.7, 0.9}, 500 reps
- Apenas 4 modelos com FE (TWFE short/long, ADL short/long)

#### 4. sim_dual_role_z_asymmetry.R (NOVO — DA critique #12)

**DGP modificado**: variar razão confounding/collider
- γ_D ∈ {0.05, 0.15, 0.3, 0.5} (confounding D→Z via Z_{t-1})
- δ_D ∈ {0.05, 0.1, 0.2} (collider D→Z contemporâneo)
- Fixar ρ_Z = 0.7
- 500 reps
- Perguntas: quando TWFE_long ≈ ADL_long? Quando net bias muda de sinal?

#### 5. Verificação de estacionaridade (DA critique #8)

Script de 20 linhas que calcula eigenvalores do companion matrix
para cada combinação de parâmetros e reporta |λ_max|.

#### 6. Reportar MC standard errors em TUDO (DA critique #9)

### Prova formal: caso limpo primeiro (DA critiques #4, #5)

**Estratégia dual**: d-separation no corpo + FWL/álgebra no appendix

#### No corpo: Proof sketch via d-separation (3 períodos)

DAG com 3 períodos mostrando:
- Condicionar em Z_{t-1} quando Z_{t-1} → Z_t abre collider Z_{t-2} (descendant rule)
- Y_{t-1} bloqueia os caminhos abertos

Isso é uma demonstração gráfica, não requer álgebra. É a prova mais intuitiva e sobrevive a qualquer parametrização.

#### No appendix: Proposição formal para caso limpo

**Caso limpo** (evita simultaneidade intratável):
- Z_t = α_Z + δ_D · D_t + ρ_Z · Z_{t-1} + ν_t (só D→Z, sem Y→Z no contemporâneo)
- Y_t = α_Y + β · D_t + γ_Y · Z_{t-1} + e_t (sem Y_{t-1} — TWFE puro)
- D_t = α_D + γ_D · Z_{t-1} + u_t (sem ρ_D — evita complicação extra)

Neste caso:
- A equação de Z não depende de Y_t (δ_Y = 0), eliminando simultaneidade
- O sistema é VAR(1) com estrutura triangular: D_t e Y_t dependem de Z_{t-1}, Z_t depende de D_t
- θ* e π são deriváveis como funções explícitas de (δ_D, γ_D, γ_Y, ρ_Z)
- Pode-se mostrar que π (coeficiente auxiliar) cresce com ρ_Z via Yule-Walker

**Proposição (rascunho do enunciado)**:
"Consider the DGP above [caso limpo]. Under TWFE, the residual bias from including Z_{t-1} is:

bias_TWFE_long = f(δ_D, γ_D, γ_Y, ρ_Z)

which is bounded away from zero for ρ_Z > 0. Under ADL (incluindo Y_{t-1}), the residual bias vanishes as T → ∞."

A extensão para o caso geral (δ_Y > 0, ρ_D > 0, ρ_Y > 0) é documentada via simulação como confirmação numérica.

### Conexão Imai & Kim (reformulada, DA critique #6)

**NÃO dizer**: "a violação de strict exogeneity no TWFE é o mecanismo que faz o IVB acumular"

**DIZER**: "The same panel structures that generate the strict exogeneity violations analyzed by Imai & Kim (2019) — temporal feedback loops between treatment, outcome, and controls — also create the conditions for accumulated collider bias when feedback operates through a dual-role control variable. In our DGP, the feedback is indirect: Y_t → Z_t → Z_{t+1} → D_{t+2} (via Z persistence and γ_D). This is distinct from the direct Y_{t-1} → D_t feedback in Imai & Kim, but both share the structure of treatment endogeneity arising from past outcomes. The ADL specification, which Imai & Kim recommend for sequential ignorability, simultaneously blocks inherited collider paths — an additional benefit not previously recognized."

## Mudanças propostas no paper (revisadas)

### Mudança 1: Nova subseção em Section 4 — "The Dual-Role Control Problem"

**Localização**: Após Section 4.7 (Caveats, linha 569), antes de Section 5.

**Extensão no corpo: MÁXIMO 1 PÁGINA** (DA critique #11)

**Conteúdo**:

1. **Motivação** (3-4 frases): GDP per capita é dual-role em 4/6 aplicações. Ding (2015) analisou cross-section. Em TSCS com Z persistência, a dinâmica introduz um novo mecanismo.

2. **1 DAG com 3 períodos** (TikZ): Mostra TWFE condicionando em Z_{t-1} — collider paths abertos. Anotar no DAG que Y_{t-1} (se incluído) bloquearia.

3. **Proposição** (enunciado apenas, 3-4 linhas): Para o caso limpo. "Proof. See Appendix X. The key step is [proof sketch de 2 frases via d-separation]."

4. **1 parágrafo de discussão**: A comparação relevante é TWFE_long vs ADL_long. O custo de TWFE é collider bias residual, estável em ρ_Z. ADL paga custo Nickell O(1/T), negligível para T ≥ 20-30 (confirmado por simulação, Appendix X).

5. **Conexão Imai & Kim** (2-3 frases): Feedback indireto via Z, não direto. ADL tem benefício duplo: sequential ignorability + bloqueio de collider paths.

6. **Transição para Section 5**: "The preceding mechanisms from Section 5 [FE absorbs between, few switchers] still operate. The dual-role case adds a further consideration: Z persistence creates inherited collider paths that TWFE cannot block."

### Mudança 2: Subseção em Section 5 — Simulação

**Extensão: 0.5 página no corpo + referência a Appendix**

**Conteúdo no corpo**:
- 1 parágrafo descrevendo DGP (3-4 frases)
- 1 tabela compacta: TWFE_long bias vs ADL_long bias por ρ_Z (5 linhas, **apenas a comparação relevante**)
- 1 parágrafo: ADL_long bias ~0.01 é quase todo Nickell (confirmado pelo varyT), desaparece com T grande

**No Appendix**: Tabela completa com todos os cenários, MC SEs, resultados do varyT, robustez ρ_Y=0

### Mudança 3: Atualizar Caveats (Section 4.7, linha 569)

Substituir frase "future work" por referência à nova Section 4.8. Manter "future work" apenas para closed-form net bias no caso geral.

### Mudança 4: Atualizar Conclusion (linhas 892-894)

2-3 frases: Derivamos o caso limpo formalmente e confirmamos via simulação o caso geral. A recomendação prática: quando Z é dual-role com persistência, ADL+Z_{t-1} é preferível a TWFE+Z_{t-1}. Future work: closed-form para o caso geral com simultaneidade, extensão para modelos não-lineares.

### Mudança 5: Novo Appendix — Prova + Simulação Completa

**Conteúdo**:
- Prova formal para caso limpo (δ_Y = 0, ρ_D = 0)
- Verificação de estacionaridade (eigenvalores)
- Tabela completa: 20 cenários com MC SEs
- Resultados varyT (decomposição Nickell)
- Robustez: ρ_Y = 0 (teste do mecanismo firewall)
- Robustez: assimetria γ/δ
- Re-rotular appendices subsequentes

## Arquivos a modificar

### Simulações (fase exploratória — extenso, cortar depois)
- [ ] NOVO: `sim_dual_role_z_8models.R` — simulação principal com 8 modelos
- [ ] ATUALIZAR: `sim_dual_role_z_varyT.R` — adicionar 4 modelos sem FE, 500 reps
- [ ] NOVO: `sim_dual_role_z_firewall.R` — ρ_Y = 0, teste do mecanismo
- [ ] NOVO: `sim_dual_role_z_asymmetry.R` — γ_D/δ_D variando
- [ ] NOVO: `check_stationarity.R` — eigenvalores companion matrix

### Paper (depois de entender os resultados)
- [ ] `ivb_paper_psrm.Rmd` — escrita final (decidir escopo depois)

## Ordem de execução

### Fase 1: Verificação prévia
1. Verificar estacionaridade (eigenvalores) para os parâmetros atuais
2. Se instável, ajustar parâmetros antes de rodar

### Fase 2: Simulação principal com 8 modelos
3. Escrever e rodar `sim_dual_role_z_8models.R` (grid principal, 500 reps)
4. Analisar resultados — produzir tabelas de decomposição A-F
5. Discutir com autor — entender os patterns

### Fase 3: Simulações complementares
6. Atualizar e rodar `sim_dual_role_z_varyT.R` (8 modelos, 500 reps)
7. Escrever e rodar `sim_dual_role_z_firewall.R` (ρ_Y = 0)
8. Escrever e rodar `sim_dual_role_z_asymmetry.R` (γ/δ)
9. Analisar tudo junto

### Fase 4: Prova formal
10. Derivar proposição para caso limpo (δ_Y = 0, ρ_D = 0)
11. Verificar álgebra contra simulação do caso limpo

### Fase 5: Escrita (decidir escopo com base nos resultados)
12. Escrever para o paper (cortar o que não servir)
13. Compilar e verificar

## Decisões do autor (resolvidas)

1. **Formalidade**: Prova formal para caso limpo. Caso geral via simulação.
2. **Escopo corpo vs appendix**: Corpo máx 1.5 páginas total. Resto no appendix.
3. **Título**: "The Dual-Role Control Problem"
4. **Imai & Kim**: Sim, com precisão sobre feedback indireto vs direto.

## Riscos

1. **Estacionaridade**: Se ρ_Z=0.9 é instável, precisamos reduzir ou documentar
2. **Prova caso limpo**: Se a álgebra não fecha em forma limpa, fallback para proposição verbal + d-separation
3. **Firewall test**: Se ρ_Y=0 mostra que ADL não vence, o mecanismo "firewall" é na verdade "especificação correta" — muda a narrativa (mas não invalida o resultado empírico)
4. **Assimetria γ/δ**: Se confounding forte domina, TWFE_long pode ser tão bom quanto ADL_long — limita generalidade
5. **Escopo R&R**: Mesmo com 1.5pp no corpo, referee pode achar excesso. Fallback: tudo no Online Appendix, apenas 1 parágrafo no corpo

## Verificação

- [ ] Eigenvalores < 1 para todos os cenários
- [ ] MC SEs reportados em todas as tabelas
- [ ] ADL_long bias → 0 com T (varyT confirma)
- [ ] Firewall test: ADL vence com ρ_Y = 0 (mecanismo genuíno)
- [ ] Prova caso limpo: álgebra verificada contra simulação
- [ ] Corpo ≤ 1.5 páginas de material novo
- [ ] DAG renderiza em TikZ
- [ ] Referências cruzadas funcionam
- [ ] Appendices re-numerados corretamente
- [ ] Paper compila sem erros
