# Devil’s Advocate Report

**Revisor:** agente `devils_advocate_plan`, GPT-6 Astra, esforço xhigh.  
**Objeto:** versão preservada em `evidence/plan_reviewed_v1.md`, SHA-256 `1091ba500ce48d0ba326667b0b634fda909edc9f24ba20a25113a6c61c83e7d9`.  
**Contrato respeitado:** `ivb-pa-refine:5375d3c27ac1:round1`; hash do PDF conferido. Revisão apenas, sem alterações ou execução de análises. Os localizadores abaixo se referem à versão revisada, preservada integralmente.

## Vulnerabilidade principal

**O plano organiza uma revisão tecnicamente rigorosa, mas seu Gate 1 ainda pode aprovar uma contribuição insuficientemente distinta.** A exigência de uma “diferença defensável” e de um benefício “demonstrável” permite avançar com uma vantagem operacional plausível, embora o comparador forte possa produzir as mesmas informações e decisões. É necessário transformar essa exigência em um teste de aprovação mais específico antes de investir nos Gates 2–5.

## Ataques por dimensão

### 1. Contribuição e confronto com a literatura: falta fechar o teste que pode reprovar a novidade

**Localizador:** Gate 1, linhas 108–117; linhas 19–23 e 161.  
**Severidade: alta.**

O plano corretamente entrega ao comparador o mesmo DAG, timing, história e dados. Isso elimina vantagens produzidas por informação privilegiada, mas agrava a pergunta substantiva: **qual capacidade permanece exclusiva da proposta quando o comparador pode aplicar a decomposição conhecida às mesmas regressões?** Cancelamento, decomposição de substituições e explicitação de pressupostos podem ser úteis sem constituir um avanço metodológico distinto.

“Decisão concreta” ainda não especifica as ações possíveis, o erro que se quer evitar e o comportamento efetivo do comparador. Uma regra convencional artificialmente limitada produziria uma vitória pouco informativa. Por outro lado, um ganho de compreensão não fica demonstrado por simulações algébricas ou desempenho de agentes, limite que o plano já reconhece.

**Como o autor poderia responder:** exigir no Gate 1 uma ficha congelada contendo:

- Decisão, ações possíveis e critério de acerto ou perda.
- Implementação suficientemente forte do comparador.
- Resultado verificável que distinguiria os procedimentos.
- Resultado que obrigaria a concluir equivalência.
- Natureza exata do acréscimo: matemática, inferencial, computacional ou operacional.

Se ambos produzem as mesmas decisões com as mesmas informações, registrar isso como resultado do gate. Uma contribuição operacional pode continuar promissora, mas precisa de uma justificativa própria para sustentar o artigo; não deve herdar automaticamente o rótulo de avanço metodológico.

### 2. Lógica matemática: “coeficiente populacional” ainda permite separar incorretamente o viés de painel curto

**Localizador:** Gate 2, linhas 123 e 130–131; Gate 4, linha 163.  
**Severidade: alta.**

A identidade

$$E[\widehat\Delta]=\Delta^P+b_L-b_S$$

está correta pela definição dos termos. Ela, sozinha, não garante que $\Delta^P$ represente exclusivamente a mudança de especificação pretendida.

Há um risco concreto na alternativa de aproximar os coeficientes populacionais por simulação de alta precisão: aumentar muito $N$, mantendo $T$ fixo e usando a mesma transformação within, pode aproximar o limite do estimador naquele painel curto. Esse limite pode incorporar justamente o componente dinâmico que se pretendia classificar como viés de estimação. A derivação existente (`derivations/adl_cet_identification_conditions.Rmd:197`) já reconhece que aumentar $N$ com $T$ fixo não remove esse problema.

O plano manda explicitar a sequência assintótica, mas falta dizer qual aproximação seria recusada como referência populacional.

**Como o autor poderia responder:** fazer do Gate 2 uma exigência inequívoca: definir a projeção causal/populacional de referência separadamente do limite da regressão within com $T$ fixo. Para cada aproximação numérica, demonstrar qual deles é recuperado. Se ambos forem necessários, nomeá-los separadamente e mostrar a relação. O Gate 4 só recebe alvos já definidos; alta precisão numérica não resolve uma definição inadequada.

### 3. Mecanismo causal e aplicação: a viabilidade documental não assegura compatibilidade conjunta com o procedimento

**Localizador:** Gate 1, linhas 112–117; linhas 129, 140–150 e 172–184.  
**Severidade: alta, sobretudo para a viabilidade da execução.**

É possível encontrar uma aplicação com janelas bem documentadas e, posteriormente, descobrir que a história necessária exige muitos lags, destrói suporte ou deixa poucos períodos; que a dependência exige clusters inadequados; ou que um estimador corrigido por viés é necessário e sai do núcleo OLS da identidade.

O plano prevê todas essas dificuldades individualmente. A lacuna está na aprovação conjunta: a aplicação passa documentalmente no Gate 1, enquanto o Gate 3 pode terminar restringindo o procedimento a uma classe que já não a contém. Seu critério de aprovação enfatiza a executabilidade por dois leitores, mas não exige expressamente que a aplicação escolhida sobreviva às restrições finais.

**Como o autor poderia responder:** tornar a escolha do Gate 1 provisória e incluir, no encerramento do Gate 3, uma matriz obrigatória de compatibilidade da aplicação principal e da reserva: história admissível defendida, equações estimáveis, suporte, $N/T$, estimador e dependência. Pelo menos uma deve permanecer dentro da região coberta antes da campanha integral de simulações. Isso antecipa um possível fracasso caro sem exigir outra aplicação agora.

### 4. Inferência e escopo: restringir a validade precisa produzir uma regra aplicável

**Localizador:** Gate 3, linhas 146–150; Gate 4, linhas 164–168.  
**Severidade: média-alta.**

O plano acerta ao reconhecer pós-seleção e comportamento não regular quando ambos os componentes do produto estão próximos de zero. Entretanto, “validar a solução ou declarar sua região de validade” pode produzir uma restrição definida pelos valores verdadeiros desconhecidos de $\theta$ e $\pi$. Nesse caso, o pesquisador não saberia se sua aplicação está dentro dela.

O mesmo problema reaparece se o procedimento escolhe história, classifica um caso como difícil e depois troca o intervalo. Validar cada intervalo com especificação fixa não valida necessariamente essa decisão composta. O plano exige calibração do procedimento final, mas não determina que a escolha entre métodos e as fronteiras entre regiões façam parte dela.

**Como o autor poderia responder:** exigir que cada restrição de uso indique como será aplicada com informação disponível ao pesquisador. Qualquer troca de método baseada nos dados deve integrar o procedimento simulado. Incluir casos nas fronteiras entre regras e próximos da origem, além dos pontos interiores. Se a validade não puder ser defendida, prever uma saída descritiva explícita ou um procedimento conservador cuja validade seja demonstrada. Não é necessário resolver toda a inferência não regular para concluir o artigo.

### 5. Evidência empírica: os retornos entre gates deixam aberta a seleção entre tentativas

**Localizador:** Gate 4, linha 168; Gate 5, linhas 174 e 184; linha 224.  
**Severidade: média.**

Pré-especificar cada rodada não elimina seleção entre rodadas. Se a vantagem desaparece e o processo volta ao Gate 1, novos exemplos, decisões ou regiões de parâmetros podem ser escolhidos à luz dos resultados anteriores. O resultado final poderia parecer previsto desde o início.

Nas aplicações, a proibição de substituir um resultado pequeno ou desfavorável é boa. Porém, “voltar à seleção” após a falha do Gate 5 precisa distinguir inelegibilidade documental de ausência de ganho científico. Esta última é evidência sobre a proposta.

**Como o autor poderia responder:** manter um registro das reformulações, indicando quais resultados as motivaram. Casos que contrariaram uma recomendação devem permanecer visíveis como limites, mesmo após restringi-la. Separar desenvolvimento e avaliação posterior do procedimento congelado. Na aplicação, ausência de vantagem incremental não autoriza substituição; somente falhas de elegibilidade previamente definidas permitem ativar a reserva.

## Ranking de vulnerabilidades

1. **Teste de novidade insuficientemente fechado:** pode produzir um paper correto e ainda incremental.
2. **Definição do alvo populacional:** pode invalidar a separação central entre especificação e estimação.
3. **Compatibilidade conjunta da aplicação:** pode deixar a demonstração principal sem caso elegível após investimento elevado.
4. **Restrições inferenciais não operacionais:** podem tornar a recomendação inaplicável ou sua calibração incompleta.
5. **Seleção entre tentativas:** pode exagerar a força da evidência final.

## O que sobrevive ao escrutínio

A correção do nesting é adequada: a identidade via modelo de união está certa, mantém a amostra e distingue diferença final de atribuição dependente do percurso. O plano também preserva limites importantes sobre interpretação causal, história, dependência, seleção e aplicações atuais.

A orquestração é realizável: respeita quatro agentes simultâneos, delimita arquivos e separa implementação de revisão. O plano de exposição é particularmente sólido ao exigir reconstrução do argumento por um leitor sem memorandos internos.

**Veredito:** há uma rota séria de investigação. Os ajustes necessários concentram-se nos critérios de aprovação e interrupção, sobretudo nos Gates 1–3. Eles aumentam a capacidade do plano de descobrir cedo que a contribuição é insuficiente, ou de demonstrar com precisão o que efetivamente a torna distinta.
