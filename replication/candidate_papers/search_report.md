# Busca de Papers Aplicados com ADL(p,q) para Aplicação Empírica do IVB

**Data de acesso das fontes:** 2026-02-27
**Objetivo:** Encontrar papers aplicados com modelo ADL(p,q), causal, em journals top de CP/RI, publicados 2020+, com dados no Dataverse.

---

## Tabela de Candidatos

### 1. Claassen (2020) — AJPS [CONFIRMADO ADL]

| Campo | Detalhes |
|-------|----------|
| **Título** | Does Public Support Help Democracy Survive? |
| **Autores** | Christopher Claassen |
| **Ano** | 2020 |
| **Journal** | American Journal of Political Science, 64(1), 118-134 |
| **DOI/Link** | https://onlinelibrary.wiley.com/doi/abs/10.1111/ajps.12452 |
| **Pergunta causal** | O apoio público à democracia ajuda a democracia a sobreviver? |
| **Especificação ADL** | **ADL(2,1)**: `d_it = φ₁d_{it-1} + φ₂d_{it-2} + βs_{it-1} + Z'_{it-1}γ + μ_i + ε_it` |
| **p, q** | p=2 (dois lags de democracia), treatment (support) entra em t-1 |
| **Identificação causal** | Pooled OLS, dynamic FE, system GMM (Blundell-Bond) |
| **Dataverse** | https://doi.org/10.7910/DVN/HWLW0J |
| **PDF** | Baixado de https://www.chrisclaassen.com/docs/Claassen_democracy_public_support.pdf |
| **Replicabilidade** | Dados + código disponíveis. Erratum publicado em 2024 (resultados similares). País-ano, 135 países, até 29 anos. 5 controles: log GDP per capita, crescimento GDP, receita de recursos naturais, democracia regional, proporção muçulmana. |

**Avaliação:** Candidato mais forte. Especificação ADL explícita, equações no paper, DAGs causais (Figure 2), OLS+FE+GMM. Ideal para demonstrar IVB — os controles Z poderiam plausivelmente ser colisores.

---

### 2. Leipziger (2024) — AJPS [A VERIFICAR]

| Campo | Detalhes |
|-------|----------|
| **Título** | Does Democracy Reduce Ethnic Inequality? |
| **Autores** | Lasse Egendal Leipziger |
| **Ano** | 2024 |
| **Journal** | American Journal of Political Science, 68(2) |
| **DOI/Link** | https://onlinelibrary.wiley.com/doi/10.1111/ajps.12812 |
| **Pergunta causal** | A democratização reduz a desigualdade étnica? |
| **Especificação ADL** | Panel FE com todas as variáveis RHS defasadas em 1 ano. **Precisa verificar se há LDV.** Também usa IV e event studies. |
| **p, q** | A confirmar |
| **Identificação causal** | FE, IV, event studies |
| **Dataverse** | https://doi.org/10.7910/DVN/4UOQUR |
| **PDF** | Não baixado (paywall Wiley). Open access? Verificar. |
| **Replicabilidade** | Dados no Dataverse. |

**Avaliação:** Bom candidato se o modelo principal incluir LDV. O paper usa FE com variáveis defasadas em 1 ano. Se houver LDV = ADL(1,1). Precisa verificar no PDF/código.

---

### 3. Blair, Di Salvatore & Smidt (2023) — APSR [A VERIFICAR]

| Campo | Detalhes |
|-------|----------|
| **Título** | UN Peacekeeping and Democratization in Conflict-Affected Countries |
| **Autores** | Robert A. Blair, Jessica Di Salvatore, Hannah M. Smidt |
| **Ano** | 2023 |
| **Journal** | American Political Science Review, 117(4), 1308-1326 |
| **DOI/Link** | https://www.cambridge.org/core/journals/american-political-science-review/article/7E5374C9417523612CF2626935FAB95D |
| **Pergunta causal** | Peacekeeping da ONU promove democratização em países afetados por conflito? |
| **Especificação ADL** | Panel FE/IV. IVs defasadas 2 períodos. **LDV reportado nos apêndices como robustez.** |
| **p, q** | A confirmar (provável ADL(1,0) ou similar nos apêndices) |
| **Identificação causal** | FE + IV (instrumentos para presença de peacekeepers) |
| **Dataverse** | https://doi.org/10.7910/DVN/UOYDHN |
| **PDF** | Tentativa de download do Warwick repository falhou (HTML). Acessível via Cambridge Core. |
| **Replicabilidade** | Dados e código no APSR Dataverse. Combina 3 datasets originais sobre mandatos, pessoal e atividades da ONU. |

**Avaliação:** Publicação forte em journal top. O modelo principal usa FE+IV; LDV aparece como robustez. Útil se a especificação com LDV for claramente documentada.

---

### 4. Albers, Jerven & Suesse (2023) — IO [A VERIFICAR]

| Campo | Detalhes |
|-------|----------|
| **Título** | The Fiscal State in Africa: Evidence from a Century of Growth |
| **Autores** | Thilo N.H. Albers, Morten Jerven, Marvin Suesse |
| **Ano** | 2023 |
| **Journal** | International Organization, 77(1), 65-101 |
| **DOI/Link** | https://www.cambridge.org/core/journals/international-organization/article/347B8C8B89485D4687604C8F1C97F89B |
| **Pergunta causal** | Como fatores de state-building (democracia, guerra, crédito externo, ajuda) afetam a capacidade fiscal na África? |
| **Especificação ADL** | Panel data 1900-2015, 5-year averages, 46 polities africanas. IVs defasadas 1 período. **Precisa verificar se há LDV.** |
| **p, q** | A confirmar |
| **Identificação causal** | OLS com FE, variáveis defasadas, SEs clusterizados por polity |
| **Dataverse** | https://doi.org/10.7910/DVN/TT0SJZ |
| **PDF** | Não baixado (paywall Cambridge). |
| **Replicabilidade** | Dataset novo + código no IO Dataverse. |

**Avaliação:** Paper aplicado forte em IO. Se incluir LDV no modelo principal, seria ADL. A estrutura de 5-year averages com IVs defasadas sugere modelo dinâmico. Verificar.

---

### 5. Mross, Fiedler & Grävingholt (2022) — ISQ [A VERIFICAR]

| Campo | Detalhes |
|-------|----------|
| **Título** | Identifying Pathways to Peace: How International Support Can Help Prevent Conflict Recurrence |
| **Autores** | Karina Mross, Charlotte Fiedler, Jörn Grävingholt |
| **Ano** | 2022 |
| **Journal** | International Studies Quarterly, 66(1), sqab091 |
| **DOI/Link** | https://academic.oup.com/isq/article/66/1/sqab091/6454667 |
| **Pergunta causal** | Como diferentes áreas de apoio internacional (peacekeeping, governança, desenvolvimento, etc.) previnem recorrência de conflito? |
| **Especificação ADL** | Panel data conflict-country-year, 1989-2019. **Provável LDV** (conflito é altamente persistente). |
| **p, q** | A confirmar |
| **Identificação causal** | Panel regression com controles e variáveis defasadas |
| **Dataverse** | ISQ Dataverse (Harvard) |
| **PDF** | Não baixado. Open access via Oxford Academic? |
| **Replicabilidade** | Dados no ISQ Dataverse. |

**Avaliação:** Tema excelente para IVB (múltiplos controles que podem ser colisores). Precisa verificar especificação ADL no paper.

---

### 6. Acemoglu, Naidu, Robinson & Restrepo (2019) — JPE [CONFIRMADO ADL, fora do escopo temporal]

| Campo | Detalhes |
|-------|----------|
| **Título** | Democracy Does Cause Growth |
| **Autores** | Daron Acemoglu, Suresh Naidu, Pascual Restrepo, James A. Robinson |
| **Ano** | 2019 |
| **Journal** | Journal of Political Economy, 127(1), 47-100 |
| **DOI/Link** | https://www.journals.uchicago.edu/doi/abs/10.1086/700936 |
| **Pergunta causal** | Democracia causa crescimento econômico? |
| **Especificação ADL** | **ADL(4,1)**: 4 lags de log GDP per capita + democracia defasada + country/year FE |
| **p, q** | p=4, q=1 (também estimado com GMM) |
| **Identificação causal** | Dynamic panel FE, system GMM, IV |
| **Dataverse** | Suplementar em https://www.journals.uchicago.edu/doi/suppl/10.1086/700936 + GitHub replications |
| **PDF** | Disponível em múltiplas fontes (NBER, MIT, etc.) |
| **Replicabilidade** | Dados e código disponíveis. Muito replicado. |

**Avaliação:** O paper canônico de ADL em CP. Fora do escopo temporal (2019, não 2020+) e fora do escopo de journal (JPE, não CP/RI journal stricto sensu). Mas é a referência ideal se for aceito como exceção.

---

### 7. Doucette (2024) — APSR [DERIVADO DE ADL]

| Campo | Detalhes |
|-------|----------|
| **Título** | What Can We Learn about the Effects of Democracy Using Cross-National Data? |
| **Autores** | Doucette |
| **Ano** | 2024 |
| **Journal** | American Political Science Review, 119(33), 1549-1558 |
| **DOI/Link** | https://www.cambridge.org/core/journals/american-political-science-review/article/A953711646FCCD3D4AEE59DE3921CB37 |
| **Pergunta causal** | Análise de poder estatístico para efeitos de democracia usando dados cross-nacional com a especificação ADL de Acemoglu et al. |
| **Especificação ADL** | Usa diretamente a especificação ADL(4,1) de Acemoglu et al. (2019) |
| **p, q** | p=4, q=1 (herda de Acemoglu et al.) |
| **Identificação causal** | Dynamic panel (mesmo framework de Acemoglu et al.) |
| **Dataverse** | https://doi.org/10.7910/DVN/CLGI63 |
| **PDF** | Via Cambridge Core |
| **Replicabilidade** | Dados no APSR Dataverse. |

**Avaliação:** Parcialmente metodológico (análise de poder), mas usa a especificação ADL aplicada. Útil como ponte entre Acemoglu et al. e um contexto APSR recente.

---

## Arquivos PDF baixados

| Arquivo | Caminho local | Status |
|---------|---------------|--------|
| Claassen (2020) AJPS | `candidate_papers/Claassen_2020_AJPS_democracy_support.pdf` | Baixado (350 KB, PDF válido) |
| Albers et al. (2023) IO | — | Paywall (Cambridge Core) |
| Blair et al. (2023) APSR | — | Paywall (Warwick redirect) |
| Leipziger (2024) AJPS | — | Paywall (Wiley) |
| Mross et al. (2022) ISQ | — | Não tentado |
| Acemoglu et al. (2019) JPE | — | Disponível via NBER/MIT (não baixado) |
| Doucette (2024) APSR | — | Paywall (Cambridge Core) |

---

## Recomendação de prioridade para o IVB paper

1. **Claassen (2020) AJPS** — melhor candidato. ADL(2,1) explícito, OLS + FE + GMM, DAGs causais, controles que podem ser colisores (GDP, crescimento, recursos naturais, democracia regional). Dataverse completo. Replicação direta.

2. **Acemoglu et al. (2019) JPE** — canônico mas fora do escopo estrito (2019, JPE). Usar como exemplo complementar ou se a restrição de data/journal for relaxada.

3. **Leipziger (2024) AJPS** — verificar se inclui LDV. Se sim, ADL com FE é modelo simples e replicável.

4. **Blair et al. (2023) APSR** — LDV como robustez. Se a especificação com LDV for documentada, pode ser útil.

5. **Albers et al. (2023) IO** — verificar LDV. Panel de longo prazo com 5-year averages, pode ser bom exemplo para TSCS.

---

## Próximos passos

- [ ] Baixar PDFs restantes (Leipziger, Blair, Albers, Mross)
- [ ] Verificar especificação ADL exata nos PDFs/código (especialmente Leipziger e Albers)
- [ ] Baixar pacotes de replicação do Dataverse para os candidatos confirmados
- [ ] Selecionar 1-2 papers para aplicação empírica real do IVB
- [ ] Implementar receita de 3 passos do IVB nos dados reais
