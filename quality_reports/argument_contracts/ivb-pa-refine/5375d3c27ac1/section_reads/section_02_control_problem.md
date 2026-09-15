**Record:** `reader-control-problem`  
**Seção:** 2, fonte 196–207

**Tese.** Para o efeito contemporâneo do tratamento (CET), a decisão sobre um controle variante no tempo depende de seu papel causal e de seu timing. O paper propõe separar o deslocamento observável entre especificações de sua interpretação causal e avaliar um baseline dinâmico estritamente condicional.

| Claim | Localizador | Escopo |
|---|---:|---|
| \(Z_t\) pode ser confounder, collider ou mediador; \(Z_{t-1}\) pode ser estado predeterminado relativamente ao CET. | 198 | Papéis possíveis, determinados pelo timing; o índice temporal não os estabelece sozinho. |
| Heurísticas de seleção por previsão do outcome ou causas comuns são insuficientes quando o controle pode ser pós-tratamento. | 200 | Problema situado em TSCS com evolução conjunta e persistência de \(D\), \(Z\) e \(Y\). |
| Se \(Z_t\) responde ao tratamento, incluir ou omitir seu valor realizado pode falhar em identificar o alvo; \(Z_t(0)\) pode ser o objeto relevante. | 202 | Motivação oriunda de DID; o paper declara não resolver o problema geral. |
| A resposta tem dois componentes: decomposição exata do deslocamento em modelos lineares aninhados e avaliação de ADL+FE com estados defasados como baseline do CET. | 204 | Chamar o deslocamento de viés causal exige DAG, estimando e identificação; o baseline depende de condições posteriores. |
| “Pré-tratamento” para \(Z_{t-1}\) é uma classificação relativa ao CET e ao timestamp substantivo. | 206 | Pode falhar para efeitos cumulativos, retardados ou de longo prazo. Resultados formais e aplicados ficam no TSCS linear. |

**Não-afirmações.** A seção não oferece regra geral de inclusão; não afirma que defasar torne um controle admissível; não identifica causalmente todo deslocamento; não resolve o problema geral de covariáveis afetadas pelo tratamento; não estende os resultados formais a DID.

**Ambiguidades.** “CET” é descrito aqui como efeito de \(D_t\) sobre \(Y_t\), ainda sem definir janela, contraste ou heterogeneidade. “Sob condições declaradas” antecipa restrições ainda não enumeradas nesta seção.
