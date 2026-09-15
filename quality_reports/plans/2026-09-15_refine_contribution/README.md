# Plano de contribuição do IVB-paper após Refine

## Entrega

- `plan.pdf`: plano completo para leitura, com oito gates e79 itens de trabalho.
- `plan.md`: fonte do plano, rechecada independentemente por Astra xhigh.
- `gates.json`: mesmos objetivos e checklists em estrutura legível por scripts; todos permanecem planejados, sem goals de execução ativados.
- `devils_advocate.md`: crítica independente da primeira versão.
- `devils_advocate_recheck.md`: resolução dos cinco achados e revalidação final.
- `plan_adjudication.json`: adjudicação das cinco críticas ao plano.
- `evidence/`: parecer original, resposta complementar fornecida na conversa, extração do PDF atual, manifestos e versões exatas do plano revisadas.

## Base científica consultada

O contrato e os sete registros de leitura estão em `quality_reports/argument_contracts/ivb-pa-refine/5375d3c27ac1/`. A adjudicação dos cinco comentários gerais e12 detalhados está em `quality_reports/adjudication/ivb-pa-refine/5375d3c27ac1/`.

A consulta bibliográfica focalizada identificou Gelbach (2016) como comparador obrigatório; a leitura integral comparativa é uma tarefa do Gate 1. Não foi concluída uma revisão sistemática da literatura nem demonstrada a originalidade do procedimento futuro.

## Reprodução do relatório

Com Python3, Pandoc e XeLaTeX disponíveis, a partir da raiz do repositório:

```bash
python3 quality_reports/plans/2026-09-15_refine_contribution/render_plan.py
```

O script renderiza apenas o plano. Ele não executa R, bootstrap ou simulações e não renderiza o manuscrito do paper. Usa as fontes Palatino, Helvetica e Menlo disponíveis neste ambiente. `pdf_header.tex` define a apresentação; o script distribui larguras das quatro tabelas para evitar colunas desproporcionais.

`build_records.py` reconstrói o contrato e a adjudicação a partir da síntese já verificada. Os registros contêm timestamps e devem ser preservados junto aos hashes: reconstruí-los cria um novo registro temporal, não uma nova avaliação independente.

## Limite de execução desta entrega

Foram produzidos somente artefatos de planejamento e revisão. O fonte e o PDF canônicos, as derivações, o código analítico e os resultados preexistentes permanecem intactos. Nenhum gate de implementação foi executado; nenhum commit ou publicação foi realizado. A versão rechecada do plano tem SHA-256 `d2d2ea2e39102ab4193ee2f82b12b0823143867a23750c38d626aa4797eb7f5d`.
