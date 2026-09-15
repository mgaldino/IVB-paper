# Frente de contribuição do Gate 1

**Resultado do designer:** a proposta congelada é reproduzida pelo comparador FWL forte no domínio examinado. Há material aplicado/didático útil, mas nenhuma capacidade metodológica distinta foi demonstrada nesta frente. A revisão independente e a decisão do gate estão pendentes.

## Ordem de leitura

1. `contribution_onepage.md`: problema, usuário, decisão, comparador e acréscimo exigido.
2. `test_prespec_v2.md` e `test_prespec_v2.json`: ficha governante, congelada antes da implementação/teste numérico.
3. `derivation.md`: prova explícita, dois exemplos, inferência e alcance da equivalência.
4. `expected_analytical_results.json`: expectativas analíticas em formato legível por máquina, **não executadas** pelo designer.
5. `contribution_memo.md`: confronto da contribuição, ataque Gelbach + checklist e opções concretas para o autor.
6. `manifest.json`: hashes da entrega, arquivos de entrada governantes e validação documental.

## Congelamentos e mudança pré-teste

`freeze_prespec_v1.json` preserva a primeira ficha, congelada às 12:02:10 UTC de 15/09/2026. Antes de qualquer teste, o coordenador observou que a comparação simples também recebe as equações e momentos e poderia reconstruir os componentes. A versão 2 explicitou C0 como relatório com campos omitidos, sem atribuir impossibilidade informacional ou perda a essa omissão. Nenhuma célula foi alterada.

`freeze_prespec_v2.json`, congelado às 12:03:13 UTC, governa a implementação. O designer comunicou esse congelamento ao coordenador antes de entregar as expectativas numéricas derivadas. V1 e V2 permanecem preservadas. As novas notas explicam a ficha; não a modificam.

## Fronteiras de responsabilidade

O designer escreveu somente nesta pasta e produziu derivações/documentos. O implementador numérico e o revisor de código devem ser outras pessoas/agentes; qualquer execução R depende de `review-r` independente antes de rodar, segundo as instruções vigentes do projeto. A revisão científica deste artefato também é independente.

O manifesto registra verificação de JSONs, hashes, referências locais e consistência documental. Não chama isso de validação de prova, execução analítica ou cobertura. A leitura integral de Gelbach e a aplicação são dependências separadas do Gate 1. Esta frente não edita manuscrito, decide gênero, executa aplicação ou aprova o gate.

## Base

Base recebida: `731cd6570651ea0f602d5c7cdff89ab43ecdb962`. HEAD observado: `b17c0a47a2b0f4526d03fdfccf5380fe60b5bc2f`. O coordenador informou que a mudança corresponde a um checkpoint de registros da execução; esta frente não executou commit. Os hashes de manuscrito, plano e congelamento Gate 0 continuaram iguais aos recebidos.

O manuscrito ativo continua `ivb_paper_pa.Rmd`, SHA-256 `12493a67133f988c5e6a13933bf2b89c0d9880e96bae329248a207b3aeaf7b5e`. O contrato governante permanece `quality_reports/argument_contracts/ivb-pa-refine/5375d3c27ac1/argument_contract.json`.
