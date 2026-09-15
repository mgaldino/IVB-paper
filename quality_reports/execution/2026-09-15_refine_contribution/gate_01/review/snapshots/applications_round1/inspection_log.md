# Log de inspeção e validação

## Fronteira

Esta tarefa leu documentação e esquemas. Escreveu somente `gate_01/applications/`. Não editou manuscrito, scripts, dados ou outputs. Não executou R, Stata, regressões, IVB, shifts, bootstrap, p-valores ou estatísticas descritivas dos dados.

## Sequência auditável

1. Foram lidos `CLAUDE.md`, o Gate 1 do plano, o recibo de aprovação do Gate 0 e o roster do acervo.
2. `protocol.json` e `protocol.md` foram escritos com E1–E7, classes e regras de parada/seleção.
3. Os dois arquivos foram hasheados antes da leitura integral das três candidatas. Os digests estão em `protocol_freeze.md` e foram reconferidos ao final.
4. PDFs primários foram convertidos com `pdftotext -layout` para arquivos temporários em `/tmp`; os temporários não foram incorporados ao repositório.
5. Scripts primários foram lidos com `sed`, `rg` e `nl -ba`, somente para variáveis, timing, amostra, FE, lags e covariância.
6. Os cabeçalhos dos TAB foram lidos sem linhas de dados. Metadados dos DTA foram acessados com `pandas.io.stata.StataReader.variable_labels()` para confirmar rótulos de D, Y, Z, país e tempo; nenhuma linha foi carregada para análise.
7. SHA256 das fontes foram calculados com `shasum -a 256` e registrados em `sources_manifest.csv`.
8. O JSON foi validado com a biblioteca padrão do Python; o CSV foi lido por `csv.DictReader`, confirmando 18 linhas e digests de 64 caracteres.
9. `git diff --check` e `git status` foram usados para verificar formatação e escopo. Como os arquivos são novos e não rastreados, `git diff` não exibe seu conteúdo; a validação substantiva deve ler os arquivos diretamente.

## Incidentes sem alteração de estado

- `jq` não está instalado; a validação JSON foi repetida com `python3` e passou.
- `pyreadstat` não está instalado; a tentativa falhou antes de ler qualquer DTA. O fallback com `pandas.io.stata.StataReader` leu apenas metadados.
- Uma primeira chamada ao leitor Stata tentou um método `close()` inexistente depois de imprimir os rótulos do primeiro arquivo. Nenhum dado foi alterado; a segunda chamada leu os rótulos do segundo arquivo sem esse método.
- Alguns arquivos com extensão `.pdf` do acervo são snapshots HTML. Eles não foram usados como fonte primária das fichas; foram usados os PDFs válidos listados no manifesto.
- Ao abrir o roster do Gate 0, a saída incluiu colunas numéricas proibidas. O incidente, seu efeito sobre a certificação de cegamento e a mitigação por revisão independente estão em `selection.md`.

## Verificações finais executadas

```text
JSON: IVB-G1-APPLICATIONS-2026-09-15-v1; 7 critérios; válido
CSV: 18 fontes; cabeçalho esperado; todos os SHA256 com 64 caracteres
Protocol hashes: idênticos aos digests congelados
git diff --check: sem erro reportado
escopo Git: somente o diretório applications aparece como novo nesta frente
```

As fichas ainda não receberam revisão independente. O implementador desta frente não as aprova.
