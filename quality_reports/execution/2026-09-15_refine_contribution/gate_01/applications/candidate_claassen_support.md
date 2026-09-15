# Ficha A3 corrigida — Claassen: apoio democrático e PIB per capita

**Classe literal E1–E7:** `HOLD_DOCUMENTATION`  
**Critério pendente:** `E7 = MISSING_NOT_FAIL`  
**Adequação adicional ao CET do plano:** `ORIGINAL_ASSUMPTIONS_EXCLUDE_CONTEMPORANEOUS_SUPPORT_EFFECT`  
**Papel na rota CET:** nenhuma principal ou reserva aprovada.

Esta ficha substitui a versão corrente da rodada inicial, preservada em `gate_01/review/snapshots/applications_round1/candidate_claassen_support.md`. A correção implementa R1-F001 e R1-F003.

## 1. Objeto documentado

- **Unidade e período:** país-ano. O artigo descreve painel de 135 países, com séries de quatro a 29 anos (p. 13); o código usa índices `Country` e `Year` (`supdem_democracy_ajps_replication_correct.R:26-35`).
- **Exposição D:** apoio público à democracia em `t-1`, `SupDem_trim` defasado um ano (artigo pp. 15–17; código `:49-56`).
- **Outcome Y:** democracia liberal do V-Dem em `t`, `Libdem_VD`.
- **Controle Z:** log do PIB per capita. O modelo original inclui `Z_{t-1}` ao lado de `D_{t-1}`; a base local preserva a série corrente e defasada.
- **História de Y:** duas defasagens de democracia fazem parte do modelo principal (`:49-56`).

## 2. Por que E7 é HOLD, não FAIL

O DAG do estudo afirma que desenvolvimento econômico causa apoio e democracia e assume ausência da seta apoio → desenvolvimento (artigo pp. 16–17). Assim, não se pode inventar PIB como mediador do apoio sob o DAG original.

Essa ausência de seta não satisfaz a regra afirmativa de FAIL do protocolo. PIB não é invariável, exclusivamente pós-outcome ou alheio ao processo D–Y; ao contrário, é confounder explícito. Falta demonstrar por que seu valor atual forneceria um contraste temporal relevante. O estado correto é `MISSING_NOT_FAIL` em E7 e `HOLD_DOCUMENTATION` no conjunto.

O caso ainda pode cumprir uma função de ausência de ganho ou ambiguidade causal, desde que essa função tenha alvo e timing documentados. Reabrir o caso não exige como único caminho provar apoio → PIB nem mudar silenciosamente o DAG.

## 3. Limite CET separado

O artigo assume que apoio não tem efeito contemporâneo sobre democracia e define `support_{t-1} -> democracy_t`. Portanto, o desenho original é de resposta subsequente. Mudar índices não cria um CET não nulo sob essas premissas.

Esse limite é mais forte que o HOLD documental de E7, mas pertence ao campo separado de adequação ao CET. Não converte E7 em inelegibilidade demonstrada.

## 4. Critérios literais e adequação ao plano

| Campo | Estado | Evidência e limite |
|---|---|---|
| E1 intervenção/exposição definida | PASS | Apoio em `t-1` e unidade país-ano são explícitos. |
| E2 janela exposição → Y | PASS | O artigo define apoio anterior e democracia posterior. |
| E3 história prévia | `PASS_DOCUMENTARY_WITH_LIMITS` | Y tem lags 1–2 e a série de PIB está disponível; uma história estritamente anterior a D precisaria recuar além de `t-1`. |
| E4 suporte/comparação | PASS documental | Painel e processo dinâmico são explícitos; suporte numérico não foi recalculado. |
| E5 painel/cluster | PASS documental | País/ano e opções de covariância estão no código; escolha final é Gate 3. |
| E6 dados/documentação | PASS | README, painel corrigido, codebook e script estão locais. |
| E7 contraste relevante | `MISSING_NOT_FAIL` | PIB integra o processo como confounder; falta documentar papel temporal variável. Ausência de D → PIB impede presumir mediação, mas não prova FAIL. |
| Adequação CET | `ORIGINAL_ASSUMPTIONS_EXCLUDE_CONTEMPORANEOUS_SUPPORT_EFFECT` | O paper exclui efeito contemporâneo de apoio sobre democracia. |

## 5. Trabalho que poderia mudar o HOLD

Sem alterar o DAG silenciosamente, uma reabertura poderia:

1. documentar uma função de caso sem ganho ou de ambiguidade, coerente com o papel de PIB como confounder;
2. localizar outro controle com papel temporal distinto, mediante novo protocolo autorizado;
3. redefinir o alvo para efeito futuro ou rota descritiva, se o autor escolher essa mudança científica;
4. demonstrar uma nova seta causal apenas se houver justificativa primária, sem tratá-la como requisito exclusivo.

## 6. Estimador e limites

- Apoio é estado latente suavizado; uma aplicação plena precisaria tratar incerteza de medição.
- O código contém OLS, FE dinâmico e GMM; GMM fica fora da identidade OLS sem derivação.
- `Z_{t-1}` é contemporâneo a `D_{t-1}`, não história pré-exposição.
- HOLD indica falta de demonstração, não exclusão substantiva.

**Conclusão corrigida:** Claassen passa E1–E6, fica `MISSING_NOT_FAIL` em E7 e `HOLD_DOCUMENTATION` no conjunto. Separadamente, as premissas originais excluem o efeito contemporâneo de apoio que a rota CET exigiria.
