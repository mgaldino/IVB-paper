# Leitura fiel da Seção 6 — Applications

**Leitor:** `read_applications`  
**Artefatos verificados:** Rmd SHA-256 `12493a…af7b5e`; PDF SHA-256 `5375d3…107d447c`. A Seção 6 está nas pp. 19–21 do PDF; as pp. 17–18 fecham a Seção 5 e fixam a distinção entre diagnóstico descritivo e linha de base causal condicional. Nenhum arquivo foi alterado e nenhuma análise foi executada.

## Tese da seção

As aplicações cumprem duas funções: demonstrar que a decomposição produz diagnósticos empíricos de mudança entre especificações e mostrar que a interpretação dessa mudança exige, separadamente, um relógio causal, um DAG e hipóteses de identificação. Os resultados apresentados são deslocamentos pontuais em uma amostra intencional. A seção não os trata como estimativas de viés causal nem como evidência sobre sua prevalência na literatura de dados em série temporal e corte transversal (TSCS).

O universo declarado contém **14 controles candidatos selecionados teoricamente em seis estudos** (`ivb_paper_pa.Rmd:141–174, 646`). A exposição detalhada da Seção 6 cobre apenas **dois desses seis estudos**, Leipziger e Rogowski. Seus candidatos destacados são GDP per capita em cada estudo. As tabelas exibem cinco linhas de controle no total: uma para Leipziger e quatro para Rogowski. Em Rogowski, população, urbanização e Polity2 são comparações adicionais da tabela; elas não pertencem à seleção de 14 definida em `collider_candidates`, que inclui apenas GDP para Rogowski.

| Claim | Localizador | Evidência | Escopo/hedge |
|---|---|---|---|
| As aplicações operacionalizam a decomposição e exigem julgamento causal separado. | Rmd 646; PDF p.19 | 14 candidatos, seis estudos, coeficientes de endpoint e comparações de escala. | Amostra intencional; resultados descritivos; sem estimativa de prevalência ou magnitude de viés causal. |
| Leipziger estima um contraste defasado, $D_{t-1}\to Y_t$, equivalente a $D_s\to Y_{s+1}$. | Rmd 650; PDF p.19 | Democracia e GDP entram com uma defasagem anual em relação ao outcome. | Auditoria de contraste defasado; não demonstração direta do CET contemporâneo $D_t\to Y_t$. |
| O timing de GDP em Leipziger é ambíguo para o tratamento. | Rmd 650, 696 | GDP é pré-outcome, mas democracia e GDP compartilham o mesmo índice anual; faltam datas intranuais. | GDP pode ser confounder, variável responsiva ao tratamento ou variável de papel duplo. |
| Em Leipziger, incluir GDP move o coeficiente de −0,0407 para −0,0352; $\widehat\Delta_Z=0,0056$. | Tabela 7; Rmd 698–732; PDF p.20 | $\hat\theta^\star=-0,0497$, $\hat\pi=0,1123$; identidade $-\hat\theta^\star\hat\pi$. | Magnitude de 15,9%, aproximadamente 16%, do coeficiente do modelo longo; não estabelece atenuação nem deconfounding. |
| Rogowski estima um contraste prospectivo entre estoque postal acumulado $D_s$ e crescimento $Y_{s+1}$. | Rmd 736; PDF pp.20–21 | Painel em passos quinquenais; outcome avançado um período; tratamento e GDP aparecem na linha-base. | Auditoria de contraste prospectivo; não demonstração direta do CET contemporâneo. |
| GDP em Rogowski produz o maior deslocamento exibido: 0,0115. | Tabela 8; Rmd 799–822; PDF p.21 | Coeficiente curto 0,0083, longo 0,0198; deslocamento equivalente a 58,0% do endpoint longo. | Aritmética descritiva: GDP pode ser confounder, estado legado responsivo ao tratamento, mediator ou dual-role. |
| O diagnóstico não decide se GDP deve ser retirado. | Rmd 736, 822 | O estoque postal acumulado pode já ter afetado GDP antes da janela do outcome. | A interpretação permanece aberta até haver DAG e evidência sobre janelas de exposição e mensuração. |

## Não-afirmações explícitas

A seção afirma explicitamente que: não há intervalos de confiança pareados para $\Delta_Z$, e nenhum é imputado; as aplicações não estimam a prevalência ou magnitude do viés causal em TSCS; os dois casos não demonstram diretamente o CET central; o deslocamento de Leipziger não estabelece attenuation bias nem deconfounding; o grande deslocamento de Rogowski não mostra que retirar GDP melhora a identificação; e a conclusão prática não é “drop GDP”.

Os ratios 0,48 e 2,11 usam $|\widehat\Delta_Z|/\widehat{\mathrm{SE}}(\hat\beta_{\text{long}})$. Essa SE pertence a **um endpoint**, não à diferença pareada. Portanto, os ratios são apenas comparações de escala: não são estatísticas de teste, não são intervalos para $\Delta_Z$ e não incorporam a covariância entre os coeficientes curto e longo. A inferência adequada exigiria reestimação pareada ou a variância da diferença descrita em Rmd 424–438.

## Ambiguidades reais

1. Em Leipziger, faltam datas intranuais de transição democrática, janela de referência do GDP e janela de mensuração do outcome. O rótulo “lagged” resolve apenas a precedência em relação ao outcome, não em relação ao tratamento.
2. Em Rogowski, “lagged GDP per capita” em Rmd 822 parece significar GDP anterior ao outcome avançado; GDP está na mesma linha-base do estoque postal acumulado e não é demonstravelmente anterior a esse tratamento.
3. “Largest such scale comparison among the published applications” não explicita na própria frase se o universo comparativo são os 14 candidatos selecionados ou apenas as aplicações detalhadas.
4. A Tabela 8 mistura o candidato teoricamente selecionado para Rogowski, GDP, com três controles adicionais. O agente macro deve preservar essa diferença ao descrever o universo 14/6.

## Terminologia a preservar

`Specification shift` é $\widehat\Delta_Z=\hat\beta_{\text{long}}-\hat\beta_{\text{short}}=-\hat\theta^\star\hat\pi$. `Included variable bias` deve ficar reservado aos casos em que DAG, timing, estimando e identificação mostram movimento para longe do CET. Também devem permanecer distintos: CET contemporâneo; contraste defasado; contraste prospectivo; endpoint coefficient; endpoint-SE scale comparison; paired confidence interval; confounder; treatment-responsive state/mediator; dual-role variable; diagnóstico; e linha de base condicional.

## Perguntas ao agente macro

- O contrato registrará que a evidência detalhada cobre dois estudos, enquanto o universo declarado cobre 14 candidatos em seis estudos?
- O superlativo 2,11 será atribuído explicitamente ao universo dos outputs selecionados ou mantido como ambiguidade?
- A síntese preservará que as aplicações validam a operacionalidade descritiva do diagnóstico, sem funcionar como validação causal da linha de base CET?
- Como o contrato nomeará o GDP de Rogowski para evitar que “lagged” sugira precedência demonstrada em relação ao estoque postal acumulado?
