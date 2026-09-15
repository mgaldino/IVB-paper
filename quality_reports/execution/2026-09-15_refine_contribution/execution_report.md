---
title: "Execução do plano de contribuição do IVB-paper"
subtitle: "Evidências, revisões e decisões por gate"
date: "15 de setembro de 2026"
lang: pt-BR
---

# Resultado e leitura deste registro

**O Gate 0 foi aprovado. O Gate 1 não foi aprovado e chegou a uma decisão de rota reservada ao autor.** A proposta testada é reproduzida pelo comparador forte com as mesmas informações, e nenhuma das três aplicações foi aprovada para demonstrar o efeito contemporâneo exigido. A derivação, a execução numérica e a triagem passaram pelas respectivas revisões independentes. A leitura integral de Gelbach permanece pendente. Os Gates 2–7 continuam planejados, com documentos próprios que registram por que não foram iniciados.

O pedido do autor autorizou a execução interna do plano de 15 de setembro, incluindo as análises e a reescrita quando suas dependências passarem. O próprio plano reserva ao autor uma mudança de rota científica após reprovação do teste de contribuição. Uma aprovação documental não resolve essa escolha.

Os arquivos desta execução ficam na pasta de mesmo nome em `quality_reports/execution/`. Cada gate tem objetivo, checklist, estado e, quando executado, evidências, revisão e decisão. Os manifestos registram os hashes, que identificam os bytes exatos examinados.

# Gate 0: base documental aprovada

A fonte e o PDF PA coincidem com o contrato da preparação anterior. O checkout iniciou em `731cd657`; os 14 arquivos do manifesto preparatório mantêm sua identidade. O manifesto ampliado registra 17 entradas, incluindo a versão histórica PSRM e o plano. Não existe recibo que prove quais bytes foram enviados ao Refine; as conclusões se referem expressamente ao PDF local.

A revalidação cobre os sete blocos substantivos e os oito claims do contrato. A matriz contém cinco comentários gerais, 12 detalhados e quatro eixos complementares. Os 17 findings primários mantêm sete classificações CONFIRMED e dez PARTIAL; os quatro eixos adicionais são mapeados a esses findings, evitando duplicação.

O inventário identifica as 26 tarefas de julho, seus arquivos, resultados, testes registrados e limites de reaproveitamento. Task13 possui resultados completos e auditoria localizados. Task14 contém dois checkpoints e registro inicial de execução, sem resultados finais verificáveis. Dois problemas de validação e denominadores continuam documentados nos bytes atuais de seu código.

O universo das aplicações contém 14 candidatos de seis estudos. Onze têm a razão do deslocamento, chamado IVB no manuscrito, pelo erro-padrão do coeficiente longo; três linhas de Albers têm esse erro-padrão ausente. População, urbanização e Polity2 de Rogowski são três comparações adicionais, registradas separadamente. A cobertura mínima de 0,700 pertence ao coeficiente longo com correção por metades do painel, denominada half-panel jackknife (HPJ), em relação ao efeito contemporâneo do tratamento (CET). Ela não é cobertura do intervalo do deslocamento. Os coeficientes 1,023 e 1,016 do desenho mediador+confundidor estão mais próximos de 1,030 que de 1,000.

## Revisão, correção e decisão

A primeira rodada recebeu REPAIR por um erro documental na Task06: o inventário dizia que faltava uma tabela de condições de escopo. O manuscrito já contém essa tabela. O coordenador confirmou o achado, o implementador corrigiu o inventário e o revisor conferiu a mudança. Os arquivos anteriores foram preservados.

A segunda rodada recebeu PASS. O revisor verificou os 12 hashes do conjunto corrigido, dois snapshots anteriores e os 17 arquivos de base. Apenas a Task06 mudou entre as 26 linhas do inventário. Não permanece achado material de cobertura ou proveniência aberto neste gate.

**Arquivos centrais, na pasta do Gate 0:** decisão (`decision.md`), congelamento (`freeze_round2.json`), revisão independente da rodada 2, inventário e matriz de resposta. As pendências científicas continuam vinculadas aos gates seguintes.

# Gate 1: contribuição examinada

A pergunta é se a proposta acrescenta uma capacidade que a decomposição existente não reproduz recebendo os mesmos dados, o mesmo relógio causal, a mesma história e as mesmas hipóteses. Comparar apenas com uma tabela de coeficientes seria insuficiente para sustentar a contribuição metodológica pretendida.

## Comparação e ficha congelada

A ficha governante do teste é a v2, congelada às 12:03:13 UTC de 15 de setembro, antes da implementação e da execução numérica. A v1 foi preservada. O protocolo das aplicações foi congelado antes da classificação, mas depois de uma exposição incidental ao inventário com valores numéricos; esse limite é documentado adiante. A revisão explicita que um analista com as mesmas equações pode reconstruir modelos intermediários omitidos de uma tabela; omitir campos de um relatório não equivale a perder acesso à informação.

Defina $D$ como exposição, $W$ como regressoras comuns, $L$ como história prévia e $Z$ como controle atual. Três modelos são usados: $B=(D,W,L)$, $C=(D,W,Z)$ e a união $U=(D,W,L,Z)$. A comparação de B com C substitui história por controle atual. Passar pela união separa duas operações:

\[
\beta_C-\beta_B=(\beta_U-\beta_B)-(\beta_U-\beta_C).
\]

O primeiro termo acrescenta Z preservando L. O negativo do segundo retira L, mantendo Z. Cada termo é uma inclusão aninhada para a qual a identidade Frisch–Waugh–Lovell (FWL) já fornece o produto dos coeficientes pertinentes. A identidade exige a mesma amostra e transformação, além de posto completo. Ela descreve projeções; não identifica um efeito causal por si.

O comparador forte, chamado C+, pode ajustar esses três modelos e as regressões auxiliares, receber o mesmo grafo causal e conservar a covariância conjunta. A proposta, chamada P, é reproduzida por esse procedimento. A prova construtiva foi confirmada por um revisor que derivou o resultado antes de confrontar o memo do responsável pelo desenho. Essa prova não afirma que toda extensão futura seria equivalente. Uma capacidade adicional teria de ser especificada e testada separadamente.

## Dois exemplos e o que podem demonstrar

No primeiro exemplo, a história influencia o tratamento e o outcome, e um controle atual medeia parte do efeito. As equações são $L=e_L$, $D=L+e_D$, $Z=D+e_Z$ e $Y=qD+bL+rZ+e_Y$, com erros gaussianos independentes, centrados e de variância unitária. Da estrutura causal, o efeito total de D é $q+r$. As projeções são $\beta_B=q+r$, $\beta_U=q$ e $\beta_C=q+b/2$.

Para $(q,b,r)=(1/2,1,1/2)$, B e C têm coeficiente 1 e U tem coeficiente 1/2. A inclusão muda o coeficiente em $-1/2$ e a retirada em $+1/2$; o total é zero. Nesse ponto C coincide de fato com o efeito total. As perturbações pré-especificadas de b mostram por que essa coincidência não certifica a especificação para a classe. Mostrar as etapas ajuda a exposição; o comparador forte também as calcula.

| Célula | B | U | C | Inclusão | Retirada | Total |
|:--|--:|--:|--:|--:|--:|--:|
| Central | 1,0 | 0,5 | 1,0 | −0,5 | +0,5 | 0,0 |
| b = 0,8 | 1,0 | 0,5 | 0,9 | −0,5 | +0,4 | −0,1 |
| b = 1,2 | 1,0 | 0,5 | 1,1 | −0,5 | +0,6 | +0,1 |
| Nula | 1,0 | 1,0 | 1,0 | 0,0 | 0,0 | 0,0 |

**Tabela 1.** Coeficientes de D e etapas da substituição no exemplo E1. Valores calculados sobre as oito linhas sintéticas de cada célula e arredondados a uma casa decimal. Inclusão é $B\rightarrow U$; retirada é $U\rightarrow C$; total é C−B. P e C+ reproduzem esses valores. São conjuntos determinísticos para verificar álgebra, não dados observados.

No segundo exemplo, dois sistemas gaussianos produzem a mesma distribuição conjunta de D, Z e Y. Em um, Z medeia D e o efeito total é 2. No outro, Z confunde a associação e o efeito total é 1. Ambos têm coeficiente curto 2, longo 1 e deslocamento $-1$. Sem informação que resolva a ordem entre D e Z, a saída correta preserva as duas interpretações condicionais. O deslocamento observado não escolhe entre elas.

O código numérico usa linhas sintéticas determinísticas com momentos exatos e matrizes de covariância conhecidas. Executado uma vez após duas rodadas de revisão R, concluiu com retorno zero e marcador final PASS: 168 verificações gerais, tabela de 106 projeções reportadas e 20 verificações de covariância. Essas contagens se referem ao mesmo conjunto de exemplos e não são amostras independentes. Os maiores erros absolutos foram $6,66\times10^{-16}$ nas projeções e $5,55\times10^{-17}$ nas transformações de covariância, abaixo da tolerância congelada. As quatro células e os dois sistemas foram preservados.

A revisão posterior conferiu as 16 saídas com hashes e tamanhos e refez a aritmética por fórmulas fechadas, sem repetir R ou ajustar regressões. O maior erro frente às projeções independentes foi $9,99\times10^{-16}$; para as matrizes, $9,71\times10^{-17}$. A auditoria do revisor também está salva como script e relatório.

Essa verificação de álgebra não é simulação de cobertura, evidência empírica ou teste da compreensão de pesquisadores. Certificados causais são entradas analíticas previamente derivadas; o código confere sua transmissão e as perdas, sem descobrir o grafo pelos dados. Os dados determinísticos preservam os segundos momentos dos exemplos, mas não são amostras gaussianas. A inferência também tem um limite: na origem em que ambos os fatores do produto são zero, a diferença pareada tem a mesma degenerescência de primeira ordem. Trocar a representação não resolve esse problema.

## Literatura e limite de acesso

O leitor bibliográfico registrou leitura integral de Blackwell e Glynn (16 páginas), Cinelli, Forney e Pearl (30), Imai e Kim de 2019 (24), Imai e Kim de 2021 (12) e Bellemare, Masaki e Pepinsky (16). A matriz contém 17 confrontos com localizadores e evidência exigida. Foram lidas também as 457 linhas da ajuda pública de b1x2 e inspecionadas as partes pertinentes do código do autor.

A documentação de b1x2 já permite decomposição conjunta por grupos, soma dos componentes, covariância do produto, heterocedasticidade e agrupamento. Um aviso sobre a covariância reportada entre a linha total e seus componentes não significa ausência geral de covariância no método. A informação temporal e as restrições dinâmicas aparecem nos demais trabalhos lidos. As fontes e seus hashes estão no manifesto bibliográfico. [Software do autor no SSC/RePEc](https://ideas.repec.org/c/boc/bocode/s457814.html).

**O artigo integral de Gelbach ainda não foi obtido.** Resumo editorial, ajuda e código não substituem a leitura integral exigida pelo plano. A prova de que o comparador especificado reproduz a proposta é verificável sem imputar limites a esse artigo; a avaliação bibliográfica completa permanece pendente. Editor, SSRN, acervos públicos e Zotero foram consultados, e foi solicitada ao autor a indicação de uma eventual cópia local. [Registro editorial de Gelbach](https://www.journals.uchicago.edu/doi/10.1086/683668).

## Aplicações: revisão documental independente

A triagem foi limitada a Blair, Ballard-Rosa e Claassen, com sete critérios congelados: exposição definida, janela exposição–outcome, história anterior, suporte documentado, painel e clusters, insumos acessíveis e contraste substantivo entre controle histórico e atual. As fichas registram timing, variáveis, estimando, preparação e riscos do estimador.

O primeiro leitor viu incidentalmente colunas numéricas ao abrir o inventário do acervo antes de escrever o protocolo, embora tenha registrado que não as usou. Por isso, a seleção não recebe certificação de cegamento. Um segundo leitor avaliou as fontes primárias antes de confrontar as fichas, sem acesso à seleção inicial ou aos resultados de IVB. Essa revisão resolve erros documentais, mas não apaga a exposição anterior nem certifica a escolha das três candidatas entre todo o acervo.

**Blair** tem elegibilidade documental para estudar projeções futuras, mas a adequação ao CET não está estabelecida. **Ballard-Rosa** permanece em espera documental porque o calendário original da crise inflacionária não foi esclarecido; a exposição é esquerda em exercício versus centro/outros, sem presumir uma nova transição. **Claassen** também permanece em espera documental: a ausência da seta causal do apoio para o PIB não satisfaz a regra de exclusão do protocolo, e as premissas originais excluem o efeito contemporâneo do apoio sobre democracia. Nenhuma candidata ocupa o papel de principal ou reserva CET.

A revisão inicial corrigiu seis itens adjudicados, incluindo a retratação de uma objeção do próprio revisor à estrutura documental de Blair. Os reparos foram revalidados nos novos bytes. A correspondência CET foi explicitada em adendo posterior, sem alterar retroativamente o protocolo. A seleção corrigida oferece uma busca adicional delimitada ou uma rota descritiva/futura, ambas ainda não ativadas. Um efeito futuro de exposição defasada não se transforma em efeito contemporâneo apenas pela troca dos índices.

## Decisão do Gate 1 e alternativas

O critério de ganho distinto falhou para a rotina congelada. A prova construtiva estabelece equivalência no domínio declarado, e os exemplos verificam sua implementação. A ausência de texto integral de Gelbach impede encerrar o confronto bibliográfico; ela não transforma a equivalência já demonstrada em ganho. A rota também não tem uma aplicação CET aprovada. Por isso, o estado local é **decisão do autor**, com pendências preservadas, e o goal não é marcado como concluído.

O memo de decisão oferece quatro opções concretas. **A: contribuição aplicada ou pedagógica**, com uma nova frase de contribuição e uma aplicação ou comparação didática defensável, atribuindo explicitamente os resultados conhecidos. **B: extensão inferencial específica**, começando por um memo que fixe alvo, comparador e garantia pretendida, por exemplo perto da origem do produto; a solução e sua novidade ainda teriam de ser estabelecidas. **C: ferramenta operacional**, com avaliação própria de erros ou custo de uso. **D: suspender esta rota**, preservando os resultados desfavoráveis e os materiais úteis. Nenhuma opção foi escolhida automaticamente.

O plano é explícito no encerramento do Gate 1: “Mudar o escopo científico é decisão do autor.” A implementação chegou a esse ponto previsto. A decisão detalhada está em `gate_01/decision.md`, com a evidência de cada critério e o próximo passo delimitado de cada alternativa.

# Gates seguintes: dependências preservadas

- **Gate 2:** identidades, alvos estatísticos e relógios causais; depende do Gate 1.
- **Gate 3:** escolha de história e inferência aplicáveis; depende do Gate 2.
- **Gate 4:** código, pilotos, simulações e comparação controlada; depende dos Gates 2–3 e da decisão do Gate 1.
- **Gate 5:** aplicação central e reprodução independente; depende dos Gates 1–4.
- **Gate 6:** reescrita do manuscrito e leitura independente; depende de resultados estáveis dos Gates 2–5.
- **Gate 7:** revisão científica final, reprodução e inspeção do PDF; depende do Gate 6.

# Verificações e reprodução dos registros

Foram executados leitura, extração de texto dos PDFs, contagens de CSV/JSON, conferência de hashes, inspeção de Git e revisão visual das 22 páginas do PDF existente. Os validadores oficiais do contrato e da adjudicação retornaram VALID. A única execução R desta etapa foi o teste determinístico dos exemplos, após revisão independente. Não foram executados Monte Carlo, bootstrap ou reestimações com dados reais.

O script `validate_execution.py` verifica estados, dependências, manifestos revisados, contagens do Gate 0 e as 16 saídas numéricas cobertas pelo manifesto do teste. Também compara os 17 arquivos de base com seus hashes de entrada. Seu PASS se refere à integridade documental; não declara aprovação de gates científicos. O script `render_report.py` compila somente este relatório, sem executar o manuscrito RMarkdown. O arquivo `report_visual_qa.json` registra as páginas e o hash do PDF final inspecionado.

O histórico Git passou a mostrar `b17c0a47`, descrito como checkpoint de encerramento de sessão, durante a execução. A diferença desse checkpoint inclui apenas registros iniciais desta pasta; os fontes científicos mantêm seus hashes. Nenhum comando de commit foi executado pela equipe.
