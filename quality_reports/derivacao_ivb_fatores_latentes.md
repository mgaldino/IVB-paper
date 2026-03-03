# Derivação detalhada do IVB com fatores latentes

## Q&A inicial

**Q1. O que será provado aqui?**  
Vamos provar, passo a passo, três resultados:

1. Com o mesmo conjunto de controles (incluindo fatores latentes), vale a identidade:
\[
\beta_L - \beta_S = -\theta_L \pi.
\]
2. Se os fatores latentes são reestimados entre o modelo curto e o longo, surge um termo adicional:
\[
\beta_L^{F_L} - \beta_S^{F_S} = -\theta_L^{F_L}\pi^{F_L} + \Delta_F.
\]
3. Interpretação causal em dois cenários:
- `Z` apenas collider;
- caso `mixed` (`confounder + collider`).

**Q2. Qual é o nível de detalhe?**  
Prova algébrica completa, com expansão das condições normais (FOC/eqs. normais), sem saltos.

---

## Motivação: por que fatores latentes em extensões de DiD (via Matrix Completion)

Em aplicações de DiD, a suposição clássica de tendências paralelas pode ser forte demais quando há:

1. choques agregados que afetam unidades de forma heterogênea;
2. componentes não observados persistentes que evoluem no tempo;
3. trajetórias pré-tratamento com padrões sistemáticos não capturados por FE padrão.

Modelos de Matrix Completion surgem justamente como extensão prática de DiD para esse tipo de cenário.  
A ideia substantiva é usar a estrutura dos dados ao longo do tempo e entre unidades para recuperar componentes latentes que funcionam como controles adicionais de trajetória.

Do ponto de vista deste documento, o ponto central é simples:

- ao introduzir fatores latentes, mudamos o conjunto efetivo de controles da regressão;
- se curto e longo usam o mesmo conjunto latente, a identidade IVB mantém a forma padrão;
- se o conjunto latente muda entre especificações (porque foi reestimado), aparece um termo adicional na decomposição.

Ou seja, a motivação para tratar fatores latentes aqui não é discutir detalhes de estimação de Matrix Completion, mas garantir comparação correta entre especificações em um ambiente DiD mais flexível.

---

## Equações de Matrix Completion (MC) e ligação com o problema de IVB

Nesta seção, escrevemos explicitamente as equações de MC para fixar a notação.

### MC: estrutura observada em painel

Considere \(i=1,\ldots,N\) e \(t=1,\ldots,T\).  
Seja \(Y_{it}\) o desfecho observado e \(D_{it}\) o tratamento.

Uma forma padrão de MC com fatores latentes é:
\[
Y_{it}
=
\mu + \alpha_i + \xi_t + X_{it}'\beta + L_{it} + \tau D_{it} + \varepsilon_{it},
\]
onde:

- \(\mu\): intercepto global;
- \(\alpha_i\): efeito fixo de unidade;
- \(\xi_t\): efeito fixo de tempo;
- \(X_{it}\): controles observados;
- \(L_{it}\): componente latente de baixa dimensão (baixa-rank em matriz \(N\times T\));
- \(\tau\): parâmetro de tratamento (ou objeto de interesse em uma versão linearizada).

### Conjunto de observações usadas para recuperar o contrafactual

Defina \(\Omega\) como o conjunto de células usadas para ajustar o componente não tratado
(tipicamente células pré-tratamento e/ou nunca tratadas, dependendo do desenho).

O problema penalizado típico é:
\[
\min_{\mu,\alpha,\xi,\beta,L}
\sum_{(i,t)\in\Omega}
\left(
Y_{it}-\mu-\alpha_i-\xi_t-X_{it}'\beta-L_{it}
\right)^2
+
\lambda_L \|L\|_*
+
\lambda_\beta \|\beta\|_2^2.
\]

Aqui, \(\|L\|_*\) é a norma nuclear (soma dos valores singulares), que força estrutura de baixa-rank.

### Curto vs longo no contexto deste documento

No problema de IVB, a diferença entre curto e longo é a inclusão de \(Z_{it}\):

- **Curto (S):** \(X_{it}^{(S)}\) não inclui \(Z_{it}\);
- **Longo (L):** \(X_{it}^{(L)}\) inclui \(Z_{it}\).

Logo, em geral, temos dois problemas MC distintos:
\[
(\hat\mu_S,\hat\alpha_S,\hat\xi_S,\hat\beta_S,\hat L_S)
\quad\text{e}\quad
(\hat\mu_L,\hat\alpha_L,\hat\xi_L,\hat\beta_L,\hat L_L).
\]

Se \(\hat L_S\neq \hat L_L\), os fatores implícitos também mudam.  
Por exemplo, via decomposição SVD:
\[
\hat L_S=\hat U_S\hat\Sigma_S\hat V_S',\qquad
\hat L_L=\hat U_L\hat\Sigma_L\hat V_L'.
\]

Isso é exatamente o que, na derivação abaixo, aparece como mudança de \(F_S\) para \(F_L\), gerando o termo \(\Delta_F\).

### Caso especial em que a fórmula IVB fica limpa

Se o pesquisador **congela** o componente latente (mesmo \(F\) no curto e no longo), então
o operador de residualização é o mesmo nos dois modelos e volta a identidade:
\[
\beta_L-\beta_S=-\theta_L\pi.
\]

Se não congelar (reestimar MC separadamente), a diferença total passa a ser:
\[
\beta_L^{F_L}-\beta_S^{F_S}
=
-\theta_L^{F_L}\pi^{F_L}
+
\Delta_F.
\]

---

## 1) Setup e suposições

### 1.1 Variáveis

- \(y\): vetor \(n \times 1\) do desfecho.
- \(d\): vetor \(n \times 1\) do tratamento.
- \(z\): vetor \(n \times 1\) do controle suspeito.
- \(W\): matriz \(n \times k\) de controles observados legítimos (inclui constante quando apropriado).
- \(F\): matriz \(n \times r\) de fatores latentes (ou proxys/fatores estimados).

Defina a matriz de controles totais:
\[
C(F) \equiv [W,\ F].
\]

### 1.2 Operador de residualização (FWL)

\[
P_F \equiv C(F)\left(C(F)'C(F)\right)^{-1}C(F)', \qquad
M_F \equiv I - P_F.
\]

Para qualquer vetor \(x\):
\[
\tilde x^F \equiv M_F x.
\]

### 1.3 Suposições técnicas mínimas

1. Mesma amostra para comparar curto e longo.
2. \(C(F)\) tem posto completo.
3. \(\tilde d^{F\prime}\tilde d^F > 0\).
4. No longo, \([\tilde d^F,\tilde z^F]\) tem posto 2 (sem colinearidade perfeita).

---

## 2) Prova 1: fórmula IVB com o mesmo \(F\) no curto e no longo

## 2.1 Definição dos modelos

Curto (S):
\[
y = \alpha_S + \beta_S d + C(F)\gamma_S + u_S.
\]

Longo (L):
\[
y = \alpha_L + \beta_L d + \theta_L z + C(F)\gamma_L + u_L.
\]

Como \(C(F)\) é o mesmo nos dois, FWL permite trabalhar no espaço residualizado por \(C(F)\):

\[
\tilde y^F = \beta_S \tilde d^F + \tilde u_S^F
\]
e
\[
\tilde y^F = \beta_L \tilde d^F + \theta_L \tilde z^F + \tilde u_L^F.
\]

## 2.2 Condição normal no modelo longo

Na regressão de \(\tilde y^F\) em \((\tilde d^F,\tilde z^F)\), a condição normal para \(\beta_L\) é:
\[
\tilde d^{F\prime}\left(\tilde y^F - \beta_L \tilde d^F - \theta_L \tilde z^F\right)=0.
\]

Expansão:
\[
\tilde d^{F\prime}\tilde y^F
- \beta_L \tilde d^{F\prime}\tilde d^F
- \theta_L \tilde d^{F\prime}\tilde z^F = 0.
\]

Isolando \(\beta_L\):
\[
\beta_L
=
\frac{\tilde d^{F\prime}\tilde y^F - \theta_L \tilde d^{F\prime}\tilde z^F}
{\tilde d^{F\prime}\tilde d^F}.
\]

## 2.3 Condição normal no modelo curto

No curto residualizado:
\[
\tilde d^{F\prime}\left(\tilde y^F-\beta_S\tilde d^F\right)=0
\]
\[
\Rightarrow\quad
\beta_S = \frac{\tilde d^{F\prime}\tilde y^F}{\tilde d^{F\prime}\tilde d^F}.
\]

## 2.4 Subtração longo menos curto

\[
\beta_L - \beta_S
=
\frac{\tilde d^{F\prime}\tilde y^F - \theta_L \tilde d^{F\prime}\tilde z^F}{\tilde d^{F\prime}\tilde d^F}
-\frac{\tilde d^{F\prime}\tilde y^F}{\tilde d^{F\prime}\tilde d^F}
=
-\theta_L\frac{\tilde d^{F\prime}\tilde z^F}{\tilde d^{F\prime}\tilde d^F}.
\]

Defina \(\pi^F\) pela regressão auxiliar:
\[
z = a + \pi^F d + C(F)\delta + \eta.
\]

FWL da auxiliar:
\[
\tilde z^F = \pi^F \tilde d^F + \tilde\eta^F
\quad\Rightarrow\quad
\pi^F = \frac{\tilde d^{F\prime}\tilde z^F}{\tilde d^{F\prime}\tilde d^F}.
\]

Substituindo:
\[
\boxed{\beta_L-\beta_S = -\theta_L\pi^F.}
\]

Isso prova a identidade IVB quando o conjunto de controles (incluindo fatores) é o mesmo.

---

## 3) Prova 2: fatores reestimados entre curto e longo

Agora o curto usa \(F_S\) e o longo usa \(F_L\):

- Curto: \(y \sim d + C(F_S)\)
- Longo: \(y \sim d + z + C(F_L)\)

Queremos \(\beta_L^{F_L} - \beta_S^{F_S}\).

## 3.1 Decomposição algébrica por soma e subtração

Some e subtraia \(\beta_S^{F_L}\):
\[
\beta_L^{F_L} - \beta_S^{F_S}
=
\underbrace{\left(\beta_L^{F_L} - \beta_S^{F_L}\right)}_{(A)}
+
\underbrace{\left(\beta_S^{F_L} - \beta_S^{F_S}\right)}_{(B)}.
\]

Defina:
\[
\Delta_F \equiv \beta_S^{F_L} - \beta_S^{F_S}.
\]

## 3.2 Termo (A)

No termo (A), o conjunto de controles é o mesmo (\(F_L\)) nos dois modelos; então pela Prova 1:
\[
(A) = -\theta_L^{F_L}\pi^{F_L}.
\]

## 3.3 Resultado final

\[
\boxed{
\beta_L^{F_L} - \beta_S^{F_S}
=
-\theta_L^{F_L}\pi^{F_L}
 + \Delta_F
}
\]
com
\[
\Delta_F = \beta_S^{F_L} - \beta_S^{F_S}.
\]

Interpretação: \(\Delta_F\) mede a mudança no coeficiente de \(d\) provocada apenas por trocar os fatores do curto de \(F_S\) para \(F_L\).

---

## 4) Caso `Z` apenas collider: o que é necessário para leitura causal

A identidade acima é algébrica. Para interpretar como “dano de collider”:

1. \(Z\) deve ser collider no problema substantivo (condicional em \(W,F\)).
2. \(Z\) não deve ser confounder do efeito de \(d\) em \(y\) (condicional em \(W,F\)).
3. O benchmark causal deve ser o curto (sem \(Z\)).

Sob essas condições, com fatores fixos:
\[
\beta_S^F \approx \tau
\quad\Rightarrow\quad
\beta_L^F - \tau \approx -\theta_L^F\pi^F.
\]

Se fatores mudam entre curto e longo:
\[
\beta_L^{F_L} - \tau
=
\underbrace{-\theta_L^{F_L}\pi^{F_L}}_{\text{componente via inclusão de }Z\text{ sob }F_L}
+
\underbrace{\Delta_F}_{\text{mudança por reestimação de fatores}}
+
\underbrace{\left(\beta_S^{F_S}-\tau\right)}_{\text{erro do benchmark curto}}.
\]

Logo, para “collider puro”, o ideal é trabalhar com fatores congelados (mesmo \(F\) no curto e no longo).

---

## 5) Caso `mixed` (`confounder + collider`)

Aqui, \(Z\) pode simultaneamente:
- reduzir viés por omissão (canal de confusão);
- introduzir distorção por condicionamento (canal collider).

## 5.1 Com fatores fixos \(F\)

Defina:
\[
\beta_S^F = \tau + U^F,\qquad
\beta_L^F = \tau + C^F.
\]

Onde:
- \(U^F\): componente líquido de viés no curto (sem \(Z\));
- \(C^F\): componente líquido de viés no longo (com \(Z\)).

Subtraindo:
\[
\beta_L^F - \beta_S^F = C^F - U^F.
\]

Mas pela Prova 1:
\[
\beta_L^F - \beta_S^F = -\theta_L^F\pi^F.
\]

Portanto:
\[
\boxed{-\theta_L^F\pi^F = C^F - U^F.}
\]

Isto é: no caso misto, \(-\theta\pi\) é efeito líquido, não identificação separada dos componentes.

## 5.2 Com fatores reestimados

\[
\beta_L^{F_L}-\beta_S^{F_S}
=
\left(\beta_L^{F_L}-\beta_S^{F_L}\right)
+
\left(\beta_S^{F_L}-\beta_S^{F_S}\right)
=
-\theta_L^{F_L}\pi^{F_L}+\Delta_F.
\]

Como acima:
\[
-\theta_L^{F_L}\pi^{F_L}=C^{F_L}-U^{F_L},
\]
então:
\[
\boxed{
\beta_L^{F_L}-\beta_S^{F_S}
=
\left(C^{F_L}-U^{F_L}\right)+\Delta_F.
}
\]

Resultado: há três elementos misturados na diferença total observada:

1. componente collider/confounding líquido sob \(F_L\);
2. componente de confusão líquida do benchmark;
3. mudança induzida por reestimação de fatores (\(\Delta_F\)).

---

## 6) Resumo prático (o que reportar)

Em aplicações com fatores latentes estimados separadamente:

1. Reportar \(-\theta_L^{F_L}\pi^{F_L}\) (efeito com fatores fixos no longo).
2. Reportar \(\Delta_F\) (mudança por reestimar fatores).
3. Reportar a soma:
\[
\beta_L^{F_L}-\beta_S^{F_S}
=
(-\theta_L^{F_L}\pi^{F_L})+\Delta_F.
\]

Sem separar esses termos, a leitura de “IVB puro” não é defensável.
