# Gate 0 — rechecagem independente da rodada 2

**Veredicto: PASS documental do Gate 0.** O único achado bloqueador da rodada 1 foi corrigido nos novos bytes. O pacote identifica com fidelidade suficiente o argumento, o parecer e o estado dos materiais para iniciar o Gate 1.

**Revisor:** `gate0_reviewer`. **Data:** 2026-09-15 UTC.  
**Congelamento revisado:** `gate_00/freeze_round2.json`, em `2026-09-15T11:52:39.121782+00:00`, com 12 arquivos.  
**Revisão anterior:** `review/final_review_round1.md` e `.json`, veredicto REPAIR.  
**Contrato preservado:** `ivb-pa-refine:5375d3c27ac1:round1`.

## 1. Correção verificada

**G0-R1-F01: resolvido na revisão independente.** A linha T06 de `inventory/task_inventory.csv` agora identifica a Tabela 3 existente em `ivb_paper_pa.Rmd:479-499`, distingue presença de suficiência e mantém a revisão da tabela e da linguagem para Gates 2–3/6. O `memo.md` recebeu um parágrafo coerente com essa correção. `correction_round2.md` registra a mudança e a fonte que a sustenta.

O diff confirmou que **somente T06 mudou entre as 26 linhas do CSV**. A adição ao memo trata apenas desse ponto. O novo registro de correção descreve esses mesmos limites. Não há necessidade de alterar o manuscrito para atender ao achado.

| Artefato alterado/adicionado | SHA-256 revisado |
|---|---|
| `inventory/task_inventory.csv` | `b3fabecd53ac00149a5ea1c2a80bc416f2617b646f8bfa67cf43e3432817d656` |
| `inventory/memo.md` | `5710d59fd525045a81dadf5d56a537aa7df88ceffd85eb9a0cb95f2641b87bf7` |
| `inventory/correction_round2.md` | `740a174bf5e52e1c15ec481b6b0b31351dd46608405b5e76231f0e92fa07dfe4` |

## 2. Integridade e reutilização das verificações

- **12/12 hashes** do congelamento round 2 conferem com os arquivos atuais.
- As duas cópias preservadas em `review/snapshots/round1/inventory/` coincidem com os hashes originais de `task_inventory.csv` e `memo.md` no freeze round 1. A trilha do REPAIR permanece verificável.
- Os outros **nove artefatos comuns às duas rodadas mantêm os mesmos hashes**. As verificações da rodada 1 são reaproveitadas para seu conteúdo.
- Os **17 arquivos do baseline** foram re-hashados e continuam idênticos; isso inclui Rmd, PDF, derivações governantes e versão PSRM. Não há mudança de fonte que demande nova leitura integral do PDF.
- O inventário mantém 26 IDs únicos, com a única correção em T06. A cobertura restante, a matriz de 21 respostas, os 14 candidatos, as 11 razões disponíveis e as três comparações extras continuam aprovados pelas verificações da rodada 1.

## 3. Por que o Gate 1 pode começar

A base documental agora distingue material existente, validação histórica, execução parcial e trabalho científico pendente. A cobertura dos sete registros de seção, C01–C08, cinco comentários gerais, 12 detalhados e quatro eixos complementares está preservada. As respostas têm IDs, localizadores, dependências e critérios de encerramento, sem converter 21 unidades de resposta em 21 defeitos independentes.

Os números reutilizados têm origem identificada e denominadores claros: 14 candidatos em seis estudos, 11 razões de endpoint-SE disponíveis, três comparações adicionais de Rogowski, cobertura de 0.700 do coeficiente longo HPJ contra o CET e coeficientes mistos 1.023/1.016 ligados a seus alvos. Task 13 possui evidência histórica localizada; Task 14 continua corretamente marcada como execução incompleta, com o conflito de revisões confrontado com o código atual e reparos destinados à etapa apropriada.

Assim, **não há achado documental material aberto que impeça testar a contribuição**. O próximo gate pode comparar o procedimento com o melhor método existente sob as mesmas informações causais e temporais e examinar uma aplicação elegível. Este PASS não estabelece novidade, não valida previamente provas ou inferência e não resolve os comentários encaminhados aos Gates 2–6. A decisão científica do Gate 1 continua podendo exigir reformulação ou suspensão da rota conforme o plano.

## 4. Executado e limite da revisão

Nesta rechecagem executei leitura da correção, comparação dos diffs e linhas CSV, conferência de 12 hashes do novo congelamento, dos dois snapshots históricos e dos 17 hashes do baseline. Reaproveitei os checks independentes da rodada 1 para os arquivos inalterados, inclusive as 102 entradas do manifesto de inputs, os valores dos candidatos e os mapeamentos CSV/JSON.

Não executei R, simulações, bootstrap, reestimações, renderização do manuscrito ou nova inspeção visual integral. Não editei os artefatos corrigidos pelo implementador. A escrita desta fase limita-se a este relatório e seu JSON.

**Conclusão:** Gate 0 aprovado para sua finalidade documental; G0-R1-F01 resolvido; Gate 1 apto a iniciar no escopo já autorizado do plano.
