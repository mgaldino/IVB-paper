# Revisão de código: verify_examples.R

Data: 2026-09-15. Revisor independente: `gate1_scientific_review`.

## Resumo executivo

**REPAIR antes da execução.** A implementação dos coeficientes, auxiliares, contrastes e covariâncias é metodologicamente coerente com a ficha congelada e com minha derivação independente. Há um defeito de portabilidade do cálculo dos hashes observado neste host e verificações de ações/efeitos causais que atualmente repetem respostas em vez de validar o objeto anunciado. Estes pontos devem ser reparados ou explicitamente delimitados antes de usar um PASS numérico como evidência.

**Nota geral: B, condicionada aos reparos abaixo.** Nenhum R foi executado, nem `parse()`, `source()`, simulação, bootstrap ou Stata. Esta é revisão estática pré-execução pela skill `/Users/manoelgaldino/.codex/skills/review-r/SKILL.md`, lida integralmente. O pedido específico autoriza salvar este relatório e prevalece sobre o “não edite nenhum arquivo” da skill; código e documentos do implementador foram preservados.

## Identidade e evidência

- Código lido integralmente, linhas 1–1293: `numerical/verify_examples.R`, SHA-256 `eaa328c2c7394c27443f28481f0fc2ebb9436534ad4c1bc390203a88ca7beae6`.
- README: `543829a14cf7cc17ed203e516f9b19c1dab1c3abecb808213b4e0a35b5ff7cdb`.
- Manifesto de fonte informado no freeze: `d07fef66fca01c424146e3304c0bb13685309078b1be988fb0d6823f7a7ac208`.
- Ficha: MD `37562fccf615793d0b589b58303e0afeb225edd73ea85e44a7bb1b7688be7097`; JSON `12affe0250af02ada1fc4213a1067ccfe5b482fa5d7a78c52261069c7e7ff00f`.
- Base científica própria: `independent_derivation_v1.md`, escrita antes de abrir derivação/expectativas do desenhista.

As observações abaixo são achados candidatos até adjudicação pelo coordenador. O revisor não implementou correções.

## Problemas críticos para liberação

### NUM-01 — Hash válido é rejeitado quando `shasum` escreve avisos no stderr

**Localizador:** linhas 35–44; chamada de preflight 59–69; manifesto 1272–1279. **Severidade:** bloqueador de execução no ambiente herdado.

`system2(..., stdout=TRUE, stderr=TRUE)` combina stdout e stderr. `sha256_file()` exige exatamente uma linha. Neste host, `LC_ALL=C.UTF-8` e `LANG=C.UTF-8` fazem o Perl do `shasum` emitir sete linhas de aviso de locale, embora o comando termine com código zero e hash correto. Verifiquei somente esse subprocesso, sem executar R: retorno 0, oito linhas capturadas e hash final correto. `suppressWarnings()` suprime condições de aviso do R; não apaga as linhas já capturadas do processo filho. A rotina portanto não é robusta ao ambiente efetivamente observado.

**Reparo proporcional:** fornecer locale portátil explicitamente ao subprocesso (por exemplo `LC_ALL=C`, `LANG=C`) ou separar stderr de stdout; validar status e formato `^[0-9a-f]{64}$` antes de aceitar o hash. Registrar dependência externa `shasum`, já que o cálculo não é exclusivamente base R. Não ignorar indiscriminadamente erro de saída ou aceitar a primeira linha arbitrária.

**Evidência de saída observada fora de R:** `returncode=0`, `captured_line_count=8`, avisos `perl: warning: Setting locale failed.`, hash `eaa328c2...`. O R não foi inicializado para testar se altera o ambiente de subprocessos; o achado é o tratamento frágil de stderr, demonstrado no ambiente herdado.

### NUM-02 — As perdas são zero por atribuição e o teste de ações verifica acordo, não acerto

**Localizadores:** linhas 732–763, 1013–1027, 1192–1210. **Severidade:** material para interpretar a tabela actions_and_losses.

A ação descritiva esperada em E1 usa a mesma `compensation_action()` que P/C+, de modo que um erro comum na regra não seria detectado por esse oráculo. As perdas descritivas/causais são gravadas como 0 sem comparar ação e alvo. O teste final confere apenas que os dois procedimentos concordam. Se ambos reportarem a mesma ação errada, `P_Cplus_action_equivalence` continua verdadeiro e não existe um teste independente contra o alvo congelado. As ações causais são também uma mesma string atribuída a todos; sua concordância confirma atribuição comum, não verificação independente de um classificador.

**Reparo proporcional:** manter um oráculo declarativo dos alvos congelados, por exemplo compensação=(TRUE,TRUE,TRUE,FALSE) e certificados de classe, separado da função que classifica os contrastes calculados. Calcular perdas 0/1/4 por comparação com esses alvos e incluir acerto na condição fail-stop. Para os certificados causais pode-se assumir a interpretação analítica já revisada como input explícito; não é necessário inventar um solver de DAGs. Rotular essa parte como “certificados analíticos fornecidos e conferidos”, distinguindo-a da validação numérica dos coeficientes. Em C0, continuar sem pontuar omissões. E2 deve usar seu shift calculado quando reporta descrição, em vez de repetir uma string constante como output numérico.

### NUM-03 — A checagem dos efeitos sob intervenção compara duas constantes

**Localizador:** linhas 1110–1115. **Severidade:** material para a afirmação de verificação de efeitos do(D).

`cet_difference <- abs(2 - 1)` seguido de comparação a 1 não verifica os efeitos gerados pelas equações. O teste sempre passa mesmo se a codificação estrutural mudar inadvertidamente. Os alvos 2 e 1 estão cientificamente corretos pela derivação independente; o problema é apresentá-los como valores recalculados pelo script.

**Reparo proporcional:** derivar as respostas a uma intervenção unitária por caminhos estruturais de cada SCM (em G_M, D altera Z; em G_F, Z permanece fixo), comparando os efeitos calculados com os alvos 2 e 1. Alternativamente, retirar esse “teste” numérico e rotular os efeitos como input analítico verificado na nota independente, sem contabilizar a comparação de constantes como verificação. Não são necessárias novas células, dados ou simulação.

## Melhoria importante de estado de execução

### NUM-04 — O log pode afirmar PASS antes de o manifesto terminar

**Localizador:** linhas 1266–1279 e 132–137. **Severidade:** integridade do registro final.

O script grava `status=PASS` antes de calcular/gravar o manifesto. Se a etapa de hashes falhar, `run_complete` ainda é FALSE, mas `on.exit()` não atualiza o log já existente. Assim o processo pode terminar com erro e manter `status=PASS`, em desacordo com o README de falhas e com o estado da entrega.

**Reparo proporcional:** registrar status de verificações separado do status final de entrega, e só finalizar `status=PASS` após gravar os artefatos obrigatórios. Um arquivo de estado final separado é uma solução simples que preserva a regra de não sobrescrever resultados anteriores. O manifesto pode omitir seu próprio hash e o marcador final; não é necessário construir auto-hashes recursivos.

## Correção metodológica: pontos aprovados na inspeção

1. **E1:** linhas 271–327 implementam o cubo lexicográfico, quatro contrastes, as quatro células e expectativas q+r, q+b/2, q. O erro e_Y é corretamente um contraste; a documentação distingue fixture de independência gaussiana.
2. **Caminhos P/C+:** linhas 330–390 e 480–510 recalculam OLS em chamadas separadas. P calcula diferenças de endpoints, C+ produtos usando auxiliares. Ambos compartilham somente a rotina OLS e os dados, sem C+ ler outputs de P. Essa independência dos caminhos de contraste é adequada, somada ao oráculo analítico independente; não é uma comparação de bibliotecas OLS diferentes.
3. **Sinais:** d_lag=U−C, retirada=−d_lag e total=d_add−d_lag estão corretos. B e C não são indevidamente tratados como aninhados entre si.
4. **E2:** linhas 441–469 e 884–900 implementam sistemas corretos e matrizes estruturais com variâncias (1,1,1) e (2,1/2,1). O segundo fixture é outra transformação determinística, não uma segunda amostra aleatória. Sua covariância reproduz a mesma Sigma.
5. **Covariância:** linhas 204–242 empilham scores por linhas comuns e preservam termos cruzados. `bread_inverse=(X'X)^−1` e `score=x_i e_i` produzem a matriz HC0 sem fator n indevido. É somente uma matriz algébrica neste fixture.
6. **Produtos e diferenças:** gradientes 393–417 e 513–521 têm os sinais corretos e incluem ambos os fatores; as comparações de influências e matrizes 797–844, 1061–1085 são mais informativas que comparar apenas diagonais. A transformação A V A' inclui Cov(d_add,d_lag). A dependência entre modelos não é descartada.
7. **Limites:** não há bootstrap, draws aleatórios, cobertura, IC, seleção de lags, dados reais ou comparação de desempenho humano. A conclusão de igualdade de covariâncias não recebe interpretação de cobertura.

## Qualidade, reprodutibilidade, performance e apresentação

- Base R é apropriada para seis fixtures minúsculos; não se exige tidyverse/fixest nem otimização paralela. `solve(X'X)` é aceitável nos casos bem condicionados prescritos porque posto/condicionamento/equações normais são reportados, e coeficientes são confrontados com solução analítica. Não extrapolar essa escolha para rotina genérica mal condicionada.
- Nenhuma semente é necessária, pois não há aleatoriedade.
- Paths relativos à raiz, hashes das fichas, recusa de overwrite, outputs por execução e `sessionInfo()` são escolhas adequadas. Faltas específicas de estado/hashing estão em NUM-01/04.
- Tabelas CSV são suficientes para a verificação técnica e correspondem ao fluxo solicitado. A descrição de perdas precisa do reparo NUM-02; rótulos de fixture e ausência de inferência estão claros.
- O volume de código é grande, mas refatoração estrutural não é necessária para liberar estes fixtures e aumentaria o escopo de nova revisão. Priorizar apenas os reparos candidatos adjudicados.
- Condições de fail-stop de projeções, sinais, covariâncias, posto e equações normais estão implementadas; ainda não foram exercitadas. Não se afirma aprovação empírica dessas condições.

## Condição para reavaliação

Após adjudicação, o implementador deve preservar esta versão, reparar os pontos aceitos e congelar novos hashes do código/README/manifesto. O revisor reabrirá os bytes alterados e sua cadeia dependente antes de conceder PASS pré-execução. A autorização para executar continua com o coordenador no escopo vigente; este relatório não executa nem autoriza uma campanha inferencial ou outro gate.
