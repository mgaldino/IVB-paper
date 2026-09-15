# Gate 1 — verificação numérica determinística

## Estado

Código reparado após os quatro achados numéricos confirmados na primeira
revisão e ainda não executado. Os bytes anteriores estão preservados em
`../review/snapshots/numerical_round1/`. A execução depende de nova revisão
`review-r` por agente independente e de liberação explícita do coordenador,
conforme `CLAUDE.md`. Também não foi usado `parse()` para validar o arquivo R
antes dessa nova revisão.

O mapa entre cada achado confirmado e o reparo correspondente está em
`repair_round2.md`.

A fonte governante é a ficha v2 congelada em
`../contribution/freeze_prespec_v2.json` às
`2026-09-15T12:03:13.129547+00:00`:

- `test_prespec_v2.md`: SHA-256
  `37562fccf615793d0b589b58303e0afeb225edd73ea85e44a7bb1b7688be7097`;
- `test_prespec_v2.json`: SHA-256
  `12affe0250af02ada1fc4213a1067ccfe5b482fa5d7a78c52261069c7e7ff00f`.

O script confere esses dois hashes antes de criar resultados e interrompe a
execução se algum deles divergir. O cálculo usa o programa externo `shasum`
com `LC_ALL=C` e `LANG=C`; valida o status do subprocesso, exige uma única linha
e aceita apenas um primeiro campo hexadecimal de 64 caracteres.

## O que o script verifica

`verify_examples.R` usa somente base R e preserva todas as células
preespecificadas:

1. **E1:** constrói as oito linhas lexicográficas do fixture ortogonal para
   `E1-central`, `E1-menos`, `E1-mais` e `E1-nulo`; ajusta B, C e U diretamente
   para P e, em implementação independente, ajusta B, C, U e as auxiliares
   `Z ~ D + L` e `L ~ D + Z` para C+.
2. **E2:** constrói fixtures determinísticos para `G_M` e `G_F`, calcula as
   matrizes observáveis por transformação linear das variâncias estruturais e
   verifica que as duas covariâncias são iguais, embora os efeitos totais sob
   `do(D)` sejam 2 e 1.
3. Confronta cada projeção calculada com a expressão algébrica congelada;
   verifica sinais, inclusão, retirada e diferença dos endpoints. Um oráculo
   declarativo separado fixa as ações esperadas das quatro células E1 e de E2.
   Funções próprias calculam as perdas 0/1/4 contra esse oráculo. Os
   certificados causais são rotulados como entradas analíticas fornecidas e
   conferidas, sem solver de DAG ou descoberta causal.
4. Registra postos, números de condição, equações normais, identificadores de
   linha e transformação comum. Nenhuma célula é filtrada pelo resultado.
5. Usa o mesmo sandwich HC0 empilhado para transportar a covariância dos
   coeficientes. Compara `A V A'` e `a V a` aos contrastes diretos e compara a
   linearização dos produtos `-theta*pi` à dos endpoints por suas funções de
   influência.
6. Recalcula a resposta de `Y` à intervenção `do(D: 0 -> 1)` nas equações de
   `G_M` e `G_F`, mantendo os erros estruturais fixos, e confronta os efeitos
   obtidos com os alvos 2 e 1.

O item 5 é uma checagem algébrica no fixture. Os arquivos não reportam erros
padrão ou intervalos e não fornecem evidência de calibração, cobertura ou
validade de um procedimento inferencial.

C0 registra os endpoints e as diferenças que a ficha lhe atribui. Seus
componentes omitidos aparecem como `campo_nao_reportado`, sem perda e sem
atribuição de ganho informacional a P ou C+.

## Comando para execução futura

Executar a partir da raiz do repositório, somente após as duas liberações
registradas acima:

```bash
Rscript --vanilla quality_reports/execution/2026-09-15_refine_contribution/gate_01/numerical/verify_examples.R
```

A execução primária grava em `numerical/results/primary/`. Se esse diretório já
existir, o script falha antes de sobrescrever qualquer arquivo. Para uma
reexecução local explicitamente identificada, usar:

```bash
Rscript --vanilla quality_reports/execution/2026-09-15_refine_contribution/gate_01/numerical/verify_examples.R --allow-rerun-local
```

Cada reexecução recebe um diretório novo no formato
`results/rerun_<UTC>_pid<PID>/`; colisões também falham. O script nunca apaga nem
substitui um resultado anterior.

## Saídas previstas por execução

- `synthetic_fixture_e1.csv` e `synthetic_fixture_e2.csv`: oito linhas por
  célula ou grafo, rotuladas como fixtures de álgebra;
- `expected_vs_computed_projections.csv`: valores esperados pela álgebra,
  outputs e tolerâncias;
- `actions_and_losses.csv`: decisões descritivas e causais, certificados
  condicionais e vetor de perdas;
- `sign_checks.csv`: sinais dos passos e shifts;
- `input_consistency.csv` e `rank_and_conditioning.csv`: linhas comuns, posto,
  condicionamento e equações normais;
- `e2_observable_covariances.csv` e `e2_interventional_effects.csv`: matrizes
  de `G_M` e `G_F` e respostas à intervenção unitária calculadas nas equações;
- `covariance_transform_checks.csv`, `covariance_matrices.csv` e
  `product_gradients.csv`: transporte determinístico de covariância e
  gradientes usados;
- `procedure_comparison.csv` e `validation_checks.csv`: comparação P/C+ e
  resultado de todas as identidades, sem seleção de linhas aprovadas;
- `run_log.txt`, `sessionInfo.txt`, `output_manifest.csv` e
  `final_status.txt`: log das verificações, ambiente R, hashes das saídas e
  marcador autoritativo final.

O log nunca declara o sucesso final: ele registra `verification_checks` e
`delivery_status=PENDING_FINALIZATION`. O manifesto inclui todas as saídas
obrigatórias anteriores e exclui seu próprio hash e `final_status.txt` para
evitar circularidade. Somente depois de gravar e recalcular o hash do manifesto
o script pode criar `final_status.txt` com `status=PASS`. Qualquer falha anterior
deixa ou cria `final_status.txt` com `status=FAILED` e encerra o processo com
erro.

## Limites

Os oito pontos são suporte finito criado para reproduzir produtos internos.
Eles não são uma amostra observada dos SCMs gaussianos e não demonstram
independência distributiva. O script não contém dados reais, Monte Carlo,
bootstrap, intervalos, teste de significância, cobertura, seleção de lags,
estimação de painel curto ou alegação sobre dependência em clusters. A
equivalência verificada, se todas as identidades passarem, refere-se somente ao
procedimento testado no domínio OLS sem pesos, mesma amostra e transformação,
história fixa e posto completo descrito na ficha v2.
