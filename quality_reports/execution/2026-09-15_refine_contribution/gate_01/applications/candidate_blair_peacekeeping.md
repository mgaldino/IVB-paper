# Ficha A1 corrigida — Blair, Di Salvatore e Smidt: mandato de promoção da democracia e ajuda externa

**Classe literal E1–E7:** `ELIGIBLE_DOCUMENTARY`  
**Adequação adicional ao CET do plano:** `NOT_ESTABLISHED`  
**Papel na rota CET:** nenhuma principal ou reserva aprovada  
**Contraste documental:** manter ajuda externa pré-exposição e acrescentar ajuda externa posterior/atual, se o relógio for confirmado nos gates seguintes.

Esta ficha substitui a versão corrente da rodada inicial, preservada em `gate_01/review/snapshots/applications_round1/candidate_blair_peacekeeping.md`. A correção implementa R1-F001 e registra a retratação do revisor em R1-F005. Não usa resultados empíricos para reclassificar o caso.

## 1. Objeto documentado

- **Unidade e período:** país africano afetado por conflito, ano, entre 1991 e 2016. O artigo define universo e unidade país-ano nas pp. 1314–1317; o script ordena por `gwnoloc year` (`replication.do:42-60,75-95`).
- **Exposição D no modelo original:** presença de mandato de promoção da democracia, `ipema_any_demo_assist_dum`, usada como `D_{t-2}`. O artigo explica o segundo lag nas pp. 1314–1316; o script o constrói e usa na Tabela 2 (`replication.do:75-95,444-450`).
- **Outcome Y:** democracia eleitoral do V-Dem, `v2x_polyarchy`, no ano `t`.
- **Controle Z:** ajuda externa, `wdi_oda`. O modelo original usa `Z_{t-3}`; o artigo diz que os controles recebem três lags para evitar pós-tratamento (pp. 1316–1317). O script preserva Z atual e cria lags 2–6 (`replication.do:99-130,355-387`).
- **História de Y:** o script cria lags 1–5 (`replication.do:42-60`). Se a exposição continuar definida em `t-2`, uma história estritamente anterior precisa terminar antes dessa exposição.

## 2. Objeto estatístico disponível e limite CET

O desenho documenta uma **resposta futura**: mandato em `t-2` e democracia em `t`. Reindexar o mandato como período zero não transforma `Y_{t}` em outcome contemporâneo; ele continua dois anos posterior à exposição documentada.

A comparação OLS documentalmente possível mantém uma história anterior ao mandato e acrescenta ajuda externa observada depois dele. Ela pode estudar como o coeficiente de uma projeção futura muda quando se acrescenta Z. Isso não demonstra o **efeito contemporâneo (CET)** exigido pelo plano porque ainda faltam:

1. uma intervenção atual definida em tempo físico, em vez de apenas `D_{t-2}`;
2. uma janela contemporânea entre essa intervenção e Y;
3. a trajetória do mandato entre `t-2` e `t`, inclusive persistência, revisão ou retirada;
4. a relação causal entre ajuda externa atual, a trajetória do mandato e democracia;
5. a distinção entre efeito contemporâneo total e efeito direto.

Logo, a classe literal `ELIGIBLE_DOCUMENTARY` não autoriza o rótulo de aplicação principal CET.

## 3. Timing efetivamente documentado

```text
t-3                  t-2                         t
história de Y/Z      mandato D                   democracia Y; ajuda Z
pré-D                exposição original          resposta dois anos depois
```

O artigo também registra respostas por vezes no primeiro ano e por vezes um ou dois anos depois (p. 1323). Isso reforça a interpretação de efeito futuro e a necessidade de modelar a trajetória. A ordem intranual entre ajuda e democracia em `t` não está documentada.

## 4. Critérios literais e adequação ao plano

| Campo | Estado | Evidência e limite |
|---|---|---|
| E1 intervenção/exposição definida | PASS | Mandato anual e segundo lag estão documentados; isso define a exposição do modelo original, não uma intervenção CET atual. |
| E2 janela exposição → Y | PASS | `D_{t-2}` precede `Y_t`; a janela é futura. |
| E3 história prévia | PASS | Lags de Y e controles estão disponíveis no script. A ordem admissível permanece para Gates 2–3. |
| E4 suporte/comparação | PASS documental | O artigo documenta variação de mandatos e estratégias FE/IV; suporte numérico não foi avaliado. |
| E5 painel/cluster | `PASS_DOCUMENTARY_WITH_RISK` | País, ano e dependência intrapaís são identificáveis. A objeção inicial do revisor que exigia VCE agrupada já no Gate 1 foi retratada e refutada na adjudicação R1-F005. Inferência continua pendente no Gate 3. |
| E6 dados/documentação | PASS | DTA, script, variáveis atuais e lags estão locais; só metadados foram inspecionados. |
| E7 contraste relevante | PASS literal | Os autores defasam controles para evitar pós-tratamento e discutem possível resposta de outros doadores às prioridades da ONU. Isso sustenta o contraste, sem provar mediação ou CET. |
| Adequação CET | `NOT_ESTABLISHED` | `D_{t-2} -> Y_t` é uma resposta futura; não há intervenção atual e janela contemporânea demonstradas. |

## 5. Disponibilidade e preparação necessária

Antes de qualquer execução, os gates seguintes precisariam:

1. conferir lacunas anuais porque os lags são gerados por posição de linha;
2. auditar a imputação por média intrapaís, que pode usar anos futuros;
3. congelar amostra comum e separar perdas de disponibilidade;
4. justificar história e lags sem retirar história ao acrescentar Z;
5. decidir dependência entre países, missões e anos;
6. decidir se o alvo é OLS descritivo ou se exige IV/2SLS;
7. definir, se a rota CET for mantida, uma exposição verdadeiramente atual, o outcome correspondente e a trajetória do tratamento.

## 6. Estimador e limites

- A leitura causal do artigo pode depender de IV/2SLS, que não herda a identidade OLS sem derivação.
- FE não equivale a clustering; a estrutura é reconstruível, mas a inferência não foi aprovada.
- Ajuda e democracia têm referência anual; seu ordenamento dentro do ano `t` permanece incerto.
- A classe literal passa; a aplicação CET não passa neste gate.

**Conclusão corrigida:** Blair continua `ELIGIBLE_DOCUMENTARY` sob E1–E7, inclusive E5 documental com risco. É uma candidata útil para projeções futuras ou para uma rota descritiva. Não há principal ou reserva aprovada para o CET.
