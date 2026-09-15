# Achados do Gate 1 e adjudicação do coordenador

Este registro contém decisões sobre achados específicos. Não equivale à aprovação do gate. Correções voltam ao autor do artefato e recebem nova revisão dos bytes afetados. As versões anteriores ficam em `snapshots/`.

## G1-LIT-01 — Notação matemática no confronto bibliográfico

- **Origem:** inspeção do coordenador e confirmação pelo revisor científico independente.
- **Artefato examinado:** `literature/reader_report.md`, SHA-256 `d8bc7ec001f747b03fd407e8f1d66713f73cf7adc6866acd3f95e3b349cb5ed2`.
- **Evidência:** linha 20 apresenta `=widehat\Gamma` sem a barra inicial; linha 23 e outros parágrafos apresentam comandos sem barra e expressões entre parênteses sem delimitadores matemáticos.
- **Classificação:** CONFIRMED. A notação prejudica a leitura e deve ser corrigida, preservando o conteúdo das afirmações.
- **Responsável pela correção:** leitor bibliográfico.
- **Estado:** correção e nova conferência pendentes.

## G1-LIT-02 — Página da equação de Blackwell e Glynn

- **Origem:** revisor científico independente; conferido pelo coordenador na extração do PDF primário.
- **Evidência:** `sources/blackwell_glynn_fulltext.txt`, linhas 457–469, contém a Eq. (17) e o rodapé 1072. A discussão de consistência começa na página seguinte, 1073. O relatório, a matriz e o manifesto indicavam a Eq. (17) somente na p. 1073.
- **Classificação:** CONFIRMED. O localizador correto é Eq. (17), p. 1072, com discussão na p. 1073. O achado corrige localização, sem refutar a interpretação do resultado.
- **Responsável pela correção:** leitor bibliográfico, em todos os registros afetados.
- **Estado:** correção e nova conferência pendentes.

Os três arquivos `reader_*` originais foram preservados em `snapshots/literature_round1/`, com manifesto próprio, antes de qualquer correção.

## G1-LIT-03 — Alvo causal de referência e interpretação de cada coeficiente

- **Origem:** revisor científico independente, SCI-03.
- **Localizadores:** `literature/reader_report.md`, seção 3, primeiro item das hipóteses; matriz bibliográfica, linha L12, evidência exigida.
- **Evidência:** a frase “mesmo estimando causal nas especificações” admite a leitura de que só se pode reportar o deslocamento quando ambos os coeficientes identificam o mesmo efeito. E1 e E2 justamente permitem mudança de alvo ou ausência de identificação.
- **Classificação:** PARTIAL. A leitura favorável distingue alvo pretendido de coeficiente, portanto não há erro confirmado na prova. Existe uma ambiguidade operacional que deve ser removida.
- **Correção solicitada:** declarar o alvo causal de referência e a relação de cada coeficiente com esse alvo, incluindo mudança de estimando ou falta de identificação; preservar a validade descritiva da identidade.
- **Responsável:** leitor bibliográfico. **Estado:** correção e nova conferência pendentes.

Mapeamento com a revisão independente: G1-LIT-01 = SCI-01; G1-LIT-02 = SCI-02; G1-LIT-03 = SCI-03.

**Fechamento da rodada 2:** o leitor corrigiu os três itens, e o revisor independente conferiu os novos hashes e os diffs em `science/literature_revalidation_v2.md`. G1-LIT-01, 02 e 03 estão resolvidos. Os registros anteriores de pendência acima descrevem o estado na abertura de cada achado.

## G1-LIT-04 — Sinal da segunda etapa no exemplo expositivo

- **Origem:** revisor científico, SCI-04, na releitura da rodada 2.
- **Localizador:** `literature/reader_report.md`, seção 4, primeiro exemplo, linha 161 da versão corrigida.
- **Evidência:** o texto anuncia dois movimentos de sinais opostos, mas descreve as duas inclusões B→U e C→U como movimentos para baixo. Na troca B→U→C, a segunda etapa é a retirada de L, de sinal invertido.
- **Classificação:** CONFIRMED como ambiguidade editorial. A derivação formal e a convenção de sinais dos testes estão corretas.
- **Correção:** explicitar inclusão B→U para baixo e retirada U→C para cima; conservar a subtração entre as duas inclusões na identidade algébrica.
- **Estado:** correção pontual pelo leitor bibliográfico e nova conferência pendentes. A rodada 2 está preservada em `snapshots/literature_round2/`.

**Fechamento de G1-LIT-04:** o leitor corrigiu o percurso na prosa, e a revisão `science/literature_revalidation_v3.md` conferiu o novo hash do relatório (`88c4f48681fe0594925a230699004ff0f84602e6a3a441a8bc168ccb3e7daf01`), CSV intacto e atualização do manifesto. G1-LIT-01 a 04 estão resolvidos nos bytes atuais. A pendência do artigo integral de Gelbach continua aberta e é distinta desses reparos.

## G1-NUM-01 — Preflight de SHA-256 mistura avisos com hash

- **Origem:** revisão estática independente de R, NUM-01.
- **Artefato:** `numerical/verify_examples.R`, SHA `eaa328c2c7394c27443f28481f0fc2ebb9436534ad4c1bc390203a88ca7beae6`, linhas 35–44.
- **Evidência:** `system2` captura stderr junto com stdout e exige uma única linha. O coordenador executou somente `shasum` no shell e observou sete linhas de avisos Perl sobre `LC_ALL=C.UTF-8`, seguidas do hash. `suppressWarnings` não elimina texto de stderr do subprocesso.
- **Classificação:** CONFIRMED. Corrigir a chamada para locale suportado e/ou separar os canais, conferir status e validar exatamente um hash hexadecimal.
- **Estado:** correção pelo implementador e nova revisão pendentes. Nenhum R foi executado.

## G1-NUM-02 — Perdas declaradas em vez de calculadas

- **Origem:** revisão estática independente, NUM-02.
- **Localizadores:** script, linhas 732–763 e 1013–1027; validação final 1192–1210.
- **Evidência:** as perdas são preenchidas com zero. A verificação final compara P com C+, sem exigir acerto contra o alvo pré-especificado. Duas ações igualmente erradas poderiam passar esse controle.
- **Classificação:** CONFIRMED. Confrontar cada ação com o alvo da ficha, calcular o vetor de perdas conforme as regras congeladas e integrar a verificação ao resultado final. Regras causais declaradas como entradas não devem ser apresentadas como descoberta causal por regressão.
- **Estado:** correção e revisão pendentes.

## G1-NUM-03 — Contraste de efeitos intervencionais hardcoded

- **Origem:** revisão estática independente, NUM-03.
- **Localizador:** script, linhas 1110–1115.
- **Evidência:** o teste calcula `abs(2 - 1)` e o compara com 1; não deriva a resposta a uma intervenção nas equações estruturais.
- **Classificação:** CONFIRMED. Calcular a resposta de Y à mesma mudança em D sob cada sistema estrutural e conferir os efeitos calculados contra 2 e 1. Manter explícito que os números vêm do sistema causal sintético conhecido.
- **Estado:** correção e revisão pendentes.

O código, README e manifesto anteriores foram preservados em `snapshots/numerical_round1/` antes de qualquer reparo.

## G1-NUM-04 — Status de sucesso antes de concluir os arquivos obrigatórios

- **Origem:** revisão estática independente, NUM-04; leitura das linhas pelo coordenador.
- **Localizadores:** script, linhas 1266–1279 e tratamento de saída 132–137.
- **Evidência:** o log recebe `status=PASS` antes de calcular e salvar o manifesto de saídas. Se a gravação ou o hashing posterior falhar, o tratamento de saída mantém o log existente, que continuaria a declarar sucesso.
- **Classificação:** CONFIRMED. O indicador autoritativo de sucesso deve ser gravado somente depois das saídas obrigatórias; qualquer falha deve deixar estado distinto de PASS, sem hashes circulares entre log/status e manifesto.
- **Estado:** correção pelo implementador e nova revisão pendentes.

## Aplicações — adjudicação da rodada 1

O coordenador confrontou o parecer com os critérios congelados, as fichas, o log de inspeção e as passagens primárias. A adjudicação integral está em `application_adjudication_round1.json`; as fontes e o parecer independente ficam em `applications/review_round1.md/json`.

| Achado independente | Decisão do coordenador | Consequência |
|---|---|---|
| R1-F001, correspondência com CET | CONFIRMED | Separar elegibilidade literal de resposta futura e adequação ao efeito contemporâneo. Nenhuma principal/reserva CET demonstrada |
| R1-F002, calendário da crise inflacionária | CONFIRMED | Corrigir certeza de frequência mensal/pré-exposição; E7 de Ballard-Rosa fica HOLD, sem declarar inexistência de história mais antiga |
| R1-F003, exclusão de Claassen por E7 | CONFIRMED | Ausência de seta apoio→PIB não satisfaz a regra de exclusão. Corrigir para HOLD e preservar hipótese contemporânea original em campo próprio |
| R1-F004, certificação do cegamento | CONFIRMED | Protocolo foi congelado depois da exposição incidental registrada. A revisão posterior não elimina a possibilidade de influência; não há prova de seleção orientada pelos resultados |
| R1-F005, objeção inicial do revisor a E5 de Blair | REFUTED | País, tempo e dependência intrapaís são identificáveis. VCE original inadequada é risco do Gate 3; não é exclusão documental por si |
| R1-F006, nível partidário versus transição | CONFIRMED | Fixar exposição ao governo em exercício e comparador centro/outros, preservando o modelo original; não chamar de efeito de nova adoção |

O artigo de Ballard-Rosa declara controles anuais salvo indicação contrária (nota 94, p. 49) e só nomeia partidarismo e Treasury como exceções mensais (p. 50). O uso de um operador mensal no código não prova a frequência original da crise. Claassen declara ausência de efeito contemporâneo do apoio sobre democracia e descreve desenvolvimento como causa de apoio e democracia; isso confirma a relevância de Z, sem criar uma seta apoio→PIB. A correção de E5 preserva a distinção entre disponibilidade documental e qualidade da inferência futura.

Os 12 arquivos iniciais foram preservados em `snapshots/applications_round1/`. O protocolo v1 e seu recibo devem continuar intactos. Uma explicitação adicional da exigência CET será registrada como adendo posterior à triagem, já exigido pelo plano original, sem ser apresentada como preespecificação anterior às leituras.
