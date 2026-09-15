# Revalidação documental do Gate 0

**Escopo:** revalidar a identidade, a cobertura e o conteúdo do contrato argumental e da adjudicação do parecer Refine antes de qualquer correção do manuscrito ou execução analítica.

**Base Git solicitada e observada:** `731cd6570651ea0f602d5c7cdff89ab43ecdb962`.

**Contrato reutilizado:** `ivb-pa-refine:5375d3c27ac1:round1`.

**Adjudicação reutilizada:** `ivb-pa-refine:5375d3c27ac1:round1`.
**Resultado:** os bytes governantes continuam idênticos aos da preparação. O contrato continua adequado como restrição anti-strawman para o escopo do Gate 0 e a adjudicação dos 17 comentários primários continua sustentada pelos localizadores relidos. Os quatro eixos do follow-up foram acrescentados à matriz como unidades de resposta mapeadas a findings existentes. Este resultado é documental e interpretativo; não certifica novidade, identificação, inferência, validade de simulações, qualidade editorial ou publicação.

## 1. Identidade dos artefatos

| Entrada | SHA-256 observado | Relação com a preparação |
|---|---|---|
| `ivb_paper_pa.pdf` | `5375d3c27ac1b75ca7246f0e7483470d98a69cf129a853560ae84cfe107d447c` | Igual ao manifesto e ao contrato |
| `ivb_paper_pa.Rmd` | `12493a67133f988c5e6a13933bf2b89c0d9880e96bae329248a207b3aeaf7b5e` | Igual ao manifesto e ao contrato |
| `derivations/adl_cet_identification_conditions.Rmd` | `f67b41089d49018dc2c1b3a6cd80ce49b67dee771df75bdf72953d9a5e64db70` | Igual ao manifesto e ao contrato |
| `derivations/multivariate_specification_shift.Rmd` | `551d6e46a7a8332e47fc5cccf81b5a52c2058941bee1f88ce5c38fdd97386d64` | Igual ao manifesto e ao contrato |
| `derivations/specification_shift_uncertainty.Rmd` | `317b7a81101a75e60ad3c9466500106878dd3b84dfc48f05722517699fbed963` | Igual ao manifesto e ao contrato |
| `derivations/shift_allocation_correlated_controls.Rmd` | `ac3796a2d67dc08c759c7923d827b70656f7c57dbacbe22a27cadd8d6f49af09` | Igual ao manifesto e ao contrato |
| `refine_feedback_original.md` | `f4e87230957a62bc52cae799d8f32fd8baa2e1cbe7ced2b25d74ec9ece5a89be` | Igual ao manifesto |
| `refine_followup_from_chat.md` | `c055d75e3a62e1b3d68ff22b9236a0e552fc59695eeae282214ec9138260a738` | Preservado; não constava da lista `files` do manifesto |
| `argument_contract.json` | `a85ea8096d4a5044eed1c6993cdcf82ec83b29a783f27dc989e1771afe7709d7` | Preservado e validado |
| `adjudication_round1.json` | `b10b0adbb146773541331c50869c6e0a10953475de0069e6c61a8299c3f14737` | Preservado e validado |
| `baseline_manifest.json` | `0f7b738c809e3e11426b423c17ed4662d67fb503b58b88b51102d8968803c3c5` | Manifesto desta execução |
| `plan.md` | `d2d2ea2e39102ab4193ee2f82b12b0823143867a23750c38d626aa4797eb7f5d` | Plano governante |
| `CLAUDE.md` | `972801f84080ad8cad5c4f86400bc35ee8858dee4795841ee62306204ad68648` | Instruções do repositório |

O PDF tem 22 páginas e 8.247 palavras no texto extraído. Não existe recibo com hash do arquivo enviado ao Refine; a conclusão de identidade limita-se ao PDF local. As citações textuais do parecer correspondem materialmente a esse PDF e ao Rmd.

### Classificação de impacto

`same_bytes`: não houve mudança no PDF, no Rmd nem nas quatro derivações governantes desde o contrato. Por isso, não se cria novo `contract_id` e não se substitui o contrato anterior. A revalidação conferiu identidade, cobertura, localizadores e conflitos locais. A pasta original do contrato e a pasta original da adjudicação permanecem intactas.

## 2. Conferência dos sete registros de seção

| Seção | Registro e SHA-256 | Identidade declarada no registro | Identidade no contrato | Cobertura verificada | Decisão de reutilização |
|---|---|---|---|---|---|
| S01 Introduction | `section_01_introduction.md`; `fd60651ffccfe102c816de574f63507ee74a9858d3e78dd986430f1f624c1adc` | `reader-introduction` | `read_timing, turno reader-introduction` | Rmd 178–195; PDF 1–3; tese, claims, não-afirmações e promessa sobre aplicações | Reutilizado; preservar a discrepância entre ID de turno e ID composto |
| S02 Control problem | `section_02_control_problem.md`; `59ab40facbc313e4a1edda6eba99ed494ec5da38ed8e580c41cbe1abf8221aa7` | `reader-control-problem` | `read_simulations, turno reader-control-problem` | Rmd 196–207; PDF 3–4; alvo CET, papéis possíveis e limites | Reutilizado; preservar a discrepância entre ID de turno e ID composto |
| S03 Timing | `section_03_timing.md`; `73cbc7602a8dce9d458a7a39cb541b41c01843b86613160cce2bc45acc283103` | `read_timing` | `read_timing` | Rmd 208–386; PDF 4–7; CET, dois relógios, tabelas, DAGs, ambiguidades | Reutilizado |
| S04 Diagnostic | `section_04_diagnostic.md`; `5a9d1e2e872af5b2d7c3738c94d8986cea5451587e54cc93e07a5c3a99ec1f2a` | O cabeçalho não contém `reader_id` | `read_diagnostic` | Rmd 387–502; PDF 8–12; FWL, múltiplos controles, inferência, identificação e derivações | Reutilizado; identidade do leitor é comprovada apenas pelo contrato, não pelo próprio registro |
| S05 Simulations | `section_05_simulations.md`; `b4a0324c3ac1c6dceb16cad5ca91a6a5176ede863e0b510cb27e9f99bc7b5439` | `read_simulations` | `read_simulations` | Rmd 503–643; PDF 12–18; Figuras 3–5, Tabelas 4–6, workflow e limites | Reutilizado |
| S06 Applications | `section_06_applications.md`; `153d70d421c10a69ef9ca6ab2018a991f461dae92fe066e3833c874fd3dc08cb` | `read_applications` | `read_applications` | Rmd 644–823; PDF 19–21; universo 14/6, dois estudos, cinco linhas e três comparações extras | Reutilizado |
| S07 Conclusion | `section_07_conclusion.md`; `4047793d21036935c5602a9e359338a6cf273946c1921711bea2bf5bcfbf6f92` | `read_applications` | `read_applications, turno conclusion` | Rmd 824–832, com referências em 834–836; PDF 21–22 | Reutilizado; a leitura substantiva termina em 832 |

Há sete arquivos e cobertura contínua das sete seções substantivas. Os records não demonstram sete contextos independentes: o próprio contrato informa quatro agentes reutilizados em turnos. As inconsistências de rótulo de S01, S02 e S04 são limitações de proveniência do leitor, não lacunas na cobertura textual. Nenhum conteúdo foi atribuído a um agente diferente daquele registrado.

## 3. Contrato revalidado

### Tese, pergunta e contribuição reivindicada

- **Tese:** mudanças entre regressões lineares aninhadas podem ser quantificadas exatamente; sua interpretação causal requer estimando, relógio temporal, DAG e identificação defendidos.
- **Pergunta:** quanto a inclusão de um controle potencialmente responsivo ao tratamento move o coeficiente e quando uma especificação dinâmica pode servir de comparação para o efeito contemporâneo do tratamento (CET)?
- **Contribuição reivindicada:** organização diagnóstica da identidade FWL e uso condicional de ADL + efeitos fixos como baseline do CET em TSCS linear. A distinção em relação à literatura existente permanece uma hipótese a testar no Gate 1.

### Claims centrais e localizadores

| ID | Claim revalidado | Força e escopo | Localizadores governantes |
|---|---|---|---|
| C01 | O deslocamento amostral entre regressões lineares aninhadas satisfaz exatamente `Delta_hat = beta_hat_L - beta_hat_S = -theta_hat*pi_hat`; IVB é uma interpretação causal restrita. | Identidade de OLS; não identifica causalidade. | Rmd 184–190, 389–420, 826; `multivariate_specification_shift.Rmd` 48–211 |
| C02 | O shift conjunto é único; incrementos sequenciais telescopam mas dependem da ordem; leave-one-out não soma necessariamente ao total; Shapley é alocação de projeção. | Modelos aninhados e mesma amostra; não é decomposição causal. | Rmd 408–422; `multivariate_specification_shift.Rmd` 213–334, 488–494; `shift_allocation_correlated_controls.Rmd` 25–67, 243–247 |
| C03 | O relógio substantivo, e não o subíndice, determina papéis candidatos; um lag não é automaticamente pré-tratamento ou admissível. | Condicional ao CET, ao DAG e às janelas documentadas. | Rmd 214–275, 277–385; Tabelas 1–2; Figuras 1–2 |
| C04 | A projeção populacional ADL + FE pode coincidir com um CET linear homogêneo sob história suficiente e condições explícitas. | Resultado populacional condicional; não garante ausência de viés within em T finito. | Rmd 457–501, 828; `adl_cet_identification_conditions.Rmd` 26–110, 113–208 |
| C05 | Nos DGPs exibidos, modelos com estados relevantes apresentam os contrastes numéricos descritos; confounding contemporâneo omitido permanece uma falha. | Evidência numérica delimitada aos grids e especificações exibidos. | Rmd 503–642; Figuras 3–5; Tabelas 4–6 |
| C06 | A incerteza do shift deve preservar a covariância entre estimadores; bootstrap por unidade e sandwich empilhado são procedimentos propostos de escopo restrito. | Ainda sem calibração aplicada; unidade de reamostragem exige hipótese de dependência adequada. | Rmd 424–438; `specification_shift_uncertainty.Rmd` 37–100, 142–214, 260–264 |
| C07 | As aplicações atuais são diagnósticos descritivos com timing ambíguo para contrastes defasado e prospectivo. | 14 candidatos em seis estudos; exposição detalhada de dois estudos, cinco linhas, das quais três são adicionais em Rogowski; sem CET direto ou IC pareado. | Rmd 141–174, 644–823; Tabelas 7–8 |
| C08 | O resultado desenvolvido limita-se ao diagnóstico e ao baseline condicional em TSCS linear. | Sem resultados para SDiD, fatores, regimes, links não lineares gerais ou efeitos acumulados. | Rmd 444, 824–832 |

## 4. Objetos estatísticos e causais

| Objeto | Definição revalidada | O que não pode ser confundido | Localizador |
|---|---|---|---|
| `beta_hat_S`, `beta_hat_L` | Coeficientes amostrais de tratamento em modelos curto e longo aninhados | Podem mudar também por amostra, pesos ou regressoras comuns se o desenho não for mantido | Rmd 391–406; nota de incerteza 54–81 |
| `Delta_hat_Z` | Diferença pareada `beta_hat_L-beta_hat_S` | Não é automaticamente viés causal nem teste estatístico | Rmd 389–406, 424–438 |
| `theta_hat`, `pi_hat` | Inclinação de Z no modelo longo e inclinação de D na auxiliar de Z | Sinais e produto não classificam causalmente o controle | Rmd 398–406, 442 |
| `Delta_hat_mathcalZ` | Shift conjunto para vetor de controles | Coordenadas e alocações podem depender da base e da ordem | Rmd 408–422; derivação multivariada 488–494 |
| Incremento sequencial, LOO, Shapley | Três diagnósticos de atribuição diferentes | Apenas o caminho sequencial telescopa; Shapley é convenção de alocação, não mecanismo causal | derivação multivariada 213–334; nota de alocação 25–67 |
| `Delta_Z` populacional | Contraste entre coeficientes de projeção populacionais em modelos definidos | Não se identifica pela média de um contraste amostral sem separar viés dos estimadores | Parecer D08; plano Gate 2, linhas 136–145 |
| `beta_D^P` | Coeficiente de projeção populacional após residualizar D pela história e FE | Diferente do limite ou viés do estimador within com T fixo | Rmd 467–477; nota de identificação 101–208 |
| `beta_CET` e `tau_CET` | Inclinação constante ou contraste causal de `Y_it(d)-Y_it(d')` dado o estado pré-exposição | CET total inclui vias mediadas, salvo alvo direto explícito | Rmd 214–238; nota de identificação 26–53 |
| CET total versus efeito direto | Alvos distintos quando `Z_t` é mediador | Um DAG de mediação não basta para identificar o coeficiente longo como efeito direto | Rmd 315, 441; parecer D09 |
| História `H^-_it` | Informação e estados fixados antes da primeira exposição relevante | Um vetor calendário `H_i,t-1` não comprova anterioridade nem suficiência | Rmd 214, 457; nota de identificação 30–42 |
| Relógio do mediador | `H^- -> D_t -> Z_t -> Y_t+` | Não governa automaticamente o collider | Rmd 222–238 |
| Relógio do collider | Processo de `Y_t` anterior à mensuração de `Z_t`, com `D_t -> Z_t <- Y_t` | Precisa ser distinguido do outcome terminal do CET | Rmd 238; parecer D05 |
| Intervalo pareado do shift | Incerteza de um contraste entre estimadores dependentes | Diferente de IC do CET, SE de endpoint e intervalo Monte Carlo da média | Rmd 424–438; nota de incerteza 142–214 |
| Cobertura 0,700 | Cobertura empírica de `long` contra `beta_CET` no grid da Figura 5 | Não é cobertura de IC para `Delta_Z` | Rmd 583–589; `metrics.R` 54–89; `simulation.R` 70–111 |
| Ratios de aplicações | `abs(Delta_hat)/SE(beta_hat_long)` e `abs(Delta_hat)/abs(beta_hat_long)` | O primeiro é escala de endpoint, não teste ou incerteza pareada | Rmd 698–732, 799–822 |
| Contrastes aplicados | Leipziger: `D_(t-1) -> Y_t`; Rogowski: estoque `D_s -> Y_(s+1)` | Nenhum é demonstração direta do CET `D_t -> Y_t` | Rmd 650, 736 |

## 5. Hipóteses e fronteiras necessárias

1. **Álgebra:** OLS sem pesos, posto completo, mesmas observações, mesmos regressores comuns e nesting por adição; Rmd 408–420 e `multivariate_specification_shift.Rmd` 182–211. Mudanças de amostra, pesos ou regressoras quebram a identidade aplicada ao contraste pretendido.
2. **História e relógio:** `H_i,t-1` deve estar contido em `H^-_it`, fechar antes da exposição e ser suficiente para assignment e média condicional; Rmd 214–275, 457–465 e nota de identificação 30–42, 59–61.
3. **Identificação causal:** consistência, ausência de interferência relevante, ausência de antecipação, exchangeability média sequencial condicionada em `D_it, H^-_it, alpha_i, tau_t`, recursividade intraperíodo e suporte; nota de identificação 55–99. A prosa abreviada do Rmd 465 omite `alpha_i,tau_t` no enunciado da exchangeability.
4. **Modelo do outcome:** média condicional dinâmica corretamente abrangida, aditividade, linearidade e homogeneidade quando um coeficiente deve representar um CET comum; Rmd 457–477 e nota de identificação 75–86.
5. **FE e rank:** FE absorvem apenas heterogeneidade unitária aditiva invariável e choques comuns aditivos; variância residual de D deve ser positiva e finita. Rank não substitui positivity; Rmd 467–496 e nota 88–99.
6. **Estimação:** a igualdade populacional não implica unbiasedness do within em T fixo; lags e tratamento predeterminado podem gerar viés tipo Nickell; Rmd 501 e nota 103–110, 188–208.
7. **Inferência:** reamostragem de unidades requer unidades independentes ou dependência suficientemente fraca entre elas, número de clusters adequado e desenho correspondente. FE de tempo não garante isso; nota de incerteza 83–100, 142–178, 260–264.
8. **Mediação:** timing, exchangeability, suporte e hipóteses de mediação/forma funcional são adicionais ao DAG para interpretar o shift como passagem de efeito total para direto; Rmd 315 e conflito local em 441.
9. **Aplicações:** timestamps, janelas de exposição e outcome, tratamento bem definido, mesma amostra, dependência e inferência precisam ser defendidos para cada caso; Rmd 629–642, 646–822.

## 6. Conflitos locais confirmados na releitura

| Conflito | Evidência dos dois lados | Consequência para a matriz |
|---|---|---|
| Inclusão aninhada versus substituição | Proposição 1 exige mesmos regressores comuns (408–420); “moved from ... lagged-state ... into contemporaneous” (451) e workflow 635–637 não dizem se o lag permanece | G2/D11 e FU4 permanecem `CONFIRMED`; solução requer desenho dos modelos, não troca automática de palavras |
| Exchangeability abreviada versus prova completa | Rmd 465 condiciona verbalmente apenas em `H^-`; derivação 63–71 inclui `alpha_i,tau_t` | D06 permanece `PARTIAL`: defeito local de consistência, não ausência global da condição |
| “Only the DAG” versus condições adicionais | Rmd 315 condiciona efeito direto a hipóteses adicionais; Rmd 441 diz “Only the DAG” | D09 permanece `PARTIAL`; transportar qualificadores e revalidar a cadeia |
| Outcome terminal versus processo anterior do collider | Rmd 222 diz “after ... any within-period responses”; Rmd 238 exige processo de Y anterior a Z no collider | D05 permanece `PARTIAL`; dois relógios existem, mas os objetos não estão formalmente distinguidos |
| Figura 4 versus collider contemporâneo | Caption/modelos em 551 não contêm `Z_t`, embora o DGP tenha collider atual | D07 permanece `CONFIRMED`; a figura não testa IVB por inclusão do collider contemporâneo |
| “Isolates finite-T” versus objetos comparados | Rmd 583 compara viés de long, mean shift e cobertura de long; não decompõe `E[Delta_hat]=Delta^P+b_L-b_S` | D08 permanece `CONFIRMED` |
| Timing conhecido pós-tratamento ausente da regra | Tabela 1, Rmd 250, oferece “plausible or ambiguous”; Rmd 275 reconhece timing conhecido por janelas não sobrepostas | D10 permanece `CONFIRMED` como lacuna local da taxonomia |
| Proximidade na Tabela 6 | 1,023 e 1,016 ficam a 0,007 e 0,014 de 1,03, e a 0,023 e 0,016 de 1,00 | D12 permanece `CONFIRMED`; “near direct” não está estabelecido para ambas as linhas sem incerteza |
| Universo das aplicações | Código 141–149 seleciona 14 candidatos; Seção 6 detalha dois estudos e Tabela 8 inclui três controles de Rogowski fora da seleção | D03 permanece `PARTIAL`; amostra intencional é reconhecida, mas universo e denominador do superlativo não estão expostos |

## 7. Cobertura do Refine e do follow-up

`response_matrix.csv` e `response_matrix.json` contêm 21 unidades de resposta:

- cinco comentários gerais: `R1-G1` a `R1-G5`;
- 12 comentários detalhados: `R1-D01` a `R1-D12`;
- quatro eixos do follow-up: `R1-FU1` a `R1-FU4`.

Os 17 IDs primários foram preservados sem alteração. Os eixos do follow-up receberam IDs novos e estáveis porque a adjudicação original os mencionava apenas em prosa. Eles são mapeados, respectivamente, a `R1-G1`, `R1-G5/R1-D02`, `R1-G3` e `R1-G2/R1-D11`. Portanto, 21 linhas de resposta não significam 21 defeitos independentes. A previsão editorial de que o paper poderia se tornar uma contribuição forte não recebeu status de finding: é prognóstico, não alegação verificável nos bytes atuais.

Contagem das 17 adjudicações primárias preservadas: 7 `CONFIRMED`, 10 `PARTIAL`, 0 `REFUTED`, 0 `UNRESOLVED`. As quatro linhas mapeadas do follow-up repetem três diagnósticos `PARTIAL` e um `CONFIRMED` sem alterar essa contagem única.

## 8. Checks do gate interpretativo

| Check | Resultado | Evidência |
|---|---|---|
| Hash do artefato | Satisfeito | PDF, Rmd e derivações iguais ao manifesto e ao contrato |
| Cobertura das seções | Satisfeito | Sete registros cobrem S01–S07; localizadores relidos |
| Claims e âncoras | Satisfeito para fidelidade | C01–C08 preservados com localizadores |
| Objetos e camadas | Satisfeito para fidelidade | Projeção, estimador, shift, viés, CET e intervalos separados acima |
| Não-afirmações e escopo | Satisfeito | Contrato preserva limites sobre causalidade, aplicações e extensões |
| Ambiguidades materiais | Visíveis e roteadas | Conflitos locais mantidos na matriz; não foram eliminados por inferência de intenção |
| Cobertura dos comentários | Satisfeito | 5 gerais + 12 detalhados + 4 follow-up |
| Proveniência dos leitores | Parcialmente documentada | Cobertura íntegra; IDs de S01/S02 diferem e S04 não os declara no record |
| Validade científica | Não avaliada | Fora do Gate 0 desta tarefa |

O contrato preserva seu `PASS` exclusivamente como PASS de fidelidade para planejar e revisar a mesma versão. Este relatório não declara PASS científico e não altera o estado global do Gate 0; deve ser conferido pelo revisor independente previsto.

## 9. Comandos executados e resultados

Artefatos congeláveis desta revalidação, antes da revisão independente:

| Saída | SHA-256 |
|---|---|
| `response_matrix.csv` | `46637a6a02e7181f4ee652ed0ea2dda799266068245bb679654c06525f96f847` |
| `response_matrix.json` | `d5586e38d4de98ec9270e44e04a4aa597f58681857ac182545174d85fd334585` |

O próprio `revalidation.md` não incorpora seu hash para evitar autorreferência; seu hash deve ser calculado pelo manifesto ou revisor que congelar o conjunto.

```text
git rev-parse HEAD
# 731cd6570651ea0f602d5c7cdff89ab43ecdb962

git status --short
# ?? quality_reports/execution/

git diff --stat 731cd6570651ea0f602d5c7cdff89ab43ecdb962 -- <fontes governantes>
# sem diferenças rastreadas

shasum -a 256 <entradas listadas nas seções 1 e 2>
# hashes registrados neste relatório

pdfinfo ivb_paper_pa.pdf
# Pages: 22; file size: 513101 bytes

pdftotext -layout ivb_paper_pa.pdf - | wc -w
# 8247

python3 /Users/manoelgaldino/.codex/skills/argument-fidelity-gate/scripts/validate_contract.py quality_reports/argument_contracts/ivb-pa-refine/5375d3c27ac1/argument_contract.json --artifact ivb_paper_pa.pdf
# VALID: .../argument_contract.json

python3 /Users/manoelgaldino/.codex/skills/adjudicate-review/scripts/validate_adjudication.py quality_reports/adjudication/ivb-pa-refine/5375d3c27ac1/adjudication_round1.json --artifact ivb_paper_pa.pdf --contract-file quality_reports/argument_contracts/ivb-pa-refine/5375d3c27ac1/argument_contract.json
# VALID: .../adjudication_round1.json

python3 -m json.tool quality_reports/execution/2026-09-15_refine_contribution/gate_00/revalidation/response_matrix.json
# JSON válido

python3 -c '<comparar CSV/JSON e a adjudicação preservada>'
# VALID matrix: 21 rows; IDs/status/order agree; 5 general + 12 detailed + 4 followup
# VALID preservation: 17 primary IDs and statuses equal adjudication_round1

git diff --check -- quality_reports/execution/2026-09-15_refine_contribution/gate_00/revalidation
# sem erros
```

Também foram relidos `CLAUDE.md`, o plano integral, o parecer original, o follow-up, o manuscrito nas sete seções, os sete section reads, o contrato, a adjudicação e as passagens pertinentes das quatro derivações.

## 10. Não executado

- Nenhum script R, bootstrap, simulação, reestimação, teste analítico do paper ou renderização foi executado.
- Nenhum arquivo do manuscrito, derivação, código, contrato ou adjudicação original foi editado.
- Nenhuma correção proposta na matriz foi implementada.
- Nenhuma busca bibliográfica integral, avaliação de novidade, seleção de aplicação ou decisão editorial foi realizada.
- Não foi tentado reconstruir a identidade dos quatro leitores além do que os records preservados documentam.

## 11. Pendências e critério de encerramento desta revalidação

A revalidação fica pronta para revisão independente quando: (i) CSV e JSON contêm as mesmas 21 unidades e IDs; (ii) os 17 status primários coincidem com a adjudicação preservada; (iii) cada linha separa diagnóstico e solução, explicita gate, dependências e critério de encerramento; (iv) os arquivos passam validação estrutural; e (v) o diff permanece restrito a esta pasta.

Pendências substantivas seguem para os gates indicados na matriz. Em especial: contribuição incremental e comparador forte (G1); objetos matemáticos, nesting e relógios (G2); história e inferência executáveis (G3); calibração e simulações (G4); aplicação central e universo empírico (G5); exposição (G6); e revisão científica/reprodutibilidade (G7). Nenhuma delas foi resolvida pela revalidação documental.
