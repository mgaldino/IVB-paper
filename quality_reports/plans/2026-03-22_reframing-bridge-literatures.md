# Reframing: IVB como ponte entre literaturas DID e TSCS

**Status**: DRAFT
**Data**: 2026-03-22

## Contexto

O framing anterior ("collider bias no CET via controles defasados") foi invalidado porque o ADL resolve o problema em todos os cenários testados (170 configs, viés < 3%). A questão era: se o ADL resolve, qual é a contribuição?

A análise de papers recentes (Caetano & Callaway 2024, Lin & Zhang 2022, Caetano et al. 2022) revelou que o problema de "bad controls" em TWFE **ainda está sendo ativamente pesquisado** por econometristas top — e o companion paper de Caetano et al. sobre bad controls **ainda nem foi publicado**. Isso sugere que o espaço está aberto e o problema não está resolvido na percepção da comunidade.

## Insight central

As literaturas de DID (economia) e TSCS (ciência política) não conversam:

- **DID/TWFE** (Caetano et al.): identifica o problema de bad controls em TWFE, propõe métodos novos (doubly robust, AIPW, imputation). Não usa ADL.
- **TSCS/ADL** (BG 2018, Imai & Kim 2019): recomenda ADL por razões de identificação (strict exogeneity, sequential ignorability). Não pensa em termos de "bad controls" ou collider bias.
- **Ninguém conectou**: que o ADL resolve o bad controls problem quando Z é collider, que a fórmula IVB quantifica o viés, que d-separation explica por que o ADL funciona.

## Elevator pitch (novo — v2, ampliado)

"Pesquisadores aplicados precisam decidir quais variáveis incluir como controles. Se a variável é confounder, incluí-la remove OVB. Se é collider ou mediador, incluí-la introduz viés. Derivamos uma fórmula fechada — IVB = -θ* × π — que quantifica a mudança na estimativa causada pela inclusão ou exclusão de qualquer variável, usando quantidades já estimadas pelo pesquisador. A fórmula é uma identidade algébrica de OLS que vale em cross-section, DID e TSCS. Combinada com um DAG, ela permite ao pesquisador avaliar se incluir um controle melhora ou piora a estimativa e em quanto. Em painéis TSCS, mostramos que o ADL resolve o caso do collider — o problema para o qual a literatura de DID ainda está desenvolvendo métodos. Aplicamos o diagnóstico a seis estudos publicados."

## Contribuições neste framing (ampliado 2026-03-22)

1. **Fórmula IVB = -θ* × π como ferramenta geral de sensibilidade**: não apenas para collider bias, mas para qualquer decisão de inclusão/exclusão de variáveis. A fórmula quantifica a diferença entre regressão longa e curta; o DAG interpreta se essa diferença é viés (collider), over-control (mediador), correção (confounder), ou trade-off (dual role). Análogo a Cinelli & Hazlett (2020) para OVB, mas para o caso de inclusão e com componentes diretamente estimáveis.

2. **Ponte DID ↔ TSCS**: conecta o "bad controls" problem (Caetano et al.) com collider bias (DAGs/Pearl) e mostra que o ADL (recomendação padrão de BG e Imai & Kim) já resolve o caso collider no setting TSCS.

3. **Quantificação do over-control bias**: quando Z é mediador contemporâneo (D → Z → Y), a fórmula IVB mede o efeito indireto que está sendo bloqueado. Caetano et al. diagnosticam o problema qualitativamente; a fórmula IVB dá o número.

4. **Resultado positivo para practitioners**: quem já usa ADL (como BG recomendam) está protegido contra collider bias. Não precisa de doubly robust ou AIPW. A fórmula IVB permite verificar isso ex post.

5. **Aplicações empíricas**: mediana IVB ~ 0.13 SE em 6 estudos publicados — confirma que o viés é tipicamente modesto em aplicações reais.

## Posicionamento vs. literatura

| Paper | Relação |
|---|---|
| BG (2018) | Complementar. Mostraram β₁ consistente no ADL (p. 1073), mas como resultado secundário. Não quantificaram o viés de TWFE nem conectaram com collider bias. |
| Caetano & Callaway (2024) | Complementar. Diagnosticam problemas de TWFE com covariáveis (hidden linearity bias). Assumem strict exogeneity — não tratam bad controls. |
| Caetano et al. (bad controls) | Complementar. Work in progress, sem draft público. Tratarão bad controls em DID. IVB trata o caso específico de collider em TSCS com fórmula fechada. |
| Lin & Zhang (2022) | Tangencial. Covariate effect bias (efeitos time-varying). Mecanismo diferente. |
| Imai & Kim (2019) | Complementar. Argumento de identificação (strict exogeneity). ADL+FE como solução paramétrica. Não discutem collider bias. |

## O que sobrevive do paper atual

- Abstract e introdução: precisam de reescrita para o novo frame
- Seção 2 (Control Variable Problem): OK, mas adicionar referências a Caetano et al.
- Seção 3 (DAGs e collider bias): OK, mas expandir para incluir mediador e dual role
- Seção 4 (IVB formula): contribuição central, fica. Adicionar Remark sobre generalidade (collider, mediador, confounder) e analogia com Cinelli & Hazlett (2020)
- Tabela OVB vs IVB: expandir para incluir caso mediador e dual role
- Seção 5 (simulações): resultados válidos, mas reinterpretar — o ADL resolver é feature, não bug
- Seção 6 (aplicações): OK, mas reinterpretar cada controle via DAG (collider? mediador? confounder?)

## O que muda

- Frame: de "problema novo que ninguém viu" para "ferramenta de sensibilidade geral + diagnóstico para problema reconhecido"
- Escopo: de "collider bias apenas" para "qualquer decisão de inclusão/exclusão de variáveis"
- Tom: de adversarial (vs. BG) para complementar (ponte entre literaturas)
- Resultado do ADL: de "boundary condition" para "resultado positivo — ADL já protege"
- Motivação: de "controles defasados viésam CET" para "a fórmula IVB quantifica o impacto de incluir/excluir qualquer variável; o DAG interpreta"
- Analogia: IVB para inclusão é como Cinelli & Hazlett (2020) para omissão, mas com componentes estimáveis

## Riscos deste framing

- **Referee pode dizer**: "se ADL resolve, e BG já recomendam ADL, qual é a contribuição?" Resposta: (1) a fórmula diagnóstica é nova e geral, (2) aplica-se a colliders, mediadores e confounders, (3) para quem usa TWFE (maioria em CP), o diagnóstico é valioso, (4) análogo a Cinelli & Hazlett para inclusão.
- **Referee pode dizer**: "isso é só FWL, trivial." Resposta: Cinelli & Hazlett (2020) também é "só" OVB reformulado, e publicaram na Statistical Science. A contribuição é a interpretação unificada via DAG + a operacionalização.
- **Referee de economia**: pode não conhecer a literatura de TSCS/ADL. Precisa contextualizar.
- **Referee de CP**: pode não conhecer Caetano et al. Precisa motivar por que o problema é relevante.
- **Escopo ampliado demais?** Risco de o paper ficar disperso. Manter foco em collider como caso principal, com mediador e confounder como extensões/remarks.

## Próximos passos

- [ ] Decidir se este reframing ampliado é o caminho (discussão com coautores)
- [ ] Se sim, reescrever introdução e abstract
- [ ] Adicionar Remark na Seção 4 sobre generalidade da fórmula (collider/mediador/confounder)
- [ ] Adicionar analogia com Cinelli & Hazlett (2020) — IVB para inclusão, deles para omissão
- [ ] Expandir tabela OVB vs IVB com caso mediador e dual role
- [ ] Adicionar referências: Caetano & Callaway (2024), Lin & Zhang (2022), Caetano et al. (2022), Cinelli & Hazlett (2020)
- [ ] Reescrever derivação em notação de potential outcomes (ver derivations/ivb_potential_outcomes.md)
- [ ] Revisar seção de simulações para reinterpretar resultado do ADL
- [ ] Reinterpretar aplicações empíricas: classificar cada controle como collider/mediador/confounder via DAG
- [ ] Escolher journal target (Political Analysis? PSRM? Journal of Politics?)
