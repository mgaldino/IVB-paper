# Backlog: Edmans Review — Pontos a Endereçar

**Data**: 2026-02-28
**Última atualização**: 2026-02-28 23:50
**Status**: EM ANDAMENTO

---

## Prioridade 1: Compilabilidade (CRÍTICO)

- [x] **Appendix C não compila**: ~~Chunks de R dependiam de objetos não definidos.~~ **FEITO** — Adicionado chunk `appendix-adl-setup` com função `sim_adl_panel()`, parâmetros e simulação de 500 reps inline. Todos os 4 chunks do Appendix C compilam sem erro.

## Prioridade 2: Base Empírica

- [x] **Expandir de 2 para 6 aplicações**: **FEITO** — Tabela 3 (`tab:ivb_summary`) adicionada na Seção 6 com 6 estudos (Claassen, Leipziger, Blair et al., Albers et al., Rogowski et al., Ballard-Rosa et al.), 57 combinações control×study. Abstract, intro e conclusão atualizados para "six published studies". 4 novas referências no .bib.
- [ ] **Diversificar colliders**: Ambas as aplicações detalhadas usam GDP p.c. A tabela-resumo mostra outros colliders (inflation crisis, independence, regional democracy), mas os deep-dives são ambos GDP. Ideal: pelo menos um deep-dive com collider diferente.
- [ ] **Buscar caso onde IVB muda conclusão**: Nenhuma aplicação reverte sinal ou significância. Claassen (FE) tem IVB de 104% — potencial candidato para deep-dive, mas beta é near-zero.

## Prioridade 3: Benchmark para "IVB grande vs pequeno"

- [ ] **Definir regra de ouro explícita**: O paper usa informalmente |IVB/β| e IVB/SE, mas não propõe benchmark. Sugestão: |IVB| < 1 SE → estatisticamente invisível; |IVB/β| < 10% → substantivamente negligível. O CSV já tem as métricas (IVB_pct_beta, IVB_over_SE, IVB_over_SDY).

## Prioridade 4: Exposition

- [ ] **Comprimir Seções 4.4 (Nickell) e 4.5 (Lag Substitution)**: Mover álgebra detalhada para apêndice, manter intuição + implicação prática no corpo. Libera ~2 páginas.
- [ ] **Harmonizar promessa da intro com caveats**: "tells researchers *how much* bias" → "quantifies the arithmetic difference between specifications" + DAG. Linha 108.
- [ ] **Cortar roadmap seção-por-seção** (linhas 79-80): Headers já fazem esse trabalho.
- [ ] **Tabela-síntese de simulações**: Section 5 summary é narrativo — adicionar tabela com |IVB/β| mediano por mecanismo.

## Prioridade 5: Citações

- [x] **Remover/ajustar citações periféricas**: **FEITO** —
  - ~~Franzese & Hays 2007~~ → removido (linha 62)
  - ~~Pearl 2018 ao lado de Imbens 2020~~ → substituído por Pearl 2009 (linha 64)
  - ~~Yao et al. 2021~~ → removido (linha 121)
  - ~~Besley & Persson 2011 para convergência~~ → substituído por Acemoglu et al. 2019 (linha ~732)
- [ ] **Limpar entradas não usadas no .bib**: 10 entradas identificadas como não citadas: franzese2007spatial, yao2021survey, besley_persson2011, cederman_etal2013, angrist_pischke2009, imai_kim2021, dechaisemartin_dhaultfoeuille2020, lal_etal2024, ross2001, stasavage2005. Decisão: remover ou manter para uso futuro?

## Prioridade 6: Execution (melhorias opcionais)

- [ ] **Conectar Mecanismo D às aplicações**: GDP p.c. medido com erro em países em desenvolvimento. Quantificar attenuation bias em θ* → upper bound do IVB verdadeiro.
- [ ] **Fortalecer Proposição 4 com exemplo numérico calibrado**: Autocorrelação típica de democratização (ρ_D estimado de dados reais).
- [ ] **Consistência de reprodutibilidade**: Simulações Seção 5 usam PNGs pré-gerados; Appendix C tem código inline. Unificar abordagem.
- [ ] **Unificar notação**: Tabela 1 usa δ₁ × γ para OVB; texto ADL usa θ* × π. Adicionar nota sobre transição.

## Prioridade 7: Contribution (direções futuras — já parcialmente endereçadas)

- [x] **Posicionar vs. Ding & Miratrix (2015)**: Expandido na Seção 1.4, Caveats (Butterfly-Bias), Seção 5 (higher-order) e Conclusão (future work FWL-based). Sessão de 2026-02-28.
- [ ] **Sensitivity analysis para IVB**: Análogo a Cinelli & Hazlett 2020. Mencionado como future work na Conclusão.
- [ ] **Derivação analítica FWL para collider vs. confounder em TWFE**: Inspirado por Butterfly-Bias de Ding & Miratrix, mas usando FWL em painel. Mencionado como future work (sessão de 2026-02-28).

---

## Resumo de progresso

| Prioridade | Status | Itens feitos / total |
|-----------|--------|---------------------|
| 1. Compilabilidade | **CONCLUÍDO** | 1/1 |
| 2. Base empírica | Parcial | 1/3 |
| 3. Benchmark | Pendente | 0/1 |
| 4. Exposition | Pendente | 0/4 |
| 5. Citações | Parcial | 1/2 |
| 6. Execution | Pendente | 0/4 |
| 7. Contribution | Parcial | 1/3 |

## Fonte

Baseado na Edmans Review (3 agentes: Contribution 6/10, Execution 7.5/10, Exposition 7.5/10) realizada em 2026-02-28.
