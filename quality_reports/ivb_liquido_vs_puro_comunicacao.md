# IVB: efeito líquido vs efeito puro de collider

## Objetivo

Documentar, sem editar o paper, onde e como comunicar de forma mais explícita que `-theta* x pi` pode ser efeito líquido entre especificações e só é "collider puro" sob hipóteses adicionais.

## Pontos do paper onde vale ajustar

1. **Abstract**
- Ideia geral: incluir uma frase curta dizendo que a expressão `-theta* x pi` é a mudança entre regressão longa e curta, com interpretação causal de collider dependendo da validade do modelo curto.
- Objetivo de comunicação: evitar leitura de que a fórmula sempre mede "dano puro do collider".

2. **Introdução (logo após a equação principal do IVB)**
- Ideia geral: distinguir explicitamente "identidade algébrica" de "interpretação causal".
- Objetivo de comunicação: reforçar que a fórmula é sempre verdadeira para modelos aninhados, mas a leitura causal exige premissas sobre o papel de `Z`.

3. **Transição após Proposição 1 / seção OVB versus IVB**
- Ideia geral: adicionar um parágrafo com o caso misto (controle que reduz parte da confusão e também abre caminho de collider).
- Objetivo de comunicação: preparar o leitor para cenários em que o efeito observado ao incluir `Z` é líquido, não necessariamente puro.

4. **Seção "A Practical Recipe"**
- Ideia geral: transformar a receita em procedimento condicional:
- Primeiro: justificar causalmente que `Z` é collider no problema substantivo.
- Depois: usar `-theta* x pi` como quantificação.
- Objetivo de comunicação: reduzir risco de uso mecânico da fórmula como teste automático.

5. **Seção "Interpretation Caveats"**
- Ideia geral: tornar explícito que, no caso misto, `-theta* x pi` representa a diferença entre especificações (efeito líquido), não necessariamente o componente puro de collider.
- Objetivo de comunicação: fechar a interpretação com uma regra clara para leitores aplicados.

## Mensagem central a ser repetida

`-theta* x pi` é sempre uma decomposição algébrica válida entre modelo curto e longo.  
Ela vira medida de "collider bias puro" apenas quando as hipóteses causais que tornam o modelo curto o benchmark correto são plausíveis.

