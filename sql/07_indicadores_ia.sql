
-- ============================================================
-- TECH CHALLENGE 03
-- 07 - INDICADORES DE INTELIGENCIA ARTIFICIAL
-- Amazon Athena
-- Banco: tc3_state_of_data
-- Tabela: gold_indicadores_ia
-- ============================================================

USE tc3_state_of_data;


-- ============================================================
-- 1. USO INDIVIDUAL DE IA GENERATIVA
-- ============================================================

SELECT
    survey_edition,
    categoria,
    respostas_validas,
    quantidade,
    ROUND(percentual, 2) AS percentual
FROM gold_indicadores_ia
WHERE indicador = 'Uso individual de IA generativa'
ORDER BY survey_edition, categoria;


-- ============================================================
-- 2. PRIORIDADE DE IA NAS EMPRESAS
-- ============================================================

SELECT
    survey_edition,
    categoria AS nivel_prioridade,
    respostas_validas,
    quantidade,
    ROUND(percentual, 2) AS percentual
FROM gold_indicadores_ia
WHERE indicador = 'Prioridade de IA nas empresas'
ORDER BY survey_edition, percentual DESC;


-- ============================================================
-- 3. INICIATIVAS CORPORATIVAS DE IA
-- ============================================================

SELECT
    survey_edition,
    indicador,
    respostas_validas,
    quantidade,
    ROUND(percentual, 2) AS percentual
FROM gold_indicadores_ia
WHERE indicador IN (
    'Uso descentralizado de IA generativa',
    'Direcionamento centralizado de IA generativa',
    'IA em produtos externos',
    'IA em produtos internos',
    'IA generativa como principal frente do negocio'
)
ORDER BY survey_edition, indicador;


-- ============================================================
-- 4. BARREIRAS PARA A ADOCAO DE IA
-- ============================================================

SELECT
    survey_edition,
    indicador,
    respostas_validas,
    quantidade,
    ROUND(percentual, 2) AS percentual
FROM gold_indicadores_ia
WHERE indicador IN (
    'Dados da empresa nao estao prontos para uso de IA',
    'ROI dos projetos de IA ainda nao comprovado'
)
ORDER BY survey_edition, indicador;


-- ============================================================
-- 5. RESULTADOS DOS PROJETOS DE IA
-- Disponivel somente para a edicao 2025-2026.
-- ============================================================

SELECT
    survey_edition,
    categoria AS resultado_projeto,
    respostas_validas,
    quantidade,
    ROUND(percentual, 2) AS percentual
FROM gold_indicadores_ia
WHERE indicador = 'Resultados dos projetos de IA'
ORDER BY percentual DESC;


-- ============================================================
-- 6. EVOLUCAO DO USO INDIVIDUAL DE IA
-- ============================================================

SELECT
    survey_edition,
    quantidade AS usuarios_de_ia,
    respostas_validas,
    ROUND(percentual, 2) AS percentual_uso
FROM gold_indicadores_ia
WHERE indicador = 'Uso individual de IA generativa'
  AND categoria = 'Utiliza IA generativa'
ORDER BY survey_edition;


-- ============================================================
-- 7. EVOLUCAO DAS PRINCIPAIS BARREIRAS
-- ============================================================

SELECT
    indicador,
    survey_edition,
    respostas_validas,
    quantidade,
    ROUND(percentual, 2) AS percentual
FROM gold_indicadores_ia
WHERE indicador IN (
    'Dados da empresa nao estao prontos para uso de IA',
    'ROI dos projetos de IA ainda nao comprovado'
)
ORDER BY indicador, survey_edition;


-- ============================================================
-- 8. VALIDACAO DA QUANTIDADE DE REGISTROS GOLD
-- ============================================================

SELECT
    survey_edition,
    COUNT(*) AS total_registros
FROM gold_indicadores_ia
GROUP BY survey_edition
ORDER BY survey_edition;
