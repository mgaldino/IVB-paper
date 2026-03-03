# Notas de Trabalho: Testes para Decisão no Trade-off IVB vs OVB

**Data**: 2026-03-02  
**Status**: rascunho conceitual (aguardando novas simulações para especificação final)

## 1. Pergunta de pesquisa (foco prático)

Quando um controle \(Z\) pode atuar como confundidor e/ou collider, devemos incluí-lo ou não no modelo?

Hipótese em desenvolvimento, baseada nas simulações:

1. Se a relação no canal collider for linear, sublinear ou não-linear bounded, o IVB tende a permanecer pequeno.
2. Se a relação for não-linear unbounded com ganho marginal crescente, o IVB pode crescer substancialmente.

## 2. Intuição mecânica do caso problemático (power1.5)

Para \(f(D)=\text{sign}(D)|D|^{1.5}\):

\[
f'(D)=1.5\sqrt{|D|}\quad (D\neq 0)
\]

Logo, o efeito marginal de \(D\) sobre \(Z\) cresce com \(|D|\). Em presença do loop dinâmico \(Z_{t-1}\to D_t\to Z_t\), valores extremos de \(D\) podem gerar amplificação.

## 3. Caminhos de teste sugeridos (versão preliminar)

### 3.1 Teste de superlinearidade no canal \(D\to Z\)

Modelo-base (painel com FE e dinâmica):

\[
Z_{it}=\alpha_i+\lambda_t+\rho_Z Z_{i,t-1}+\delta D_{it}+\theta\,\text{sign}(D_{it})|D_{it}|^p+\varepsilon_{it}
\]

Ideias de hipótese:

1. \(H_0: p\le 1\) vs \(H_1: p>1\) (superlinearidade).
2. Alternativamente, \(H_0:p=1.5\) para teste direcionado ao padrão power1.5.

Implementação sugerida:

1. Profile/grid search em \(p\).
2. Inferência com bootstrap por cluster de unidade (para IC de \(p\) e teste unilateral).

### 3.2 Teste de amplificação do loop \(Z\to D\to Z\)

Equação dinâmica de tratamento:

\[
D_{it}=\mu_i+\tau_t+\rho_D D_{i,t-1}+\gamma_D Z_{i,t-1}+u_{it}
\]

Com os parâmetros do canal \(D\to Z\), definir ganho local aproximado:

\[
G_{it}=\gamma_D\left(\delta+\theta p|D_{it}|^{p-1}\right)
\]

Hipótese possível:

1. \(H_0:Q_{0.9}(G)\le 1\) vs \(H_1:Q_{0.9}(G)>1\).

Interpretação: quantis altos de \(G\) acima de 1 indicam regime de amplificação relevante no suporte observado.

### 3.3 Diagnósticos complementares

1. Granger bidirecional \(D\leftrightarrow Z\) para evidência de feedback (diagnóstico auxiliar, não prova causal final).
2. Testes de raiz unitária/explosividade apenas como complemento de persistência global; não identificam sozinhos bounded vs unbounded.

## 4. Regra de decisão provisória para incluir ou não \(Z\)

1. **Baixo risco IVB**: não rejeita superlinearidade e sem evidência de amplificação forte.
2. **Risco intermediário**: evidência de superlinearidade, mas sem amplificação robusta.
3. **Alto risco IVB**: evidência de superlinearidade + amplificação no loop.

No cenário de alto risco, a inclusão automática de \(Z\) como “controle de rotina” fica fragilizada.

## 5. Condições para bom poder dos testes

1. Cauda suficiente de \(|D|\) no suporte observado.
2. Testes unilaterais alinhados ao mecanismo (superlinearidade e amplificação).
3. Bootstrap cluster para inferência robusta em painel.
4. Calibração de poder via Monte Carlo com \(N,T\) compatíveis com aplicações empíricas-alvo.

## 6. Limites conceituais importantes

1. Dados finitos não “provam” comportamento assintótico unbounded; testam comportamento no suporte observado.
2. Evidência de forma funcional e feedback é informativa para risco de IVB, não garantia mecânica de magnitude em todos os DGPs.
3. A decisão final continua substantiva (teoria do processo gerador e timing causal).

## 7. Próximo passo (quando novas simulações chegarem)

1. Fixar o conjunto mínimo de testes (idealmente 1 ou 2).
2. Escolher estatística final de decisão (por exemplo, classificação baixo/intermediário/alto risco).
3. Rodar estudo formal de poder e tamanho para o protocolo escolhido.
4. Traduzir o protocolo para implementação prática em script único de aplicação empírica.
