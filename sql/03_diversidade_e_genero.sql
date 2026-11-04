
-- ============================================================
-- TECH CHALLENGE 03
-- 03 - DIVERSIDADE E GENERO
-- Amazon Athena
-- ============================================================

USE tc3_state_of_data;


-- 1. SENIORIDADE POR GENERO E EDICAO
-- Percentual calculado dentro de cada grupo de genero.

SELECT
    survey_edition,
    genero,
    senioridade,
    COUNT(*) AS quantidade,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (
            PARTITION BY survey_edition, genero
        ),
        2
    ) AS percentual
FROM gold_perfil_profissional
WHERE genero IS NOT NULL
  AND TRIM(genero) <> ''
  AND senioridade IS NOT NULL
  AND TRIM(senioridade) <> ''
GROUP BY survey_edition, genero, senioridade
ORDER BY survey_edition, genero, quantidade DESC;


-- 2. DISTRIBUICAO SALARIAL POR GENERO
-- Percentual dentro de cada grupo de genero.

SELECT
    survey_edition,
    genero,
    faixa_salarial,
    COUNT(*) AS quantidade,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (
            PARTITION BY survey_edition, genero
        ),
        2
    ) AS percentual
FROM gold_perfil_profissional
WHERE genero IS NOT NULL
  AND TRIM(genero) <> ''
  AND faixa_salarial IS NOT NULL
  AND TRIM(faixa_salarial) <> ''
GROUP BY survey_edition, genero, faixa_salarial
ORDER BY survey_edition, genero, quantidade DESC;


-- 3. DISTRIBUICAO SALARIAL POR GENERO E SENIORIDADE

SELECT
    survey_edition,
    genero,
    senioridade,
    faixa_salarial,
    COUNT(*) AS quantidade
FROM gold_perfil_profissional
WHERE genero IS NOT NULL
  AND TRIM(genero) <> ''
  AND senioridade IS NOT NULL
  AND TRIM(senioridade) <> ''
  AND faixa_salarial IS NOT NULL
  AND TRIM(faixa_salarial) <> ''
GROUP BY
    survey_edition,
    genero,
    senioridade,
    faixa_salarial
ORDER BY
    survey_edition,
    genero,
    senioridade,
    quantidade DESC;


-- 4. COMPARACAO DE PARTICIPACAO POR GENERO
-- Percentual de cada genero entre as respostas validas.

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
ORDER BY survey_edition, percentual DESC;
