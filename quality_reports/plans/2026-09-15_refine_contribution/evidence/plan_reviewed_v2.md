---
title: "Uma contribuição distinta para o IVB-paper"
subtitle: "Plano de revisão com gates, agentes e critérios de decisão"
author: "Plano preparado para Manoel Galdino"
date: "15 de setembro de 2026"
lang: pt-BR
---

# 1. Direção proposta

**O paper deve demonstrar que seu procedimento muda uma decisão metodológica relevante em relação ao melhor procedimento existente.** Corrigir as equações, oferecer intervalos adequados e melhorar as aplicações é necessário para tornar o trabalho confiável. A contribuição distinta depende de uma demonstração adicional: qual erro de interpretação ou de especificação o leitor passa a evitar, em quais condições e com qual evidência?

A rota recomendada é desenvolver e testar um procedimento para avaliar controles que mudam de papel ao longo do tempo. Esse procedimento deve preservar um efeito contemporâneo bem definido, separar inclusão de controle, retirada de história e mudança de amostra, e quantificar as mudanças com incerteza adequada. Seu valor precisa aparecer em um exemplo transparente e em uma aplicação central com timing defensável. A decomposição FWL fornece a álgebra do procedimento; a novidade precisa ser demonstrada na pergunta que ele resolve e na evidência que produz.

Esta é uma **hipótese de contribuição a testar**, não uma promessa de novidade já estabelecida ou de aceitação editorial. O Gate 1 tem poder de interromper a rota antes de uma longa campanha de simulações e reescrita. Um artigo mais correto e mais claro pode continuar incremental; o plano preserva essa possibilidade para que o investimento subsequente seja informado.

## 1.1 O teste que organiza a revisão

Um caso promissor é uma mudança pequena do coeficiente que resulte da compensação entre duas intervenções: retirar uma variável da história pré-exposição e acrescentar seu valor contemporâneo. O leitor pode interpretar a estabilidade aparente como tranquilizadora, embora os dois passos alterem a comparação por razões diferentes. Outro caso é uma mudança conjunta pequena que esconda contribuições opostas de controles com papéis diferentes. Esses casos devem ser examinados, mas **compensação entre componentes, por si, já é um problema conhecido de decomposição**.

O teste precisa comparar três níveis de informação: comparação convencional dos coeficientes; decomposição existente acompanhada das mesmas informações causais; procedimento proposto. Todos recebem a mesma amostra, documentação temporal e informações disponíveis. Se a vantagem desaparecer diante do segundo comparador, a alegação de avanço metodológico deve ser reduzida ou reformulada. A experiência dos agentes com um exemplo não substitui evidência de que pesquisadores humanos tomariam decisões melhores.

O plano também exige casos em que a resposta correta seja conservar a ambiguidade. Nem o sinal de $\widehat\pi$, nem o de $\widehat\theta$, nem a magnitude de seu produto identifica, isoladamente, o papel causal do controle.

## 1.2 Uma comparação bibliográfica que precisa vir primeiro

Gelbach (2016), *When Do Covariates Matter? And Which Ones, and How Much?*, já apresenta uma decomposição condicional das mudanças de coeficientes e uma fórmula de covariância. Isso torna insuficiente vender a identidade vetorial, a presença de controles correlacionados ou a incorporação de covariância como novidade por si. A página editorial e o resumo foram consultados nesta preparação; o confronto integral de resultados e hipóteses pertence ao Gate 1. [Fonte primária](https://www.journals.uchicago.edu/doi/10.1086/683668).

Os demais confrontos prioritários são Blackwell e Glynn sobre inferência causal com TSCS; Cinelli, Forney e Pearl sobre bons e maus controles; e os trabalhos já citados sobre sensibilidade, dinâmica e covariáveis afetadas pelo tratamento. A revisão bibliográfica será dirigida por claims concretos, com textos integrais e localizadores. Não se exige uma revisão enciclopédica. [Blackwell e Glynn](https://doi.org/10.1017/S0003055418000357); [versão dos autores de Cinelli, Forney e Pearl](https://carloscinelli.com/files/Cinelli%20et%20al%20(2020)%20-%20A%20Crash%20Course%20in%20Good%20and%20Bad%20Controls.pdf).

# 2. Base e diagnóstico desta preparação

O manuscrito ativo é `ivb_paper_pa.Rmd`, acompanhado de `ivb_paper_pa.pdf`, com 22 páginas. A fonte contém aproximadamente 8.196 palavras, incluindo código e metadados. O checkout iniciou limpo em `main`, commit `482796295b843cc6d9c88c33b4ae5a714c005123`. Foram lidos o parecer integral, seus cinco comentários gerais, os 12 comentários detalhados e a resposta adicional fornecida na conversa.

O parecer corresponde materialmente aos trechos da versão PA atual. Não há recibo do upload que permita provar identidade entre os bytes enviados ao Refine e o PDF local. O registro de leitura e a adjudicação desta preparação se referem expressamente ao PDF local identificado pelos hashes no manifesto.

## 2.1 O que já existe e merece reaproveitamento

- **Álgebra e identificação:** há derivações separadas para deslocamento versus viés, múltiplos controles, alocação entre controles correlacionados, incerteza e condições de identificação do CET. Serão auditadas e integradas; não tratadas como trabalho inexistente.
- **Inferência:** `derivations/scripts/specification_shift_uncertainty.R` já contém contraste pareado, sandwich empilhado e bootstrap por unidade para um controle escalar em OLS sem pesos. A nota declara explicitamente que não executou bootstrap ou avaliou cobertura. Existência do código e calibração empírica são estados distintos.
- **Dinâmica e escolha de lags:** há um pacote de misspecificação de lags que compara ordens fixas, ordem verdadeira, AIC e BIC, e um pacote sobre painéis curtos. Suas saídas devem ser confrontadas com as perguntas novas antes de qualquer ampliação.
- **Aplicações:** Leipziger e Rogowski são auditorias descritivas de contrastes defasados ou prospectivos, com timing reconhecidamente ambíguo. Seu papel didático pode ser preservado, mas eles não cumprem atualmente a função de aplicação central do CET.
- **Plano anterior:** o plano de julho contém 26 tarefas. Esta revisão não reinicia essa lista. O inventário distinguirá material utilizável, material que exige correção e lacunas efetivas.

## 2.2 Pontos que mudam a interpretação do parecer

1. A intercambialidade com efeitos fixos já está escrita na derivação de identificação. O problema confirmado é a ausência dessa condição na formulação abreviada do corpo, acompanhada de uma necessidade de conferir toda a cadeia de prova.
2. A ressalva sobre hipóteses adicionais para efeito direto existe na seção de DAGs. A frase “Only the DAG” na seção seguinte excede essa ressalva e precisa ser reconciliada localmente.
3. A cobertura mínima de 0,700 é calculada para o coeficiente do modelo longo em relação ao CET. Não é um resultado de cobertura do intervalo para $\Delta_Z$.
4. As cinco linhas exibidas nas aplicações não são simplesmente cinco dos 14 candidatos selecionados: três controles da tabela de Rogowski são comparações adicionais. O universo de seis estudos, seus 14 candidatos e os controles adicionais precisam ser enumerados separadamente.
5. A identidade aninhada já tem prova. A lacuna é sua relação com o verbo “mover” um controle e com comparações que substituem $Z_{t-1}$ por $Z_t$.

# 3. Orquestração e escolhas de modelo

As escolhas abaixo são heurísticas conservadoras, sem benchmark comparativo deste projeto. “Máximo” corresponde a `max`; “leve”, a `low`. Maior esforço não substitui especificação clara, testes ou revisão independente. A orientação oficial recomenda Astra com esforço maior para problemas complexos e modelos menores para tarefas mais simples; o catálogo ativo confirma as configurações usadas aqui. [OpenAI Docs](https://developers.openai.com/tracks/building-agents#how-to-choose).

| Configuração permitida | Responsabilidade recomendada | Limite de uso |
|---|---|---|
| Astra leve | Coordenação rotineira, encaminhamento de tarefas já decididas e atualização de estado | Não decide novidade, identificação, provas ou aprovação científica |
| Astra high | Orquestração substantiva, síntese entre frentes e revisão editorial independente | Escala divergências conceituais persistentes para xhigh |
| Astra xhigh | Teste de contribuição, adjudicação de desacordos matemáticos, auditoria causal crítica e Devil's Advocate final | Concentrado nas decisões de maior consequência |
| Sol high | Leitura localizada, documentação de aplicações, edição explicativa com argumento estável | Não recebe uma prova ainda indefinida como simples tarefa de redação |
| Sol xhigh | Desenvolvimento matemático e inferencial, desenho de simulações, implementação analítica complexa | Precisa de revisão independente antes da execução ou integração |
| Sol máximo | Um impasse formal ou inferencial excepcional e delimitado | Reserva; não é o padrão para cada seção ou cada script |
| Luna xhigh | Inventários, validação de esquema, conferência de arquivos e referências, tabelas e formatação determinadas | Nenhuma decisão causal, de originalidade ou de aceitação final |
| Luna máximo | Transformação mecânica extensa com muitos casos de borda verificáveis | Usar somente se piloto mostrar necessidade; não promove Luna a árbitro científico |

**Configuração de execução:** um orquestrador e no máximo três trabalhadores simultâneos. Cada tarefa recebe arquivos exclusivos para escrita. As frentes só trabalham em paralelo quando seus resultados não dependem de decisões ainda abertas. Um único integrador aplica mudanças no manuscrito; implementadores não aprovam seu próprio código, prova ou texto.

Para os gates científicos, o orquestrador recomendado é Astra high; o avaliador de contribuição e o árbitro de controvérsias, Astra xhigh. Sol xhigh produz as derivações e o código analítico; Sol high ou xhigh desenvolve a exposição conforme a dificuldade. Luna fica com trabalho definido e verificável. Não se usarão Terra ou esforços fora da lista do autor.

## 3.1 Contrato comum de cada tarefa delegada

Cada prompt começa com: **“Faça um excelente trabalho: preciso de um resultado correto, claro, verificável e útil para um leitor que retome este paper daqui a seis meses.”** Depois especifica objetivo, arquivos de entrada e hashes, arquivos autorizados para escrita, entregáveis, dependências, pressupostos, limites de escopo e critérios de aprovação.

O agente deve entregar: o que mudou e por quê; evidência por claim; comandos executados e resultados; o que não executou; pendências; e um parágrafo explicando a intuição. Uma igualdade matemática precisa de justificativa para cada passagem. Um fato ausente é registrado como ausente; o agente não inventa definições, dados, nomes de procedimentos ou resultados para preencher uma lacuna.

O revisor recebe o artefato congelado, o contrato do argumento e os critérios do gate. Faz primeiro sua própria leitura e derivação; só depois confronta o relatório do implementador. Seus achados são candidatos até a adjudicação. Correções voltam ao implementador, e a revisão posterior verifica os novos bytes e as dependências afetadas.

## 3.2 Goals, gates e autorização

Cada gate abaixo deve ser **um goal sequencial**, com o objetivo indicado e sem orçamento de tokens presumido. Ao iniciar a execução autorizada, o orquestrador cria o goal do gate atual; só o conclui quando os entregáveis e a revisão independente passarem. O próximo goal é criado depois. As tarefas internas e frentes paralelas pertencem ao mesmo gate, sem criar vários goals concorrentes.

Um gate registra aprovação técnica, não autorização para uma fase não pedida. O pedido atual autoriza este plano, seus registros de leitura e sua avaliação crítica. A revisão do manuscrito, a execução das análises propostas, commits, publicação e envio não foram iniciados. Um pedido posterior para executar o plano fornecerá autorização para as etapas internas correspondentes; não será necessário pedir novamente a mesma autorização a cada gate. Novas decisões substantivas fora da rota aprovada continuam reservadas ao autor.

Os estados locais serão: planejado, em execução, em revisão, aprovado, requer correção ou decisão do autor. O registro deve conter data, hashes, responsável, evidência, achados e decisão. Não usar `complete` para uma entrega com trabalho obrigatório pendente; bloqueio formal de goal seguirá a regra da ferramenta, sem esconder pendências no arquivo de estado.

| Goal | Pergunta que precisa ser resolvida antes de avançar |
|---|---|
| Gate 0 | O parecer, o argumento e o estado do código estão corretamente identificados? |
| Gate 1 | Qual acréscimo demonstrável sobrevive ao melhor comparador existente? |
| Gate 2 | As identidades, os alvos e as interpretações causais estão corretos? |
| Gate 3 | O procedimento é aplicável e comporta ao menos uma aplicação viável? |
| Gate 4 | Código e evidência controlada sustentam o ganho e a inferência anunciados? |
| Gate 5 | Uma aplicação real demonstra o procedimento e seus limites? |
| Gate 6 | Um leitor independente consegue reconstruir o argumento e as derivações? |
| Gate 7 | O conjunto resiste à crítica e pode ser reproduzido? |

# 4. Gates e listas de trabalho

## Gate 0. Fixar a base e adjudicar o parecer

**Goal:** produzir uma base verificável do que o paper afirma, do que o Refine critica e do que já está implementado. **Responsáveis:** Sol high nas leituras; Luna xhigh no inventário; Astra high na síntese e adjudicação. **Entrada:** autorização para iniciar a revisão; parte desta preparação já fornece os registros necessários.

- [ ] Conferir novamente commit, alterações preexistentes, fonte ativa e PDF; calcular hashes e preservar o parecer original. Reutilizar o contrato desta preparação apenas enquanto a identidade e a cobertura se mantiverem válidas.
- [ ] Ler corpo, figuras, tabelas e derivações vinculadas. Para cada claim, registrar objeto estatístico, interpretação causal, pressupostos, evidência e localizador. Manter conflitos locais visíveis, sem ampliar as afirmações do paper para criticá-las.
- [ ] Registrar os cinco comentários gerais, os 12 detalhados e os quatro eixos da resposta complementar. Separar diagnóstico de solução sugerida e classificar cada finding como confirmado, parcial, refutado ou não resolvido.
- [ ] Inventariar os materiais de julho e os pacotes existentes. Para cada tarefa antiga, registrar arquivo, output, teste observado, validade para a pergunta atual e eventual retrabalho. “Já existe” não equivale a “já validado para este uso”.
- [ ] Enumerar os 14 candidatos dos seis estudos e, separadamente, as comparações adicionais. Confrontar a seleção programada com as tabelas exibidas e definir o denominador de qualquer síntese ou superlativo.
- [ ] Definir fronteiras de arquivos. A versão histórica PSRM e o repositório IVB-SDiD ficam preservados; criar diretórios próprios para os novos resultados sem sobrescrever resultados antigos.
- [ ] Entregar matriz de resposta com IDs estáveis, localizadores, gate responsável, dependências e critérios de encerramento. As propostas ainda dependentes de desenho seguem para o gate competente, sem serem tratadas como patches aprovados.

**Passa quando:** todas as seções e comentários têm cobertura; todos os números reutilizados têm origem identificada; não existe desacordo sobre o que o texto realmente afirma que impeça o próximo gate. **Se falhar:** corrigir a leitura ou a proveniência antes de implementar a parte dependente. **Entregáveis:** contrato, matriz de adjudicação, inventário e manifesto.

## Gate 1. Demonstrar valor incremental e viabilidade da aplicação

**Goal:** decidir se há uma rota defensável para uma contribuição metodológica distinta e uma aplicação capaz de demonstrá-la. **Responsáveis:** Astra xhigh no desenho da contribuição; Sol xhigh no confronto bibliográfico; Sol high na viabilidade documental. **Revisor:** Astra high independente do desenho. **Dependência:** Gate 0.

- [ ] Escrever uma página com problema, usuário do método, decisão concreta, procedimento existente mais forte e resultado adicional pretendido. A frase de contribuição deve ser compreensível sem os nomes internos do projeto.
- [ ] Construir uma tabela “resultado conhecido / lacuna específica / acréscimo proposto / evidência exigida”. Ler integralmente os trabalhos mais próximos, incluindo Gelbach. Confrontar a decomposição conjunta, a alocação, a covariância e o papel da informação temporal, sem atribuir novidade pelo nome dado ao objeto.
- [ ] Desenvolver no máximo dois exemplos candidatos. Explicitar o que cada comparador observa e qual decisão deve tomar. Incluir uma situação de benefício, uma de ausência de ganho e uma de ambiguidade causal. O exemplo serve para testar o argumento; não é evidência empírica de adoção ou compreensão humana.
- [ ] Comparar a proposta com uma decomposição existente que receba exatamente o mesmo DAG, o mesmo timing e a mesma história. Decompor a fonte de eventual vantagem: informação nova, resultado novo, organização operacional ou simples mudança de apresentação.
- [ ] Congelar uma ficha do teste de contribuição com decisão, ações possíveis, critério de acerto ou perda, implementação do comparador forte, resultado que distingue os procedimentos e resultado que obriga a reconhecer equivalência. Identificar se o acréscimo pretendido é matemático, inferencial, computacional ou operacional. O comparador não pode ser artificialmente impedido de executar regressões ou aplicar hipóteses às quais tem acesso.
- [ ] Fazer triagem documental de até três aplicações candidatas, começando pelo acervo. Usar critérios definidos antes de calcular os deslocamentos: intervenção atual bem definida, janelas documentadas, história prévia disponível, suporte, painel e clusters adequados, dados acessíveis e contraste relevante entre controles. Registrar exclusões.
- [ ] Produzir para cada candidata uma ficha de timing, variáveis, unidade de análise, estimando, disponibilidade, limitações e trabalho de preparação. Não selecionar por magnitude ou significância de $\Delta$. Um efeito pequeno pode cumprir a função científica.
- [ ] Escolher uma aplicação principal e uma reserva por critérios substantivos. Se nenhuma servir, formular uma busca adicional delimitada ou uma rota explicitamente descritiva; a falta de uma aplicação CET não será resolvida apenas renomeando o índice temporal.
- [ ] Registrar essa escolha como provisória até a verificação conjunta do Gate 3. Anotar desde já se história, número de períodos, suporte ou dependência podem exigir um estimador fora do núcleo algébrico do paper.
- [ ] Submeter a proposta a um ataque explícito: “Isto é Gelbach mais um checklist já conhecido?” Registrar o que sobrevive, qual proposição ou capacidade exige desenvolvimento e por que merece um artigo autônomo.

**Passa quando:** a ficha do teste está fechada e um exemplo verificável identifica uma capacidade ou ganho que o comparador forte não reproduz nas condições declaradas; a rota tem ao menos uma aplicação documentalmente viável. O resultado ainda é candidato a confirmação nos gates seguintes. A leitura integral da literatura é condição para afirmar novidade. Se houver equivalência matemática e inferencial, ela será registrada. Um ganho apenas operacional exige uma justificativa e evidência próprias, sem herdar automaticamente a classificação de avanço metodológico. **Se falhar:** produzir um memo de decisão com opções concretas: estreitar para contribuição aplicada/pedagógica, desenvolver uma extensão específica de maior alcance ou suspender esta rota. Mudar o escopo científico é decisão do autor. **Entregáveis:** ficha congelada do teste, memo de contribuição, confronto com literatura, exemplos e seleção provisória da aplicação.

## Gate 2. Estabilizar os objetos matemáticos e os relógios causais

**Goal:** fazer cada comparação do paper corresponder a um objeto definido, uma identidade correta e pressupostos causais explícitos. **Implementador:** Sol xhigh; Sol máximo apenas para um impasse delimitado. **Revisor:** Astra xhigh. **Dependência:** Gate 1.

- [ ] Fixar as definições de efeito contemporâneo, coeficiente populacional, estimador amostral, deslocamento de especificação e viés relativo ao alvo. Especificar a sequência assintótica quando ela importar. Manter uma folha de notação comum ao corpo, apêndice e código.
- [ ] Distinguir a projeção populacional de referência do limite do estimador within quando $N$ cresce e $T$ permanece fixo. Se ambos forem usados, dar nomes e definições diferentes e derivar sua relação. Uma grande simulação com $T$ fixo e a mesma transformação within não será aceita automaticamente como verdade populacional livre do componente dinâmico que se quer medir.
- [ ] Definir separadamente os relógios de mediador e collider. No segundo, explicitar como o processo de resultado anterior à mensuração do controle se relaciona com o outcome do estimando. Corrigir “any within-period responses” sem apagar a inclusão das vias mediadas no CET total.
- [ ] Separar anterioridade temporal de admissibilidade causal. Classificar timing documentadamente pré-exposição, documentadamente pós-exposição, plausível ou ambíguo; depois avaliar o papel no DAG e a suficiência da história. Um timestamp não resolve essas outras condições.
- [ ] Re-derivar a identidade escalar e vetorial por residualização e equações normais. Explicar cada passagem, posto, interceptos/FE, amostra comum e a distinção entre coeficientes de projeção e efeitos causais. Confrontar com a literatura de decomposição, com atribuição apropriada.
- [ ] Fixar como comparação principal a inclusão de $Z_t$ preservando toda a história justificada. Para estudar substituição, usar modelos definidos por conjuntos de regressoras. Se $B$ contém a história e o lag, $C$ contém a história e o valor atual, e $U$ contém ambos, escrever e provar $\widehat\beta_C-\widehat\beta_B=(\widehat\beta_U-\widehat\beta_B)-(\widehat\beta_U-\widehat\beta_C)$. Todos usam as mesmas observações e transformações.
- [ ] Explicar que cada parcela da expressão anterior é uma inclusão aninhada com sua própria auxiliar. Comparar as duas ordens possíveis de adição/retirada e distinguir diferença final única de atribuição dependente do percurso. Verificar colinearidade e casos em que o modelo de união não é estimável; nesses casos, não fingir uma decomposição identificada.
- [ ] Separar mudança de especificação de mudança de amostra e de pesos. O núcleo permanece OLS sem pesos; extensões só entram se necessárias à aplicação e formalmente demonstradas. Não aplicar a identidade de OLS a GMM, estimadores penalizados ou coeficientes corrigidos por viés sem uma derivação específica.
- [ ] Reconciliar a intercambialidade do corpo com o conjunto completo $H^-_{it},\alpha_i,\tau_t$ da derivação. Reexaminar a passagem de médias potenciais a média observada e ortogonalidade; distinguir isso da correlação induzida pelo demeaning em $T$ finito. Transportar para o corpo as hipóteses adicionais necessárias à interpretação como efeito direto.
- [ ] Formalizar a decomposição $E[\widehat\Delta]=\Delta^P+b_L-b_S$, onde $b_m=E[\widehat\beta_m]-\beta_m^P$. Mostrar também $E[\widehat\beta_m]-\tau=(\beta_m^P-\tau)+b_m$. Cada termo deve ter um alvo e um modo de avaliação; comparar dois vieses observados não isola automaticamente os componentes.
- [ ] Fazer verificação independente linha a linha e checagens numéricas determinísticas dos sinais, limites, conjuntos de regressoras e identidade. Incluir exemplos de controles correlacionados e um contraexemplo à aplicação indevida em comparação não aninhada. Tests confirmam implementação; não substituem a prova.

**Passa quando:** nenhuma comparação central usa a identidade fora de seu domínio; todas as passagens de prova e seus pressupostos estão verificados; cada resultado tem uma explicação em prosa e um exemplo. **Se falhar:** retirar ou reformular o claim afetado antes de programar a evidência. **Entregáveis:** derivações revisadas, nota de relógios, mapa dos modelos e parecer matemático adjudicado.

## Gate 3. Tornar história e inferência procedimentos executáveis

**Goal:** oferecer um procedimento que um terceiro consiga aplicar, inclusive quando os dados não sustentam uma conclusão causal. **Responsáveis:** Sol xhigh para história e inferência em arquivos separados; Astra high integra; Astra xhigh revisa. **Dependência:** Gate 2, com documentação da aplicação escolhida.

- [ ] Definir o conjunto mínimo de história a partir do processo substantivo e de uma classe explícita de DAGs/dinâmicas. Distinguir lags causalmente obrigatórios de escolhas de aproximação. Um critério de informação não pode retirar um confundidor necessário apenas para melhorar o ajuste.
- [ ] Fixar uma regra primária de lag/transformações antes de examinar $\Delta$, usando a frequência dos dados, a duração plausível dos mecanismos e a informação pré-exposição. Delimitar um conjunto pequeno de alternativas e fixar a mesma janela de observações comparável. AIC/BIC, se usados, escolhem dentro de um conjunto já admissível; não certificam intercambialidade.
- [ ] Usar os resultados existentes de seleção de lags para identificar limites e dúvidas. Especificar o que autocorrelação residual, instabilidade, pouco suporte, alta persistência ou sensibilidade ao histórico devem provocar: revisão do modelo, restrição da conclusão ou resultado inconclusivo. Ausência de rejeição não prova suficiência causal.
- [ ] Escrever o procedimento completo em passos, com entradas, saídas e exemplos. Permitir explicitamente que ele devolva “somente diagnóstico descritivo” quando timing ou identificação não estiverem defendidos. Esclarecer por que ADL+FE é uma implementação condicional da média, sem lhe atribuir privilégio universal.
- [ ] Definir separadamente os alvos dos intervalos: CET, coeficientes de projeção dos modelos e deslocamento populacional. O diagnóstico amostral observado é uma identidade exata; sua incerteza se refere a um parâmetro definido, não à aritmética já calculada.
- [ ] Escolher inferência conforme a amostragem e a dependência da aplicação. Bootstrap por unidade requer independência ou dependência suficientemente fraca entre unidades; FE de tempo não garantem isso. Se forem necessários clusters mais amplos, poucos-clusters ou dependência transversal residual, justificar e validar o procedimento específico ou restringir o escopo.
- [ ] Tratar escolhas de história feitas com os próprios dados como parte do procedimento. Preferir uma especificação primária previamente fixada. Se seleção por dados for mantida, distinguir intervalos condicionais à especificação de incerteza do procedimento completo; repetir seleção em reamostras é uma candidata a validar, não garantia de validade pós-seleção.
- [ ] Definir regimes difíceis da inferência: poucos clusters, estimador dinâmico viesado, denominador próximo de zero, produto com ambos os componentes próximos de zero e muitos controles. Não presumir que diferença pareada ou bootstrap usual elimina o problema não regular na origem. Validar a solução ou declarar sua região de validade.
- [ ] Para cada restrição de uso, especificar como o pesquisador a aplicará com informação observável ou premissa substantiva defendida. Não definir uma região prática apenas pelos valores verdadeiros desconhecidos de $\theta$ e $\pi$. Qualquer regra que, a partir dos dados, altere história, classificação do caso ou método de intervalo integra o procedimento completo a calibrar, inclusive nas fronteiras entre regimes. Se a validade não puder ser defendida, a saída deve ser descritiva ou usar um procedimento conservador com justificativa própria.
- [ ] Fixar magnitudes substantivas e critérios de avaliação antes da execução. Reportar o deslocamento em unidades interpretáveis, seu intervalo e, quando estável, razão para um benchmark nomeado. Não selecionar controles pelo teste de significância do shift nem usar $|\Delta|/SE(\widehat\beta_L)$ como teste.
- [ ] Fechar uma matriz de compatibilidade para aplicação principal e reserva: história admissível defendida, equações estimáveis, suporte, $N/T$, estimador, dependência e inferência disponível. A necessidade de corrigir viés não pode transformar silenciosamente a identidade OLS em identidade de outro estimador. Pelo menos uma candidata deve permanecer na região coberta antes da campanha integral de simulações.

**Passa quando:** dois leitores conseguem executar o procedimento e identificar quando ele permite interpretação causal, apenas descrição ou nenhuma estimativa confiável; e ao menos uma aplicação passa na matriz conjunta. Estimandos, hipóteses de dependência, regras de uso e tratamento da seleção estão explícitos. **Se falhar:** restringir a classe coberta e reavaliar a compatibilidade antes da execução extensa; não adicionar mais métodos sem uma necessidade demonstrada. **Entregáveis:** protocolos operacional e inferencial, matriz de compatibilidade e especificação congelada da aplicação.

## Gate 4. Implementar e demonstrar o ganho com evidência controlada

**Goal:** obter código revisado e evidência que avalie contribuição, erro e limites do procedimento. **Implementação:** Sol xhigh em código e desenho de simulações; Luna xhigh em manifestos e tabelas determinadas. **Revisão de código:** outro Sol xhigh, via `review-r`; revisão científica Astra xhigh. **Dependência:** Gate 3.

- [ ] Adaptar as rotinas existentes em módulos separados para amostra comum, modelos aninhados, substituição, inferência e relatórios. Preservar IDs de linhas e clusters; recusar silenciosas mudanças de regressoras, pesos ou amostra. Lags devem respeitar unidade e continuidade do calendário.
- [ ] Testar identidade escalar/vetorial, inclusão/retirada, sinais, colinearidade, missing, unidades reamostradas repetidas, covariância cruzada e erros de entrada. Usar tolerância relativa escalada, por exemplo $10^{-10}(1+|\Delta|)$ nos casos bem condicionados, e registrar condicionamento numérico.
- [ ] Retirar cálculos do Rmd: scripts R produzem saídas persistentes, e o documento lê essas saídas. `dplyr::select()` será explícito. Preservar sementes, versões, parâmetros, saídas brutas e falhas de todas as replicações.
- [ ] Fazer revisão de código antes de execução e resolver todos os achados materiais. Rodar primeiro um piloto pequeno que verifique equações, estabilidade, alvos, amostragem e fluxo de inferência. Uma execução integral do plano, quando autorizada, inclui os pilotos e simulações especificados; não exige repetir a autorização por gate.
- [ ] Construir a matriz mínima de simulações a partir do teste de contribuição: incluir e omitir $Z_t$ mantendo o lag; substituição com passos separados; confundidor legítimo; mediador; collider; papéis mistos/cancelamento; história insuficiente; e ambiguidade que não pode ser resolvida pelos coeficientes. Reutilizar DGPs existentes quando responderem à pergunta.
- [ ] Comparar os três procedimentos do Gate 1 com o mesmo conjunto de informações. Pré-especificar decisão, erro relevante, magnitude substantiva e regiões de parâmetros; não escolher depois o caso em que a proposta parece melhor. Separar ganho demonstrado por uma regra formal de uma hipótese sobre comportamento de leitores.
- [ ] Separar desenvolvimento de avaliação posterior do procedimento congelado. Registrar versões, resultados que motivaram ajustes e quais casos já foram examinados; preservar os casos desfavoráveis como limites. Uma nova rodada pré-especificada não apaga o fato de que sua hipótese foi desenvolvida à luz das anteriores.
- [ ] Para cada DGP, publicar equações, parâmetros, condições iniciais, restrições de estabilidade, burn-in, número de unidades/períodos, repetições e regras de retenção. Calibrar também as regras de seleção e troca de intervalos, com casos nas suas fronteiras e próximos à origem do produto. Substituir “Task 12/13” por apêndices científicos identificados e diretamente acessíveis.
- [ ] Definir $\beta_S^P$, $\beta_L^P$ e $\Delta^P$ a partir do DGP, por cálculo analítico quando disponível ou por aproximação independente de alta precisão com erro documentado. Estimar separadamente o componente de especificação e o viés de estimação; explicitar a sequência assintótica. Recalcular as figuras que hoje dizem “isolar” viés sem essa separação.
- [ ] Auditar a cobertura de 70% até a célula e o estimador de origem. Distinguir IC do CET, IC de $\Delta^P$ e intervalo Monte Carlo para uma média simulada. Incluir calibração do procedimento final, não apenas da versão com história e clusters conhecidos.
- [ ] Fixar precisão Monte Carlo e tolerância de cobertura antes da rodada integral. Como ponto inicial de planejamento, estimar cobertura com MCSE de no máximo 0,005 nas células que sustentam recomendações; isso requer cerca de 1.900 repetições se a cobertura for 0,95 e até 10.000 no pior caso. Ajustar o orçamento pelo piloto, sem reduzir silenciosamente a precisão. Reportar falhas e intervalos de Monte Carlo; cobertura baixa exige reparo ou restrição de uso, não descarte da célula.
- [ ] Reavaliar a comparação mediador+confundidor. Os valores 1,023 e 1,016 estão mais próximos de 1,03 que de 1,00; explicitar distâncias e incerteza Monte Carlo. Ampliar separação de alvos apenas com parâmetros substantivamente motivados e pré-especificados, preservando o caso original.

**Passa quando:** código e provas concordam; simulações respondem à decisão do Gate 1; os resultados sustentam um ganho delimitado diante do comparador forte; a inferência está calibrada na região de uso anunciada e as falhas estão explicadas. **Se o ganho desaparecer:** voltar ao Gate 1. **Entregáveis:** código, testes, DGPs, dados simulados brutos, manifesto, relatório e figuras científicas.

## Gate 5. Executar a aplicação central e organizar as demais

**Goal:** mostrar o procedimento completo em uma aplicação cujo estimando, timing, modelo e inferência correspondam aos resultados anteriores. **Implementador:** Sol xhigh; documentação Sol high; conferências Luna xhigh. **Revisor causal/inferencial:** Astra high, com Astra xhigh para desacordos. **Dependências:** Gates 1–4.

- [ ] Preservar a seleção da aplicação feita sem acesso aos shifts; documentar qualquer mudança de elegibilidade ou disponibilidade. A aplicação reserva não será escolhida porque o primeiro resultado foi pequeno, nulo ou desfavorável.
- [ ] Ativar a reserva somente por falha de elegibilidade definida previamente, como indisponibilidade dos dados ou impossibilidade documental/estatística de implementar o desenho. Ausência de vantagem incremental é evidência sobre a proposta e deve permanecer no artigo ou no diagnóstico de viabilidade; não autoriza procurar uma aplicação mais favorável.
- [ ] Reproduzir a especificação original pertinente e registrar diferenças antes de adaptá-la. Validar tipos, ausências, duplicidades, unidade de análise, intervalos de datas, construção de lags, suporte e perdas de amostra. Documentar o novo estimando se a análise original tinha outro alvo.
- [ ] Publicar uma figura simples das janelas de exposição, covariadas, história e outcome; citar documentação primária para as datas. Um CET exige uma intervenção atual e uma janela de resposta defensáveis; converter subscritos de um estoque acumulado não basta.
- [ ] Expor os DAGs plausíveis, suas premissas e o que permanece incerto. Na aplicação observacional, não tratar o modelo preferido como verdade conhecida: formular a conclusão condicionalmente à evidência e às hipóteses defendidas.
- [ ] Estimar a linha de base congelada e os modelos que acrescentam controles atuais mantendo a história. Exibir as equações completas. Quando a prática substantiva motivar substituição, apresentar a diferença total e os passos aninhados separados, sobre a mesma amostra.
- [ ] Calcular coeficientes, shift assinado, componentes, covariância e intervalos com o procedimento validado. Separar efeitos da amostra, do estimador, da dinâmica e da inclusão do controle. Explicar sinais e magnitudes em unidades da aplicação, sem selecionar o denominador mais favorável.
- [ ] Mostrar em linguagem aplicada qual conclusão muda, ou por que uma conclusão antes confiante deve permanecer inconclusiva. Comparar com a decomposição existente e as mesmas informações causais. Reportar também o que o procedimento não consegue decidir.
- [ ] Reorganizar Leipziger e Rogowski como exemplos complementares de ambiguidade, se continuarem úteis. Fornecer tabela completa dos seis estudos e 14 candidatos; identificar controles adicionais e retirar superlativos sem universo explícito. Manter a amostra intencional e seus critérios transparentes.
- [ ] Obter reprodução independente a partir dos dados e scripts congelados, incluindo amostra comum, sinais, intervalos, janelas e conclusões. Desacordos de interpretação causal são adjudicados separadamente de diferenças computacionais.

**Passa quando:** a aplicação percorre todas as etapas do procedimento, produz uma conclusão metodológica útil mesmo se a estimativa for pequena, e não precisa de timing inventado ou hipótese escondida. **Se falhar:** voltar à seleção ou estreitar a contribuição; não forçar uma narrativa causal. **Entregáveis:** aplicação reproduzível, ficha de identificação, tabelas, figura temporal e auditoria independente.

## Gate 6. Reescrever para compreensão, com matemática explicada

**Goal:** fazer o leitor entender o problema, o procedimento e os resultados sem memorizar todo o manuscrito nem conhecer o histórico dos agentes. **Autor de exposição:** Sol xhigh; edição localizada Sol high; integração Astra high. **Leitor independente:** outro agente, sem acesso aos memorandos internos. **Dependências:** resultados estabilizados dos Gates 2–5.

- [ ] Criar um roteiro argumental de uma página: uma pergunta, uma contribuição central, o papel de cada resultado e a evidência que o sustenta. A introdução será reescrita a partir do resultado efetivamente obtido, com atribuição explícita do que já era conhecido.
- [ ] Abrir com um problema aplicado concreto e um exemplo que reapareça ao introduzir notação, modelos, decomposição e decisão. O exemplo deve ajudar o leitor a acompanhar a lógica; não precisa concentrar todas as exceções do apêndice.
- [ ] Organizar o corpo em: problema e contribuição; alvo e timing; comparação entre especificações; procedimento dinâmico e inferência; evidência simulada; aplicação central; limites. Integrar as condições perto da afirmação a que se aplicam, evitando uma seção inteira de ressalvas desconectadas.
- [ ] Para cada equação ou proposição, escrever antes a pergunta que ela responde; definir símbolos localmente; explicar depois cada componente, a intuição e um exemplo. O corpo mostra os passos indispensáveis e o apêndice contém a derivação completa, com referências concretas a equações.
- [ ] Abrir cada seção lembrando brevemente o problema e o resultado anterior necessário. Encerrar com o que foi estabelecido e por que isso permite o próximo passo. Reintroduzir símbolos usados após uma distância longa; evitar “as above” quando o leitor precisa procurar qual hipótese está em jogo.
- [ ] Eliminar nomes como “Task 12”, “Task 13”, “firewall”, “safe”, “bad” e rótulos de conveniência quando exigirem conhecimento interno. Usar nomes científicos ou descritivos definidos. Preservar nomes internos apenas nos arquivos de trabalho e na proveniência.
- [ ] Revisar cada parágrafo telegráfico: fornecer sujeito, conexão causal ou lógica e consequência para o leitor. Remover repetição que apenas reafirme contribuição; preservar repetição orientadora que restabeleça estimando e escopo no lugar em que serão usados.
- [ ] Fazer cada tabela e figura funcionar autonomamente: título, modelos completos ou chave inequívoca, alvos, unidades, parâmetros essenciais, tamanho amostral, denominador e natureza exata dos intervalos. Numerar e referenciar todo apêndice; não depender de nomes de arquivos para a compreensão científica.
- [ ] Dar o PDF a um leitor sem acesso ao plano, às conversas ou aos nomes internos. Pedir que explique por escrito a contribuição, a diferença para Gelbach, os passos da substituição, os dois testes para admissibilidade do lag, o alvo dos intervalos e a decisão da aplicação. Exigir localizadores e explicação com suas próprias palavras.
- [ ] Adjudicar erros desse leitor: distinguir incompreensão causada pelo texto de crítica científica. Reescrever as passagens responsáveis e repetir a leitura das partes afetadas. Não aprovar por uma nota média de estilo se a contribuição ou uma derivação continuar incompreensível.

**Passa quando:** um leitor independente reconstrói corretamente o argumento e as passagens matemáticas essenciais; não há termos internos sem definição, saltos de derivação ou resultados órfãos de contexto. **Entregáveis:** fonte e PDF revisados, apêndice científico, relatório do leitor e registro das mudanças explicativas.

## Gate 7. Aprovação científica e pacote reproduzível

**Goal:** entregar um paper e um pacote cuja correção, contribuição e clareza resistam a verificações independentes. **Revisores:** Astra xhigh para contribuição e Devil's Advocate; Sol xhigh para matemática/inferência; Sol high para exposição. Luna xhigh auxilia na conferência mecânica. **Dependência:** Gate 6.

- [ ] Congelar os bytes candidatos e revalidar o contrato argumental das partes alteradas e suas dependências. O PASS da versão de julho não aprova automaticamente a nova versão.
- [ ] Pedir uma revisão adversarial da contribuição: o que o procedimento permite fazer, o que já existia, quais pressupostos sustentam a diferença e se a aplicação demonstra esse ganho. O revisor deve apontar a objeção mais forte e a evidência capaz de respondê-la.
- [ ] Revisar independentemente as provas, o alinhamento de estimandos e estimadores, a seleção de história, a incerteza pareada, a dependência e os limites. Separar erros críticos, imprecisões locais e limitações já reconhecidas; adjudicar todos os achados materiais.
- [ ] Reproduzir o pacote a partir de scripts documentados em ambiente limpo apropriado. Executar testes relevantes, auditar todos os números citados e registrar versões, sementes, entradas, saídas e falhas. Não exigir reruns irrelevantes quando as dependências permanecem intactas.
- [ ] Inspecionar todas as páginas do PDF e do apêndice: matemática, tabelas, figuras, captions, referências, fontes, tamanho do texto e quebras de página. Corrigir o fonte e conferir novamente a região alterada.
- [ ] Fechar a matriz do Refine com uma resposta interna por comentário: diagnóstico, mudança, localização e evidência. A resposta pode rejeitar uma solução inadequada, desde que o motivo esteja demonstrado.
- [ ] Produzir avaliação editorial final: contribuição sustentada, público e gênero do artigo, limitações e eventual decisão pendente do autor. A escolha do periódico será feita com base no paper resultante e nas regras atuais, sem prometer aceite ou inferir probabilidade a partir de PASS técnico.
- [ ] Entregar PDF principal, apêndice, fontes, scripts, dados/outputs permitidos, manifesto, instruções de reprodução e resumo do que foi executado. Commit, tag, push, submissão e mensagens a terceiros dependem de pedido explícito para essas ações.

**Passa quando:** não há erro crítico confirmado ou achado material não resolvido; a contribuição sobrevive ao comparador forte; a aplicação e as provas sustentam o claim; a leitura independente passa; os resultados e o PDF são reproduzíveis. **Se falhar:** retornar somente ao gate e às dependências afetadas, com novo hash após correção. **Entregável:** pacote pronto para a decisão editorial do autor.

# 5. Sequência e critérios que atravessam os gates

O caminho principal é $0\rightarrow1\rightarrow2\rightarrow3\rightarrow4\rightarrow5\rightarrow6\rightarrow7$. A triagem documental da aplicação ocorre já no Gate 1. Durante a formalização, documentação e preparo estrutural de dados podem avançar sem analisar shifts ou antecipar decisões pendentes. O código da aplicação pode ser preparado durante o Gate 4, mas sua inferência final depende da validação do procedimento.

Em cada gate, a tarefa delimitada passa por implementação ou análise, congelamento, revisão independente, adjudicação, correção pelo implementador e verificação dos novos bytes. A meta é resolver a questão científica de cada etapa; a quantidade de relatórios não é um critério de sucesso.

Três condições encerram ou reabrem a rota: ausência de contribuição incremental depois do confronto com o método existente; ausência de aplicação compatível com o estimando; e inferência ou provas que não sustentem o escopo pretendido. Nenhuma delas será escondida por mais simulações, uma nova sigla ou uma introdução mais enfática.

Todo retorno de gate gera uma nota de reformulação com o motivo, as evidências já vistas, a mudança de hipótese e o que será avaliado posteriormente. O registro preserva tentativas e resultados adversos. Uma aplicação sem ganho científico não é descartada como se tivesse falhado apenas uma checagem documental.

# 6. Rastreabilidade dos comentários do Refine

| Comentário | Problema a resolver | Gates principais |
|---|---|---|
| Geral: valor analítico | Distinguir ganho do procedimento de identidade conhecida | 1, 4, 5, 7 |
| Geral: substituição | Fazer workflow e comparações corresponderem à álgebra | 2, 4, 5 |
| Geral: baseline | Definir história, lag e situações inconclusivas | 2, 3, 4 |
| Geral: simulações/cobertura | Identificar DGPs, alvos e origem das falhas | 3, 4, 6 |
| Geral: aplicações | Ter aplicação central compatível com CET e inferência | 1, 5 |
| 1 | Apêndices identificados com equações e parâmetros | 0, 4, 6 |
| 2 | Aplicações atuais não exercitam baseline CET | 1, 5, 6 |
| 3 | Universo de aplicações e controles incompleto no artigo | 0, 5, 6 |
| 4 | Escopo do bootstrap e dependência entre unidades | 3, 4, 5 |
| 5 | Relógio do outcome e collider | 2, 5, 6 |
| 6 | Condicionamento completo na intercambialidade | 2, 6 |
| 7 | Especificação que inclua collider contemporâneo ausente da figura | 4, 6 |
| 8 | Decomposição entre deslocamento populacional e viés finito | 2, 4, 6 |
| 9 | Hipóteses para leitura como efeito direto | 2, 6 |
| 10 | Timing pós-tratamento documentado | 2, 3, 5 |
| 11 | Amostra e regressoras comuns; inclusão versus substituição | 2, 3, 4, 5 |
| 12 | Proximidade dos alvos na simulação mista | 4, 6 |

# 7. Avaliação crítica do plano

Um agente **Astra xhigh**, independente da elaboração do plano, aplicou a skill Devil's Advocate. Sua conclusão foi que a rota é séria, mas os critérios iniciais ainda permitiam avançar com uma contribuição apenas plausível. Todos os cinco achados foram adjudicados como problemas reais de especificação dos critérios do plano e incorporados:

| Crítica | Alteração no plano final |
|---|---|
| Gate 1 podia aprovar vantagem operacional vaga | Ficha congelada com ações, critério de acerto/perda, comparador forte, condição de distinção e condição de equivalência; ganho operacional recebe avaliação própria |
| Grande $N$ com $T$ fixo podia ser confundido com verdade populacional | Gate 2 separa explicitamente a projeção de referência do limite do estimador within e exige demonstrar o que a aproximação recupera |
| Aplicação podia perder elegibilidade depois da escolha do método | Gate 3 exige matriz conjunta de história, suporte, $N/T$, estimador, dependência e inferência, antes da campanha integral |
| Região de validade podia depender de parâmetros desconhecidos | Regras precisam ser aplicáveis pelo pesquisador; seleção e troca de métodos são avaliadas como procedimento composto, inclusive nas fronteiras |
| Retornos de gate podiam permitir seleção entre tentativas | Registro de reformulações, separação entre desenvolvimento e avaliação posterior e preservação de casos desfavoráveis; reserva só por inelegibilidade pré-definida |

O revisor considerou adequada a decomposição da substituição pelo modelo de união, a preservação dos limites causais, a separação entre implementação e revisão e o teste de exposição por leitor sem memorandos internos. O relatório integral e o registro das alterações acompanham este plano. Esse parecer avalia o desenho da revisão; não certifica antecipadamente a contribuição que será produzida.

# 8. Estado da entrega

Este documento é um plano de revisão. Nesta preparação foram realizadas leitura do parecer e do manuscrito, inspeção de artefatos existentes, leituras delimitadas por agentes e consulta bibliográfica focalizada. Os registros anexos documentam a base, a adjudicação e a revisão crítica do plano. Nenhuma análise empírica ou simulação do paper foi executada e o manuscrito canônico foi preservado.
