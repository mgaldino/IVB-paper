# Leitura fiel da Seção 7 — Conclusion

**Leitor:** `read_applications`  
**Escopo:** `ivb_paper_pa.Rmd:824–832`.

## Tese e claims

| Claim | Localizador | Escopo/hedge |
|---|---|---|
| Em modelos lineares aninhados de TSCS, $\widehat\Delta_Z$ tem decomposição fechada que quantifica tamanho e direção da mudança. | Rmd 826 | Não decide admissibilidade nem mede, por si, viés causal; requer CET, DAG temporal, timing e identificação. |
| Para o CET, ADL + FE com estados defasados é uma linha de base condicional. | Rmd 828 | Exige relógio causal, história suficiente, exchangeability, suporte, dinâmica plausível, ausência de interferência relevante e controle do viés em $T$ finito. As simulações cobrem apenas os DGPs exibidos. |
| A contribuição combina diagnóstico descritivo e linha de base TSCS condicional. | Rmd 830 | O diagnóstico mede movimento entre regressões; a linha de base estrutura a comparação sob as condições do CET. |
| O domínio desenvolvido é TSCS linear. | Rmd 832 | A linha de base é local ao CET; não linearidade cobre cenários testados, e confounding contemporâneo não observado pode deixar viés. |

## Não-afirmações explícitas

O paper não afirma que a identidade determine admissibilidade ou que a mudança seja automaticamente viés causal. As simulações não estabelecem ADL + FE como estimador causal fora das condições declaradas. Uma covariável defasada pode responder ao tratamento para efeitos distribuídos, cumulativos ou longos. Não reivindica resultados para controle sintético, synthetic DID, modelos fatoriais, regimes de tratamento ou links não lineares.
