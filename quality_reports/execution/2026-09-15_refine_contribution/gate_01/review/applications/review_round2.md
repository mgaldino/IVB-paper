# Gate 1 — revalidação documental das aplicações, rodada 2

**Veredicto: PASS de integridade documental dos reparos adjudicados.** Os seis itens da rodada 1 foram tratados corretamente, os documentos dependentes apresentam a mesma decisão e os manifestos correspondem aos bytes entregues. **Esse PASS não aprova uma aplicação CET e não conclui o Gate 1.**

Revisor: `gate1_application_review`. Data: 15/09/2026. Escopo: pacote corrigido `gate_01/applications/`, seus manifestos, registros históricos e correspondência com a adjudicação da rodada 1. Nenhuma nova candidatura ou análise empírica.

## Identidade do pacote

Manifesto revisado: `applications/manifest_round2.json`.

SHA-256 recebido e reconferido: `ea3140977b67f4d6a485a8ed9be8ac255d1e7743e11d7ef8c6bc801acc32ffe0`.

A revisão verificou os **14 artefatos** enumerados pelo manifesto, a completude do inventário de arquivos correntes, os hashes das **25 fontes** enumeradas no CSV, as duas bases de reparo, o manifesto do snapshot e os **12 arquivos da rodada inicial**. Os hashes históricos também foram comparados aos digests registrados independentemente em `review_round1.json`, e não apenas ao manifesto produzido para o snapshot. Não houve divergência.

O protocolo v1 e seu recibo continuam byte a byte iguais aos arquivos congelados e ao snapshot. A Fase A e os dois arquivos de revisão da rodada 1 também permanecem intactos. As classificações anteriores estão preservadas como história substituída, sem serem apresentadas como decisão corrente.

## Resultado aplicado preservado

| Candidata | Classe literal E1–E7 | Adequação CET | Papel CET aprovado |
|---|---|---|---|
| Blair: mandato e ajuda externa | `ELIGIBLE_DOCUMENTARY` | `NOT_ESTABLISHED` | nenhum |
| Ballard-Rosa: esquerda em exercício versus centro/outros; crise inflacionária | `HOLD_DOCUMENTATION`, E7 `MISSING_TIMING` | `NOT_ESTABLISHED` | nenhum |
| Claassen: apoio e PIB per capita | `HOLD_DOCUMENTATION`, E7 `MISSING_NOT_FAIL` | Premissas originais excluem efeito contemporâneo de apoio | nenhum |

A mesma matriz aparece em `README.md:7–15`, `selection.md:15–21`, `archive_disposition.md:5–12`, `repair_round2.md` e no adendo CET. As três fichas mantêm os campos separados. A possibilidade de uma busca adicional e a rota descritiva/futura são opções ainda não escolhidas; não foram ativadas nesta correção.

## Verificação item por item

| Achado e adjudicação anterior | Reparo observado | Resultado |
|---|---|---|
| R1-F001 — CONFIRMED | As fichas distinguem resposta futura e CET; a seleção não confere papel principal/reserva a nenhuma candidata; o adendo explicita que mudar a origem dos índices não muda o horizonte físico | PASS |
| R1-F002 — CONFIRMED | Ballard-Rosa é HOLD por timing da **crise inflacionária**, com pertinência substantiva preservada; frequência mensal e história `t−2` não são presumidas | PASS |
| R1-F003 — CONFIRMED | Claassen é HOLD, não FAIL afirmativo de E7; PIB continua parte do processo como confundidor, e a ausência de apoio→PIB não é tratada como irrelevância causal | PASS |
| R1-F004 — CONFIRMED | Os logs registram exposição incidental antes do protocolo; a revisão posterior não elimina influência possível nem valida a seleção de todo o acervo | PASS |
| R1-F005 — REFUTED | Blair permanece com E5 PASS documental/risco; minha objeção anterior foi expressamente retirada, sem certificar a adequação da inferência | PASS |
| R1-F006 — CONFIRMED | Ballard-Rosa fixa categoria em exercício, esquerda versus centro/outros; separa o contraste de direita e explica que posse datada não converte o regressor em nova transição | PASS |

### R1-F001: campo CET posterior, sem reescrever o protocolo

`candidate_blair_peacekeeping.md:18–30,46–53,69–74` separa projeção futura, alvo causal e covariância. `candidate_ballard_rosa_debt.md:31–35,48` mantém a resposta no mês seguinte; `candidate_claassen_support.md:26–30,43` preserva a hipótese contemporânea original. `selection.md:5–11,23–34` não promove essas descrições a principal/reserva CET.

`cet_correspondence_addendum.md` declara na abertura que foi produzido **depois da triagem e da adjudicação**, explicita intervenção, janela, trajetória e relação de Z com D/Y, e não retroage como critério congelado. Seus estados adicionais coexistem com E1–E7. Os hashes confirmam que `protocol.md`, `protocol.json` e `protocol_freeze.md` não foram alterados.

### R1-F002 e R1-F006: contraste efetivo de Ballard-Rosa

`candidate_ballard_rosa_debt.md:13–16` define o contraste categórico. As linhas 20–29 distinguem grade mensal e período de mensuração da crise; as linhas 41–48 registram E7 faltante e E3 como disponibilidade que requer uma rota histórica corrigida. As linhas 54–60 especificam o trabalho documental ainda necessário. A correção não usa o GDP examinado na minha Fase A como fundamento para rejeitar crise.

O PASS limitado de E3 não certifica o lag `t−2`: a ficha retira explicitamente essa afirmação e mantém HOLD em E7. Isso respeita o protocolo, que distingue disponibilidade de história de escolha da ordem de lags, sem converter uma lacuna de calendário em impossibilidade substantiva.

### R1-F003: ausência de seta não equivale a FAIL

`candidate_claassen_support.md:18–30,38–43,45–52` usa a condição de FAIL congelada, mantém GDP como confundidor e admite uma eventual função de ausência de ganho ou ambiguidade sem inventar mediação. A hipótese de ausência de efeito contemporâneo continua no campo CET separado. `selection.md:9,19` e `archive_disposition.md:9` reproduzem corretamente essa decisão.

### R1-F004: cronologia e limite da revisão

`decision_log.md:7–10,37–39`, `inspection_log.md:9–18,36–38`, `README.md:35–37` e `selection.md:46–48` registram a ordem correta: roster com valores proibidos, escrita/congelamento do protocolo, classificação e revisão posterior. Também preservam a distinção entre ausência de evidência de uso intencional e prova de ausência de influência. O recibo original, que documenta congelamento antes da classificação, permanece preservado e é contextualizado pelos novos logs.

### R1-F005: retratação preservada

`candidate_blair_peacekeeping.md:50,63,69–71` e `decision_log.md:17,22–27` tratam a estrutura país-ano identificável como suficiente para E5 documental, sem confundir FE com clustering ou dispensar a avaliação de dependência no Gate 3. Os bytes da minha Fase A foram preservados; a retratação aparece como informação posterior.

## Integridade, rastreabilidade e limite editorial

| Verificação independente | Resultado |
|---|---|
| Hash do manifesto da rodada 2 recebido | corresponde |
| Artefatos correntes do manifesto | 14/14 correspondem |
| Inventário de arquivos correntes | nenhum ausente ou não enumerado, além do próprio manifesto excluído de seu hash |
| Fontes do CSV | 25/25 hashes correspondem |
| Bases de reparo no manifesto | 2/2 correspondem |
| Manifesto do snapshot | corresponde ao digest declarado |
| Arquivos do snapshot | 12/12 correspondem ao manifesto e aos hashes independentes da rodada 1 |
| Protocolo JSON, Markdown e recibo | 3/3 iguais ao snapshot e aos digests congelados |
| Fase A e revisão da rodada 1 | 4/4 arquivos preservados |
| Adjudicação lida | F001/F002/F003/F004/F006 CONFIRMED; F005 REFUTED |
| Consistência dos seis reparos nos documentos dependentes | PASS |

**Observação editorial não bloqueante:** `candidate_blair_peacekeeping.md:40` mantém a remissão herdada à p. 1324 para a passagem sobre respostas no primeiro ano ou um/dois anos depois. Na fonte lida na Fase A, essa passagem está na p. **1323**, seção Conclusion. A mesma referência ampla aparece na entrada S10 do CSV. Convém ajustar o localizador na próxima consolidação; isso não altera a janela documentada nas pp. 1315–1317, a classificação ou a resolução dos seis achados. Este PASS é dos reparos e de sua integridade, não uma nova auditoria exaustiva de todas as referências bibliográficas.

## Execução e limites

Foram executados somente leituras de documentos (`cat`, `nl`, `rg`), SHA-256, leitura de JSON/CSV e comparação de bytes em Python, sem interpretar observações dos datasets. Os arquivos numéricos presentes nos manifestos foram processados apenas como bytes para hash; valores do roster ou resultados empíricos não foram exibidos. A escrita desta revisão limita-se a `review/applications/review_round2.md` e `.json`.

Não executei R, Stata, regressões, shifts, bootstrap, simulações, nova busca ou leitura de outra candidata. As verificações atuais não estabelecem identificação causal, suporte estatístico, suficiência da história, amostra comum ou inferência adequada. O manifesto registra a identidade das fontes; a comparação de hashes não reproduz análises nem prova cegamento anterior.

### Intuição e decisão final

O reparo torna a triagem utilizável porque o leitor consegue saber o que foi demonstrado e o que ainda falta. Blair tem documentação para uma comparação de projeções futuras; Ballard-Rosa precisa esclarecer o relógio da crise; Claassen não pode receber uma exclusão que o protocolo não prevê. Nenhum desses estados fornece automaticamente a aplicação de efeito contemporâneo exigida pela rota científica. Assim, **o pacote documental passa**, enquanto a escolha da continuação do Gate 1 permanece separada e deve considerar a ausência de aplicação CET aprovada.

**Encerramento:** PASS de integridade documental da rodada 2, sem reparo material remanescente nos seis itens adjudicados. Nenhuma principal/reserva CET aprovada. Nenhuma decisão global do Gate 1 tomada por este revisor. Relatório entregue ao orquestrador; fase encerrada.
