# Reparo da verificação numérica — rodada 2

**Data:** 15 de setembro de 2026. **Estado:** código preparado para nova revisão
estática independente; nenhum R executado ou parseado. **Escopo:** somente os
quatro achados `G1-NUM-01` a `G1-NUM-04` classificados como `CONFIRMED` em
`../review/coordinator_findings.md`.

## Identidade

Versão anterior preservada, sem edição, em
`../review/snapshots/numerical_round1/`:

- `verify_examples.R`:
  `eaa328c2c7394c27443f28481f0fc2ebb9436534ad4c1bc390203a88ca7beae6`;
- `README.md`:
  `543829a14cf7cc17ed203e516f9b19c1dab1c3abecb808213b4e0a35b5ff7cdb`;
- `source_manifest.json`:
  `d07fef66fca01c424146e3304c0bb13685309078b1be988fb0d6823f7a7ac208`.

Versão reparada entregue à nova revisão:

- `verify_examples.R`:
  `98b4fbc20bdce3d03eaae7e1828a34a2c37e1e07c7f46cb848cc32131aff7127`;
- `README.md`:
  `d29514a2f655c2f7efa6cb6cda28e934d5d6b0b0ae38c883fb812d3389806c4b`.

## Achados e reparos

| Achado | Reparo implementado | Condição agora verificada |
|---|---|---|
| `NUM-01` | `sha256_file()` chama o `shasum` externo com `LC_ALL=C` e `LANG=C`, preserva o status do subprocesso, exige uma linha e aceita exatamente um campo hexadecimal de 64 caracteres na primeira posição. | Avisos do locale herdado não contaminam a saída; status diferente de zero, número inesperado de linhas ou formato inválido interrompem a execução. |
| `NUM-02` | As ações esperadas foram transcritas para oráculos declarativos separados das funções que classificam os outputs. As ações causais são entradas analíticas explícitas, armazenadas separadamente do oráculo. `descriptive_loss_from_oracle()` e `causal_loss_from_oracle()` calculam perdas 0/1/4. | Cada ação é confrontada com seu alvo e cada perda pontuada precisa ser zero para `overall_pass`. As omissões E1 de C0 permanecem sem pontuação. A saída honesta `somente_descritivo` de E2 recebe perda zero somente com os dois certificados condicionais corretos. |
| `NUM-03` | `e2_gm_under_do_D()` e `e2_gf_under_do_D()` calculam `Y` sob `do(D=0)` e `do(D=1)` diretamente nas equações dos SCMs, mantendo os erros fixos. | Os efeitos recalculados são confrontados separadamente com os alvos 2 e 1; sua diferença é calculada a partir desses resultados. |
| `NUM-04` | `run_log.txt` registra o resultado das verificações e mantém a entrega como pendente. Depois de todas as saídas obrigatórias, `output_manifest.csv` é gravado e seu hash é recalculado. Somente então `final_status.txt` pode receber `status=PASS`. | Qualquer encerramento anterior deixa ou cria `status=FAILED`. O manifesto exclui a si próprio e o marcador final; `final_status.txt` registra o hash do manifesto, eliminando circularidade. |

## Escopo preservado

A implementação OLS, os fixtures, as seis células/grafos, as auxiliares FWL,
os sinais e as transformações de covariância aprovadas na primeira revisão não
foram reestruturados. O reparo não acrescenta simulação, amostragem, solver de
DAG, bootstrap, dados reais, intervalo, cobertura ou afirmação sobre clusters.
Os efeitos intervencionais vêm dos SCMs sintéticos conhecidos da ficha.

## Verificação desta entrega

- Os hashes foram recalculados no shell com `LC_ALL=C LANG=C shasum -a 256`.
- O diff contra `snapshots/numerical_round1/` foi inspecionado para confirmar o
  escopo dos quatro reparos.
- O manifesto JSON foi validado com `python3 -m json.tool` e os arquivos foram
  submetidos a checagem estática de whitespace.
- Nenhum comando R, `parse()`, `source()` ou carregamento de runtime R foi
  executado. Não existe `numerical/results/` nesta entrega pré-revisão.

Essas verificações são de integridade e escopo. Correção sintática e execução
do R continuam pendentes da nova revisão independente e da liberação posterior
do coordenador.
