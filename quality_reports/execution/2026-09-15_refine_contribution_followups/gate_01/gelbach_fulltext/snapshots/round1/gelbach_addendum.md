---
title: "Gelbach: complemento ao Gate 1"
subtitle: "Fonte integral, confronto bibliográfico e consequência para a contribuição"
author: "IVB-paper | Registro de execução"
date: "15 de setembro de 2026"
lang: pt-BR
---

# 1. Resultado e alcance

**O arquivo `683668.link.pdf`, indicado pelo autor em Downloads, é o artigo de Jonah B. Gelbach (2016), *When Do Covariates Matter? And Which Ones, and How Much?*, publicado no *Journal of Labor Economics*, 34(2), pp. 509–543, DOI 10.1086/683668.** A cópia contém 35 páginas. Sua incorporação resolve a pendência de acesso à fonte primária.

Este complemento reúne a leitura integral por um leitor e o confronto independente dos resultados pertinentes. A cobertura de cada leitor é documentada separadamente: 35 páginas no registro integral; 29 páginas textuais e 12 conferidas visualmente na leitura independente inicial. A revisão não reproduz as tabelas empíricas do artigo. O fechamento documental depende do parecer sobre os arquivos congelados, registrado no índice deste pacote.

**O diagnóstico substantivo do Gate 1 permanece desfavorável à rotina metodológica testada.** O artigo sustenta resultados que o comparador forte já podia executar. Não foi identificado, neste confronto, um ganho da proposta sobre esse comparador. A triagem anterior também não estabeleceu uma aplicação para o efeito contemporâneo do tratamento (CET); ela não foi refeita nesta complementação. A nova fonte melhora a atribuição e encerra a lacuna de leitura, sem satisfazer os outros critérios do gate.

# 2. O que a fonte primária esclarece

Os localizadores abaixo usam as páginas impressas. No PDF, a página 1 corresponde à p. 509.

1. **Identidade e alocação já conhecidas.** As eqs. (4) e (11) estabelecem as versões populacional e amostral da decomposição, e a eq. (12) aloca o deslocamento por covariada; grupos são somas dos componentes. A base e o modelo completo precisam estar fixados. Gelbach usa base menos completo; a convenção do IVB-paper inverte esse sinal. Fontes: p. 518 e pp. 521–523.

2. **Covariância conjunta.** O Apêndice B inclui a incerteza dos coeficientes do modelo completo, a das projeções auxiliares e dois termos cruzados. A eq. (B2), p. 532, contém esses quatro termos. A p. 534 admite estimação robusta à heterocedasticidade ou dependência por grupos, sob condições apropriadas. A variância de uma auxiliar isolada com resposta estimada tratada como fixa omite três termos (pp. 534–535).

3. **Cancelamento e degenerescência são problemas distintos já reconhecidos.** O exemplo de indústria mostra contribuição agregada próxima de zero com vetores de associações não nulos (Tabela 6, p. 525; discussão, p. 526). A nota 14, p. 524, trata do colapso da primeira ordem quando ambos os fatores relevantes são zero. O pré-teste ali sugerido não demonstra cobertura uniforme perto dessa origem.

4. **Timing e causalidade exigem uma leitura delimitada.** A identidade vale como projeção linear sem interpretação causal (p. 518). A nota 3, p. 511, e a conclusão, p. 530, reconhecem casos em que a estrutura causal temporal justifica uma ordem natural de inclusão. Portanto, não cabe dizer que Gelbach ignora toda informação temporal. A identificação do CET continua exigindo hipóteses causais próprias.

5. **Extensões têm condições específicas.** A seção V.A, pp. 526–527, distingue equivalência finita no caso IV exatamente identificado e equivalência assintótica no sobreidentificado, mantendo instrumentos fixos e válidos. A seção V.C, pp. 528–529, usa uma nula de ortogonalidade para o resultado ligado ao teste de Hausman. Os detalhes remetidos a Gelbach (2009) não foram examinados. Nada disso fornece uma fórmula geral de variância a partir apenas dos erros-padrão de dois coeficientes arbitrários.

# 3. A ponte com o teste do IVB-paper

Na ficha congelada, os modelos compartilham outcome, amostra e transformação. OLS e posto completo delimitam a identidade. O tratamento é $D$; $W$ reúne as regressoras comuns; $L$ representa o controle defasado e $Z$, o atual. Os modelos são

\[
B=[D,W,L],\qquad C=[D,W,Z],\qquad U=[D,W,L,Z].
\]

O comparador forte, denominado C+ nos registros, recebe as mesmas informações causais da proposta e pode ajustar todos esses modelos. Aplicar a identidade de Gelbach uma vez com base B e outra com base C produz

\[
d_{\mathrm{add}}=\widehat\beta_U-\widehat\beta_B,
\qquad d_{\mathrm{lag}}=\widehat\beta_U-\widehat\beta_C,
\]
\[
\widehat\beta_C-\widehat\beta_B=d_{\mathrm{add}}-d_{\mathrm{lag}}.
\]

**São duas aplicações com bases diferentes.** Seus componentes não devem ser confundidos com uma única alocação de Gelbach a partir de $[D,W]$, usando os grupos $[L,Z]$. As regressões auxiliares condicionam em conjuntos diferentes nesses dois objetos. A ponte para a troca é uma consequência algébrica explicitada no teste; não é apresentada como um teorema novo ou como fórmula literal do artigo para essa troca.

A covariância entre os dois contrastes também deve respeitar a dependência comum. Se $d=(d_{\mathrm{add}},d_{\mathrm{lag}})'$, então

\[
\operatorname{Var}(\widehat\beta_C-\widehat\beta_B)
=[1,-1]\operatorname{Var}(d)[1,-1]'.
\]

Essa transformação é nossa aplicação ao contraste definido. O Apêndice B fornece o precedente de inferência conjunta, mas não uma fórmula literal para essas duas bases distintas. A ficha já permite construir sua matriz conjunta por equações comuns ou reamostras pareadas. A nova leitura não executou bootstrap e não demonstrou cobertura perto da origem do produto.

No exemplo de compensação previamente verificado, B e C têm coeficiente 1 e U tem 0,5: incluir Z muda o coeficiente em $-0,5$ e retirar L o muda em $+0,5$. O deslocamento final é zero. O comparador forte pode recuperar ambos os passos; esse exemplo não estabelece uma capacidade exclusiva da proposta.

# 4. Decisão e trilha de evidência

**O Gate 1 continua não aprovado; a escolha de outra rota permanece com o autor.** O plano exige ganho demonstrável frente ao comparador forte e aplicação viável, além da leitura. Encontrar e ler o PDF resolve esta última pendência. Os Gates 2–7 continuam sujeitos à decisão prevista no plano, que diz: “Mudar o escopo científico é decisão do autor.”

A entrega anterior foi preservada como registro do estado que antecedeu o fornecimento do PDF. Este adendo atualiza apenas a pendência bibliográfica e suas consequências. Acesso frustrado naquele momento e acesso resolvido agora são eventos distintos. O manuscrito e as análises anteriores não foram alterados.

Para retomar o trabalho: `acquisition.json` registra origem e hash; `reading/` contém relatório integral, cobertura das 35 páginas, matriz de claims e manifesto; `review/` preserva leitura independente e pareceres. O `README.md` reúne o estado final, a adjudicação, a conferência de integridade e os comandos de reprodução. A revisão documental e as verificações de hashes não constituem uma nova execução analítica nem aprovação científica da contribuição.
