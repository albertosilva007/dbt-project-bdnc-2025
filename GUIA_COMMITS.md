# 📝 Guia de Commits - Padrão Conventional Commits

## Padrão Utilizado: Conventional Commits

Formato: `<tipo>(<escopo>): <descrição>`

### Tipos de Commit:
- `feat`: Nova funcionalidade
- `fix`: Correção de bug
- `docs`: Documentação
- `style`: Formatação (não afeta código)
- `refactor`: Refatoração de código
- `test`: Testes
- `chore`: Tarefas de manutenção

---

## Sequência de Commits Recomendada

Execute os comandos na ordem abaixo:

### 1. Configuração e Setup
```bash
git add .gitignore
git commit -m "chore: adicionar .gitignore para Python e DBT"

git add 01_configurar_ambiente_dbt_duckdb.ipynb
git commit -m "feat: adicionar notebook de configuração do ambiente DBT e DuckDB"
```

### 2. Carga de Dados
```bash
git add 02_duckdb_insercao_carga.ipynb
git commit -m "feat: adicionar script de carga de dados CSV no DuckDB com tratamento de encoding"

git add 03_insercao_dados.ipynb
git commit -m "feat: adicionar alternativa de carga de dados usando pandas"
```

### 3. Modelos DBT
```bash
git add meu_projeto_dbt/models/staging/
git commit -m "feat(dbt): adicionar modelo staging para unificação de dados do censo"

git add meu_projeto_dbt/models/intermediate/
git commit -m "feat(dbt): adicionar modelo intermediate para cálculo de médias por período"

git add meu_projeto_dbt/models/mart/
git commit -m "feat(dbt): adicionar modelos mart com análise de variação percentual"

git add meu_projeto_dbt/models/sources.yml
git commit -m "docs(dbt): adicionar definição de sources para tabelas raw"
```

### 4. Visualizações
```bash
git add 04_visualizacao_analise.py
git commit -m "feat: adicionar script de geração de visualizações da análise"

git add visualizacoes/
git commit -m "feat: adicionar gráficos e relatórios da análise de ingressantes"
```

### 5. Documentação
```bash
git add README.md
git commit -m "docs: adicionar documentação completa do projeto"
```

### 6. Limpeza (arquivos deletados)
```bash
git add "dicionário_dados_educação_superior_2017.xlsx" "dicionário_dados_educação_superior_2018.xlsx" "dicionário_dados_educação_superior_2023.xlsx" "dicionário_dados_educação_superior_2024.xlsx"
git commit -m "chore: remover arquivos de dicionário movidos para pasta específica"

git add dicionario_de_dados/
git commit -m "chore: organizar dicionários de dados em pasta dedicada"
```

---

## Comando Único (Alternativa Rápida)

Se preferir fazer commits mais agrupados:

```bash
# Setup e configuração
git add .gitignore 01_configurar_ambiente_dbt_duckdb.ipynb
git commit -m "feat: adicionar configuração inicial do ambiente DBT e DuckDB"

# Carga de dados
git add 02_duckdb_insercao_carga.ipynb 03_insercao_dados.ipynb
git commit -m "feat: adicionar scripts de carga de dados no DuckDB"

# Modelos DBT
git add meu_projeto_dbt/models/
git commit -m "feat(dbt): adicionar pipeline completo de transformação de dados"

# Visualizações
git add 04_visualizacao_analise.py visualizacoes/
git commit -m "feat: adicionar visualizações e análise de resultados"

# Documentação
git add README.md
git commit -m "docs: adicionar documentação completa do projeto"

# Limpeza
git add dicionario_de_dados/ "dicionário_dados_educação_superior_*.xlsx"
git commit -m "chore: reorganizar arquivos de dicionário de dados"
```

---

## Verificar antes de fazer push

```bash
# Ver histórico de commits
git log --oneline -10

# Ver status final
git status

# Fazer push (quando estiver pronto)
git push origin main
# ou
git push origin master
```

