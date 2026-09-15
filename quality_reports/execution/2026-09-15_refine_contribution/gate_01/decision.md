# Gate 1: decisão e opções de continuação

Data: 15 de setembro de 2026. Responsável pela síntese e adjudicação: coordenador, com desenho e revisões independentes identificados abaixo.

## Resultado principal

**Gate 1 não aprovado; estado local: decisão do autor.** A rotina congelada não demonstrou uma capacidade metodológica que o comparador forte deixe de reproduzir com a mesma informação. A equivalência foi derivada construtivamente, confirmada por revisor independente e verificada nos exemplos numéricos preespecificados. Nenhuma das três aplicações foi aprovada para demonstrar o efeito contemporâneo do tratamento (CET). A leitura integral de Gelbach continua pendente.

Essa conclusão aciona o ponto de decisão previsto no plano. O pedido do autor já autorizou a implementação interna, inclusive análises e reescrita quando suas dependências passarem. Não falta uma autorização rotineira para executar o próximo comando. Falta escolher uma rota científica depois do resultado desfavorável do teste. O plano determina: **“Mudar o escopo científico é decisão do autor.”** [Plano, encerramento do Gate 1](../../../plans/2026-09-15_refine_contribution/plan.md).

Os Gates 2–7 permanecem planejados, com notas próprias de dependência. O goal do Gate 1 não foi marcado como completo: há trabalho bibliográfico obrigatório pendente e uma escolha substantiva a fazer. O PASS dos artefatos não recebe o significado de aprovação da contribuição.

## 1. Critérios e evidência

| Critério do Gate 1 | Resultado | Evidência principal |
|---|---|---|
| Ficha fechada antes do teste | Cumprido para os exemplos; v2 congelada antes da implementação e execução | `contribution/test_prespec_v2.md`, `contribution/test_prespec_v2.json`, `contribution/freeze_prespec_v2.json` |
| Ganho ou capacidade que o comparador forte não reproduz | **Não cumprido** para a rotina especificada | `contribution/derivation.md`, `review/science/independent_derivation_v1.md`, `review/science/scientific_review_v1.md` |
| Exemplos verificáveis | Cumprido, preservando o resultado desfavorável | `numerical/execution_result.md`, `numerical/results/primary/`, `review/science/postexecution_review.md` |
| Confronto integral com a literatura mais próxima | **Parcial**; cinco trabalhos completos, ajuda e código primários examinados; artigo integral de Gelbach ausente | `literature/reader_report.md`, `literature/reader_claim_comparison.csv`, `literature/acquisition_log.md` |
| Aplicação compatível com a função CET | **Não estabelecida** entre as três candidatas | `applications/selection.md`, três fichas, adendo CET e revisão documental independente |
| Seleção sem informação dos shifts | Não certificável para o processo inicial | Logs de inspeção e decisão, adjudicação R1-F004 e revisão posterior independente |
| Ataque explícito ao caráter incremental | Realizado; o núcleo testado não superou a objeção | `contribution/contribution_memo.md`, seção 4; revisão científica independente |

Os localizadores desta tabela são relativos a esta pasta. As revisões, manifestos e versões anteriores permitem conferir a cronologia e os bytes, sem depender de declarações de conclusão dos implementadores.

## 2. O que foi demonstrado

Com a mesma amostra, transformação e posto completo, o modelo B contém tratamento, regressoras comuns e história prévia; C troca essa história pelo controle atual; U contém ambos. A diferença C−B é a soma do passo de inclusão B→U e do passo de retirada U→C. Cada passo é reproduzido pela identidade Frisch–Waugh–Lovell (FWL). O comparador C+ pode ajustar os três modelos e as duas regressões auxiliares, usar o mesmo grafo causal e transformar a mesma covariância conjunta. A proposta P não tem informação adicional nesse teste.

No exemplo de compensação, B e C têm coeficiente 1, U tem 0,5, e os passos são −0,5 e +0,5. O coeficiente final realmente coincide com o CET na célula central; as perturbações mostram que essa coincidência não estabelece identificação ao longo da classe. A célula nula preserva a ausência de ganho. No exemplo de ambiguidade, duas populações gaussianas têm a mesma distribuição observável e deslocamento −1, mas efeitos totais 2 e 1. Ambos os procedimentos devem manter as interpretações condicionais aos grafos.

O código foi corrigido pelo implementador após quatro achados confirmados e recebeu PASS de revisão R antes de executar. Uma execução em R 4.4.2 terminou com código zero: 168 verificações gerais, 106 projeções reportadas e 20 comparações de covariância. São verificações sobre quatro células de oito linhas e dois conjuntos de oito linhas, não repetições Monte Carlo. O revisor verificou os 16 hashes/tamanhos e recomputou projeções, gradientes e covariâncias por fórmulas próprias. Os maiores erros frente ao cálculo independente foram 9,99 × 10⁻¹⁶ e 9,71 × 10⁻¹⁷, respectivamente.

O domínio da prova é a rotina OLS definida, com seus dados e hipóteses comuns. A execução confirma sua implementação nos casos prescritos. Ela não avalia cobertura, inferência em painéis dinâmicos, ganho humano ou toda extensão possível. O problema de primeira ordem na origem do produto não é resolvido apenas escrevendo o contraste como diferença pareada.

## 3. Literatura e aplicações: o que permanece aberto

A leitura integral registrada cobre Blackwell–Glynn, Cinelli–Forney–Pearl, Imai–Kim (2019 e 2021) e Bellemare–Masaki–Pepinsky. A ajuda pública de b1x2 foi lida integralmente e trechos pertinentes do código do autor foram inspecionados. Erros de notação, localizadores e explicação dos sinais foram corrigidos e revalidados. O artigo integral de Gelbach não foi localizado nas rotas acessíveis; resumo, ajuda e código não substituem essa exigência. A solicitação de eventual caminho local ao autor permanece sem resposta registrada.

A conclusão de equivalência deriva das equações do comparador especificado. Não é uma afirmação de que o artigo não lido contém cada passagem temporal da proposta. A pendência bibliográfica impede encerrar o confronto e afirmar novidade; ela não constitui evidência de um ganho ainda ausente.

A seleção documental corrente é:

- **Blair:** elegível pelos critérios documentais literais, incluindo painel e estrutura de dependência identificáveis; CET não estabelecido. Uma análise de projeção futura pode ser possível, ainda dependente de preparação e inferência.
- **Ballard-Rosa:** espera documental sobre o calendário da crise inflacionária. A exposição é esquerda em exercício versus centro/outros, e o operador mensal no código não prova a frequência original da crise. CET não estabelecido.
- **Claassen:** espera documental, sem exclusão afirmativa pela mera ausência da seta apoio→PIB. O PIB é substantivamente relevante como confundidor. As premissas originais excluem o efeito contemporâneo do apoio sobre democracia.

**Não há principal nem reserva CET aprovada.** A classificação inicial foi corrigida e preservada em snapshot. O protocolo original não foi alterado; a correspondência CET foi explicitada em adendo posterior à triagem. O leitor inicial teve contato incidental com colunas numéricas antes de congelar o protocolo. A revisão independente não encontrou base para afirmar seleção deliberada pelo resultado, mas tampouco elimina a possibilidade de influência anterior. Isso permanece como limitação, inclusive para a escolha das três candidatas entre o acervo.

## 4. Opções concretas para o autor

| Rota | Próximo passo delimitado se escolhida | Evidência que precisaria existir antes de nova aprovação |
|---|---|---|
| **A. Contribuição aplicada ou pedagógica** | Fixar uma nova frase de contribuição, o público e a decisão ensinada. Avaliar se a comparação futura de Blair sustenta esse objetivo ou se cabe a busca documental delimitada descrita em `applications/selection.md` | Aplicação ou demonstração didática defensável, com atribuição de FWL/Gelbach e afirmação compatível com o que foi medido. Não manter o claim de capacidade metodológica inédita |
| **B. Extensão inferencial específica** | Escrever um memo de uma página com alvo, estimador, dependência, região de validade, comparador forte e garantia desejada; fazer leitura dirigida e prova antes de código | Uma garantia adicional demonstrada, por exemplo para o deslocamento perto da origem do produto. Solução e originalidade ainda não estão estabelecidas; não presumir que inversão de conjuntos ou bootstrap conhecido seja novo |
| **C. Ferramenta operacional** | Definir uma tarefa de uso, erro ou custo mensurável e comparador disponível; escolher avaliação de software ou uso humano e congelar seu protocolo | Evidência própria de redução de erros ou trabalho. Acerto de agentes e validação algébrica não medem compreensão humana |
| **D. Suspender esta rota** | Preservar a decisão, fontes, código, saídas e versões históricas como base para uma escolha posterior | Nenhuma nova alegação de contribuição; os defeitos já mapeados no manuscrito continuam documentados, sem campanha adicional de simulações e reescrita |

A busca adicional oferecida pela triagem é uma opção delimitada, não uma procura por resultados mais favoráveis. Uma aplicação futura seria escolhida por elegibilidade e relevância; ausência de ganho não seria convertida em exclusão documental. A rota escolhida exigirá uma nota de reformulação que preserve os exemplos e informações já vistos. Nenhuma das opções foi executada nesta consolidação.

## 5. Revisão, preservação e retomada

O desenho foi produzido por `gate1_contribution`; o confronto bibliográfico por `gate1_literature`; a triagem por `gate1_applications`; o código por `gate1_numerical`. `gate1_scientific_review` revisou o argumento, o R antes da execução e as saídas; `gate1_application_review` refez a leitura documental antes do confronto com as fichas. O coordenador conferiu e adjudicou os achados, devolveu reparos aos implementadores e preservou os bytes anteriores. As classificações e retratações estão em `review/coordinator_findings.md` e nos pareceres, sem tratar toda objeção como confirmada.

O congelamento global acompanha esta decisão. A conferência final de sua integridade e correspondência aos pareceres fica em `review/science/final_gate_review.md/json`. Um PASS dessa conferência significa que o diagnóstico negativo está corretamente documentado, sem conceder aprovação científica ao Gate 1.

Os 17 arquivos de base, incluindo fonte e PDF PA e os arquivos históricos PSRM, mantiveram os hashes de entrada na validação final. Não houve edição do manuscrito, execução de Monte Carlo, bootstrap ou estimação com dados reais nesta etapa. O PDF entregue é o relatório desta execução. Os documentos de cada gate distinguem o que foi feito do que aguarda a continuação escolhida.
