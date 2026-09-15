# Gate 1 — confronto independente das aplicações, rodada 1

**Estado:** revisão concluída; achados candidatos à adjudicação do orquestrador. **Data:** 15/09/2026. **Escopo:** documentos em `gate_01/applications/`, confrontados com a Fase A congelada e fontes primárias das mesmas três candidatas. Nenhuma nova candidatura ou análise empírica.

## Resultado e revisão da posição anterior

**A seleção ainda não demonstra uma aplicação compatível com o efeito contemporâneo exigido pelo plano.** Essa conclusão permanece, mas uma parte da minha justificativa anterior deve ser corrigida: **Blair passa E5 no sentido documental do protocolo.** País, tempo e estrutura de dependência por unidade são identificáveis; a ausência de covariância agrupada adequada no modelo original pertence à avaliação de implementação e inferência do Gate 3. Não é, isoladamente, razão para `HOLD_DOCUMENTATION` em E5.

Também não transfiro para a ficha de Ballard-Rosa o achado da Fase A sobre crescimento do PIB. O implementador escolheu **crise inflacionária**, um contraste distinto. Conferido esse contraste, sua pertinência substantiva está sustentada; a documentação de sua frequência e janela de mensuração continua insuficiente para afirmar que `Z[t−2]` é história pré-exposição mensal e `Z[t]` é uma medida posterior a D adequadamente ordenada.

| Desenho efetivamente implementado | Conclusão literal E1–E7 sugerida nesta revisão | Compatibilidade adicional com o plano |
|---|---|---|
| Blair: mandato e ajuda externa | `ELIGIBLE_DOCUMENTARY`, com E5 PASS documental/risco; substitui minha avaliação anterior de E5 | Ainda falta demonstrar CET; `D[t−2] → Y[t]` documenta resposta futura |
| Ballard-Rosa: partidarismo e crise inflacionária | `HOLD_DOCUMENTATION`: E7 sem timing suficientemente documentado; justificativa de E3 precisa corrigir o alegado lag mensal admissível | Ainda falta demonstrar CET; `D[t−1] → Y[t]` documenta resposta no mês seguinte |
| Claassen: apoio e PIB per capita | `HOLD_DOCUMENTATION`, não `INELIGIBLE_DEMONSTRATED` por E7 | O desenho original assume ausência de efeito contemporâneo de apoio sobre democracia |

E3 verifica disponibilidade de alguma história, não fixa a ordem dos lags. Por isso, no caso Ballard-Rosa, a falha de justificativa de `t−2` não demonstra ausência de história mais antiga. Pode-se manter PASS de disponibilidade somente com uma rota documental para essa história, sem certificar o calendário proposto. A classificação HOLD já decorre de E7.

**Decisão recomendada:** corrigir a seleção e suas justificativas; não usar a classe literal de Blair como certificação de aplicação CET nem o FAIL incorreto de Claassen como exclusão demonstrada. A decisão de ampliar o alvo para efeitos futuros ou assumir uma rota descritiva pertence ao autor. Nesta rodada não há aprovação final de principal/reserva para a rota CET.

### Intuição

Uma revisão útil precisa corrigir tanto a implementação quanto o próprio parecer. Saber que o painel é de países permite planejar a dependência mesmo que a regressão original não a trate adequadamente. Ter uma crise registrada em uma tabela mensal, por outro lado, não prova que ela foi medida mensalmente: uma classificação anual pode ser repetida em todos os meses. E um controle que não é causado pelo tratamento pode continuar relevante como confundidor. Essas três distinções evitam criar exclusões artificiais e, ao mesmo tempo, impedem que uma janela temporal apenas renomeada seja apresentada como o efeito contemporâneo pretendido.

## Identidade e procedimento

Fase A preservada, com hashes reconferidos:

- Markdown: `ede8fb0848b7824c4d838c4fc38aa99e2d256617d3ca9224ea7e5d9771064045`.
- JSON: `0d1e147621c4f5a0012b3be60ff552c5dc7cf8414297a656b3d067f1379e2cbc`.

O artefato principal confrontado é `applications/selection.md`, SHA-256 `4495e71a10e1e9b1a884033c3af57eb9332f66ca76e3f968fda59640b7e34b18`. Os hashes das fichas, protocolos e demais documentos estão no JSON desta revisão. O protocolo confere com os digests de seu recibo. Hashes demonstram identidade de bytes; isoladamente não demonstram a cronologia da leitura.

Foram aplicadas as verificações de fonte, escopo e classificação da skill `adjudicate-review`. Os status abaixo expressam o parecer do revisor sobre cada proposição; **todos permanecem candidatos**, pois a adjudicação e o encaminhamento final pertencem ao orquestrador. O contrato operacional é o plano e o protocolo documental congelado, não um novo contrato de argumento do manuscrito.

## Achados

| ID | Status do revisor | Critério | Impacto |
|---|---|---|---|
| R1-F001 | CONFIRMED | E1/E2 + Gate 1 do plano | Seleção não estabelece correspondência com CET; exige correção antes de aprovar essa rota |
| R1-F002 | CONFIRMED | E3/E7 | Ficha Ballard-Rosa certifica calendário mensal de crise sem documentação suficiente; HOLD documental |
| R1-F003 | CONFIRMED | E7 e regra de classes | FAIL de Claassen excede as condições congeladas; substituir por HOLD |
| R1-F004 | CONFIRMED | Regra de informação proibida/cegamento | Concordância de revisão posterior não elimina influência possível da exposição inicial |
| R1-F005 | REFUTED | E5 | Retirar minha objeção de E5 a Blair; manter risco de inferência no Gate 3 |
| R1-F006 | CONFIRMED | E1/estimando | Ficha Ballard-Rosa alterna exposição a esquerda e passagem à esquerda; fixar intervenção e contraste |

### R1-F001 — Janela posterior não certifica CET

**Localizadores do artefato:** `candidate_blair_peacekeeping.md:18–23,28–33,69`; `candidate_ballard_rosa_debt.md:18–23,27–32,69`; `selection.md:5–8,16–18`; `protocol.md:19–20,38–44`. **Regra governante:** plano, linhas 124–127, especialmente a proibição de resolver a ausência de aplicação CET pela mudança de índice; §1 exige preservar efeito contemporâneo.

**Evidência primária:** Blair, pp. 1315–1317, usa mandato com dois anos de defasagem e controles com três; `replication.do:446` usa `ipema_any_demo_assist_dum_2l`. Ballard-Rosa, pp. 48–50 e nota 91, usa partidarismo do mês anterior; `IO replication.do:74–79` confirma. Claassen, pp. 15–17, distingue o efeito subsequente e exclui o contemporâneo, o que a própria ficha reconhece em E2.

O implementador descreve corretamente uma projeção de Y futuro nas duas primeiras fichas e reconhece limites causais. O problema específico é tratá-las como solução suficiente da exigência aplicada do plano. A ressalva de que a interpretação “contemporâneo/direto permanece condicional” (`Blair:23`) não define uma intervenção nem uma janela contemporânea. Além disso, efeito contemporâneo total e efeito direto são alvos distintos; condicionamento em ajuda atual não identifica automaticamente nenhum deles. Reindexar `s=t−2` deixa `Y[s+2]`; em Ballard-Rosa, `s=t−1` deixa `Y[s+1]`.

**Correção necessária:** declarar separadamente elegibilidade documental de uma comparação de projeções futuras e compatibilidade com CET. Exigir intervenção atual, janela de resposta e trajetória de tratamento durante a janela, sem confundir presença persistente de mandato/governo com nova adoção. Atualizar seleção/README/disposição e, se necessário, versionar o protocolo com a exigência omitida. Não transformar isso em `FAIL E2`, pois a ordem D→Y original está documentada. A escolha de redefinir o alvo científico requer decisão do autor.

### R1-F002 — Crise inflacionária: a ficha não documenta o calendário mensal alegado

**Localizadores do artefato:** `candidate_ballard_rosa_debt.md:13,20,29–32,40,44,53,57,66`; `selection.md:8,17,33`. **Fonte primária:** Ballard-Rosa, p. 49, nota 94, descreve controles anuais salvo indicação contrária; p. 50 afirma defasagem anual das medidas à direita exceto partidarismo e Treasury mensais. A crise inflacionária é definida como indicador de crise em curso, p. 49, e discutida substantivamente p. 57. No código, `crisis_inflation` aparece sem lag em `:67–79` e com `l.` nas interações `:111–123`.

O uso de `l.crisis_inflation` em um painel mensal mostra qual deslocamento de linha temporal o modelo pretende aplicar; não demonstra que o indicador foi originalmente medido por mês. Nas fontes lidas não há uma exceção documentada que transforme essa crise em medida mensal. Portanto, a ficha não pode afirmar simultaneamente “séries mensais de Y e crise” e história seguramente pré-exposição em `t−2`. O problema antecede a alegada falta de datas **dentro do mês**: falta reconciliar frequência e período de referência da própria medida. Se o indicador for anual repetido, `t−2` pode recuperar o mesmo ano de `D[t−1]`; `Z[t]` pode carregar informações de meses posteriores ao desfecho.

Isso não repete automaticamente minha crítica ao GDP. A conclusão sobre **crise** decorre das notas de mensuração do artigo e da discrepância entre a descrição e o código. Tampouco afirmo que a série real seja definitivamente anual: a documentação pode conter uma exceção em fonte ainda não apresentada. A parte substantiva de E7 é forte: preferências partidárias, inflação e risco percebido pelos credores estão conectados nas pp. 39–46,49,57. Falta o relógio que permite usar esses argumentos no contraste proposto.

**Correção necessária:** classificar E7 como falta documental; substituir certeza de pré-exposição de `Z[t−2]` por hipótese a verificar. Identificar a fonte original da crise, regra de início/fim e frequência, reconciliar atual/lag no script e texto. História anual mais antiga pode ser disponível; não declará-la impossível. Não inferir mediação somente por a crise estar registrada após o mês usado como D. Nenhum cálculo de transições ou shifts é necessário para esta correção documental.

### R1-F003 — Ausência de apoio→PIB não satisfaz o FAIL congelado de E7

**Localizadores do artefato:** `candidate_claassen_support.md:3–5,17,29,40–42`; `selection.md:10,18`; `archive_disposition.md:9`; `decision_log.md:9`; README, resultado. **Regra:** `protocol.md:25` e `protocol.json`, fail_rule E7, excluem Z apenas invariável, apenas pós-outcome ou alheio ao processo D–Y. A regra de HOLD cobre timing/papel não documentado.

**Fonte primária:** Claassen, p. 17, diz que desenvolvimento influencia apoio e democracia e assume ausência do sentido apoio→desenvolvimento. Equações 1–2 e `supdem_democracy_ajps_replication_correct.R:51–56` incluem o controle. Portanto, Z não é alheio ao processo. Também não há, nas fontes usadas, demonstração de que toda medida disponível de Z seja invariável ou pós-outcome.

A ausência da seta D→Z impede atribuir ao GDP um papel de mediador com base no DAG original, mas não implica a condição negativa usada para `INELIGIBLE_DEMONSTRATED`. O protocolo não exige que todo caso seja um exemplo positivo de tratamento causando o controle. O próprio plano pede situações de ausência de ganho e de ambiguidade. O estado sustentado é **HOLD_DOCUMENTATION para o contraste proposto**, mantendo em separado a incompatibilidade do CET não nulo com a hipótese contemporânea original. A mera ausência de seta não basta para aprovar E7 tampouco.

**Correção necessária:** trocar FAIL/inelegível por MISSING/HOLD e harmonizar os documentos. Reescrever o requisito de reabertura da linha 40: não impor como único caminho provar apoio→PIB ou escolher outro Z; também pode haver uma justificativa documental para caso de ausência de ganho/ambiguidade, com alvo e timing compatíveis. Não modificar o DAG original silenciosamente.

### R1-F004 — Repetição independente não elimina dúvida de influência anterior

**Localizadores:** `selection.md:37`, frase “Uma coincidência da rota sob essa repetição elimina a dúvida de influência”; `inspection_log.md:9–11,25`; `decision_log.md:20–22`; `protocol_freeze.md:3,14`.

Os documentos registram que o roster exibiu valores proibidos antes da elaboração/congelamento do protocolo; esse é o limite de evidência observado no próprio log, sem inferência de uso intencional dos valores. Uma escolha posterior concordante, feita sem esses números, reforça que há razões documentais independentes para aquela escolha. Não reconstrói o estado cognitivo inicial nem demonstra que informação vista não influenciou priorização, desenho do protocolo ou seleção. Hashes posteriores também não provam ausência dessa influência. O conjunto de três candidatas recebido pelo revisor já estava fixado, o que limita ainda mais a alegação de validação independente da seleção de todo o acervo.

**Correção necessária:** substituir por formulação como: “A repetição independente fornece evidência adicional sobre a sustentação documental da escolha; não elimina o comprometimento do cegamento inicial nem certifica ausência de influência dos valores vistos. Concordâncias e divergências serão preservadas e adjudicadas.” Registrar que o protocolo foi congelado antes da classificação, **mas depois do acesso incidental registrado**, sem rotular a rota inteira como estritamente pré-exposição a resultados. Preservar incidente e hashes. Não há aqui prova de seleção orientada por resultados; há um limite de certificação.

### R1-F005 — Reavaliação de Blair E5: minha objeção anterior foi excessiva

**Proposição revista:** a ausência de `vce(cluster)` no comando original justificaria `MISSING E5`. **Fontes:** `protocol.md:23,27,44`; `candidate_blair_peacekeeping.md:43,58,67`; `replication.do:35–45`; `indvar_separate_ctrls.ado:13,23`; artigo pp. 1315–1317.

O protocolo exige painel e nível de cluster/dependência identificáveis e deixa a adequação da inferência para depois. O país-ano, `gwnoloc`, e a estrutura intrapaís são identificáveis. A ficha não afirma que a covariância padrão já seja adequada: declara expressamente esse risco e a possível dependência entre missões/países. Exigir na triagem uma VCE já apropriada seria mais forte que o critério congelado. **Retiro a justificativa de HOLD por E5 da minha Fase A.** A implementação recebe PASS documental com risco nesse item. Isso não remove R1-F001 sobre CET, que é independente da covariância.

**Correção necessária:** registrar esta revisão da avaliação sem editar a Fase A congelada; conservar no Gate 3 a escolha de estrutura e método inferencial. Não confundir FE com cluster nem afirmar que o número de clusters é adequado sem avaliar a amostra.

### R1-F006 — Exposição partidária e transição para esquerda são intervenções distintas

**Localizadores:** `candidate_ballard_rosa_debt.md:11,18,32,41`; `selection.md:8`. **Fonte primária:** Ballard-Rosa, p. 48, define categorias direita/esquerda/centro-outros atualizadas por posse; `IO replication.do:74–79` usa níveis de categoria defasados, não um indicador de transição.

A expressão “passagem para/exposição a governo de esquerda” deixa dois alvos em aberto. O modelo de nível inclui meses de continuidade do governo e distingue esquerda e direita em relação a centro/outros. Não é automaticamente o efeito de uma nova entrada da esquerda, nem fixa um único contraste esquerda contra todos os demais. A data de posse disponível não converte o regressor em indicador de adoção.

**Correção necessária:** fixar exposição em exercício e o comparador partidário, ou declarar e justificar um redesenho de transição. Não condicionar o passado pela data do governo real e chamar isso automaticamente de história prévia à intervenção contrafactual. E1 passa para a exposição categórica original; o achado é de precisão do estimando proposto, sem provar inexistência de contraste.

## Limites, pontos já cobertos e verificações

As fichas já reconhecem adequadamente imputação por médias de todos os anos, lags por posição, seleção para meses com emissão, compatibilidade não automática de IV/GMM/Heckman com OLS, amostra comum e incerteza de mensuração. Não os reapresento como omissões novas. Os números de países citados no artigo não substituem contagens efetivas após construir a amostra. As demais candidatas do acervo não foram relidas nesta fase; sua disposição não é uma exclusão substantiva certificada por mim.

Executados: `rg --files`; `nl -ba`, `cat`, `sed` e `rg` nos documentos autorizados e nas fontes primárias já usadas; `shasum -a 256` de documentos e Fase A; gravação apenas de `review_round1.md/json`; leitura e validação documental do JSON. Não executei R, Stata, estatísticas sobre observações, regressões, shifts, bootstrap, simulações ou nova busca de candidatura. O quadro e o JSON usam os mesmos seis IDs e estados. Os hashes da Fase A continuam iguais.

**Encerramento:** há correções documentais delimitadas e uma decisão material de adequação ao estimando ainda pendente. Esta revisão não autoriza alterar o alvo do paper nem aprova o Gate 1. Relatório enviado ao orquestrador para adjudicação; fase encerrada para liberar a implementação das correções que forem aprovadas.
