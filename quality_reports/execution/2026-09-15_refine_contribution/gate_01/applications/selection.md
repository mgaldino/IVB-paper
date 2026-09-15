# Seleção corrigida das aplicações

## Decisão

**Nenhuma candidata está aprovada como principal ou reserva para a rota CET.** A classificação literal do protocolo e a adequação adicional ao efeito contemporâneo do plano produzem resultados distintos:

1. **Blair, Di Salvatore e Smidt:** `ELIGIBLE_DOCUMENTARY` sob E1–E7 para a projeção futura documentada, mas `NOT_ESTABLISHED` para CET. O desenho usa mandato em `t-2` e democracia em `t`; renomear `t-2` como origem não torna o outcome contemporâneo. A candidata não recebe papel principal ou reserva CET.
2. **Ballard-Rosa, Mosley e Wellhausen:** `HOLD_DOCUMENTATION`, com `E7 = MISSING_TIMING`, e `NOT_ESTABLISHED` para CET. A exposição original é o estado partidário em exercício, com esquerda comparada a centro/outros. Não é uma nova transição. O artigo trata controles como anuais salvo exceções e não documenta a crise inflacionária como mensal; o operador `l.` no código não certifica sua frequência ou ordem temporal.
3. **Claassen:** `HOLD_DOCUMENTATION`, com `E7 = MISSING_NOT_FAIL`. O PIB é um confounder explícito no processo de apoio e democracia. A ausência de apoio → PIB impede presumir mediação, mas não satisfaz a regra de FAIL de E7. Separadamente, as premissas originais excluem o efeito contemporâneo de apoio sobre democracia.

A seleção inicial de Blair como principal, Ballard-Rosa como reserva e Claassen como inelegível está preservada em `gate_01/review/snapshots/applications_round1/` e **foi substituída** por esta decisão após revisão e adjudicação. Nenhuma classificação foi alterada por magnitude, sinal, significância, IVB ou shift.

## Matriz harmonizada

| candidata | E1 | E2 | E3 | E4 | E5 | E6 | E7 | classe literal | adequação CET | papel CET |
|---|---|---|---|---|---|---|---|---|---|---|
| Blair: mandato → democracia; ajuda externa | PASS | PASS | PASS | PASS documental | `PASS_DOCUMENTARY_WITH_RISK` | PASS | PASS literal | `ELIGIBLE_DOCUMENTARY` | `NOT_ESTABLISHED` | nenhum |
| Ballard-Rosa: esquerda em exercício vs. centro/outros → denominação; crise inflacionária | `PASS_ORIGINAL_CATEGORICAL_EXPOSURE` | PASS | `PASS_AVAILABILITY_REQUIRES_CORRECTED_HISTORY_ROUTE` | PASS documental | PASS | PASS | `MISSING_TIMING` | `HOLD_DOCUMENTATION` | `NOT_ESTABLISHED` | nenhum |
| Claassen: apoio → democracia; PIB per capita | PASS | PASS | `PASS_DOCUMENTARY_WITH_LIMITS` | PASS documental | PASS documental | PASS | `MISSING_NOT_FAIL` | `HOLD_DOCUMENTATION` | `ORIGINAL_ASSUMPTIONS_EXCLUDE_CONTEMPORANEOUS_SUPPORT_EFFECT` | nenhum |

E3 em Ballard-Rosa registra disponibilidade potencial de história; não certifica que `t-2` seja anterior à exposição no período de referência real. E5 em Blair passa documentalmente porque país, ano e dependência intrapaís são identificáveis; a adequação da covariância fica para o Gate 3. `HOLD_DOCUMENTATION` significa falta de documentação, não inelegibilidade demonstrada.

## Correspondência com CET

O adendo posterior `cet_correspondence_addendum.md` exige, para um papel CET, uma intervenção atual em tempo físico, uma janela contemporânea de resposta e a trajetória do tratamento durante a janela. Os desenhos `D[t-2] -> Y[t]` e `D[t-1] -> Y[t]` continuam sendo respostas futuras quando os índices são renomeados. Efeito contemporâneo total e efeito direto também são alvos distintos; acrescentar um controle atual não identifica automaticamente nenhum deles.

## Opções submetidas ao autor, ainda não escolhidas

Como nenhuma principal ou reserva CET foi demonstrada, há duas rotas possíveis. Esta triagem não escolhe entre elas:

1. **Busca adicional delimitada:** painel anual ou subanual com intervenção atual datada, outcome na janela contemporânea, história de Y/Z anterior e Z atual plausivelmente afetado durante a janela; somente repositórios primários de periódicos e arquivos públicos; até oito títulos/resumos e no máximo três textos integrais; parar no primeiro par principal/reserva que satisfaça E1–E7 e a correspondência CET, ou após três leituras integrais sem esse par.
2. **Rota descritiva/futura:** usar Blair como caso documental para uma mudança de coeficiente em projeção futura, com rótulo explícito de alvo descritivo ou futuro e sem apresentá-lo como CET.

Qualquer uma dessas rotas exige decisão do autor. Não houve nova leitura de aplicações nesta correção.

## Pendências antes de qualquer Gate 3

| caso | pendência documental/metodológica |
|---|---|
| Blair | definir intervenção e janela CET se esse alvo for mantido; documentar trajetória do mandato; validar calendário, história, imputação, amostra comum e dependência; decidir OLS versus IV |
| Ballard-Rosa | obter a fonte primária da crise, sua frequência e regra de início/fim; definir história realmente anterior; manter o contraste categórico original; tratar meses sem emissão e possível estimador fracional/duas partes |
| Claassen | documentar um papel de ausência de ganho ou ambiguidade para o PIB, ou escolher outro alvo/controle mediante nova autorização; preservar o DAG original e a distinção entre OLS dinâmico e GMM |

Nenhuma regressão, R, Stata, bootstrap, IVB, shift, p-valor ou estatística substantiva dos dados foi executada. Esta decisão continua sujeita à nova revisão independente dos bytes corrigidos e não constitui aprovação do Gate 1.

## Cegamento e valor da revisão independente

O roster que continha colunas proibidas foi lido antes da criação e do congelamento do protocolo. O protocolo foi congelado antes da classificação das três candidatas, mas a sequência não é estritamente cega à informação vista. A revisão posterior concordou que Blair passa E1–E7 e que as rotas examinadas não demonstram CET; divergiu da classificação inicial de Ballard-Rosa e Claassen e retratou a objeção inicial a E5 de Blair. Essa revisão fortalece a sustentação documental das conclusões corrigidas, mas não elimina o comprometimento inicial nem certifica ausência de influência.
