# Execução do plano de contribuição do IVB-paper

**Resultado atual:** Gate 0 aprovado; Gate 1 não aprovado, em decisão do autor. O comparador forte reproduziu a proposta, nenhuma aplicação CET foi aprovada e Gelbach integral permanece pendente. Gates 2–7 não foram executados.

## Pedido e escopo

O autor solicitou a implementação do plano de 15 de setembro e documentos rastreáveis para cada gate. A autorização cobre as etapas internas do plano, inclusive código, pilotos, simulações, reescrita e PDFs quando os gates antecedentes passarem. Mudança de rota científica após reprovação, commit, tag, push e envio permanecem decisões distintas conforme o plano.

A execução começou no commit `731cd6570651ea0f602d5c7cdff89ab43ecdb962`, com checkout limpo. Todas as 14 entradas do manifesto da preparação mantêm o SHA-256. O avanço do commit desde a preparação não altera a identidade desses arquivos.

## Registros

- [Manifesto de entrada](baseline_manifest.json): hashes, comparação com preparação e estado Git inicial.
- [Gate 0 — base documental](gate_00/decision.md): aprovado após duas rodadas de revisão independente.
- [Gate 1 — contribuição e decisão](gate_01/decision.md): equivalência demonstrada e conferida independentemente; alternativas concretas para o autor. A decisão negativa preserva a pendência bibliográfica e a ausência de aplicação CET.
- [Gate 2](gate_02/README.md), [Gate 3](gate_03/README.md), [Gate 4](gate_04/README.md), [Gate 5](gate_05/README.md), [Gate 6](gate_06/README.md) e [Gate 7](gate_07/README.md): planejados, com requisitos e dependências preservados.
- Os Gates 0 e 1 têm decisões, manifestos e revisão independente; os Gates 2–7 têm notas próprias de dependência e não execução. A aprovação exige o cumprimento do critério científico, além de integridade documental.
- O plano original e seus registros históricos ficam preservados em `quality_reports/plans/2026-09-15_refine_contribution/`.

## Como auditar o Gate 1

1. [Ficha v2 congelada](gate_01/contribution/test_prespec_v2.md): decisões, ações, perdas, dois exemplos e critério de equivalência, definidos antes de executar o teste.
2. [Derivação](gate_01/contribution/derivation.md) e [memo da contribuição](gate_01/contribution/contribution_memo.md): resultado e alternativas ainda não escolhidas.
3. [Confronto bibliográfico](gate_01/literature/reader_report.md), [matriz de 17 itens](gate_01/literature/reader_claim_comparison.csv) e [log de aquisição](gate_01/literature/acquisition_log.md): fontes lidas, localizadores e texto de Gelbach ainda indisponível.
4. [Seleção documental corrigida](gate_01/applications/selection.md): nenhum papel principal/reserva CET. O protocolo foi congelado antes da classificação, mas após exposição incidental a resultados do acervo; a revisão posterior não apaga esse limite. As versões iniciais foram preservadas em snapshots.
5. [Resultado da execução numérica](gate_01/numerical/execution_result.md): exemplos executados uma vez após revisão R independente; marcador final PASS e saídas preservadas. A [documentação de preparação](gate_01/numerical/README.md) e seu manifesto permanecem como registros da fase anterior ao teste.
6. [Adjudicação de achados](gate_01/review/coordinator_findings.md): achados confirmados, parciais e refutados, correções e revalidações. A pasta `review/snapshots/` preserva versões anteriores.

O [fonte do relatório consolidado](execution_report.md) reúne a explicação para leitura futura. `render_report.py` gera seu PDF sem executar o manuscrito RMarkdown. `validate_execution.py` verifica a integridade dos registros; esse PASS documental não aprova gates científicos pendentes.

O manifesto final `delivery_manifest.json` registra todos os arquivos desta pasta, incluindo revisões, snapshots, PDF e registros de validação. Para conferir a entrega, executar da raiz do repositório:

```bash
python3 quality_reports/execution/2026-09-15_refine_contribution/build_delivery_manifest.py --verify
python3 quality_reports/execution/2026-09-15_refine_contribution/validate_execution.py
```

Esses comandos leem os artefatos sem repetir R. O teste numérico tem instruções próprias e recusa sobrescrever a execução primária preservada. Os manifestos históricos podem descrever bytes substituídos por reparos; os snapshots e pareceres posteriores resolvem essas versões, enquanto o manifesto final registra os bytes entregues.

## Fronteiras de escrita

Os novos registros ficam neste diretório. Resultados novos dos próximos gates terão diretórios próprios e não substituirão resultados históricos. Um único integrador editará `ivb_paper_pa.Rmd` quando o plano atingir a fase correspondente. `ivb_paper_psrm.Rmd`, `ivb_paper_psrm.pdf` e o repositório irmão `IVB-SDiD` ficam fora da edição.

## Retomada

Consultar os `state.json` em ordem. Um gate planejado não foi executado. Um gate em decisão do autor não está aprovado. Os checklists guardam pendências mesmo quando uma decisão científica encerra a rota. A execução não converte uma falha em aprovação para prosseguir.

A [decisão do Gate 1](gate_01/decision.md) oferece contribuição aplicada/pedagógica, extensão inferencial específica, avaliação operacional ou suspensão. Nenhuma alternativa foi escolhida automaticamente. O pedido de eventual cópia local de Gelbach continua aberto.
