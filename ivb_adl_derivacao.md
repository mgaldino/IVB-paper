# Derivação do IVB para o caso ADL

Abaixo está a derivação do **viés por variável incluída** (IVB) quando você estima um modelo **ADL** e adiciona um controle “problemático” (p.ex. post-treatment/collider) `Z_t`. A derivação usa **FWL** (Frisch–Waugh–Lovell) e deixa claro que o resultado tem a mesma forma do OVB padrão, mas com **residualização pelos lags**.

---

## 1) Caso base: ADL(1,0)

### Modelo “curto” (correto)
\[
y_t = \alpha + \beta D_t + \rho y_{t-1} + e_t,
\qquad \mathbb{E}[e_t\mid D_t, y_{t-1}] = 0.
\]

### Modelo “longo” (errado) incluindo `Z_t`
\[
y_t = \alpha^{\star} + \beta^{\star} D_t + \rho^{\star} y_{t-1} + \theta^{\star} Z_t + v_t.
\]

**Objetivo:** expressar o viés em \(\beta^{\star}\) relativo a \(\beta\), isto é, \(\beta^{\star} - \beta\).

---

## 2) Passo-chave: FWL (residualização pelos controles dinâmicos)

Defina o conjunto de controles “legítimos” no ADL(1,0):
\[
W_t = (1,\; y_{t-1}).
\]

Defina os resíduos após projetar cada variável em \(W_t\):

- \(\tilde y_t := y_t - \widehat{\Pi}_y W_t\)
- \(\tilde D_t := D_t - \widehat{\Pi}_D W_t\)
- \(\tilde Z_t := Z_t - \widehat{\Pi}_Z W_t\)

Pelo teorema FWL, a regressão longa
\[
y_t \sim D_t + y_{t-1} + Z_t
\]
é equivalente a
\[
\tilde y_t \sim \tilde D_t + \tilde Z_t.
\]

---

## 3) Fórmula do coeficiente em dois regressores

Na regressão \(\tilde y_t \sim \tilde D_t + \tilde Z_t\), o coeficiente em \(\tilde D_t\) pode ser escrito como:
\[
\beta^{\star}
=
\frac{\operatorname{Cov}(\tilde D_t,\tilde y_t)-\theta^{\star}\operatorname{Cov}(\tilde D_t,\tilde Z_t)}
{\operatorname{Var}(\tilde D_t)}.
\]

Já o coeficiente “curto” (no modelo correto) é:
\[
\beta
=
\frac{\operatorname{Cov}(\tilde D_t,\tilde y_t)}
{\operatorname{Var}(\tilde D_t)}.
\]

Subtraindo, obtemos o IVB:
\[
\beta^{\star} - \beta
=
-\theta^{\star}\,\frac{\operatorname{Cov}(\tilde D_t,\tilde Z_t)}{\operatorname{Var}(\tilde D_t)}.
\]

---

## 4) Regressão auxiliar e forma “estimável”

Considere a regressão auxiliar:
\[
Z_t = a + \pi D_t + \lambda y_{t-1} + \eta_t.
\]

O coeficiente \(\pi\) é o efeito **parcial** de \(D_t\) sobre \(Z_t\) controlando por \(y_{t-1}\). Pela álgebra de regressão parcial:
\[
\pi
=
\frac{\operatorname{Cov}(\tilde D_t,\tilde Z_t)}{\operatorname{Var}(\tilde D_t)}.
\]

Substituindo:
\[
\boxed{
\text{IVB}(\beta)
=
\beta^{\star}-\beta
=
-\theta^{\star}\,\pi
}
\]

### Como estimar na prática (duas regressões)
1. **Regressão longa:** \(y_t \sim D_t + y_{t-1} + Z_t\)  \(\Rightarrow\) pegue \(\hat\theta^{\star}\).
2. **Regressão auxiliar:** \(Z_t \sim D_t + y_{t-1}\) \(\Rightarrow\) pegue \(\hat\pi\).
3. **Viés estimado:** \(\widehat{\text{IVB}} = -\hat\theta^{\star}\,\hat\pi\).

---

## 5) Forma geral: ADL(p,q)

Modelo curto:
\[
y_t
=
\alpha
+\sum_{i=1}^{p}\rho_i y_{t-i}
+\sum_{j=0}^{q}\beta_j D_{t-j}
+e_t.
\]

Modelo longo (incluindo \(Z_t\)):
\[
y_t
=
\alpha^{\star}
+\sum_{i=1}^{p}\rho_i^{\star} y_{t-i}
+\sum_{j=0}^{q}\beta_j^{\star} D_{t-j}
+\theta^{\star} Z_t
+v_t.
\]

Seja \(X_t\) o vetor de controles “legítimos” (constante, \(y_{t-1},...,y_{t-p}\) e os lags relevantes de \(D\) dependendo de qual \(\beta_j\) está em foco). Então, para qualquer \(\beta_j\):

\[
\boxed{
\beta_j^{\star} - \beta_j
=
-\theta^{\star}\,\pi_j
}
\]

onde \(\pi_j\) é o coeficiente em \(D_{t-j}\) na regressão auxiliar:
\[
Z_t \sim D_{t-j} + X_t.
\]

---

## 6) Observação: por que a dinâmica importa na prática

A **forma** do viés é simples, mas a dinâmica altera fortemente \(\pi\) e \(\pi_j\), porque tudo é “parcializado” por lags. Em particular:

- Se \(D_t\) é muito previsível pelos lags, \(\tilde D_t\) pode ter pouca variação efetiva, e \(\pi\) pode ficar instável.
- Se \(Z_t\) é post-treatment (resposta de \(y\) ou de choques correlacionados), tende a ocorrer \(\theta^{\star}\neq 0\) e \(\pi\neq 0\) mecanicamente.

---

Se você quiser, eu adapto a notação para o seu ADL específico (p,q) e para o seu desenho causal (o que exatamente é \(Z_t\), e em que timing ele entra).
