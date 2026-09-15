# Leitura e preflight do coordenador

## Base efetivamente verificada

O checkout iniciou limpo em `main`, commit `731cd6570651ea0f602d5c7cdff89ab43ecdb962`. As 14 entradas do manifesto da preparação mantêm os hashes registrados. O manifesto desta execução acrescenta o plano e os dois arquivos históricos PSRM, totalizando 17 entradas. A mudança de commit desde a preparação não alterou essas fontes.

O coordenador leu integralmente `ivb_paper_pa.Rmd`, o parecer original, a resposta complementar e o plano. Leu o contrato e as derivações de identificação, deslocamento versus viés, múltiplos controles e incerteza. A revisão científica das provas pertence aos gates posteriores: esta leitura fixa o objeto e as dependências.

## Cobertura do PDF

O PDF canônico de 22 páginas foi renderizado, sem recompilar o manuscrito, com:

```bash
pdftoppm -scale-to 1000 -png ivb_paper_pa.pdf /tmp/ivb-gate0-pdf/page
```

Foram inspecionadas as 22 páginas em seis folhas de contato. O PDF contém sete seções, cinco figuras e oito tabelas. As figuras 1–3 explicitam os DAGs; a figura 4 omite o controle contemporâneo nos quatro modelos exibidos; a figura 5 compara viés médio e deslocamento médio. As tabelas 6–8 correspondem aos alvos mistos e às duas aplicações discutidas no parecer.

Esta inspeção confirma cobertura e presença dos objetos. Não é o controle final de diagramação do Gate 7. Algumas tabelas têm letra muito pequena e a nota dentro da figura 4 parece chegar ao limite direito; a região deverá ser conferida em resolução completa se essa figura for mantida na reescrita.

## Distinções preservadas

1. O produto FWL descreve inclusão aninhada na mesma amostra. O verbo “moved”, na linha 451, pode representar substituição e precisa de tratamento próprio.
2. A hipótese de intercambialidade completa existe na nota de identificação. A versão abreviada do corpo omite os efeitos fixos. Não se atribui essa omissão à cadeia inteira sem leitura.
3. A ressalva de mediação está na seção de DAGs, mas “Only the DAG”, na linha 441, a comprime indevidamente.
4. O IC de 95% com cobertura mínima de 0,700 é do coeficiente longo relativo ao CET. A nota de inferência declara não ter executado bootstrap ou calibrado cobertura de um intervalo para o deslocamento.
5. O manuscrito executa regressões nas aplicações dentro do Rmd. Retirar esses cálculos exige a etapa analítica autorizada pelo plano; não é uma compilação neutra.
6. Leipziger e Rogowski já são descritos como contrastes defasado/prospectivo com timing ambíguo. Essa limitação reconhecida impede tratá-los como aplicações CET prontas.

## Fronteiras

A execução grava novos documentos exclusivamente em `quality_reports/execution/2026-09-15_refine_contribution/` nesta etapa. O manuscrito ativo, a versão histórica PSRM, os resultados antigos e o repositório IVB-SDiD foram preservados. Cópias históricas do parecer e contrato não são regravadas.

## Executado e não executado

Executados: leitura de fontes e instruções, comparação SHA-256, inspeção Git, renderização do PDF existente para imagens e criação dos registros de oito gates. Os agentes registram separadamente seus validadores e conferências documentais.

Não executados nesta etapa: bootstrap, simulações, reestimação das aplicações, renderização do Rmd, alteração de manuscrito, commit, tag ou envio. O pedido atual já autoriza as análises internas quando suas dependências científicas passarem; não há nova exigência de permissão para cada gate.
