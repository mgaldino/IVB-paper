# Adendo de correspondência com o efeito contemporâneo (CET)

**Data:** 15 de setembro de 2026, depois da triagem inicial e da adjudicação da rodada 1  
**Estado:** explicitação posterior exigida pelo plano; não preespecificada antes da leitura das candidatas  
**Efeito sobre o protocolo v1:** nenhum. E1–E7, classes e hashes congelados permanecem intactos.

## Por que este adendo existe

O protocolo v1 pergunta se uma comparação documental pode ser reconstruída. O plano do Gate 1 também exige que a aplicação corresponda ao efeito contemporâneo (CET). A rodada inicial tratou a passagem literal de E1–E7 como suficiente para escolher principal e reserva, embora os desenhos examinados medissem respostas futuras. A adjudicação R1-F001 confirmou essa lacuna.

Este adendo cria um **campo adicional de correspondência**, separado da classe literal. Ele não retroage como critério congelado nem transforma um PASS literal em FAIL.

## Requisitos adicionais para receber papel CET

Uma candidata só pode ser principal ou reserva CET se as fontes documentarem conjuntamente:

1. **intervenção atual em tempo físico:** o evento, estado ou mudança de D que define o período de intervenção, com unidade e data/intervalo;
2. **janela contemporânea de Y:** o outcome e sua referência temporal dentro da janela associada à intervenção atual;
3. **trajetória do tratamento:** persistência, revisão, retirada ou mudança de D entre intervenção e mensuração de Y;
4. **ordem de Z:** história de Z termina antes da intervenção e Z atual tem período de referência ordenável em relação a D e Y;
5. **estimando declarado:** efeito contemporâneo total, efeito direto ou projeção descritiva/futura são distinguidos; a inclusão de Z atual não escolhe o estimando por si.

## Regra de indexação

Uma mudança de origem algébrica não altera o tempo físico:

```text
D[t-2] -> Y[t]  continua uma resposta dois períodos depois de D.
D[t-1] -> Y[t]  continua uma resposta um período depois de D.
```

Chamar o período de D de “zero” apenas reescreve esses objetos como `D[0] -> Y[2]` e `D[0] -> Y[1]`. Nenhum deles se torna CET sem uma definição substantiva adicional de intervenção e janela.

## Estados permitidos neste adendo

- `ESTABLISHED`: os cinco requisitos acima estão documentados.
- `NOT_ESTABLISHED`: a fonte documenta outra janela ou deixa requisitos essenciais sem demonstração.
- `ORIGINAL_ASSUMPTIONS_EXCLUDE_CONTEMPORANEOUS_SUPPORT_EFFECT`: o desenho original exclui afirmativamente o CET de apoio relevante.
- `NOT_ASSESSED`: candidata não triada para correspondência CET.

Esses estados não substituem `ELIGIBLE_DOCUMENTARY`, `HOLD_DOCUMENTATION`, `INELIGIBLE_DEMONSTRATED` ou `NOT_SCREENED`.

## Aplicação aos três casos já lidos

| candidata | classe literal E1–E7 | estado CET | fundamento |
|---|---|---|---|
| Blair et al. | `ELIGIBLE_DOCUMENTARY` | `NOT_ESTABLISHED` | mandato em `t-2` e democracia em `t`; trajetória do mandato e janela contemporânea não demonstradas |
| Ballard-Rosa et al. | `HOLD_DOCUMENTATION` | `NOT_ESTABLISHED` | estado partidário em `t-1` e emissão em `t`; exposição é nível em exercício, além da falta de timing da crise |
| Claassen | `HOLD_DOCUMENTATION` | `ORIGINAL_ASSUMPTIONS_EXCLUDE_CONTEMPORANEOUS_SUPPORT_EFFECT` | o paper assume ausência de efeito contemporâneo de apoio sobre democracia |

**Conclusão:** nenhuma candidata examinada satisfaz o campo adicional. Não há principal ou reserva CET aprovada. Uma busca adicional ou a adoção de uma rota descritiva/futura depende de escolha posterior do autor.
