# Reparo documental da leitura de Gelbach, rodada 1

**Finding:** `R1-GF001` (`PARTIAL`).  
**Estado:** `IMPLEMENTED_AWAITING_INDEPENDENT_REVIEW`.  
**Fonte governante:** `../adjudication_round1.json`, SHA-256 `a3d4c675820d24d954c23e4c9fa55054e3e48301fed2e53fc1fe9fa104c497c6`.  
**Escopo implementado:** somente a parte confirmada sobre cronologia e atribuição bibliográfica. A parte ampla que sugeria mudança operacional efetiva de `C+` foi refutada pela adjudicação e não motivou redesenho.

## Antes e depois

| Local | Antes | Depois | Fundamento |
|---|---|---|---|
| Resultado principal do relatório | “`C+` fica mais forte depois desta leitura” | A leitura fortalece a atribuição bibliográfica de capacidades já congeladas; `C+` não foi ampliado depois dos resultados | A ficha v2 já continha momentos/alvo projetivo, OLS e auxiliares, hipóteses comuns, covariância conjunta e degenerescência |
| Relatório §3.2 | “alvo populacional mais forte que o registrado antes” e alvo apresentado como acréscimo a `C+` | A derivação anterior já tinha a versão populacional; o artigo agora fornece atribuição primária direta | `contribution/derivation.md:9` e ficha v2 antecedem a leitura integral |
| Relatório §3.6 | IV e Hausman “entram no comparador” | IV e Hausman delimitam eventual comparação futura | O teste congelado permanece OLS sem pesos |
| Relatório §5 | `C+` “passa a ter cinco camadas” | As cinco camadas organizam a descrição bibliograficamente atualizada do mesmo `C+` | Nenhuma operação, regra, dado ou hipótese foi acrescentado ao teste |
| CSV `L01`/`L17` | “strengthened” podia indicar nova capacidade | Atribuição bibliográfica fortalecida; núcleo e comparador congelado inalterados | Encerramento da pendência de full text muda a evidência disponível, não o desenho já testado |
| CSV `L02`/`L04`/`L05`/`L10`/`L12` | Algumas prescrições em tempo presente permitiam leitura de atualização posterior | Capacidades existentes e limites externos são atribuídos explicitamente à ficha congelada | Harmonização local necessária para não perpetuar a ambiguidade de `L01`/`L17` |

## Resultado preservado

- `P` e `C+` continuam equivalentes no domínio OLS sem pesos declarado.
- A identidade, os exemplos `E1`/`E2`, a regra de perda, os dados e a conclusão científica não mudaram.
- Pesos, instrumentos, IV e Hausman continuam fora do teste; são apenas referências para uma eventual ampliação futura.
- A distinção entre as duas aplicações aninhadas `B/U` e `C/U`, e a origem deduzida de sua covariância cruzada, não mudou.
- A cobertura permanece 35/35 páginas textuais e 22 páginas visuais; `page_coverage.csv` não foi alterado.
- O Gate 1 continua não aprovado e sujeito à revisão independente.

## Arquivos e hashes após o reparo substantivo

- `full_read_report.md`: `2737dcab2c8a66baea836c4c751e7ea745b128ca43ce4bf0aeeba36d5f3b0c33`
- `claim_comparison.csv`: `e3413815890a91a3508474b08dc52e2911cfa6126c1619c6e07f62b8a91241dc`
- `page_coverage.csv` inalterado: `d897a8a64b899f69bffb027c8fe433b1a7421822fc73809d4d08cde6b26eaac6`

Os bytes anteriores permanecem em `../snapshots/round1/reading/`. O manifesto é atualizado com estes hashes e com este registro de reparo.

## Verificação e limites

Foram confrontados os diffs do relatório e do CSV contra os snapshots da rodada 1. Uma busca dirigida confirmou a remoção das formulações ambíguas identificadas na adjudicação. O CSV será novamente validado quanto a linhas e colunas, e o JSON do manifesto e seus hashes serão verificados mecanicamente após a atualização.

Nenhum R, Stata, estimação, simulação, bootstrap, teste numérico, nova leitura bibliográfica, alteração do manuscrito ou modificação fora de `reading/` foi executado. Este reparo não se autoaprova.
