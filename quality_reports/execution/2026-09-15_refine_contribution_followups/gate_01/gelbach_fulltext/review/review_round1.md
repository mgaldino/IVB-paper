# Gelbach integral: revisão independente, rodada 1 (Fase B)

**Data:** 15/09/2026. **Revisor:** `gelbach_full_review`. **Natureza:** confronto documental e matemático delimitado; findings candidatos sujeitos à adjudicação do coordenador.

## 1. Veredicto

**DOCUMENTATION_REQUIRES_LOCAL_CORRECTIONS.** A leitura e a incorporação são substantivamente fiéis nos pontos examinados. Há dois reparos documentais delimitados: tornar inequívoco que o acesso fortaleceu a atribuição bibliográfica de C+, sem ampliar retroativamente o comparador testado; corrigir um número de equação no adendo. Não foi identificado erro que reverta a equivalência no domínio OLS congelado ou que exija refazer os testes anteriores.

**`gate_approved: false`.** A revisão documental não aprova a contribuição científica nem escolhe outra rota. A pendência de acesso foi resolvida e a leitura integral do implementador está documentada; a incorporação pode ser fechada após adjudicação e verificação dos reparos locais. Nenhuma capacidade adicional de P ou aplicação CET foi demonstrada por esta complementação. A aplicação não foi novamente auditada: seu estado é o da decisão anterior.

| Resultado da revisão candidata | Quantidade |
|---|---:|
| CONFIRMED proposto | 1 |
| PARTIAL proposto | 1 |
| REFUTED proposto como finding separado | 0 |
| UNRESOLVED material | 0 |

Os dois findings são recomendações de classificação, não adjudicação final. A expressão “requer correções” se refere à clareza e precisão deste registro; não é uma exigência de reabrir outros gates.

## 2. Identidade, independência e cobertura

O freeze `review_input_freeze_round1.json`, SHA-256 `f150900bba2ac9a355f5ded9dc503d0fe04866fe2ab6a4cb84bbdbecc8942029`, foi conferido antes do confronto. Os **7 arquivos correntes** coincidem com os hashes recebidos e com suas **7 cópias em `snapshots/round1/`**. Os hashes de fonte PDF/texto/mapa, das seis entradas antigas enumeradas pelo manifesto e da decisão histórica também foram conferidos. Verificar um hash não significa reler o conteúdo inteiro desse arquivo.

A Fase A permaneceu intacta: `independent_source_read.md`, SHA-256 `c302572c55619d09ff38167e0829a3493637790021ba672cbf3b4fbcd6d4c28b`; seu freeze, SHA-256 `a402ead86fd4a4d5ac53ff97c0401cbdb44f1b2dd7021e09904119f29315cd6f`, registra conclusão em `2026-09-15T14:51:48.991385+00:00`, antes de abrir os novos produtos do leitor. Seu argumento foi usado como base independente, sem reescrevê-lo em função do confronto.

**Nesta Fase B foram lidos integralmente:** `reading/full_read_report.md`, `reading/page_coverage.csv`, `reading/claim_comparison.csv`, `reading/read_manifest.json`, `gelbach_addendum.md`, `review_scope.md` e o freeze de entrada. O PDF do adendo foi renderizado e visualizado nas **3/3 páginas**. Não foram encontrados cortes, sobreposições ou defeitos materiais de leitura; as equações da troca e da variância estão legíveis. O localizador incorreto de equação também consta na página 1 do PDF.

**Fonte científica, cobertura independente acumulada:** permanece a da Fase A, **pp.509–512 e 516–540 (29/35 páginas textuais)**; visual **pp.518, 521–524, 526, 528–529 e 532–535 (12 páginas)**. A p.518 foi reaberta visualmente nesta rodada para confirmar as eqs. (3) e (4), sem ampliar a cobertura. Não foram lidas independentemente as pp.513–515 e 541–543; não se afirma segunda leitura integral das 35 páginas. Os localizadores centrais foram confrontados com a fonte já lida e sua síntese anterior à exposição aos produtos novos.

**Cobertura do implementador:** as 35 linhas do CSV têm páginas de PDF 1–35 e impressas 509–543 em sequência, todas com leitura textual declarada. As 22 páginas visuais declaradas no CSV coincidem exatamente com o manifesto. A matriz contém L01–L17, sem lacunas ou duplicatas. Os hashes dos três outputs registrados pelo manifesto coincidem. Isso verifica a consistência e a proveniência do registro de leitura integral; não certifica que o revisor leu também as 35 páginas nem reproduz empiricamente as tabelas. Os enunciados de ausência sobre todo o artigo permanecem atribuídos à leitura integral do implementador, enquanto a revisão independente cobriu o desenvolvimento técnico pertinente.

## 3. Confronto substantivo

| Tema | Fonte primária e base independente | Produtos confrontados | Avaliação |
|---|---|---|---|
| Identidade OLS e sinal | Gelbach pp.518, 521–522, eqs.(3),(11); Fase A A01–A02 | Relatório §§2.2–2.3; matriz L01–L02; adendo §§2–3 | Correto: base menos completo em Gelbach; sinal inverso no IVB-paper; identidade amostral distinta do limite/projeção. Ressalva de localizador R1-GF002 abaixo |
| Auxiliares e grupos | pp.522–524, eq.(12), H por grupos; A03 | Relatório §2.4; matriz L03; adendo §3 | Correto: coeficientes do completo, auxiliares na base de cada comparação; aditividade não escolhe partição ou modelo causal |
| Duas bases da substituição | Aplicações separadas de (11); ficha v2 linhas 40–48; A03/§6 | Relatório linhas 17, 123, 195, 211; matriz L15; adendo linhas 39–58 | Correto: não atribui B/C/U como alocação única de Gelbach. O adendo explicita por que a base [D,W] e grupos [L,Z] definiriam componentes diferentes |
| Covariância cruzada da troca | Dedução a partir do sistema comum; ficha v2 linha 46; A05/§6 | Matriz L05 e L15; manifesto key_conclusions; adendo linhas 51–58 | Correto: a transformação [1,−1]V[1,−1]' é aplicação da equipe; não fórmula literal do artigo para duas bases distintas |
| Quatro termos inferenciais | pp.532–535, B1–B6; A05–A06 | Relatório §2.5; matriz L05; adendo linha 23 | Correto: considera coeficientes longos, auxiliares e termos cruzados; não usa o erro convencional da auxiliar como variância completa |
| Robust/cluster e regularidade | pp.524, 534–535; A06–A07 | Relatório linhas 93–95, 251; matriz L05 | Correto: a capacidade existe sob condições pertinentes; não é transformada em cobertura universal, fixed-T ou validade com poucos clusters |
| Degenerescência e cancelamento | nota 14 p.524; pp.525–527; A04/A07 | Relatório §§2.6–2.7; adendo linha 25 | Correto: origem do produto, cancelamento dentro e entre blocos são distintos; o pré-teste sugerido não é apresentado como garantia uniforme |
| Causalidade e timing | p.511 nota3, p.516 nota8, p.518, p.530; A08 | Relatório linhas 66–75, 125, 249–254; matriz L08–L09; adendo linha 27 | Correto no contexto: a formulação causal de Gelbach é registrada como dele e limitada expressamente; a decomposição não identifica DAG/efeito total. Timing não é retratado como irrelevante |
| IV/Hausman | pp.526–529, nota16, p.530; A09–A10 | Relatório §§2.8–2.9, 3.6 e linha249; matriz L07; adendo linha29 | Correto: exata identificação versus sobreidentificação, instrumentos fixos/válidos, nula de ortogonalidade distinta de produto zero; provas remetidas a 2009 não são declaradas auditadas |
| Oaxaca–Blinder e aplicações | pp.527–528, 535–538; leitura contextual A | Relatório §§2.9–2.10 | Síntese compatível; não foi auditada integralmente a prova do Apêndice C nem reproduzidas as tabelas. Nenhuma conclusão da decisão atual depende de validar aqui a replicação dessa extensão |
| Consequência científica | Plano Gate1, ficha v2 §§2–3/7/10, decisão histórica §§1–3 | Relatório linhas 17–19/225; adendo linhas15/64–68; scope | Correto: leitura remove dependência bibliográfica, preservando falta de ganho e de aplicação CET. A imprecisão sobre “fortalecer C+” é documental e está delimitada em R1-GF001 |

Não há finding contra a simples existência das extensões IV/Hausman ou a interpretação causal cuidadosa do relatório. Os limites escritos, lidos em conjunto, refutam essas possíveis objeções. Não se exige auditoria integral de Gelbach (2009), painel curto ou outros gates para fechar este complemento.

## 4. Findings candidatos

### R1-GF001 — Distinguir fortalecimento bibliográfico de ampliação retroativa de C+

**Classificação proposta:** `PARTIAL`. **Tipo:** `scope_or_consistency` / exposição da cronologia. **Severidade:** média para rastreabilidade, sem efeito demonstrado sobre a equivalência ou os testes. **Autor responsável:** leitor, nos próprios arquivos de `reading/`.

**Trechos e localizadores:**

- `reading/full_read_report.md:13`: “O comparador forte C+ fica mais forte depois desta leitura porque deve receber também”, seguido de alvo populacional, teoria de covariância, ressalva na origem, IV e cancelamento.
- `reading/full_read_report.md:155`: “acrescenta limites que precisam entrar no comparador”.
- `reading/full_read_report.md:157–164`: título “Alvo populacional mais forte que o registrado antes” e prescrição do que C+ “deve reportar”.
- `reading/full_read_report.md:201–207`: seção “Comparador C+ após a leitura integral”, “passa a ter cinco camadas explícitas”, seguida de pesos e instrumentos.
- `reading/claim_comparison.csv`, L17, campo `consequence_for_Cplus`: “C+ is strengthened”. L01, campo `change_or_limit`, diz que o texto integral acrescenta evidência publicada e um alvo populacional, sem delimitar que o acréscimo é de atribuição ao artigo.

**Parte sustentada do finding:** essas formulações, sobretudo a lista no resultado principal, permitem entender que se acrescentaram capacidades ao comparador após ver o resultado. A ficha v2, preservada no hash `37562f...`, já dá os mesmos momentos, alvo/relógio/hipóteses e especificações (§2; linhas18–28), OLS e auxiliares (§3; linhas40–48), covariância conjunta (linha46), degenerescência e equivalência de intervalos sem garantia de cobertura (§7; linhas132–134). Seu §10, linha158, declara literalmente “C+ já tinha essas capacidades” após descrever robust, cluster e covariância. A derivação antiga, hash `7038d7...`, linha9, explicita a versão populacional sob momentos finitos e matriz não singular. A nova fonte permite atribuir a Gelbach o alvo populacional, a nota14 e outros resultados que antes não estavam comprovados pelo artigo acessível; não acrescenta esses operadores à rotina congelada.

**Evidência que limita/refuta a versão ampla da acusação:** o mesmo relatório preserva a equivalência no domínio OLS (linhas17 e225), restringe IV a uma alegação futura (linha184) e chama a troca de construção derivada. A matriz L07 diz “If C+ is extended to IV”. O manifesto afirma equivalência da rotina congelada, e o adendo linhas15 e58 diz expressamente que o comparador já podia executar os resultados e já tinha permissão para obter a matriz conjunta. A ficha permanece com o mesmo hash. Assim, **não há evidência de alteração operacional pós-resultado, reexecução enviesada ou invalidação da conclusão anterior**. A parte confirmável é a ambiguidade interna na descrição da mudança, não uma violação científica já praticada.

**Correção proposta, segura e delimitada:** substituir as passagens centrais por uma afirmação inequívoca de fortalecimento da **base bibliográfica e da descrição do comparador já congelado**, preservando operações, domínios, dados e regras da v2. Nomear IV/Hausman como referências para **eventual comparação futura**, não capacidades acrescentadas ao teste OLS encerrado. As cinco camadas podem permanecer como explicitação do que já estava permitido; não é necessário redesenhar C+, recalcular outputs, rever a decisão negativa ou reescrever o relatório inteiro. Harmonizar a formulação compacta de L01/L17 e atualizar apenas hashes/manifesto derivados dos arquivos alterados.

### R1-GF002 — Número da equação populacional no adendo

**Classificação proposta:** `CONFIRMED`. **Tipo:** `artifact` / localizador. **Severidade:** baixa. **Autor responsável:** coordenador, `gelbach_addendum.md` e PDF derivado.

**Trecho:** `gelbach_addendum.md:21`, reproduzido em `gelbach_addendum.pdf`, **página1, §2, item1**: “As eqs. (4) e (11) estabelecem as versões populacional e amostral da decomposição”.

**Evidência:** na fonte, **p.518/PDF10**, a eq.(3) é `β1base = β1 + Γβ2 = β1 + δ`, a relação populacional de decomposição; a eq.(4) é `X2 = X1Γ + W`, a projeção auxiliar que define Γ. A eq.(11), p.521, é a identidade amostral. A p.518 foi reaberta visualmente nesta Fase B; a mesma distinção está na Fase A A01–A02. O número4 aponta para uma equação relevante à construção, mas não para a relação populacional que a frase atribui diretamente a ela.

**Correção proposta, segura e delimitada:** usar “eqs. (3) e (11)” ou “eqs. (3)–(4) e (11)”, explicando a auxiliar se mantiver (4). Regenerar o PDF do adendo e atualizar seus hashes. Nenhuma derivação ou conclusão substantiva precisa mudar.

## 5. Decisões preservadas e consequência do fechamento

A decisão histórica `decision.md`, hash `f4eb96cb79d35535d159e2e90ef14c5f387fe54a834d498a7b0eb16f911fd7b3`, registra equivalência, ausência de aplicação CET aprovada e pendência do Gelbach integral. O adendo cita de modo fiel a primeira e a segunda e atualiza a terceira. O exemplo numérico do adendo, B=C=1 e U=0,5, coincide com o registro histórico, linhas29–35. Foi feita **conferência documental**, sem nova execução analítica desses números.

Depois de adjudicados e, se aceitos, corrigidos os dois pontos acima, o fechamento pode dizer: **a fonte integral foi obtida e lida; a incorporação foi revisada; a atribuição dos resultados conhecidos ficou mais precisa; nenhuma capacidade adicional da rotina P foi demonstrada**. Não pode dizer que o novo acesso autorizou IV, resolveu inferência em painel curto, demonstrou cobertura uniforme ou decidiu a rota científica. As possibilidades futuras apresentadas no relatório continuam perguntas, não trabalho escolhido ou executado.

A fronteira entre revisão documental e `gate_approved` permanece explícita. A revisão não exige nova avaliação das três aplicações ou de toda a literatura já examinada; tais questões permanecem nas dependências e decisões antigas.

## 6. Verificações executadas e limites

- SHA-256 do freeze, sete produtos e sete snapshots; três arquivos da fonte; seis entradas antigas do manifesto; decisão histórica; dois registros da Fase A.
- Leitura dos seis produtos textuais e freeze especificados acima; confronto pontual adicional com ficha v2, decisão histórica e linha9/trechos pertinentes da derivação anterior.
- Validação mecânica dos CSVs: 35 páginas em ordem, mapeamento +508, 22 marcações visuais coincidentes, 17 claims L01–L17 sem duplicação; correspondência dos três hashes de output do manifesto.
- `pdfinfo` do adendo: 3 páginas A4; `pdftoppm -scale-to 1500 -png` para `/tmp/ivb_gelbach_review_round1/`; abertura visual das três páginas; reabertura da página518 já renderizada da fonte.
- O PDF do adendo contém, visualmente, o mesmo ponto de localizador registrado no Markdown. Não se executou reconstrução do PDF nem um diff de AST/extração integral entre Markdown e PDF; foi confrontado visualmente todo o conteúdo das três páginas.

Não executado: R, Stata, novas análises, bootstrap, nova coleta, Gelbach2009, reescrita do manuscrito, edição dos sete produtos, alteração do pacote antigo, commit/push ou escolha de rota. Os únicos arquivos escritos por esta Fase B são `review/review_round1.md` e `review/review_round1.json`, além das imagens temporárias permitidas. Os findings voltam ao coordenador para adjudicação; o revisor não implementou reparos.
