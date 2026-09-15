# Disposição do acervo

O Gate 0 enumera seis grupos de estudos. O protocolo permite no máximo três leituras integrais. A disposição abaixo separa seleção, não seleção por limite e inelegibilidade demonstrada.

| grupo do acervo | disposição | justificativa documental | o que a disposição não significa |
|---|---|---|---|
| Blair et al. | `SCREENED_ELIGIBLE` | exposição em `t-2`, controles em `t-3`, outcome em `t`, dados e código locais; o artigo declara a defasagem dos controles para evitar pós-tratamento | não prova causalidade ou compatibilidade com IV |
| Ballard-Rosa et al. | `SCREENED_ELIGIBLE` | país-mês, posse precisa, D em `t-1`, crise atual e defasada, FE/cluster reconstruíveis | não resolve seleção para meses com emissão |
| Claassen | `SCREENED_INELIGIBLE_FOR_NAMED_CONTRAST` | DAG e código são claros, mas o próprio DAG exclui apoio → PIB e trata PIB como confounder defasado | não torna o estudo inteiro inútil nem prova ausência de outro Z |
| Leipziger | `NOT_SCREENED_KNOWN_DOCUMENTATION_LIMIT` | plano e instrução do Gate registram timing/história ambíguos; com o teto de três, não recebeu nova leitura integral | falta de documentação localizada não é inelegibilidade demonstrada |
| Rogowski et al. | `NOT_SCREENED_KNOWN_DOCUMENTATION_LIMIT` | plano e instrução do Gate registram timing/história ambíguos; com o teto de três, não recebeu nova leitura integral | falta de documentação localizada não é inelegibilidade demonstrada |
| Albers et al. | `NOT_SCREENED_CAP_REACHED` | o teto foi preenchido por dois desenhos com relógio explícito e um teste negativo com DAG explícito; reconstruir a intervenção atual no painel fiscal histórico exigiria uma quarta leitura | não houve julgamento de elegibilidade nem exclusão substantiva |

## Controles adicionais nos mesmos estudos

PIB per capita e refugiados/IDPs em Blair, e programa do FMI e crise da dívida em Ballard-Rosa, permanecem controles alternativos dentro das mesmas aplicações. Eles não foram contados como novas candidatas porque o protocolo fixa como unidade o estudo-desenho mais um contraste nomeado. A eventual troca do Z dentro do mesmo estudo exigirá justificar previamente uma falha documental do Z escolhido; conveniência de resultado não é motivo válido.

## Busca adicional

Não se ativa busca adicional neste Gate 1 porque duas candidatas passam documentalmente. Se ambas falharem no Gate 3, a busca autorizável deve ser delimitada antes de começar:

- **tipo de desenho:** painel anual ou subanual com exposição datada, outcome posterior, história de Y/Z anterior à exposição e controle atual plausivelmente afetado pela exposição;
- **fontes:** repositórios primários de periódicos e arquivos de replicação públicos, priorizando ciência política aplicada;
- **teto:** até oito estudos triados por título/resumo e no máximo três textos integrais;
- **parada:** primeiro par principal/reserva que passe E1–E7, ou três leituras integrais sem PASS;
- **saída se falhar:** rota descritiva explicitamente rotulada para decisão do autor, sem renomear índices temporais.
