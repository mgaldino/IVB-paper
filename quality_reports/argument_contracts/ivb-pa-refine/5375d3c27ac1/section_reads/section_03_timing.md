## Relatório de leitura — `read_timing`

Hashes do PDF e da fonte conferem com os valores fornecidos. A Seção 3 ocupa as páginas 4–7 e foi conferida no PDF renderizado. Somente leitura: nenhum arquivo foi alterado e nenhuma análise foi executada. Fonte canônica: [ivb_paper_pa.Rmd](/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/ivb_paper_pa.Rmd:208). Artefato consultado: :codex-file-citation{path="/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/ivb_paper_pa.pdf" purpose="source"}.

### Tese

A Seção 3 sustenta que o papel causal de uma covariável variante no tempo é definido por seu relógio substantivo e pelo estimando, não pelo índice calendário. Para o efeito contemporâneo do tratamento (CET), um $Z_t$ mediador pertence ao efeito total dentro do período e condicioná-lo muda o alvo para um efeito direto; um $Z_t$ collider abre uma associação não causal, mas exige outro relógio, no qual o processo de resultado precede a mensuração de $Z_t$. Um $Z_{t-1}$ é apenas candidato a estado predeterminado ou confundidor defasado: sua admissibilidade requer comprovação de que sua janela fecha antes do início relevante de $D_t$, além das condições posteriores de suficiência da história e identificação. Essa lógica é local ao CET e não se transfere automaticamente para efeitos distribuídos, acumulados ou de longo prazo.

### Claims, evidência e escopo

| Claim | Localizador | Evidência textual | Escopo preservado |
|---|---|---|---|
| O CET compara $Y_{it}(d)$ e $Y_{it}(d')$, condicionado à história imediatamente pré-exposição $H^-_{it}$. | Rmd 214–222; PDF pp. 4–5 | Definição formal de $\tau_{\mathrm{CET}}(d,d';h)$. | Tratamentos bem definidos; no modelo linear constante, contraste unitário ou efeito marginal. |
| Para um mediador, o relógio candidato é $H^-_{it}\to D_{it}\to Z_{it}\to Y^+_{it}$. O CET inclui $D\to Z\to Y$, salvo alvo direto explícito. | Rmd 222–238; PDF p. 5 | Definição, cadeia temporal e ressalva explícita. | Relógio de mediador; não é imposto aos demais DAGs. |
| O collider contemporâneo exige outro relógio: $D_t\to Z_t\leftarrow Y_t$, com o processo de $Y_t$ anterior à mensuração de $Z_t$. | Rmd 238; PDF p. 5 | Declaração explícita sobre a ordem intraperíodo. | O subíndice comum indica período, não simultaneidade. |
| Um lag só pode ser chamado pré-tratamento se sua janela fechar antes da primeira exposição relevante. | Rmd 240–275; Tabela 1; PDF p. 5 | Checklist de onset, fim, intensidade e janelas de $D,Z,Y$. | Antecipação, médias anuais e janelas sobrepostas podem invalidar a classificação. |
| Condicionar em $Z_t$ abre o collider atual e pode ativar o caminho herdado via $Z_{t-1}$. | Rmd 277–313; Figura 1; PDF p. 6 | D-separation no DAG exibido. | “Pode ativar”; conclusão condicionada ao grafo mostrado. |
| $Y_{t-1}$ bloqueia o caminho herdado e o caminho dinâmico ordinário exibidos, mas não fecha o collider contemporâneo aberto em $Z_t$. | Rmd 279; PDF p. 6 | Distinção explícita entre três caminhos. | Não afirma suficiência geral de $Y_{t-1}$. |
| No DAG mediador, $Z_{t-1}$ pode bloquear confundimento defasado sem bloquear $D_t\to Z_t\to Y_t$; $Z_t$ bloqueia a mediação. | Rmd 315–350; Figura 2; PDF pp. 6–7 | Comparação gráfica dos conjuntos de ajuste. | $Z_{t-1}$ precisa ser substantivamente pré-tratamento; efeito direto exige hipóteses adicionais de mediação. |
| O mesmo $Z$ pode ter papel dual: confundidor defasado e collider contemporâneo. | Rmd 352–385; Tabela 2; PDF p. 7 | Síntese dos quatro papéis candidatos. | A decisão depende da janela documentada, não de incluir ou excluir sempre a variável. |

### Não-afirmações explícitas

- A cadeia do mediador não é um relógio universal; o texto separa expressamente o relógio do collider (Rmd 238; PDF p. 5).
- “Defasado” não equivale a “pré-tratamento” ou “admissível” (Rmd 250–266, 275, 359–361; PDF pp. 5 e 7).
- $Y_{t-1}$ não resolve o collider contemporâneo aberto por condicionamento em $Z_t$ (Rmd 279; PDF p. 6).
- Condicionar em mediador não estima o CET total: desloca o alvo para um parâmetro direto sob hipóteses adicionais (Rmd 315; PDF p. 6).
- A Seção 3 não chama todo deslocamento de coeficiente de IVB; essa denominação é reservada, na Seção 4, a casos em que DAG, timing, estimando e identificação estabelecem afastamento do CET (Rmd 385–389; PDF pp. 7–8).
- O lag não é suficiente por si: a Seção 4 exige $H_{i,t-1}\subseteq H^-_{it}$, história suficiente, exchangeability, suporte e forma dinâmica adequada (Rmd 457–477; PDF p. 10).
- A admissibilidade é local ao CET. Para efeitos distribuídos, acumulados, regimes ou longo prazo, o manuscrito manda escolher outro alvo e método (Rmd 633–638, 832; PDF pp. 18 e 21).

### Ambiguidades reais

1. $Y^+_{it}$ designa a mensuração terminal no relógio do mediador, enquanto o DAG do collider usa $Y_t$ como processo anterior a $Z_t$. A distinção é enunciada, mas a relação entre esses dois objetos de resultado não é formalizada.
2. As categorias “known”, “plausible” e “ambiguous” são definidas verbalmente; o limiar documental para passar de plausível a conhecido não é operacionalizado (Rmd 275).
3. Para exposição contínua com feedback intraperíodo, o texto reconhece que o alvo deveria ser um contraste entre trajetórias, mas não define esse estimando (Rmd 275).
4. A Seção 3 estabelece o teste temporal do lag; a suficiência do conjunto de ajuste aparece apenas depois. Portanto, “timestamp passes” não encerra a admissibilidade causal.

### Terminologia a preservar

- **CET**: efeito de $D_t$ sobre $Y_t$, condicionado à história pré-exposição.
- **$H^-_{it}$**: informação e estados fixados imediatamente antes do tratamento.
- **Estado predeterminado** e **confundidor defasado**: papéis distintos de $Z_{t-1}$, ambos condicionais ao timestamp.
- **Collider contemporâneo**, **mediador contemporâneo** e **variável de papel dual**: classificações mecanismo-específicas.
- **Efeito total** inclui a via mediada; **efeito direto** surge ao condicionar no mediador, sob hipóteses adicionais.
- **IVB** exige interpretação causal estabelecida; sem ela, o objeto é deslocamento descritivo de especificação.

### Dúvidas para a síntese macro

- A contribuição deve apresentar a Seção 3 como o contrato interpretativo que antecede o diagnóstico, ou como resultado causal autônomo?
- Convém distinguir nominalmente o $Y_t$ intermediário do relógio do collider do $Y^+_t$ terminal do CET?
- A síntese deve explicitar os dois portões do lag: anterioridade temporal e suficiência causal/dinâmica?
- As aplicações devem ser descritas apenas como auditorias de timing e deslocamento? O próprio manuscrito diz que os contrastes defasado e forward não demonstram diretamente o CET central (Rmd 650, 736; PDF pp. 19–20).
