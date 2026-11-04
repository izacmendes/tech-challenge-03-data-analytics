
-- ============================================================
-- TECH CHALLENGE 03
-- 07 - INDICADORES DE INTELIGENCIA ARTIFICIAL
-- Amazon Athena
-- ============================================================

-- 1. Indicadores de IA por edição da pesquisa

SELECT
    survey_edition,
    indicador,
    categoria,
    respostas_validas,
    quantidade,
    percentual
FROM gold_indicadores_ia
WHERE indicador IN (
    'Uso individual de IA generativa',
    'Prioridade de IA nas empresas',
    'Uso descentralizado de IA generativa',
    'Direcionamento centralizado de IA generativa',
    'IA generativa em produtos externos',
    'IA generativa em produtos internos',
    'IA generativa como principal frente do negocio',
    'Barreiras para adoção de IA',
    'Resultados dos projetos de IA'
)
ORDER BY
    survey_edition,
    indicador,
    quantidade DESC;


-- 2. Evolução do uso individual de IA generativa

SELECT
    survey_edition,
    categoria,
    respostas_validas,
    quantidade,
    percentual
FROM gold_indicadores_ia
WHERE indicador = 'Uso individual de IA generativa'
ORDER BY survey_edition;


-- 3. Evolução das prioridades de IA nas empresas

SELECT
    survey_edition,
    categoria,
    respostas_validas,
    quantidade,
    percentual
FROM gold_indicadores_ia
WHERE indicador = 'Prioridade de IA nas empresas'
ORDER BY
    survey_edition,
    quantidade DESC;


-- 4. Barreiras para adoção de IA

SELECT
    survey_edition,
    categoria,
    respostas_validas,
    quantidade,
    percentual
FROM gold_indicadores_ia
WHERE indicador = 'Barreiras para adoção de IA'
ORDER BY
    survey_edition,
    quantidade DESC;


-- 5. Resultados dos projetos de IA

SELECT
    survey_edition,
    categoria,
    respostas_validas,
    quantidade,
    percentual
FROM gold_indicadores_ia
WHERE indicador = 'Resultados dos projetos de IA'
ORDER BY
    survey_edition,
    quantidade DESC;
