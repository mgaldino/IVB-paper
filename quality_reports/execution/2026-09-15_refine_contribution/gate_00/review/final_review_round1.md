# Gate 0 — revisão independente do pacote congelado, rodada 1

**Veredicto: REPAIR.** Há uma correção documental localizada no inventário da Task 06. As demais verificações de identidade, cobertura, denominadores, mapeamentos e estado de Task 14 passaram. Não é necessário resolver antecipadamente os problemas científicos dos Gates 2–6 para corrigir este Gate 0.

**Revisor:** `gate0_reviewer`, separado dos implementadores.  
**Data:** 2026-09-15 UTC.  
**Artefato revisado:** os 11 arquivos de `gate_00/freeze_round1.json`, congelados em `2026-09-15T11:49:33.017093+00:00`.  
**Base:** `731cd6570651ea0f602d5c7cdff89ab43ecdb962`.  
**Contrato:** `ivb-pa-refine:5375d3c27ac1:round1`.  
**Leitura anterior ao confronto:** `review/independent_read.md`, produzida antes de consultar os artefatos dos implementadores.

## 1. Integridade do pacote

Recalculei os SHA-256 dos 11 arquivos congelados, das 102 entradas de `inventory/input_sha256.csv` e dos 17 arquivos do baseline: todos coincidiram. A lista integral de hashes revisados acompanha o JSON desta revisão. Fonte PA e PDF preservam respectivamente:

- Rmd: `12493a67133f988c5e6a13933bf2b89c0d9880e96bae329248a207b3aeaf7b5e`.
- PDF: `5375d3c27ac1b75ca7246f0e7483470d98a69cf129a853560ae84cfe107d447c`.

A reutilização do contrato é adequada para esses bytes. A cobertura original tem sete registros de seção e quatro agentes em turnos delimitados; a revalidação preserva as limitações de identificação dos leitores. O coordenador documenta inspeção das 22 páginas, cuja execução é atribuída ao seu registro. Não reivindico ter repetido essa inspeção visual. A ausência de recibo com hash do upload original ao Refine permanece explícita.

## 2. Achado candidato que requer correção

### G0-R1-F01 — inventário trata como ausente uma tabela já existente

**Severidade:** média, documental; bloqueia o encerramento de Gate 0 até correção da linha.  
**Localizador do artefato congelado:** `inventory/task_inventory.csv`, linha 7, `task_id=T06`, campos `tests_observed_in_records` e `rework_needed`.  
**Hash desse artefato:** `0b4f92f68d464a92e986d10a457330481d417f926b28c0e22834f5b8768a6266`.

A linha afirma **“não há tabela de scope conditions dedicada”** e propõe **“materializar a tabela de condições de escopo”**. Entretanto, `ivb_paper_pa.Rmd:479-499` contém a Tabela 3, intitulada *Standardized scope conditions for using ADL + FE with lagged state variables as a CET baseline*. Ela lista alvo/relógio, história/intercambialidade, dinâmica, forma funcional, efeitos fixos, suporte, estimação em T finito e inferência. O próprio pacote de revalidação reconhece essas condições e remete à tabela.

**Por que importa:** Gate 0 deve distinguir material utilizável, material a corrigir e lacunas efetivas. Tratar essa tabela como inexistente induz retrabalho e contradiz a reconstrução do argumento. A existência da tabela não prova que ela esteja cientificamente completa, operacional ou corretamente integrada; esses são critérios distintos e podem permanecer pendentes.

**Critério de correção:** registrar a Tabela 3 e seu localizador entre os materiais existentes; substituir a alegação de ausência e o pedido de criação por eventual revisão/integração da tabela já existente. Manter pendentes a busca de linguagem, as inconsistências locais e a operacionalização que não estejam verificadas. Conferir as referências dependentes no pacote e gerar novo congelamento. Não editar o manuscrito para atender a este achado.

O achado foi comunicado ao coordenador, que informou confirmação pela mesma fonte. A classificação final e a implementação cabem à adjudicação e ao implementador; esta revisão mantém a identificação como achado candidato com evidência direta.

## 3. Conferências que passaram

| Dimensão | Resultado independente | Evidência e limite |
|---|---|---|
| Cobertura do argumento | PASS documental | Sete seções, C01–C08, objetos estatísticos, interpretação causal, hipóteses, não-afirmações e conflitos locais preservados. Não certifica novidade ou provas. |
| 26 tarefas | PASS de enumeração; REPAIR de conteúdo em T06 | IDs T01–T26 únicos, em ordem, com objetivos, arquivos/outputs, testes observados, validade e retrabalho. Li todas as linhas; o único problema material encontrado está acima. |
| Universo dos candidatos | PASS | 14 candidatos, seis estudos, sete rótulos de especificação; dois rótulos pertencem a Leipziger. Todos os valores dos campos IVB, coeficiente longo, SE e razão coincidem com as linhas correspondentes do CSV fonte. |
| Denominador de razões | PASS | 11 razões disponíveis; três ausências em Albers. Mediana absoluta 0.126873193968874, máximo 2.1075941609384, uma razão acima de 1. A síntese não atribui 14 observações às razões. |
| Comparações adicionais | PASS | População, urbanização e Polity2 de Rogowski estão em arquivo separado, sem interseção com os 14 pares selecionados. Valores conferem com o CSV fonte. Cinco linhas exibidas são dois candidatos mais três extras. |
| Parecer e complemento | PASS | 21 IDs únicos: cinco gerais, 12 detalhados e quatro eixos complementares. Os 17 primários preservam sete CONFIRMED e dez PARTIAL. |
| CSV versus JSON da matriz | PASS | IDs, ordem, status, grupos, gates e mapeamentos coincidem em todas as 21 entradas. As versões textuais são paráfrases, não cópias literais; preservam o significado verificado. |
| Mapeamentos e encerramento | PASS | Os quatro eixos apontam para G1; G5/D02; G3; G2/D11. Todos os destinos existem. As linhas distinguem diagnóstico, solução, dependências e critério observável de encerramento. |
| Proveniência numérica | PASS | 0.700, 1.023, 1.016 e 14 possuem origem, universo e limites. O phase-map e o código confirmam o alvo da cobertura. |
| Executado versus histórico | PASS | Checks documentais novos e registros históricos estão separados. Não se declara nova execução de R, bootstrap, MC ou inferência aplicada. |
| Fronteiras | PASS | Novos registros estão na árvore de execução; PA, PSRM, outputs antigos e fontes governantes mantêm identidade. Não houve edição científica por este revisor. |

### Task 13 e a cobertura

A cobertura mínima de 0.700 refere-se ao coeficiente **long** de HPJ contra o CET. A célula identificada independentemente é `P_N250_T08_RY50` (N=250, T=8, rhoY=.5). `metrics.R:57` agrega `covered_long`; `simulation.R:70-111` constrói a cobertura contra `beta_true`. A estatística é o mínimo entre células, cada qual com 500 replicações, não uma cobertura agrupada das 108 células, nem cobertura do intervalo de Delta.

Task 13 tem outputs e auditoria histórica localizados. O problema de interpretar o phase map como isolamento de viés finito continua corretamente encaminhado aos Gates 2 e 4. Sua existência não torna a cobertura do procedimento de Delta já validada.

### Task 14 e os registros conflitantes

O inventário distingue PASS pré-execução, REPAIR externo, dois checkpoints e ausência de resultado integral verificável. A leitura independente do código atual corrobora os pontos registrados: `R/metrics.R:76-99` resume shifts finitos sem contagens dos pares efetivos; `:102-111` não exporta `n_acf_finite`; o runner calcula `validation` em `:157`, escreve outputs e manifesto de conclusão em `:171-204` e pode renderizar em `:284` sem exigir que todos os checks tenham passado.

Portanto, o tratamento documental do conflito é correto. Não bastaria apenas contar os pareceres PASS/REPAIR; aqui há confronto com os bytes atuais. O reparo e os testes executáveis desse código pertencem à etapa analítica correspondente, antes de reutilizar uma bateria completa. Nenhum teste R foi executado nesta revisão.

## 4. Limite do veredicto e sequência

O REPAIR incide na identificação do acervo, não nas controvérsias científicas já destinadas aos gates seguintes. Nesting/substituição, suficiência da história, relógios, hipótese com FE, identificação do efeito direto, inferência pareada e aplicação CET estão descritos com fidelidade suficiente para trabalho posterior.

**O Gate 1 poderá iniciar depois de corrigida T06 e revalidado o novo congelamento**, se nenhuma dependência material tiver mudado. As demais verificações desta rodada podem ser reaproveitadas pelos hashes correspondentes. O teste de Gate 1 deve avaliar ganho perante o comparador forte com a mesma informação causal/temporal e verificar aplicação elegível; o PASS documental não antecipa que essa contribuição exista.

Intuição para a retomada: a tabela de condições já responde quais pressupostos o baseline exige; o trabalho ainda aberto é tornar esses pressupostos e escolhas aplicáveis e avaliar o ganho científico. O inventário deve orientar esse trabalho a partir da tabela existente, sem recriá-la como se nunca tivesse sido produzida.

## 5. Executado e não executado

Executado pelo revisor: leitura dos 11 artefatos, inspeção integral das 26 linhas do inventário e das 21 respostas, comparação de hashes, parsing CSV/JSON, comparação dos valores com CSV fonte, aritmética de denominadores, conferência de mapeamentos, leitura localizada do código Task 14 e confronto com a leitura independente anterior.

Não executado: R, reestimação, bootstrap, Monte Carlo, novo PDF, revisão científica integral das provas, pesquisa bibliográfica do Gate 1, correção do inventário ou qualquer edição de artefato congelado. Escrita restrita a este relatório e ao JSON correspondente.
