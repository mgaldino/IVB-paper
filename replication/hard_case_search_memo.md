# Q&A

1. **Encontrei um caso melhor que Kronick para virar aplicação principal?**  
Sim, encontrei um candidato melhor em termos de dificuldade conceitual: **Jensen (2025), “Educating for Democracy? Going to College Increases Political Participation”**, no *British Journal of Political Science*.

2. **Ele é melhor em que sentido?**  
Porque combina:

- tratamento não escalonado;
- DiD com dois períodos;
- comparação explícita entre modelos com e sem controles pós-tratamento;
- controles time-varying que são muito mais plausivelmente mediadores/colliders do que `ln_pob` na Kronick;
- dados replicáveis em Harvard Dataverse.

3. **Ele é perfeito?**  
Não. O movimento empírico entre os modelos com e sem controles pós-tratamento parece moderado, não gigantesco. Então ele é um caso claramente mais difícil **conceitualmente**, mas ainda não é um “smoking gun” óbvio de `IVB_post` enorme.

4. **Encontrei um caso ainda melhor, com shift grande e desenho totalmente limpo?**  
Ainda não. Não encontrei, nesta rodada, um paper com tratamento claramente binário e não escalonado, dados replicáveis e uma mudança claramente grande entre `safe` e `contaminado`.

# Critérios usados na busca

O objetivo foi achar uma aplicação que maximizasse:

1. tratamento não escalonado;
2. DiD verdadeiro, preferencialmente com um choque comum no tempo;
3. presença explícita de controles time-varying potencialmente problemáticos;
4. possibilidade de construir um bloco `safe` com informação pré-tratamento;
5. replicação pública.

# Ranking atual

## 1. Jensen (2025) — melhor candidato para a próxima replicação

**Referência**  
Andreas Videbæk Jensen. “Educating for Democracy? Going to College Increases Political Participation.” *British Journal of Political Science* (2025). DOI: `10.1017/S0007123424000486`.  
Dados: Harvard Dataverse, DOI `10.7910/DVN/PZCP0B`.

**Por que encaixa bem**

- desenho com dois períodos (`2004` e `2008`);
- tratamento não escalonado: frequentar faculdade entre esses dois pontos;
- o autor estima modelos com e sem controles pós-tratamento;
- os controles são extremamente plausíveis como mediadores ou colliders do efeito da faculdade sobre comparecimento eleitoral.

**Controles time-varying usados pelo paper**

O artigo informa que eles incluem:

- mobilidade residencial;
- morar com os pais;
- casar;
- vitimização por crime;
- adoecer ou ficar incapacitado;
- perder emprego;
- ter filhos;
- divórcio dos pais;
- perda de emprego dos pais;
- doença séria na família;
- morte dos pais;
- morte de parente ou amigo.

Esses controles são quase um catálogo de más covariáveis potenciais, porque a faculdade pode alterar vários desses eventos, e esses eventos também podem afetar participação política.

**Bloco `safe` já presente**

O paper também usa ajustes com informação pré-tratamento:

- `pre-college voting × time FE`;
- em algumas especificações, `time FE ×` habilidades cognitivas pré-tratamento, gênero, raça, educação e renda dos pais;
- matching em características pré-tratamento.

Ou seja, ele já está muito perto da arquitetura que interessa ao paper: `safe` primeiro, controles realizados depois.

**Mudanças de coeficiente reportadas**

Na Tabela 1 do artigo:

- modelo restrito sem controles pós-tratamento: `0.096`
- modelo restrito com controles pós-tratamento: `0.106`
- modelo restrito com controles pós-tratamento + trends em covariáveis pré-tratamento: `0.089`
- modelo matched sem controles pós-tratamento: `0.116`
- modelo matched com controles pós-tratamento: `0.101`

Portanto, o deslocamento existe, mas não é enorme. Ainda assim, este é o melhor caso encontrado até agora para uma análise aplicada de `safe vs contaminated control`.

**Leitura**

Jensen parece um caso em que:

- o problema de identificação é real;
- o autor tem consciência explícita do risco de post-treatment bias;
- há desenho limpo e dados replicáveis;
- o paper pode agregar clareza e decomposição formal.

## 2. Carcelli e Park (2024) — excelente caso de bad control, mas pior ajuste ao seu desenho

**Referência**  
Shannon Carcelli e Kee Hyun Park. “Partisanship in the Trump Trade War: Evidence from County-Level Crop Planting Data.” *International Studies Quarterly* 68(4), 2024. DOI: `10.1093/isq/sqae141`.

**Por que é interessante**

- os autores discutem explicitamente que `MFP payments` são um controle pós-tratamento;
- reportam que incluir esses pagamentos não altera muito os resultados;
- também fazem análise de mediação;
- os dados estão no ISQ Dataverse.

**Por que não é o melhor caso para você**

- o “tratamento” é mais um choque comum interagido com exposição política (`Trump vote share`) do que um grupo binário tratado/controle;
- o desenho é menos próximo do seu caso canônico de DiD não escalonado com grupos tratados e controle bem definidos.

**Leitura**

É um ótimo caso para mostrar consciência aplicada sobre bad controls. Mas, como aplicação principal do paper, ele é inferior ao Jensen.

# Conclusão provisória

## Melhor escolha agora

Se o objetivo é achar uma aplicação principal **mais difícil que Kronick**, eu seguiria com **Jensen (2025)**.

## Melhor papel da Kronick

Kronick continua muito útil, mas como:

- caso-ponte;
- apêndice forte;
- ou exemplo de “good behavior” do framework.

## Lacuna que ainda resta

Ainda não encontrei um caso que reúna, ao mesmo tempo:

- tratamento binário e não escalonado;
- controles time-varying claramente ruins;
- mudança grande da estimativa ao incluir esses controles;
- replicação pública pronta.

Se esse for o padrão exigido, a busca precisa continuar.

# Recomendação operacional

1. Próxima replicação: **Jensen (2025)**.  
2. Carcelli e Park (2024): manter como reserva.  
3. Se Jensen também entregar apenas ganho marginal, então a estratégia mais promissora passa a ser:

- usar Kronick ou Jensen como aplicação curta;
- e deixar a contribuição principal vir da simulação calibrada.
