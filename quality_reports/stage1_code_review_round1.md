# Code Review --- Round 1: ivb_paper_psrm.Rmd + ivb_utils.R

**Reviewer**: Claude Code (Automated Review Agent)
**Date**: 2026-02-28
**Files Reviewed**:
1. `ivb_paper_psrm.Rmd` (1131 lines, 17 R chunks)
2. `replication/ivb_utils.R` (204 lines)

---

## Score: 72/100

---

## Arquivos revisados

- `/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/ivb_paper_psrm.Rmd` -- Paper Rmd com 17 chunks R embutidos (setup, 2 include_graphics, 6 data/replication chunks, 4 IVB computation chunks, 4 simulation/figure chunks)
- `/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/replication/ivb_utils.R` -- Funcao `compute_ivb_multi()` (189 linhas de codigo efetivo)

---

## Issues por severidade

### Critico

Nenhuma issue critica encontrada. A logica de calculo do IVB esta correta em todos os chunks. Seeds estao fixadas em todas as simulacoes. Paths de dados sao relativos e portaveis. A formula IVB = -theta * pi esta implementada corretamente tanto em `compute_ivb_multi()` quanto nos chunks de simulacao.

### Major

1. **vcov inconsistente entre replicacao e diagnostico IVB** (-10)
   - **Arquivo**: `ivb_paper_psrm.Rmd`, chunks `leipziger-replication` (linha 692) e `leipziger-ivb` (linha 714); chunks `rogowski-replication` (linha 772) e `rogowski-ivb` (linha 798)
   - **Descricao**: Os modelos de replicacao usam `vcov = ~country_id` (erros-padrao clusterizados por pais), mas as chamadas a `compute_ivb_multi()` usam `vcov = "iid"`. Embora os coeficientes pontuais (beta, theta, pi) sejam identicos independentemente do vcov -- e o IVB seja uma identidade algebrica de coeficientes -- os objetos `models` retornados por `compute_ivb_multi()` contem SEs iid. Se alguem extrair SEs desses objetos para comparar com os reportados no texto (que vem dos modelos clusterizados), havera discrepancia. Alem disso, se `IVB_over_SE` for computado a partir dos modelos internos, usara SEs iid quando o paper justifica SEs clusterizados para as aplicacoes empiricas.

2. **cache = TRUE habilitado globalmente pode mascarar erros de dependencia** (-10)
   - **Arquivo**: `ivb_paper_psrm.Rmd`, chunk `setup` (linhas 34-43)
   - **Descricao**: `cache = TRUE` e definido em `knitr::opts_chunk$set()`, ativando cache para todos os chunks por padrao. Isso significa que alteracoes em `replication/ivb_utils.R` ou nos dados de replicacao NAO invalidam automaticamente o cache dos chunks que dependem deles. O chunk `setup` faz `source("replication/ivb_utils.R")`, mas os chunks downstream (e.g., `leipziger-ivb`, `rogowski-ivb`) que usam `compute_ivb_multi()` so serao recalculados se seu proprio codigo mudar -- nao se a funcao que chamam mudar. Isso pode levar a resultados stale apos editar `ivb_utils.R`.

### Minor

1. **Magic numbers na normalizacao do indice SEI sem comentario** (-2)
   - **Arquivo**: `ivb_paper_psrm.Rmd`, chunk `leipziger-data` (linha 676)
   - **Codigo**: `dat_lp$SEI <- (dat_lp$v2peapssoc - 3.37) / (-3.135 - 3.37)`
   - **Descricao**: Os valores 3.37 e -3.135 sao os limites teoricos da variavel V-Dem `v2peapssoc` usados para reescalar o indice ao intervalo [0, 1]. Nao ha comentario explicando a origem desses valores. Um leitor nao familiar com V-Dem nao sabera de onde vem.

2. **Magic numbers no DGP da simulacao ADL sem comentario inline** (-2)
   - **Arquivo**: `ivb_paper_psrm.Rmd`, linhas 1013-1018
   - **Codigo**: `N <- 200; T_periods <- 20; beta_true <- 1; rho_val <- 0.5; delta_d <- 0.6; delta_y <- 0.4`
   - **Descricao**: Embora o Appendix D (linha 1115) documente esses parametros no texto, o chunk em si nao tem comentario. Quem le o codigo isolado precisa procurar no Appendix para entender as escolhas.

3. **Import `library(haven)` carregado mas nao utilizado** (-2)
   - **Arquivo**: `ivb_paper_psrm.Rmd`, chunk `setup` (linha 50)
   - **Descricao**: O pacote `haven` e carregado, mas nenhum chunk usa funcoes do haven (como `read_dta()`, `read_sav()`). Todos os dados sao lidos com `read.csv()` ou `read.delim()`. O import e desnecessario e adiciona tempo de carregamento.

4. **dpi = 300 global irrelevante para chunks com include_graphics** (-2)
   - **Arquivo**: `ivb_paper_psrm.Rmd`, chunk `setup` (linha 42) vs chunks `fig-heatmap-A` (linha 584) e `fig-heatmap-B` (linha 588)
   - **Descricao**: O `dpi = 300` e definido globalmente, mas os chunks de heatmap A e B usam `knitr::include_graphics()` para PNGs pre-gerados externamente. O parametro `dpi` so afeta chunks que geram plots via R; para `include_graphics`, e ignorado. Nao causa erro, mas pode dar a impressao errada de que esses plots foram gerados a 300 dpi pelo Rmd.

5. **Nomes de parametros `delta_d`/`delta_y` no Appendix diferem da notacao `gamma_D`/`gamma_Y` da Secao 5** (-2)
   - **Arquivo**: `ivb_paper_psrm.Rmd`, chunk `appendix-adl-setup` (linhas 992, 1003) e texto do Appendix D (linha 1115)
   - **Descricao**: A funcao `sim_adl_panel()` usa `delta_d` e `delta_y` como parametros do collider, enquanto a Secao 5 (Monte Carlo principal) usa `gamma_D` e `gamma_Y`. Ambas as notacoes sao internamente consistentes dentro de suas secoes, mas o uso de `delta` pode confundir porque `delta` e usado no CLAUDE.md e na Secao 5 para o efeito confounding de Z (onde `delta = 0` significa sem confounding). Embora o Appendix D use explicitamente `delta_d`/`delta_y` na descricao do DGP 2, a sobreposicao de nomes reduz clareza.

6. **Coluna `id` gerada mas nao usada nos modelos da simulacao ADL** (-2)
   - **Arquivo**: `ivb_paper_psrm.Rmd`, chunk `appendix-adl-setup` (linhas 1004, 1023-1025)
   - **Descricao**: A funcao `sim_adl_panel()` cria `id = i` no data frame, mas os modelos `lm(Y ~ D + Y_lag, data = df)` nao usam FE por unidade. A coluna `id` e bagagem morta no data frame. O DGP nao inclui unit FE (o que e correto para a demonstracao), mas gerar `id` sem usa-lo pode confundir o leitor.

7. **Chunk `leipziger-ivb-table` sem `cache = TRUE` explicito** (-2)
   - **Arquivo**: `ivb_paper_psrm.Rmd`, chunk `leipziger-ivb-table` (linha 719)
   - **Descricao**: Este chunk depende de `r_lp <- ivb_lp$results` do chunk anterior (`leipziger-ivb`, que tem `cache = TRUE`). O chunk `leipziger-ivb-table` nao tem `cache = TRUE` explicito, mas herda do global. Se o cache do chunk anterior for invalidado mas o deste nao, haveria inconsistencia. Na pratica, knitr gerencia dependencias inter-chunks corretamente quando se usa `cache = TRUE` global, entao isso nao causa erro -- mas a dependencia implicita e fragil.

---

## Calculo do score

```
Score inicial: 100

Major (-10 cada):
  1. vcov inconsistente (cluster vs iid) entre replicacao e IVB:  -10
  2. cache = TRUE global pode mascarar erros de dependencia:       -10

Minor (-2 cada):
  3. Magic numbers SEI (3.37, -3.135) sem comentario:              -2
  4. Magic numbers DGP ADL sem comentario inline:                   -2
  5. Import haven carregado mas nao utilizado:                      -2
  6. dpi=300 global irrelevante para include_graphics:              -2
  7. Nomes delta_d/delta_y vs gamma_D/gamma_Y inconsistentes:       -2
  8. Coluna id gerada mas nao usada nos modelos ADL:                -2
  9. Dependencia implicita entre chunks de tabela e IVB:            -2

Total de deducoes: -10 -10 -2 -2 -2 -2 -2 -2 -2 = -34
Nota: deducoes de minor limitadas a 7 items x (-2) = -14

Subtotal: 100 - 10 - 10 - 14 = 66
```

**Ajuste**: Reavaliando issue 9 (dependencia inter-chunks). O knitr gerencia isso corretamente com cache global -- nao e uma issue real. Removo a deducao.

```
Score final: 100 - 10 - 10 - 12 = 68
```

**Ajuste 2**: Reavaliando issue 6 (dpi global). Isso e um non-issue na pratica -- dpi para include_graphics e controlado pelo `out.width` e resolucao da imagem de entrada, nao pelo dpi do chunk. Removo.

```
Score final: 100 - 10 - 10 - 10 = 70
```

**Ajuste 3**: Mantendo todas as minor restantes (5 items validos).

```
Score final definitivo:
  100
  - 10 (vcov inconsistente)
  - 10 (cache global)
  - 2  (magic numbers SEI)
  - 2  (magic numbers DGP ADL)
  - 2  (haven nao utilizado)
  - 2  (nomes delta vs gamma)
  - 2  (coluna id nao usada)
  ---------
  = 70

Arredondado com ajuste por qualidade geral do ivb_utils.R: +2
(a funcao utilitaria e exemplar em validacao, documentacao e estrutura)

Score final: 72/100 -> APROVADO (limiar >= 60)
```

---

## Pontos positivos

### ivb_utils.R

1. **Validacao de inputs exemplar**: 14 checks de validacao cobrindo tipo, comprimento, sobreposicao entre argumentos, e existencia de variaveis no data frame. Mensagens de erro claras e informativas com `call. = FALSE`.

2. **Documentacao roxygen completa**: Todos os parametros documentados com tipo, descricao e default. Valor de retorno detalhado com todos os componentes da lista.

3. **Sanity check `diff_check`**: O campo `diff_check = ivb_formula - ivb_direct` permite verificar que a identidade algebrica IVB = beta_long - beta_short = -theta * pi e satisfeita numericamente. Isso e crucial para deteccao de bugs.

4. **Tratamento configuravel de NAs**: `na_action = c("omit", "fail")` com `match.arg` e um design robusto que permite uso flexivel sem surpresas.

5. **Deteccao de collinearidade**: Verifica se `theta` ou `beta` sao `NA` apos estimacao e emite erro informativo.

### ivb_paper_psrm.Rmd

6. **Seeds fixadas em todas as simulacoes**: `set.seed(123)` (heatmap cross-section, linha 958), `set.seed(42)` (ADL, linha 1020), `set.seed(77)` (rho_grid, linha 1070). Reprodutibilidade garantida.

7. **Separacao clara entre replicacao e diagnostico**: Cada aplicacao empirica tem chunks separados e nomeados (dados, replicacao, IVB, tabela). Facilita depuracao e navegacao.

8. **Paths relativos e portaveis**: `source("replication/ivb_utils.R")` e paths de dados usam caminhos relativos ao diretorio do Rmd. Funciona em qualquer maquina que tenha o repositorio clonado.

9. **Tabelas LaTeX bem formatadas**: Uso correto de `escape = FALSE` para math, `booktabs = TRUE`, alinhamento consistente, e captions descritivos.

10. **Inline R code para valores dinamicos**: Os resultados no texto sao referenciados via `` `r round(...)` `` em vez de hardcoded, garantindo consistencia entre codigo e texto.

11. **Simulacao heatmap cross-section elegante**: O chunk `fig-heatmap` (linha 952) usa `rowwise() %>% mutate()` para iterar sobre o grid de parametros de forma compacta e legivel. O plot com `geom_tile` + `geom_text` e informativo e auto-contido.

12. **Formula IVB verificada em 3 contextos**: Cross-section (chunk heatmap), ADL sem FE (chunk ADL scatter), e painel com FE (via `compute_ivb_multi` nas aplicacoes). Todos confirmam a identidade.

---

## Recomendacoes

1. **Unificar vcov nas aplicacoes empiricas**: Passar `vcov = ~country_id` para `compute_ivb_multi()` nos chunks Leipziger e Rogowski, ou adicionar um comentario explicito justificando que `vcov = "iid"` e intencional porque o IVB depende apenas de coeficientes pontuais. Exemplo:
   ```r
   # vcov="iid" is intentional: IVB is an algebraic identity of point estimates,
   # independent of standard error computation. Clustered SEs are used only in
   # the replication models above for inference on the treatment effect.
   ```

2. **Substituir cache global por cache seletivo**: No chunk `setup`, usar `cache = FALSE` como default e adicionar `cache = TRUE` apenas nos chunks computacionalmente caros. Alternativa: usar `cache.extra` para invalidar cache quando dependencias mudam:
   ```r
   # No setup:
   knitr::opts_chunk$set(cache = FALSE, ...)
   # Nos chunks caros:
   # ```{r leipziger-data, cache=TRUE, cache.extra=tools::md5sum("replication/ivb_utils.R")}
   ```

3. **Comentar os magic numbers do SEI**: Adicionar uma linha antes da normalizacao:
   ```r
   # Rescale V-Dem v2peapssoc to [0,1] using theoretical bounds [-3.135, 3.37]
   dat_lp$SEI <- (dat_lp$v2peapssoc - 3.37) / (-3.135 - 3.37)
   ```

4. **Remover `library(haven)`**: Nao e utilizado. Se for mantido como precaucao para futuras leituras de .dta, adicionar comentario.

5. **Unificar notacao delta/gamma**: Renomear `delta_d` e `delta_y` para `gamma_D` e `gamma_Y` no DGP do Appendix, ou adicionar comentario explicando que a notacao difere intencionalmente da Secao 5. A segunda opcao e mais segura se o Appendix D ja foi publicado com essa notacao.

6. **Remover coluna `id` nao usada ou adicionar FE**: Na funcao `sim_adl_panel()`, ou remover `id = i` do data frame (ja que os modelos nao usam FE), ou adicionar um comentario explicando que o id esta presente para possivel extensao futura.
