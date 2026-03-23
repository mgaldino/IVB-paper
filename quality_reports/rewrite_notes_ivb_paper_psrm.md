# Notas editoriais: Bad Controls in Dynamic Panels

**Arquivo original**: ivb_paper_psrm.Rmd
**Data**: 2026-03-22

## Diagnóstico da versão original

A introdução original abre com "Applied researchers using TSCS data face a recurring decision" — funcional mas genérico, sem tensão ou puzzle concreto. O primeiro parágrafo tenta fazer trabalho demais: problema, três papéis causais, timing, e crítica das heurísticas em um único bloco denso. O parágrafo da fórmula (original para 3) é longo e repete a interpretação via DAG que já aparece no parágrafo seguinte.

## Principais mudanças

1. **Abertura com tensão concreta** — "Every researcher who includes a time-varying covariate is making a bet" em vez de "Applied researchers face a recurring decision." A metáfora da aposta é precisa (incluir pode ajudar ou prejudicar) e cria engajamento imediato sem ser jornalística.

2. **GDP per capita como exemplo concreto na abertura** — Em vez de falar abstratamente sobre Z_{t-1} vs Z_t, o primeiro parágrafo usa GDP per capita como instância concreta que muda de papel com timing. Isso antecipa as aplicações empíricas.

3. **Parágrafo da literatura como "divide disciplinar"** — A frase "parallel but disconnected responses" enquadra DID e TSCS como campos que reconhecem o problema mas não conversam, motivando a ponte. Mais preciso que "the difficulty is increasingly recognized."

4. **Fórmula separada em dois jobs** — O parágrafo da fórmula agora faz: (a) apresenta a equação, (b) diz de onde vem (OLS/FWL), (c) a última frase — separada — explica que o DAG transforma a decomposição em diagnóstico. Na versão original, tudo estava misturado.

5. **Resultado nulo reframado** — O penúltimo parágrafo agora fecha com "The typical finding is that the specification choice does not matter much. Knowing that is itself the point." Isso antecipa a objeção do reviewer ("se IVB é pequeno, por que se importar?") convertendo o resultado nulo em feature.

6. **Roadmap idêntico** — Mantido ipsis litteris.

## O que foi preservado

- A equação IVB = -θ* × π e seu placement central
- O framing "two tools" (fórmula + benchmark)
- A footnote sobre notação cross-section vs TSCS
- O contraste com DID de 2 períodos
- Todos os números: 238 DGPs, 3%, 0.13 SE, 14 candidatos, Rogowski et al.
- Todas as citações (Cinelli, Caetano & Callaway, Lin & Zhang, Caetano et al., BG, IK, FWL, Rogowski)
- O roadmap

## Pontos para verificação do autor

1. **"Making a bet"** — A metáfora é precisa mas pode soar informal para alguns leitores de PA/PSRM. Se preferir algo mais austero, "Every researcher who includes a time-varying covariate implicitly chooses between specifications that may differ substantially" funciona mas é mais fraco.

2. **GDP per capita no primeiro parágrafo** — Referência específica a uma variável antes de apresentar o framework formal. Funciona pedagogicamente mas pode parecer prematuro. Alternativa: remover a menção específica e ficar com a formulação genérica Z_{t-1} vs Z_t.

3. **"Knowing that is itself the point"** — Esta frase é a resposta direta à objeção do DA ("resultado nulo = auto-sabotagem"). Verificar se o autor concorda com essa postura (analogia: sensitivity analysis é valiosa mesmo quando o resultado sobrevive).

4. **Ausência de "foreign collider bias" na intro** — O conceito foi removido da introdução (aparece na Seção 3.3). Isso é intencional: o DA classificou o termo como sem conteúdo analítico adicional. Mas se o autor considera o conceito pedagogicamente central, pode ser reintroduzido com uma frase.
