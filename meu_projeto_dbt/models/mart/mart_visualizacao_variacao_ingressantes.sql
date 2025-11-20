{{
    config(
        materialized='view'
    )
}}

-- Visualização final para análise da variação de ingressantes
-- Responde à pergunta: Qual foi a variação percentual na quantidade de ingressantes 
-- por faixa etária (60+), comparando pré-pandemia vs pós-pandemia, Presencial vs EAD?

SELECT 
    MODALIDADE_DESCRICAO,
    
    -- Médias pré-pandemia
    ROUND(MEDIA_PRE_60_MAIS, 2) AS MEDIA_PRE_60_MAIS,
    ROUND(MEDIA_PRE_50_MAIS, 2) AS MEDIA_PRE_50_MAIS,
    
    -- Médias pós-pandemia
    ROUND(MEDIA_POS_60_MAIS, 2) AS MEDIA_POS_60_MAIS,
    ROUND(MEDIA_POS_50_MAIS, 2) AS MEDIA_POS_50_MAIS,
    
    -- Variação percentual
    ROUND(VARIACAO_PERCENTUAL_60_MAIS, 2) AS VARIACAO_PERCENTUAL_60_MAIS,
    ROUND(VARIACAO_PERCENTUAL_50_MAIS, 2) AS VARIACAO_PERCENTUAL_50_MAIS,
    
    -- Interpretação
    CASE 
        WHEN VARIACAO_PERCENTUAL_60_MAIS > 0 THEN 'Aumento'
        WHEN VARIACAO_PERCENTUAL_60_MAIS < 0 THEN 'Redução'
        ELSE 'Sem mudança'
    END AS TENDENCIA_60_MAIS,
    
    CASE 
        WHEN VARIACAO_PERCENTUAL_50_MAIS > 0 THEN 'Aumento'
        WHEN VARIACAO_PERCENTUAL_50_MAIS < 0 THEN 'Redução'
        ELSE 'Sem mudança'
    END AS TENDENCIA_50_MAIS,
    
    -- Totais
    TOTAL_PRE_60_MAIS,
    TOTAL_POS_60_MAIS,
    TOTAL_PRE_50_MAIS,
    TOTAL_POS_50_MAIS

FROM {{ ref('mart_variacao_ingressantes_faixa_etaria') }}
WHERE MODALIDADE_DESCRICAO IN ('Presencial', 'EAD')
ORDER BY 
    CASE MODALIDADE_DESCRICAO
        WHEN 'Presencial' THEN 1
        WHEN 'EAD' THEN 2
        ELSE 3
    END

