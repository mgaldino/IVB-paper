# Seleção provisória das aplicações

## Decisão

Há duas candidatas que passam documentalmente os sete critérios. A seleção provisória é:

1. **Principal: Blair, Di Salvatore e Smidt — mandato de promoção da democracia; ajuda externa histórica e atual.** O caso tem o relógio mais claro do acervo examinado: história em `t-3`, mandato em `t-2` e outcome em `t`. Os autores defasam os controles para evitar pós-tratamento, o que torna a inclusão adicional de ajuda externa atual uma decisão metodológica já motivada pelo próprio desenho.
2. **Reserva: Ballard-Rosa, Mosley e Wellhausen — governo de esquerda; crise inflacionária histórica e atual.** O caso usa país-mês, posse datada, FE e cluster por país. Ele é reserva porque Y só existe nos meses com emissão, criando uma seleção que pode exigir Heckman, modelo em duas partes ou resposta fracional fora do núcleo OLS.

**Claassen — apoio democrático e PIB per capita** não passa para o contraste triado. O paper assume que apoio não causa o confounder econômico e que o efeito de PIB sobre democracia é defasado. Sob esse DAG, PIB atual não é um controle que muda de papel após a exposição. Esse é um FAIL afirmativo em E7, não ausência documental.

## Matriz resumida

| candidata | E1 | E2 | E3 | E4 | E5 | E6 | E7 | classe | papel |
|---|---|---|---|---|---|---|---|---|---|
| Blair: mandato → democracia; ajuda externa | PASS | PASS | PASS | PASS doc. | PASS doc./risco | PASS | PASS | `ELIGIBLE_DOCUMENTARY` | principal |
| Ballard-Rosa: governo de esquerda → denominação; inflação | PASS | PASS | PASS/risco | PASS doc. | PASS | PASS | PASS | `ELIGIBLE_DOCUMENTARY` | reserva |
| Claassen: apoio → democracia; PIB p.c. | PASS | PASS | PASS | PASS doc. | PASS doc. | PASS | **FAIL** | `INELIGIBLE_DEMONSTRATED` | nenhuma |

`PASS doc.` registra que a estrutura está documentada sem teste numérico de suporte. `PASS/risco` indica que a variável existe, mas a amostra comum pode ser severamente selecionada. Os detalhes e localizadores estão nas três fichas.

## Status e regra de troca

A escolha permanece **provisória até o Gate 3**. A reserva só pode substituir a principal por uma quebra de elegibilidade definida no protocolo, como história inviável, amostra comum inexistente, dependência sem inferência defensável, incompatibilidade entre estimando e estimador ou dados necessários indisponíveis. Resultado posterior pequeno, nulo, desfavorável ou sem ganho incremental não autoriza troca.

Nenhuma regressão, R, Stata, bootstrap, IVB, shift ou estatística dos dados foi executada. A seleção avalia a possibilidade documental de testar a aplicação; não aprova identificação causal ou inferência.

## Riscos que o Gate 3 deve resolver

| caso | risco que pode retirar elegibilidade | teste documental/estatístico posterior |
|---|---|---|
| Blair | lags por posição de linha; imputação com médias que usam o futuro; OLS-FE sem cluster explícito; causalidade pode depender de IV | validar calendário, amostra comum e imputação; matriz de dependência; decidir se o alvo permanece OLS ou exige IV |
| Ballard-Rosa | Y ausente sem emissão; lags mensais com lacunas; data intramês da crise; proporção limitada | validar índice mensal e disponibilidade de `Y_{t-2}`; modelar seleção; decidir OLS, fracional ou duas partes |

## Limite de cegamento e revisão independente

Ao abrir o roster do Gate 0 para identificar o universo, o comando exibiu também colunas numéricas de IVB e erro-padrão que estavam no mesmo CSV. Nenhum valor foi copiado para as fichas, para a matriz ou para a justificativa, e o protocolo foi congelado antes da classificação. Ainda assim, a cegueira estrita à informação proibida não pode ser certificada para esta triagem. O revisor independente deve repetir a escolha usando somente `protocol.json`, nomes dos estudos e as fontes primárias listadas no manifesto, sem abrir o CSV do Gate 0. Uma coincidência da rota sob essa repetição elimina a dúvida de influência; divergência exige adjudicação substantiva.
