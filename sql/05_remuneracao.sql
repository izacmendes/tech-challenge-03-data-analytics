
-- ============================================================
-- TECH CHALLENGE 03
-- 05 - REMUNERACAO
-- Amazon Athena
-- ============================================================

USE tc3_state_of_data;


-- 1. DISTRIBUICAO GERAL DAS FAIXAS SALARIAIS

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


-- 2. FAIXA SALARIAL MAIS FREQUENTE POR EDICAO

WITH distribuicao AS (
    SELECT
        survey_edition,
        faixa_salarial,
        COUNT(*) AS quantidade
    FROM gold_perfil_profissional
    WHERE faixa_salarial IS NOT NULL
      AND TRIM(faixa_salarial) <> ''
    GROUP BY survey_edition, faixa_salarial
),
ranking AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY survey_edition
            ORDER BY quantidade DESC
        ) AS posicao
    FROM distribuicao
)
SELECT
    survey_edition,
    faixa_salarial AS faixa_mais_frequente,
    quantidade
FROM ranking
WHERE posicao = 1
ORDER BY survey_edition;


-- 3. DISTRIBUICAO SALARIAL POR SENIORIDADE

SELECT
    survey_edition,
    senioridade,
    faixa_salarial,
    COUNT(*) AS quantidade,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (
            PARTITION BY survey_edition, senioridade
        ),
        2
    ) AS percentual
FROM gold_perfil_profissional
WHERE senioridade IS NOT NULL
  AND TRIM(senioridade) <> ''
  AND faixa_salarial IS NOT NULL
  AND TRIM(faixa_salarial) <> ''
GROUP BY survey_edition, senioridade, faixa_salarial
ORDER BY survey_edition, senioridade, quantidade DESC;


-- 4. QUANTIDADE DE RESPOSTAS SALARIAIS POR EDICAO

SELECT
    survey_edition,
    COUNT(*) AS total_registros,
    COUNT(faixa_salarial) AS respostas_salariais_validas
FROM gold_perfil_profissional
GROUP BY survey_edition
ORDER BY survey_edition;
