# Ideação: Lead do Paper IVB

## O Puzzle

Você tem um paper com múltiplas contribuições — formula IVB, conexão Blackwell/Glynn/Imai/Kim, simulações NL extensas, 6 aplicações empíricas — e a pergunta é: qual é o **gancho** que maximiza impacto? O lead atual (fórmula IVB como contribuição principal) pode sofrer de um problema de "so what?" — uma identidade FWL não é, por si só, surpresa. O que é surpresa é o que ela *revela*.

## O que o paper realmente tem

Antes de avaliar leads, inventário do que existe:

1. **Fórmula IVB = −θ*·π** (FWL identity, cross-section + panel)
2. **Extensão para ADL+FE** com decomposição between/within
3. **Bridge entre 3 literaturas**: IVB (Pearl/DAGs), post-treatment bias (Blackwell & Glynn), strict exogeneity (Imai & Kim)
4. **Resultado quantitativo**: |IVB| < 1% de β em 6 estudos publicados
5. **Simulações NL extensas**: 8 tipos NL, boundary bounded/unbounded
6. **Resultado T=10 vs T=30**: ADL_all domina mesmo com T curto
7. **Diagnóstico aplicável**: pesquisador pode calcular IVB com dados reais

## Cinco leads possíveis

---

### Lead A: "The Formula" (atual)

**Pitch**: Ninguém computou IVB antes. Aqui está a fórmula e como usá-la.

| Dimensão | Avaliação |
|---|---|
| Novidade | Média. FWL identity é conhecida; a *aplicação* ao collider é nova |
| "So what?" | Fraco. Referee pergunta: "OK, e daí? A fórmula diz algo que eu não sabia?" |
| Audiência | Metodólogos |
| Target journals | Political Analysis, PSRM |
| Risco | Paper pode parecer um "technical note" — correto mas menor |

**Problema central**: A fórmula é o *instrumento*, não o *resultado*. Se o lead é a fórmula, o resultado ("IVB é pequeno") fica como corolário, e o paper perde punch.

---

### Lead B: "Resolvendo o trade-off TSCS" ⭐

**Pitch**: Há um debate aberto sobre o melhor modelo para painéis (TWFE vs ADL vs MSM). Blackwell & Glynn dizem: use MSM, ADL tem post-treatment bias. Imai & Kim dizem: use ADL+FE, TWFE básico não é identificado. Nós mostramos que o trade-off é **quantificável** e, na prática, **resolvido**: ADL+FE domina porque o post-treatment bias (= IVB) é negligível sob condições realistas.

| Dimensão | Avaliação |
|---|---|
| Novidade | Alta. Ninguém quantificou o trade-off — todos argumentam qualitativamente |
| "So what?" | Forte. Resolve uma questão prática que afeta centenas de papers em CP |
| Audiência | Aplicados + metodólogos |
| Target journals | **AJPS, APSR**, Political Analysis |
| Risco | Reviewer pode dizer "ADL+FE já é o default, qual a novidade?" |

**Estrutura**:
1. Intro: O debate TSCS está mal colocado — é um trade-off quantificável, não qualitativo
2. A fórmula IVB como ferramenta de quantificação
3. Por que IVB é pequeno sob linearidade (álgebra + intuição)
4. Boundary: quando IVB cresce (NL unbounded → trade-off vira real)
5. Aplicações: 6 estudos confirmam
6. Recomendação: ADL+FE como default, fórmula para verificar

**A fórmula IVB é o instrumento-chave**, mas o *resultado* é a resolução do debate. Isso é muito mais forte para top journal.

---

### Lead C: Dois papers separados

**Paper 1**: "Included Variable Bias: A Formula" (methods note)
- Fórmula cross-section + panel
- 6 aplicações empíricas
- Curto, technical, Political Analysis ou PSRM

**Paper 2**: "When Does Model Choice Matter in TSCS?" (substantive)
- O debate Blackwell/Glynn vs Imai/Kim
- Simulações NL como boundary conditions
- Resultado: ADL+FE domina exceto sob NL unbounded
- AJPS/APSR

| Dimensão | Avaliação |
|---|---|
| Novidade | Alta (dividida em duas contribuições claras) |
| Viabilidade | Média. Paper 1 sozinho é fino. Paper 2 precisa de paper 1 publicado |
| Risco | Dependency chain: se paper 1 demora, paper 2 fica travado |
| Benefício | Cada paper tem narrativa mais limpa |

**Minha avaliação**: Factível mas subótimo. Paper 1 como standalone é um "note" — correto, citável, mas não um blockbuster. E o timing é difícil. Melhor unificar.

---

### Lead D: "Diagnostic Framework"

**Pitch**: Pesquisadores precisam decidir se incluir um controle que pode ser collider. Oferecemos um framework diagnóstico: compute IVB, compare com SE, decida.

| Dimensão | Avaliação |
|---|---|
| Novidade | Média-alta. Ferramental novo |
| "So what?" | Forte na prática, mas parece "aplicado demais" para top journal |
| Audiência | Aplicados (quase exclusivamente) |
| Target journals | PSRM, Political Analysis |
| Risco | Reviewer: "Isso é um pacote de R, não um paper" |

Essa é essencialmente a lead A com roupagem prática. Melhor que A, mas ainda abaixo de B.

---

### Lead E: "Bridge/Unification"

**Pitch**: Blackwell & Glynn (post-treatment bias), Imai & Kim (strict exogeneity), e Pearl (collider bias) descrevem o **mesmo fenômeno** de três ângulos. A fórmula IVB unifica os três e mostra que o problema é pequeno sob condições realistas.

| Dimensão | Avaliação |
|---|---|
| Novidade | Alta. A conexão entre os três nunca foi formalizada |
| "So what?" | Forte. Simplifica um landscape confuso para aplicados |
| Audiência | Metodólogos + aplicados |
| Target journals | AJPS, Political Analysis |
| Risco | Reviewer: "A unificação é óbvia em retrospecto" — mas isso é *bom* para contribuições elegantes |

Essa é a lead mais "intelectual" e a que provavelmente gera mais citações de longo prazo. Mas é próxima de B — a diferença é que B enfatiza o *resultado prático* ("use ADL+FE") enquanto E enfatiza a *elegância teórica* ("os três são o mesmo fenômeno").

---

## Minha recomendação: Lead B com elementos de E

**Um paper, lead prático, fundação teórica elegante.**

A razão é simples: papers em CP que resolvem debates práticos > papers que derivam fórmulas. A fórmula é o motor, mas o carro é "quando e por que ADL+FE domina."

### Estrutura recomendada

| Seção | Conteúdo | Lead A (atual) | Lead B+E (proposto) |
|---|---|---|---|
| **Intro** | O problema | "Collider bias exists" | "There's an unresolved debate in TSCS" |
| **2** | Framework | DAGs + collider | IVB como unificação de 3 perspectivas |
| **3** | Fórmula | Derivação detalhada | Derivação **como ferramenta** para quantificar trade-off |
| **4** | Painel | Extensão para ADL+FE | **Resultado principal**: IVB é pequeno, ADL+FE domina |
| **5** | Boundary | — | **NL simulations**: bounded → ok, unbounded → trade-off real |
| **6** | Aplicações | 6 estudos | 6 estudos **confirmam** o resultado teórico |
| **7** | Conclusão | "Use a fórmula" | "ADL+FE é o default. A fórmula diz quando não é." |

### O que muda na prática

1. **Primeiro parágrafo**: não começa com "collider bias is a problem" — começa com "applied researchers face a fundamental model choice: TWFE, ADL, or MSM"
2. **A fórmula aparece na seção 3**, não na intro. A intro fala do trade-off e promete resolvê-lo.
3. **As simulações NL ganham protagonismo**: não são robustness checks, são a **delimitação da claim** ("ADL+FE domina *exceto* sob NL unbounded")
4. **A conexão BG/IK/Pearl vira a seção teórica**, não um aside

### Por que NÃO dois papers

O resultado "IVB é pequeno" só é interessante **no contexto do debate TSCS**. Sozinho, é um "cálculo que dá número pequeno." Dentro do debate, é a resolução: "o post-treatment bias que Blackwell & Glynn identificaram é empiricamente negligível, então o custo de perder α_i com MSM é injustificado."

A fórmula sem o debate é um technical note. O debate sem a fórmula é argumentação qualitativa. Juntos, é um paper completo.

### O resultado NL como *strenght*, não *weakness*

No lead A, o resultado "Dlog amplifica IVB" é uma complicação inconveniente. No lead B, é uma **feature**: "Mostramos exatamente a fronteira. O trade-off é real se — e somente se — a não-linearidade no canal collider é unbounded. Em CP, onde variáveis são tipicamente bounded (proporções, índices, contagens log-transformadas), isso é virtualmente implausível."

Isso transforma a limitação em uma **condição de aplicabilidade** precisa — que é exatamente o que referees querem ver.

---

## Próximos passos sugeridos

1. **Reescrever a intro** com o lead B+E: abrir com o debate TSCS, não com collider bias
2. **Reestruturar a seção teórica** como unificação BG/IK/Pearl (atualmente está no CLAUDE.md mas não no paper)
3. **Promover as simulações NL** de apêndice para seção principal (boundary conditions)
4. **Considerar mudar o título**: algo como "When Does Model Choice Matter? Quantifying the TWFE–ADL Trade-off in Panel Data" — com subtítulo mencionando IVB
5. **Avaliar target journal**: com lead B+E, AJPS ou APSR são viáveis. Com lead A, PSRM é o teto
