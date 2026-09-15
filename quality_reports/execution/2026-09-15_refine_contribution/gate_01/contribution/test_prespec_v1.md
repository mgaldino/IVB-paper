# Teste pré-especificado de contribuição, versão 1

**Estado:** pronto para congelamento antes de implementação e testes numéricos. **Data:** 15 de setembro de 2026. **Responsável pelo desenho:** `gate1_contribution`. **Âmbito:** Gate 1, núcleo OLS linear do plano aprovado. A revisão independente e a decisão global pertencem a outros responsáveis.

## 1. Hipótese e decisão

Testar se o procedimento proposto permite uma decisão ou um resultado verificável que a decomposição existente, equipada com as mesmas informações causais e regressões necessárias, não consegue reproduzir. A hipótese não presume sucesso. Os dois exemplos são casos de desenvolvimento deliberadamente construídos; nenhum será apresentado como avaliação fora da amostra, frequência de um problema real ou evidência sobre comportamento humano.

A decisão tem **duas coordenadas distintas**:

1. **Descrição da troca:** o pequeno deslocamento final esconde uma alteração material ao incluir o controle atual mantendo a história? Respostas: `compensacao`, `sem_compensacao_material`, `nao_determinado`. Isso é uma decisão sobre projeções, não sobre admissibilidade causal.
2. **Interpretação causal:** quais especificações preservam uma identificação do efeito total contemporâneo para toda a classe causal explicitamente defendida? Respostas: conjunto de modelos certificados e `somente_descritivo` quando a informação comum não seleciona uma interpretação. Igualdade numérica acidental com o alvo não certifica um modelo para a classe.

Separar essas coordenadas evita construir uma vitória artificial: um leitor que conheça o DAG já pode rejeitar um controle mediador para o efeito total sem calcular qualquer shift. A decomposição pode acrescentar magnitude e atribuição, mas isso não lhe dá uma decisão causal exclusiva.

## 2. Entradas comuns e objetos

Todos recebem os mesmos dados sintéticos determinísticos ou momentos exatos, identificadores de observações, relógio temporal, conjunto de DAGs defendidos, história, estimando, hipóteses, formas funcionais e transformações. Não haverá dados reais, pesos, seleção de lags, mudança de amostra, estimação de painel curto ou inferência de cobertura neste teste.

Seja `W` a matriz comum que inclui o intercepto e quaisquer controles comuns fixados. Seja `L` o estado pré-exposição a preservar e `Z` a medida atual candidata. Os modelos são:

- `B`: `Y ~ D + W + L`;
- `C`: `Y ~ D + W + Z`;
- `U`: `Y ~ D + W + L + Z`.

No exemplo E1, `W` contém apenas intercepto. Trata-se de um subproblema condicional de uma janela temporal, não de evidência sobre viés within ou suficiência de lags num painel. No E2, a comparação é aninhada `S: Y ~ D + 1` e `T: Y ~ D + Z + 1`.

Definir `d_add = beta_U - beta_B`, `d_lag = beta_U - beta_C` e `d_total = beta_C - beta_B = d_add - d_lag`. A contribuição da **retirada** ao longo de `B -> U -> C` é `-d_lag`. Não confundir `d_lag` com a contribuição assinada da retirada.

## 3. Comparadores congelados

### C0: comparação dos endpoints

Calcula `beta_B`, `beta_C` e `d_total` em E1; calcula `beta_S`, `beta_T` e sua diferença em E2. Pode e deve aplicar o mesmo DAG e as mesmas hipóteses à decisão causal. Se os endpoints não determinam os componentes intermediários, pode responder `nao_determinado`. **Não se atribuirá a C0 a regra irracional de que coeficientes semelhantes provam validade causal.** C0 representa a informação exibida pela comparação simples, não o melhor analista possível. Seu desempenho não decide a originalidade.

### C+: decomposição FWL com informação causal igual

Implementação mínima explícita, sem acesso a outputs da proposta:

1. Verificar mesmas linhas, regressores comuns, transformações e posto.
2. Ajustar `B`, `C` e `U` por OLS. Em E2, ajustar `S` e `T`.
3. Ajustar as auxiliares `Z ~ D + W + L` e `L ~ D + W + Z`.
4. Com os coeficientes conjuntos de `U`, calcular `d_add = -theta_Z,U * pi_Z|W,L` e `d_lag = -theta_L,U * pi_L|W,Z`, estendendo a produtos internos se um bloco for vetorial.
5. Calcular `d_total = d_add - d_lag` e verificar a diferença direta dos endpoints.
6. Aplicar as mesmas hipóteses causais e a mesma regra de decisão descrita abaixo. Dado um conjunto de DAGs, conservar as conclusões condicionais e sua divergência.
7. Para incerteza, fica autorizado a obter a covariância conjunta dos coeficientes por equações empilhadas ou pelas mesmas reamostras pareadas, com a mesma unidade de dependência. Este Gate 1 não executa bootstrap nem declara cobertura. A transformação linear das covariâncias pode ser conferida deterministicamente.

O comparador pode calcular modelos intermediários e aplicar as hipóteses disponíveis. Não se estabelece uma proibição fictícia de regressões não mostradas num exemplo editorial. A derivação FWL é independente da disponibilidade do texto integral de Gelbach. A atribuição bibliográfica exata, inclusive de resultados inferenciais, continua dependente da leitura integral.

### P: procedimento proposto

Recebe as mesmas entradas. Explicita estimando e relógio; distingue timing de papel causal; mantém a história defendida; ajusta os mesmos modelos; decompõe a troca; reporta magnitude e incerteza apropriada quando disponível; aplica os mesmos critérios causais e permite saída descritiva. Neste teste, **não existe uma operação matemática nova já especificada além dessas**. Um acréscimo posterior precisa ser nomeado, justificado e registrado como nova versão antes de novos testes, preservando a versão 1 e os resultados adversos.

## 4. Ações, acerto e perda

Para E1, fixar antes dos testes `s = 1/8` unidade de outcome por unidade de tratamento para deslocamento final pequeno e `m = 1/4` para passo material. São escalas didáticas, sem estimativa de relevância numa aplicação. Definir:

`compensacao = (abs(d_total) <= s) AND (abs(d_add) >= m) AND (abs(-d_lag) >= m) AND (d_add * (-d_lag) < 0)`.

O alvo descritivo é calculado das projeções exatas. A igualdade dos endpoints não identifica esse alvo sem o modelo intermediário ou informação equivalente. Não se fará teste de significância, razão por SE de endpoint ou escolha de limiar após observar saídas.

Na coordenada causal, o alvo é a conclusão válida **para a classe causal fornecida**, não a igualdade de um coeficiente ao CET em um ponto de parâmetros. E1 fornece uma classe estrutural conhecida; E2 fornece dois DAGs compatíveis e nenhum critério que selecione entre eles. Certificados condicionais são permitidos e obrigatórios quando úteis; selecionar um DAG pela magnitude ou pelo sinal do shift é erro.

Perda por item, registrada separadamente por coordenada:

- `0`: resposta correta, com os qualificadores exigidos;
- `1`: `nao_determinado` quando as entradas daquele procedimento permitem determinar a resposta;
- `4`: resposta determinada incorreta, ou certificado causal além do que o conjunto de hipóteses permite.

Quando a informação causal é insuficiente, `somente_descritivo` acompanhado dos certificados condicionais corretos tem perda `0`. A comparação primária usa o vetor de perdas, sem pesos agregados que possam esconder erro causal. Uma omissão de campo é tratada como `nao_determinado`, não como erro causal inventado. A perda de C0 por ausência de componentes descreve sua informação reportada e **não** fundamenta superioridade de P sobre C+.

## 5. Exemplo E1: substituir estado prévio por medida atual

### Classe e relógio

`L` fecha antes de `D`; `Z` pode responder a `D`; `Y` é medido depois de `Z`. Assumir variáveis contínuas e equações estruturais recursivas:

```
L = e_L
D = L + e_D
Z = D + e_Z
Y = q D + b L + r Z + e_Y
```

Erros mutuamente independentes, gaussianos, média zero e variância um. Consistência, ausência de interferência/antecipação, suporte contínuo e nenhuma causa omitida. A história é `L`. O CET total é a derivada da média de `Y` sob `do(D=d)` mantendo a distribuição de `L`: `q+r`. A variável `Z` não é confundidor atual nessa classe. `b`, `r` e `q` são parâmetros da classe, não informações secretas exclusivas da proposta.

### Células congeladas, todas obrigatórias

| Célula | q | b | r | Função |
|---|---:|---:|---:|---|
| E1-central | 1/2 | 1 | 1/2 | Cancelamento exato construído |
| E1-menos | 1/2 | 4/5 | 1/2 | Perturbação preservada, sem escolher sinal favorável |
| E1-mais | 1/2 | 6/5 | 1/2 | Perturbação simétrica |
| E1-nulo | 1 | 0 | 0 | Ausência de ganho: não há qualquer passo populacional |

As três primeiras células pertencem à classe de efeitos de `L` e `Z` não fixados em zero. `B` identifica o efeito total ao longo dessa classe; `U` condiciona no mediador e identifica o efeito direto sob as hipóteses fornecidas; `C` ainda omite `L`. Se um endpoint coincidir numericamente com o CET, isso deve ser reportado como coincidência naquele ponto, sem negar a igualdade e sem certificá-lo para perturbações. Na célula E1-nulo, é dada a subclasse estrutural com **ausência** das setas `L -> Y` e `Z -> Y`; B, C e U identificam o mesmo efeito total. Não se transporta para ela o certificado da classe maior sem atualizar o DAG fornecido igualmente a todos.

### Implementação determinística a preparar por outro agente

Usar os oito vetores binários `x=(x1,x2,x3)` em ordem lexicográfica. Definir quatro colunas de contraste `e_L=(-1)^x1`, `e_D=(-1)^x2`, `e_Z=(-1)^x3` e `e_Y=(-1)^(x1+x2)`. Elas são centradas e ortogonais com produto interno dividido por oito igual à matriz identidade. Aplicar as equações acima; os momentos de segunda ordem e os coeficientes OLS reproduzirão os momentos populacionais. Este suporte finito é **fixture de álgebra**, não amostra empírica de uma população gaussiana nem demonstração de independência distributiva ou inferência.

Recalcular os coeficientes diretamente e pelas auxiliares, sem hardcode das respostas. Validar também posto e condicionamento. Os quatro casos ficam preservados qualquer que seja o resultado.

## 6. Exemplo E2: um mesmo shift admite duas leituras causais

Os registros apenas estabelecem que `Y` fecha depois de `D` e `Z`; a ordem entre D e Z é desconhecida. A história comum está vazia. O conjunto de hipóteses fornecido a todos é a união das duas estruturas abaixo, com todos os erros independentes em cada estrutura:

```
G_M (mediador):
D = e_D, Var(e_D)=1
Z = D + e_Z, Var(e_Z)=1
Y = D + Z + e_Y, Var(e_Y)=1

G_F (confundidor):
Z = u_Z, Var(u_Z)=2
D = Z/2 + u_D, Var(u_D)=1/2
Y = D + Z + u_Y, Var(u_Y)=1
```

Todos os erros gaussianos de média zero. Sem informação documental adicional que escolha `G_M` ou `G_F`, nenhuma rotina pode tratar um deles como conhecido. Testar a igualdade das matrizes de covariância observáveis e a desigualdade dos efeitos `do(D)`. Produzir certificados condicionais para cada DAG; a decisão global correta é somente descritiva quanto à atribuição do shift a viés ou mediação. Não se prometerá identificar o verdadeiro DAG.

Pode-se usar os oito contrastes descritos em E1, com três colunas para os erros de `G_M`, como fixture de OLS, e verificar a matriz de covariância de `G_F` por transformação linear exata. Não gerar uma segunda amostra aleatória para avaliar equivalência observacional: isso confundiria erro de amostragem com o objeto da demonstração.

## 7. O que distingue, o que obriga a reconhecer equivalência

### Evidência de capacidade distinta, necessária para a rota metodológica

Um resultado de P deve: (i) reduzir estritamente ao menos uma coordenada de perda frente a C+, sem piorar outra; (ii) vir de operação, resultado ou garantia explicitamente descrita; (iii) usar as mesmas entradas e hipóteses; (iv) sobreviver à revisão independente e à possibilidade de C+ executar as regressões/interpretações autorizadas. Alternativamente, uma garantia inferencial ou melhoria computacional específica pode ser candidata se tiver um alvo e condições que o comparador implementado não satisfaça; nenhum desses resultados está fornecido por simplesmente renomear a decomposição.

### Equivalência que deve ser registrada

Se C+ e P obtiverem os mesmos coeficientes, componentes, decisões causais e transformações de covariância nos dois exemplos, e a identidade demonstrar que isso ocorre para toda amostra de posto completo no domínio declarado, registrar **equivalência do procedimento testado nesse domínio**. A equivalência não afirma que qualquer futura extensão é impossível e não certifica toda a literatura.

A mesma sequência de reamostras e a mesma regra de intervalo aplicada ao mesmo contraste resultam nos mesmos intervalos, inclusive quando o procedimento de intervalo for inválido. A equivalência de outputs não é prova de cobertura. Perto de `theta=pi=0`, os dois enfrentam a mesma degenerescência; não será atribuída vantagem a P por escrever o produto como diferença.

### Ganho operacional

Automatizar amostra comum, caminhos, relatórios e recusas de inputs pode ser útil. Neste Gate 1, isso permanece hipótese operacional: não serão inferidas redução de erros de pesquisadores, velocidade ou adoção a partir das respostas de agentes ou do tamanho do relatório. Como o comparador tem orçamento irrestrito de regressões nos dois exemplos, não se declarará vantagem computacional por uma comparação não medida. Qualquer avaliação de usabilidade/tempo precisa de protocolo próprio e não ocorre aqui.

## 8. Verificação e regras de mudança

- Nenhum script R deve ser executado antes de revisão `review-r` independente e liberação pelo coordenador na autorização vigente.
- Checagens futuras: diferenças OLS/FWL, sinais, posto, covariâncias exatas e classificação de ações; tolerância numérica `1e-10*(1+abs(alvo))` para grandezas escalares bem condicionadas. Matrizes usam tolerância análoga ao máximo absoluto; condicionamento e erros devem ficar no output.
- Não rodar simulações, bootstrap, shifts reais ou novas extensões como consequência desta ficha.
- Congelar este arquivo e o JSON antes da implementação. Qualquer correção científica cria v2 com motivo e evidência já vista; v1 permanece preservada. Ajuste meramente tipográfico também recebe novo hash.
- A leitura integral de Gelbach e a viabilidade da aplicação são dependências separadas do Gate 1. Sem elas, não declarar PASS do gate nem novidade.

## 9. Identidade e proveniência

Base recebida: commit `731cd6570651ea0f602d5c7cdff89ab43ecdb962`. HEAD observado em 15/09 durante o desenho: `b17c0a47a2b0f4526d03fdfccf5380fe60b5bc2f`; mudança comunicada ao coordenador. O manuscrito manteve SHA-256 `12493a67133f988c5e6a13933bf2b89c0d9880e96bae329248a207b3aeaf7b5e`. Plano: `d2d2ea2e39102ab4193ee2f82b12b0823143867a23750c38d626aa4797eb7f5d`. Freeze Gate 0 aprovado: `6cabcc31b691492eeb44e6390250bb14b09cedc04f03e7ca63e85ffdcdbc7faa`.

Fontes locais governantes: `plan.md:115–129` (teste e critério); contrato C01–C04/C06/C08; `response_matrix.csv` R1-G1, R1-G2, R1-G3, R1-FU1/FU4; `ivb_paper_pa.Rmd:184–192,389–451,457–501,629–638`; `specification_shift_uncertainty.Rmd:185–206` (produto e origem). Esses localizadores sustentam a pergunta e os limites; as duas estruturas sintéticas são construções analíticas deste desenho, não evidência retirada das aplicações.
