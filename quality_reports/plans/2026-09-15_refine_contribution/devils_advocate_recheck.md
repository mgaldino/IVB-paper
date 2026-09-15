# Rechecagem independente do Devil's Advocate

**Agente:** `devils_advocate_plan`; GPT-6 Astra, xhigh.  
**Versão revisada original:** `1091ba500ce48d0ba326667b0b634fda909edc9f24ba20a25113a6c61c83e7d9`.  
**Versão após cinco correções:** `93cd5efd1d2920593be8356c8bdc53a99e2fca558fe6bc1d8f62f6e5792818df`.

## Resultado da rechecagem das cinco correções

**Resultado: os cinco achados estão RESOLVIDOS para fins de planejamento.** Não identifiquei contradição material que mantenha algum deles aberto. Permanecem exigências de execução e verificação futura, não resultados certificados.

Conferi o diff contra a versão original preservada, cujo SHA-256 corresponde a `1091ba500ce48d0ba326667b0b634fda909edc9f24ba20a25113a6c61c83e7d9`. O plano rechecado tem SHA-256 `93cd5efd1d2920593be8356c8bdc53a99e2fca558fe6bc1d8f62f6e5792818df`.

1. **Critério de novidade — RESOLVIDO.** Localizadores: Gate 1, linhas119–123 e130; Gate 4, linha177. A ficha agora fixa decisão, ações, perda, comparador, distinção e equivalência. A proibição de limitar artificialmente o comparador fecha a possibilidade de demonstrar vantagem por uma comparação fraca. O critério de aprovação exige exemplo verificável, reconhece sua natureza provisória e exige justificativa própria para ganho apenas operacional. A existência efetiva desse ganho continua sendo objeto do Gate 1.
2. **Projeção de referência versus limite within — RESOLVIDO.** Localizadores: Gate 2, linhas136–137 e145–148; Gate 4, linha180. A nova exigência distingue expressamente os dois objetos e impede aceitar automaticamente uma grande simulação com $T$ fixo como referência livre do componente dinâmico. A definição de alvos e a verificação independente antecedem sua utilização nas simulações. A aproximação de alta precisão do Gate 4 permanece compatível com essa restrição; não a revoga.
3. **Compatibilidade conjunta da aplicação — RESOLVIDO.** Localizadores: Gate 1, linha127; Gate 3, linhas164–166; Gate 4, linha170. A seleção inicial tornou-se provisória. A matriz contempla história, estimabilidade, suporte, $N/T$, estimador, dependência e inferência; pelo menos uma aplicação precisa passar antes da execução extensa. Restringir o procedimento exige reavaliar a compatibilidade, fechando a lacuna entre viabilidade documental e aplicabilidade estatística.
4. **Restrições inferenciais operacionais e procedimento completo — RESOLVIDO.** Localizadores: Gate 3, linhas160–166; Gate 4, linhas179–181. O plano exige informação utilizável para aplicar restrições e inclui escolhas de história, classificação e troca de intervalos no procedimento a calibrar. Também determina avaliar fronteiras entre regimes e proximidade da origem, com saída descritiva quando a validade não for defendida. Isso especifica corretamente a tarefa; não pressupõe validade pós-seleção.
5. **Seleção entre tentativas e uso da reserva — RESOLVIDO.** Localizadores: Gate 4, linha178; Gate 5, linhas191–192; seção5, linha244. Desenvolvimento e avaliação posterior estão separados; reformulações e evidências anteriores ficam registradas; ausência de ganho não autoriza trocar de aplicação.

**Harmonização editorial opcional:** na linha202, “voltar à seleção” continua genérico. A regra expressa da linha192 já o restringe a inelegibilidade previamente definida, portanto não considero pendência material. Repetir essa condição no encerramento do Gate 5 reduziria o risco de leitura isolada.

Nenhum arquivo foi editado; nenhuma análise foi executada.

## Revalidação depois da harmonização editorial

**Revalidação concluída: o encerramento permanece coerente com os cinco achados resolvidos para fins de planejamento.**

O diff contém somente o parágrafo de encerramento do Gate 5, na linha202 do plano. A nova redação explicita corretamente que:

- Retornar à seleção exige inelegibilidade previamente definida.
- Ausência de ganho científico retorna ao Gate 1, preservando a aplicação e seu resultado.
- Não é permitido substituir o caso por uma aplicação mais favorável.

A alteração elimina a ambiguidade editorial residual e não reabre os demais achados.

**SHA-256 final:** `d2d2ea2e39102ab4193ee2f82b12b0823143867a23750c38d626aa4797eb7f5d`.

Conferi também que a versão anterior preservada corresponde ao hash `93cd5efd1d2920593be8356c8bdc53a99e2fca558fe6bc1d8f62f6e5792818df`. Nenhum arquivo foi editado; nenhuma análise foi executada.
