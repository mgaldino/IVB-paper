# Protocolo congelado de triagem documental das aplicações

**ID:** `IVB-G1-APPLICATIONS-2026-09-15-v1`  
**Estado:** `FROZEN_BEFORE_CANDIDATE_TRIAGE`  
**Escopo:** até três candidatas do acervo local, sem estimar modelos nem consultar resultados para escolher o caso.

## Pergunta e unidade de triagem

A triagem pergunta se um desenho permite documentar uma exposição atual, um outcome posterior, uma história realmente pré-exposição e uma comparação interpretável entre manter essa história e acrescentar um controle atual sobre amostra comum. A unidade é o par **estudo-desenho + um contraste substantivo de controle atual**. Vários controles do mesmo estudo não contam como aplicações independentes.

## Informação proibida para seleção

Não podem orientar a escolha: IVB ou shifts de especificação, erros-padrão, p-valores, significância, sinal ou magnitude de coeficientes e qualquer resultado favorável ao procedimento. A inspeção permitida limita-se a fontes primárias locais: texto integral do estudo, README, codebook, apêndices, scripts originais para definição e timing, e esquema dos dados. Não serão executados R, Stata, regressões, estatísticas substantivas ou cálculos de shift.

## Critérios definidos antes da triagem

| ID | Critério | Evidência mínima para PASS | Falta documental | Inelegibilidade demonstrada |
|---|---|---|---|---|
| E1 | Intervenção/exposição atual definida | fonte primária identifica o que muda, para quem e quando | variável existe, mas timing/significado é insuficiente | a fonte mostra que a exposição não pode ser datada ou não existe na unidade |
| E2 | Janela exposição → outcome | datas ou intervalos ordenam D antes de Y; medidas no mesmo período exigem ordem intraperíodo | rótulos temporais sem datas/ordem | Y precede D ou integra a própria definição de D |
| E3 | História pré-exposição disponível | ao menos uma medida de Y e Z genuinamente anterior, com índice e construção documentados | medidas anteriores parecem existir, mas o alinhamento é incerto | todas as medidas disponíveis são contemporâneas ou posteriores a D |
| E4 | Suporte e comparação documentados | desenho explica variação de exposição e comparação contemporânea relevante | modelo existe, mas a origem temporal da variação não está documentada | não há contraste de exposição ou grupos são definidos por outcome futuro |
| E5 | Painel e clusters reconstruíveis | unidade, tempo e nível de cluster/dependência são identificáveis | painel existe, mas clusters/dependência não estão documentados | desenho é transversal ou não comporta história temporal |
| E6 | Dados e documentação acessíveis | D, Y, Z, unidade, tempo, amostra e cluster mapeiam para dados/código locais ou repositório primário acessível | arquivos existem, mas o mapeamento essencial está incompleto | insumos necessários estão documentadamente ausentes ou inacessíveis |
| E7 | Contraste substantivo entre controle histórico e atual | timing e argumento substantivo tornam relevantes a história de Z e seu valor atual após D | versões atual/defasada são construíveis, mas timing ou papel não é documentado | Z é apenas invariável, pós-outcome ou alheio ao processo D–Y |

O PASS documental em E3 não fixa a ordem de lags; E5 não atesta número efetivo de clusters; E4 não prova identificação. Essas verificações pertencem aos Gates 2–3.

## Regra de classificação

- `ELIGIBLE_DOCUMENTARY`: E1–E7 passam. Somente esta classe admite seleção provisória como principal ou reserva.
- `HOLD_DOCUMENTATION`: nenhum critério falha por evidência afirmativa, mas falta documentação para ao menos um critério. Isso não prova inelegibilidade substantiva.
- `INELIGIBLE_DEMONSTRATED`: ao menos um critério falha por evidência primária afirmativa.
- `NOT_SCREENED`: estudo do acervo que não entrou nas até três leituras integrais.

## Escolha, congelamento e parada

Primeiro, as candidatas serão priorizadas por clareza do relógio exposição–outcome, história reconstruível, acesso local a dados/código, painel/cluster documentado e relevância substantiva do controle em papéis temporais distintos. Depois, no máximo três desenhos serão lidos integralmente. A principal e a reserva só poderão vir da classe `ELIGIBLE_DOCUMENTARY`, e permanecerão provisórias até a matriz conjunta do Gate 3. Resultado posterior pequeno, nulo ou desfavorável não autoriza troca.

A triagem para após três fichas, ou antes se duas candidatas elegíveis permitirem principal e reserva. Se nenhuma passar, a saída será uma busca adicional delimitada ou uma rota descritiva submetida ao autor. Alterar subscritos sem documentação temporal não satisfaz o protocolo.

## Limite da conclusão

Elegibilidade documental não estabelece identificação causal, compatibilidade do estimador, períodos prévios suficientes, clusters efetivos adequados, suporte estatístico ou novidade metodológica. Ela apenas decide se existe uma rota verificável para testar essas condições nos gates seguintes.
