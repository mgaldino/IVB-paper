# Devil's Advocate Report -- Round 3 (Manuscript Delta Review)

**Manuscrito avaliado**: `ivb_paper_psrm.Rmd`
**Data da revisao**: 2026-03-01
**Revisor**: Devil's Advocate (Stage 2, Round 3)
**Target journal**: Political Science Research and Methods (PSRM)
**Revisao anterior**: `stage2_devils_advocate_round2.md` (Score: 78/100, REPROVADO)

---

## Score: 83/100 -> APROVADO

---

## Escopo desta revisao

Esta revisao avalia APENAS as mudancas feitas em resposta as Issues A-D da Round 2, verifica se os fixes introduziram novas inconsistencias, e computa o score atualizado via metodo delta.

---

## Issue A (Major, -8 na Round 2, ajustada para -5): Qualidade heterogenea das classificacoes DAG

**STATUS: SUBSTANCIALMENTE MELHORADO.**

Quatro sub-fixes foram aplicados:

### A1. Blair Refugees/IDPs: Collider -> Ambiguous

**Avaliacao: FIX GENUINO.**

A variavel foi reclassificada de "Collider" para "Ambiguous" na tabela de classificacao (linha 1261). A nota explicativa (linha 1268) articula explicitamente o argumento de reverse causality (Z->D): "the reverse channel---refugee crises triggering PKO deployment ($Z \to D$)---is equally plausible, making the variable simultaneously a potential confounder." Este era exatamente o argumento que a Round 2 previu que um referee faria. A reclassificacao e honesta e bem justificada.

Consequencia mecanica: Refugees/IDPs foi removido de `collider_candidates` no codigo R (linha 634), reduzindo a contagem de 14 para 13. A mediana |IVB/SE| muda de 0.13 para 0.11, refletindo a remocao de um valor que era exatamente a mediana anterior (|IVB/SE| = 0.127).

### A2. Ballard-Rosa IMF program e Sov. debt crisis: Collider -> Collider (weak)

**Avaliacao: FIX PARCIAL, ADEQUADO.**

Ambas variaveis foram reclassificadas de "Collider" para "Collider (weak)" (linhas 1329-1330). A nota explicativa (linha 1348) reconhece que "both channels operate through indirect, multi-step causal chains" e que "the $D \to Z$ channel for IMF programs is debatable." Uma referencia foi adicionada para IMF program (Alesina 1987), mas Sov. debt crisis continua sem referencia.

O fix e honesto sobre a fragilidade da classificacao, mas nao a resolve completamente: ambas variaveis permanecem como collider candidates na tabela-resumo, e a distincao entre "Collider" e "Collider (weak)" nao tem criterios formais. No entanto, o reconhecimento explicito da fraqueza e suficiente para um referee -- a transparencia e a defesa.

**Ressalva residual**: Sov. debt crisis continua sem referencia para nenhum dos dois canais causais. Isso e o elo mais fraco das classificacoes remanescentes.

### A3. Albers Liberal democracy: "Turnover -> democratization" -> "Turnover -> regime openness"

**Avaliacao: FIX GENUINO.**

A formulacao anterior ("Turnover -> democratization") era circular: government turnover e um componente da democratizacao. A nova formulacao ("Turnover -> regime openness", linha 1285) e conceitualmente distinta: regime openness (abertura do regime) e uma propriedade mais ampla que inclui mas nao se reduz a turnover. A referencia (Besley & Persson 2011) suporta a ideia de que governos mais abertos (liberal democracy) surgem em contextos de maior barganha fiscal, o que e o canal Y->Z. A classificacao permanece como "Collider (weak)", o que e proporcional a forca da evidencia.

### A4. Contagens atualizadas

**Avaliacao: CONSISTENTE.**

Verifiquei todas as ocorrencias de contagens e medianas:

| Localizacao | Contagem | Mediana | Status |
|-------------|----------|---------|--------|
| Introducao (linha 77) | 13 | 0.11 | OK |
| Narrativa pos-tabela (linha 701) | 13 | 0.11 | OK |
| Conclusao (linha 906) | 13 | 0.11 | OK |
| Abstract (linha 32) | nao especifica | "below 0.15" | OK (compativel) |
| Codigo R (linhas 630-640) | 13 itens | N/A | OK |

Nenhuma ocorrencia residual de "14" ou "0.13" foi encontrada no manuscrito.

**Verificacao numerica da mediana**: A partir do CSV `standardized_ivb_metrics.csv`, os 10 valores de |IVB/SE| disponiveis (excluindo Albers com SE=NA) sao, ordenados: 0.001, 0.020, 0.074, 0.076, 0.087, 0.141, 0.194, 0.282, 0.476, 2.108. A mediana (media do 5o e 6o valores) = (0.087 + 0.141) / 2 = 0.114, arredondado para 0.11. Correto.

**Impacto na deducao**: A Issue A da Round 2 deduzia -8 (ajustada para -5 por mitigantes) por classificacoes heterogeneas. As mudancas abordam diretamente as classificacoes mais problematicas identificadas na Round 2 (Blair Refugees/IDPs, Albers Liberal democracy) e adicionam transparencia as mais fracas (Ballard-Rosa IMF/Sov. debt). A base evidencial e agora mais honesta, embora nao perfeita. Recupero +3 pontos.

---

## Issue B (Minor, -2 na Round 2): Inconsistencia Claassen GDP growth

**STATUS: COMPLETAMENTE RESOLVIDO. FIX GENUINO.**

A nota explicativa abaixo da tabela de classificacao de Claassen (linha 1225) agora explica: "GDP growth shares the same mechanism but is excluded from the main table to avoid double-counting the same causal channel. Both GDP variables are classified as 'Collider (weak)' because the $D \to Z$ channel (public support -> GDP) is indirect and operates through institutional quality rather than a direct causal mechanism."

Este fix resolve a inconsistencia de forma elegante: (1) justifica por que GDP growth nao esta na tabela-resumo (double-counting), (2) mantem a classificacao "Collider (weak)" no Appendix F para transparencia, e (3) articula o racional causal para a classificacao "weak." O ROOT CAUSE da inconsistencia era a falta de explicacao para a discrepancia entre Appendix F e tabela-resumo; isso foi eliminado.

**Impacto na deducao**: Recupero os 2 pontos completos.

---

## Issue C (Minor, -1 na Round 2): Entrada bibliografica Cederman incorreta

**STATUS: COMPLETAMENTE RESOLVIDO.**

A entrada foi corrigida de `@article` para `@book` (linha 327 do references.bib):
```bibtex
@book{cederman_etal2013,
  title={Inequality, Grievances, and Civil War},
  author={Cederman, Lars-Erik and Gleditsch, Kristian Skrede and Buhaug, Halvard},
  year={2013},
  publisher={Cambridge University Press}
}
```

O titulo e agora o titulo do livro, o tipo e `@book`, e o campo `journal` espurio foi removido. A formatacao bibliografica sera correta.

**Impacto na deducao**: Recupero 1 ponto completo.

---

## Issue D (Minor, -2 na Round 2): IVB/SE limitacao nao discutida

**STATUS: COMPLETAMENTE RESOLVIDO. FIX GENUINO.**

Um paragrafo dedicado foi adicionado na narrativa pos-tabela (linha 705):

> "A caveat on cross-study comparisons: standard errors vary substantially across studies (from 0.005 in Rogowski et al. to 0.216 in Claassen's FE specification), reflecting differences in sample size, clustering structure, and treatment variation rather than differences in bias magnitude. The |IVB/SE| benchmark is most informative *within* a given study---as a measure of whether collider bias exceeds that study's own sampling uncertainty---and should be interpreted with caution when comparing across studies with very different precision levels."

O paragrafo aborda exatamente o que a Round 2 solicitou: (1) menciona a variacao de ~40x nos SEs com exemplos concretos (0.005 vs. 0.216), (2) explica que SEs refletem propriedades idiossincraticas (sample size, clustering, treatment variation), (3) recomenda cautela em comparacoes cross-study, e (4) afirma que o benchmark e mais informativo within-study. O fix e genuino e completo.

**Impacto na deducao**: Recupero os 2 pontos completos.

---

## Verificacao de novas inconsistencias

### Verificacao 1: Contagens internas

Todas as ocorrencias de "13 collider candidates" no manuscrito sao consistentes entre si e com o codigo R. Nenhuma ocorrencia residual de "14" foi encontrada. PASS.

### Verificacao 2: Mediana consistente com os dados

A mediana de 0.11 e numericamente correta para os 10 valores de |IVB/SE| disponiveis apos excluir Albers (SE=NA) e remover Blair Refugees/IDPs (reclassificado como Ambiguous). PASS.

### Verificacao 3: Abstract vs. corpo do texto

O abstract diz "below 0.15" (vago), o corpo diz "approximately 0.11" (preciso). Ambos sao corretos e consistentes. PASS.

### Verificacao 4: "One-eighth" como descricao da mediana

Linhas 701 e 906 descrevem a mediana como "about one-eighth of a standard error" (1/8 = 0.125). A mediana real e 0.114. A diferenca e pequena e coberta pelo qualificador "about." PASS (marginal).

### Verificacao 5: Reclassificacoes coerentes entre tabela e nota

- Blair Refugees/IDPs: tabela diz "Ambiguous" (linha 1261), nota explica reverse causality (linha 1268). Coerente.
- Ballard-Rosa IMF: tabela diz "Collider (weak)" (linha 1329), nota explica indirect chains (linha 1348). Coerente.
- Ballard-Rosa Sov. debt: tabela diz "Collider (weak)" (linha 1330), nota explica (linha 1348). Coerente.
- Albers Liberal democracy: tabela diz "Collider (weak)" com "Turnover -> regime openness" (linha 1285). Coerente com a correcao de circularidade.

PASS.

### Verificacao 6: Collider candidates no codigo R vs. Appendix F

O codigo R (linhas 630-640) lista:
- Claassen FE: Log GDP p.c. -- Appendix F: Collider (weak). Incluido. OK.
- Leipziger SEI: Log GDP p.c. -- Appendix F: Collider. Incluido. OK.
- Leipziger ext: Civil war, GDP growth -- Appendix F: Collider, Collider. Incluido. OK.
- Blair: Foreign Aid, GDP per capita -- Appendix F: Collider, Collider. Incluido. OK.
- Blair: Refugees/IDPs -- Appendix F: Ambiguous. NAO incluido. OK.
- Albers: Hyperinflation, GDP growth, Liberal democracy -- Appendix F: Collider, Collider, Collider (weak). Incluido. OK.
- Rogowski: Log GDP p.c. -- Appendix F: Collider + Confounder. Incluido. OK.
- Ballard-Rosa: Inflation crisis, IMF program, Sov. debt crisis -- Appendix F: Collider, Collider (weak), Collider (weak). Incluido. OK.
- Claassen FE: GDP growth -- Appendix F: Collider (weak). NAO incluido. Explicado na nota (double-counting). OK.

PASS.

### Observacao: Leipziger ext. GDP growth vs. Claassen GDP growth

No Appendix F (linha 1241), Leipziger ext. GDP growth e classificado como "Collider" e esta incluido na tabela-resumo. Para Claassen, GDP growth e classificado como "Collider (weak)" e excluido por double-counting. A logica de exclusao por double-counting nao e aplicada a Leipziger.

**Severidade**: Negligivel. A diferenca pode ser justificada porque (1) na especificacao estendida de Leipziger, GDP growth e um controle adicional com papel causal distinto de Log GDP p.c. no contexto de ethnic inequality, e (2) o IVB de GDP growth em Leipziger ext. e negligivel (|IVB/SE| = 0.001). A inconsistencia e mais estetica do que substantiva e nao justifica deducao.

---

## Calculo do score via metodo delta

```
Score Round 2: 78

Pontos recuperados por fixes:
  Issue A (classificacoes DAG): +3
    - Blair Refugees/IDPs reclassificado como Ambiguous: +1.5
    - Albers Liberal democracy corrigido: +0.5
    - Ballard-Rosa IMF/Sov. debt reclassificados como weak: +0.5
    - Contagens atualizadas e consistentes: +0.5
  Issue B (Claassen GDP growth inconsistencia): +2
  Issue C (bib Cederman): +1
  Issue D (IVB/SE limitacao): +2

Total recuperado: +8

Novas deducoes: 0
  (Nenhuma inconsistencia substantiva introduzida pelos fixes.)

Net delta: +8

Score bruto: 78 + 8 = 86

Ajuste de calibracao: -3
  A Issue A da Round 2 nao foi 100% resolvida:
  - Sov. debt crisis permanece sem referencia (-1)
  - Distincao Collider vs. Collider (weak) carece de criterios formais (-1)
  - Classificacoes com cadeias causais indiretas nao foram resolvidas para
    Albers GDP growth (YoY) que permanece sem referencia (-1)

Score final: 86 - 3 = 83/100
```

**Score final: 83/100 -> APROVADO (threshold: 80/100)**

---

## Resumo das deducoes remanescentes

| Categoria | Issue | Deducao | Status vs Round 2 |
|-----------|-------|---------|-------------------|
| Critico | Formula trivial | -7 | Nao alterado |
| Critico | Simulacoes v4 | -8 | Nao alterado |
| Major | Classificacoes DAG heterogeneas | -2 | Melhorou (-5 -> -2) |
| Major | "IVBs modest" + selecao estudos | -5 | Nao alterado |
| Minor | Abstract overpromises | -2 | Nao alterado |
| Minor | Proposition 4 vazia | -2 | Nao alterado |
| Minor | Nickell nao verificada | -2 | Nao alterado |
| Minor | Nenhuma aplicacao ADL | -3 | Nao alterado |
| Minor | Sem SEs para IVB | -2 | Nao alterado |
| Minor | Appendix E superficial | -2 | Nao alterado |
| Minor | IVB/SE limitacao | 0 | **Resolvido** (-2 -> 0) |
| Minor | Inconsistencia Claassen GDP growth | 0 | **Resolvido** (-2 -> 0) |
| Minor | Bib entry Cederman | 0 | **Resolvido** (-1 -> 0) |
| Minor | Contagem dupla Leipziger | -1 | Nao alterado |

---

## Vulnerabilidades remanescentes mais criticas

1. **Simulacoes v4 nao validadas** (-8): Esta continua sendo a maior vulnerabilidade operacional. O CLAUDE.md indica que o review de codigo permanece PENDENTE. A Secao 5 depende destas simulacoes para sustentar os quatro mecanismos que explicam por que IVBs sao pequenos.

2. **Ballard-Rosa Sov. debt crisis sem referencia**: O unico collider candidate remanescente sem nenhuma referencia de suporte. Um referee poderia questionar por que esta incluido na tabela-resumo sem evidencia citada para nenhum dos canais causais.

3. **Formula trivial como contribuicao** (-7): Issue conceitual que nao muda com edits textuais. A defesa e adequada mas um referee hostil pode insistir.

---

## Avaliacao final

O manuscrito ultrapassou o threshold de aprovacao. Os quatro fixes solicitados foram implementados de forma genuina, nao cosmetica:

1. **Blair Refugees/IDPs -> Ambiguous**: Reclassificacao honesta com justificativa explicita de reverse causality (Z->D). A nota explicativa antecipa exatamente a objecao que um referee faria.

2. **Ballard-Rosa IMF/Sov. debt -> Collider (weak)**: Reconhecimento transparente de cadeias causais indiretas. Referencia adicionada para IMF (Alesina 1987). Nota explicativa reconhece debatibilidade.

3. **Albers Liberal democracy**: "Turnover -> regime openness" elimina a circularidade da formulacao anterior.

4. **Claassen GDP growth**: Nota explicativa resolve elegantemente a inconsistencia entre Appendix F e tabela-resumo via argumento de double-counting.

5. **Bib Cederman**: Corrigido de @article para @book.

6. **IVB/SE limitacao**: Paragrafo completo com dados concretos (0.005 vs. 0.216), explicacao causal da variacao, e recomendacao de cautela cross-study.

As contagens (13) e medianas (0.11) foram atualizadas consistentemente em todo o manuscrito: abstract, introducao, narrativa pos-tabela, conclusao e codigo R. Nenhuma inconsistencia numerica foi encontrada.

O paper esta a 5 pontos das barreiras restantes mais impactantes: validacao das simulacoes v4 (+5 estimado) e resolucao final das classificacoes remanescentes sem referencia (+2 estimado). Estes fixes elevariam o score para ~88-90.

**APROVADO (83/100, threshold 80/100)**
