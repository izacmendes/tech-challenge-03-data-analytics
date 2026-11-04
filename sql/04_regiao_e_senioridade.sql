
-- ============================================================
-- TECH CHALLENGE 03
-- 04 - REGIAO E SENIORIDADE
-- Amazon Athena
-- ============================================================

USE tc3_state_of_data;


-- 1. DISTRIBUICAO DE SENIORIDADE POR REGIAO

SELECT
    survey_edition,
    regiao,
    senioridade,
    COUNT(*) AS quantidade,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (
            PARTITION BY survey_edition, regiao
        ),
        2
    ) AS percentual
FROM gold_perfil_profissional
WHERE regiao IS NOT NULL
  AND TRIM(regiao) <> ''
  AND senioridade IS NOT NULL
  AND TRIM(senioridade) <> ''
GROUP BY survey_edition, regiao, senioridade
ORDER BY survey_edition, regiao, quantidade DESC;


-- 2. QUANTIDADE DE PARTICIPANTES POR REGIAO

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


-- 3. SENIORIDADE MAIS FREQUENTE EM CADA REGIAO

WITH distribuicao AS (
    SELECT
        survey_edition,
        regiao,
        senioridade,
        COUNT(*) AS quantidade
    FROM gold_perfil_profissional
    WHERE regiao IS NOT NULL
      AND TRIM(regiao) <> ''
      AND senioridade IS NOT NULL
      AND TRIM(senioridade) <> ''
    GROUP BY survey_edition, regiao, senioridade
),
ranking AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY survey_edition, regiao
            ORDER BY quantidade DESC
        ) AS posicao
    FROM distribuicao
)
SELECT
    survey_edition,
    regiao,
    senioridade AS senioridade_mais_frequente,
    quantidade
FROM ranking
WHERE posicao = 1
ORDER BY survey_edition, regiao;


-- 4. TAMANHO DAS AMOSTRAS POR REGIAO E EDICAO

SELECT
    survey_edition,
    regiao,
    COUNT(*) AS total_respostas,
    COUNT(senioridade) AS respostas_com_senioridade
FROM gold_perfil_profissional
WHERE regiao IS NOT NULL
  AND TRIM(regiao) <> ''
GROUP BY survey_edition, regiao
ORDER BY survey_edition, total_respostas DESC;
