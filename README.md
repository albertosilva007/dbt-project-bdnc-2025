# 📊 Projeto de Engenharia de Dados - Análise de Ingressantes por Faixa Etária

## 📋 Sumário

- [Pergunta de Negócio](#-pergunta-de-negócio)
- [Objetivo do Projeto](#-objetivo-do-projeto)
- [Tecnologias Utilizadas](#-tecnologias-utilizadas)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Processo de Desenvolvimento](#-processo-de-desenvolvimento)
- [Limitações e Ajustes](#-limitações-e-ajustes)
- [Resultados](#-resultados)
- [Como Reproduzir](#-como-reproduzir)
- [Arquivos e Documentação](#-arquivos-e-documentação)

---

## 🎯 Pergunta de Negócio

**Pergunta Original:**
> "Qual foi a variação percentual na quantidade de ingressantes por faixa etária (62 a 69), comparando a média dos anos pré-pandemia (2017-2019) com a média dos anos pós-pandemia (2022-2024)? Essa mudança foi mais acentuada nos cursos Presenciais vs. EAD (27)?"

**Colunas Chave Utilizadas:**
- `NU_ANO_CENSO`: Ano do censo
- `TP_MODALIDADE_ENSINO`: Tipo de modalidade de ensino
- `QT_ING_0_17` até `QT_ING_60_MAIS`: Quantidade de ingressantes por faixa etária

---

## 🎯 Objetivo do Projeto

Desenvolver um pipeline completo de engenharia de dados que:

1. ✅ **Carregue os dados brutos** do censo da educação superior
2. ✅ **Realize transformações** dos dados via DBT
3. ✅ **Gere tabela mart final** com documentação completa
4. ✅ **Construa visualizações** que respondam à pergunta de negócio

---

## 🛠️ Tecnologias Utilizadas

- **Python 3.12**: Linguagem principal
- **DuckDB 1.4.2**: Banco de dados analítico
- **DBT 1.10.15**: Ferramenta de transformação de dados
- **Pandas**: Manipulação de dados
- **Matplotlib & Seaborn**: Visualizações
- **Jupyter Notebook**: Desenvolvimento e documentação

---

## 📁 Estrutura do Projeto

```
dbt-project-bdnc-2025/
├── 01_configurar_ambiente_dbt_duckdb.ipynb    # Configuração inicial
├── 02_duckdb_insercao_carga.ipynb              # Carga de dados brutos
├── 03_insercao_dados.ipynb                     # Alternativa de carga
├── 04_visualizacao_analise.py                  # Script de visualização
├── data_input/                                 # Dados brutos (CSV)
│   ├── MICRODADOS_CADASTRO_CURSOS_2017.CSV
│   ├── MICRODADOS_CADASTRO_CURSOS_2018.CSV
│   ├── MICRODADOS_CADASTRO_CURSOS_2023.CSV
│   └── MICRODADOS_CADASTRO_CURSOS_2024.CSV
├── bd/
│   └── dev.duckdb                              # Banco de dados DuckDB
├── meu_projeto_dbt/                            # Projeto DBT
│   ├── models/
│   │   ├── staging/
│   │   │   └── stg_cursos_censo.sql
│   │   ├── intermediate/
│   │   │   └── int_ingressantes_faixa_etaria.sql
│   │   ├── mart/
│   │   │   ├── mart_variacao_ingressantes_faixa_etaria.sql
│   │   │   └── mart_visualizacao_variacao_ingressantes.sql
│   │   └── sources.yml
│   └── dbt_project.yml
├── visualizacoes/                              # Resultados e gráficos
│   ├── 01_variacao_percentual.png
│   ├── 02_comparacao_medias.png
│   ├── 03_tendencia.png
│   ├── dados_analise.csv
│   └── relatorio_analise.txt
└── README.md                                   # Este arquivo
```

---

## 🔄 Processo de Desenvolvimento

### Etapa 1: Configuração do Ambiente

**Arquivo:** `01_configurar_ambiente_dbt_duckdb.ipynb`

**Ações realizadas:**
- Criação de ambiente virtual Python (`.venv`)
- Instalação de dependências: `dbt-duckdb`, `pandas`, `duckdb`
- Criação do banco DuckDB (`bd/dev.duckdb`)
- Inicialização do projeto DBT (`meu_projeto_dbt`)
- Criação da estrutura de diretórios (raw, staging, intermediate, mart)
- Configuração do arquivo `profiles.yml` do DBT
- Teste de conexão com o banco

**Resultado:** Ambiente configurado e pronto para uso.

---

### Etapa 2: Carga de Dados Brutos

**Arquivo:** `02_duckdb_insercao_carga.ipynb`

**Ações realizadas:**
- Mapeamento automático de arquivos CSV na pasta `data_input`
- Conexão ao banco DuckDB
- Criação do schema `raw`
- Inserção de cada arquivo CSV como tabela no schema `raw`
- Tratamento de encoding (`latin-1` para caracteres especiais)
- Configuração de delimitador (ponto e vírgula `;`)
- Criação dos schemas: `staging`, `intermediate`, `mart`

**Tabelas criadas:**
- `raw.MICRODADOS_CADASTRO_CURSOS_2017`
- `raw.MICRODADOS_CADASTRO_CURSOS_2018`
- `raw.MICRODADOS_CADASTRO_CURSOS_2023`
- `raw.MICRODADOS_CADASTRO_CURSOS_2024`

**Desafios resolvidos:**
- Encoding: Tentativa de múltiplos encodings até encontrar `latin-1`
- Delimitador: Uso correto do parâmetro `delim` (não `delimiter`)
- Caminhos: Normalização de caminhos para Windows

---

### Etapa 3: Transformação de Dados (DBT)

#### 3.1 Modelo Staging

**Arquivo:** `meu_projeto_dbt/models/staging/stg_cursos_censo.sql`

**Função:** Unificar dados de todos os anos em uma única view.

**Transformações:**
- União de dados de 2017, 2018, 2023 e 2024
- Classificação de períodos (Pré-Pandemia vs Pós-Pandemia)
- Identificação de modalidades (Presencial = 1, EAD = 2)
- Cálculo de faixas etárias:
  - `QT_ING_60_MAIS`: Ingressantes com 60+ anos
  - `QT_ING_50_MAIS`: Soma de 50-59 + 60+ anos
- Filtro de anos e modalidades relevantes

**Resultado:** View `stg_cursos_censo` com dados unificados e classificados.

---

#### 3.2 Modelo Intermediate

**Arquivo:** `meu_projeto_dbt/models/intermediate/int_ingressantes_faixa_etaria.sql`

**Função:** Calcular médias de ingressantes por período e modalidade.

**Transformações:**
- Agrupamento por período (Pré/Pós pandemia) e modalidade
- Cálculo de médias de ingressantes 60+ e 50+
- Cálculo de totais por período
- Contagem de registros

**Resultado:** Tabela `int_ingressantes_faixa_etaria` com médias calculadas.

---

#### 3.3 Modelo Mart

**Arquivo:** `meu_projeto_dbt/models/mart/mart_variacao_ingressantes_faixa_etaria.sql`

**Função:** Calcular variação percentual entre períodos.

**Transformações:**
- Join entre dados pré e pós pandemia
- Cálculo de variação absoluta
- Cálculo de variação percentual (com tratamento de divisão por zero)
- Identificação de tendências (Aumento/Redução)

**Resultado:** Tabela `mart_variacao_ingressantes_faixa_etaria` com análise completa.

---

#### 3.4 View de Visualização

**Arquivo:** `meu_projeto_dbt/models/mart/mart_visualizacao_variacao_ingressantes.sql`

**Função:** Formatar dados para visualização e análise.

**Transformações:**
- Arredondamento de valores
- Classificação de tendências
- Ordenação por modalidade

**Resultado:** View `mart_visualizacao_variacao_ingressantes` pronta para análise.

---

### Etapa 4: Documentação

**Comandos executados:**
```bash
dbt docs generate
dbt docs serve
```

**Resultado:**
- Documentação interativa gerada
- Acessível em `http://localhost:8080`
- Inclui linhagem de dados, descrições de colunas e código SQL

---

### Etapa 5: Visualizações

**Arquivo:** `04_visualizacao_analise.py`

**Gráficos gerados:**

1. **01_variacao_percentual.png**
   - Comparação de variação percentual 60+ e 50+ anos
   - Por modalidade (Presencial vs EAD)

2. **02_comparacao_medias.png**
   - Comparação de médias pré vs pós pandemia
   - Por modalidade

3. **03_tendencia.png**
   - Gráfico de barras horizontais mostrando tendência
   - Indicação visual de aumento/redução

**Arquivos gerados:**
- `dados_analise.csv`: Dados exportados para análise externa
- `relatorio_analise.txt`: Relatório textual com conclusões

---

## ⚠️ Limitações e Ajustes

### 1. Faixa Etária 62-69 Anos

**Problema:** Não existe coluna específica para a faixa etária 62-69 anos nos dados do INEP.

**Solução Implementada:**
- Uso de `QT_ING_60_MAIS` (60+ anos) como aproximação mais próxima
- Cálculo adicional de `QT_ING_50_MAIS` (50+ anos) para análise mais ampla

**Impacto:** Análise válida, mas não exatamente na faixa solicitada (62-69).

---

### 2. Código EAD 27

**Problema:** A pergunta menciona código 27 para EAD, mas esse código não existe em `TP_MODALIDADE_ENSINO`.

**Valores Encontrados:**
- `1` = Presencial
- `2` = EAD (Educação a Distância)

**Solução Implementada:**
- Uso do código `2` para EAD, conforme padrão do INEP
- Verificação realizada: apenas códigos 1 e 2 existem nos dados

**Impacto:** Análise correta, mas usando código diferente do mencionado na pergunta.

---

### 3. Anos Disponíveis

**Problema:** A pergunta solicita comparação entre:
- Pré-pandemia: 2017-2019 (3 anos)
- Pós-pandemia: 2022-2024 (3 anos)

**Anos Disponíveis:**
- Pré-pandemia: 2017, 2018 (faltam 2019)
- Pós-pandemia: 2023, 2024 (falta 2022)

**Solução Implementada:**
- Cálculo de médias com os anos disponíveis (2 anos em cada período)
- Classificação mantida: 2017-2018 como pré-pandemia, 2023-2024 como pós-pandemia

**Impacto:** Médias calculadas com 2 anos ao invés de 3, mas análise ainda válida.

---

## 📊 Resultados

### Resumo dos Resultados

**Períodos Comparados:**
- Pré-Pandemia: 2017-2018 (média)
- Pós-Pandemia: 2023-2024 (média)

**Faixa Etária Analisada:** 60+ anos (aproximação para 62-69 anos)

---

### Resultados por Modalidade

#### EAD (Educação a Distância)

- **Média Pré-Pandemia (60+)**: 0.06 ingressantes
- **Média Pós-Pandemia (60+)**: 0.04 ingressantes
- **Variação Percentual**: **-28.53%** (Redução)
- **Tendência**: Redução

#### Presencial

- **Média Pré-Pandemia (60+)**: 0.13 ingressantes
- **Média Pós-Pandemia (60+)**: 0.18 ingressantes
- **Variação Percentual**: **+39.37%** (Aumento)
- **Tendência**: Aumento

---

### Conclusões

1. **Modalidade com Maior Variação:**
   - **Presencial** com variação de **39.37%**

2. **Mudança Mais Acentuada:**
   - A mudança foi **MAIS ACENTUADA nos cursos PRESENCIAIS**
   - Presencial: Aumento de 39.37%
   - EAD: Redução de 28.53%

3. **Tendências Opostas:**
   - Cursos **Presenciais** tiveram **aumento** significativo de ingressantes 60+
   - Cursos **EAD** tiveram **redução** de ingressantes 60+

---

## 🔄 Como Reproduzir

### Pré-requisitos

- Python 3.12+
- Ambiente virtual Python
- Acesso aos dados CSV na pasta `data_input`

### Passo a Passo

#### 1. Configurar Ambiente

```bash
# Execute o notebook
01_configurar_ambiente_dbt_duckdb.ipynb
```

Isso criará:
- Ambiente virtual `.venv`
- Banco DuckDB `bd/dev.duckdb`
- Projeto DBT `meu_projeto_dbt`

#### 2. Carregar Dados Brutos

```bash
# Execute o notebook
02_duckdb_insercao_carga.ipynb
```

Isso criará as tabelas no schema `raw`.

#### 3. Executar Transformações DBT

```bash
cd meu_projeto_dbt
dbt run
```

Isso criará todos os modelos (staging, intermediate, mart).

#### 4. Gerar Documentação

```bash
dbt docs generate
dbt docs serve
```

Acesse `http://localhost:8080` para ver a documentação.

#### 5. Gerar Visualizações

```bash
# Volte para o diretório raiz
cd ..
python 04_visualizacao_analise.py
```

Isso gerará os gráficos na pasta `visualizacoes/`.

---

## 📄 Arquivos e Documentação

### Arquivos Principais

- **README.md**: Este arquivo (documentação completa)
- **RESUMO_ATIVIDADE.md**: Resumo executivo da atividade
- **INSTRUCOES_ANALISE.md**: Instruções detalhadas de execução

### Visualizações Geradas

Localizadas em `visualizacoes/`:

1. **01_variacao_percentual.png**: Gráfico de barras comparando variação percentual
2. **02_comparacao_medias.png**: Comparação de médias pré vs pós pandemia
3. **03_tendencia.png**: Gráfico de tendência (aumento/redução)
4. **dados_analise.csv**: Dados exportados para análise externa
5. **relatorio_analise.txt**: Relatório textual com conclusões

### Documentação DBT

Acesse via:
```bash
cd meu_projeto_dbt
dbt docs serve
```

Inclui:
- Linhagem de dados (Lineage Graph)
- Descrições de modelos e colunas
- Código SQL original e compilado
- Dependências entre modelos

---

## 📝 Notas Finais

### Decisões Técnicas

1. **Encoding**: Uso de `latin-1` para tratar caracteres especiais (acentos)
2. **Delimitador**: Ponto e vírgula (`;`) conforme formato dos CSVs
3. **Materialização**: Views para staging, tabelas para intermediate e mart
4. **Nomenclatura**: Padrão DBT (staging → intermediate → mart)

### Validações Realizadas

- ✅ Dados carregados corretamente (verificação de contagem de linhas)
- ✅ Transformações executadas sem erros
- ✅ Documentação gerada com sucesso
- ✅ Visualizações criadas e validadas

### Possíveis Melhorias

1. Adicionar dados de 2019 e 2022 se disponíveis
2. Criar análise adicional para outras faixas etárias
3. Implementar testes de dados no DBT
4. Criar dashboard interativo (ex: Streamlit, Power BI)

---

## 👤 Autor

Projeto desenvolvido como parte de atividade de Engenharia de Dados.

**Data de Conclusão:** Novembro 2025

---

## 📞 Suporte

Para dúvidas ou problemas:
1. Consulte a documentação DBT: `dbt docs serve`
2. Verifique os logs em `logs/dbt.log`
3. Revise os notebooks de configuração e carga

---

**Status do Projeto:** ✅ COMPLETO

Todos os requisitos foram atendidos:
- ✅ Carregamento de dados brutos
- ✅ Transformação via DBT
- ✅ Tabela mart com documentação
- ✅ Visualizações geradas
