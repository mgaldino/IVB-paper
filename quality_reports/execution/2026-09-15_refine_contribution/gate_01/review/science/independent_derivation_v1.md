# Gate 1: derivação científica independente antes dos relatórios do implementador

Data: 2026-09-15. Revisor: `gate1_scientific_review`, independente do desenho e da implementação. Esta nota foi escrita após a leitura da ficha v2, seu JSON e freeze, das regras Gate 1, CLAUDE.md, contrato histórico e trechos científicos do manuscrito. Nenhum memo de contribuição, derivação do desenhista, tabela de resultados esperados ou script numérico foi aberto antes desta gravação. Não executei R, simulação, bootstrap ou análise real.

## 1. Identidade verificada e objeto

Hashes conferidos com SHA-256: manuscrito `12493a67133f988c5e6a13933bf2b89c0d9880e96bae329248a207b3aeaf7b5e`; plano `d2d2ea2e39102ab4193ee2f82b12b0823143867a23750c38d626aa4797eb7f5d`; ficha MD `37562fccf615793d0b589b58303e0afeb225edd73ea85e44a7bb1b7688be7097`; ficha JSON `12affe0250af02ada1fc4213a1067ccfe5b482fa5d7a78c52261069c7e7ff00f`. Contrato: `ivb-pa-refine:5375d3c27ac1:round1`, especialmente C01–C04/C06/C08. A verificação abaixo concerne ao procedimento congelado; não certifica novidade ou Gate 1 completo.

O objeto estatístico é a diferença de coeficientes OLS, com as mesmas observações, transformações e regressoras comuns e com posto completo. A interpretação causal requer as hipóteses separadas de cada estrutura. Os exemplos determinísticos reproduzem momentos e identidades, sem amostragem gaussiana ou evidência de cobertura.

## 2. Prova FWL e comparação por união

Seja A uma matriz de controles comuns (incluindo intercepto), M_A seu residualizador ortogonal e d=M_A D, y=M_A Y, z=M_A Z. Na regressão longa, y=d beta_long+z theta+e, com d'e=0. Multiplicando por d'/(d'd), obtém-se beta_short=beta_long+(d'z/(d'd)) theta. Logo beta_long-beta_short=−pi' theta, em que pi é o vetor das inclinações de Z_j em D+A. As equações normais são suficientes; não há hipótese causal nessa prova. No caso populacional, substituir produtos internos por esperanças e exigir momentos finitos e covariância não singular.

Aplicar primeiro com A=(W,L), e depois com A=(W,Z):

- B=(D,W,L), C=(D,W,Z), U=(D,W,L,Z).
- a=beta_U−beta_B=−theta_Z,U' pi_Z|W,L.
- l=beta_U−beta_C=−theta_L,U' pi_L|W,Z.
- t=beta_C−beta_B=a−l.
- A retirada assinada de L no percurso B→U→C é −l, e não l.

A identidade final t=a−l é telescópica; as duas identidades produto são inclusões aninhadas distintas. Não se pode aplicar diretamente a auxiliar que acrescenta Z a B à comparação C−B, pois C também retira L. O percurso alternativo B→(D,W)→C tem incrementos distintos em geral, embora o mesmo endpoint. A soma de contribuições conjuntas, parcelas sequenciais e leave-one-out são objetos diferentes. Se U perde posto, os produtos com coeficientes únicos de U deixam de estar definidos; a mera existência de B e C não resolve isso.

## 3. E1: solução analítica própria

Escrevendo Y=(q+r)D+bL+r e_Z+e_Y, a regressão B preserva L e tem beta_B=q+r. Em U, beta_U=q. Para C, a regressão auxiliar de L em (D,Z) tem coeficiente em D igual a 1/2 e em Z igual a zero: Cov(L,D)=Cov(L,Z)=1 e Cov(D,Z)=2, Var(D)=2, Var(Z)=3; a inversa de [[2,2],[2,3]] dá esse resultado. Portanto beta_C=q+b/2. A auxiliar Z~D+L tem inclinação 1 em D. Consequentemente:

`a=−r; l=−b/2; retirada=+b/2; t=b/2−r; CET=q+r.`

| Célula | beta_B | beta_C | beta_U | a | l | retirada | t | CET | Compensação |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| central | 1 | 1 | 1/2 | −1/2 | −1/2 | 1/2 | 0 | 1 | sim |
| menos | 1 | 9/10 | 1/2 | −1/2 | −2/5 | 2/5 | −1/10 | 1 | sim |
| mais | 1 | 11/10 | 1/2 | −1/2 | −3/5 | 3/5 | 1/10 | 1 | sim |
| nulo | 1 | 1 | 1 | 0 | 0 | 0 | 0 | 1 | não |

Todos os três casos não nulos cumprem os limiares congelados 1/8 e 1/4; nenhum deles foi escolhido após saída numérica. O certificado total da classe é {B}; U identifica q, o efeito direto sob a SCM linear e hipóteses fornecidas. C coincide numericamente com o CET no caso central, mas não possui esse certificado na classe: seu viés relativo ao CET é b/2−r. Na subclasse nula, as duas setas para Y estão conhecidamente ausentes e o certificado total é {B,C,U}. É necessário preservar essa atualização da classe em qualquer tabela de ações.

Na ordem (L,D,Z), Cov(X)=[[1,1,1],[1,2,2],[1,2,3]]. As covariâncias com Y são (q+b+r, 2q+b+2r, 2q+b+3r); Var(Y)=2q²+b²+3r²+2qb+4qr+2br+1. Estas expressões podem servir como oráculo analítico independente do OLS numérico.

Os oito contrastes de Walsh prescritos são centrados e mutuamente ortogonais: a soma de qualquer caractere binário não constante no cubo é zero, e o produto de caracteres distintos também é não constante. Dividir o Gram por n=8 produz I_4. Isso prova igualdade dos segundos momentos relevantes. Não prova independência conjunta dos quatro erros: e_Y=e_L e_D. Os fixtures não devem fornecer validação inferencial ou substituto de amostra aleatória.

## 4. E2: equivalência observacional e diferença causal

Em G_M: (D,Z,Y)=(e_D,e_D+e_Z,2e_D+e_Z+e_Y). Em G_F: (D,Z,Y)=(u_Z/2+u_D,u_Z,3u_Z/2+u_D+u_Y). Com as variâncias fornecidas, ambas têm média zero e matriz

`Sigma_(D,Z,Y)=[[1,1,2],[1,2,3],[2,3,6]].`

Como as duas distribuições são gaussianas multivariadas, igualdade de média e covariância implica igualdade da distribuição observável completa. Nos fixtures, igualdade de covariância continua sendo só checagem de momentos; a conclusão sobre distribuição vem das SCMs gaussianas, não das linhas sintéticas.

Em ambas, beta_S=Cov(D,Y)/Var(D)=2 e beta_T=1, theta_Z,T=1, pi_Z=1, shift=−1. Em G_M, do(D=d) altera Z e o efeito total é 2; o ajuste S identifica total e T identifica direto. Em G_F, do(D=d) não altera Z e o total é 1; T identifica total, enquanto S inclui confundimento. Sem escolher a estrutura, o certificado de um coeficiente OLS único para o total não existe. A ação correta registra ambas as afirmações condicionais e mantém a atribuição causal do shift indeterminada. Nem sinal nem tamanho do shift resolve a ordem de D e Z.

## 5. Covariância: igualdade de transformações, não cobertura

Empilhar beta=(beta_B,beta_C,beta_U)' e definir

`H=[[−1,0,1],[0,−1,1],[−1,1,0]]`.

Então (a,l,t)'=H beta e Cov(a,l,t)=H Cov(beta) H'. Em particular Var(t)=Var(beta_C)+Var(beta_B)−2Cov(beta_B,beta_C), e também Var(t)=Var(a)+Var(l)−2Cov(a,l). O vetor (a,−l,t) usa K=diag(1,−1,1)H; a covariância entre adição e retirada tem o sinal oposto à covariância entre a e l. Uma implementação que esquece esse sinal pode dar variância errada mesmo com contrastes corretos.

Para produto escalar, o gradiente de −theta pi é (−pi,−theta), e a variância delta inclui `2 theta pi Cov(theta,pi)`. Para a−l, é indispensável também a covariância cruzada entre os parâmetros das duas auxiliares e do modelo U. No vetor, o gradiente é (−pi',−theta'). A igualdade de estimativas produto/diferença é exata amostra a amostra; a igualdade de aproximações delta exige uma covariância conjunta coerente com as mesmas equações. Misturar estimativas de covariância, ajustes de graus de liberdade ou populações-alvo pode quebrá-la.

Se C+ e P produzem a mesma função dos mesmos dados, suas distribuições e covariâncias verdadeiras são iguais quando existem. Reamostras idênticas e regras de intervalo idênticas também dão saídas idênticas; reamostras independentes introduzem discrepância computacional desnecessária. Uma transformação H de uma matriz arbitrária PSD é checagem algébrica, não estimativa validada de variância. Na origem theta=pi=0 o gradiente é zero e a aproximação de primeira ordem pode degenerar; reescrever produto como diferença não muda essa dificuldade.

## 6. Implicação para a contribuição e limites desta revisão inicial

A ficha fornece a C+ os mesmos modelos, hipóteses, dados e operações que P. A prova mostra igualdade dos contrastes em todo o domínio OLS declarado, e os critérios causais são os mesmos por construção. Logo espero igualdade das duas coordenadas de perda de C+/P nos casos prescritos, sem ganho matemático/inferencial do procedimento atualmente descrito. Isso é conclusão sobre este procedimento e comparador explícito, não impossibilidade de extensões futuras ou prova de cobertura de toda a literatura.

O exemplo central demonstra por que endpoints estáveis podem ocultar passos grandes, mas C+ recupera os passos. O segundo exemplo demonstra limite da informação causal comum, não capacidade exclusiva de P. C0 omite campos e não recebe penalidade por isso; não se deve tratá-lo como analista incapaz de reconstruir o que suas entradas contêm.

Novidade exige ainda leitura integral da literatura mais próxima; conforme instrução recebida, Gelbach integral está pendente. Aplicações pertencem a outro leitor. O Gate 1 não pode receber PASS desta nota, mesmo que todos os testes determinísticos futuros concordem. A conclusão limitada pode fundamentar um memo de decisão segundo plan.md:129.

## 7. Próximos passos autorizados

Após preservar esta leitura, confrontar memo/derivação/resultados esperados e reader_* bibliográficos; registrar diferenças candidatas para adjudicação. O script R só será aberto depois do aviso de congelamento do coordenador, submetido a review-r independente antes de qualquer execução e reavaliado se mudar de bytes. Nenhum código ou fonte científica foi editado nesta revisão.
