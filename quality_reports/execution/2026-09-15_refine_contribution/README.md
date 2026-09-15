# Execução do plano de contribuição do IVB-paper

## Pedido e escopo

O autor solicitou a implementação do plano de 15 de setembro e documentos rastreáveis para cada gate. A autorização cobre as etapas internas do plano, inclusive código, pilotos, simulações, reescrita e PDFs quando os gates antecedentes passarem. Mudança de rota científica após reprovação, commit, tag, push e envio permanecem decisões distintas conforme o plano.

A execução começou no commit `731cd6570651ea0f602d5c7cdff89ab43ecdb962`, com checkout limpo. Todas as 14 entradas do manifesto da preparação mantêm o SHA-256. O avanço do commit desde a preparação não altera a identidade desses arquivos.

## Registros

- `baseline_manifest.json`: hashes atuais, comparação com preparação e estado Git de entrada.
- `gate_00` a `gate_07`: objetivo, critérios, checklist, estado, artefatos e revisões de cada etapa.
- Cada gate será encerrado com decisão explícita e manifesto dos bytes revisados. A aprovação exige revisão independente.
- O plano original e seus registros históricos ficam preservados em `quality_reports/plans/2026-09-15_refine_contribution/`.

## Fronteiras de escrita

Os novos registros ficam neste diretório. Resultados novos dos próximos gates terão diretórios próprios e não substituirão resultados históricos. Um único integrador editará `ivb_paper_pa.Rmd` quando o plano atingir a fase correspondente. `ivb_paper_psrm.Rmd`, `ivb_paper_psrm.pdf` e o repositório irmão `IVB-SDiD` ficam fora da edição.

## Retomada

Consultar os `state.json` em ordem. Um gate planejado não foi executado. Um gate em decisão do autor não está aprovado. Os checklists guardam pendências mesmo quando uma decisão científica encerra a rota. A execução não converte uma falha em aprovação para prosseguir.
