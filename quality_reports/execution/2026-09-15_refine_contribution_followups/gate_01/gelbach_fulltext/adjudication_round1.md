# Adjudicação da leitura integral de Gelbach, rodada 1

**Veredicto: READY_FOR_IMPLEMENTATION.** Dois reparos documentais: um CONFIRMED e um PARTIAL. Nenhum item material UNRESOLVED. O Gate 1 científico permanece não aprovado.

Pacote conferido: `review_input_freeze_round1.json`, SHA-256 `f150900bba2ac9a355f5ded9dc503d0fe04866fe2ab6a4cb84bbdbecc8942029`. Sete arquivos correntes e sete snapshots íntegros. Fonte primária: PDF SHA-256 `77392b7b09815f291f0ca55aa965786c59c4ca46a9ac1da44df0395dff96de2f`. Pareceres e seus hashes constam no JSON autoritativo.

O escopo é o complemento bibliográfico e sua síntese; não se substituiu o contrato do manuscrito nem a ficha v2. O coordenador relê as passagens citadas e confere a p.518 visualmente.

## R1-GF001: PARTIAL

**Finding preservado:** Separate stronger bibliographic support from retroactive strengthening of tested C+: O comparador forte C+ fica mais forte depois desta leitura porque deve receber também

**Evidência do defeito:** The tested v2 already provides exact/population moments, shared causal inputs, OLS/intermediates, joint covariance and origin-degeneracy limits. It states C+ already had robust/cluster/covariance capacities (line158). Previous derivation line9 supplies a population version. The new report is ambiguous about what was added after observing results.

**Evidência que limita a acusação:** Report lines17/225 preserve frozen OLS equivalence; line184 and matrix L07 qualify IV as a future scope. Addendum lines15/58 explicitly say C+ could already execute these operations. No operational change or biased rerun was found.

**Decisão:** A descrição admite leitura de mudança posterior das capacidades. A ficha v2 e o próprio contexto do relatório refutam mudança operacional efetiva. A correção deve esclarecer a atribuição bibliográfica sem alterar o teste.

**Encaminhamento seguro:** State bibliographic strengthening and clearer description of unchanged v2; qualify IV/Hausman as future comparison only; harmonize L01/L17 and update derived manifest hashes. Do not redesign or rerun tests.

## R1-GF002: CONFIRMED

**Finding preservado:** Correct population-equation locator in addendum: As eqs. (4) e (11) estabelecem as versões populacional e amostral da decomposição

**Evidência do defeito:** Source printed p518/PDF10 eq(3) gives beta1base=beta1+Gamma beta2=beta1+delta. Eq(4) gives auxiliary projection X2=X1Gamma+W; sample identity is eq(11) p521. Source p518 was visually rechecked.

**Decisão:** O número 4 localiza a auxiliar, não a relação populacional diretamente atribuída pela frase. A troca por 3 corrige a referência sem mudar a matemática.

**Encaminhamento seguro:** Use eqs(3) and(11), or eqs(3)-(4) and(11) with auxiliary meaning distinguished; rebuild addendum PDF and update hashes.

## Autoria, autorização e nova revisão

R1-GF001 volta ao leitor, somente em `reading/`, preservando cobertura e ficha v2. R1-GF002 será implementado pelo coordenador no Markdown do adendo e no PDF derivado. Os bytes anteriores estão em `snapshots/round1/`. O revisor verifica os novos arquivos; não implementa reparos.

Nenhuma análise ou nova rota é necessária para esses reparos. A implementação interna já foi autorizada pelo usuário. A escolha científica posterior continua reservada ao autor, conforme o encerramento do Gate 1 no plano.

Contagens: CONFIRMED 1; PARTIAL 1; REFUTED 0; UNRESOLVED 0. A parte ampla de GF001 (alteração efetiva do comparador) é refutada dentro da classificação PARTIAL; não é contada novamente como outro finding.
