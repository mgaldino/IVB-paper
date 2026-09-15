# Included Variable Bias in Dynamic Panels

Este repositório contém o paper principal sobre mudanças de especificação causadas pela inclusão de covariadas potencialmente responsivas ao tratamento em painéis dinâmicos.

## Manuscrito ativo

- Fonte canônica: `ivb_paper_pa.Rmd`
- PDF correspondente: `ivb_paper_pa.pdf`
- Título: *From Specification Shifts to Included Variable Bias in Dynamic Panels*
- Estado substantivo preservado desde o commit `c281e6926437e41c7660b573457ae746d6f8a3aa` (2026-07-12)

A identidade de Frisch–Waugh–Lovell mede uma mudança entre projeções aninhadas. Sua interpretação como viés causal depende separadamente do estimando, do relógio temporal, do DAG e das condições de identificação.

`ivb_paper_psrm.Rmd` e `ivb_paper_psrm.pdf` são uma versão histórica, preservada desde o commit `51c3a34dbf68dd4a8fc07adb9f481e8acac355fb` (2026-03-23). Eles não são o manuscrito ativo.

## Extensão SDiD

A extensão para estimadores com pesos adaptativos está isolada na branch `feature/ivb-sdid-factor-models`, em um worktree próprio. Ela contém um manuscrito, uma derivação e uma aplicação diferentes do paper principal. O snapshot pendente foi preservado no commit `67aa080`.

A extensão é candidata a um repositório independente. Até essa decisão ser executada, ela não deve ser fundida em `main` nem tratada como nova versão do manuscrito PA.

## Estrutura

- `derivations/`: identidades, condições de identificação e notas teóricas.
- `simulations/`: scripts, resultados e diagnósticos de Monte Carlo.
- `replication/`: aplicações e resultados reproduzíveis.
- `plots/`: figuras geradas pelos scripts.
- `quality_reports/`: planos, revisões e auditorias.

Os cálculos permanecem nos scripts R; os Rmds apresentam resultados já produzidos. Consulte `CLAUDE.md` antes de executar análises, compilar manuscritos, commitar ou criar tags.

## Versionamento

As versões científicas e os checkpoints de migração são preservados por tags Git anotadas:

- `paper/psrm-2026-03-23`: versão PSRM de 49 páginas, no commit `51c3a34`.
- `paper/pa-2026-07-12`: versão PA de 22 páginas, no commit `c281e69`.
- `archive/ivb-sdid-pre-split-2026-09-14`: checkpoint da extensão antes da separação de repositório, no commit `6a22a4b`.

As tags são locais até que seu envio ao remoto seja autorizado. Para recuperar ou comparar uma versão, use `git show <tag>:<arquivo>` e `git diff <tag1> <tag2> -- <arquivo>`.
