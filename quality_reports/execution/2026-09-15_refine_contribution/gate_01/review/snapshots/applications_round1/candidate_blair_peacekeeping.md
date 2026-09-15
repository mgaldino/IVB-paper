# Ficha A1 — Blair, Di Salvatore e Smidt: mandato de promoção da democracia e ajuda externa

**Classificação Gate 1:** `ELIGIBLE_DOCUMENTARY`  
**Papel provisório:** aplicação principal, sujeita à matriz conjunta do Gate 3  
**Contraste:** manter ajuda externa pré-exposição e acrescentar ajuda externa pós-exposição/atual  
**A classificação não usa IVB, erro-padrão, p-valor, sinal ou magnitude de coeficiente.**

## 1. Objeto aplicado

- **Unidade e período:** país africano afetado por conflito, ano, entre 1991 e 2016. O artigo define esse universo e a unidade país-ano nas pp. 1314–1317; o script ordena por `gwnoloc year` (`replication.do:42-60,75-95`).
- **Exposição D:** indicador de que uma missão da ONU possui mandato de promoção da democracia. Para a especificação principal considerada aqui, usa-se `ipema_any_demo_assist_dum_2l`, o mandato com defasagem de dois anos. O artigo explica que resoluções e fontes podem atravessar anos e usa dois períodos para reduzir causalidade reversa (pp. 1314–1316); o script constrói lags anuais e chama a Tabela 2 com o segundo lag (`replication.do:75-95,444-450`).
- **Outcome Y:** índice de democracia eleitoral do V-Dem, `v2x_polyarchy`, no ano corrente. O artigo define seus componentes na p. 1316; o dado local o rotula como “Electoral democracy (V-Dem)”.
- **Controle Z:** ajuda externa, `wdi_oda`. A história proposta é `iwdi_oda_3l`, anterior ao mandato em `t-2`; o valor atual é `iwdi_oda`. O artigo lista ajuda externa entre os seis controles e afirma que eles são defasados três períodos para evitar viés pós-tratamento (pp. 1316–1317). O script preserva a variável atual, imputa faltantes por média intrapaís e constrói lags 2–6 (`replication.do:99-130,355-387`).
- **História de Y:** o script produz `v2x_polyarchy_1l` a `v2x_polyarchy_5l` (`replication.do:42-60`). Para ser realmente pré-exposição quando `D=D_{t-2}`, a história candidata precisa terminar em `Y_{t-3}`; `Y_{t-1}` e `Y_{t-2}` não podem ser chamados de pré-exposição sem redefinir o alvo.

## 2. Estimando e comparação a testar depois

O objeto documentalmente viável é a mudança na projeção linear intrapaís do índice de democracia em `t` associada à presença do mandato em `t-2`, ao comparar, sobre a mesma amostra:

1. modelo de história: `Y_t` em `D_{t-2}`, história de `Y` terminando em `t-3`, ajuda externa `Z_{t-3}`, demais histórias e efeitos fixos de país;
2. modelo de união: o mesmo modelo mais ajuda externa atual `Z_t`.

A interpretação como efeito causal contemporâneo/direto permanece condicional. O artigo usa efeitos fixos e também instrumentos baseados em padrões de outros mandatos. Se a estratégia causal escolhida no Gate 3 exigir IV/2SLS, a identidade OLS do núcleo não pode ser transportada automaticamente para esse estimador.

## 3. Timing documentado

```text
t-3                  t-2                         t
Y e ajuda externa    mandato da ONU D            democracia Y
pré-exposição        exposição principal         ajuda externa atual Z
```

O intervalo exposição–outcome é anual e positivo. O próprio artigo registra melhora por vezes no primeiro ano e por vezes um ou dois anos depois (p. 1324), além de testar lags alternativos. O valor atual de ajuda externa ocorre após `D_{t-2}`, mas compartilha o ano de `Y_t`; a ordem intranual entre ajuda e democracia não está documentada. Isso limita a distinção entre mediador, proxy e variável concomitante, sem apagar seu status pós-exposição.

## 4. Evidência por critério

| Critério | Estado | Evidência e limite |
|---|---|---|
| E1 intervenção atual definida | PASS | PEMA codifica criação/revisão de mandatos; exposição anual e segundo lag estão no artigo pp. 1314–1316 e no script `:75-95,444-450`. |
| E2 janela exposição → Y | PASS | `D_{t-2}` precede `Y_t`; artigo pp. 1314–1316 e 1324. A ordem ajuda–Y dentro de `t` é incerta. |
| E3 história prévia | PASS | Lags 1–5 de Y e 2–6 dos controles existem no script `:42-60,112-130`; a história admissível termina em `t-3`. |
| E4 suporte/comparação | PASS documental | Mandatos são estabelecidos, ampliados e revistos ao longo do painel; o artigo documenta variação e estratégias FE/IV nas pp. 1314–1318. Suporte numérico não foi calculado. |
| E5 painel/cluster | PASS documental com risco | País e ano estão disponíveis; FE de país são explícitos no artigo e no programa `indvar_separate_ctrls.ado:13-27`. A implementação principal observada usa a covariância padrão de `xtreg`; o nível de dependência adequado precisa ser decidido no Gate 3. |
| E6 dados acessíveis | PASS | DTA, script, variáveis atuais e lags estão locais; o esquema foi inspecionado sem ler observações ou calcular estatísticas. |
| E7 contraste relevante | PASS | Os autores defasam controles especificamente para evitar pós-tratamento (pp. 1316–1317) e discutem que prioridades da ONU podem influenciar outros doadores (pp. 1317–1318). Manter `Z_{t-3}` e acrescentar `Z_t` testa uma decisão substantiva real. |

## 5. Disponibilidade e preparação necessária

**Disponível:** DTA original; script Stata; indicador de mandato atual e seus lags; outcome atual e lags; ajuda externa atual e lags; identificadores país/ano; efeitos fixos; alternativas de exposição (pessoal e atividades).

**Preparação antes de qualquer estimação:**

1. conferir lacunas anuais por país, porque o script usa posições de linha após ordenar e não declara `xtset` antes de gerar os lags;
2. congelar qual mandato constitui D e por que `t-2` é o relógio relevante;
3. definir história de Y terminando em `t-3` e justificar sua ordem, sem retirar história ao acrescentar `Z_t`;
4. construir amostra comum antes dos dois modelos e separar a perda causada pela disponibilidade de `Z_t`;
5. auditar a imputação por média intrapaís, que usa informação de anos posteriores e pode ser incompatível com uma história estritamente pré-exposição;
6. decidir dependência e inferência por país, missões simultâneas e choques comuns;
7. formular DAGs concorrentes para ajuda externa: confounder persistente, resposta doadora ao mandato, mediador e proxy de crise.

## 6. Limitações e possível estimador fora de OLS

- O desenho observacional mantém seleção de missões e mandatos; FE não resolve sozinho a endogeneidade documentada.
- A estratégia IV do artigo pode ser necessária para a leitura causal e fica fora da identidade OLS até derivação própria.
- Ajuda externa e Y têm referência anual; o ordenamento dentro do ano `t` é incerto.
- A imputação por média intrapaís incorpora potencialmente o futuro e precisa ser substituída, restringida ou tratada explicitamente.
- Dependência transversal entre missões, decisões do Conselho de Segurança e doadores pode exigir inferência além de cluster simples por país.

**Conclusão da ficha:** a candidata passa a elegibilidade documental porque possui exposição datada, janela positiva, história reconstruível, dados locais e um contraste que os próprios autores associam ao risco pós-tratamento. O PASS não aprova causalidade, IV, inferência ou número de lags.
