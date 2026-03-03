# Plano: Reestruturação do Paper IVB (ivb_paper_psrm.Rmd)

**Status**: DRAFT
**Data**: 2026-02-28

## Contexto

O paper atual tem a teoria completa mas falta demonstração empírica. As simulações de Monte Carlo são tautológicas (validam uma identidade algébrica). A aplicação (civil war simulada) é circular. Dois pareceristas concordaram unanimemente em R&R Major com as mesmas prioridades. O usuário pediu ajustes específicos.

## Objetivo

Reestruturar o paper incorporando: (1) duas replicações empíricas reais (Leipziger + Rogowski), (2) seção sobre quando IVB importa (simulação v4 mecanismos A+B), (3) remoção completa das simulações tautológicas, (4) expansão sobre Nickell bias, (5) retomada do conceito foreign collider bias, (6) clareza sobre identidade algébrica vs interpretação causal, (7) referências sugeridas.

## Nova estrutura do paper

```
1. Introduction (EDITAR — motivação empírica + antecipar resultados das replicações)
2. The Control Variable Problem (MANTER — Sections 2.1-2.4 como estão)
3. DAGs and Collider Bias (EDITAR — expandir foreign collider bias)
4. The Included Variable Bias Formula (EDITAR — expandir Nickell bias, fortalecer caveats)
5. When Does IVB Matter in Panel Data? (NOVA — v4 mecanismos A+B)
6. Empirical Applications (NOVA — Leipziger + Rogowski)
7. Conclusion (EDITAR — so what empírico)
Appendix: derivações completas (MANTER as que já existem)
```

## Mudanças detalhadas

### 1. REMOVER: Monte Carlo section (linhas 524-800)
- Remover integralmente a Section 5 "Monte Carlo Validation"
- Inclui 3 DGPs, 3 code chunks de simulação, scatter plots, tabela de sumário
- Não mover para apêndice — remover completamente

### 2. REMOVER: Application civil war (linhas 801-847)
- Remover a Section 6 "Application: Political Change and Civil War"
- O DGP de civil war permanece como ilustração na Section 3 (DAGs), mas sai como "aplicação"

### 3. NOVA SEÇÃO 5: "When Does IVB Matter in Panel Data?"
**Fonte**: sim_ivb_twfe_v4_report.Rmd + sim_ivb_twfe_v4.R

Conteúdo:
- Motivação: a fórmula diz *quanto* é o IVB, mas quando devemos esperar que ele seja grande?
- **Mecanismo A** (Between/within D→Z): Formalizar como proposição
  - DGP: Z_it = gamma_D^btw * mu_i^D + gamma_D^wth * (D_it - mu_i^D) + gamma_Y * Y_it + FE + nu
  - Resultado: após TWFE, pi = gamma_D^wth + gamma_Y * beta (gamma_D^btw absorvido)
  - Implicação: se D causa Z primariamente em níveis (cross-sectional), IVB é pequeno
  - Incluir 1 figura: heatmap A (horizontal bands) ou line plot flat
- **Mecanismo B** (Between/within Y→Z): Análogo
  - DGP: Z_it = gamma_D * D_it + gamma_Y^btw * bar(Y_i) + gamma_Y^wth * (Y_it - bar(Y_i)) + FE + nu
  - Resultado: após TWFE, theta* depende apenas de gamma_Y^wth
  - Incluir 1 figura: heatmap B
- **Mecanismos C e D** (apenas discussão breve, sem figuras):
  - C: Tratamento binário com poucos switchers → SE grande → IVB/SE pequeno
  - D: Erro de medida em Z → atenuação de theta* → IVB menor
- Parágrafo síntese: em aplicações típicas de CP (TWFE com tratamento binário slow-moving, controles medidos com erro, covariação D-Z primariamente cross-sectional), todos os 4 mecanismos operam simultaneamente, explicando por que IVBs empíricos são tipicamente modestos

Figuras: incluir plots v4 existentes (plots/v4_heatmap_A_btw_wth.png, plots/v4_heatmap_B_btw_wth.png). Referenciá-los com knitr::include_graphics().

### 4. NOVA SEÇÃO 6: "Empirical Applications"

#### 6.1 Leipziger (2024) — Democracy and Ethnic Inequality
**Fonte**: unified_ivb_report.Rmd linhas 237-454

Conteúdo:
- Especificação: TWFE, tratamento = democratização binária, outcome = desigualdade étnica
- Replicação breve (tabela de comparação publicado vs replicado)
- Avaliação de plausibilidade de colisor via DAG + revisão de literatura:
  - GDP p.c.: forte (Grundler & Link 2024 com IV, Acemoglu et al. 2019)
  - Civil war: forte na teoria (Cederman et al. 2013), IVB empírico negligível
  - Oil income, ethnic frac.: não são colisores
- Decomposição IVB (tabela): GDP p.c. como collider principal
  - IVB ≈ +0.006, ~16% de atenuação do efeito de democracia
  - Direção consistente: theta* < 0 (riqueza reduz desigualdade), pi > 0 (democracia aumenta renda)
- Interpretação: mesmo um único controle retido por razões válidas pode introduzir IVB mensurável
- Conexão com foreign collider bias: o pesquisador precisa consultar a literatura sobre os determinantes de GDP (não apenas a literatura sobre desigualdade étnica)

**Dados**: replication/candidate_papers/leipziger_2024/Country-level_dataset.tab
**Código**: adaptar de unified_ivb_report.Rmd (chunks leipziger-*)
**Função**: source("replication/ivb_utils.R") para compute_ivb_multi()

#### 6.2 Rogowski et al. (2022) — Postal Infrastructure and Growth
**Fonte**: unified_ivb_report.Rmd linhas 832-939

Conteúdo:
- Especificação: TWFE, tratamento = log post offices, outcome = GDP growth
- Replicação breve
- Avaliação de plausibilidade de colisor:
  - GDP p.c.: forte (convergência condicional + mecanismo do paper D→Z)
  - Outros controles: IVBs pequenos
- Decomposição IVB (tabela): GDP p.c. domina com IVB de ~58% do efeito tratamento
  - theta < 0 (convergência: GDP alto → growth baixo)
  - pi > 0 (post offices → GDP alto)
  - IVB > 0: incluir GDP p.c. *infla* o efeito estimado
- **Caso contrastante**: ilustra que IVB grande NÃO implica automaticamente viés de colisor
  - GDP p.c. é simultaneamente confundidor (convergência) e potencial colisor
  - A interpretação causal depende do DAG, não da magnitude do IVB
  - Conecta diretamente com a Section 4.7 (Interpretation Caveats)

**Dados**: replication/candidate_papers/post_office_2022/country_panel.tab

### 5. EDITAR: Introduction (linhas 53-74)
- Adicionar motivação empírica: "We apply the formula to six published studies..." → antecipar que IVBs são tipicamente modestos mas podem chegar a 58%
- Atualizar resumo da estrutura do paper para refletir nova organização
- Mencionar que o paper também investiga as condições estruturais que determinam a magnitude do IVB

### 6. EDITAR: Section 3 — Expandir "Foreign Collider Bias" (linhas 199-247)
- Expandir de 2 parágrafos para 3-4
- Adicionar: o conceito é relevante porque heurísticas padrão instruem o pesquisador a revisar a literatura sobre o outcome e o tratamento, mas NÃO sobre os determinantes do controle. O pesquisador precisa consultar literaturas "estrangeiras" (e.g., a literatura sobre determinantes de GDP quando o controle é GDP)
- Antecipar que as aplicações empíricas (Leipziger, Rogowski) ilustram este fenômeno
- Conectar explicitamente com as replicações: Leipziger incluiu GDP p.c. como controle para desigualdade étnica sem consultar a literatura sobre democracia→crescimento

### 7. EDITAR: Section 4 — Fortalecer caveats e expandir Nickell bias

#### 4.7 Interpretation Caveats (linhas 515-522)
- Fortalecer a linguagem: a identidade algébrica IVB = -theta* × pi NÃO é automaticamente "viés de colisor"
- A interpretação causal requer que o pesquisador tenha estabelecido, via DAG ou raciocínio substantivo, que Z é um colisor
- Se Z é confundidor: a mesma decomposição dá o OVB no modelo curto, e o modelo longo é o correto
- Se Z é mediador: nenhuma das duas especificações recupera o estimando causal sem assumptions adicionais
- Adicionar frase: "The formula quantifies the *arithmetic* difference between two nested specifications; only the DAG determines which specification is causally correct."
- Referência a Acharya, Blackwell & Sen (2016) sobre mediadores vs colisores

#### 4.5 Nickell bias — EXPANDIR (linha 428, atualmente 1 parágrafo)
Expandir para 3-4 parágrafos cobrindo:
- O que é Nickell bias: em painéis com FE e T pequeno, o LDV demeanado correlaciona mecanicamente com o erro demeanado. O viés é O(1/T).
- Como interage com IVB: a identidade IVB continua valendo (é algébrica), MAS os componentes theta* e pi já estão contaminados pelo Nickell bias. Portanto, o IVB diagnostica o viés de colisor *dentro do framework OLS/FE como estimado*, não dentro de um framework livre de Nickell bias.
- Implicação prática: em painéis com T grande (T > 20-30), o Nickell bias é pequeno e o IVB diagnóstico é confiável. Em painéis com T pequeno (T < 10), pesquisadores devem considerar GMM (Arellano-Bond) ou estimadores de viés corrigido antes de interpretar o IVB causalmente.
- Referências: Nickell (1981), Arellano & Bond (1991), Judson & Owen (1999) sobre quando T é "grande o suficiente"

### 8. EDITAR: Practical Recipe — Adicionar "Passo 0" (linhas 490-513)
- Antes dos 3 passos atuais, adicionar:
  - **Step 0: Establish causal status.** Using a DAG or substantive domain expertise, establish that Z is plausibly a collider — a variable caused by both D and Y (or by D and an unobserved common cause of Y). If Z is instead a confounder, the IVB formula quantifies omitted variable bias in the short model, and the long model is correctly specified. The three steps below are informative only if Z's collider status has been established through causal reasoning, not statistical testing.

### 9. EDITAR: Conclusion (linhas 848-875)
- Adicionar parágrafo com resultados empíricos: "Across six published studies, the IVB was typically modest..."
- Mencionar que as condições estruturais (FE absorve canais between, poucos switchers, erro de medida) explicam por que IVBs são pequenos
- Manter a menção a future work (sensitivity analysis framework)
- Adicionar referência ao compute_ivb_multi() como supplementary material

### 10. ADICIONAR referências ao references.bib
Novas entradas necessárias:
- Leipziger (2024) AJPS
- Rogowski et al. (2022) AJPS
- Acemoglu et al. (2019) JPE — Democracy Does Cause Growth
- Grundler & Link (2024) — Causal effect of ethnic inequality on GDP
- Easterly & Levine (1997) QJE — Africa's Growth Tragedy
- Cederman et al. (2013) — Political exclusion and conflict
- Angrist & Pischke (2009) — Mostly Harmless Econometrics (bad controls)
- Acharya, Blackwell & Sen (2016) APSR — Direct effects
- Arellano & Bond (1991) RES — GMM dynamic panels
- Imai & Kim (2021) Political Analysis — TWFE
- de Chaisemartin & D'Haultfoeuille (2020) AER — TWFE heterogeneous effects
- Lal et al. (2024) Political Analysis
- Ross (2001) — Resource curse
- Besley & Persson (2011) — Pillars of Prosperity
- Stasavage (2005) — Democracy and education spending
- Papaioannou & Siourounis (2008) — Democratization and growth

### 11. ATUALIZAR: YAML header
- Adicionar `haven` e `fixest` às bibliotecas carregadas no setup chunk
- Adicionar `source("replication/ivb_utils.R")` no setup chunk
- Verificar que os paths para dados funcionam (pode precisar de paths relativos)

## Arquivos a modificar

- [x] `IVB-paper/ivb_paper_psrm.Rmd` — reestruturação principal
- [x] `IVB-paper/references.bib` — novas referências

## Arquivos a ler (NÃO modificar)

- `IVB-paper/replication/ivb_utils.R` — função compute_ivb_multi()
- `IVB-paper/replication/unified_ivb_report.Rmd` — código das replicações
- `IVB-paper/sim_ivb_twfe_v4_report.Rmd` — texto da simulação v4
- `IVB-paper/sim_ivb_twfe_v4.R` — código da simulação v4
- `IVB-paper/plots/v4_*.png` — figuras da simulação v4

## Ordem de execução

1. Adicionar referências ao references.bib
2. Editar Introduction (antecipar resultados empíricos)
3. Expandir foreign collider bias (Section 3)
4. Fortalecer caveats + expandir Nickell bias + adicionar Passo 0 (Section 4)
5. Remover Monte Carlo section (linhas 524-800) e Application (linhas 801-847)
6. Inserir nova Section 5 "When Does IVB Matter?"
7. Inserir nova Section 6 "Empirical Applications" (Leipziger + Rogowski)
8. Editar Conclusion
9. Atualizar YAML/setup

## Verificação

- [ ] Paper compila com rmarkdown::render() sem erros
- [ ] Dados de Leipziger e Rogowski carregam corretamente
- [ ] compute_ivb_multi() funciona com os datasets
- [ ] Figuras v4 aparecem no PDF
- [ ] Referências novas resolvem corretamente
- [ ] Estrutura de seções está coerente
- [ ] Foreign collider bias aparece em 3+ locais (Section 3, Leipziger, discussão)
- [ ] Caveat sobre identidade algébrica está claro em Section 4.7 e no Passo 0
- [ ] Nickell bias tem 3-4 parágrafos
