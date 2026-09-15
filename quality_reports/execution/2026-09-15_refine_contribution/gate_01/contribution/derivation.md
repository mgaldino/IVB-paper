# Derivação e teste justo do acréscimo proposto

**Versão:** 15/09/2026, `gate1_contribution`. **Base:** ficha congelada v2. **Status:** derivação do designer, sem revisão independente ou teste numérico pelo designer. Os resultados desta nota não constituem nova versão do manuscrito.

## 1. Pergunta e domínio exato

A pergunta é se separar uma troca entre covariáveis, mantendo a mesma informação causal, acrescenta uma capacidade ao comparador FWL. Primeiro demonstramos o que esse comparador calcula. Depois construímos os dois exemplos da ficha. Por fim delimitamos o que a equivalência diz sobre inferência e originalidade.

O domínio é OLS sem pesos, mesma amostra e transformação, regressoras de posto completo e tratamento residual com soma de quadrados positiva. A prova é amostral. Sua versão populacional substitui produtos internos por esperanças sob momentos de segunda ordem finitos e matriz de momentos não singular. Nenhuma passagem identifica um efeito causal sem hipóteses adicionais. A prova não identifica o limite do estimador within com T fixo e não estende automaticamente OLS a GMM, estimadores corrigidos ou penalizados.

## 2. Uma inclusão aninhada, passo a passo

Sejam `X` as regressoras comuns, incluindo intercepto, `d` o tratamento e `z` o bloco acrescentado. Defina a projeção residual `M_X = I - X(X'X)^(-1)X'`. Escreva `d_tilde=M_X d`, `z_tilde=M_X z` e `y_tilde=M_X y`.

O modelo longo residualizado é

\[
\widetilde y=\widetilde d\widehat\beta_L+
\widetilde z\widehat\theta+\widehat e_L.
\tag{1}
\]

As equações normais de OLS dão `d_tilde' e_L=0`: o resíduo é ortogonal a cada regressor incluído. Multiplicar (1) por `d_tilde'/(d_tilde'd_tilde)` portanto produz

\[
\frac{\widetilde d'\widetilde y}{\widetilde d'\widetilde d}
=\widehat\beta_L+
\frac{\widetilde d'\widetilde z}{\widetilde d'\widetilde d}\widehat\theta.
\tag{2}
\]

O lado esquerdo é `beta_S`, pelo OLS do modelo curto após residualizar X. O vetor linha no segundo termo contém os coeficientes de d nas auxiliares de cada coluna de z sobre d e X; denote sua transposta por `pi`. Subtrair `beta_S` dos dois lados dá

\[
\widehat\beta_L-\widehat\beta_S=-\widehat\pi'\widehat\theta.
\tag{3}
\]

Cada passagem usa a mesma amostra. A correlação entre colunas de z não invalida (3): seus coeficientes `theta` vêm do modelo longo conjunto. A soma dos produtos por coordenada é uma decomposição condicional de projeções. Não é preciso supor controles mutuamente independentes nem somar regressões marginais de Y em cada controle. Essa é precisamente a capacidade que não pode ser retirada do comparador.

## 3. Substituição pelo modelo de união

Use as regressoras `B=(d,W,L)`, `C=(d,W,Z)` e `U=(d,W,L,Z)`. A adição de Z a B usa `X=(W,L)` em (3); a adição de L a C usa `X=(W,Z)`. Logo,

\[
d_{add}=\widehat\beta_U-\widehat\beta_B
=-\widehat\theta_{Z,U}'\widehat\pi_{Z\mid W,L},
\tag{4}
\]

\[
d_{lag}=\widehat\beta_U-\widehat\beta_C
=-\widehat\theta_{L,U}'\widehat\pi_{L\mid W,Z}.
\tag{5}
\]

Subtraindo (5) de (4), o coeficiente de U cancela:

\[
\widehat\beta_C-\widehat\beta_B=d_{add}-d_{lag}.
\tag{6}
\]

O percurso `B -> U -> C` inclui Z e depois retira L; por isso a parcela assinada de retirada é **`-d_lag`**. Se ela tiver o sinal oposto a `d_add`, os movimentos podem se compensar. A identidade (6) é diferença de dois passos conhecidos. O comparador não necessita que Gelbach tenha escolhido a mesma aplicação temporal num exemplo de seu artigo para poder calculá-la.

Há outro percurso pela interseção `A=(d,W)`: `B -> A -> C`. Ele dá `(beta_A-beta_B)+(beta_C-beta_A)`, o mesmo total. Em geral atribui números distintos a cada passo porque altera o conjunto condicionado. O caminho via U é uma escolha operacional útil: primeiro mede a inclusão atual preservando a história. Essa utilidade não o transforma numa alocação causal única.

O modelo de união precisa existir. Se L e Z tornam o tratamento colinear, beta_U pode não estar definido mesmo quando B e C individualmente têm coeficientes estimáveis. Nesse caso, (4)–(6) como decomposição identificada via U não estão disponíveis a nenhum dos dois procedimentos. Recusar esse cálculo é uma propriedade necessária de implementação, não uma vantagem científica exclusiva.

## 4. O que se segue para a comparação forte

O comparador C+ da ficha ajusta exatamente os modelos e auxiliares das equações (4)–(5). A proposta P ajusta esses mesmos modelos. Para qualquer amostra de posto completo, ambos obtêm o mesmo vetor de coeficientes e os mesmos contrastes, ressalvadas diferenças de precisão numérica. A conclusão é **construtiva para a rotina testada**: foi especificado um algoritmo de C+ que reproduz P sem ler seus outputs.

Não se trata da afirmação tautológica de que um comparador onipotente reproduz qualquer método concebível. O algoritmo aqui é pequeno e explícito: três modelos, duas auxiliares e duas aplicações FWL. Nada prova que uma futura regra de história, garantia inferencial ou algoritmo adicional seria automaticamente equivalente. Essa capacidade adicional precisa ser apresentada e confrontada, não presumida existente ou impossível.

Se a etapa causal de P aplica um conjunto de hipóteses a esses outputs e C+ recebe esse mesmo conjunto, C+ pode aplicar a mesma etapa. Uma diferença decorrente de fornecer o DAG correto apenas a P seria ganho de informação, não ganho da decomposição. Um certificado causal que exige informação ausente dos dois é inválido, qualquer que seja o tamanho do shift.

## 5. E1: contas explícitas da troca

As equações congeladas são

\[
L=e_L,\quad D=L+e_D,\quad Z=D+e_Z,\quad
Y=qD+bL+rZ+e_Y,
\tag{7}
\]

com erros independentes, gaussianos, centrados e de variância 1. Sua ordem é `L < D < Z < Y`. A independência garante que não há confundimento omitido nas equações estruturais. Substituindo a equação de Z na de Y sob intervenção em D,

\[
Y(d)=(q+r)d+bL+r e_Z+e_Y.
\tag{8}
\]

Portanto o efeito total por unidade de D é `q+r`, inclusive condicional em L. Não se obtém esse resultado da regressão; ele vem da intervenção na estrutura conhecida.

### 5.1 Coeficiente de B

Substituir Z em (7) na distribuição observada dá `Y=(q+r)D+bL+r e_Z+e_Y`. O erro composto é ortogonal a D e L pela independência dos erros. As equações normais populacionais de B são satisfeitas com

\[
\beta_B=q+r.
\tag{9}
\]

Assim B identifica o efeito total em toda essa classe, sob as hipóteses declaradas.

### 5.2 Coeficiente de U e primeira auxiliar

No modelo U, a equação de Y já é a média condicional correta, com erro e_Y ortogonal a D, L e Z. Logo `beta_U=q`, `theta_L,U=b` e `theta_Z,U=r`. Como `Z=D+e_Z`, a auxiliar de Z em D e L tem coeficiente 1 em D e 0 em L. Aplicar (4) produz `d_add=-r`.

### 5.3 Segunda auxiliar e coeficiente de C

A matriz de momentos de `(L,D,Z)` segue diretamente de (7):

\[
\Sigma_{L,D,Z}=
\begin{pmatrix}1&1&1\\1&2&2\\1&2&3\end{pmatrix}.
\tag{10}
\]

Para obter o coeficiente de D na regressão de L em D e Z, inverter a matriz 2×2 dos regressores dá

\[
\pi_{L\mid Z}=
\frac{\operatorname{Cov}(L,D)\operatorname{Var}(Z)
-\operatorname{Cov}(L,Z)\operatorname{Cov}(D,Z)}
{\operatorname{Var}(D)\operatorname{Var}(Z)
-\operatorname{Cov}(D,Z)^2}
=\frac{1\cdot3-1\cdot2}{2\cdot3-2^2}=\frac12.
\tag{11}
\]

O denominador é 2, portanto positivo. O coeficiente de Z nessa auxiliar é zero. A equação (5) resulta em `d_lag=-b/2`; como `d_lag=beta_U-beta_C`, segue `beta_C=q+b/2`.

### 5.4 Resultados analíticos a verificar

| Célula | CET total | beta_B | beta_U | beta_C | d_add | -d_lag, retirada | d_total | Compensação pela ficha |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| E1-central | 1 | 1 | 1/2 | 1 | −1/2 | 1/2 | 0 | Sim |
| E1-menos | 1 | 1 | 1/2 | 9/10 | −1/2 | 2/5 | −1/10 | Sim |
| E1-mais | 1 | 1 | 1/2 | 11/10 | −1/2 | 3/5 | 1/10 | Sim |
| E1-nulo | 1 | 1 | 1 | 1 | 0 | 0 | 0 | Não |

Nas três primeiras células, cada passo tem módulo pelo menos 1/4, o total tem módulo no máximo 1/8 e os passos têm sinais opostos. No caso nulo, nenhum passo é material. Esses números são derivados analiticamente; o teste R independente deve produzir seus próprios coeficientes a partir das linhas ou momentos, não copiá-los da tabela.

Na célula central, **beta_C é realmente igual ao CET**. Seria falso chamá-lo numericamente enviesado nesse ponto. A igualdade, porém, exige `b/2=r`; mover b para 4/5 ou 6/5, sem mudar a estrutura causal ou o efeito total, produz diferenças −1/10 e +1/10. Portanto a regra de substituir L por Z não preserva identificação do CET na classe fornecida. A proposta e o comparador com o mesmo DAG chegam à mesma conclusão.

O ganho sobre um relatório restrito aos endpoints é tornar visíveis os dois passos. O par de endpoints sozinho não os identifica: na família `q=1-r, b=2r`, ambos permanecem iguais a 1, enquanto os passos valem `-r` e `+r`. Essa observação não é impossibilidade informacional para C0 nesta tarefa, pois ele também recebe as equações e momentos e poderia usá-los. A v2 registra sua omissão como campo não reportado, sem escore de fracasso.

### 5.5 Por que o fixture não é simulação

Os oito vetores binários e as quatro colunas de sinais da ficha têm médias zero. O produto de duas colunas distintas é outro contraste não constante e soma zero sobre os oito vetores; o quadrado de cada coluna soma oito. Assim `E_fixture' E_fixture/8=I`. Como os regressores e Y são combinações lineares dessas colunas, seus momentos de segunda ordem coincidem exatamente com os usados em (10). OLS recupera as projeções da tabela por álgebra.

A quarta coluna é produto de duas outras; portanto **não** se reivindica independência distributiva das colunas do fixture. A independência pertence à população gaussiana usada para justificar a interpretação causal. O suporte finito serve apenas para verificar os cálculos lineares com momentos exatos. Não é teste de cobertura ou amostra extraída de um estudo.

## 6. E2: mesma distribuição, efeitos diferentes

No sistema de mediação `G_M`,

\[
D=e_D,\quad Z=D+e_Z,\quad Y=D+Z+e_Y
=2e_D+e_Z+e_Y.
\tag{12}
\]

Os três erros têm variância 1 e são gaussianos independentes. Logo, na ordem `(D,Z,Y)`,

\[
\Sigma_M=\begin{pmatrix}1&1&2\\1&2&3\\2&3&6\end{pmatrix}.
\tag{13}
\]

Por exemplo, `Cov(Z,Y)=Cov(e_D+e_Z,2e_D+e_Z+e_Y)=2+1=3`, e `Var(Y)=4+1+1=6`. Intervir em D deixa a resposta de Z ativa: `Y(d)=2d+e_Z+e_Y`. Assim o CET total é 2.

No sistema de confundimento `G_F`,

\[
Z=u_Z,\quad D=Z/2+u_D,\quad Y=D+Z+u_Y
=3u_Z/2+u_D+u_Y,
\tag{14}
\]

com variâncias `(2,1/2,1)` para `(u_Z,u_D,u_Y)`. A variância de D é `2/4+1/2=1`, `Cov(D,Z)=2/2=1`, `Var(Y)=9·2/4+1/2+1=6`, `Cov(D,Y)=3·2/4+1/2=2` e `Cov(Z,Y)=3·2/2=3`. Portanto `Sigma_F=Sigma_M`. As médias também são zero e os sistemas são gaussianos; **a distribuição conjunta observável é idêntica**, não apenas alguns momentos. O determinante da matriz comum é 1, de modo que o exemplo não depende de colinearidade.

Intervir em D no segundo sistema rompe a equação de assignment de D e mantém Z: `Y(d)=d+u_Z+u_Y`. O CET total é 1. Assim nenhuma função dos dados observados pode selecionar entre CET 1 e CET 2 quando a informação comum permite ambos os sistemas.

As regressões são as mesmas sob ambas as distribuições. O modelo curto tem

\[
\beta_S=\operatorname{Cov}(D,Y)/\operatorname{Var}(D)=2.
\tag{15}
\]

No longo, a equação `Y=D+Z+erro` tem erro ortogonal a ambos os regressores em cada sistema; logo `beta_T=1`, `theta=1`. A auxiliar de Z em D tem `pi=1`; portanto `Delta=1-2=-1=-theta*pi`.

Condicional em `G_M`, o curto identifica o efeito total e o longo o direto nas hipóteses especificadas. Condicional em `G_F`, o longo identifica o efeito total e o curto tem confundimento. Como as janelas de D e Z não resolvem sua ordem, a saída comum correta é **shift descritivo −1, acompanhada dessas duas interpretações condicionais**. Não é legítimo escolher a história vazia como suficiente sob ambos os DAGs: sob `G_F`, o ajuste em Z é necessário. A ausência de um ajuste comum certificado faz parte do limite mostrado.

## 7. Inferência: equivalência e limites exatos da conclusão

Seja `v=(beta_B,beta_C,beta_U)'` e V sua covariância conjunta estimada. A matriz

\[
A=\begin{pmatrix}-1&0&1\\0&-1&1\end{pmatrix}
\tag{16}
\]

transforma v em `(d_add,d_lag)'`. Portanto sua covariância é `A V A'`. A diferença total é `a'v`, com `a=(-1,1,0)'`, e sua variância é `a' V a`. Essa transformação preserva as covariâncias entre modelos. Se C+ e P usam a mesma V, as covariâncias transformadas são idênticas por multiplicação de matrizes. Não se declarou igualdade exata de estimativas obtidas com correções finitas, normalizações ou implementações de sandwich diferentes.

Em qualquer reamostra na qual os modelos sejam estimáveis, a identidade FWL se mantém. Aplicar a mesma regra de intervalo à mesma sequência pareada de shifts dá o mesmo intervalo para C+ e P. Essa afirmação independe de a reamostragem ser apropriada: igualdade entre intervalos incorretos continua sendo igualdade. Cobertura requer hipótese de dependência, alvo e validação próprios.

Na região regular, a identidade funcional implica a mesma linearização: `IF_Delta = -pi' IF_theta - theta' IF_pi`, equivalente à diferença das funções de influência dos endpoints quando as equações são tratadas conjuntamente. No caso escalar `theta=pi=0`, se ambos os estimadores forem da ordem `n^(-1/2)`, seu produto será da ordem `n^(-1)` e o termo de primeira ordem será zero. A mesma degenerescência atinge a diferença pareada porque ela é o mesmo número em cada amostra. Escrever a diferença como contraste linear de coeficientes não cria automaticamente uma distribuição normal não degenerada.

Esta última observação delimita uma possível pergunta inferencial específica, já apontada no plano Gate 3 e na nota local: como fornecer inferência válida perto da origem do produto e sob o estimador dinâmico escolhido? Ela **não** fornece aqui uma solução ou prova de novidade. Intervalos obtidos de uma região conjunta para `(theta,pi)` são uma possibilidade a confrontar com literatura e requisitos; sua mera existência como transformação de conjunto também não bastaria para originalidade. Uma futura vantagem deve demonstrar garantia ou eficiência diferente, sob condições implementáveis. O exemplo determinístico E1-nulo não verifica a distribuição local e não será usado como teste dessa pergunta.

## 8. Confronto com fonte primária existente

A ajuda pública `gelbach_b1x2.sthlp:154–203` define a diferença na convenção `base-full`, a representação por coeficientes do modelo longo e a decomposição aditiva por grupos. Nosso sinal é `full-base`; a diferença de sinal é convenção, não resultado. As linhas 79–82 documentam VCE robusta e cluster com dependência arbitrária intragrupo. As linhas 225–236 descrevem opções sobre ortogonalidade e exclusão de covariâncias dos parâmetros, sob hipóteses específicas. Portanto é inadequado construir um comparador que ignore covariância, suponha iid por imposição ou não trate grupos correlacionados.

Essas passagens da ajuda foram lidas diretamente pelo designer. A equipe bibliográfica fez a leitura integral da ajuda e inspeção dirigida do código; seus localizadores adicionais permanecem evidência da frente bibliográfica até sua revisão. O artigo integral de Gelbach ainda não foi obtido nesta etapa. Não atribuímos a ele ausência de tratamento temporal, inferência específica ou aplicações que não lemos. A equivalência algébrica acima é provada independentemente dessa pendência; a avaliação completa de novidade depende dela.

## 9. Intuição e conclusão limitada

Comparar somente o ponto de partida e o ponto de chegada pode esconder quanto se subiu e depois se desceu. Um terceiro modelo mostra as duas etapas. Esse é o valor expositivo do exemplo E1. Porém uma decomposição conhecida já permite calcular cada etapa, e o mesmo mapa causal permite interpretá-la. E2 mostra uma limitação mais forte: dois mapas causais podem gerar exatamente os mesmos dados e exigir ajustes diferentes. A quantidade de detalhe algébrico não escolhe o mapa.

Assim, **o procedimento testado é reproduzível pelo comparador forte no domínio declarado**. Não encontramos uma capacidade matemática, inferencial ou computacional distinta dentro da versão congelada. A organização operacional pode ser útil, mas sua utilidade não foi mensurada e não recebe um certificado de novidade desta prova. O resultado é candidato à adjudicação independente e deve informar a decisão do autor sem alterar automaticamente gênero, manuscrito ou escopo.
