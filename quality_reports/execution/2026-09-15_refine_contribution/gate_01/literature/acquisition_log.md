# Aquisição dos textos integrais

Data: 15 de setembro de 2026. Esta aquisição começou como preparação de insumos durante o fechamento documental do Gate 0; não contém decisão científica do Gate 1.

## Arquivos obtidos

- Blackwell e Glynn: `references_pdfs/causal-tscs.pdf`, já existente, 16 páginas. DOI editorial: <https://doi.org/10.1017/S0003055418000357>. Texto extraído em `sources/blackwell_glynn_fulltext.txt`; versão e leitura integral serão confirmadas pelo leitor.
- Cinelli, Forney e Pearl: PDF público dos autores, 30 páginas, com data interna de 21 de março de 2022. URL: <https://carloscinelli.com/files/Cinelli%20et%20al%20(2020)%20-%20A%20Crash%20Course%20in%20Good%20and%20Bad%20Controls.pdf>. Arquivo `sources/cinelli_forney_pearl_2022.pdf` e texto extraído em `sources/cinelli_forney_pearl_fulltext.txt`.

Os hashes estão no manifesto de aquisição. Download e extração não equivalem a leitura integral.

## Gelbach: busca ainda sem cópia integral legível

1. A página do editor confirma o artigo de 2016, Journal of Labor Economics 34(2), 509–543, DOI 10.1086/683668. Tanto a consulta web quanto o navegador mostram resumo e exigência de assinatura para o texto integral. O pedido direto de PDF retornou HTTP 403. O link PDF de acesso bibliográfico exibido na página retornou ao resumo; não comprovou acesso integral.
2. A página pública do SSRN, <https://papers.ssrn.com/sol3/papers.cfm?abstract_id=1425737>, identifica uma versão de 28 de agosto de 2014, 40 páginas, revisada em 16 de setembro de 2014. A consulta por navegador abriu a página e o fluxo público de download sem cadastro. Uma navegação produziu URL temporária de arquivo, mas não um PDF exportável/legível pelas ferramentas disponíveis. Tentativas posteriores retornaram à página de cadastro opcional e ao item. Não houve cadastro ou alteração de conta. URLs temporárias com tokens não são preservadas neste registro.
3. O download direto pelo link de entrega do SSRN retornou HTTP 403. `content.export()` não é suportado no navegador em uso. A ação de download não produziu arquivo localizado em Downloads ou diretórios temporários consultados. Não se considera o arquivo obtido.
4. Três cópias indexadas do CiteSeerX (identificadores `54eb8ed0782496883dca8846c34b17375716aeac`, `20072bd40224282510f7fe08405e21155596154b` e `011679a3b5a41f7d8802c5c649a4ad99b96fce89`) redirecionaram para cópias arquivadas indisponíveis/404. O texto parcial do índice não foi usado como leitura integral.
5. O programa de seminários de Duke de 2012 aponta para <https://ipl.econ.duke.edu/seminars/system/files/seminars/222.pdf>, mas esse arquivo retorna 404. A página pessoal do autor não forneceu uma cópia acessível. RePEc encaminha ao editor com restrição de assinatura.
6. A busca por nomes de arquivos em Documents/Downloads não localizou Gelbach. A skill Zotero confirmou API local ativa; buscas por título e por `Gelbach` retornaram listas vazias. Não houve modificação da biblioteca.
7. A consulta de disponibilidade ao Internet Archive para o antigo working paper do Arizona retornou HTTP 429. Não foi repetida após esse limite; o arquivo não foi obtido.
8. Uma busca final localizou o registro primário do JSTOR, <https://www.jstor.org/stable/26553211>. A página confirma 35 páginas, 509–543. O PDF público redireciona ao registro. No navegador, a opção gratuita de leitura abre um formulário de criação de conta; a outra opção exige acesso institucional. Nenhuma conta foi criada e nenhum login foi realizado. Esse caminho forneceu metadados e resumo, sem leitura integral.

Foi solicitada ao autor a indicação de uma eventual cópia local. A solicitação não interrompe trabalho independente. Enquanto o texto integral não for obtido, nenhuma conclusão de novidade será baseada somente no resumo; a limitação deve constar do estado e do confronto bibliográfico. Não foram usados meios de contornar assinatura, autenticação ou bloqueios de acesso.

## Fonte primária adicional obtida: software do autor

O registro SSC/RePEc S457814 (<https://ideas.repec.org/c/boc/bocode/s457814.html>) aponta para código e ajuda de `b1x2`, escritos por Jonah Gelbach e disponibilizados sob GPL v3. Ambos foram baixados do servidor público de Boston College (`http://fmwww.bc.edu/repec/bocode/b/b1x2.ado` e `.sthlp`) e guardados em `sources/`. A documentação enumera decomposição, matriz de covariância, heterocedasticidade e clustering. Os arquivos serão lidos como evidência primária das capacidades do software existente; não substituem o artigo integral. Nenhum código Stata foi instalado ou executado.
