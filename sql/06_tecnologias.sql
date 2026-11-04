
-- ============================================================
-- TECH CHALLENGE 03
-- 06 - INDICADORES DE TECNOLOGIA
-- Amazon Athena
-- ============================================================

USE tc3_state_of_data;


-- 1. TODOS OS INDICADORES DE TECNOLOGIA

SELECT
    survey_edition,
    indicador,
    respostas_validas,
    quantidade,
    ROUND(percentual, 2) AS percentual
FROM gold_indicadores_tecnologia
ORDER BY survey_edition, indicador;


-- 2. EVOLUCAO DO USO DE PYTHON E SQL

SELECT
    survey_edition,
    indicador,
    respostas_validas,
    quantidade,
    ROUND(percentual, 2) AS percentual
FROM gold_indicadores_tecnologia
WHERE indicador IN ('Python', 'SQL')
ORDER BY indicador, survey_edition;


-- 3. COMPARACAO ENTRE PROVEDORES DE NUVEM

SELECT
    survey_edition,
    indicador AS provedor_nuvem,
    respostas_validas,
    quantidade,
    ROUND(percentual, 2) AS percentual
FROM gold_indicadores_tecnologia
WHERE indicador IN ('AWS', 'Azure', 'GCP')
ORDER BY survey_edition, percentual DESC;


-- 4. COMPARACAO ENTRE FERRAMENTAS DE BI

SELECT
    survey_edition,
    indicador AS ferramenta_bi,
    respostas_validas,
    quantidade,
    ROUND(percentual, 2) AS percentual
FROM gold_indicadores_tecnologia
WHERE indicador IN ('Power BI', 'Tableau', 'Looker')
ORDER BY survey_edition, percentual DESC;


-- 5. EVOLUCAO DO PERCENTUAL POR TECNOLOGIA

SELECT
    indicador,
    MAX(CASE
        WHEN survey_edition = '2023_2024'
        THEN percentual
    END) AS percentual_2023_2024,

    MAX(CASE
        WHEN survey_edition = '2024_2025'
        THEN percentual
    END) AS percentual_2024_2025,

    MAX(CASE
        WHEN survey_edition = '2025_2026'
        THEN percentual
    END) AS percentual_2025_2026

FROM gold_indicadores_tecnologia
GROUP BY indicador
ORDER BY indicador;


-- 6. VALIDACAO DA QUANTIDADE DE INDICADORES

SELECT
    survey_edition,
    COUNT(*) AS total_indicadores
FROM gold_indicadores_tecnologia
GROUP BY survey_edition
ORDER BY survey_edition;
