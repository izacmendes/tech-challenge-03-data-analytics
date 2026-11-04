
-- ============================================================
-- TECH CHALLENGE 03
-- 08 - MODELO DE TRABALHO
-- Amazon Athena
-- ============================================================

USE tc3_state_of_data;


-- ============================================================
-- 1. CONSOLIDACAO DOS MODELOS ATUAIS E IDEAIS
-- Edições 2024-2025 e 2025-2026
-- ============================================================

WITH modelos AS (

    SELECT
        '2024_2025' AS survey_edition,
        'Atual' AS tipo_modelo,
        "2_r_modelo_de_trabalho_atual" AS modelo
    FROM silver_state_of_data_2024_2025

    UNION ALL

    SELECT
        '2024_2025',
        'Ideal',
        "2_s_modelo_de_trabalho_ideal"
    FROM silver_state_of_data_2024_2025

    UNION ALL

    SELECT
        '2025_2026',
        'Atual',
        "2_q_modelo_de_trabalho_atual"
    FROM silver_state_of_data_2025_2026

    UNION ALL

    SELECT
        '2025_2026',
        'Ideal',
        "2_r_modelo_de_trabalho_ideal"
    FROM silver_state_of_data_2025_2026
)

SELECT
    survey_edition,
    tipo_modelo,
    modelo,
    COUNT(*) AS quantidade,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (
            PARTITION BY survey_edition, tipo_modelo
        ),
        2
    ) AS percentual
FROM modelos
WHERE modelo IS NOT NULL
  AND TRIM(modelo) <> ''
GROUP BY survey_edition, tipo_modelo, modelo
ORDER BY survey_edition, tipo_modelo, quantidade DESC;


-- ============================================================
-- 2. PERCENTUAL DE TRABALHO REMOTO OU HIBRIDO
-- Comparacao entre modelo atual e ideal por edicao
-- ============================================================

WITH modelos AS (

    SELECT
        '2024_2025' AS survey_edition,
        'Atual' AS tipo_modelo,
        "2_r_modelo_de_trabalho_atual" AS modelo
    FROM silver_state_of_data_2024_2025

    UNION ALL

    SELECT
        '2024_2025',
        'Ideal',
        "2_s_modelo_de_trabalho_ideal"
    FROM silver_state_of_data_2024_2025

    UNION ALL

    SELECT
        '2025_2026',
        'Atual',
        "2_q_modelo_de_trabalho_atual"
    FROM silver_state_of_data_2025_2026

    UNION ALL

    SELECT
        '2025_2026',
        'Ideal',
        "2_r_modelo_de_trabalho_ideal"
    FROM silver_state_of_data_2025_2026
),

resumo AS (
    SELECT
        survey_edition,
        tipo_modelo,
        COUNT(*) AS respostas_validas,
        SUM(
            CASE
                WHEN LOWER(modelo) LIKE '%remoto%'
                  OR LOWER(modelo) LIKE '%flex%'
                THEN 1
                ELSE 0
            END
        ) AS remoto_ou_flexivel
    FROM modelos
    WHERE modelo IS NOT NULL
      AND TRIM(modelo) <> ''
    GROUP BY survey_edition, tipo_modelo
)

SELECT
    survey_edition,
    tipo_modelo,
    respostas_validas,
    remoto_ou_flexivel,
    ROUND(
        remoto_ou_flexivel * 100.0 /
        respostas_validas,
        2
    ) AS percentual_remoto_ou_flexivel
FROM resumo
ORDER BY survey_edition, tipo_modelo;


-- ============================================================
-- 3. MODELO DE TRABALHO POR SENIORIDADE
-- ============================================================

WITH modelos AS (

    SELECT
        '2024_2025' AS survey_edition,
        "2_g_nivel" AS senioridade,
        'Atual' AS tipo_modelo,
        "2_r_modelo_de_trabalho_atual" AS modelo
    FROM silver_state_of_data_2024_2025

    UNION ALL

    SELECT
        '2024_2025',
        "2_g_nivel",
        'Ideal',
        "2_s_modelo_de_trabalho_ideal"
    FROM silver_state_of_data_2024_2025

    UNION ALL

    SELECT
        '2025_2026',
        "2_g_nivel",
        'Atual',
        "2_q_modelo_de_trabalho_atual"
    FROM silver_state_of_data_2025_2026

    UNION ALL

    SELECT
        '2025_2026',
        "2_g_nivel",
        'Ideal',
        "2_r_modelo_de_trabalho_ideal"
    FROM silver_state_of_data_2025_2026
)

SELECT
    survey_edition,
    senioridade,
    tipo_modelo,
    modelo,
    COUNT(*) AS quantidade,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (
            PARTITION BY
                survey_edition,
                senioridade,
                tipo_modelo
        ),
        2
    ) AS percentual
FROM modelos
WHERE senioridade IS NOT NULL
  AND TRIM(senioridade) <> ''
  AND modelo IS NOT NULL
  AND TRIM(modelo) <> ''
GROUP BY
    survey_edition,
    senioridade,
    tipo_modelo,
    modelo
ORDER BY
    survey_edition,
    senioridade,
    tipo_modelo,
    quantidade DESC;


-- ============================================================
-- 4. DIFERENCA ENTRE PREFERENCIA E MODELO ATUAL POR REGIAO
-- Percentual de remoto ou flexivel
-- ============================================================

WITH modelos AS (

    SELECT
        '2024_2025' AS survey_edition,
        "1_i_2_regiao_onde_mora" AS regiao,
        'Atual' AS tipo_modelo,
        "2_r_modelo_de_trabalho_atual" AS modelo
    FROM silver_state_of_data_2024_2025

    UNION ALL

    SELECT
        '2024_2025',
        "1_i_2_regiao_onde_mora",
        'Ideal',
        "2_s_modelo_de_trabalho_ideal"
    FROM silver_state_of_data_2024_2025

    UNION ALL

    SELECT
        '2025_2026',
        "1_i_2_regiao_onde_mora",
        'Atual',
        "2_q_modelo_de_trabalho_atual"
    FROM silver_state_of_data_2025_2026

    UNION ALL

    SELECT
        '2025_2026',
        "1_i_2_regiao_onde_mora",
        'Ideal',
        "2_r_modelo_de_trabalho_ideal"
    FROM silver_state_of_data_2025_2026
),

resumo AS (
    SELECT
        survey_edition,
        regiao,
        tipo_modelo,
        COUNT(*) AS respostas_validas,
        SUM(
            CASE
                WHEN LOWER(modelo) LIKE '%remoto%'
                  OR LOWER(modelo) LIKE '%flex%'
                THEN 1
                ELSE 0
            END
        ) AS remoto_ou_flexivel
    FROM modelos
    WHERE regiao IS NOT NULL
      AND TRIM(regiao) <> ''
      AND modelo IS NOT NULL
      AND TRIM(modelo) <> ''
    GROUP BY survey_edition, regiao, tipo_modelo
),

percentuais AS (
    SELECT
        survey_edition,
        regiao,
        tipo_modelo,
        respostas_validas,
        ROUND(
            remoto_ou_flexivel * 100.0 /
            respostas_validas,
            2
        ) AS percentual_remoto_ou_flexivel
    FROM resumo
)

SELECT
    survey_edition,
    regiao,

    MAX(
        CASE WHEN tipo_modelo = 'Atual'
        THEN respostas_validas END
    ) AS total_atual,

    MAX(
        CASE WHEN tipo_modelo = 'Ideal'
        THEN respostas_validas END
    ) AS total_ideal,

    MAX(
        CASE WHEN tipo_modelo = 'Atual'
        THEN percentual_remoto_ou_flexivel END
    ) AS percentual_atual,

    MAX(
        CASE WHEN tipo_modelo = 'Ideal'
        THEN percentual_remoto_ou_flexivel END
    ) AS percentual_ideal,

    ROUND(
        MAX(
            CASE WHEN tipo_modelo = 'Ideal'
            THEN percentual_remoto_ou_flexivel END
        )
        -
        MAX(
            CASE WHEN tipo_modelo = 'Atual'
            THEN percentual_remoto_ou_flexivel END
        ),
        2
    ) AS diferenca_pp

FROM percentuais
GROUP BY survey_edition, regiao
ORDER BY survey_edition, regiao;
