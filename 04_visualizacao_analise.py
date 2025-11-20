"""
Script para criar visualização da análise de variação de ingressantes
Gera gráficos comparando pré vs pós pandemia por modalidade
"""

import duckdb
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path

# Configuração de estilo
sns.set_style("whitegrid")
plt.rcParams['figure.figsize'] = (14, 8)
plt.rcParams['font.size'] = 11

# Cores para as modalidades
CORES = {
    'Presencial': '#2E86AB',
    'EAD': '#A23B72'
}

def conectar_banco():
    """Conecta ao banco DuckDB"""
    caminho_banco = "bd/dev.duckdb"
    return duckdb.connect(caminho_banco)

def carregar_dados_mart(con):
    """Carrega dados da tabela mart de visualização"""
    query = """
    SELECT 
        MODALIDADE_DESCRICAO,
        MEDIA_PRE_60_MAIS,
        MEDIA_POS_60_MAIS,
        VARIACAO_PERCENTUAL_60_MAIS,
        MEDIA_PRE_50_MAIS,
        MEDIA_POS_50_MAIS,
        VARIACAO_PERCENTUAL_50_MAIS,
        TENDENCIA_60_MAIS,
        TENDENCIA_50_MAIS
    FROM mart_visualizacao_variacao_ingressantes
    WHERE MODALIDADE_DESCRICAO IN ('Presencial', 'EAD')
    ORDER BY MODALIDADE_DESCRICAO
    """
    return con.execute(query).df()

def criar_grafico_variacao_percentual(df):
    """Cria gráfico de barras mostrando variação percentual"""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))
    
    # Gráfico 1: Variação 60+ anos
    cores_60 = [CORES[mod] for mod in df['MODALIDADE_DESCRICAO']]
    bars1 = ax1.bar(df['MODALIDADE_DESCRICAO'], df['VARIACAO_PERCENTUAL_60_MAIS'], 
                    color=cores_60, alpha=0.8, edgecolor='black', linewidth=1.5)
    
    ax1.axhline(y=0, color='black', linestyle='--', linewidth=1)
    ax1.set_title('Variação Percentual de Ingressantes 60+ Anos\n(Pré vs Pós Pandemia)', 
                  fontsize=14, fontweight='bold', pad=20)
    ax1.set_ylabel('Variação Percentual (%)', fontsize=12)
    ax1.set_xlabel('Modalidade de Ensino', fontsize=12)
    ax1.grid(axis='y', alpha=0.3)
    
    # Adicionar valores nas barras
    for i, (bar, valor) in enumerate(zip(bars1, df['VARIACAO_PERCENTUAL_60_MAIS'])):
        altura = bar.get_height()
        ax1.text(bar.get_x() + bar.get_width()/2., altura + (2 if altura > 0 else -5),
                f'{valor:.1f}%', ha='center', va='bottom' if altura > 0 else 'top',
                fontsize=11, fontweight='bold')
    
    # Gráfico 2: Variação 50+ anos
    cores_50 = [CORES[mod] for mod in df['MODALIDADE_DESCRICAO']]
    bars2 = ax2.bar(df['MODALIDADE_DESCRICAO'], df['VARIACAO_PERCENTUAL_50_MAIS'], 
                    color=cores_50, alpha=0.8, edgecolor='black', linewidth=1.5)
    
    ax2.axhline(y=0, color='black', linestyle='--', linewidth=1)
    ax2.set_title('Variação Percentual de Ingressantes 50+ Anos\n(Pré vs Pós Pandemia)', 
                  fontsize=14, fontweight='bold', pad=20)
    ax2.set_ylabel('Variação Percentual (%)', fontsize=12)
    ax2.set_xlabel('Modalidade de Ensino', fontsize=12)
    ax2.grid(axis='y', alpha=0.3)
    
    # Adicionar valores nas barras
    for i, (bar, valor) in enumerate(zip(bars2, df['VARIACAO_PERCENTUAL_50_MAIS'])):
        altura = bar.get_height()
        ax2.text(bar.get_x() + bar.get_width()/2., altura + (2 if altura > 0 else -5),
                f'{valor:.1f}%', ha='center', va='bottom' if altura > 0 else 'top',
                fontsize=11, fontweight='bold')
    
    plt.tight_layout()
    return fig

def criar_grafico_comparacao_medias(df):
    """Cria gráfico comparando médias pré e pós pandemia"""
    fig, ax = plt.subplots(figsize=(12, 6))
    
    x = range(len(df))
    width = 0.35
    
    # Preparar dados
    modalidades = df['MODALIDADE_DESCRICAO'].tolist()
    pre_60 = df['MEDIA_PRE_60_MAIS'].tolist()
    pos_60 = df['MEDIA_POS_60_MAIS'].tolist()
    
    # Criar barras
    bars1 = ax.bar([i - width/2 for i in x], pre_60, width, 
                   label='Pré-Pandemia (2017-2018)', color='#FF6B6B', alpha=0.8, edgecolor='black')
    bars2 = ax.bar([i + width/2 for i in x], pos_60, width, 
                   label='Pós-Pandemia (2023-2024)', color='#4ECDC4', alpha=0.8, edgecolor='black')
    
    ax.set_xlabel('Modalidade de Ensino', fontsize=12)
    ax.set_ylabel('Média de Ingressantes 60+ Anos', fontsize=12)
    ax.set_title('Comparação de Médias: Ingressantes 60+ Anos\nPré vs Pós Pandemia por Modalidade', 
                 fontsize=14, fontweight='bold', pad=20)
    ax.set_xticks(x)
    ax.set_xticklabels(modalidades)
    ax.legend(fontsize=11)
    ax.grid(axis='y', alpha=0.3)
    
    # Adicionar valores nas barras
    for bars in [bars1, bars2]:
        for bar in bars:
            altura = bar.get_height()
            if altura > 0:
                ax.text(bar.get_x() + bar.get_width()/2., altura + altura*0.02,
                       f'{altura:.1f}', ha='center', va='bottom', fontsize=10)
    
    plt.tight_layout()
    return fig

def criar_grafico_tendencia(df):
    """Cria gráfico mostrando a tendência (aumento/redução)"""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    # Preparar dados
    modalidades = df['MODALIDADE_DESCRICAO'].tolist()
    variacoes = df['VARIACAO_PERCENTUAL_60_MAIS'].tolist()
    cores = [CORES[mod] for mod in modalidades]
    
    # Criar barras horizontais
    bars = ax.barh(modalidades, variacoes, color=cores, alpha=0.8, edgecolor='black', linewidth=1.5)
    
    ax.axvline(x=0, color='black', linestyle='--', linewidth=2)
    ax.set_xlabel('Variação Percentual (%)', fontsize=12)
    ax.set_title('Tendência de Variação: Ingressantes 60+ Anos\nComparação Pré vs Pós Pandemia', 
                 fontsize=14, fontweight='bold', pad=20)
    ax.grid(axis='x', alpha=0.3)
    
    # Adicionar valores
    for i, (bar, valor) in enumerate(zip(bars, variacoes)):
        width = bar.get_width()
        ax.text(width + (5 if width > 0 else -5), bar.get_y() + bar.get_height()/2,
               f'{valor:.1f}%', ha='left' if width > 0 else 'right', va='center',
               fontsize=11, fontweight='bold')
    
    # Adicionar anotações
    ax.text(0.02, 0.98, '← Redução', transform=ax.transAxes, 
           fontsize=10, verticalalignment='top', color='red', fontweight='bold')
    ax.text(0.98, 0.98, 'Aumento →', transform=ax.transAxes, 
           fontsize=10, verticalalignment='top', ha='right', color='green', fontweight='bold')
    
    plt.tight_layout()
    return fig

def gerar_relatorio_texto(df):
    """Gera relatório textual com os resultados"""
    relatorio = []
    relatorio.append("=" * 80)
    relatorio.append("RELATÓRIO DE ANÁLISE: VARIAÇÃO DE INGRESSANTES 60+ ANOS")
    relatorio.append("=" * 80)
    relatorio.append("")
    relatorio.append("PERÍODOS COMPARADOS:")
    relatorio.append("  • Pré-Pandemia: 2017-2018 (média)")
    relatorio.append("  • Pós-Pandemia: 2023-2024 (média)")
    relatorio.append("")
    relatorio.append("OBSERVAÇÃO: Faixa etária 62-69 anos não disponível nos dados.")
    relatorio.append("            Análise realizada com faixa 60+ anos (aproximação mais próxima).")
    relatorio.append("")
    relatorio.append("-" * 80)
    relatorio.append("")
    
    for _, row in df.iterrows():
        modalidade = row['MODALIDADE_DESCRICAO']
        relatorio.append(f"MODALIDADE: {modalidade}")
        relatorio.append(f"  Média Pré-Pandemia (60+): {row['MEDIA_PRE_60_MAIS']:.2f}")
        relatorio.append(f"  Média Pós-Pandemia (60+): {row['MEDIA_POS_60_MAIS']:.2f}")
        relatorio.append(f"  Variação Percentual: {row['VARIACAO_PERCENTUAL_60_MAIS']:.2f}%")
        relatorio.append(f"  Tendência: {row['TENDENCIA_60_MAIS']}")
        relatorio.append("")
    
    relatorio.append("-" * 80)
    relatorio.append("CONCLUSÃO:")
    
    # Identificar qual modalidade teve maior variação
    maior_var = df.loc[df['VARIACAO_PERCENTUAL_60_MAIS'].abs().idxmax()]
    relatorio.append(f"  • A modalidade com maior variação foi: {maior_var['MODALIDADE_DESCRICAO']}")
    relatorio.append(f"    Variação: {maior_var['VARIACAO_PERCENTUAL_60_MAIS']:.2f}%")
    relatorio.append("")
    
    # Comparar Presencial vs EAD
    presencial = df[df['MODALIDADE_DESCRICAO'] == 'Presencial'].iloc[0]
    ead = df[df['MODALIDADE_DESCRICAO'] == 'EAD'].iloc[0]
    
    if abs(presencial['VARIACAO_PERCENTUAL_60_MAIS']) > abs(ead['VARIACAO_PERCENTUAL_60_MAIS']):
        relatorio.append("  • A mudança foi MAIS ACENTUADA nos cursos PRESENCIAIS")
    else:
        relatorio.append("  • A mudança foi MAIS ACENTUADA nos cursos EAD")
    
    relatorio.append("")
    relatorio.append("=" * 80)
    
    return "\n".join(relatorio)

def main():
    """Função principal"""
    print("📊 Gerando visualizações da análise...")
    
    # Conectar ao banco
    con = conectar_banco()
    
    # Carregar dados
    print("📥 Carregando dados da tabela mart...")
    df = carregar_dados_mart(con)
    
    if df.empty:
        print("❌ Erro: Nenhum dado encontrado na tabela mart!")
        print("   Execute 'dbt run' primeiro para criar os modelos.")
        return
    
    print(f"✅ {len(df)} registros carregados")
    
    # Criar diretório para salvar gráficos
    output_dir = Path("visualizacoes")
    output_dir.mkdir(exist_ok=True)
    
    # Gerar gráficos
    print("📈 Criando gráficos...")
    
    # Gráfico 1: Variação percentual
    fig1 = criar_grafico_variacao_percentual(df)
    fig1.savefig(output_dir / "01_variacao_percentual.png", dpi=300, bbox_inches='tight')
    print("  ✅ Gráfico 1 salvo: 01_variacao_percentual.png")
    
    # Gráfico 2: Comparação de médias
    fig2 = criar_grafico_comparacao_medias(df)
    fig2.savefig(output_dir / "02_comparacao_medias.png", dpi=300, bbox_inches='tight')
    print("  ✅ Gráfico 2 salvo: 02_comparacao_medias.png")
    
    # Gráfico 3: Tendência
    fig3 = criar_grafico_tendencia(df)
    fig3.savefig(output_dir / "03_tendencia.png", dpi=300, bbox_inches='tight')
    print("  ✅ Gráfico 3 salvo: 03_tendencia.png")
    
    # Gerar relatório textual
    print("📝 Gerando relatório textual...")
    relatorio = gerar_relatorio_texto(df)
    
    with open(output_dir / "relatorio_analise.txt", "w", encoding="utf-8") as f:
        f.write(relatorio)
    print("  ✅ Relatório salvo: relatorio_analise.txt")
    
    # Mostrar relatório no console
    print("\n" + relatorio)
    
    # Salvar dados em CSV
    df.to_csv(output_dir / "dados_analise.csv", index=False, encoding="utf-8-sig")
    print(f"\n💾 Dados exportados: dados_analise.csv")
    
    print(f"\n✅ Visualizações geradas com sucesso em: {output_dir.absolute()}")
    
    # Mostrar gráficos
    plt.show()
    
    con.close()

if __name__ == "__main__":
    main()

