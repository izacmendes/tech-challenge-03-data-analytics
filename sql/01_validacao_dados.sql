
-- ============================================================
-- TECH CHALLENGE 03
-- 01 - VALIDACAO DOS DADOS
-- Amazon Athena
-- ============================================================


-- 1. Quantidade de registros por edição
-- Tabela: Perfil profissional

SELECT
    survey_edition,
    COUNT(*) AS total_registros
FROM gold_perfil_profissional
GROUP BY survey_edition
ORDER BY survey_edition;


-- 2. Quantidade de registros por edição
-- Tabela: Indicadores de IA

SELECT
    survey_edition,
    COUNT(*) AS total_registros
FROM gold_indicadores_ia
GROUP BY survey_edition
ORDER BY survey_edition;


-- 3. Quantidade de registros por edição
-- Tabela: Indicadores de tecnologia

SELECT
    survey_edition,
    COUNT(*) AS total_registros
FROM gold_indicadores_tecnologia
GROUP BY survey_edition
ORDER BY survey_edition;


-- 4. Verificação de valores nulos
-- Tabela: Perfil profissional

SELECT
    survey_edition,
    COUNT(*) AS total_registros,
    SUM(CASE WHEN genero IS NULL THEN 1 ELSE 0 END) AS genero_nulo,
    SUM(CASE WHEN regiao IS NULL THEN 1 ELSE 0 END) AS regiao_nula,
    SUM(CASE WHEN cargo IS NULL THEN 1 ELSE 0 END) AS cargo_nulo,
    SUM(CASE WHEN senioridade IS NULL THEN 1 ELSE 0 END) AS senioridade_nula,
    SUM(CASE WHEN faixa_salarial IS NULL THEN 1 ELSE 0 END) AS salario_nulo
FROM gold_perfil_profissional
GROUP BY survey_edition
ORDER BY survey_edition;


-- 5. Verificação de valores nulos
-- Tabela: Indicadores de IA

SELECT
    survey_edition,
    COUNT(*) AS total_registros,
    SUM(CASE WHEN indicador IS NULL THEN 1 ELSE 0 END) AS indicador_nulo,
    SUM(CASE WHEN categoria IS NULL THEN 1 ELSE 0 END) AS categoria_nula,
    SUM(CASE WHEN respostas_validas IS NULL THEN 1 ELSE 0 END) AS respostas_validas_nulas,
    SUM(CASE WHEN quantidade IS NULL THEN 1 ELSE 0 END) AS quantidade_nula,
    SUM(CASE WHEN percentual IS NULL THEN 1 ELSE 0 END) AS percentual_nulo
FROM gold_indicadores_ia
GROUP BY survey_edition
ORDER BY survey_edition;


-- 6. Verificação de valores nulos
-- Tabela: Indicadores de tecnologia

SELECT
    survey_edition,
    COUNT(*) AS total_registros,
    SUM(CASE WHEN indicador IS NULL THEN 1 ELSE 0 END) AS indicador_nulo,
    SUM(CASE WHEN respostas_validas IS NULL THEN 1 ELSE 0 END) AS respostas_validas_nulas,
    SUM(CASE WHEN quantidade IS NULL THEN 1 ELSE 0 END) AS quantidade_nula,
    SUM(CASE WHEN percentual IS NULL THEN 1 ELSE 0 END) AS percentual_nulo
FROM gold_indicadores_tecnologia
GROUP BY survey_edition
ORDER BY survey_edition;


-- 7. Conferência das edições disponíveis

SELECT DISTINCT
    survey_edition
FROM gold_perfil_profissional
ORDER BY survey_edition;


-- 8. Verificação de percentuais fora do intervalo esperado
-- Tabela: Indicadores de IA

SELECT
    survey_edition,
    indicador,
    categoria,
    percentual
FROM gold_indicadores_ia
WHERE percentual < 0
   OR percentual > 100
ORDER BY survey_edition, indicador;


-- 9. Verificação de percentuais fora do intervalo esperado
-- Tabela: Indicadores de tecnologia

SELECT
    survey_edition,
    indicador,
    percentual
FROM gold_indicadores_tecnologia
WHERE percentual < 0
   OR percentual > 100
ORDER BY survey_edition, indicador;
