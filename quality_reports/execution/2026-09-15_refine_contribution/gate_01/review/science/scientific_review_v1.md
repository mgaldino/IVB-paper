# Revisão científica independente do Gate 1

Data: 2026-09-15. Revisor: `gate1_scientific_review`. Escopo: ficha, prova, exemplos, comparação C+/P e confronto bibliográfico; aplicações fora do escopo. Nenhum R executado e nenhum código numérico aberto nesta fase.

## Parecer

**PASS científico delimitado para a álgebra e a conclusão de equivalência do procedimento congelado; NÃO PASS do Gate 1 global.** A derivação própria, preservada antes de consultar relatórios do desenhista, coincide com os resultados e as condições de `derivation.md` e `expected_analytical_results.json`. Não encontrei erro material nos sinais, exemplos E1/E2, certificados causais ou limites da conclusão de contribuição. A implementação ainda exige revisão pré-execução independente. A apresentação bibliográfica exige pequenos reparos e sua dependência Gelbach integral permanece aberta.

Minha nota prévia é `independent_derivation_v1.md`, SHA `127af01ab77788de445ed2360528db4992f37805997c51968ff79ad48e28a175`. Sua ordem de gravação foi comunicada ao coordenador antes da abertura dos memos e relatórios. As passagens científicas do manuscrito examinadas foram 184–192, 389–451, 457–501 e 629–638, com o contrato C01–C04/C06/C08.

## Conferência independente

| Objeto | Evidência confrontada | Resultado da revisão |
|---|---|---|
| FWL escalar/vetorial | derivation.md §§2–3, equações 1–6 | Equações normais produzem exatamente full−short=−theta'pi; duas auxiliares distintas dão a troca |
| Sinal da retirada | derivation.md §3; ficha §2 | Correto: retirada=−d_lag e total=d_add−d_lag |
| E1 central/perturbações/nulo | derivation.md §5; JSON E1_cells | Todos os números concordam; compensação em três casos e ausência no nulo |
| Identificação na classe | derivation.md §5.4; JSON certificados | B identifica total na classe; igualdade C=CET no centro é real e não robusta a b; subclasse nula recebe {B,C,U} |
| Fixture determinístico | derivation.md §5.5 | Gram/n=I; dependência e_Y=e_L e_D reconhecida; não há inferência gaussiana a partir do fixture |
| E2 | derivation.md §6; JSON E2 | Mesma Sigma e distribuição gaussiana; total 2 versus 1; shift −1; conclusões condicionais e ambiguidade global corretas |
| Covariância | derivation.md §7 | Transformações conjuntas e equivalência condicionada à mesma V são corretas; mesma reamostragem não certifica cobertura |
| Origem do produto | derivation.md §7 | Degenerescência de primeira ordem não é eliminada por escrever diferença; fixture nulo não testa inferência |
| Contribuição | onepage; memo §§1–6; derivation.md §§4,9 | Conclusão delimitada de nenhuma capacidade adicional encontrada é sustentada para a rotina congelada |

Os exemplos oferecem uma explicação verificável para uma comparação que pode induzir erro de leitura. Eles não demonstram que um pesquisador cometerá esse erro, que P reduza erros humanos, ou que P melhore inferência. C+ reconstrói explicitamente os mesmos objetos e possui as mesmas hipóteses. A prova é mais forte que igualdade em quatro pontos: cobre a identidade OLS no domínio fixado. A equivalência causal, por sua vez, concerne às regras declaradas que recebem a mesma informação, e não à universalidade de todos os métodos possíveis.

## Confronto bibliográfico e nível de leitura

Li `reader_report.md`, sua matriz L01–L17 e `reader_manifest.json`. Conferi diretamente as passagens primárias decisivas de Gelbach: ajuda 35–42, 79–82 e 114–251; código 920–959, 1035–1056 e 1230–1233. Elas sustentam convenção base−full, decomposição por grupos, amostra comum, opções robusta/cluster e termos cruzados do produto. O aviso de covariância reportada de __TC não permite concluir que o método ignore toda covariância. Não executei Stata nem auditei o software completo.

Conferi seletivamente a extração integral disponível de Blackwell–Glynn, em especial linhas 392–418 e 443–492, que distinguem seleção sequencial, dinâmica, CET do ADL e efeitos defasados. Conferi seletivamente Cinelli–Forney–Pearl em controles pré-tratamento colisor, mediação/efeito direto e controles pós-tratamento neutros (extração, regiões 196–217 e 308–388). Esses trechos apoiam a interpretação causal limitada dos exemplos.

**Não reivindico releitura integral independente dos cinco PDFs bibliográficos.** O manifesto registra que o leitor bibliográfico leu esses PDFs integralmente; minha revisão valida o confronto e os trechos decisivos declarados. Imai–Kim 2019/2021 e Bellemare et al. permanecem, nesta revisão, evidência do leitor bibliográfico não revalidada integralmente. Gelbach artigo integral continua ausente; ajuda/código e resumo não substituem essa dependência. Não se declara cobertura completa ou novidade.

## Achados candidatos para adjudicação

| ID | Classe | Localizador | Achado e reparo proposto |
|---|---|---|---|
| SCI-01 | Editorial, confirmado por inspeção, candidato à adjudicação | reader_report.md:20,23 e demais ocorrências `widehat` sem barra/delimitador | A fórmula e o texto perderam escapes e delimitadores matemáticos. Restaurar `\\widehat` e delimitadores matemáticos válidos, preservando convenção base−full. O erro de apresentação não altera a prova independente; exige correção para legibilidade e reprodução do relatório. |
| SCI-02 | Localizador bibliográfico, candidato à adjudicação | reader_report.md §2.3 e tabela de cobertura; matriz L10; reader_manifest.json Blackwell | Eq.(17) aparece no fim da página impressa 1072; a frase sobre consistência segue na 1073. A extração local mostra equação nas linhas 459–461, rodapé 1072 na 464 e continuação 467–470. Corrigir para “Eq.(17), p.1072; discussão p.1073”. |
| SCI-03 | Precisão do requisito, candidato à adjudicação | reader_report.md §3 “Hipóteses”, primeira linha; matriz L12 evidence_required | “Mesmo estimando causal nas especificações” pode ser lido como exigir que ambos os coeficientes identifiquem o mesmo efeito para poder reportar o shift. O próprio E1 compara total e direto, e E2 mantém ambiguidade. Esclarecer: fixar um alvo causal comum de referência e explicitar se cada coeficiente o identifica; a identidade descritiva continua válida quando um deles não o identifica. A leitura favorável já distingue alvo de coeficiente; reparar redação evita uma regra operacional contraditória. |

Todos os achados são candidatos para o coordenador adjudicar antes de qualquer reparo por seus autores. Não alterei relatórios da contribuição ou da literatura. Bytes corrigidos deverão ser identificados e relidos no escopo afetado.

## Consequência para a decisão

O critério de capacidade metodológica distinta do Gate 1 não foi atendido pela proposta congelada: o comparador forte reproduz seus objetos. Essa conclusão negativa é útil e não depende da execução para ser matematicamente fundamentada. Os testes futuros poderão verificar implementação e detectar defeitos; não transformarão a mesma identidade em capacidade distinta. A pendência bibliográfica impede uma conclusão completa de novidade; aplicações exigem parecer separado. O memo corretamente reserva ao autor a escolha de estreitar para contribuição aplicada/pedagógica, formular capacidade específica, medir ganho operacional ou suspender a rota. Nenhuma opção está implementada ou autorizada por este parecer.

## Bytes efetivamente confrontados

| Arquivo relativo a gate_01 | SHA-256 |
|---|---|
| contribution/contribution_onepage.md | ce02beed613504d125ef99c4e68e832a2a4b9296f9a29375cd3619f812cb9bbe |
| contribution/contribution_memo.md | 973f3f9ff578054b78ee889464a987cede704ef0ca8304c72d621a38bfa24a98 |
| contribution/derivation.md | 7038d74a1623e9b18a8902b48a44cbe7ba69530c7de96a03b876203055edb0c8 |
| contribution/expected_analytical_results.json | d1e7514636531ddf383bb7fad6bc75a6e6b90a7c03e3143ca45b1038955e104e |
| literature/reader_report.md | d8bc7ec001f747b03fd407e8f1d66713f73cf7adc6866acd3f95e3b349cb5ed2 |
| literature/reader_claim_comparison.csv | 1a86300890644c8d185f08bbf4ea596b3bf25ac96bcb5ba03d70eab1658c301d |
| literature/reader_manifest.json | 1c632069ea8c9f0d5ab7e129a72dfbde2b26feb7450aa4dad5f33086ec287b58 |

O hash do manuscrito/ficha/plano está na nota independente. O histórico de memória foi consultado apenas para orientação de escopo IVB e não constitui evidência científica deste parecer. A Fase B de review-r está pendente de aviso do coordenador sobre código congelado; a skill foi lida antecipadamente, sem abrir o script.
