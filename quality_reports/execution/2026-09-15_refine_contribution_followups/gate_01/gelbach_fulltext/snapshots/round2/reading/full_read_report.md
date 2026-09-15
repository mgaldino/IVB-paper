# Leitura integral de Gelbach (2016) e confronto delimitado do Gate 1

**Fonte:** Jonah B. Gelbach, “When Do Covariates Matter? And Which Ones, and How Much?”, *Journal of Labor Economics* 34(2), 2016, pp. 509–543, DOI `10.1086/683668`.  
**PDF lido:** `sources/gelbach_2016_683668.pdf`  
**SHA-256 do PDF:** `77392b7b09815f291f0ca55aa965786c59c4ca46a9ac1da44df0395dff96de2f`  
**Cobertura:** 35/35 páginas de PDF, incluindo notas, tabelas, apêndices A–D e referências.  
**Escopo:** leitura e confronto bibliográfico. Nenhuma análise, simulação, estimação, Stata, R, bootstrap ou edição do manuscrito foi executada.

## 1. Resultado principal

A leitura integral **fortalece o diagnóstico de sobreposição do núcleo matemático e inferencial**. Gelbach não oferece apenas uma identidade amostral. O artigo distingue a identidade finita, um alvo populacional de projeção, uma interpretação substantiva condicionada à adequação do modelo completo e uma teoria assintótica conjunta para os componentes. Ele também trata blocos de covariáveis correlacionadas, cancelamento entre componentes, OLS e IV, um resultado de Hausman e o caso degenerado em que os dois fatores relevantes do produto zeram.

Consequentemente, continuam válidas as conclusões anteriores de que a identidade vetorial, a alocação condicional por blocos e a incorporação da covariância não constituem, sozinhas, uma contribuição distinta. O comparador forte `C+` **não foi ampliado depois dos resultados**: a ficha v2 já lhe fornecia momentos e alvo projetivo, hipóteses causais comuns, modelos intermediários OLS, covariância conjunta e o limite de degenerescência na origem; a derivação anterior já registrava a versão populacional. A leitura integral fortalece a **atribuição bibliográfica** dessas capacidades congeladas a Gelbach, com localizadores para o alvo populacional, o Apêndice B, a nota de não regularidade e os exemplos de cancelamento. IV e Hausman delimitam apenas uma comparação futura se o escopo for ampliado; eles não integram o teste OLS sem pesos já realizado.

O texto integral também corrige duas possíveis caricaturas. Primeiro, Gelbach não é indiferente à especificação causal: ele condiciona a interpretação substantiva à correção do modelo completo e discute endogeneidade, mensuração e instrumentos. Segundo, ele reconhece que o timing pode fornecer uma ordem causal natural. O artigo, porém, não desenvolve neste texto um procedimento para escolher história pré-exposição em painéis, classificar covariáveis por DAG ou reconciliar um alvo causal contemporâneo com efeitos fixos e dinâmica. Isso preserva uma possível rota operacional para o IVB-paper, mas a rota fica mais estreita: ela precisa demonstrar uma capacidade ou decisão adicional frente a `C+` com a mesma informação, e não apenas acrescentar linguagem causal a uma decomposição conhecida.

A conclusão anterior de equivalência da rotina congelada `P` e de `C+` no domínio OLS declarado permanece. O exemplo de substituição `B,C,U` não aparece como tal em Gelbach; ele é uma construção derivada pela equipe ao aplicar duas vezes a decomposição aninhada. Essa origem deve ser preservada. A construção mostra que `C+` reproduz o núcleo proposto, mas não deve ser atribuída a Gelbach como resultado que ele enunciou.

Este relatório não aprova o Gate 1. Ele entrega evidência para revisão independente e adjudicação posterior.

## 2. Síntese fiel do artigo antes do confronto

### 2.1 Pergunta e contribuição declarada

Gelbach parte de uma prática comum: estimar uma especificação básica e adicionar covariáveis em sequência, atribuindo a cada conjunto recém-adicionado a mudança observada no coeficiente de interesse. Quando as covariáveis adicionadas são correlacionadas, essa atribuição depende da ordem. O artigo propõe uma decomposição condicional, invariável à sequência, baseada na fórmula de viés por variável omitida. O objetivo é responder quanto cada covariável ou bloco contribui para a diferença entre o coeficiente da especificação básica e o da completa, sempre usando os coeficientes estimados conjuntamente no modelo completo (pp. 509–511, 518–523).

O exemplo substantivo é a diferença salarial entre homens negros e brancos no NLSY79. Adicionar educação antes de AFQT e adicionar AFQT antes de educação produz atribuições muito diferentes. A inversão decorre de que a diferença racial em educação muda de sinal quando se condiciona em AFQT (pp. 514–517; Apêndice D, pp. 538–540).

### 2.2 Identidade amostral finita

Se `X1` contém as regressoras presentes nos modelos básico e completo, e `X2` contém as covariáveis acrescentadas apenas ao modelo completo, Gelbach define a diferença na convenção

\[
\widehat\delta=\widehat\beta^{base}_1-\widehat\beta^{full}_1.
\]

Para OLS na mesma amostra e com posto suficiente,

\[
\widehat\delta=(X_1'X_1)^{-1}X_1'X_2\widehat\beta_2
=\widehat\Gamma\widehat\beta_2.
\]

Esta é uma identidade exata de amostra, demonstrada pelas equações normais e pela ortogonalidade do resíduo OLS (eq. 11, pp. 521–522). Para a convenção do IVB-paper, `long - short`, o mesmo objeto aparece com sinal negativo.

Para cada covariável `k`, o componente é

\[
\widehat\delta_k=\widehat\Gamma_k\widehat\beta_{2k},
\qquad
\widehat\delta=\sum_k\widehat\delta_k.
\]

Os coeficientes de `X2` vêm do mesmo modelo completo. Por isso, correlação entre as colunas de `X2` não invalida a decomposição. Partições mutuamente exclusivas de covariáveis podem ser somadas em blocos `g`, mantendo a soma exata ao endpoint (eq. 12, pp. 522–523).

### 2.3 Alvo populacional

O artigo começa por `Y=X1 beta1+X2 beta2+epsilon` e observa que, sem impor média condicional zero, `beta` pode ser definido como o coeficiente da projeção linear populacional, desde que os momentos relevantes existam e a matriz de segundos momentos seja não singular. A projeção populacional de `X2` em `X1` define `Gamma`, e

\[
\beta^{base}_1-\beta_1=\Gamma\beta_2=\delta.
\]

Portanto, o componente populacional `delta_g=Gamma_g beta_{2g}` é um componente da diferença entre duas projeções populacionais. A identidade finita estima esse objeto por plug-in sob a amostragem e as condições regulares pertinentes (eqs. 1–4, pp. 518–519).

Esse alvo populacional não é automaticamente causal. Gelbach escreve que `E[epsilon_i | X_i]=0` permite interpretar `beta` como efeito parcial da média condicional e diz que assumirá essa condição em geral, embora os resultados algébricos não dependam dela (p. 518). Em nota anterior, ele formula uma condição substantiva mais ampla: a decomposição só é geralmente significativa se a função de regressão completa puder ser escrita corretamente como linear em `X1` e `X2`, sem endogeneidade, erro de mensuração ou outro problema não resolvido; instrumentos válidos podem, em princípio, tratar problemas que também sejam resolvidos no modelo de regressão (nota 3, p. 511).

Assim, há quatro objetos distintos:

1. a igualdade amostral exata;
2. o componente de uma diferença entre projeções populacionais;
3. a distribuição assintótica do estimador desse componente;
4. a interpretação causal, que exige hipóteses adicionais sobre o modelo e o desenho.

O artigo não autoriza colapsar esses quatro níveis.

### 2.4 Alocação por covariável e por bloco

Gelbach oferece duas implementações equivalentes. Uma estima uma auxiliar para cada covariável `X2k` e multiplica o coeficiente de `X1` por `beta2k`. A outra constrói, para cada observação, o termo de heterogeneidade do bloco,

\[
\widehat H_i^g=\sum_{k\in g}X_{2k,i}\widehat\beta_{2k},
\]

e regressa `Hhat_g` em `X1`. O coeficiente resultante é exatamente `deltahat_g`. A segunda forma reduz o número de auxiliares quando há muitas dummies e dá uma interpretação direta: o bloco contribui para a diferença quando a heterogeneidade de outcome associada ao bloco difere sistematicamente ao longo de `X1` (pp. 523–524).

Essa é uma alocação condicional a uma partição escolhida pelo pesquisador e ao modelo completo. O artigo não afirma que os blocos se escolham sozinhos, nem resolve pelo valor de `delta_g` quais covariáveis pertencem causalmente ao modelo completo.

### 2.5 Covariância e inferência

O Apêndice B deriva a covariância assintótica conjunta dos componentes. A expansão de primeira ordem de cada `deltahat_g=Gammahat_g betahat_2g` inclui a incerteza de `betahat_2g`, a incerteza de `Gammahat_g` e dois termos cruzados. A equação (B2) apresenta os quatro blocos; as equações (B3)–(B6) organizam sua estimação por um sistema empilhado (pp. 531–534).

O artigo alerta que estimar apenas a equação auxiliar e aplicar a ela um erro-padrão comum omite a estimação de `beta_2`: em geral, isso retém apenas um dos termos de (B2). Sob heterocedasticidade condicional ou agrupamento, Gelbach recomenda os estimadores robustos usuais para as matrizes pertinentes (pp. 534–535). Sob esfericidade condicional, os termos cruzados relevantes simplificam e a covariância entre certos estimadores zera.

A inferência é assintótica e pontual. O artigo não demonstra cobertura de block bootstrap em painel curto, não deriva a sequência `N -> infinito` com `T` fixo e não prova validade uniforme perto de uma singularidade.

### 2.6 A origem não regular

A nota 14, p. 524, é decisiva para o IVB-paper. Para o bloco `g`, a abordagem auxiliar regular exige que pelo menos um elemento de `Gamma_g` ou de `beta_2g` seja não zero. Se os dois vetores forem inteiramente zero, a variância de

\[
\sqrt n(\widehat\delta_g-\delta_g)
\]

converge a zero e estatísticas de teste têm comportamento não padrão. Quando `Gamma_g=0` é admitido, Gelbach recomenda verificar previamente que nem todos os elementos de `beta_2g` são zero por um teste conjunto no modelo completo.

Essa passagem mostra que o artigo reconhece a degenerescência na origem do produto. Ela não entrega uma solução uniforme para sequências locais em que os dois fatores se aproximam de zero. Também não diz que todo cancelamento é não regular: `Gamma_g beta_2g=0` pode ocorrer por ortogonalidade entre vetores não nulos, caso em que a derivada de primeira ordem não precisa zerar. É preciso separar:

- **origem:** ambos os vetores relevantes zeram, com linearização degenerada;
- **cancelamento dentro de bloco:** produto interno zero com fatores não nulos;
- **cancelamento entre blocos:** componentes não nulos e de sinais opostos somam perto de zero.

Reconhecer a origem não regular já não pode ser apresentado como novo. Uma contribuição inferencial futura teria de fornecer e demonstrar uma garantia além do aviso e da triagem sugerida por Gelbach.

### 2.7 Cancelamento e sequência

O artigo documenta três formas próximas de cancelamento.

1. Na aplicação salarial, componentes sequenciais mudam de magnitude e até de sinal conforme a ordem de educação e AFQT; os vieses dos componentes sequenciais somam exatamente a zero porque o endpoint é o mesmo (pp. 516–517; 538–540).
2. Para indústria, `Gamma_industry` e `beta_2,industry` são ambos diferentes de zero, mas o produto é aproximadamente zero porque as duas direções são quase ortogonais (p. 526).
3. Na aplicação IV resumida, controlar conjuntamente por covariáveis quase não muda o efeito estimado, embora blocos individuais produzam deslocamentos aproximadamente iguais e de sinais opostos (pp. 526–527).

Portanto, “mudança total pequena mascara movimentos grandes e opostos” já está no domínio substantivo de Gelbach. O artigo não formula a troca temporal não aninhada `B -> U -> C`; esse caminho continua sendo uma aplicação derivada, e não uma descoberta textual no artigo.

Gelbach recomenda abandonar a adição sequencial na maioria dos exercícios e estimar o modelo completo de uma vez. Ao mesmo tempo, reconhece que há casos especiais em que o timing fornece uma ordem causal natural, citando Altonji, Bharadwaj e Lange como contraexemplo ao seu domínio principal (nota 3, p. 511). O artigo assume que o pesquisador já decidiu qual é a especificação completa apropriada; ele não fornece uma regra geral para selecionar a história ou decidir se uma covariável responsiva ao tratamento deve entrar.

### 2.8 OLS e IV

O núcleo é desenvolvido para OLS. Na extensão IV, Gelbach afirma:

- com identificação exata de `beta_1`, a equivalência entre a fórmula amostral e a diferença base–full vale em amostras finitas quando todos os coeficientes são estimados por 2SLS;
- com sobreidentificação, a equivalência não vale exatamente em amostras finitas, mas vale assintoticamente se todos os instrumentos forem válidos;
- o conjunto de instrumentos é mantido fixo entre especificações no argumento do artigo (p. 526 e nota 16).

O artigo remete a Gelbach (2009) para detalhes. A leitura atual sustenta a existência e o escopo declarados da extensão, mas não reconstrói a prova remetida ao working paper de 2009.

### 2.9 Oaxaca–Blinder e Hausman

Gelbach mostra que sua decomposição contém a decomposição Oaxaca–Blinder. O Apêndice C deriva a correspondência entre os componentes de preços e quantidades e grupos específicos de `X2`, além do coeficiente de grupo no modelo completo (pp. 527–528; 535–538). A não unicidade de Oaxaca–Blinder permanece ligada à escolha do grupo de referência e do ponto de avaliação.

Para Hausman, o artigo afirma que, sob a hipótese nula de ortogonalidade entre `X1` e todas as covariáveis de `X2`, o resultado de variância da diferença se aplica. Para um único coeficiente, estimativas e erros-padrão das duas especificações bastam para um teste assintoticamente normal padrão (pp. 528–530). Essa é uma hipótese nula específica e mais forte que “a soma dos componentes é zero”: cancelamento pode gerar diferença total zero sem ortogonalidade de `X1` e `X2`. Os detalhes são novamente remetidos a Gelbach (2009).

### 2.10 Aplicação e hipóteses empíricas

A amostra contém 1.749 homens do NLSY79, sem pesos; todas as especificações comparadas usam as mesmas observações. O artigo trata educação e AFQT como pertencentes ao modelo completo para fins da demonstração, seguindo Lang e Manove, e reconhece que essa escolha é substantiva (nota 8, p. 516). Na versão expandida, o modelo completo inclui 26 covariáveis, agrupadas em educação, AFQT, ocupação e indústria. Os erros-padrão reportados assumem esfericidade condicional; erros robustos foram, segundo o autor, muito semelhantes (pp. 524–525; Apêndice A, pp. 530–531).

Os resultados empíricos ilustram a decomposição, mas não validam qualquer regra geral para covariáveis pós-tratamento ou para painéis dinâmicos.

## 3. O que muda depois da leitura integral

### 3.1 Dependência documental encerrada

A pendência `L17` de obter e ler o artigo integral foi encerrada para esta fonte: 35/35 páginas foram lidas e as páginas matemáticas foram conferidas visualmente. Isso permite substituir inferências baseadas apenas na ajuda e no código por atribuições ao artigo, com páginas e equações.

Encerrar a pendência documental não libera uma alegação de novidade. O conteúdo integral amplia a evidência publicada para a sobreposição conhecida e explicita limites que já eram contemplados na ficha e na derivação congeladas. O comparador efetivamente testado não mudou.

### 3.2 Atribuição bibliográfica do alvo populacional agora confirmada

A derivação anterior já registrava uma versão populacional sob momentos de segunda ordem finitos e matriz não singular, e a ficha v2 já fornecia os momentos e o alvo projetivo comuns. A leitura integral permite agora atribuir diretamente a Gelbach o alvo populacional `delta=Gamma beta_2`. A descrição do `C+` congelado separa, como já exigiam esses artefatos:

- o endpoint e os componentes exatos na amostra;
- os componentes de projeção populacional estimados;
- a incerteza assintótica desses componentes;
- qualquer interpretação causal adicional e suas hipóteses.

A fonte publicada reduz o espaço para afirmar que o IVB-paper torna a decomposição “estimável” ou dá a ela, pela primeira vez, um parâmetro populacional. Essa mudança é de sustentação bibliográfica, não de capacidade do comparador após o teste.

### 3.3 Pressuposto do modelo completo e temporalidade

A leitura integral mostra que Gelbach não escolhe a especificação completa por meio da decomposição. Ele assume que o pesquisador a considera apropriada, reconhece o debate sobre educação e AFQT e limita a interpretação substantiva a um modelo completo adequado. Ele também reconhece que o timing pode produzir uma ordem causal natural.

A rota temporal do IVB-paper deve então ser descrita como desenvolvimento de uma regra, protocolo ou evidência para decisões que Gelbach toma como dadas. Não é correto dizer que Gelbach prova que timing é irrelevante ou que seu artigo oferece uma classificação causal dinâmica completa. Também não é correto dizer que ele desconhece o problema de ordenação causal.

### 3.4 A origem não regular já é reconhecida

A derivação anterior identificou corretamente a degenerescência em `theta=pi=0`. A novidade possível ficou mais estreita: o artigo de 2016 reconhece o caso, explica por que o teste comum é não padrão e sugere uma verificação conjunta de `beta_2` quando `Gamma=0` é possível. Uma proposta futura precisa comparar-se a esse tratamento e demonstrar, por exemplo, validade uniforme, cobertura finita ou uma região de confiança com garantia própria. Apenas apontar a origem não regular não distingue o IVB-paper.

### 3.5 Cancelamento é ainda menos promissor como novidade

O artigo já mostra cancelamento dentro de um bloco por ortogonalidade e entre blocos por efeitos opostos, inclusive no contexto IV. O exemplo congelado `E1` ainda é útil para visualizar uma substituição temporal não aninhada, mas seu ganho é de organização até que se mostre uma decisão que `C+` não reproduz.

### 3.6 IV e Hausman delimitam eventual escopo futuro

O teste congelado de `C+` e `P` permanece em OLS sem pesos. Se uma alegação futura cobrir IV, a comparação então ampliada deverá respeitar identificação exata versus sobreidentificação e conjunto de instrumentos fixo. Se uma alegação futura tratar testes de mudança entre especificações, deverá reconhecer o resultado de Hausman sob ortogonalidade, sem convertê-lo em solução geral para inferência sobre qualquer componente ou cancelamento. Nenhuma dessas referências altera retrospectivamente o teste realizado.

## 4. O que se mantém

1. **Identidade e vetor:** `L01` e `L02` permanecem equivalentes no núcleo; o artigo publicado fornece a evidência direta.
2. **Alocação condicional:** `L03` permanece conhecida. LOO e Shapley respondem a outras perguntas; o artigo integral não foi usado para atribuir a Gelbach resultados que ele não enuncia sobre esses métodos.
3. **Amostra comum:** `L04` permanece requisito da identidade. A ajuda oficial continua sendo a evidência explícita de implementação; o artigo usa a mesma amostra no desenvolvimento e na aplicação.
4. **Covariância:** `L05` permanece largamente equivalente, agora com suporte direto do Apêndice B. Bootstrap em painel não foi demonstrado no artigo, mas sua mera escolha não estabelece novidade.
5. **Aviso de software:** `L06` não muda. O aviso específico sobre a linha agregada pertence ao código/ajuda, não ao artigo; não deve ser generalizado.
6. **Escopo computacional:** `L07` continua mais amplo em `b1x2`; a distinção teórica entre IV exatamente identificado e sobreidentificado é referência para eventual escopo futuro, fora do teste OLS sem pesos.
7. **Classificação causal e timing:** `L08`–`L14` permanecem dependentes da literatura causal e de painel. Gelbach acrescenta uma distinção projeção/causal e reconhece timing, mas não fornece neste artigo o protocolo TSCS proposto.
8. **Substituição:** `L15` permanece uma equivalência derivada de duas decomposições aninhadas. Não é um teorema textual de Gelbach e não é uma capacidade exclusiva de `P`.
9. **Valor incremental:** `L16` permanece um candidato operacional não demonstrado. Como Gelbach já apresenta auxiliares simples, grupos e software, a alegação operacional futura precisa ser específica ao relógio causal, à história e às decisões em painel.
10. **Fronteira de novidade:** `L17` muda de “pendente por falta de texto integral” para “texto integral lido; atribuição do núcleo conhecido confirmada e documentação da sobreposição ampliada”. O `C+` congelado permanece o mesmo, e a leitura não libera novidade matemática ou inferencial.

O mapeamento linha a linha está em `claim_comparison.csv`.

## 5. Descrição bibliograficamente atualizada do `C+` congelado

A ficha v2 já definia as operações e informações de `C+`. A leitura integral permite descrevê-las com cinco camadas e atribuí-las com maior precisão; esta organização não adiciona operações ao comparador testado.

### Camada 1: domínio e especificação

No teste congelado, fixar a mesma amostra, transformações, OLS sem pesos, regressoras comuns e partição de blocos, e verificar posto. A especificação completa deve ser defendida antes de interpretar a decomposição. Pesos e matriz de instrumentos pertencem apenas a uma eventual ampliação futura do escopo.

### Camada 2: álgebra amostral

Calcular endpoints e componentes pela identidade exata. Para a substituição `B=(D,W,L)`, `C=(D,W,Z)` e `U=(D,W,L,Z)`, aplicar Gelbach/FWL separadamente a `B -> U` e `C -> U`; a identidade que liga `B` a `C` é derivada pela subtração das duas inclusões.

### Camada 3: alvo populacional

Nomear os componentes `Gamma_g beta_2g` como partes de uma diferença entre projeções populacionais. Não chamá-los automaticamente de viés causal. Se o estimador dinâmico com transformação within e `T` fixo tiver outro limite, esse limite precisa ser derivado à parte.

### Camada 4: inferência

Usar a covariância conjunta dos fatores/componentes e a dependência pertinente. Separar o regime regular, a origem degenerada e os dois tipos de cancelamento. A equivalência de uma transformação de covariância não prova cobertura.

### Camada 5: interpretação causal

Aplicar o mesmo estimando, DAG, relógio e histórico fornecidos a `P`. Quando esses insumos não selecionarem uma classe causal, preservar a saída descritiva. Gelbach não cria a informação causal, mas sua decomposição é compatível com recebê-la externamente.

Essas camadas apenas organizam a descrição da ficha já congelada. O resultado permanece: `P` e `C+` produzem os mesmos coeficientes, componentes e decisões causais quando recebem as mesmas entradas e regras. Uma diferença futura precisa vir de uma operação, garantia ou evidência adicional identificada antes do teste.

## 6. Capacidades ou testes que a leitura torna pertinentes, sem implementação

### 6.1 Inferência válida perto da origem

Pergunta candidata: construir um procedimento com garantia declarada quando `Gamma_g` e `beta_2g` podem ser simultaneamente zero ou localmente pequenos. O teste deve comparar cobertura e tamanho com a aproximação delta regular e com a triagem sugerida por Gelbach. É necessário definir sequência local, alvo, classe de dependência e critério de validade. O artigo lido identifica o problema; não oferece uma solução uniforme.

### 6.2 Alvo within em painel curto

Pergunta candidata: demonstrar a relação entre a projeção populacional de referência e o limite de um estimador com efeitos fixos quando `N` cresce e `T` permanece fixo. A identidade amostral após a mesma transformação continua algébrica, mas não decide qual alvo o estimador recupera. Esse desenvolvimento precisa separar viés dinâmico, alvo causal e deslocamento entre especificações.

### 6.3 Regra executável de história e recusa

Pergunta candidata: definir uma regra verificável que, dados relógio, DAG e histórico, escolha uma comparação admissível ou devolva “somente descritivo/mudar desenho”. Para distinguir `P`, a regra deve gerar uma ação ou garantia que `C+`, recebendo as mesmas informações, não reproduza. Se for apenas uma interface que organiza decisões conhecidas, o ganho deve ser avaliado como operacional.

### 6.4 Evidência de valor operacional

Se a alegação for que o protocolo reduz erros de interpretação ou melhora a escolha de especificação, a evidência deve medir esse resultado em usuários ou tarefas pré-especificadas. A experiência dos agentes e a quantidade de campos do relatório não medem esse ganho.

Nenhuma dessas propostas foi implementada ou testada nesta leitura.

## 7. Dúvidas e limites deliberados

- A extensão IV e o resultado de Hausman são enunciados no artigo, mas as provas detalhadas são remetidas a Gelbach (2009), que não foi lido nesta tarefa. Este relatório não amplia os enunciados além do texto de 2016.
- A afirmação de Gelbach de que média condicional zero dá interpretação causal de efeito parcial é registrada como formulação do autor. Ela não substitui as hipóteses modernas necessárias para interpretar uma exposição manipulável, mediação, interferência ou dinâmica.
- O Apêndice B permite matrizes robustas e agrupadas usuais. Isso não demonstra, sem análise adicional, validade para qualquer padrão de dependência TSCS, para poucos clusters ou para block bootstrap.
- O artigo reconhece que timing pode criar uma ordem natural e assume um modelo completo apropriado. Não foi inferida uma afirmação universal sobre tudo o que Gelbach discutiu em outros trabalhos, no software ou em versões anteriores.
- A decomposição por blocos depende da partição escolhida. O artigo prova aditividade condicional para essa partição; não seleciona os blocos por um critério causal.
- Cancelamento total não é sinônimo de origem não regular. Essa distinção deve permanecer explícita em futuras derivações e testes.
- Não foi reavaliada a literatura externa já lida no relatório anterior. O confronto aqui é delimitado ao que a leitura integral de Gelbach muda ou preserva.

## 8. Intuição para retomar o paper

Gelbach entrega três coisas em camadas. Primeiro, uma conta exata: a mudança entre um modelo curto e um longo pode ser dividida em produtos entre a associação de cada bloco com a regressora focal e o coeficiente desse bloco no modelo longo. Segundo, ele dá a essa conta um alvo populacional e erros-padrão conjuntos. Terceiro, ele permite uma leitura econômica se o pesquisador já tiver acertado qual modelo completo é substantivamente válido. O IVB-paper tenta atuar exatamente no ponto que Gelbach toma como entrada: decidir o que pertence à história, o que é resposta ao tratamento e qual efeito se quer estimar. Esse ponto pode ser útil, mas precisa produzir uma decisão, garantia ou evidência adicional. Reembalar a primeira e a segunda camadas não basta.

## 9. Comandos e verificações executados

### Leitura de instruções e entradas

- `sed -n` em `CLAUDE.md`, no plano autorizado, nas duas skills aplicáveis e nos quatro artefatos anteriores delimitados pelo contrato.
- `find` e `rg` para localizar instruções, arquivos, contrato comum, `C+` e alegações `L01`–`L17`.
- passagem rápida pela memória de projeto com `rg` em `MEMORY.md`; foram usados apenas `MEMORY.md:3–4`, que registram o limite de não executar R/Lean, recompilar ou avançar fases e exigem rechecagem do checkout. O `rollout_id` associado, recuperado de `MEMORY.md:10`, é `01a0a28f-0518-70a0-9381-aa7f7e5c661e`. O contrato atual já impunha independentemente o limite de não executar análises.

### Integridade e cobertura da fonte

- `pdfinfo sources/gelbach_2016_683668.pdf`: 35 páginas, 626.909 bytes, sem criptografia.
- `shasum -a 256` do PDF, texto e `page_map.json`; o hash do PDF coincidiu com o contrato.
- `pdftotext -layout` para as faixas de páginas 1–7, 8–14, 15–21, 22–28 e 29–35.
- nova extração integral para `/tmp/gelbach_full_reader/reextract.txt` e `cmp -s` com o texto fornecido: retorno `0`, bytes idênticos.
- inspeção do `page_map.json`: 35 entradas, mapeando páginas de PDF 1–35 a páginas impressas 509–543.
- tentativa de resumo mecânico com `jq`: não executada porque `jq` não está instalado; a cobertura foi conferida diretamente no mapa e pelo PDF.

### Conferência visual

- `pdftoppm -png -r 150` renderizou as 35 páginas em `/tmp/gelbach_full_reader/`.
- `view_image` em 22 páginas com matemática ou enunciados inferenciais centrais: PDF 2, 10–16, 18–21 e 23–32, correspondentes às páginas impressas 510, 518–524, 526–529 e 531–540.
- `montage` não estava disponível; nenhuma folha de contato foi criada. As imagens individuais já renderizadas foram usadas na inspeção.

### Estado do repositório

- `git status --short --branch` confirmou a branch `main` e mostrou o diretório de follow-up como não rastreado. Nenhum arquivo fora de `gelbach_fulltext/reading/` foi alterado por este leitor.

## 10. O que não foi executado

- nenhum script R ou Stata;
- nenhuma simulação, estimação, aplicação empírica, bootstrap ou cálculo de shift do projeto;
- nenhum teste de cobertura ou inferência perto da origem;
- nenhuma leitura ou execução do working paper Gelbach (2009);
- nenhuma edição ou renderização de `ivb_paper_pa.Rmd`/PDF;
- nenhuma alteração dos entregáveis anteriores da Gate 1;
- nenhum commit, tag, push, publicação ou mensagem externa.

## 11. Estado desta entrega

**Leitura integral concluída; confronto produzido; decisão do Gate 1 reservada à revisão independente e à adjudicação.**
