# Plano: Atualização do Relatório v2 — Síntese Imai & Kim + Blackwell & Glynn

**Status**: APPROVED
**Data**: 2026-03-01

## Contexto

Após leitura cuidadosa de Imai & Kim (2019) e Blackwell & Glynn (2018), identificamos que:

1. **Imai & Kim** discutem violação de strict exogeneity (não "Nickell bias") — o TWFE básico é **não-identificado** quando há dinâmica causal. O viés é permanente (não O(1/T)).
2. **Blackwell & Glynn** mostram que o ADL tem **post-treatment bias** quando Z_it é afetado pelo tratamento. SNMM/MSM evitam isso mas não controlam por unobs time-invariant.
3. **Conexão com nosso paper**: O IVB (included variable bias) de controlar por Z dual-role é o **mesmo mecanismo** que o post-treatment bias de Blackwell — visto de ângulos diferentes.
4. **Insight principal**: Sob linearidade, o ADL+FE domina porque (a) o IVB/post-treatment bias é pequeno, e (b) FE controla por confounders time-invariant que MSM/IPTW não conseguem. Em CP, unobs time-invariant são ubíquos.

O relatório v2 atual usa "Nickell bias" incorretamente para descrever o argumento de Imai & Kim. Precisa de reframing completo + incorporação de Blackwell & Glynn.

## Objetivo

Atualizar `quality_reports/dual_role_z_simulation_report_v2.md` para:
1. Sintetizar corretamente Imai & Kim + Blackwell & Glynn
2. Reframear strict exogeneity como problema de identificação (não Nickell)
3. Conectar IVB ↔ post-treatment bias ↔ strict exogeneity
4. Articular por que ADL+FE é a escolha prática sob linearidade
5. Apontar simulações faltantes

## Mudanças no Relatório

### 1. Nova Seção 1.1: Framework Teórico (após Motivação)

Adicionar subseção que sintetiza os dois papers:

**Imai & Kim (2019): Identificação em modelos FE**
- O modelo NP-FE requer strict exogeneity: E(ε_it | X_i, α_i) = 0
- Strict exogeneity proíbe dinâmica: assumptions (a)-(d)
- Quando violada, o TWFE básico (Y ~ D | FE) é **não-identificado** — viés permanente
- Table 1 deles: trade-off entre time-invariant unobs vs dinâmica causal
- Modificações paramétricas (LDV, X_lag) relaxam parcialmente as assumptions
- "Partially allowed" = a especificação permite, mas estimador within precisa de IV

**Blackwell & Glynn (2018): Post-treatment bias no ADL**
- Sob sequential ignorability (mais fraca que strict exogeneity), ADL é viésado para efeitos defasados
- Z_it pós-tratamento: condicionar abre back-door path via U_i
- "There is no way to estimate the direct effect of lagged treatment without bias with a single ADL model"
- SNMM/MSM evitam o post-treatment bias, mas exigem todos confounders observados
- FE não é compatível com MSM/IPTW facilmente (footnote 13 do paper)

**Conexão com IVB**:
- IVB = post-treatment bias = conditioning on collider = mesmo mecanismo
- No nosso DGP: Z_{t-1} é pré-treatment para D_t (OK para efeito contemporâneo)
- Mas Z_{t-1} é pós-treatment para D_{t-1} (post-treatment bias para efeito defasado)
- A inclusão de Z_lag cria IVB MAS remove OVB maior → net benefit

**Tabela-síntese das abordagens**:

| Abordagem | Unobs time-invariant | Feedback Y→D | Carryover D→Y | Post-treatment Z |
|-----------|---------------------|--------------|---------------|-----------------|
| TWFE (Y~D\|FE) | Controla | Viés permanente | Viés permanente | N/A |
| ADL+FE | Controla | Parametricamente | Com D_lag | Pequeno sob linearidade |
| ADL+FE+IV (Arellano-Bond) | Controla | Consistente | Com D_lag | Pequeno + IV |
| SNMM | Não controla | Handles | Handles | Evita |
| MSM/IPTW | Não controla | Handles | Handles | Evita |

**Argumento-chave para o paper**: MSM/IPTW evitam o IVB mas NÃO controlam por α_i. Em CP, α_i (country effects, institutional factors) é ubíquo. Portanto, ADL+FE é preferível quando o IVB é pequeno — o que nossas simulações mostram ser o caso sob linearidade.

### 2. Reframing de Strict Exogeneity (múltiplas seções)

**Seção 3.4 (VaryT)** — Substituir interpretação:
- ATUAL: "O vies residual e Nickell bias, que e O(1/T)"
- NOVO: "O TWFE_s é não-identificado (viés permanente que CRESCE com T por acumulação de collider bias). O ADL_l_FE tem viés residual O(1/T) do estimador within com LDV, que converge a zero — é **consistente** sob as condições paramétricas."

**Seção 4.4 (Conexão Imai & Kim para feedback)**:
- REMOVER: "Nickell bias" como descrição do argumento de Imai & Kim
- NOVO: "Imai & Kim Figure 2(c): feedback viola strict exogeneity do TWFE básico → viés permanente (0.43-0.69 em nossas simulações). O ADL+FE é a solução paramétrica (Table 1 row 2), com viés residual < 0.01 sob T=30."

**Seção 6.5 e 7.3**: Remover "Nickell cost" como framing principal. Usar:
- "Viés do estimador within com LDV" quando se referir ao ADL+FE
- "Violação de strict exogeneity" quando se referir ao TWFE básico
- "Post-treatment bias" quando se referir ao efeito de incluir Z_lag

### 3. Nova Seção 7.6: ADL+FE vs MSM/IPTW — O Trade-off Prático

Seção nova após 7.5, argumentando:

1. **Blackwell & Glynn mostram** que ADL é viésado para efeitos defasados quando Z é post-treatment
2. **MSM/IPTW resolvem** o post-treatment bias, mas:
   - Não controlam por confounders time-invariant não-observados
   - Difíceis de implementar com FE + tratamento binário (BG footnote 13)
   - Requerem modelagem correta do propensity score
3. **Nossas simulações mostram** que sob linearidade, o post-treatment bias (IVB) é pequeno:
   - ADL_all com FE: |bias| ≈ 0.003-0.008
   - ADL_all sem FE: |bias| ≈ 0.12 (10-15x maior)
   - O custo de não ter FE >> custo do IVB
4. **Em aplicações de CP**: confounders time-invariant são a norma (country effects, institutions, geography). Não é plausível assumir ausência de unobs time-invariant.
5. **Conclusão**: ADL+FE é a escolha prática sob linearidade. O pesquisador aceita um IVB pequeno em troca de controle por α_i.
6. **Caveat**: sob não-linearidade, o IVB pode ser maior (não testado).

### 4. Atualização da Seção 8 (Limitações)

Adicionar/modificar:
- Item 2: "**DGP linear**: O resultado de que o IVB é pequeno depende criticamente da linearidade. Sob DGPs não-lineares, o post-treatment bias pode ser substancial (Blackwell & Glynn 2018, Figure 5). Testar com DGP não-linear é uma extensão importante."
- Novo item: "**Não comparamos diretamente com MSM/IPTW**: As simulações não incluem SNMM ou MSM como estimadores. A comparação é implícita (ADL com vs sem FE), mas uma comparação direta fortaleceria o argumento."

### 5. Atualização da Seção 9 (Implicações)

Reorganizar "O que incluir":
1. **Framework teórico**: Três perspectivas sobre o mesmo fenômeno (IVB, post-treatment bias, strict exogeneity violation)
2. **Tabela de trade-offs**: ADL+FE vs MSM/IPTW — quando cada abordagem é preferível
3. **Resultado quantitativo**: Sob linearidade, IVB é pequeno (<1% de beta) → ADL+FE domina quando há confounders time-invariant plausíveis
4. Manter: mapping Imai & Kim, resultado de carryover, restrição de estacionariedade

Atualizar "O que NÃO dizer":
- Item 1 (já correto): não dizer "Imai & Kim se preocupam com Nickell bias"
- NOVO: ~~"ADL+FE resolve o post-treatment bias"~~ → ADL+FE tem post-treatment bias pequeno sob linearidade, não zero. A solução "correta" seria SNMM/MSM, mas estes não controlam por α_i.

### 6. Atualização da Seção 11 (Resumo Executivo)

Reescrever para refletir o novo framing:
- Três perspectivas unificadas sobre o viés
- ADL+FE como escolha prática (não "solução ótima")
- Condições: linearidade + confounders time-invariant plausíveis

## Simulações Faltantes

### Necessárias (apontadas no relatório)

1. **DGP não-linear**: O resultado central ("IVB é pequeno sob linearidade") precisa de qualificação. Uma simulação com DGP não-linear (e.g., efeitos multiplicativos, log-linear, ou threshold effects) mostraria quando o IVB se torna substantivo. Isso fortaleceria o argumento ao delimitar quando ADL+FE funciona e quando não.

### Opcionais (nice-to-have)

2. **Comparação direta ADL vs SNMM/MSM no DGP com α_i**: Implementar MSM/IPTW (sem FE) no nosso DGP para mostrar empiricamente que o viés de não controlar por α_i domina o IVB. O argumento teórico é suficiente, mas evidência empírica seria mais convincente.

3. **DGP com δ_t (time FE)**: Já diagnosticado — adicionar time FE ao DGP não muda resultados. Mas para fidelidade ao framework de Imai & Kim, os DGPs deveriam incluí-los. Nota: resultados existentes são válidos (diag_time_fe_results.csv confirma max |diff| < 0.005).

## Arquivos a modificar

- [ ] `quality_reports/dual_role_z_simulation_report_v2.md` — Todas as mudanças acima

## Ordem das edições

1. Seção 1.1: Framework teórico (NOVA)
2. Seção 3.4: Reframing VaryT
3. Seção 4.4: Reframing Sim 1 conexão
4. Seção 7.3: Reframing trade-offs
5. Seção 7.6: ADL+FE vs MSM/IPTW (NOVA)
6. Seção 8: Limitações atualizadas
7. Seção 9: Implicações atualizadas
8. Seção 11: Resumo executivo reescrito

## Verificação

- [ ] Nenhuma menção a "Nickell bias" como argumento central de Imai & Kim
- [ ] Strict exogeneity framed como problema de identificação (permanente), não amostra finita
- [ ] Post-treatment bias (Blackwell) conectado a IVB
- [ ] Trade-off ADL+FE vs MSM/IPTW articulado explicitamente
- [ ] Linearidade identificada como condição crucial para o resultado "IVB pequeno"
- [ ] Simulação não-linear apontada como extensão necessária
