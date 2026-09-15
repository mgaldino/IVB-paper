# Revisão independente após execução determinística do Gate 1

Data: 2026-09-15. Revisor: `gate1_scientific_review`.

## Resultado

**PASS dos outputs da execução primária, no domínio determinístico previsto.** Os coeficientes, contrastes, sinais, ações, perdas, matrizes e efeitos intervencionais concordam com minha derivação independente anterior aos relatórios do desenhista. O estado final e os hashes correspondem à execução do código revisado. Não identifiquei achado material que exija repetir R ou reparar os outputs.

Este resultado confirma a implementação dos exemplos e a equivalência do procedimento congelado frente a C+. Não demonstra capacidade metodológica adicional, cobertura de intervalos, ganho humano, completude bibliográfica ou PASS global do Gate 1.

## Proveniência conferida

- Código executado/revisado: `numerical/verify_examples.R`, SHA `98b4fbc20bdce3d03eaae7e1828a34a2c37e1e07c7f46cb848cc32131aff7127`.
- Autorização do coordenador: `numerical/execution_authorization.json`, emitida às 12:42:56 UTC, aponta para a revisão v2 e o mesmo hash do código.
- Console/log registram a execução primária às **12:42:58 UTC de 15/09/2026** e sua conclusão PASS. O coordenador informa exit code 0; o console preservado mostra a mensagem de sucesso, sem reproduzir por si um campo separado de exit code.
- `numerical/results/primary/final_status.txt` declara PASS depois das saídas obrigatórias. Seu hash do manifesto confere: `aedc8deff4e1b3ea99aa3bd7c21da3d98932d146b8e2e6a2900ff610f08a7cdc`.
- Os **16 arquivos listados no manifesto** existem e seus hashes e tamanhos concordam. O manifesto e o marcador final são registrados separadamente nesta revisão, conforme o protocolo sem circularidade.
- R 4.4.2, arquitetura aarch64 e locale efetivo C estão registrados em `sessionInfo.txt`. Os avisos iniciais de locale e fallback para C permanecem no console; o subprocesso de hashing corrigido funcionou e não impediu a entrega.

O inventário completo dos bytes conferidos está em `postexecution_review.json` e `postexecution_audit_evidence.json`. Nenhuma fonte ou saída do implementador foi alterada pelo revisor.

## Conferência de resultados

| Dimensão | Resultado observado | Avaliação independente |
|---|---|---|
| Validações do script R | 168 linhas com `pass=TRUE` | Conferidas; são verificações de artefatos/identidades, não amostras ou repetições Monte Carlo |
| Células E1 | 4 células × 8 linhas = 32 linhas | Central, menos, mais e nulo preservados; IDs lexicográficos e equações conferidos |
| Grafos E2 | 2 grafos × 8 linhas = 16 linhas | Ambos preservados; mesma Sigma observável conferida |
| Projeções | 126 linhas, das quais 106 reportadas | 20 campos omitidos de C0 permanecem sem pontuação; números reportados conferidos contra fórmulas próprias |
| Ações/perdas | 18 linhas | Alvos descritivos corretos, perdas calculadas zero nas coordenadas pontuadas, omissão C0/E1 sem perda |
| Modelos | 54 diagnósticos | Todos com posto completo; entradas comuns consistentes |
| Covariâncias/influências | 20 comparações internas | Todas dentro das tolerâncias; matrizes e gradientes também conferidos por fórmulas independentes |
| Efeitos do(D) em E2 | G_M=2; G_F=1 | Concordam com propagação da intervenção nas SCMs |

### Erros e condicionamento

- Maior erro dos coeficientes/contrastes reportados frente às fórmulas independentes: **9,99 × 10⁻¹⁶**.
- Maior diferença entre matrizes exportadas e minha recomputação por fórmulas fechadas das contribuições de influência: **9,71 × 10⁻¹⁷**.
- Maior diferença registrada nas comparações internas de covariância/influências P/C+: **5,55 × 10⁻¹⁷**.
- Maior resíduo de equação normal registrado: **2,89 × 10⁻¹⁵**, abaixo de 10⁻¹⁰.
- Maior número de condição da matriz de desenho: **4,049**; do Gram: **16,394**. Os casos são bem condicionados.

Essas discrepâncias são compatíveis com arredondamento em ponto flutuante e estão muito abaixo das tolerâncias preespecificadas. Não houve mudança de parâmetro, filtragem de célula ou escolha de resultado favorável nesta revisão.

## E1 e E2 confrontados com a derivação anterior

Em E1, as fórmulas independentes são `beta_B=q+r`, `beta_C=q+b/2`, `beta_U=q`, `d_add=−r`, `d_lag=−b/2`, `retirada=b/2` e `total=b/2−r`. As três células não nulas reportam compensação; a nula reporta ausência. No caso central, C coincide realmente com o CET; as duas perturbações preservam as diferenças −0,1 e +0,1. Os certificados fornecidos distinguem essa coincidência da identificação ao longo da classe. Na subclasse nula, B/C/U recebem o certificado total comum.

Em E2, as matrizes observáveis são `[[1,1,2],[1,2,3],[2,3,6]]`; os coeficientes curto/longo são 2 e 1 e o shift é −1. G_M possui efeito total 2; G_F possui efeito total 1. A saída conserva os certificados condicionais e a ambiguidade causal global. Nenhum resultado escolhe o DAG pelos coeficientes.

**Os certificados causais são inputs analíticos revisados e comparados com um oráculo declarado.** Sua correção é sustentada pela derivação das SCMs; as linhas de perda zero não são evidência de descoberta causal automática ou experimento de decisão humana.

## Covariâncias: verificação adicional independente

Para evitar depender apenas das marcas PASS do próprio script, recomputei as matrizes por fórmulas fechadas, usando o cubo determinístico e n=8. Para cada observação, as contribuições de influência dos coeficientes de D são:

```
IF_B = e_D (r e_Z + e_Y) / n
IF_U = (e_D − e_Z) e_Y / n
IF_C = (e_L + e_D − 2e_Z) [b(e_L − e_D)/2 + e_Y] / (2n)
```

Essas fórmulas seguem diretamente de `d_residual × residual / sum(d_residual²)`. Formei as diferenças `(IF_U−IF_B, IF_U−IF_C, IF_C−IF_B)` e somei seus produtos externos. Os resultados reproduzem as matrizes exportadas para as quatro células. Confira-se também a completude e os sinais dos 60 gradientes não nulos exportados, contra as derivadas independentes de cada contraste e produto.

Em E2, o HC0 do shift vale **1/4 no fixture G_M** e **1/8 no fixture G_F**, e ambos estão corretos. No primeiro fixture, a influência é `−(e_1 e_2 + e_2 e_3)/n`; no segundo, é `(−e_1+e_2)e_3/(sqrt(2)n)`. Os suportes finitos têm segundos momentos iguais e quartos momentos diferentes. Logo a equivalência observacional das populações gaussianas especificadas não exige igualdade dessas matrizes HC0 em dois fixtures discretos diferentes. A comparação P/C+ usa sempre o mesmo fixture e preserva o emparelhamento.

As diferenças das influências observadas pelo R estão na tabela de checks; seus vetores completos não são exportados como artefato separado. A revisão conferiu a implementação estática, os gradientes exportados e as matrizes por cálculo independente. Não afirma ter confrontado um arquivo inexistente de vetores de influência.

## Como reproduzir esta auditoria

O script do revisor `audit_postexecution.py`, nesta pasta, lê os CSVs e verifica hashes, linhas, fórmulas, ações e covariâncias por aritmética independente. Não chama R, não refaz OLS, não sorteia dados e não executa experimento inferencial. Seu único output é `postexecution_audit_evidence.json`, com cada verificação e o manifesto dos arquivos examinados.

```
python3 quality_reports/execution/2026-09-15_refine_contribution/gate_01/review/science/audit_postexecution.py
```

O registro contém 426 asserções de auditoria dos arquivos. Essa contagem também não representa observações independentes ou replicações de um experimento. Nenhum R foi repetido pelo revisor.

## Limitações e encerramento desta fase

- A execução observada percorreu o caminho de sucesso. Os ramos de falha, corrupção de hashes, perdas não zero, posto deficiente e recusa de sobrescrita foram inspecionados no código, **não executados** nesta etapa.
- Os fixtures são dados sintéticos determinísticos e não amostras empíricas ou gaussianas. Não há Monte Carlo, cobertura, bootstrap, intervalos ou evidência sobre dependência em clusters.
- O caso E1-nulo não é uma experiência de validade inferencial perto de `theta=pi=0` e não resolve a degenerescência de primeira ordem.
- O resultado confirma equivalência da rotina congelada no domínio de sua prova e a implementação nos casos prescritos. Não comprova ganho de usabilidade ou capacidade metodológica adicional.
- O artigo integral de Gelbach continua ausente. Esta revisão não certifica completude bibliográfica ou novidade.
- Aplicações foram examinadas por outro leitor. A decisão e o congelamento global final do Gate 1 ainda exigem síntese do coordenador e conferência dos respectivos pareceres, sem transferir a este PASS técnico o status do gate.

**Conclusão:** nenhuma repetição R ou correção numérica é necessária com base nos resultados conferidos. A próxima etapa autorizada é a conferência da síntese e do congelamento global do Gate 1.
