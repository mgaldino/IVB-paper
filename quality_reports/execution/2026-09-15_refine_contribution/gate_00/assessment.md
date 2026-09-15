# Gate 0: base verificável e adjudicação do parecer

Data da síntese: 15 de setembro de 2026. Responsável: coordenador Astra.

## Resultado submetido à revisão

O conjunto identifica o argumento, os comentários e o estado dos materiais com precisão suficiente para testar a contribuição no Gate 1. Esta recomendação é documental: não aprova a correção científica do manuscrito nem fecha os comentários que dependem dos gates seguintes.

O checkout começou limpo em `731cd6570651ea0f602d5c7cdff89ab43ecdb962`. Os 14 arquivos do manifesto preparatório coincidem com os bytes atuais. O manifesto desta execução reúne 17 entradas, incluindo a versão histórica PSRM e o plano. O contrato da versão PA pode ser reutilizado porque a identidade e a cobertura se mantêm; a falta de recibo dos bytes enviados ao Refine continua registrada.

## Cobertura e evidência

1. **Argumento:** sete registros históricos cobrem continuamente as seções substantivas. A revalidação relê C01–C08 com objeto estatístico, interpretação causal, hipóteses, evidência e localizadores. Os registros históricos não representam sete leitores independentes novos. O coordenador inspecionou as 22 páginas do PDF e o revisor fez sua própria leitura antes de receber as entregas dos implementadores.
2. **Parecer:** `revalidation/response_matrix.csv` e `.json` contêm 21 unidades: cinco gerais, 12 detalhadas e quatro eixos complementares. Os 17 findings originais mantêm sete CONFIRMED e dez PARTIAL. Os quatro eixos adicionais apontam para findings existentes e não elevam o total de defeitos independentes.
3. **Acervo:** `inventory/task_inventory.csv` enumera T01–T26, arquivos, outputs, testes registrados, validade atual e retrabalho. Testes históricos observados não são apresentados como executados nesta sessão. Task13 tem outputs e auditoria localizados; Task14 tem dois checkpoints e início de execução, sem resultados finais verificáveis. A inspeção registra os problemas de bloqueio de validação e denominadores que precisam ser reparados antes de reaproveitar sua bateria completa.
4. **Aplicações:** `inventory/application_candidates.csv` tem 14 candidatos de seis estudos, distribuídos em sete rótulos de especificação. Apenas 11 possuem a razão IVB/SE; três linhas de Albers têm SE ausente. População, urbanização e Polity2 de Rogowski são comparações adicionais, em arquivo separado. As cinco linhas das tabelas atuais correspondem a dois candidatos selecionados e três extras.
5. **Números:** `inventory/number_provenance.csv` identifica fontes, unidades e denominadores de 0,700, 1,023, 1,016 e 14. O primeiro é cobertura do coeficiente longo HPJ em relação ao CET, não do intervalo para o deslocamento. Os dois coeficientes do desenho mediador+confundidor estão mais próximos de 1,030 que de 1,000. A síntese das razões usa 11 valores disponíveis, não 14.
6. **Fronteiras:** os novos artefatos ficam sob `quality_reports/execution/2026-09-15_refine_contribution/`. A versão histórica PSRM, o projeto IVB-SDiD, o manuscrito PA e os resultados analíticos anteriores foram preservados. A autorização atual abrange a execução interna do plano, sujeita às dependências; não é necessário pedir novamente autorização para cada tarefa histórica.

## O que continua aberto

Os conflitos de nesting versus substituição, escolha de história, relógios causais, intercambialidade com efeitos fixos, inferência pareada, interpretação das figuras e aplicação CET têm diagnóstico rastreável. Permanecem como trabalho científico dos gates responsáveis. Este gate não exige resolvê-los para confirmar o que os documentos afirmam.

O Gate 1 deve confrontar a proposta com Gelbach, acompanhado das mesmas informações causais e temporais, e verificar a elegibilidade de uma aplicação antes de investir na bateria de simulações e na reescrita. Uma vantagem apenas sobre a comparação simples de coeficientes não satisfaz o critério de contribuição do plano.

## Verificações e limite da conclusão

Foram executados parsing e contagem dos CSV/JSON, conferência de hashes, inspeção de Git, leitura de fontes/outputs e inspeção visual do PDF existente. Os validadores oficiais do contrato e da adjudicação retornaram VALID. Não foram executados R, estimações, simulações, bootstrap ou renderização do manuscrito. A revisão independente deste pacote e sua adjudicação ficam em `review/` e no registro de decisão.

**Recomendação do coordenador:** aprovar a base documental se a revisão dos artefatos congelados não identificar lacuna material de cobertura ou proveniência.
