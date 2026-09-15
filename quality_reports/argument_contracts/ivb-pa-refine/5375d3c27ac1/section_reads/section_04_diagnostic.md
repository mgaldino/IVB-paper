## Relatório de leitura fiel — Seção 4

**A Seção 4 separa três objetos: a mudança exata entre coeficientes amostrais, sua incerteza conjunta e as condições sob as quais um coeficiente populacional ADL + FE identifica o CET.** Sua contribuição declarada é organizar a mudança de especificação como diagnóstico interpretável. O texto não apresenta a identidade FWL como descoberta algébrica nem como demonstração automática de viés causal.

Li as linhas 387–502 de [ivb_paper_pa.Rmd](/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/ivb_paper_pa.Rmd:387), conferi o trecho correspondente nas páginas 8–12 do PDF e consultei as derivações diretamente referidas. Os dois SHA256 coincidem integralmente com os fornecidos. Não editei arquivos nem executei análises, testes, bootstrap ou renderização.

### Tese e sequência do argumento

A diferença \(\widehat\Delta_Z=\widehat\beta_L-\widehat\beta_S\) pode ser escrita como \(-\widehat\theta^\star\widehat\pi\), desde que o contraste preserve o sistema de regressões lineares aninhadas. O produto combina a associação parcial entre controle e desfecho no modelo longo com a associação parcial entre tratamento e controle na auxiliar. Esses componentes são estimáveis; sua leitura causal depende de informação adicional.

Com vários controles, existe um deslocamento conjunto entre os dois modelos extremos. Atribuições sequenciais dependem da ordem; comparações retirando um controle do modelo completo são sensibilidades condicionais e não parcelas automaticamente aditivas.

A seção então apresenta uma proposta de inferência que preserva a dependência entre os estimadores e delimita sua implementação empírica. Finalmente, explicita um resultado populacional condicional: sob história suficiente, relógio causal, intercambialidade, suporte e média condicional corretamente especificados, o coeficiente da projeção ADL + FE coincide com o CET homogêneo. Isso não elimina o viés do estimador within em painéis curtos.

### Registro de afirmações

Localizadores “Rmd” referem-se ao manuscrito acima.

| Afirmação | Localizador | Evidência textual/matemática | Escopo |
|---|---|---|---|
| IVB é uma interpretação causal restrita do deslocamento | Rmd 389; PDF p. 8 | O termo fica reservado a casos em que DAG, timing, estimando e identificação estabelecem afastamento de \(\beta_{\mathrm{CET}}\) | Não equivale a qualquer mudança de coeficiente |
| A identidade escalar é exata | Rmd 391–406; Eq. 3 | Modelos curto e longo compartilham \(D,W\); auxiliar estima \(Z\) sobre \(D,W\) | Identidade de regressão, atribuída a FWL |
| O resultado vetorial requer amostra e regressoras comuns | Rmd 408–420; Proposição 1 | Condições expressas de posto completo, OLS sem pesos, mesmas observações e regressoras comuns | Controles conjuntos; sem extrapolação automática a outros estimadores |
| Alocações diferem do deslocamento conjunto | Rmd 416–422 | Incrementos sequenciais telescopam; leave-one-out não precisa somar; Shapley resume ordens | Sensibilidade de projeções, sem decomposição causal |
| A inferência deve preservar a covariância dos coeficientes | Rmd 426–435; PDF p. 9 | \(\operatorname{Var}(\widehat\Delta)=V_L+V_S-2\operatorname{Cov}(L,S)\); sandwich empilhado | Não se justifica tratar modelos aninhados como estimativas independentes |
| O bootstrap proposto reamostra unidades inteiras | Rmd 426 | Curto, longo e auxiliar são reestimados nas mesmas linhas de cada reamostra | Procedimento proposto; validade depende do desenho |
| Aplicações não apresentam ICs para o deslocamento | Rmd 435 | Declaração expressa de resultados pontuais e magnitudes relativas | Não há alegação de inferência aplicada já concluída |
| O coeficiente ADL + FE pode identificar o CET | Rmd 457–477; PDF pp. 10–11 | Média potencial aditiva com inclinação constante, condições causais e razão FWL populacional | Resultado suficiente e condicional, não garantia decorrente do rótulo ADL |
| FE têm capacidade delimitada | Rmd 477; Tabela 3 | Absorvem fatores aditivos invariantes e choques aditivos comuns | Não removem confundimento temporal omitido nem respostas heterogêneas a choques |
| Identificação, estimação e inferência são distintas | Rmd 489–501; PDF p. 12 | Tabela separa condições; parágrafo explica Nickell, dependência e fatores omitidos | GMM não é universalmente superior nem conserta relógio causal inválido |

### O que as derivações efetivamente oferecem

A [derivação multivariada](/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/derivations/multivariate_specification_shift.Rmd:125) contém a prova populacional por residualização e equação normal, uma verificação por substituição e a versão amostral nas linhas 182–211. Exige a mesma amostra inclusive diante de ausências nos controles e declara que a extensão ponderada não é provada ali. Portanto, não cabe dizer que o manuscrito apenas promete uma prova inexistente.

A [derivação de identificação](/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/derivations/adl_cet_identification_conditions.Rmd:63) explicita intercambialidade **condicional também a \(\alpha_i,\tau_t\)**. A prova encadeia consistência, intercambialidade, média observada e ortogonalidade FWL. Distingue essa cadeia do viés within e explicita que pesos sob heterogeneidade podem não ser convexos.

A [nota de incerteza](/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/derivations/specification_shift_uncertainty.Rmd:260) declara que não produz replicações bootstrap, intervalos ou avaliação de cobertura. Limita a implementação a controle escalar, OLS sem pesos, amostra completa comum e agrupamento por uma unidade. Dependência entre unidades, poucos clusters e calibração dos intervalos já são limitações reconhecidas.

### Não-afirmações explícitas

- A fórmula não identifica admissibilidade de controles nem mede, por si, viés causal.
- Não se propõe um estimador novo.
- Defasar tratamento ou covariada não assegura bloqueio causal nem história suficiente.
- Não há resultado reivindicado para controle sintético, synthetic DID ou modelos de fatores.
- O coeficiente populacional identificado não implica estimador within não viesado em \(T\) finito.
- Suporte causal não é substituído pelo posto da projeção.
- A magnitude relativa fica instável com denominador próximo de zero.
- Os procedimentos de incerteza não estabelecem a interpretação causal do deslocamento.

### Ambiguidades reais, sem adjudicação de defeitos

1. **“Moved from the lagged-state set … into the contemporaneous set” (Rmd 451).** A frase pode descrever substituição de \(Z_{t-1}\) por \(Z_t\), enquanto a identidade imediatamente construída corresponde à inclusão de \(Z_t\) preservando \(W\). A seção não explicita nesse ponto se o lag permanece nem a ponte entre uma troca não aninhada e comparações aninhadas. É uma ambiguidade operacional localizada.

2. **Condicionamento da intercambialidade.** A prosa principal (465) menciona apenas \(H^{-}_{it}\); a média potencial inclui FE, e a derivação explicita \(H^{-}_{it},\alpha_i,\tau_t\). O documento de apoio resolve a intenção, mas a abreviação no corpo admite leitura diferente.

3. **Efeito direto.** A frase do corpo (441) afirma que, sendo \(Z\) mediador, o deslocamento reflete passagem do efeito total ao direto. Na Seção 3, linha 315, essa interpretação aparece corretamente condicionada a hipóteses adicionais de mediação. O ponto de leitura é se essa ressalva anterior governa suficientemente a frase condensada; não há base para atribuir ao conjunto do manuscrito uma identificação incondicional do efeito direto.

### Terminologia e perguntas ao macro

**Specification shift** designa contraste de coeficientes; **IVB**, afastamento causalmente estabelecido do CET; **baseline/benchmark**, comparação condicional; **CET**, efeito contemporâneo que inclui vias mediadas no período, salvo alvo direto explicitamente definido; **exchangeability**, restrição causal de médias potenciais, distinta da consequência de média zero do resíduo.

Para consolidar o argumento: qual comparação exata operacionaliza “mover” o controle? A proposta inferencial integra a contribuição atual como método ainda não calibrado, ou como componente aplicado futuro? Convém carregar para o corpo os qualificadores já existentes sobre mediação e condicionamento em FE? Essas perguntas delimitam possíveis ajustes de apresentação; não constituem revisão do paper inteiro nem novos erros demonstrados.
