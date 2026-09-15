# Revisão de código: verify_examples.R, rodada 2

Data: 2026-09-15. Revisor independente: `gate1_scientific_review`.

## Resumo executivo

**PASS pré-execução, restrito aos bytes e fixtures identificados abaixo.** Os quatro reparos NUM-01–04 resolvem os defeitos adjudicados; a cadeia de coeficientes, contrastes e covariâncias continua coerente com a ficha e com a derivação independente. Não identifiquei novo achado material nesta rodada. Este PASS é de revisão estática: execução, outputs e condições de falha ainda não foram exercitados em R pelo revisor.

**Nota geral: A para o escopo determinístico delimitado.** A revisão usa a skill `review-r` já lida na rodada anterior. Não executei ou parseei R, não editei código e não ampliei os exemplos ou o domínio.

## Identidade examinada

| Arquivo relativo a gate_01/numerical | SHA-256 recalculado |
|---|---|
| verify_examples.R | 98b4fbc20bdce3d03eaae7e1828a34a2c37e1e07c7f46cb848cc32131aff7127 |
| README.md | d29514a2f655c2f7efa6cb6cda28e934d5d6b0b0ae38c883fb812d3389806c4b |
| repair_round2.md | 1fb7de332d8e53fb76f9626ca4fabc32478c1468a74a18812a563acc5f3b5531 |
| source_manifest.json | cb96ea39df03496bec9b801181103e9de57316a97de69fe56df9d9a2ce9549d6 |

A ficha governante continua v2: MD `37562fccf615793d0b589b58303e0afeb225edd73ea85e44a7bb1b7688be7097`; JSON `12affe0250af02ada1fc4213a1067ccfe5b482fa5d7a78c52261069c7e7ff00f`. O snapshot da rodada 1 preserva seus três hashes originais, conferidos novamente. Não existia `numerical/results/` ao final desta revisão.

## Método e cobertura desta revisão

Li integralmente o diff do script contra `review/snapshots/numerical_round1/verify_examples.R`, reli as funções novas e os blocos dependentes de montagem de tabelas, validação global, gravação e encerramento; li README, memo de reparo e manifesto. A primeira rodada já havia coberto integralmente as 1.293 linhas anteriores. A nova versão possui 1.645 linhas; o diff preserva OLS, construção dos fixtures, caminhos P/C+, auxiliares e transporte HC0. Não tratei checks de whitespace, hash ou JSON como prova de execução R.

## Problemas críticos

**Nenhum achado material aberto nos bytes desta rodada.** Os quatro achados confirmados receberam os seguintes reparos, verificados estaticamente:

| Achado | Localizadores na versão 2 | Resultado e evidência |
|---|---|---|
| NUM-01: hashing/locale | 35–65 | `system2` fornece `LC_ALL=C` e `LANG=C`, verifica status, número de linhas e primeiro campo SHA-256 de 64 caracteres. Rodei somente o subprocesso `shasum` no shell com esse locale: retorno zero, uma linha e hash correto. O manifesto declara a dependência externa. |
| NUM-02: perdas/ações | 350–392; 505–545; 599–628; 882–942; 1174–1232; 1372–1415; 1449–1455; 1477–1485; 1509–1517 | Oráculos declarativos separados fixam alvos; E1 classifica os contrastes calculados; E2 reporta o shift calculado; funções calculam perdas 0/1/4; cada ação pontuada precisa acertar seu alvo para o PASS global. Certificados causais são inputs analíticos explicitamente rotulados, não descoberta causal. C0/E1 mantém omissão sem perda. |
| NUM-03: efeitos do(D) | 578–589; 1303–1349 | As funções de intervenção propagam D para Z em G_M e mantêm Z fixo em G_F. Calculam Y(1)−Y(0); os efeitos calculados são confrontados individualmente com 2 e 1 antes de verificar sua diferença. A igualdade deixou de ser um teste entre constantes. |
| NUM-04: estado final | 152–175; 1567–1641 | Log distingue verificações de finalização; exige todos os 16 outputs prévios; grava manifesto e calcula seu hash; somente então cria `final_status.txt` com PASS ou FAILED. A ausência de conclusão bem-sucedida é tratada pelo `on.exit`. O hash do manifesto fica no marcador final, sem auto-hash circular. |

### Checagem dos efeitos dependentes

- A escala de perdas permanece 0/1/4. O alvo E1 corresponde a compensação nas três células não nulas e ausência na nula. O certificado da subclasse sem as duas setas é {B,C,U}; nas outras três células, B identifica o CET na classe. Essas entradas coincidem com a derivação independente escrita antes dos relatórios do implementador.
- Em E2, `somente_descritivo` recebe perda zero somente quando os certificados condicionais completos coincidem com o oráculo. O código não seleciona entre G_M/G_F a partir do shift. A igualdade das ações causais é conferência de inputs analíticos comuns; sua validade vem da prova, não de um teste de descoberta causal.
- `all_scored_actions_match_oracle` entra em `validation_table`, que entra em `overall_pass`; logo mero acordo P/C+ não basta. Erros nas classificações ou certificados podem produzir perda positiva e impedir PASS.
- OLS direto e produtos FWL continuam independentes como caminhos de cálculo de contrastes. C+ não lê os outputs de P. As chamadas compartilham a mesma rotina OLS, fato já aceito na rodada 1 e documentado: não é teste independente de dois pacotes de regressão.
- Os scores empilhados continuam alinhados por IDs de linha. Gradientes incluem incerteza dos dois fatores e termos cruzados. A equivalência HC0 e das influências continua sendo uma checagem algébrica do fixture.
- O novo output de intervenção soma uma tabela às saídas requeridas. `final_status.txt` e `output_manifest.csv` ficam deliberadamente fora do conjunto auto-hasheado; o marcador final identifica o manifesto. Uma falha de validação não recebe marcador PASS mesmo quando as tabelas foram gravadas para diagnóstico.

## Melhorias importantes

Nenhuma melhoria material necessária antes da execução delimitada. Não recomendo refatoração adicional nesta rodada: o reparo preserva o núcleo já revisado e as mudanças têm localizadores claros.

## Sugestões

Ao sintetizar outputs, reportar o marcador final como estado autoritativo e distinguir as verificações computadas dos certificados causais fornecidos. Isso já está documentado no README e deve ser preservado na decisão do Gate 1. Os timestamps, paths de execução e informações de ambiente são metadados; reprodutibilidade científica exige concordância dos valores e invariantes numéricos, não igualdade desses metadados em execuções distintas.

## Pontos positivos

- Nenhuma célula foi removida, substituída ou escolhida após resultados.
- Expectativas algébricas, inputs causais e outputs calculados têm papéis distintos.
- Constantes esperadas são usadas como oráculo; os efeitos/coeficientes observados são calculados por caminhos próprios.
- Logs e manifestos preservam a distinção entre resultado das verificações e conclusão da entrega.
- Base R é suficiente para esses fixtures minúsculos; nenhuma semente, biblioteca de painel ou paralelização é necessária. O subprocesso `shasum` está declarado.
- A documentação conserva a fronteira entre identidade estatística, hipótese causal e validade inferencial.

## Verificações efetivamente executadas

1. Leitura estática do código, diff e documentação; nenhuma avaliação de R.
2. SHA-256 dos quatro artefatos, comparação dos artefatos com o manifesto e conferência dos três hashes históricos do snapshot: todos concordam.
3. Leitura estrutural do JSON pelo Python, para a conferência de manifestos.
4. Subprocesso de hashing com locale portátil: hash correto e sem avisos extras. Não se trata de execução parcial do script R.
5. Inspeção de que `numerical/results/` não existia nesta entrega pré-execução.

Não executei testes numéricos, ramos de falha, parser R, `source()`, simulação, bootstrap ou dados reais. A prova independente e a revisão estática fundamentam a recomendação de execução; não substituem sua realização.

## Decisão e limites

**Recomendo ao coordenador adjudicar PASS pré-execução para o SHA `98b4fbc20bdce3d03eaae7e1828a34a2c37e1e07c7f46cb848cc32131aff7127` e executar apenas a verificação determinística prevista.** A liberação e execução pertencem ao coordenador. Após a execução, conferir estado final, hashes, preservação das quatro células E1/dois grafos E2, erros versus tolerâncias, ações/perdas e matrizes produzidas contra a nota independente.

Este PASS não valida cobertura, inferência por clusters, painéis curtos, comportamento humano, efeitos em dados reais, novidade ou Gate 1 completo. Gelbach integral continua ausente. Qualquer alteração do código após este hash requer nova revisão dos bytes e dependências afetados. Relatórios das rodadas anteriores permanecem preservados.
