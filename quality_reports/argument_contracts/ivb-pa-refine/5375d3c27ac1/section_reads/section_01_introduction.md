## Registro `reader-introduction`

### Tese

A Introduction formula uma contribuição em dois níveis. O objeto geral é o **diagnóstico de deslocamento de especificação**: em modelos lineares aninhados, $\widehat{\Delta}_Z=\widehat{\beta}^{\star}-\widehat{\beta}=-\widehat{\theta}^{\star}\widehat{\pi}$ mede exatamente quanto a inclusão de $Z$ desloca o coeficiente do tratamento. O payoff aplicado, mais estreito, é avaliar ADL + FE com estados defasados como baseline condicional para o efeito contemporâneo do tratamento (CET) em TSCS. Fonte: [ivb_paper_pa.Rmd](/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/ivb_paper_pa.Rmd:178).

| Claim | Localizador | Escopo |
|---|---|---|
| Covariáveis contemporâneas podem ser simultaneamente atraentes como controles e responsivas ao tratamento; incluir ou omitir pode gerar problemas distintos. | L180–182; PDF pp. 1–2 | Motivação por painéis TSCS e literatura correlata; o paper não promete resolver o problema geral. |
| A decomposição é exata e diretamente estimável em modelos lineares aninhados. | L184–188; PDF p. 2; abstract L34 | Descreve movimento entre coeficientes; DAG, timing e identificação determinam significado causal. |
| ADL + FE com estados defasados é baseline comparativo condicional para o CET. | L190; PDF pp. 2–3; abstract L34 | Requer timestamps, papéis causais, identificação, forma funcional, suporte e condições de estimação. |
| A arquitetura combina diagnóstico geral e aplicação dinâmica específica. | L192–194; PDF p. 3 | O “full payoff” desenvolvido aqui fica no domínio TSCS linear. |

### Não-afirmações

- A identidade algébrica não demonstra viés causal.
- O manuscrito não critica ou substitui a literatura geral de identificação; usa-a como ponto de partida (L182).
- O baseline não é estimador causal universal nem regra para “defasar tudo” (L190).
- A Introduction não promete extensão comprovada para outros estimadores ou estimandos.

### Ambiguidades delimitadas

- “Full payoff” pode soar amplo, mas a frase governante o restringe ao caso TSCS linear (L192).
- “Diretamente estimável” qualifica o deslocamento de projeção, não sua interpretação causal.
- O exemplo inicial ilustra o dilema, mas não classifica definitivamente conflito contemporâneo como confundidor, mediador ou collider.

### Promessa sobre aplicações

A promessa é mostrar como diagnóstico e baseline **interagem** em estudos publicados (L194), não provar viés causal generalizado. A seção de aplicações confirma o escopo: deslocamentos pontuais descritivos, amostra intencional, sem intervalos pareados e com julgamentos causais de timing separados (L646). Os dois estudos detalhados auditam contrastes defasado e forward, não demonstram diretamente o CET contemporâneo central (L650, L736). Nenhum arquivo foi alterado e nenhuma análise foi executada.
