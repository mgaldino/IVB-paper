# Devil's Advocate Report — Dual-Role Z Simulation Report v2

**Data**: 2026-03-01

## Vulnerabilidade principal

**O relatorio esta desatualizado em relacao ao codigo que acabou de rodar.** Sim 1 mostra "ADL_noFE" como modelo 6, mas o codigo corrigido agora tem "ADL_Dlag" (Y~D+D_lag+Z_lag+Y_lag|FE) — um modelo completamente diferente. Sim 3 mostra 4 cenarios, mas o grid expandido tem 5. Os numeros do Sim 1 na coluna 6 estao errados. Antes de qualquer argumento substantivo, o relatorio precisa ser sincronizado com os resultados reais.

## Ataques por dimensao

### Logica interna

1. **Sim 1 Secao 4.1: Pool_l e ADL_noFE tem valores identicos (-0.342, -0.342)**
   - **Severidade**: Alta
   - Isso confirma que eram modelos duplicados no codigo original. O relatorio apresenta 6 modelos mas na verdade tem 5 unicos. Apos a correcao, o modelo 6 agora e ADL_Dlag (com FE), nao ADL_noFE. Toda a coluna "ADL_noFE" na Secao 4.1 esta errada.
   - **Como o autor poderia responder**: Atualizar o relatorio com os resultados do re-run.

2. **Secao 4.2: O vies do ADL_full *diminui* com phi — nao e explicado**
   - **Severidade**: Media
   - Se feedback Y->D viola strict exogeneity e causa Nickell bias, por que o vies cai de 0.010 para 0.005 quando phi aumenta de 0 para 0.10? O relatorio diz "ao controlar Y_lag, o canal phi e parcialmente absorvido" — mas isso nao explica por que absorver *mais* feedback gera *menos* vies. Uma possibilidade: phi muda a estrutura de correlacao de modo que Y_lag absorve mais confounding, mas isso e especulacao. Sem uma explicacao analitica, este resultado mina a narrativa "feedback causa Nickell bias".
   - **Como o autor poderia responder**: Derivar analiticamente o vies do ADL_full como funcao de phi, mostrando por que o efeito e nao-monotonico ou decrescente.

3. **Secao 7.3: O IVB e *sempre negativo* na tabela de trade-offs**
   - **Severidade**: Media
   - Se Z e dual-role (confounder + collider), deveria haver cenarios onde o componente collider domina e o IVB e positivo — ou seja, incluir Z *aumenta* o vies. Mas em todos os cenarios, incluir Z *reduz* vies (IVB negativo, net benefit positivo). Isso sugere que no DGP escolhido, Z e essencialmente um confounder com propriedade secundaria de collider, nao um verdadeiro dual-role. O titulo "dual-role" promete mais do que entrega.
   - **Como o autor poderia responder**: Sim asymmetry ja mostra cenarios com gamma_D=0 onde Z e quase puro collider. Integrar esses resultados na tabela 7.3 ou reconhecer que o DGP base foi calibrado para confounder-dominant.

4. **"Especificacao universalmente segura" e uma alegacao forte demais**
   - **Severidade**: Alta
   - O relatorio afirma que ADL_all e "universalmente seguro" (Secao 7.5, Secao 11). Mas "universalmente" implica todos os DGPs, e os testes cobrem apenas uma familia parametrica especifica (VAR(1) linear, erros iid, efeitos homogeneos). A palavra certa seria "robusto nos cenarios testados".
   - **Como o autor poderia responder**: Substituir "universalmente seguro" por "robusto em todos os cenarios testados".

### Mecanismo causal

5. **A restricao de estacionariedade como "bound natural" e circular**
   - **Severidade**: Media
   - O argumento "phi forte gera instabilidade, entao em processos estacionarios phi tende a ser pequeno" e trivialmente verdadeiro. Nao e um achado — e uma propriedade matematica de processos VAR. O relatorio apresenta isso como insight empiricamente relevante (Secao 4.5, 8, 9), mas nao ha evidencia de que DGPs de CP se aproximam do limite de estacionariedade. Se phi tipico e 0.01, o bound de 0.15-0.17 e irrelevante.
   - **Como o autor poderia responder**: Citar evidencia empirica sobre magnitude de feedback em aplicacoes de CP. Sem isso, o bound e informacao sem relevancia pratica.

6. **Falta o efeito total de D quando beta_2 > 0**
   - **Severidade**: Media
   - Quando beta_2=0.5, o efeito total de D e beta + beta_2 = 1.5. O pesquisador aplicado geralmente quer o efeito total, nao apenas o contemporaneo. O ADL_all estima beta=1 corretamente, mas o relatorio nao discute como combinar hat(beta) + hat(beta_2) para o efeito total, nem sua variancia. A Secao 8 menciona isso em uma unica frase nas limitacoes — deveria ser central.
   - **Como o autor poderia responder**: Adicionar tabela mostrando hat(beta + beta_2) e seu desvio-padrao.

### Evidencia empirica

7. **Apenas um conjunto de parametros base**
   - **Severidade**: Alta
   - gamma_D=0.15, gamma_Y=0.2, rho_Y=0.5, rho_D=0.5, delta_D=0.1, delta_Y=0.1 sao todos fixos. A dominancia do ADL_all pode depender dessas escolhas. Exemplo: com gamma_D muito grande e delta_Y muito pequeno (Z e forte confounder, fraco collider), o IVB seria diferente. Nenhuma analise de sensibilidade foi feita para os parametros base.
   - **Como o autor poderia responder**: As simulacoes base (v1) variam rho_Z e sigma_aZ. A sim asymmetry varia gamma_D e delta_Y. Mas os DGPs estendidos (Sims 1-3) fixam tudo exceto phi/beta_2/rho_Z. Uma variacao de rho_Y (0.3, 0.5, 0.7) seria informativa.

8. **N=100, T=30 e generoso — Nickell bias e O(1/T)**
   - **Severidade**: Alta
   - Com T=30, o Nickell bias e ~3.3%. Muitos paineis em CP tem T=10-15, onde Nickell e ~6.7-10%. O relatorio VaryT (Secao 3.2) mostra convergencia para T=10,30,100 *no DGP base*, mas **nao repete VaryT para os DGPs estendidos com phi e beta_2**. E possivel que com T=10 e phi=0.10, o Nickell bias seja substantivo.
   - **Como o autor poderia responder**: Rodar Sims 1-3 com T=10 e T=15 para pelo menos um cenario.

9. **Sem coverage rates**
   - **Severidade**: Media
   - O relatorio reporta bias e RMSE, mas para recomendacoes praticas o que importa e a taxa de cobertura dos intervalos de confianca de 95%. Um modelo com bias=0.01 mas SEs muito apertados pode ter cobertura pessima. Um modelo com bias=0.05 mas SEs generosos pode ter cobertura adequada.
   - **Como o autor poderia responder**: Adicionar coluna de coverage (% de CIs que contem beta_true).

10. **Sim 3: Grid assimetrico com cobertura limitada**
    - **Severidade**: Baixa
    - 5 cenarios nao formam um grid regular (phi x beta_2 x rho_Z), tornando dificil separar efeitos marginais. E.g., nao ha cenario phi=0.10/beta_2=0.3/rho_Z=0.7 (por instabilidade) nem phi=0.05/beta_2=0.3/rho_Z=0.5. Dificulta generalizacao.
    - **Como o autor poderia responder**: A restricao e pela estacionariedade — nao ha escolha. Reconhecer explicitamente.

### Escopo e generalizacao

11. **DGP linear, homogeneo, iid**
    - **Severidade**: Media
    - Erros iid, efeitos constantes, sem heterogeneidade de tratamento. Em CP, o tratamento e tipicamente binario e heterogeneo. A extensao para D binario com treatment effect heterogeneity mudaria os resultados.
    - **Como o autor poderia responder**: As simulacoes existentes (v1 Mechanism C) testam D binario, embora nao no contexto dos DGPs estendidos.

12. **Uma unica variavel Z**
    - **Severidade**: Baixa
    - Em aplicacoes, multiplas variaveis podem ser dual-role. Os resultados podem nao escalar.
    - **Como o autor poderia responder**: Reconhecer como limitacao (ja feito na Secao 8.5).

### Economia do texto

13. **Secao 3 (Resultados DGP Base) e redundante**
    - **Severidade**: Media
    - 30 linhas resumindo resultados ja documentados no relatorio v1. Leitor do v2 que nao leu v1 nao tem informacao suficiente; leitor que leu v1 nao precisa do resumo. Ou expande com numeros novos, ou remove e referencia v1.
    - **Como o autor poderia responder**: Cortar para 5-10 linhas com referencia ao v1, ou integrar os numeros do DGP base como baseline nas tabelas dos DGPs estendidos.

14. **Secao 6.2 (ranking completo) repete 6.1**
    - **Severidade**: Baixa
    - A tabela de ranking por |bias| nao adiciona informacao alem do que ja esta na tabela 6.1 — apenas reordena. O segundo cenario (phi=0.10) e o unico com insight novo (ADL_DZlag cai para 4o, mostrando que Z_lag sem Y_lag nao basta quando phi e alto). Manter apenas esse cenario.
    - **Como o autor poderia responder**: Condensar em uma frase na Secao 6.5.

15. **Secao 10 (Arquivos Produzidos) e administrativa**
    - **Severidade**: Baixa
    - Lista de arquivos e util para o pesquisador mas ocupa espaco em um relatorio analitico. Mover para apendice ou README.
    - **Como o autor poderia responder**: Mover para README ou nota de rodape.

## Ranking de vulnerabilidades

1. **Relatorio desatualizado vs codigo** (#1) — numeros errados no Sim 1, grid incompleto no Sim 3. Problema factual.
2. **"Universalmente seguro" sem base** (#4) — alegacao mais forte que a evidencia permite.
3. **Parametros base fixos** (#7) — dominancia do ADL_all pode ser sensivel a escolhas nao testadas.
4. **T=30 generoso, sem VaryT nos DGPs estendidos** (#8) — conclusao "Nickell negligivel" pode nao valer para T=10-15.
5. **IVB sempre negativo** (#3) — sugere que o DGP foi calibrado para confounder-dominant, enfraquecendo o claim de "dual-role".
6. **Bias do ADL_full diminui com phi** (#2) — resultado contraintuitivo sem explicacao analitica.
7. **Sem coverage rates** (#9) — bias e insuficiente para recomendacoes praticas.
8. **Efeito total de D ignorado** (#6) — relevante quando beta_2 > 0.

## Recomendacoes de corte

1. **Cortar Secao 3 inteira** (Resultados DGP Base) — substituir por 5 linhas de baseline + referencia ao v1. Economia: ~30 linhas.
2. **Cortar Secao 6.2** (ranking detalhado) — manter apenas a conclusao "ADL_all 1o em todos os cenarios". Economia: ~20 linhas.
3. **Cortar Secao 10** ou mover para README. Economia: ~15 linhas.
4. **Condensar Secao 2.5** (estacionariedade) — os numeros exatos dos limites sao excessivos. Manter apenas a mensagem qualitativa. Economia: ~5 linhas.
5. **Cortar argumento "restricao de estacionariedade como bound natural"** das Secoes 4.5 e 9 — e circular e nao contribui sem evidencia empirica sobre phi tipico.

## O que sobrevive ao escrutinio

1. **O achado central e robusto**: D_lag e essencial quando beta_2 > 0, e inofensivo quando beta_2 = 0. Isso e genuinamente util e nao-obvio a priori (poderia haver interacao com Nickell).

2. **A hierarquia ADL_all > ADL_full > TWFE e estavel** em todos os cenarios testados — nao ha inversao.

3. **O mapeamento Imai & Kim (Secao 7.4)** e a melhor parte do relatorio: mostra concretamente que cada assumption violada tem um controle correspondente. Isso e pedagogico e original.

4. **A tabela 5.2 (beneficio de D_lag)** e clear e compelling: melhoria de 0.007 (beta_2=0) vs 0.148 (beta_2=0.5) quantifica exatamente o custo de omissao.

5. **O hat(beta_2) recovery** (Sim 2) mostra que ADL_all nao so estima beta corretamente mas tambem recupera beta_2, validando a especificacao.
