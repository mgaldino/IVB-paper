# Diagnóstico: Viés do Agente Implementador (Fixer)

**Data**: 2026-03-01
**Contexto**: Observado em múltiplas interações no projeto IVB-paper

## O problema

O Agente Implementador (fixer) no research-pipeline tem um viés sistemático: **responde a toda crítica adicionando texto, nunca removendo**. Quando o reviewer identifica uma fraqueza, o fixer adiciona caveats, parágrafos qualificadores, ou seções inteiras — mesmo quando a resposta correta seria cortar o conteúdo problemático.

Isso é especialmente danoso em manuscritos acadêmicos, onde parcimônia é virtude e cada parágrafo precisa justificar sua existência.

## Sintomas observados

1. **Simulações redundantes mantidas**: Mechanisms A/B (heatmaps de FE absorvendo between) e Mechanism D (atenuação por erro de medida) são resultados bem conhecidos. O argumento algébrico no texto é suficiente e mais rigoroso. As simulações não adicionam insight novo. O fixer, em vez de remover, adicionaria um caveat tipo "these simulations serve as numerical verification of the algebraic result" — o que não resolve o problema do leitor que leu três páginas para nada.

2. **Caveats em vez de cortes**: Quando um reviewer diz "este ponto é fraco", o fixer adiciona uma frase tipo "an important limitation is..." em vez de perguntar "este conteúdo deveria existir?".

3. **Viés de ação**: O fixer opera sob pressão implícita de "fazer algo" para cada item do parecer. Remover conteúdo não parece "fazer algo" — parece não ter trabalhado. Mas é frequentemente a ação correta.

## Causa raiz no pipeline

O prompt do Implementador no Estágio 2 (Devil's Advocate) diz:

> "Para cada issue de severidade Crítico e Major, **faça a correção** no manuscrito."

"Faça a correção" é interpretado como "adicione ou modifique texto". O prompt nunca menciona que cortar/remover é uma correção válida. Além disso:

- O prompt do Estágio 1 diz "implemente as **correções** indicadas" — novamente, viés para adição.
- Nenhum prompt menciona que a melhor resposta pode ser deletar seções, parágrafos, ou argumentos inteiros.
- O pipeline não tem um gate de "este conteúdo justifica sua existência?" — só tem gates de "este conteúdo tem problemas?".

## Mudanças necessárias no `research-pipeline/SKILL.md`

### 1. Alterar o prompt do Implementador (Estágio 2, linha 98)

**Atual**:
```
Prompt: Leia o Devil's Advocate Report abaixo. Para cada issue de severidade
Crítico e Major, faça a correção no manuscrito. Não mexa em pontos que não
foram criticados.
```

**Proposto**:
```
Prompt: Leia o Devil's Advocate Report abaixo. Para cada issue de severidade
Crítico e Major, decida a ação correta entre:
(a) CORTAR — remover o conteúdo que não se justifica (seção, parágrafo,
    figura, tabela). Esta é frequentemente a melhor resposta quando o
    conteúdo é redundante, trivial, ou repete resultado bem conhecido.
(b) REESCREVER — reformular o argumento para eliminar a vulnerabilidade.
(c) ADICIONAR — incluir evidência, caveat, ou argumento faltante. Use
    apenas quando o problema é genuinamente uma lacuna, não quando o
    conteúdo existente é fraco.

Regra de decisão: se o leitor terminará a seção pensando "para que eu li
isso?", a resposta é (a), não (c). Caveats não salvam conteúdo que não
deveria existir. Não mexa em pontos que não foram criticados.
```

### 2. Alterar o prompt do Implementador (Estágio 1, linha 80)

**Atual**:
```
Prompt: Leia o parecer abaixo e implemente as correções indicadas.
Priorize: Crítico primeiro, depois Major, depois Minor. Não adicione
melhorias extras que não foram pedidas.
```

**Proposto**:
```
Prompt: Leia o parecer abaixo e implemente as correções indicadas.
Priorize: Crítico primeiro, depois Major, depois Minor. Não adicione
melhorias extras que não foram pedidas. Lembre-se: remover código
redundante ou desnecessário é uma correção válida — frequentemente a
melhor. Não preserve código problemático adicionando workarounds.
```

### 3. Adicionar instrução ao Agente Reviewer (Estágio 2, Devil's Advocate)

O reviewer precisa classificar explicitamente se a ação recomendada é cortar vs. reescrever vs. adicionar. Adicionar ao prompt do reviewer:

```
Para cada vulnerabilidade, indique a AÇÃO RECOMENDADA:
- CORTAR: o conteúdo não se justifica e deve ser removido
- REESCREVER: o argumento tem mérito mas a formulação é vulnerável
- ADICIONAR: há uma lacuna genuína que precisa ser preenchida

Prefira CORTAR quando: (i) o resultado é bem conhecido e não precisa de
demonstração, (ii) a simulação confirma algebra sem insight novo, (iii) o
leitor não ganha nada lendo a seção. Nunca recomende adicionar caveats
para salvar conteúdo que deveria ser cortado.
```

### 4. Adicionar regra global ao pipeline (nova seção após "Scoring")

```markdown
## Princípio de Parcimônia

O pipeline opera sob o princípio de que **menos é mais** em escrita acadêmica.
Especificamente:

- Remover conteúdo fraco é tão válido quanto adicionar conteúdo forte.
- Uma seção que apenas confirma um resultado algébrico já demonstrado não
  justifica sua existência — o leitor não ganha nada.
- Um caveat não salva uma seção sem contribuição própria.
- O teste para manter conteúdo é: "O leitor entende algo novo ou diferente
  após ler isso?" Se não, cortar.
- Simulações que confirmam resultados analíticos sem adicionar insight
  empírico novo (e.g., calibração com dados reais, robustez a violações)
  devem ser candidatas a remoção.
```

## Mudanças necessárias no `devils-advocate/SKILL.md`

### 5. Adicionar dimensão de ataque: Economia do texto

Após a seção "5. Contra-argumentos na literatura", adicionar:

```markdown
### 6. Economia do texto
- Há seções que repetem resultados bem conhecidos sem insight novo?
- Há simulações que apenas confirmam algebra sem explorar regimes novos?
- O leitor terminará alguma seção pensando "para que eu li isso?"
- Há conteúdo que poderia ser cortado sem perda para o argumento central?
```

E no formato de output, adicionar ao ranking de vulnerabilidades:

```markdown
## Recomendações de corte
[Seções, figuras, ou parágrafos que deveriam ser removidos, com justificativa]
```

## Mudanças no `quality-gates.md`

### 6. Adicionar penalidade para conteúdo sem contribuição

Na seção de manuscritos, adicionar:

```
- Seção/figura sem contribuição nova (repete resultado conhecido): -10
- Simulação que apenas confirma algebra sem insight adicional: -5
```

## Resumo das mudanças

| Arquivo | O que muda | Linhas afetadas |
|---------|-----------|-----------------|
| `research-pipeline/SKILL.md` | Prompt do Implementador (Estágio 1) | ~80 |
| `research-pipeline/SKILL.md` | Prompt do Implementador (Estágio 2) | ~98 |
| `research-pipeline/SKILL.md` | Prompt do Reviewer (Estágio 2) | ~92 |
| `research-pipeline/SKILL.md` | Nova seção "Princípio de Parcimônia" | após ~63 |
| `devils-advocate/SKILL.md` | Nova dimensão "Economia do texto" | após ~49 |
| `devils-advocate/SKILL.md` | Nova seção "Recomendações de corte" no output | após ~78 |
| `quality-gates.md` | Penalidade para conteúdo sem contribuição | seção manuscritos |

## Teste de validação

Após implementar, rodar o pipeline no IVB paper e verificar se o Devil's Advocate:
1. Identifica Mechanisms A/B/D como candidatas a corte (não a caveats)
2. Recomenda CORTAR (não REESCREVER) para simulações redundantes
3. O Implementador efetivamente remove seções em vez de adicionar qualificadores
