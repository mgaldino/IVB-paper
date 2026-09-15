# Gelbach integral: leitura independente da fonte, Fase A

**Responsável:** agente `gelbach_full_review`. **Data:** 15/09/2026. **Estado:** síntese própria concluída antes da abertura do relatório do novo leitor. Este documento não adjudica o relatório e não aprova o Gate 1. A Fase B depende do recebimento de seus hashes congelados pelo coordenador.

## 1. Resultado e fronteira da leitura

A fonte primária confirma uma decomposição OLS exata, aditiva por covariadas e grupos, baseada em coeficientes do modelo completo; desenvolve a covariância conjunta dos componentes, inclusive os termos cruzados e a possibilidade de estimação robusta ou por clusters; e reconhece explicitamente a degenerescência do produto. Também contém cancelamento entre componentes. Esses resultados impedem tratar produto FWL, múltiplos controles, cancelamento ou consideração de covariância como novidades por si.

O comparador C+ da ficha pré-especificada já recebe essas capacidades e as mesmas informações causais. A fonte fortalece sua atribuição bibliográfica. A passagem da decomposição aninhada para a troca `B → U → C` é uma aplicação da identidade duas vezes. A covariância conjunta desses dois contrastes pode ser construída com as mesmas equações ou reamostras, mas não deve ser atribuída como uma fórmula literalmente apresentada por Gelbach para duas bases distintas. Essa precisão de atribuição não gera uma vantagem de P sobre o C+ autorizado.

**Cobertura efetivamente lida:** extração textual das páginas impressas **509–512 e 516–540**, correspondentes às páginas **1–4 e 8–32 do PDF: 29 de 35 páginas**. Foram lidas integralmente, na extração, as seções centrais IV–VI e o Apêndice B. Apêndices C/D foram lidos em texto para contexto; suas provas não receberam uma auditoria matemática integral. As páginas **513–515 e 541–543 não foram lidas** nesta Fase A. Portanto, esta é uma **leitura independente localizada do texto integral disponível**, não uma alegação de leitura integral das 35 páginas. Não certifica a replicação das tabelas empíricas.

**Conferência visual:** páginas impressas **518, 521, 522, 523, 524, 526, 528, 529, 532, 533, 534 e 535** (PDF **10, 13, 14, 15, 16, 18, 20, 21, 24, 25, 26 e 27**), renderizadas e abertas individualmente. Foram verificados sinais, chapéus, índices e transpostas das fórmulas-chave (1)–(4), (11)–(12), agregação de grupos, (B1)–(B6), além da nota 14 e dos enunciados IV/Hausman. A inspeção visual confirma que a extração frequentemente troca sinais de igualdade, mais, menos e letras gregas. A síntese abaixo usa notação normalizada, e não cópia mecânica da extração.

**Independência:** não foi aberto `reading/full_read_report.md` nem outro produto do novo leitor antes de finalizar este documento. Foram consultados somente a fonte, a ficha C+ e o plano para orientar a comparação; não se consultou o resultado da nova implementação. Nenhuma rota científica foi escolhida pelo autor nesta etapa: a mudança observada é o acesso ao artigo.

## 2. Fonte e entradas congeladas

Raiz relativa do pacote: `quality_reports/execution/2026-09-15_refine_contribution_followups/gate_01/gelbach_fulltext/`.

| Entrada | SHA-256 conferido |
|---|---|
| `sources/gelbach_2016_683668.pdf` | `77392b7b09815f291f0ca55aa965786c59c4ca46a9ac1da44df0395dff96de2f` |
| `sources/gelbach_2016_683668.txt` | `19c73f00577d19e289c6649ecc5668886d51dd74b08235a081d88d72e833e442` |
| `sources/page_map.json` | `25348b1c91a61f2bb9d6396631c545854f1af2c4ca7fa362b62655e880999972` |
| `quality_reports/plans/2026-09-15_refine_contribution/plan.md` | `d2d2ea2e39102ab4193ee2f82b12b0823143867a23750c38d626aa4797eb7f5d` |
| `quality_reports/execution/2026-09-15_refine_contribution/gate_01/contribution/test_prespec_v2.md` | `37562fccf615793d0b589b58303e0afeb225edd73ea85e44a7bb1b7688be7097` |

Referência: Jonah B. Gelbach (2016), *When Do Covariates Matter? And Which Ones, and How Much?*, Journal of Labor Economics 34(2), 509–543, DOI 10.1086/683668. Todos os localizadores a seguir usam a paginação impressa; para abrir no PDF, subtrair 508.

## 3. Núcleo OLS: identidade, objetos e sinais

### A01. O artigo distingue projeção e interpretação econômica

Em **p.518, seção IV, antes das eqs. (2)–(4)**, o autor define `Y = X1 β1 + X2 β2 + ε` e admite interpretação como projeção linear mesmo sem `E[ε|X]=0`, desde que existam os momentos relevantes e a matriz de momentos seja invertível. A identidade não depende de uma interpretação causal nem de um modelo longo causalmente admissível. A introdução ressalva a adequação do modelo completo em **p.511, nota 3**, e a aplicação toma a presença de escolaridade como escolha substantiva em **p.516, nota 8**.

### A02. Derivação independente da identidade amostral

Sejam `X=[X1 X2]` de posto completo, mesma amostra e mesmo outcome nas duas regressões. A decomposição dos valores observados pelo ajuste longo é

`Y = X1 β̂1,full + X2 β̂2 + ε̂`.

As equações normais implicam `X1' ε̂ = 0`. Pré-multiplicar por `(X1'X1)^(-1) X1'` dá, termo a termo,

`β̂1,base = β̂1,full + (X1'X1)^(-1)X1'X2 β̂2`.

Logo, escrevendo `Γ̂=(X1'X1)^(-1)X1'X2`,

`δ̂ = β̂1,base − β̂1,full = Γ̂ β̂2`.

Esta é a **eq. (11), pp.521–522**, com prova pelas equações normais no corpo e alternativa FWL na **nota 12, p.521**. É uma igualdade finita de OLS: não exige normalidade, homocedasticidade, independência ou hipóteses causais. Os inversos, a compatibilidade entre linhas e o aninhamento importam. Não transportar a igualdade para amostras diferentes só porque as variáveis têm o mesmo nome.

O IVB-paper/ficha define o deslocamento como longo menos curto. Portanto, para o coeficiente de D,

`Δ = −δ̂_D = −π̂' θ̂`.

A inversão do sinal não muda o conteúdo matemático. A parte populacional está nas **eqs. (2)–(4), p.518**; requer os limites de momentos/consistência correspondentes, além da identidade amostral.

### A03. Alocação condicional: qual condicionamento entra em cada fator

Para covariada `k`, **eq. (12), p.522** define `δ̂k = Γ̂k β̂2k`; somar os componentes recupera `δ̂`. Cada `β̂2k` vem do **modelo completo**, com todos os controles. Cada `Γ̂k` vem da regressão auxiliar de `X2k` apenas em **X1**, a base fixada. Não se incluem automaticamente todas as outras colunas de X2 em cada auxiliar. Confundir esses dois condicionamentos transforma a alocação em outro objeto.

Em **pp.522–523**, grupos são somas dessas contribuições. Defina `Ĥg = X2g β̂2g`. A regressão de `Ĥg` em X1 fornece exatamente `δ̂g`. Assim bastam G auxiliares para G grupos, em vez de uma auxiliar por coluna. Essa conveniência computacional está explicitada na **nota 13, p.523**.

A invariância é em relação à ordem de inclusão dos mesmos controles, **condicional à base, ao modelo completo e aos grupos fixados**. Não é uma afirmação de alocação única sob qualquer redefinição da base, transformação que misture grupos, escolha de modelo ou interpretação causal. A diferença entre uma alocação condicional e a contabilidade de passos sequenciais é examinada em **pp.538–540, Apêndice D, eqs. (D1)–(D3)**.

### A04. Cancelamento já aparece na fonte

**Tabela 6, p.525 e discussão p.526:** os vetores de relações de indústria com raça e com salário são não nulos, mas seu produto é aproximadamente zero. O artigo usa isso para mostrar que associações em ambos os fatores não são suficientes para o bloco mudar o coeficiente. **Seção V.A, p.526**, também descreve grupos com contribuições aproximadamente iguais e de sinais opostos em aplicação IV. Os números são evidência publicada, lida, não reproduzida aqui.

## 4. Inferência conjunta e regularidade

### A05. O objeto inferencial inclui todos os componentes conjuntamente

**P.524**, o autor considera a distribuição conjunta dos componentes por grupos e invoca o método delta; **Apêndice B, pp.531–535**, detalha a matriz. Não se limita a um erro-padrão de endpoint ou a grupos presumidos independentes.

A **eq. (B1), p.532**, decompõe a variação de `δ̂g=Γ̂g β̂2g` em variação de `β̂2g` e variação de `Γ̂g`. Uma escrita independente e normalizada, na primeira ordem, é:

`√n(δ̂g−δg) = Γg √n(β̂2g−β2g) + Q11^(-1) n^(-1/2) Σ_i x1i vgi + op(1)`,

onde `Q11=plim(X1'X1/n)` e `vgi = wgi' β2g`; `wgi` é o resíduo populacional da projeção de X2g em X1. A fonte escreve B1 com Γ̂g no primeiro termo, uma decomposição exata antes do limite. A troca por Γg acima utiliza consistência e é explicitamente assintótica.

O produto desta expressão pelo análogo transposto para h gera **quatro termos em (B2), p.532**:

1. covariância entre os coeficientes longos dos grupos g e h, multiplicada pelos Γ;
2. covariância das projeções auxiliares, incluindo a aleatoriedade das covariadas;
3. primeiro termo cruzado entre coeficiente longo e auxiliar;
4. segundo termo cruzado, na orientação transposta correspondente.

As **eqs. (B3)–(B6), p.533**, organizam o cálculo em sistema empilhado. **P.534** descreve os blocos cruzados e a estimação com resíduos estimados. **P.534, último parágrafo, continuado na p.535**, alerta que a variância convencional de uma auxiliar isolada, tratando o outcome estimado como dado, captura só o segundo termo e omite primeiro, terceiro e quarto. Não basta chamar a regressão auxiliar de robusta para corrigir essa omissão.

### A06. Heterocedasticidade e clusters não são lacunas do artigo

**P.534, penúltimo parágrafo**, admite estimadores robustos usuais sob heterocedasticidade condicional ou dependência por grupos para os blocos pertinentes. **P.535, primeiro parágrafo completo**, apresenta simplificações sob esfericidade condicional que anulam termos cruzados relevantes. Não generalizar essa simplificação ao caso robusto. A tabela empírica declara esfericidade condicional em **p.525, nota da Tabela 6**; o **Apêndice A, p.531**, informa ausência de pesos e proximidade dos erros robustos. Existência da formulação robusta e regime efetivamente usado na tabela são fatos distintos.

A fonte fornece uma construção assintótica, não certificação de cobertura para painéis curtos, poucos clusters ou seleção de modelo. Não derive tais garantias da palavra “cluster”. Esta leitura não auditou código Stata nem executou estimador.

### A07. Regularidade e degenerescência

O artigo utiliza existência de momentos, inversos de matrizes de momentos, consistência dos estimadores e normalidade assintótica conjunta; **p.518**, **p.524** e **pp.532–534**. Não apresenta, nessas páginas, um teorema autônomo com uma lista exaustiva de condições de amostragem para todo regime de painel/cluster. Para uso concreto, seriam necessárias condições de LLN/CLT e estimação consistente da covariância adequadas à dependência observada. Esta última frase explicita o que o argumento exige; não atribui ao artigo um teorema adicional.

**Nota 14, p.524**, exige que ao menos um elemento de Γg ou β2g seja não nulo para evitar o caso em que a variância na escala √n colapsa e os testes ficam não padronizados. O autor sugere testar o bloco β2g no modelo completo quando Γg=0 for possível. Deve-se registrar essa sugestão como tal; ela não demonstra cobertura uniforme nem valida um procedimento selecionado por pré-teste.

Intuição: no caso escalar, o gradiente do produto πθ é `(θ,π)`. Quando ambos são zero, a primeira ordem desaparece. Reescrever o mesmo produto como diferença de coeficientes não cria automaticamente uma distribuição regular. Nem todo deslocamento zero é degenerado: produtos internos podem cancelar com fatores não nulos, como no exemplo de indústria. A contribuição de um bloco pode ser zero sem que seu gradiente seja zero.

## 5. Limites causais e extensões

### A08. A fonte não escolhe o controle causalmente admissível

Há duas camadas a conservar. Primeiro, **p.518** afirma explicitamente que os resultados não exigem `E[ε|X]=0` e admite o alvo de projeção. Segundo, o autor associa a condição de média condicional zero a uma interpretação de efeito parcial causal. Na redação do IVB-paper, essa associação não deve ser transportada como prova de identificação causal a partir de uma propriedade puramente estatística da regressão: uma regressão gaussiana observacional também pode ter média residual condicional zero sob estruturas causais distintas. A admissibilidade para um efeito total ou direto depende do modelo causal, do timing e das demais hipóteses.

Isso é uma delimitação crítica da incorporação, não a acusação de que Gelbach promete descobrir o DAG. **P.511, nota 3; p.516, nota 8; p.524, nota 15**, condicionam a interpretação substantiva à adequação do modelo completo. **P.511, nota 3 e p.530**, ainda reconhecem situações em que o timing pode sugerir uma ordem natural. Seria incorreto resumir o artigo como se negasse a relevância de qualquer ordenação temporal.

No C+ da ficha, a seleção causal depende de informações comuns aos comparadores. O exemplo E2 de DAGs compatíveis pode ilustrar esse limite; não converte o deslocamento em critério para escolher um deles.

### A09. IV: distinção explícita entre identidade exata e equivalência assintótica

**Seção V.A, p.526 e continuação p.527; nota 16, p.526; conclusão p.530:** o texto afirma equivalência exata no caso exatamente identificado quando os coeficientes são estimados por 2SLS; no caso sobreidentificado, afirma equivalência assintótica, sob instrumentos válidos, e nega equivalência geral em amostras fixas. Discute adição de covariadas exógenas e mantém o conjunto de instrumentos fixo para o argumento. Remete a Gelbach (2009) para detalhes.

A leitura verificou o enunciado publicado, não uma prova integral dessa extensão: essa prova não está exposta na seção lida e o texto de 2009 não foi aberto. Não generalizar para mudança de instrumentos, controles endógenos ou identidade finita sobreidentificada. Não é autorização para desenvolver IV neste projeto.

### A10. Hausman: nula específica, não receita universal para diferenças

**Seção V.C, pp.528–529**, afirma resultado de variância de diferenças sob a nula de ortogonalidade entre X1 e X2, permitindo, para um coeficiente, um teste com coeficientes e erros-padrão publicados. **P.530** resume essa nula como suficiente para ausência de mudança. Detalhes são remetidos a Gelbach (2009).

A nula de ortogonalidade não equivale à nula geral `Γβ2=0`: o produto pode se anular por β2 zero ou compensação entre termos. Portanto, não usar a passagem como permissão genérica para combinar apenas erros-padrão de endpoints em qualquer contraste. O artigo disponível sustenta o enunciado delimitado; esta Fase A não certifica hipóteses completas/prova do resultado remetido a 2009.

## 6. Ponte precisa com C+ e efeito esperado sobre o gate

A ficha define `B: Y~D+W+L`, `C: Y~D+W+Z`, `U: Y~D+W+L+Z`.

| Objeto da ficha | Aplicação da identidade | Limite de atribuição |
|---|---|---|
| `d_add = βU−βB` | Gelbach com `X1=[D,W,L]`, `X2=Z`; `−θZ,U πZ|W,L` | Consequência direta de (11) para esse par aninhado |
| `d_lag = βU−βC` | Gelbach com `X1=[D,W,Z]`, `X2=L`; `−θL,U πL|W,Z` | Segunda aplicação, com base diferente |
| Retirada no caminho U→C | `−d_lag` | Inversão do sentido do contraste |
| `d_total = βC−βB` | `d_add−d_lag` por soma e subtração de βU | Ponte algébrica própria para a troca; não novo teorema |
| Covariância da troca | Se `d=(d_add,d_lag)'`, então `Var(d_total)=[1,−1]Var(d)[1,−1]'` | Transformação linear própria; a matriz precisa incluir dependência entre as duas comparações |

Uma decomposição única com `X1=[D,W]` e grupos `L,Z` teria auxiliares em `[D,W]` e, em geral, componentes diferentes desses passos. A equivalência C+/P não depende de confundir esses objetos: C+ já pode executar as duas regressões auxiliares com suas bases corretas e obter sua covariância conjunta. Para incerteza, Gelbach oferece precedente e construção geral de componentes conjuntos; a incorporação deve separar o que está literalmente no Apêndice B do uso dessa lógica para bases distintas. A ficha §3.7 permite explicitamente equações empilhadas ou reamostras pareadas. Não se executou bootstrap ou teste de cobertura neste trabalho.

**Consequência esperada da incorporação:** substituir ressalvas de acesso pendente por evidência primária localizada para OLS, grupos, covariância, robust/cluster, degenerescência e cancelamento; melhorar a precisão bibliográfica das extensões IV/Hausman; preservar a distinção entre projeção, identificação e garantia inferencial. **Não decorre do acesso:** uma operação adicional de P, ganho frente ao C+, aplicação documentalmente viável, escolha de nova rota pelo autor ou PASS global. O plano exige uma capacidade ou ganho que o comparador forte não reproduza, além de aplicação viável; uma revisão bibliográfica concluída sozinha não satisfaz esses critérios.

Esta é uma previsão independente, condicionada ao confronto dos artefatos congelados na Fase B. Não foi revisada a decisão anterior para registrar um novo status, nem foi conferido o resultado dos testes antigos nesta fase. A ficha é usada para definir a comparação, não como prova empírica de equivalência já executada.

## 7. Verificações, não execuções e próxima etapa

Executado: hash do PDF e entradas; leitura de texto por páginas usando separação form-feed; consulta ao mapa de páginas; renderização local por `pdftoppm` e abertura de 12 páginas; derivação algébrica independente escrita acima; inspeção da ficha C+ e critério do plano. Imagens temporárias: `/tmp/ivb_gelbach_independent/`. Somente este relatório e seu registro de freeze foram escritos no diretório autorizado `review/`.

Não executado: R, Stata, análise empírica, simulação, bootstrap, auditoria de código, consulta de Gelbach (2009), nova coleta, edição de manuscrito, modificação do pacote antigo congelado ou mudança de decisão científica.

A Fase B deve receber hashes congelados do relatório do novo leitor e confrontar fidelidade dos claims, precisão dos localizadores, cobertura declarada, signos e condicionamentos, limites inferenciais/causais e efeito pretendido sobre a decisão. Os achados permanecerão candidatos até adjudicação pelo coordenador, com classes `CONFIRMED`, `PARTIAL`, `REFUTED` ou `UNRESOLVED`. Esta Fase A não autoriza reparos.
