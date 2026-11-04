
-- ============================================================
-- TECH CHALLENGE 03
-- 02 - PERFIL PROFISSIONAL
-- Amazon Athena
-- Banco: tc3_state_of_data
-- Tabela: gold_perfil_profissional
-- ============================================================

USE tc3_state_of_data;


-- ============================================================
-- 1. DISTRIBUICAO DE GENERO POR EDICAO
-- ============================================================

SELECT
    survey_edition,
    genero,
    COUNT(*) AS quantidade,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY survey_edition),
        2
    ) AS percentual
FROM gold_perfil_profissional
WHERE genero IS NOT NULL
  AND TRIM(genero) <> ''
GROUP BY survey_edition, genero
ORDER BY survey_edition, quantidade DESC;


-- ============================================================
-- 2. DISTRIBUICAO POR REGIAO
-- ============================================================

SELECT
    survey_edition,
    regiao,
    COUNT(*) AS quantidade,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY survey_edition),
        2
    ) AS percentual
FROM gold_perfil_profissional
WHERE regiao IS NOT NULL
  AND TRIM(regiao) <> ''
GROUP BY survey_edition, regiao
ORDER BY survey_edition, quantidade DESC;


-- ============================================================
-- 3. DISTRIBUICAO POR CARGO
-- ============================================================

SELECT
    survey_edition,
    cargo,
    COUNT(*) AS quantidade,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY survey_edition),
        2
    ) AS percentual
FROM gold_perfil_profissional
WHERE cargo IS NOT NULL
  AND TRIM(cargo) <> ''
GROUP BY survey_edition, cargo
ORDER BY survey_edition, quantidade DESC;


-- ============================================================
-- 4. DISTRIBUICAO POR SENIORIDADE
-- ============================================================

SELECT
    survey_edition,
    senioridade,
    COUNT(*) AS quantidade,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY survey_edition),
        2
    ) AS percentual
FROM gold_perfil_profissional
WHERE senioridade IS NOT NULL
  AND TRIM(senioridade) <> ''
GROUP BY survey_edition, senioridade
ORDER BY survey_edition, quantidade DESC;


-- ============================================================
-- 5. DISTRIBUICAO POR FAIXA SALARIAL
-- ============================================================

SELECT
    survey_edition,
    faixa_salarial,
    COUNT(*) AS quantidade,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY survey_edition),
        2
    ) AS percentual
FROM gold_perfil_profissional
WHERE faixa_salarial IS NOT NULL
  AND TRIM(faixa_salarial) <> ''
GROUP BY survey_edition, faixa_salarial
ORDER BY survey_edition, quantidade DESC;


-- ============================================================
-- 6. TOTAL DE RESPOSTAS VALIDAS POR DIMENSAO
-- ============================================================

SELECT
    survey_edition,
    COUNT(*) AS total_respostas,
    COUNT(genero) AS respostas_genero,
    COUNT(regiao) AS respostas_regiao,
    COUNT(cargo) AS respostas_cargo,
    COUNT(senioridade) AS respostas_senioridade,
    COUNT(faixa_salarial) AS respostas_faixa_salarial
FROM gold_perfil_profissional
GROUP BY survey_edition
ORDER BY survey_edition;
