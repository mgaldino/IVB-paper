# Relatório Unificado: Over-control Contemporâneo

**Data**: 2026-03-22  
**Status**: OFFICIAL SYNTHESIS  
**Baseado em**:

- `quality_reports/overcontrol_contemporaneous_simulation_report.md`
- `quality_reports/overcontrol_simulation_report.md`

**Scripts subjacentes**:

- `simulations/nonlinearity/sim_overcontrol_contemporaneous.R`
- `simulations/overcontrol/sim_overcontrol.R`

---

## 1. Objetivo

Consolidar os dois exercícios de simulação sobre **over-control com mediador contemporâneo** em uma leitura única para uso no paper.

Os dois relatórios são **complementares**, não substitutos:

1. O experimento `sim_overcontrol_contemporaneous.R` isola o caso de **mediador puro** e usa um contraste mais limpo para TSCS dinâmico.
2. O experimento `sim_overcontrol.R` amplia o escopo para incluir também o caso **mediador + confounder via lags**.

---

## 2. O que cada experimento identifica

### 2.1 Experimento A: mediador puro, contraste limpo

DGP:

`D_t -> Z_t -> Y_t`, sem `Y_t -> Z_t` e sem canal de confounding por `Z_{t-1}`.

Parâmetros lineares:

- `beta = 1.0`
- `theta = 0.5`
- `delta_D = 0.4`

Logo, o efeito total linear verdadeiro é:

`1.2 = 1.0 + 0.5 * 0.4`

Este experimento foi desenhado para responder:

- incluir `Z_t` contemporâneo bloqueia o efeito indireto?
- substituir `Z_t` por `Z_{t-1}` evita esse bloqueio?

### 2.2 Experimento B: mediador puro + mediador com confounding

DGP mais geral:

- variante `pure_mediator`: `gamma_D = 0`, `gamma_Y = 0`
- variante `mediator_confounder`: `gamma_D = 0.15`, `gamma_Y = 0.2`

Parâmetros lineares:

- `beta = 1.0`
- `theta = 0.3`
- `delta_D = 0.1`

Logo, o efeito total linear verdadeiro é:

`1.03 = 1.0 + 0.3 * 0.1`

Este experimento foi desenhado para responder:

- `Z_{t-1}` continua seguro quando há mediador contemporâneo?
- se `Z_{t-1}` também for confounder, ele ajuda a remover OVB sem gerar over-control?

### 2.3 Implicação metodológica

Os dois experimentos **não estão na mesma escala numérica**.

Os tamanhos de over-control não são diretamente comparáveis porque:

- o Experimento A calibra um canal mediador maior
- o Experimento B calibra um canal mediador menor e adiciona uma variante com confounding

Portanto, a síntese deve comparar **direção e mecanismo**, não magnitude bruta entre os dois scripts.

---

## 3. Resultado comum aos dois relatórios

### 3.1 `Z_t` contemporâneo gera over-control

Ambos os exercícios mostram que incluir `Z_t` contemporâneo desloca a estimativa na direção do **efeito direto**, bloqueando o canal `D_t -> Z_t -> Y_t`.

### 3.2 `Z_{t-1}` não bloqueia o mediador contemporâneo

Para o **efeito contemporâneo** de `D_t` sobre `Y_t`, usar `Z_{t-1}` em vez de `Z_t` não gera over-control.

Formulação precisa:

> `Z_{t-1}` é pré-tratamento para o efeito contemporâneo de `D_t` sobre `Y_t`, não “pré-tratamento em sentido absoluto”.

### 3.3 `TWFE short` não é benchmark causal limpo neste setting

Os dois relatórios convergem num ponto decisivo:

- `TWFE short` sem dinâmica fica inflado por persistência e/ou dinâmica omitida
- portanto, ele **não** deve ser usado como benchmark substantivo do efeito total no caso TSCS dinâmico

O benchmark correto para comunicar o resultado do mediador é uma especificação ADL com dinâmica adequada.

---

## 4. Leitura unificada do caso linear

### 4.1 Mediador puro: resultado limpo

No Experimento A:

- `ADL total` ficou em `1.199`-`1.201`
- `ADL bad` ficou em `0.992`-`0.998`
- `ADL safe` ficou em `1.197`-`1.199`
- over-control em ADL: `-0.203` a `-0.206`

Leitura:

- `ADL total` recupera o efeito total
- `ADL + Z_t` recupera algo muito próximo do efeito direto
- `ADL + Z_{t-1}` preserva o efeito total

Este é o exercício mais limpo para demonstrar o mecanismo de over-control.

### 4.2 Mediador puro com calibração menor: mesmo mecanismo

No Experimento B, variante `pure_mediator`:

- `adl_DYlag` ficou em `1.028`-`1.031`
- `adl_DYlag_Z` ficou em `0.997`-`0.998`
- `adl_all` ficou em `1.027`-`1.029`
- over-control em ADL: `-0.031` a `-0.032`

Leitura:

- o mecanismo é o mesmo
- a magnitude é menor porque o canal mediador foi calibrado para ser menor

### 4.3 Mediador + confounder: `Z_{t-1}` ajuda

No Experimento B, variante `mediator_confounder`:

- `adl_DYlag` ficou em `1.091`-`1.111`
- `adl_DYlag_Z` ficou em `1.016`-`1.023`
- `adl_all` ficou em `1.028`-`1.031`
- over-control em ADL com `Z_t`: `-0.068` a `-0.095`

Leitura:

- incluir `Z_t` contemporâneo ainda gera over-control
- incluir `Z_{t-1}` remove confounding via lags
- e faz isso **sem** bloquear o efeito indireto contemporâneo

Este é o resultado que sustenta a frase:

> Em TSCS, um ADL bem especificado pode usar `Z_{t-1}` para corrigir confounding sem incorrer em over-control contemporâneo.

---

## 5. Não linearidade

Os dois relatórios convergem também sob não linearidade:

- formas **bounded** preservam o padrão qualitativo
- formas **unbounded** amplificam o deslocamento de projeção linear

### 5.1 Mediador puro

Faixa de over-control em ADL no Experimento A:

- bounded moderado (`log2`, `softpoly2`): `-0.203` a `-0.211`
- bounded forte (`tanh`): `-0.258` a `-0.434`
- unbounded (`Dlog`): `-0.406` a `-1.035`

Faixa correspondente no Experimento B:

- bounded: `-0.032` a `-0.050`
- unbounded: `-0.085` a `-0.092`

Outra vez: magnitudes diferentes refletem parametrização diferente, não divergência conceitual.

### 5.2 Mediador + confounder

No Experimento B:

- bounded: `-0.069` a `-0.115`
- unbounded: `-0.140` a `-0.186`

Conclusão:

- quando confounding e mediação coexistem, o ganho de usar `Z_{t-1}` fica ainda mais substantivamente relevante

---

## 6. Fórmula IVB

O ponto mais forte do Experimento A é que ele mostra de forma limpa:

`coef(ADL + Z_t) - coef(ADL total) = -theta* x pi`

até precisão de máquina.

Portanto, para o caso mediador:

- sob linearidade, IVB coincide exatamente com o efeito indireto bloqueado
- sob não linearidade, IVB continua sendo a diferença entre projeções lineares, com interpretação causal aproximada guiada pelo DAG

---

## 7. Formulação oficial para o paper

### 7.1 O que podemos dizer

> Nos DGPs TSCS simulados, incluir o mediador contemporâneo `Z_t` desloca a estimativa do efeito contemporâneo de `D_t` sobre `Y_t` na direção do efeito direto, caracterizando over-control. Em contraste, uma especificação `ADL + FE` que usa estados defasados, incluindo `Z_{t-1}` quando substantivamente apropriado, evita o over-control contemporâneo. Quando `Z_{t-1}` também é confounder, sua inclusão corrige OVB sem bloquear o canal mediador contemporâneo.

### 7.2 O que não devemos dizer

- Não dizer: `ADL + Z_{t-1} sempre cura`.
- Não dizer: `Z_{t-1} é sempre pré-tratamento`.
- Não dizer: `TWFE short` identifica o efeito total neste setting dinâmico.
- Não dizer: `ADL resolve todos os problemas de Caetano et al.`.

### 7.3 Formulação precisa sobre timing

> Para o efeito contemporâneo de `D_t` sobre `Y_t`, `Z_{t-1}` é pré-tratamento. Isso não implica que a mesma variável seja inocua para efeitos defasados, cumulativos ou de longo prazo.

---

## 8. Recomendação para a Seção 5

O caso mediador deve ser apresentado assim:

1. **Caso linear limpo**: usar o Experimento A para mostrar `ADL total` vs `ADL bad` vs `ADL safe`.
2. **Extensão com confounding**: usar o Experimento B para mostrar que `Z_{t-1}` também pode remover OVB quando necessário.
3. **Não linearidade**: resumir que o padrão qualitativo sobrevive, mas formas unbounded ampliam a magnitude.

Em termos de comunicação, o contraste recomendado é:

- `ADL total`: benchmark do efeito total contemporâneo
- `ADL bad`: inclui `Z_t`, produz over-control
- `ADL safe`: inclui `Z_{t-1}`, evita over-control contemporâneo

---

## 9. Conexão com PTA condicional

### 9.1 A variante mediador+confounder É o caso de PTA condicional

Quando gamma_D > 0 e gamma_Y > 0, Z_{t-1} causa tanto D_t quanto Y_t. Em linguagem de potential outcomes, parallel trends **não vale incondicionalmente** — unidades com Z_{t-1} alto têm trajetórias diferentes de Y(0). PT só vale condicional em Z_{t-1}.

Isso cria o dilema identificado por Caetano et al.: o pesquisador **precisa** de Z para PT, mas Z é bad control (mediador contemporâneo).

### 9.2 O ADL com Z_{t-1} resolve o dilema

Os resultados da variante mediator_confounder mostram:

| Modelo | Coef D | Interpretação |
|---|---|---|
| adl_DYlag (sem Z) | 1.09-1.11 | PT condicional violada → OVB |
| adl_DYlag_Z (com Z_t) | 1.00-1.02 | PT satisfeita, mas over-control → bloqueia indireto |
| **adl_all (com Z_{t-1})** | **1.03** | **PT satisfeita via Z_{t-1}, sem over-control** |

A estrutura temporal do TSCS **separa os dois papéis de Z**:

- **Z_{t-1}** (defasado): satisfaz PTA condicional (remove confounding). Papel de confounder.
- **Z_t** (contemporâneo): seria bad control (over-control do canal indireto). Não é incluído no ADL.

### 9.3 Contraste com DID de 2 períodos

No DID canônico (2 períodos), essa separação **não existe**. O pesquisador só tem Z_{t*} contemporâneo:

- Incluir Z_{t*}: satisfaz conditional PT mas gera over-control (bloqueia D → Z → Y)
- Excluir Z_{t*}: evita over-control mas viola conditional PT (OVB)

O dilema é real e inescapável no DID sem dinâmica — é exatamente o que motiva os métodos de Caetano et al. (doubly robust, AIPW, imputation).

### 9.4 Implicação para o paper

Este é um **resultado forte para o framing do paper**: o ADL com Z_{t-1} é a solução natural para “conditional PT with bad control” no setting TSCS. Funciona porque lags separam confounder de bad control temporalmente.

A formulação precisa:

> Em TSCS, quando PTA só vale condicional em Z e Z é simultaneamente mediador contemporâneo, o ADL com Z_{t-1} satisfaz a PTA condicional (controlando confounding via lag) sem incorrer em over-control contemporâneo (porque Z_{t-1} não intercepta o caminho D_t → Z_t → Y_t). Essa separação temporal é uma vantagem estrutural do setting TSCS sobre o DID canônico de 2 períodos.

### 9.5 Qualificações

- O resultado depende do **estimando ser o CET** (efeito contemporâneo de D_t sobre Y_t). Para efeitos defasados ou cumulativos, Z_{t-1} pode ser post-treatment e o argumento de timing não se aplica.
- O resultado assume que o DAG é conhecido (o pesquisador sabe que Z é mediador e/ou confounder). Se a classificação estiver errada, a recomendação pode ser inadequada.
- Não temos prova formal de que o viés residual sob NL é negligível em geral — temos o argumento de d-separation (para collider) e timing (para mediador), verificados numericamente em DGPs específicos. A conjectura de generalidade é razoável mas não provada.

---

## 10. Conclusão

Os dois relatórios contam a mesma história, cada um cobrindo uma parte diferente do terreno:

- o primeiro mostra com nitidez o mecanismo do mediador
- o segundo mostra que a conclusão sobre `Z_{t-1}` continua válida quando o controle também exerce papel de confounder via lags

A conexão com PTA condicional fecha o argumento: o ADL com Z_{t-1} é a solução natural para o dilema “preciso de Z para PT, mas Z é bad control” no setting TSCS. Essa separação temporal é uma vantagem estrutural sobre o DID de 2 períodos.

Recomendação central para o paper:

> Em TSCS, quando o estimando é o CET, use ADL com Z_{t-1}. Isso evita over-control contemporâneo, resolve collider bias (por d-separation), satisfaz PTA condicional (controlando confounding via lag), e resolve o caso dual role. O resultado é robusto sob linearidade (exato, via fórmula IVB) e sob não-linearidade bounded e unbounded (verificado numericamente em 200+ cenários MC). A conjectura é que o resultado é geral.
