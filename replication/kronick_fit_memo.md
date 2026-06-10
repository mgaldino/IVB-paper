# Q&A

1. **A aplicação da Kronick deve entrar no texto principal?**  
Provavelmente não como aplicação principal. O melhor uso é como caso-ponte, em apêndice ou em uma seção curta de ilustração.

2. **Por quê?**  
Porque os autores já fizeram a coisa substantivamente correta: separaram um ajuste baseado em informação pré-tratamento (`ano × população de 1990`) do mero uso de um controle time-varying realizado (`ln_pob`).

3. **O que o nosso framework acrescenta, então?**  
Clareza conceitual e decomposição quantitativa:
   - `OVB_safe = 15.97 - 6.68 = 9.30`
   - `IVB_post(ln_pob) = 6.76 - 6.68 = 0.08`

4. **Qual é a conclusão?**  
Kronick (2020) é um caso de bom comportamento para o paper: mostra que o framework não serve apenas para denunciar controles ruins, mas também para mostrar quando o medo do controle pós-tratamento é pequeno depois de construir um bloco `safe` adequado.

# Diagnóstico

Na replicação em [kronick_ivb_report.pdf](/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/replication/kronick_ivb_report.pdf), o grande deslocamento da estimativa vem de passar do modelo sem ajuste adicional para o modelo com `ano × população de 1990`.

- Sem ajuste adicional: `15.97`
- Bloco `safe`: `6.68`
- `safe + ln_pob`: `6.76`

Isso implica:

- o custo de **não** ajustar para heterogeneidade de tendência por porte municipal é grande;
- o custo adicional de incluir `ln_pob` realizado é pequeno;
- a narrativa empírica do artigo original já está bem alinhada com o que o paper defenderia.

# O que os autores teriam feito de diferente se tivessem lido o paper

Eles provavelmente não mudariam a conclusão substantiva. O que mudaria seria a apresentação da estratégia.

Em vez de tratar a coluna com `ln_pob + ano × população de 1990` como uma única robustez, eles provavelmente teriam:

- destacado o bloco `safe` como o principal ajuste;
- separado explicitamente `omitido -> safe` de `safe -> contaminado`;
- interpretado `ln_pob`, `pol_local` e `alc_oficialista` como controles potencialmente contaminados, e não apenas como covariáveis adicionais;
- mostrado a identidade `IVB = -theta*pi` para cada controle incluído após o bloco `safe`.

# Recomendação

Usar Kronick como:

- **apêndice forte**, se o objetivo for mostrar um caso em que o framework melhora a interpretação, mas não reverte o resultado;
- **ponte narrativa curta no texto principal**, se você quiser enfatizar que o framework também produz diagnósticos tranquilizadores;
- **não** como principal aplicação empírica do paper, se a ambição for mostrar um caso em que a inclusão de controles pós-tratamento realmente cria um problema grande.

# Próximo passo

O caso principal ideal para o paper deve ter três propriedades:

1. tratamento claramente não escalonado;
2. controles time-varying claramente plausíveis como mediadores/colliders/confounders;
3. uma mudança mais substantiva entre o modelo `safe` e o modelo com controles realizados.
