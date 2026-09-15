## Leitura fiel da Seção 5 — `read_simulations`

**Tese da seção.** A Seção 5 apresenta a principal implicação aplicada do artigo: quando o alvo é o **efeito contemporâneo do tratamento (CET)**, uma especificação dinâmica ADL + efeitos fixos, com estados defasados substantivamente justificados, pode funcionar como **baseline condicional de comparação**. Esse baseline não substitui o diagnóstico de deslocamento de especificação \(\widehat{\Delta}_Z\): ele fornece o ponto de comparação, enquanto \(\widehat{\Delta}_Z\) mede a mudança no coeficiente. A interpretação causal exige o relógio causal, o DAG e as condições de identificação e estimação da Tabela 3.

| Claim | Localizador | Evidência apresentada | Escopo/hedge |
|---|---|---|---|
| No DGP de dupla função, \(Z_{t-1}\) é confounder e \(Z_t\) é collider contemporâneo; \(Y_{t-1}\) bloqueia dois caminhos defasados exibidos. | Rmd 509–511; Fig. 3 | Argumento de d-separation no DAG. | Vale para o grafo exibido; não fecha o collider contemporâneo se \(Z_t\) for condicionado, nem exclui caminhos omitidos ou viés em \(T\) finito. |
| A especificação dinâmica com \(Y_{t-1}\), \(Z_{t-1}\) e FE tem viés menor no DGP principal. | Rmd 551–559; Fig. 4, PDF pp. 13–14 | Alvo \(\beta_{\mathrm{CET}}=1\); \(N=100,T=30\), burn-in 100, 500 replicações. Viés de ADL+FE+\(Z_{t-1}\): 0,008–0,010; TWFE+\(Z_{t-1}\): 0,237–0,271; TWFE curto chega a 0,716. | DGP linear e homogêneo; subconjunto fixa \(\sigma_{\alpha_Z}=0{,}5\). Intervalos são incerteza Monte Carlo da média do viés, não ICs do estimador. |
| Os quatro modelos exibidos na Fig. 4 são TWFE curto, TWFE+\(Z_{t-1}\), ADL+FE e ADL+FE+\(Z_{t-1}\). | Rmd 551; PDF 837–842 | Comparações de viés e RMSE ao longo de \(\rho_Z\). | Nenhum dos quatro condiciona em \(Z_t\); a figura sustenta o papel do estado defasado e da dinâmica, não estima diretamente o dano de incluir o collider contemporâneo. |
| O viés em \(T\) finito pode ser distinguido do deslocamento provocado por \(Z_{t-1}\). | Rmd 583–589; Fig. 5 | Grade principal: 54 células por estimador, 500 replicações; FE-ADL within e split-panel jackknife. \(|\text{viés}|\geq|\mathrm{mean}(\Delta_Z)|\) em 0/54 e 6/54 células; máximo \(|\text{viés}|=0{,}0454\), máximo \(|\Delta_Z|=0{,}0381\), cobertura mínima 0,700. | Cobertura é do IC do estimador **long** para \(\beta_{\mathrm{CET}}\), não de \(\Delta_Z\). Não produz cutoff universal de \(T\) nem demonstra robustez causal. Arellano–Bond e stress grid ficam no relatório/apêndice. |
| A persistência de \(Y\) é necessária para o mecanismo “firewall” exibido. | Rmd 591–595; Tabela 5 | Com \(\rho_Y=0\), o viés TWFE+\(Z_{t-1}\) é aproximadamente zero; com \(\rho_Y>0\), ADL+FE+\(Z_{t-1}\) reduz fortemente o viés. | O contraste não separa quanto da melhora vem de cada caminho bloqueado. \(Y_{t-1}\) não é declarado suficiente em geral. |
| Condicionar no mediador contemporâneo desloca o coeficiente para o efeito direto. | Rmd 597–627; Tabela 6 | Mediador puro: alvo total 1,20, direto 1; ADL sem \(Z\) ≈1,20, ADL+\(Z_t\) ≈1,00, ADL+\(Z_{t-1}\) ≈1,20. Mediador+confounder: alvos 1,03 e 1; \(Z_{t-1}\) recupera ≈1,03. | Resultados específicos aos DGPs. No caso com confounding, a leitura depende da estrutura conhecida, não do rótulo da especificação. TWFE estático não é o comparador primário. |
| O baseline só é utilizável por um workflow condicional. | Rmd 629–642 | Definir CET e janelas; avaliar história, exchangeability, dinâmica, suporte, \(T\) e interferência; usar lags necessários; comparar com \(Z_t\); reportar \(\widehat{\Delta}_Z\); manter linguagem descritiva quando a identificação não estiver estabelecida. | Alvos distribuídos, cumulativos, de longo prazo ou de regime requerem outro estimando e método. |
| Simulações adicionais delimitam o baseline. | Rmd 640–642; PDF pp. 17–18 | Não linearidades testadas: viés absoluto de ADL(all) ≤0,4% de \(\beta\) nas células estáveis. Confounding contemporâneo não observado: viés de 8%–53%; oracle <0,3%. | Não cobre não linearidades ou ordens de lag não testadas; o baseline não resolve confounding contemporâneo não observado. |

### Natureza das comparações

O diagnóstico algébrico do artigo é exato para **modelos lineares aninhados**, com mesmas observações e regressoras comuns. Na evidência da Seção 5:

- Figura 4: cada par “short/long” é aninhado pela adição de \(Z_{t-1}\); TWFE versus ADL também acrescenta \(Y_{t-1}\).
- Figura 5: short \(D+Y_{t-1}\) versus long \(D+Y_{t-1}+Z_{t-1}\), dentro de cada estimador, é aninhado.
- Tabela 6: ADL sem \(Z\) é o tronco comum; adicionar \(Z_t\) ou \(Z_{t-1}\) gera dois contrastes aninhados distintos. A comparação direta \(Z_t\) versus \(Z_{t-1}\) é uma **substituição entre especificações não aninhadas**.

### Não-afirmações

A seção não afirma que ADL+FE seja estimador causal universal; que “defasar controles” os torne automaticamente admissíveis; que TWFE estático seja referência causal; que as simulações validem DID, event study ou efeitos de regime; que exista cutoff aceitável universal de \(T\); que FE removam confounding contemporâneo não observado; que os intervalos das Figuras 4/Tabela 5 sejam cobertura amostral; ou que \(\widehat{\Delta}_Z\) seja viés causal sem identificação.

### Ambiguidades reais e terminologia

1. A abertura promete comparar especificações dinâmicas que diferem quanto a \(Z_t\), mas a Fig. 4 exibe inclusão/omissão de \(Z_{t-1}\), sem especificação com \(Z_t\).
2. O workflow não explicita se a especificação com \(Z_t\) **retém** \(Z_{t-1}\) ou o substitui; isso determina se \(\widehat{\Delta}_Z\) é aninhado.
3. “ADL+FE” não designa a mesma RHS em todos os artefatos: Figuras 4–5 usam \(D_t+Y_{t-1}\) como short, enquanto a Tabela 6 usa \(D_t+D_{t-1}+Y_{t-1}\). A equação geral do benchmark também contém \(D_{t-1}\).
4. Preservar: **CET**, **total CET**, **direct effect**, **conditional comparison baseline**, **specification shift**, **IVB**, **Monte Carlo uncertainty interval** e **empirical coverage**.

### Perguntas ao macro

- Qual contraste será declarado operacional: adicionar \(Z_t\) mantendo a história defasada, ou substituir \(Z_{t-1}\) por \(Z_t\)?
- Convém explicitar as RHS de cada “ADL+FE” para impedir que o mesmo rótulo oculte ordens de lag diferentes?
- A síntese macro distinguirá claramente que a evidência de dupla função testa o firewall defasado, enquanto a evidência direta de sobrecontrole vem da Tabela 6?
- O papel das simulações ficará subordinado ao claim central do diagnóstico de deslocamento, como a própria seção estabelece?

Inspeção somente; nenhuma simulação foi executada e nenhum arquivo foi alterado.

<oai-mem-citation>
<citation_entries>
MEMORY.md:1483-1485|note=[used to preserve the read only phase boundary and keep the estimand explicit]
</citation_entries>
<rollout_ids>
</rollout_ids>
</oai-mem-citation>
