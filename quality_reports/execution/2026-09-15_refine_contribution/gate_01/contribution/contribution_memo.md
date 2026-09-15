# Memo de contribuição e opções para a decisão do autor

**Conclusão do designer:** a rotina congelada produz uma comparação aplicada mais explícita, mas o comparador FWL forte reproduz seus objetos, interpretações condicionais e transformações de covariância. Até aqui não sobreviveu uma capacidade metodológica distinta. A conclusão é delimitada à proposta examinada; não é prova de que uma contribuição futura seja impossível. A leitura integral de Gelbach, a validação numérica independente, a revisão do argumento e a viabilidade documental da aplicação permanecem sob responsabilidade das respectivas frentes.

## 1. A contribuição proposta em linguagem aplicada

O procedimento organiza uma decisão real: ao avaliar a medida atual de uma covariável, manter a história necessária ao efeito contemporâneo e distinguir esse acréscimo da eventual retirada do estado anterior. Ele pode exibir quanto cada operação altera o coeficiente e quais conclusões dependem do relógio causal. Se a ordem ou o papel do controle permanecerem incertos, ele deve apresentar as interpretações condicionais sem escolher entre elas pelos sinais do shift.

Essa frase descreve um procedimento útil. A questão científica do Gate 1 é mais exigente: o procedimento oferece algo que uma decomposição conhecida, com o mesmo DAG, timing, história e capacidade de ajustar regressões, não ofereça? A prova e os exemplos não encontraram esse acréscimo na versão testada.

## 2. Resultado conhecido, lacuna, proposta e evidência exigida

| Resultado conhecido ou já implementado | Lacuna específica da versão do paper | Acréscimo proposto | Evidência necessária e conclusão desta frente |
|---|---|---|---|
| Identidade FWL e decomposição conjunta por grupos; ajuda Gelbach 154–203 | O texto apresenta o nome do objeto como locus de originalidade, Rmd 389 e 444 | Dar nome e interpretar o shift em TSCS | Nome e aplicação não acrescentam capacidade algébrica; dois passos FWL reproduzem a troca |
| Produtos condicionais com coeficientes do modelo longo; ajuda Gelbach 166–203 | A discussão pode fazer correlação entre controles parecer obstáculo exclusivo | Separar componentes e compensações | Comparador já trata blocos correlacionados; alocação descritiva e causal permanecem distintas |
| Normal equations/FWL para qualquer conjunto comum | O verbo “moved” não fixa a operação, Rmd 451 e 629–637 | Modelo de união B/C/U e preservação explícita da história | Equações (4)–(6) de `derivation.md` resolvem a lacuna de correção; não acrescentam álgebra independente |
| DAGs e hipóteses informam ajuste e efeito total/direto; contrato C03/C04 e literatura causal a confrontar | A regra de história ainda não é executável para toda aplicação | Classificar timing, defender história e permitir saída descritiva | Mesma informação permite mesma decisão a C+; uma nova regra identificadora exigiria teorema e pressupostos próprios |
| VCE robusta/cluster e tratamento da covariância do produto; ajuda Gelbach 79–82, 225–236 | Aplicações ainda não têm ICs pareados; contrato C06 | Covariância entre endpoints, dois passos e reamostragem pareada | C+ pode usar a mesma covariância e os mesmos resamples. Entrega correta é necessária; não é novidade já demonstrada |
| Identidade estatística não identifica DAG | O texto tem formulação excessiva local em Rmd 442 | Distinguir total/direto/confundimento, preservar ambiguidade | E2 demonstra um limite correto e útil; não resolve o limite e não distingue P de C+ |
| Métodos gerais de validação de inputs, documentação e relatórios | Aplicador pode misturar amostra, história ou relógio | Ferramenta que mantenha invariantes e exponha decisões | Potencial operacional; nenhum benchmark de erros, tempo ou compreensão foi realizado. A mesma amostra já é exigida pelo comparador |
| Produto pode perder termo de primeira ordem na origem; nota local 185–206 e plano Gate 3 | Regra inferencial válida nessa região ainda não foi demonstrada | Uma garantia uniforme ou conservadora com condições observáveis | Pergunta específica possível, sem solução ou novidade estabelecida. A diferença pareada não elimina a degenerescência |

As linhas causais acima usam o contrato para descrever fielmente a proposta, não como substituto de atribuição bibliográfica. A frente de literatura prepara os confrontos localizados com Blackwell–Glynn e Cinelli–Forney–Pearl. O artigo integral de Gelbach continua necessário para a conclusão bibliográfica do gate; a ajuda primária já elimina comparadores frágeis que ignorem blocos, dependência ou covariância.

## 3. O que os dois exemplos dizem e o que não dizem

**E1 identifica uma falha possível do relatório de endpoints.** A troca pode ocultar passos de −1/2 e +1/2; dois números iguais não mostram os movimentos. O exemplo também impede um erro da crítica: o modelo substituído realmente coincide com o CET na célula central. O problema é a identificação ao longo da classe, evidenciada pelas perturbações, e não um viés numérico inexistente nessa célula. A versão nula oferece ausência de ganho: todos os coeficientes e movimentos já concordam.

**E1 não demonstra uma decisão causal exclusiva da decomposição.** As hipóteses fornecidas revelam que Z responde ao tratamento e medeia seu efeito. Um analista com o mesmo DAG pode conservar o alvo total antes de calcular os componentes. C0 recebe também as equações e os momentos; por isso a v2 não trata sua omissão de campos como impossibilidade informacional ou erro de pesquisador. C+/P são a comparação decisiva.

**E2 estabelece uma impossibilidade inferencial específica.** Dois sistemas gaussianos geram exatamente a mesma distribuição de `(D,Z,Y)` e o mesmo shift −1, mas têm CETs 2 e 1. Quando a documentação só estabelece que o resultado vem depois de D e Z, nenhum dos procedimentos pode descobrir a ordem causal pelos coeficientes. Conclusões condicionais ao DAG e diagnóstico descritivo são o resultado correto, com perda zero.

Os exemplos são construções didáticas deliberadas, não seleção de aplicações, teste de frequência de cancelamento, pesquisa com usuários ou avaliação de inferência. E1 é uma janela com estado inicial L; não presume distribuição estacionária de uma série inteira em que todas as variáveis se repetem indefinidamente. A prova FWL se aplica também à matriz com efeitos fixos estimável, mas esse fixture não avalia viés within em painéis dinâmicos.

## 4. Ataque explícito: “Isto é Gelbach mais um checklist já conhecido?”

**A objeção tem força contra o núcleo atualmente especificado.** Um leitor já equipado com decomposição por grupos, regressões intermediárias, informação temporal e hipóteses causais consegue produzir todos os números e rótulos propostos. A inclusão do modelo de união corrige uma comparação mal definida no texto; o cancelamento mostra a utilidade de uma decomposição; a ambiguidade protege a interpretação. Nenhuma dessas três funções, tal como formalizada aqui, exige um resultado novo.

Há, porém, dois limites à objeção. Primeiro, a leitura integral de Gelbach não foi concluída; não podemos declarar que ele publicou cada passo temporal desta proposta ou que seu artigo limita a contribuição a um gênero específico. O argumento de equivalência é matemático e apoiado pela ajuda primária, não uma atribuição de trechos não lidos. Segundo, combinar componentes existentes pode ter valor científico aplicado ou operacional. Esse valor precisa ser demonstrado no uso, na decisão substantiva ou numa garantia adicional; a ausência de uma identidade nova não prova ausência de qualquer valor.

**O que sobrevive:** a comparação via U, a atribuição assinada da retirada, a distinção entre coincidência numérica e identificação na classe, e o exemplo de ambiguidade são materiais úteis para corrigir e ensinar o problema. **O que não está sustentado:** originalidade baseada em nomear o shift, capacidade inédita de lidar com controles correlacionados, inferência pareada como vantagem automática sobre Gelbach, identificação do papel causal por coeficientes, ou superioridade operacional inferida das respostas de agentes.

Uma contribuição autônoma não pode ser defendida apenas pela frase “integra tudo em um workflow”. Precisaria de uma aplicação que gere conhecimento substantivo que justifique esse gênero, de uma evidência operacional com alvo definido, ou de uma capacidade adicional realmente desenvolvida. O Gate 1 exige uma dessas bases; o relatório não a substitui por uma formulação editorial mais enfática.

## 5. Busca justa por uma capacidade específica dentro da rota

Foram examinadas quatro possibilidades, sem abrir extensões ou executar análises:

1. **Matemática da substituição.** O candidato é o modelo de união e o contraste de dois shifts. A derivação explícita mostra que o comparador o reproduz. Não resta uma nova identidade nessa operação.
2. **Inferência conjunta.** O candidato é preservar a covariância de passos e endpoints em vez de tratá-los como independentes. A documentação primária já contempla covariâncias do produto e dependência intragrupo; a transformação conjunta e as mesmas reamostras estão disponíveis a C+. Não se encontrou uma garantia distinta na rotina atual. O problema não regular na origem é concreto, porém a solução permanece ausente; ele não pode ser usado como promessa retroativa de novidade.
3. **Computação.** O candidato é evitar regressões redundantes ou automatizar passos. Para a troca escalar são três modelos e duas auxiliares, já um custo pequeno e explícito. Nenhum limite de complexidade, ganho de memória ou benchmark de tempo foi demonstrado. A enumeração de muitos caminhos não integra estes dois exemplos e não foi introduzida como outra pesquisa.
4. **Operação aplicada.** O candidato é tornar obrigatórios o registro da história, a amostra comum e a saída inconclusiva. Isso pode impedir erros de uso, mas o comparador recebe as mesmas informações e regras, e os exemplos não medem erros de usuários. Uma ferramenta pode ter valor prático sem que a presente comparação prove uma contribuição metodológica distinta.

O resultado desfavorável não foi obtido impedindo a proposta de usar informação legítima. Tampouco se transferiu a ela uma hipótese causal que o comparador não recebesse. A conclusão permanece limitada ao procedimento especificado e pode ser revista se uma capacidade concreta for apresentada com nova ficha e evidência, preservando o que já foi visto.

## 6. Opções concretas para o memo de decisão do autor

| Opção | Resultado que seria buscado | Próximo passo delimitado se o autor escolher | Custo/limite científico |
|---|---|---|---|
| **A. Estreitar para contribuição aplicada ou pedagógica** | Um texto que ensine e documente como uma comparação publicada mistura história e controle atual, com atribuição explícita de FWL/Gelbach | Usar a triagem documental do Gate 1 para avaliar se uma aplicação defensável oferece uma conclusão substantiva ou didática suficientemente relevante; reescrever a frase de contribuição antes de retomar gates | Reconhecer equivalência metodológica; gênero e veículo dependem do resultado, sem promessa editorial. Nenhum paper foi alterado por esta opção |
| **B. Escolher uma capacidade inferencial específica** | Por exemplo, um procedimento para o shift com validade justificada perto da origem do produto, sob um estimador e dependência explicitamente fixados | Novo memo de uma página: alvo, região, comparador inferencial existente mais forte, garantia desejada e critério de impossibilidade/abandono; leitura dirigida e prova antes de código | A pergunta está dentro dos limites reconhecidos pela rota, mas a solução não existe ainda. Se exigir mudar estimador ou classe dinâmica, isso é nova decisão de escopo; não presumir originalidade de inversão de conjuntos conhecida |
| **C. Avaliar uma ferramenta operacional como objeto próprio** | Redução verificável de erros de implementação ou custo de produzir um relatório correto | Definir usuários/tarefas, erros concretos e comparador disponível; decidir se a avaliação será de software ou de uso humano; congelar protocolo antes de criar evidência | Exige evidência operacional própria; exemplos resolvidos por agentes e validação da aritmética não medem compreensão humana. Pode mudar o gênero científico |
| **D. Suspender esta rota e preservar o material** | Evitar campanha de simulações e reescrita sem diferença demonstrada | Arquivar fichas, provas, testes independentes e a conclusão de equivalência; manter o manuscrito e os outputs científicos atuais | Não resolve os defeitos existentes nem descarta os exemplos; adia a escolha de uma contribuição de maior alcance |

Essas opções não autorizam sua própria execução. A revisão independente pode confirmar ou corrigir esta avaliação; o coordenador deve sintetizá-la com a bibliografia e a aplicação. Nenhuma opção foi escolhida pelo designer, e nenhuma mudança de gênero, extensão, fonte do paper ou campanha analítica foi iniciada.

## 7. Evidência, execução e limitações

- Lidos: `CLAUDE.md`; plano completo; decisão e freeze Gate 0; revalidação/matriz; contrato; passagens relevantes do manuscrito e da nota inferencial; passagens localizadas da ajuda oficial de Gelbach.
- Executado: leitura e busca local, criação de Markdown/JSON nesta pasta, cálculo de hashes dos documentos e validação estrutural a registrar no manifesto. Os dois exemplos foram derivados por álgebra; não foram estimados pelo designer.
- Não executado: R, revisão `review-r` pelo designer, testes numéricos, simulação, bootstrap, estimativas reais, mensuração de usabilidade, renderização do paper, alteração do manuscrito, commit ou publicação.
- Pendente: prova e código revistos independentemente; implementação/verificação autorizada pelo coordenador após `review-r`; leitura integral de Gelbach; incorporação do confronto bibliográfico; síntese com a viabilidade documental da aplicação; adjudicação e decisão global do Gate 1.

O arquivo `expected_analytical_results.json` contém expectativas derivadas, marcadas como **não executadas**, para facilitar comparação com a verificação independente. A ficha v2 e seu congelamento permanecem intactos. O README e o manifesto identificam os arquivos finais desta frente e a ordem de leitura.
