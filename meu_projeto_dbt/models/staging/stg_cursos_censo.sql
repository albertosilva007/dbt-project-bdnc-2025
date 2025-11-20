{{
    config(
        materialized='view'
    )
}}

-- Modelo staging que unifica os dados de todos os anos do censo
-- Combina as tabelas raw de diferentes anos

WITH cursos_2017 AS (
    SELECT 
        NU_ANO_CENSO,
        TP_MODALIDADE_ENSINO,
        QT_ING_0_17,
        QT_ING_18_24,
        QT_ING_25_29,
        QT_ING_30_34,
        QT_ING_35_39,
        QT_ING_40_49,
        QT_ING_50_59,
        QT_ING_60_MAIS,
        QT_ING,
        NO_REGIAO,
        SG_UF,
        NO_CURSO
    FROM {{ source('raw', 'MICRODADOS_CADASTRO_CURSOS_2017') }}
),

cursos_2018 AS (
    SELECT 
        NU_ANO_CENSO,
        TP_MODALIDADE_ENSINO,
        QT_ING_0_17,
        QT_ING_18_24,
        QT_ING_25_29,
        QT_ING_30_34,
        QT_ING_35_39,
        QT_ING_40_49,
        QT_ING_50_59,
        QT_ING_60_MAIS,
        QT_ING,
        NO_REGIAO,
        SG_UF,
        NO_CURSO
    FROM {{ source('raw', 'MICRODADOS_CADASTRO_CURSOS_2018') }}
),

cursos_2023 AS (
    SELECT 
        NU_ANO_CENSO,
        TP_MODALIDADE_ENSINO,
        QT_ING_0_17,
        QT_ING_18_24,
        QT_ING_25_29,
        QT_ING_30_34,
        QT_ING_35_39,
        QT_ING_40_49,
        QT_ING_50_59,
        QT_ING_60_MAIS,
        QT_ING,
        NO_REGIAO,
        SG_UF,
        NO_CURSO
    FROM {{ source('raw', 'MICRODADOS_CADASTRO_CURSOS_2023') }}
),

cursos_2024 AS (
    SELECT 
        NU_ANO_CENSO,
        TP_MODALIDADE_ENSINO,
        QT_ING_0_17,
        QT_ING_18_24,
        QT_ING_25_29,
        QT_ING_30_34,
        QT_ING_35_39,
        QT_ING_40_49,
        QT_ING_50_59,
        QT_ING_60_MAIS,
        QT_ING,
        NO_REGIAO,
        SG_UF,
        NO_CURSO
    FROM {{ source('raw', 'MICRODADOS_CADASTRO_CURSOS_2024') }}
),

unificado AS (
    SELECT * FROM cursos_2017
    UNION ALL
    SELECT * FROM cursos_2018
    UNION ALL
    SELECT * FROM cursos_2023
    UNION ALL
    SELECT * FROM cursos_2024
)

SELECT 
    NU_ANO_CENSO,
    TP_MODALIDADE_ENSINO,
    CASE 
        WHEN TP_MODALIDADE_ENSINO = 1 THEN 'Presencial'
        WHEN TP_MODALIDADE_ENSINO = 2 THEN 'EAD'
        ELSE 'Outro'
    END AS MODALIDADE_DESCRICAO,
    -- Calcula ingressantes na faixa 60+ (mais próxima de 62-69)
    COALESCE(QT_ING_60_MAIS, 0) AS QT_ING_60_MAIS,
    -- Também calcula a soma de 50-59 e 60+ para faixa mais ampla
    COALESCE(QT_ING_50_59, 0) + COALESCE(QT_ING_60_MAIS, 0) AS QT_ING_50_MAIS,
    COALESCE(QT_ING_0_17, 0) AS QT_ING_0_17,
    COALESCE(QT_ING_18_24, 0) AS QT_ING_18_24,
    COALESCE(QT_ING_25_29, 0) AS QT_ING_25_29,
    COALESCE(QT_ING_30_34, 0) AS QT_ING_30_34,
    COALESCE(QT_ING_35_39, 0) AS QT_ING_35_39,
    COALESCE(QT_ING_40_49, 0) AS QT_ING_40_49,
    COALESCE(QT_ING_50_59, 0) AS QT_ING_50_59,
    COALESCE(QT_ING, 0) AS QT_ING_TOTAL,
    NO_REGIAO,
    SG_UF,
    NO_CURSO,
    -- Classifica período (usando apenas anos disponíveis)
    CASE 
        WHEN NU_ANO_CENSO IN (2017, 2018, 2019) THEN 'Pre-Pandemia'
        WHEN NU_ANO_CENSO IN (2022, 2023, 2024) THEN 'Pos-Pandemia'
        ELSE 'Outro'
    END AS PERIODO_PANDEMIA
FROM unificado
WHERE NU_ANO_CENSO IN (2017, 2018, 2019, 2022, 2023, 2024)
  AND TP_MODALIDADE_ENSINO IN (1, 2)  -- Presencial (1) e EAD (2)

