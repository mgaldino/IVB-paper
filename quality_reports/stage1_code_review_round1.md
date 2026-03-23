# Code Review --- Stage 1, Round 1

**Reviewer**: Claude Code (Agente Reviewer)
**Date**: 2026-03-22
**File Reviewed**: `ivb_paper_psrm.Rmd` (R chunks only) + `replication/ivb_utils.R`
**11 R chunks evaluated**

---

## Score: 86
## Status: APROVADO (com issues major a resolver)

---

## Issues encontradas

### Critico
(nenhuma)

### Major

1. **Cache sem invalidacao adequada para dependencias externas** (-10)
   - **Chunks afetados**: `leipziger-data` (linha 657), `leipziger-replication` (linha 678), `leipziger-ivb` (linha 699), `rogowski-data` (linha 750), `rogowski-replication` (linha 764), `rogowski-ivb` (linha 783).
   - **Descricao**: Seis chunks usam `cache=TRUE` e dependem de arquivos externos: os datasets `.tab` (lidos via `read.delim()`) e a funcao `compute_ivb_multi()` (carregada via `source("replication/ivb_utils.R")` no chunk `setup`). O knitr cache nao rastreia automaticamente dependencias externas lidas por `read.delim()` ou carregadas por `source()`. Se `ivb_utils.R` for editado (e.g., correcao de bug em `compute_ivb_multi()`) e o cache nao for limpo manualmente, os chunks `leipziger-ivb` e `rogowski-ivb` retornarao resultados desatualizados silenciosamente. Os chunks `ivb-summary-table` e `ivb-full-table` incluem comentarios reconhecendo essa limitacao, mas os chunks de replicacao nao.
   - **Recomendacao**: Adicionar `cache.extra = tools::md5sum("replication/ivb_utils.R")` nos chunks que chamam `compute_ivb_multi()`. Para chunks de dados, adicionar `cache.extra = tools::md5sum(...)` apontando para o arquivo `.tab` correspondente. Alternativamente, declarar dependencias com `dependson` entre chunks.

2. **Pacote `data.table` carregado mas nao utilizado** (-2, tratado como Minor)
   - **Chunk**: `setup` (linha 52)
   - **Descricao**: `library(data.table)` e carregado no chunk de setup, mas nenhum chunk no manuscrito utiliza funcoes ou sintaxe de `data.table`. O arquivo `ivb_utils.R` tambem nao usa `data.table` (usa `dplyr` e `fixest`). Provavel residuo dos scripts de simulacao.
   - **Recomendacao**: Remover `library(data.table)` do setup.

### Minor

1. **Calculo de `pct` no chunk `rogowski-ivb` nao verifica significancia de `beta_long`** (-2)
   - **Chunk**: `rogowski-ivb` (linha 804)
   - **Descricao**: A coluna `pct` e calculada como `round(100 * r$ivb_formula / r$beta_long, 1)` para todos os 4 controles sem verificar se `beta_long` e estatisticamente significativo. O chunk `ivb-summary-table` (linhas 588-594) protege contra isso condicionando `IVB_pct` em `|beta_long / SE_beta| >= 1.96`. Neste caso concreto, `beta_long` (coeficiente de post offices) e significativo em todas as 4 iteracoes do loop, entao o resultado final esta correto. Porem, a logica de protecao esta ausente, criando inconsistencia com o chunk principal.
   - **Recomendacao**: Adicionar verificacao de significancia, ou documentar que a protecao e desnecessaria neste caso particular porque o denominador e sempre o mesmo coeficiente significativo.

---

## Observacoes positivas

1. **`compute_ivb_multi()` e uma funcao bem construida**: Validacao extensiva de inputs (linhas 59-112 de `ivb_utils.R`) com mensagens de erro claras. Verifica tipos, comprimentos, sobreposicao de variaveis, NA nos coeficientes, e collinearidade. Inclui `diff_check` no output para verificacao da identidade algebrica IVB = beta_long - beta_short. Documentacao roxygen-style completa.

2. **Uso correto de `dplyr::lag()` qualificado**: No chunk `leipziger-data` (linhas 670-671), o codigo usa `dplyr::lag()` explicitamente em vez de `lag()`, evitando o conflito classico com `stats::lag()`. Boa pratica defensiva.

3. **Inline R code para reportar resultados**: O manuscrito usa `` `r ...` `` extensivamente para reportar coeficientes, SEs, e N diretamente do output dos modelos (linhas 685, 735, 773, 823). Isso garante consistencia perfeita entre tabelas e texto e elimina erros de copy-paste.

4. **Separacao clara entre replicacao e diagnostico**: A arquitetura de chunks separa: (a) leitura e preparacao de dados, (b) replicacao do modelo original com vcov clusterizado, (c) calculo do IVB com vcov = "iid", (d) formatacao da tabela. Os comentarios nos chunks de IVB explicam corretamente por que vcov = "iid" e intencional (o IVB e identidade algebrica dos coeficientes pontuais, independente dos SEs).

5. **Tratamento defensivo de razoes instáveis**: O chunk `ivb-summary-table` (linhas 588-594) verifica significancia estatistica antes de computar `IVB_pct_beta`, reportando "---" quando `|t| < 1.96`. Isso evita razoes espurias por divisao por beta proximo de zero.

6. **Escape correto de caracteres LaTeX**: O chunk `ivb-full-table` (linha 1190) escapa `%` para `\\%` nos nomes de controles (e.g., "% Muslim"), prevenindo erros de compilacao LaTeX. A funcao `kable()` e usada com `escape = FALSE` apenas quando necessario para expressoes matematicas nos headers.

7. **Comentarios sobre seguranca do cache**: Os chunks `ivb-summary-table` e `ivb-full-table` incluem comentarios explicitos documentando por que `cache=TRUE` e seguro ("CSV is generated once and versioned"). Mesmo que a invalidacao nao seja automatica, mostra consciencia do problema.

8. **Construcao robusta de formulas em `ivb_utils.R`**: A funcao `build_feols_formula()` (linhas 130-137) lida corretamente com os casos de `fe` vazio e `rhs_terms` vazio, usando `stats::as.formula()` para garantir que a formula e um objeto R valido. A separacao entre `rhs_short`, `rhs_long`, e `rhs_aux` e clara e correta.

9. **Todos os caminhos de dados verificados**: Todos os arquivos referenciados nos chunks existem nos caminhos esperados (`replication/standardized_ivb_metrics.csv`, os dois `.tab`, e `replication/ivb_utils.R`).

10. **Loop do chunk `rogowski-ivb` e idiomatico e correto**: O `do.call(rbind, lapply(...))` que itera sobre controles, excluindo cada um como `z` e usando os demais como `w`, implementa corretamente a decomposicao IVB para cada controle individualmente.
