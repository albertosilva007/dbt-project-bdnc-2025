{{
    config(
        materialized='table'
    )
}}

-- Modelo mart que calcula a variação percentual de ingressantes
-- Comparando pré-pandemia vs pós-pandemia por modalidade

WITH pre_pandemia AS (
    SELECT 
        MODALIDADE_DESCRICAO,
        TP_MODALIDADE_ENSINO,
        MEDIA_ING_60_MAIS,
        MEDIA_ING_50_MAIS,
        TOTAL_ING_60_MAIS,
        TOTAL_ING_50_MAIS
    FROM {{ ref('int_ingressantes_faixa_etaria') }}
    WHERE PERIODO_PANDEMIA = 'Pre-Pandemia'
),

pos_pandemia AS (
    SELECT 
        MODALIDADE_DESCRICAO,
        TP_MODALIDADE_ENSINO,
        MEDIA_ING_60_MAIS,
        MEDIA_ING_50_MAIS,
        TOTAL_ING_60_MAIS,
        TOTAL_ING_50_MAIS
    FROM {{ ref('int_ingressantes_faixa_etaria') }}
    WHERE PERIODO_PANDEMIA = 'Pos-Pandemia'
)

SELECT 
    COALESCE(pre.MODALIDADE_DESCRICAO, pos.MODALIDADE_DESCRICAO) AS MODALIDADE_DESCRICAO,
    COALESCE(pre.TP_MODALIDADE_ENSINO, pos.TP_MODALIDADE_ENSINO) AS TP_MODALIDADE_ENSINO,
    
    -- Valores pré-pandemia
    COALESCE(pre.MEDIA_ING_60_MAIS, 0) AS MEDIA_PRE_60_MAIS,
    COALESCE(pre.MEDIA_ING_50_MAIS, 0) AS MEDIA_PRE_50_MAIS,
    COALESCE(pre.TOTAL_ING_60_MAIS, 0) AS TOTAL_PRE_60_MAIS,
    COALESCE(pre.TOTAL_ING_50_MAIS, 0) AS TOTAL_PRE_50_MAIS,
    
    -- Valores pós-pandemia
    COALESCE(pos.MEDIA_ING_60_MAIS, 0) AS MEDIA_POS_60_MAIS,
    COALESCE(pos.MEDIA_ING_50_MAIS, 0) AS MEDIA_POS_50_MAIS,
    COALESCE(pos.TOTAL_ING_60_MAIS, 0) AS TOTAL_POS_60_MAIS,
    COALESCE(pos.TOTAL_ING_50_MAIS, 0) AS TOTAL_POS_50_MAIS,
    
    -- Variação absoluta
    COALESCE(pos.MEDIA_ING_60_MAIS, 0) - COALESCE(pre.MEDIA_ING_60_MAIS, 0) AS VARIACAO_ABSOLUTA_60_MAIS,
    COALESCE(pos.MEDIA_ING_50_MAIS, 0) - COALESCE(pre.MEDIA_ING_50_MAIS, 0) AS VARIACAO_ABSOLUTA_50_MAIS,
    
    -- Variação percentual (60+)
    CASE 
        WHEN COALESCE(pre.MEDIA_ING_60_MAIS, 0) = 0 THEN 
            CASE WHEN COALESCE(pos.MEDIA_ING_60_MAIS, 0) > 0 THEN 100.0 ELSE 0.0 END
        ELSE 
            ((COALESCE(pos.MEDIA_ING_60_MAIS, 0) - COALESCE(pre.MEDIA_ING_60_MAIS, 0)) / 
             NULLIF(COALESCE(pre.MEDIA_ING_60_MAIS, 0), 0)) * 100
    END AS VARIACAO_PERCENTUAL_60_MAIS,
    
    -- Variação percentual (50+)
    CASE 
        WHEN COALESCE(pre.MEDIA_ING_50_MAIS, 0) = 0 THEN 
            CASE WHEN COALESCE(pos.MEDIA_ING_50_MAIS, 0) > 0 THEN 100.0 ELSE 0.0 END
        ELSE 
            ((COALESCE(pos.MEDIA_ING_50_MAIS, 0) - COALESCE(pre.MEDIA_ING_50_MAIS, 0)) / 
             NULLIF(COALESCE(pre.MEDIA_ING_50_MAIS, 0), 0)) * 100
    END AS VARIACAO_PERCENTUAL_50_MAIS,
    
    -- Diferença entre modalidades (para identificar qual teve maior variação)
    CASE 
        WHEN COALESCE(pre.MODALIDADE_DESCRICAO, '') = 'Presencial' THEN 'Presencial'
        WHEN COALESCE(pre.MODALIDADE_DESCRICAO, '') = 'EAD' THEN 'EAD'
        ELSE COALESCE(pos.MODALIDADE_DESCRICAO, 'Outro')
    END AS MODALIDADE

FROM pre_pandemia pre
FULL OUTER JOIN pos_pandemia pos
    ON pre.TP_MODALIDADE_ENSINO = pos.TP_MODALIDADE_ENSINO
ORDER BY 
    CASE 
        WHEN COALESCE(pre.MODALIDADE_DESCRICAO, pos.MODALIDADE_DESCRICAO) = 'Presencial' THEN 1
        WHEN COALESCE(pre.MODALIDADE_DESCRICAO, pos.MODALIDADE_DESCRICAO) = 'EAD' THEN 2
        ELSE 3
    END

