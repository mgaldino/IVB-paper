# Ficha A3 — Claassen: apoio democrático e PIB per capita

**Classificação Gate 1:** `INELIGIBLE_DEMONSTRATED` para o contraste PIB per capita atual  
**Papel provisório:** nenhuma seleção; preservado como exemplo descritivo/limite  
**Motivo decisivo:** o DAG primário assume que apoio não causa PIB e que PIB atua como confounder defasado; acrescentar PIB atual não representa, sob o argumento do estudo, um controle que muda de papel após a exposição.

## 1. Objeto aplicado

- **Unidade e período:** país-ano. O artigo descreve um painel de 135 países, com séries de quatro a 29 anos (p. 13), e o código declara `pdata.frame(..., index = c("Country", "Year"))` (`supdem_democracy_ajps_replication_correct.R:26-35`).
- **Exposição D:** apoio público à democracia no ano anterior, `SupDem_trim` defasado em um ano. O artigo formula o efeito de `s_{it-1}` sobre democracia `d_{it}` nas pp. 15–17; o código usa `plm::lag(SupDem_trim, 1)` (`:49-56`).
- **Outcome Y:** índice de democracia liberal do V-Dem no ano corrente, `Libdem_VD`.
- **Controle Z triado:** log do PIB per capita, `lnGDP_imp`. O modelo original inclui `Z_{t-1}` ao lado de `D_{t-1}` (`:49-56`). A base local também preserva `lnGDP_imp` e a versão defasada, conforme o cabeçalho e o codebook.
- **História de Y:** duas defasagens de democracia fazem parte do modelo principal (`:49-56`).

## 2. Estimando possível e por que ele não satisfaz E7

Seria mecanicamente possível comparar um baseline com PIB anterior à exposição, por exemplo `Z_{t-2}`, e um modelo de união que acrescentasse `Z_t`. Isso não basta para elegibilidade substantiva. No DAG do estudo, desenvolvimento econômico é um confounder que afeta apoio e democracia; o autor assume explicitamente que `z` influencia apoio, que apoio não influencia `z`, e que o efeito de `z` sobre democracia ocorre com um ano de atraso (artigo pp. 16–17). Sob essas premissas, PIB atual não adquire um papel pós-exposição relevante em relação a `D=support_{t-1}`. Criar o caso exigiria contrariar o argumento causal primário ou apenas trocar subscritos.

## 3. Evidência por critério

| Critério | Estado | Evidência e limite |
|---|---|---|
| E1 intervenção atual definida | PASS como exposição | Apoio em `t-1` e unidade país-ano são explícitos; artigo pp. 15–17 e código `:49-56`. |
| E2 janela exposição → Y | PASS | O artigo exclui efeito contemporâneo e define apoio em `t-1` sobre democracia em `t` (pp. 15–17). |
| E3 história prévia | PASS | Y tem lags 1–2; PIB corrente e lag estão na base; código `:49-56` e codebook pp. 12–20. |
| E4 suporte/comparação | PASS documental | O painel mede apoio e democracia ao longo do tempo e o artigo explicita o processo dinâmico; suporte numérico não foi recalculado. |
| E5 painel/cluster | PASS documental | País e ano são índices; o código usa Beck–Katz por tempo no principal e covariância Arellano por grupo em robustez (`:76-85,483-509`). A escolha adequada permanece para Gate 3. |
| E6 dados acessíveis | PASS | README identifica painel corrigido, codebook e script (`readme.txt:10-43`); TAB local contém as variáveis. |
| E7 contraste relevante | **FAIL demonstrado** | O DAG afirma `Z -> support`, ausência de `support -> Z` e efeito defasado de Z sobre Y (artigo pp. 16–17). Logo, PIB atual não tem o papel temporal variável exigido. |

## 4. Limitações adicionais

- Apoio é um estado latente suavizado ao longo do tempo; uma aplicação plena precisaria propagar incerteza de medição.
- O código oferece OLS pooled, FE dinâmico e system GMM. GMM fica fora da identidade OLS sem derivação específica (`:511-519`).
- PIB em `t-1` é contemporâneo à exposição em `t-1`, e não uma história pré-exposição; qualquer baseline válido precisaria recuar para `t-2`.
- A classificação negativa vale para o contraste **apoio × PIB atual** e para o contrato causal declarado pelo estudo. Ela não prova que o estudo inteiro seja incapaz de fornecer outro contraste após nova justificativa primária.

## 5. Trabalho que mudaria o estado

Para reabrir esta candidata seria necessária evidência substantiva primária de que apoio em `t-1` pode afetar PIB antes de `Y_t`, ou a escolha documentada de outro Z que possa responder ao apoio e também influenciar democracia. A simples construção de `lnGDP_imp_t` ou renomeação dos índices não supera o FAIL.

**Conclusão da ficha:** a candidata é documentalmente rica, mas falha por evidência afirmativa em E7. Isso é inelegibilidade demonstrada para o contraste selecionado, distinta de falta de arquivo ou de timing não encontrado.
