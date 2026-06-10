# Q&A

1. **Qual é o objetivo da simulação calibrada pela Jensen?**  
Separar, em um DiD não escalonado com dois períodos, três fontes distintas de movimento do coeficiente:
   - o modelo-base;
   - o ganho de um bloco `safe` construído com covariáveis pré-tratamento interagidas com o pós;
   - o deslocamento adicional ao incluir controles time-varying realizados.

2. **Por que calibrar pela Jensen em vez da Kronick?**  
Porque a Jensen entrega um padrão mais informativo para o paper. O artigo já distingue explicitamente especificações com e sem time-varying controls, e nossa extensão mostrou que grande parte da mudança do coeficiente vem do bloco `safe`, não apenas dos controles realizados no pós.

3. **Quais números devem guiar a calibração?**  
Na replicação em [jensen_ivb_report.pdf](/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/replication/jensen_ivb_report.pdf):

- **Full sample**
  - base: `0.137`
  - base + TVC: `0.130`
  - base + `safe`: `0.111`
  - base + `safe` + TVC: `0.107`

- **Restricted control group**
  - base: `0.096`
  - base + TVC: `0.106`
  - base + `safe`: `0.078`
  - base + `safe` + TVC: `0.089`

# Objetivo substantivo

A simulação deve responder à seguinte pergunta:

> Em um DiD não escalonado, quando o pesquisador compara um modelo “sem controles adicionais” com um modelo “com controles time-varying”, em que medida essa diferença reflete:
> 1. omissão de um bloco `safe` baseado em informação pré-tratamento; e
> 2. inclusão de controles realizados no pós-tratamento?

O alvo não é reproduzir a Jensen linha por linha, mas reproduzir a **geometria empírica** do caso:

- o bloco `safe` move o coeficiente mais do que os TVCs no full sample;
- no restricted sample, os TVCs podem até mover o coeficiente no sentido oposto ao ajuste `safe`;
- o modelo completo pode mascarar essa diferença de mecanismos.

# DGP proposto

## Estrutura

Dois períodos, `t in {0,1}`, e tratamento binário não escalonado `D_i`.

### Outcome sem tratamento

\[
Y_{it}(0) = \alpha_i + \lambda_t + \beta_V V_i \cdot Post_t + \beta_X' X_i \cdot Post_t + u_{it}
\]

onde:

- `V_i` é uma medida binária de participação pré-tratamento, análoga a `voted_in_PREPERIOD`;
- `X_i` é um vetor de covariáveis pré-tratamento observáveis, análogo a `rr_dyn_ses`, `rr_dyn_cog`, sexo e raça;
- `Post_t` é o indicador do período pós.

### Efeito causal total

\[
Y_{i1}(1) - Y_{i1}(0) = \tau + \kappa' Z_{i1}(1)
\]

onde `Z_{i1}` é um vetor de variáveis time-varying realizadas no pós. Isso permite que parte do efeito total opere por canais que depois podem ser “controlados a mais”.

### Controles realizados no pós

\[
Z_{i1} = \Pi D_i + \Gamma X_i + \eta_i
\]

com `Z_{i0}` pré-tratamento não entrando na estimação principal. O vetor `Z_{i1}` deve representar mecanismos do tipo:

- morar com os pais;
- casar;
- ter filhos;
- trabalhar;
- mobilidade residencial;
- choques familiares.

Não é necessário replicar todos esses canais separadamente; basta um vetor pequeno com sinais plausíveis.

# Especificações a comparar

## Modelo-base

\[
Y_{it} = \alpha_i + \lambda_t + \delta (D_i \cdot Post_t) + \rho (V_i \cdot Post_t) + \varepsilon_{it}
\]

Este é o análogo de `m1` ou `m4`.

## Modelo com TVCs

\[
Y_{it} = \alpha_i + \lambda_t + \delta^{tvc} (D_i \cdot Post_t) + \rho (V_i \cdot Post_t) + \theta' Z_{it} + \varepsilon_{it}
\]

Este é o análogo de `m2` ou `m5`.

## Modelo safe

\[
Y_{it} = \alpha_i + \lambda_t + \delta^{safe} (D_i \cdot Post_t) + \rho (V_i \cdot Post_t) + \psi' (X_i \cdot Post_t) + \varepsilon_{it}
\]

Este é o modelo novo que a Jensen não reporta explicitamente, mas que nosso paper quer enfatizar.

## Modelo completo

\[
Y_{it} = \alpha_i + \lambda_t + \delta^{full} (D_i \cdot Post_t) + \rho (V_i \cdot Post_t) + \psi' (X_i \cdot Post_t) + \theta' Z_{it} + \varepsilon_{it}
\]

Este é o análogo de `m3` ou `m6`.

# Quantidades de interesse

## Decomposição principal

\[
OVB_{safe} = \hat{\delta}^{base} - \hat{\delta}^{safe}
\]

\[
IVB_{post} = \hat{\delta}^{full} - \hat{\delta}^{safe}
\]

\[
Article\ shift = \hat{\delta}^{tvc} - \hat{\delta}^{base}
\]

O ponto da simulação é mostrar que `Article shift` mistura duas coisas e, por isso, pode ser enganoso sobre o papel dos TVCs.

## Métricas

- viés médio de cada especificação em relação ao `ATT` total verdadeiro;
- RMSE;
- cobertura;
- `OVB_safe`;
- `IVB_post`;
- sinal de `IVB_post` e sinal de `OVB_safe`.

# Cenários mínimos

## Cenário A: Jensen-like full sample

Calibrar parâmetros para obter aproximadamente:

- `base - safe ≈ +0.026`
- `full - safe ≈ -0.005`
- `tvc - base ≈ -0.007`

Intuição:

- heterogeneidade relevante em `X_i × Post_t`;
- TVCs afetados pelo tratamento, mas com efeito incremental pequeno depois que o bloco `safe` entra.

## Cenário B: Jensen-like restricted sample

Calibrar parâmetros para obter aproximadamente:

- `base - safe ≈ +0.018`
- `full - safe ≈ +0.012`
- `tvc - base ≈ +0.010`

Intuição:

- o conjunto restrito altera a composição do grupo de comparação;
- o bloco `safe` reduz a estimativa;
- os TVCs a puxam parcialmente de volta para cima.

## Cenário C: Amplificação de IVB_post

Partir do cenário A ou B e aumentar `\Pi` ou `\kappa` para obter:

- `|IVB_post|` comparável ou maior que `|OVB_safe|`.

Esse cenário não precisa ser “empiricamente típico”. Ele serve para mostrar quando o problema de incluir os TVCs realmente domina.

# Implementação em R

## Arquivos sugeridos

- Script de geração e estimação:  
  [simulations/dynamics/sim_jensen_two_period.R](/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/simulations/dynamics/sim_jensen_two_period.R)

- Relatório curto:  
  [quality_reports/sim_jensen_two_period_report.Rmd](/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/quality_reports/sim_jensen_two_period_report.Rmd)

## Pacotes

- `fixest`
- `dplyr`
- `readr`
- `ggplot2`
- `modelsummary` ou `knitr`

## Grade inicial

- `N = {2_000, 5_000, 10_000}`
- proporção tratada `p(D=1) = {0.2, 0.4}`
- intensidade da heterogeneidade em `X_i × Post_t`
- intensidade da dependência de `Z_{i1}` no tratamento
- intensidade da relação entre `Z_{i1}` e `Y_{i1}`

# Resultado esperado

Se a calibração funcionar, a simulação deve mostrar:

1. que comparar apenas `base` e `base + TVC` pode superestimar ou subestimar o papel dos TVCs;
2. que o bloco `safe` pode fazer a maior parte do trabalho mesmo quando o artigo enfatiza a inclusão de controles time-varying;
3. que a direção do deslocamento causado pelos TVCs pode mudar com a composição da amostra, como no contraste entre `m1`--`m3` e `m4`--`m6`.

# Próximo passo recomendado

Implementar primeiro os cenários A e B e verificar se a decomposição empírica aproximada da Jensen aparece. Só depois vale abrir um cenário C, em que `IVB_post` seja deliberadamente grande.
