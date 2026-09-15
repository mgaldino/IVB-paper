# Gate 0 inventory — correction round 2

**Data:** 2026-09-15  
**Escopo:** correção documental restrita a T06 e ao trecho dependente do `memo.md`. Nenhuma outra linha do inventário foi alterada; nenhum arquivo fora de `gate_00/inventory/` foi escrito.

## Achado corrigido

A revisão independente e a conferência do coordenador identificaram um falso negativo em `task_inventory.csv`: a linha T06 dizia que não havia tabela dedicada de condições de escopo. Os bytes atuais de `ivb_paper_pa.Rmd` mostram a tabela integral em `ivb_paper_pa.Rmd:479-499`:

- caption na linha 481: “Standardized scope conditions for using ADL + FE with lagged state variables as a CET baseline”;
- label na linha 482: `tab:adl_identification_estimation_pa`;
- oito condições substantivas nas linhas 489–496, incluindo relógio/CET, história/exchangeability, média condicional dinâmica, forma funcional, efeitos fixos/choques comuns, suporte, `T` finito e inferência.

## Mudança aplicada

- `task_inventory.csv:T06` agora aponta para `ivb_paper_pa.Rmd:479-499` e registra a tabela como existente.
- O status continua `partial_text_integration` porque a presença do artefato não resolve, por si só, sua suficiência, coerência com as hipóteses e auditoria de rótulos/ocorrências residuais. Essas questões permanecem nos gates 2–3/6.
- `memo.md` agora distingue explicitamente existência da Table 3 de sua revisão substantiva e não descreve a tabela como ausente.

## Verificação da correção

- Parsing CSV após a alteração: `task_inventory.csv` permanece com 26 linhas e 8 colunas.
- Fonte conferida por `nl -ba ivb_paper_pa.Rmd | sed -n '468,508p'`.
- Nenhum comando R, simulação, renderização ou reestimação foi executado.

## SHA256 após a correção

```text
b3fabecd53ac00149a5ea1c2a80bc416f2617b646f8bfa67cf43e3432817d656  task_inventory.csv
5710d59fd525045a81dadf5d56a537aa7df88ceffd85eb9a0cb95f2641b87bf7  memo.md
c4468cbc7670f3f39cb28fabe583df6d80e552cafa06f99226ce53b44a6e17e9  application_candidates.csv
ad1187f3ab90ccbd7acca44f42f301efa412989ab028622f1a49f9e9565a8b23  rogowski_additional_comparisons.csv
3708ca3f6dcdb9306bd3148d292a955f66912bd695d228910a54930fd264ea7e  number_provenance.csv
bf17de583f91b6da2a1cc05525d034c5ce4adcfea93c779da7d540bd03548469  input_sha256.csv
```

O hash da fonte ativa permanece o registrado no manifesto de base: `ivb_paper_pa.Rmd = 12493a67133f988c5e6a13933bf2b89c0d9880e96bae329248a207b3aeaf7b5e`.
