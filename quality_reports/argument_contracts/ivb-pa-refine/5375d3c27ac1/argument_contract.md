# Contrato do argumento

**ID:** `ivb-pa-refine:5375d3c27ac1:round1`  
**PDF SHA-256:** `5375d3c27ac1b75ca7246f0e7483470d98a69cf129a853560ae84cfe107d447c`  
**Fonte SHA-256:** `12493a67133f988c5e6a13933bf2b89c0d9880e96bae329248a207b3aeaf7b5e`

## 1. Source-bound identity

Artefato local completo; não há recibo com hash do upload ao Refine. Trechos do parecer correspondem materialmente ao PDF atual.

## 2. Document profile

Paper metodológico em inglês; 22 páginas; sete seções. Perfil general. Quatro agentes fizeram leituras delimitadas; foram reutilizados em turnos nas seções curtas, e não se reivindicam sete contextos independentes. O orquestrador leu o documento integralmente e os registros.

## 3. Thesis, question, and contribution

Quantificar mudanças de especificação com identidade linear e interpretar causalmente somente sob estimando, timing e identificação defendidos.

O manuscrito reivindica organização diagnóstica da identidade e um baseline ADL+FE condicional; sua distinção da literatura é questão para revisão, não certificada pelo contrato.

## 4. Core claims

### C01

O deslocamento entre regressões lineares aninhadas tem identidade exata FWL; sua interpretação como IVB exige identificação causal.

Força: identidade amostral e interpretação causal condicional.

### C02

O shift conjunto é único; incrementos sequenciais dependem da ordem e leave-one-out não é soma aditiva.

Força: álgebra condicional.

### C03

O relógio substantivo determina papéis candidatos; lag não torna controle admissível automaticamente.

Força: causal condicional a DAG e relógio.

### C04

ADL+FE é baseline condicional para CET linear homogêneo com história suficiente e condições de identificação e estimação.

Força: resultado populacional condicional.

### C05

Os modelos com estados relevantes têm menor viés em DGPs exibidos; o baseline falha com confounding omitido.

Força: evidência numérica delimitada.

### C06

Incerteza do shift deve preservar covariância entre estimadores; procedimentos são propostos, não calibrados nas aplicações.

Força: proposta inferencial de escopo restrito.

### C07

Aplicações são diagnósticos descritivos com timing ambíguo de contrastes defasado/prospectivo.

Força: evidência descritiva intencional.

### C08

A contribuição desenvolvida se limita a TSCS linear e uso condicional do diagnóstico.

Força: escopo.

## 5. Claim → evidence → scope map

| Claim | Localizador | Evidência | Escopo |
|---|---|---|---|
| C01 | Rmd 184-190,389-420,826 | Equações curto/longo e auxiliar; Proposição 1 | OLS sem pesos, posto completo, amostra e regressoras comuns |
| C02 | Rmd 408-422; derivations/multivariate_specification_shift.Rmd | Identidade vetorial, definições e prova por FWL | Especificações lineares aninhadas; alocação não causal |
| C03 | Rmd 214-275,279,315,385 | Definição CET, tabelas1-2 e figuras1-2 | CET atual; relógios de mediador e collider diferentes |
| C04 | Rmd 457-501; derivations/adl_cet_identification_conditions.Rmd:63-73 | Média potencial, prova FWL, suporte, tabela3 | Intercambialidade completa nas derivações; não garante within sem viés em T finito |
| C05 | Rmd 551-642; figuras4-5; tabela6 | Outputs existentes e parâmetros/captions | DGPs testados; cobertura0.700 é de long para CET; não é calibração de IC do shift |
| C06 | Rmd 424-438; derivations/specification_shift_uncertainty.Rmd:260-264 | Variância da diferença, script pareado, nota de trabalho não executado | Um controle, OLS, amostra completa comum, cluster por unidade; limites reconhecidos na nota |
| C07 | Rmd 646-650,732-736,822 | Leipziger e Rogowski; tabelas7-8 | 14 candidatos em seis estudos; duas aplicações, três controles extras de Rogowski; sem CET direto ou IC do shift |
| C08 | Rmd 444,828-832 | Conclusão e declaração de extensões futuras | Sem resultados para SDiD, fatores, regimes, links não lineares ou efeitos acumulados |

## 6. Profile-specific contract

Método estatístico, sem jogo estratégico ou desenho empírico único. O contrato distingue os objetos listados no JSON e as duas aplicações.

## 7. What the document does not claim

- Não cria novo estimador causal universal.
- Não infere causalidade ou papel do controle apenas de theta, pi ou Delta.
- Não garante lag admissível ou história suficiente pelo índice temporal.
- Não oferece ICs pareados nas aplicações atuais.
- Não resolve efeitos de regimes, SDiD, fatores ou confounding contemporâneo omitido.
- Não interpreta seis estudos como amostra representativa.

## 8. Terminology

- specification shift: Contraste de projeções não é automaticamente viés causal.
- conditional ADL+FE baseline: CET, timing, história e condições são necessários.
- intervalo Monte Carlo da média do viés: Objetos de incerteza distintos.

## 9. Reconciliation log

### A versão afirma identificação universal ou condicional?

Condicional: Rmd190,457-501,828 e nota de identificação. Frases locais mais fortes continuam registradas como inconsistências, sem atribuir claim universal ao paper.

### Moved significa uma inclusão aninhada?

A intenção não é inferida. O contrato registra a identidade válida para adição e a frase operacional451 compatível com substituição, não coberta por essa identidade. É um defeito/ambiguidade textual localizado que o plano deve resolver, não prova de erro no teorema.

### Intercambialidade com FE está ausente de todo o argumento?

Não: explicitada na nota63-73; omitida na formulação abreviada Rmd465. A crítica incide na consistência de exposição e na rechecagem da cadeia afetada.

### O paper identifica efeito direto somente pelo DAG?

Seção3,315 exige hipóteses de mediação; Rmd441 comprime inadequadamente essa condição. O contrato conserva ambos os localizadores e não atribui uma tese incondicional global.

### Cobertura0.700 é para Delta?

Não. metrics.R:57 usa covered_long; simulation.R:70-111 compara ao beta_true, com beta_cet como alvo. Não é IC pareado de Delta.

### As cinco linhas são subset simples dos14 candidatos?

Não. Rmd141-150 seleciona só GDP em Rogowski; sua tabela inclui três controles adicionais. O contrato separa estudo, candidato selecionado e comparação adicional.

### Restam dúvidas que mudem a descrição do argumento?

Não para o escopo de planejar revisão: as tensões foram explicitamente preservadas como propriedades textuais, não eliminadas ou resolvidas por atribuição de intenção. Validade científica e decisões de desenho permanecem para os gates futuros.

## 10. Gate verdict

**PASS de fidelidade no escopo de planejamento.** As tensões locais estão registradas, sem atribuir ao texto uma intenção de correção. O contrato não certifica a validade científica, a contribuição nem os outputs.
