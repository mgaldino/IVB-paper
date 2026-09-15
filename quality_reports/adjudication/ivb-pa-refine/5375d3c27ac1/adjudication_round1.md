# Adjudicação do parecer Refine

## 1. Source and contract identity

PDF SHA-256: `5375d3c27ac1b75ca7246f0e7483470d98a69cf129a853560ae84cfe107d447c`. Contrato: `ivb-pa-refine:5375d3c27ac1:round1`.

## 2. Executive disposition

7 comentários confirmados e 10 parciais, somando cinco gerais e12 detalhados. As ressalvas presentes são preservadas; não se atribuem claims universais ao paper. As recomendações complementares sobre valor diagnóstico, aplicação, história e nesting seguem nos mesmos gates.

## 3. Findings table

| ID | Status | Localizador | Encaminhamento |
|---|---|---|---|
| R1-D01 | CONFIRMED | Rmd559-585 | G4,G6 |
| R1-D02 | PARTIAL | Rmd194,650,736 | G1,G5,G6 |
| R1-D03 | PARTIAL | Rmd141-150,646,777-799,822 | G0,G5 |
| R1-D04 | PARTIAL | Rmd426-438; derivation uncertainty260-264 | G3,G4 |
| R1-D05 | PARTIAL | Rmd222-238 | G2 |
| R1-D06 | PARTIAL | Rmd465; derivations/adl_cet_identification_conditions.Rmd63-73 | G2 |
| R1-D07 | CONFIRMED | Rmd551; Figura4 | G4 |
| R1-D08 | CONFIRMED | Rmd583; metrics.R54-89; simulation.R70-111 | G2,G4 |
| R1-D09 | PARTIAL | Rmd315,441 | G2,G6 |
| R1-D10 | CONFIRMED | Rmd250-253 | G2,G3 |
| R1-D11 | CONFIRMED | Rmd408-417,451,635-637 | G2,G3 |
| R1-D12 | CONFIRMED | Rmd619-625; Tabela6 | G4,G6 |
| R1-G1 | PARTIAL | Rmd184-192,389-444 | G1,G4,G5 |
| R1-G2 | CONFIRMED | Rmd451,629-637 | G2 |
| R1-G3 | PARTIAL | Rmd457-501,629-637 | G2,G3 |
| R1-G4 | PARTIAL | Rmd559-589 | G3,G4,G6 |
| R1-G5 | PARTIAL | Rmd650,736 | G1,G5 |

## 4. Evidence and reasoning by finding

### R1-D01: Simulation boundaries rely on undefined artifacts

**CONFIRMED.** Referências a static audit e Task12/13 sem apêndices identificados no artigo.

Apêndices devem ter identificação científica e parâmetros acessíveis. Solução: `safe`. Gates: G4,G6.

### R1-D02: Applications do not instantiate the CET baseline

**PARTIAL.** A roadmap promete interação com baseline; nenhum caso estima o CET contemporâneo/ADL.

Contrapeso: Os casos declaram explicitamente sua função descritiva e contraste não contemporâneo.

Corrigir promessa e criar aplicação central; não acusar resultados de fingirem identificação. Solução: `needs_design`. Gates: G1,G5,G6.

### R1-D03: Section 6 omits most of the announced applications

**PARTIAL.** Faltam tabela completa e universo explícito do maior ratio; três controles de Rogowski são adicionais.

Contrapeso: A seção declara amostra intencional e não representativa.

Especificar universos de estudo, candidato e comparação extra. Solução: `safe`. Gates: G0,G5.

### R1-D04: Unit resampling does not cover general TSCS dependence

**PARTIAL.** Apresentação principal não explicita independência entre unidades para reamostragem.

Contrapeso: A nota reconhece dependência transversal e escopo unit-cluster restrito.

Trazer restrição ao corpo e validar para desenho escolhido; não reivindicar inferência geral. Solução: `needs_design`. Gates: G3,G4.

### R1-D05: CET outcome timing conflicts with the collider clock

**PARTIAL.** Any responses coloca a mensuração depois de respostas que incluem Z; collider usa Y anterior a Z.

Contrapeso: A própria seção explicita dois relógios distintos.

Distinguir outcome/processo e limitar a frase, sem afirmar que todo DAG está incoerente. Solução: `needs_design`. Gates: G2.

### R1-D06: Missing fixed effects in exchangeability assumption

**PARTIAL.** Intercambialidade abreviada omite FE presentes na média potencial.

Contrapeso: Nota formal inclui FE explicitamente e usa essa condição no passo1.

Reconciliar corpo e prova, não inventar uma falha global da derivação. Solução: `safe`. Gates: G2.

### R1-D07: Figure 4 leaves collider conditioning untested

**CONFIRMED.** Quatro modelos exibidos não incluem Z_t.

Acrescentar comparação realmente aninhada com Z_t se sustentar claim, ou limitar figura. Solução: `needs_design`. Gates: G4.

### R1-D08: Figure 5 does not isolate finite-T bias

**CONFIRMED.** O phase map compara viés de long com diferença entre endpoints e não separa Delta populacional de viés finito.

Definir ambos os alvos e decompor componentes; coverage observada é de long contra CET. Solução: `needs_design`. Gates: G2,G4.

### R1-D09: A DAG alone does not identify a direct-effect shift

**PARTIAL.** Only the DAG e a passagem para efeito direto omitem hipóteses na frase local.

Contrapeso: Seção3 exige hipóteses adicionais de mediação.

Aplicar os qualificadores junto à afirmação e verificar provas afetadas. Solução: `safe`. Gates: G2,G6.

### R1-D10: Timestamp table omits known post-treatment controls

**CONFIRMED.** Regra otherwise só oferece plausible/ambiguous, omitindo pós-exposição documentada.

Separar status temporal de papel causal. Solução: `safe`. Gates: G2,G3.

### R1-D11: Workflow and Section 4.1 leave the diagnostic's nesting unclear

**CONFIRMED.** Moved e passos3-4 permitem leitura de substituição não coberta pelo produto único.

Preservar lags na adição primária; derivar troca em passos identificados. Solução: `needs_design`. Gates: G2,G3.

### R1-D12: Table 6 does not separate the mixed-design targets

**CONFIRMED.** 1.023 e1.016 distam .007 e.014 do total1.03, e .023 e.016 do direto1.00.

Corrigir near, apresentar incerteza e preservar targets originais. Solução: `safe`. Gates: G4,G6.

### R1-G1: Comentário geral G1

**PARTIAL.** Contribuição enfatiza nomear/estimar decomposição de ingredientes conhecidos.

Contrapeso: O texto atribui identidade a FWL e reconhece escopo estreito.

Novidade incremental exige confronto integral com Gelbach e demonstração de decisão; não é possível prometer forte publicação. Solução: `needs_design`. Gates: G1,G4,G5.

### R1-G2: Comentário geral G2

**CONFIRMED.** Workflow não reconcilia substituição com adição aninhada.

Corrigir contraste e provar decomposição da troca. Solução: `needs_design`. Gates: G2.

### R1-G3: Comentário geral G3

**PARTIAL.** Condições de história são assumidas sem procedimento de seleção no corpo.

Contrapeso: Baseline é expressamente condicional e nota possui prova de identificação.

Operacionalizar dentro de classe delimitada; AIC/BIC não prova suficiência causal. Solução: `needs_design`. Gates: G2,G3.

### R1-G4: Comentário geral G4

**PARTIAL.** Artigo não integra DGPs completos e não diagnostica coverage mínima.

Contrapeso: Equações/outputs existem em pacotes; 0.700 é CET de long, não IC Delta.

Integrar proveniência e desenhar avaliação correta de inferência. Solução: `needs_design`. Gates: G3,G4,G6.

### R1-G5: Comentário geral G5

**PARTIAL.** Aplicações não instanciam CET e inferência proposta.

Contrapeso: O texto admite ambos os limites.

Selecionar aplicação por compatibilidade documental, não resultado. Solução: `needs_design`. Gates: G1,G5.

## 5. Unsafe fixes and owner decisions

Não inferir causalidade pelos componentes; não chamar seleção de lags de prova causal; não transformar o contraste de estoque de Rogowski em CET por mudança de índice. Mudança de rota científica após Gate1 exige decisão do autor.

## 6. Unresolved items

Não restam dúvidas sobre os defeitos locais para fins de planejar revisão. Originalidade incremental, aplicação adequada e inferência válida são objetivos prospectivos, não resultados certificados nesta adjudicação.

## 7. Adjudication verdict

**READY_FOR_IMPLEMENTATION** no sentido de encaminhar defeitos e desenhos aos gates. Este turno entrega planejamento; não implementa o paper.
