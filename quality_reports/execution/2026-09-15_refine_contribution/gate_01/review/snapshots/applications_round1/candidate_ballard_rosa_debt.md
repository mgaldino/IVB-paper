# Ficha A2 — Ballard-Rosa, Mosley e Wellhausen: governo de esquerda e crise inflacionária

**Classificação Gate 1:** `ELIGIBLE_DOCUMENTARY`  
**Papel provisório:** aplicação reserva, sujeita à matriz conjunta do Gate 3  
**Contraste:** manter crise inflacionária pré-exposição e acrescentar crise inflacionária atual  
**A classificação não usa IVB, erro-padrão, p-valor, sinal ou magnitude de coeficiente.**

## 1. Objeto aplicado

- **Unidade e período:** país-mês de emissor soberano, 1990–2016; análise principal em não membros da OCDE. O artigo descreve 131 emissores na base ampla e a unidade país-mês nas pp. 47–48. O script importa dados país-ano-mês, ordena por `ccode time` e usa 1990–2016 (`IO replication.do:9-10,20-30,45-69`).
- **Exposição D:** orientação partidária do Executivo, `execrlc_mo`, atualizada ao mês exato da posse e usada com uma defasagem mensal. O artigo explica que a posse, não a eleição anterior, inicia a capacidade de emitir dívida (p. 48, nota 91); o script usa `l.ib2.execrlc_mo` (`:73-79`).
- **Outcome Y:** proporção, pelo valor, dos títulos soberanos com maturidade de pelo menos um ano emitidos na moeda doméstica no mês, `propDom_gt1yr`. O artigo define o outcome e a unidade na p. 48; o script fixa essa variável em `:70`.
- **Controle Z:** indicador de crise inflacionária, `crisis_inflation`. O script mostra a variável atual no conjunto amplo de controles (`:66-79`) e também uma versão defasada em um mês nas especificações de interação (`:111-123`). Para esta triagem, a história precisa ser anterior ao início de `D_{t-1}`; portanto, o baseline candidato é `Z_{t-2}` ou mais antigo, e o modelo de união acrescenta `Z_t`.
- **História de Y:** a série mensal `propDom_gt1yr` permite construir lags, mas é observada somente em meses com emissão. O artigo explicita essa seleção na p. 50. Uma história realmente pré-exposição deve terminar em `Y_{t-2}` quando D é `t-1`.

## 2. Estimando e comparação a testar depois

O objeto documentalmente viável é a mudança na projeção linear intrapaís da proporção de emissão em moeda doméstica no mês `t`, associada à passagem para/exposição a governo de esquerda em `t-1`, entre:

1. modelo de história: `Y_t` em `D_{t-1}`, história de `Y` e crise terminando em `t-2`, demais histórias, tendência temporal comum e FE de país;
2. modelo de união: o mesmo modelo mais crise inflacionária atual `Z_t`.

Esse objeto é condicional à ocorrência de emissão com maturidade suficiente. O artigo descreve os resultados como observacionais e trata seleção para meses de emissão com um modelo de Heckman em robustez (p. 50). Uma leitura causal exige hipóteses adicionais sobre mudança de governo, emissão e crise.

## 3. Timing documentado

```text
t-2                         t-1                         t
Y e crise pré-exposição     governo em exercício D     emissão Y; crise atual Z
```

A data de posse permite ordenar D antes do outcome mensal. A crise inflacionária atual é pós-início do governo e pode ser influenciada por sua política; o artigo considera que governos de esquerda podem preferir expansão fiscal e que crises afetam a tolerância do mercado aos termos dos títulos (pp. 49 e 57). O início/fim da crise dentro do mês e a data de cada emissão não estão documentados na base agregada, de modo que o papel de `Z_t` deve permanecer ambíguo entre mediador, moderador e concomitante até o Gate 3.

## 4. Evidência por critério

| Critério | Estado | Evidência e limite |
|---|---|---|
| E1 intervenção atual definida | PASS | Governo em exercício é atualizado por data de posse e defasado um mês; artigo p. 48, nota 91, e script `:73-79`. |
| E2 janela exposição → Y | PASS | `D_{t-1}` precede emissão em `t`; outcome mensal é definido na p. 48. Data intramês de crise e emissão não está disponível. |
| E3 história prévia | PASS documental com risco | Séries mensais de Y e crise permitem lags até `t-2`; Y é ausente nos meses sem emissão (artigo p. 50), o que pode reduzir e selecionar a amostra comum. |
| E4 suporte/comparação | PASS documental | Mudanças de governo são datadas e a análise usa variação intrapaís com FE; artigo pp. 48–50 e script `:73-79`. Suporte por transição não foi calculado. |
| E5 painel/cluster | PASS | País-mês, `ccode time`, FE e cluster por país estão explícitos no script `:30-39,66-79`; o artigo reporta 79 países no modelo amplo e cluster por país nas pp. 50 e 55. |
| E6 dados acessíveis | PASS | DTA, TAB e do-file locais contêm D, Y, Z, país, ano, tempo e variáveis de amostra. O esquema foi inspecionado sem calcular estatísticas. |
| E7 contraste relevante | PASS | A crise atual aparece no modelo amplo; a versão defasada aparece em interações (`:66-82,111-123`). O argumento liga partidarismo, inflação e tolerância do mercado (artigo pp. 49, 57). |

## 5. Disponibilidade e preparação necessária

**Disponível:** DTA e TAB originais; do-file; identificadores país/tempo; partidarismo mensal; outcome mensal; crise atual; operadores de lag no código; FE e cluster por país; restrição não OCDE.

**Preparação antes de qualquer estimação:**

1. reconstruir o índice mensal `time` e verificar lacunas, sem tratar a linha anterior como mês anterior;
2. definir `Z_{t-2}` como história mínima e justificar a distância até D;
3. definir história de Y somente com meses anteriores à exposição e registrar quais observações sobrevivem;
4. congelar uma amostra comum entre história e união antes de estimar;
5. separar o efeito de acrescentar `Z_t` da seleção causada por meses sem emissão;
6. documentar início/fim intramês das crises, se a fonte original o permitir;
7. formular DAGs em que inflação é confounder persistente, mediador da política do governo, moderador da demanda ou proxy de crise macroeconômica;
8. avaliar se uma proporção com massa nos limites pede estimador fracional e se a seleção de emissão pede modelo em duas partes.

## 6. Limitações e possível estimador fora de OLS

- Y só existe quando há emissão; a análise condiciona em uma decisão que pode responder ao governo e à crise.
- Um modelo de Heckman, um modelo em duas partes ou um estimador fracional pode ser necessário. Nenhum herda automaticamente a identidade OLS.
- D é um estado político observacional, não uma intervenção atribuída aleatoriamente.
- A base país-mês não fornece na documentação examinada a ordem entre crise e emissão dentro do mês.
- O estimando condicional à emissão difere de um efeito sobre toda a política de financiamento soberano.

**Conclusão da ficha:** a candidata passa documentalmente e fica como reserva. Sua maior vantagem é alinhar OLS-FE, cluster de país e um controle atual explicitamente ligado ao mecanismo. Sua maior limitação é a seleção para meses com emissão, que pode deslocar o desenho para fora do núcleo OLS.
