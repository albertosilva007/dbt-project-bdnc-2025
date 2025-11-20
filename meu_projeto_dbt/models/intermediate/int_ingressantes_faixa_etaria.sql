{{
    config(
        materialized='table'
    )
}}

-- Modelo intermediate que calcula as médias de ingressantes por faixa etária
-- Agrupado por período (pré/pós pandemia) e modalidade

SELECT 
    PERIODO_PANDEMIA,
    MODALIDADE_DESCRICAO,
    TP_MODALIDADE_ENSINO,
    -- Média de ingressantes na faixa 60+
    AVG(QT_ING_60_MAIS) AS MEDIA_ING_60_MAIS,
    -- Média de ingressantes na faixa 50+
    AVG(QT_ING_50_MAIS) AS MEDIA_ING_50_MAIS,
    -- Total de ingressantes na faixa 60+
    SUM(QT_ING_60_MAIS) AS TOTAL_ING_60_MAIS,
    -- Total de ingressantes na faixa 50+
    SUM(QT_ING_50_MAIS) AS TOTAL_ING_50_MAIS,
    -- Contagem de registros
    COUNT(*) AS QTD_REGISTROS,
    -- Média total de ingressantes
    AVG(QT_ING_TOTAL) AS MEDIA_ING_TOTAL
FROM {{ ref('stg_cursos_censo') }}
WHERE PERIODO_PANDEMIA IN ('Pre-Pandemia', 'Pos-Pandemia')
GROUP BY 
    PERIODO_PANDEMIA,
    MODALIDADE_DESCRICAO,
    TP_MODALIDADE_ENSINO

