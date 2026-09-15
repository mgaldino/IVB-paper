# Ficha A2 corrigida — Ballard-Rosa, Mosley e Wellhausen: partidarismo em exercício e crise inflacionária

**Classe literal E1–E7:** `HOLD_DOCUMENTATION`  
**Critério pendente:** `E7 = MISSING_TIMING`  
**Adequação adicional ao CET do plano:** `NOT_ESTABLISHED`  
**Papel na rota CET:** nenhuma principal ou reserva aprovada.

Esta ficha substitui a versão corrente da rodada inicial, preservada em `gate_01/review/snapshots/applications_round1/candidate_ballard_rosa_debt.md`. A correção implementa R1-F001, R1-F002 e R1-F006.

## 1. Objeto documentado

- **Unidade e período:** país-mês de emissor soberano, 1990–2016; a análise principal usa não membros da OCDE. O artigo descreve a base e a unidade nas pp. 47–48; o script ordena por `ccode time` (`IO replication.do:9-10,20-30,45-69`).
- **Exposição D original:** categoria partidária do Executivo em exercício, usada com um lag mensal. A fórmula distingue direita e esquerda contra a categoria omitida centro/outros (`IO replication.do:73-79`). Esta ficha considera o contraste **governo de esquerda em exercício versus centro/outros**. Governo de direita é um contraste separado.
- **D não é transição:** a data de posse atualiza a categoria mensal, mas o regressor inclui meses de continuidade. O modelo não estima automaticamente o efeito de uma nova entrada da esquerda.
- **Outcome Y:** proporção do valor dos títulos com maturidade mínima de um ano emitidos em moeda doméstica, `propDom_gt1yr`, no mês `t` (artigo p. 48; script `:70`).
- **Controle Z:** crise inflacionária, `crisis_inflation`. O script a usa sem lag no conjunto amplo e com `l.` nas interações (`:66-79,111-123`). Esse operador não demonstra a frequência de mensuração da fonte.

## 2. Frequência da crise e história

O artigo declara que os controles são anuais salvo indicação contrária (nota 94, p. 49). Na descrição do timing, as exceções explicitamente mensais são partidarismo e Treasury; as demais medidas à direita recebem lag de um ano (p. 50). As fontes examinadas não documentam crise inflacionária como exceção mensal.

Portanto:

- não se pode chamar `crisis_inflation_{t-2}` de história mensal seguramente pré-exposição;
- não se pode afirmar que `crisis_inflation_t` foi medido após `D_{t-1}`;
- uma classificação anual repetida por mês pode fazer `t`, `t-1` e `t-2` compartilharem o mesmo período de referência;
- o código prova como o regressor foi deslocado na grade mensal, não quando a crise foi observada ou começou.

E3 continua PASS de **disponibilidade potencial**: a base contém história de Y e crise que pode ser recuada. A ordem específica não está certificada. E7 fica MISSING porque falta a fonte primária da crise, sua frequência e regra de início/fim.

## 3. Objeto estatístico e limite CET

O modelo original associa a categoria do governo em exercício no mês anterior à emissão em `t`. Esse é um contraste de estado partidário defasado, não efeito de uma nova transição. Mesmo se a frequência da crise for resolvida, `D_{t-1} -> Y_t` continua resposta no mês seguinte. Reindexar períodos não demonstra CET.

Além disso, Y só existe em meses com emissão. O objeto é condicional à ocorrência de emissão e pode exigir tratamento de seleção.

## 4. Critérios literais e adequação ao plano

| Campo | Estado | Evidência e limite |
|---|---|---|
| E1 intervenção/exposição definida | `PASS_ORIGINAL_CATEGORICAL_EXPOSURE` | Estado partidário em exercício; esquerda versus centro/outros. Não é indicador de adoção/transição. |
| E2 janela exposição → Y | PASS | Categoria em `t-1` precede emissão em `t`; janela futura de um mês. |
| E3 história prévia | `PASS_AVAILABILITY_REQUIRES_CORRECTED_HISTORY_ROUTE` | Séries permitem buscar história mais antiga, mas `t-2` não está certificado como período distinto da crise anual. |
| E4 suporte/comparação | PASS documental | O modelo usa variação intrapaís e FE; suporte por categoria/transição não foi calculado. |
| E5 painel/cluster | PASS | País, tempo, FE e cluster por país estão explícitos no script e artigo. |
| E6 dados/documentação | PASS | DTA, TAB e do-file locais contêm os campos necessários; apenas esquema foi inspecionado. |
| E7 contraste relevante | `MISSING_TIMING` | Pertinência substantiva existe, mas frequência e intervalo da crise não foram reconciliados entre texto, fonte e código. |
| Adequação CET | `NOT_ESTABLISHED` | O modelo usa estado partidário em `t-1` para outcome em `t`; não há intervenção contemporânea demonstrada. |

## 5. Trabalho documental necessário

Sem estimar, seria necessário:

1. identificar a fonte primária de `crisis_inflation`;
2. documentar frequência, data de início/fim e regra de agregação;
3. reconciliar a descrição anual do artigo com usos sem lag e com `l.` no código;
4. definir uma história que termine antes da exposição partidária no período de referência real;
5. manter separados esquerda versus centro/outros e direita versus centro/outros;
6. congelar uma amostra comum e documentar meses sem emissão;
7. definir uma intervenção atual própria se o CET continuar sendo o alvo científico.

## 6. Estimador e limites

- Heckman, modelo em duas partes ou resposta fracional podem ser necessários; nenhum herda automaticamente a identidade OLS.
- A pertinência causal da crise não prova seu relógio.
- Data de posse constrói o estado partidário; não transforma cada observação em nova transição.
- O caso está em HOLD por falta documental, não por inelegibilidade demonstrada.

**Conclusão corrigida:** Ballard-Rosa não pode ser reserva neste Gate 1. E7 fica `MISSING_TIMING`, a classe literal é `HOLD_DOCUMENTATION` e a adequação CET não foi estabelecida.
