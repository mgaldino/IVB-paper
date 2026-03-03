# Ideação: Tratamento Teórico do Caso Collider + Confounder

**Status**: DRAFT — iteração 1
**Data**: 2026-03-01
**Origem**: Crítica do referee cold-read (Major 3.4)

---

## O Puzzle

O referee identifica que o cenário empiricamente dominante é Z ser **simultaneamente colisor e confounder** (ex: GDP per capita em quase todos os estudos). O paper atual:
- Reconhece o problema (Seção 3.6)
- Cita Ding & Miratrix (2015) sobre a butterfly-structure
- Ilustra com Rogowski (58% IVB, mas pode ser deconfounding legítimo)
- Mas **não oferece ferramentas analíticas** para o researcher lidar com a ambiguidade

A fórmula IVB diz: β_long − β_short = −θ* × π. Mas quando Z é colisor+confounder, **nem β_long nem β_short são consistentes**. O paper não ajuda o researcher a decidir qual é o "menor mal."

---

## Direção 1: Intervalo de Identificação Parcial (Agnostic Bounds)

**A ideia**: Quando o researcher não sabe se Z é colisor ou confounder, o β verdadeiro está em algum lugar entre β_short e β_long. Formalizar como identificação parcial.

**O argumento**:
- Se Z é colisor puro → β_short é consistente → β_true = β_short
- Se Z é confounder puro → β_long é consistente → β_true = β_long
- Se Z é ambos → β_true ∈ [min(β_short, β_long), max(β_short, β_long)]
- A **largura** desse intervalo é exatamente |IVB|

**Proposição candidata**: "Under DAG uncertainty about the causal role of Z, the true treatment effect lies in the interval [β_short, β_long] (or its reverse). If both estimates are statistically significant and of the same sign, the qualitative conclusion is robust to DAG misspecification."

### Feedback do autor (iteração 1):

**PROBLEMA SÉRIO**: A proposição assume que os dois extremos (colisor puro vs. confounder puro) delimitam o espaço de viés possível. Isso ignora **bias amplification** (Pearl 2011, Middleton & Aronow 2015). No caso misto, o viés de uma das especificações pode ser *maior* do que em ambos os extremos puros. Sem tratar bias amplification, o intervalo [β_short, β_long] não é um bound válido e o resultado não ajuda o pesquisador aplicado.

**Para avançar**: É preciso:
1. Formalizar quando bias amplification ocorre no contexto collider+confounder
2. Determinar se o intervalo [β_short, β_long] contém β_true mesmo com amplification, ou se não
3. Se não contém, derivar bounds corretos que levem amplification em conta
4. Ou alternativamente, mostrar condições suficientes sob as quais amplification é negligível

**Status**: BLOQUEADO até resolver o problema de bias amplification.

---

## Direção 2: Parâmetro de Sensibilidade κ (Cinelli-Hazlett Style)

**A ideia**: Parametrizar a incerteza sobre o DAG com κ ∈ [0,1] capturando a "fração colisor" do IVB.

**Formalização tentativa**:
- κ = fração do IVB atribuível ao canal colisor
- Bias(β_short) = (1−κ) × IVB
- Bias(β_long) = −κ × IVB
- β_short é preferível ⟺ κ > 1/2

### Feedback do autor (iteração 1):

Altamente especulativo. κ não é estimável e a decomposição linear pode não ser bem-definida quando os canais interagem (simultaneidade). Precisa de fundamentação mais sólida antes de propor.

**Status**: ESPECULATIVO.

---

## Direção 3: Butterfly-Structure sob TWFE (Extensão de Ding & Miratrix 2015)

**A ideia original**: Estender o resultado de Ding & Miratrix (condicionar em Z reduz viés líquido em ~75% do espaço paramétrico) para TWFE.

### Feedback do autor (iteração 1):

**PROBLEMA ESTRUTURAL**: O DAG em TSCS tem estrutura diferente da butterfly cross-sectional. Em TSCS:
- Há dependência temporal (Y_{t-1} → Y_t, D_{t-1} → D_t)
- FE absorve componentes between mas também introduz Nickell bias
- A butterfly de Ding & Miratrix tem U1→D, U1→Z, D→Z←Y, U2→Z, U2→Y — quatro variáveis latentes com simetria específica
- Em TSCS, a "confounding" é tipicamente Z_{t-1}→D_t e Z_{t-1}→Y_t (lag structure), não a butterfly simétrica

**Para avançar**: Precisa primeiro mapear o DAG TSCS correto para o caso collider+confounder, e depois ver se a butterfly é caso especial, ou se precisa de análise própria.

**Status**: REQUER ADAPTAÇÃO SUBSTANCIAL DO DAG.

---

## Direção 4: Equações Simultâneas

**A ideia**: Derivar Bias(β_short) e Bias(β_long) no sistema:
- Y = βD + δZ + ε
- Z = γ_D·D + γ_Y·Y + ν

### Feedback do autor (iteração 1):

Altamente especulativo. O loop Y↔Z cria simultaneidade; OLS inconsistente em ambas equações; expressões provavelmente opacas.

**Status**: NÃO RECOMENDADO para este paper.

---

## Síntese (iteração 1)

| Direção | Status | Próximo passo |
|---------|--------|---------------|
| 1: Bounds | BLOQUEADO | Resolver bias amplification |
| 2: κ sensitivity | ESPECULATIVO | Precisa de fundamento |
| 3: Butterfly+TWFE | REQUER ADAPTAÇÃO | Mapear DAG TSCS correto |
| 4: Equações simultâneas | NÃO RECOMENDADO | — |

**Nenhuma direção está pronta para implementação.** O obstáculo principal é que todas dependem de resolver o problema de bias amplification ou de adaptar a butterfly para TSCS — ambos não-triviais.

## Referências

- Ding & Miratrix (2015). "To Adjust or Not to Adjust? Sensitivity Analysis of M-Bias and Butterfly-Bias." *Journal of Causal Inference*.
- Cinelli & Hazlett (2020). "Making Sense of Sensitivity: Extending Omitted Variable Bias." *JRSS-B*.
- Greenland (2003). "Quantifying Biases in Causal Models: Classical Confounding vs Collider-Stratification Bias." *Epidemiology*.
- Pearl (2011). "Invited Commentary: Understanding Bias Amplification." *AJE*.
- Middleton & Aronow (2015). "Bias Amplification and Cancellation of Offsetting Biases." *JCI*.
