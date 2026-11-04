
import sys
import re
import unicodedata
from datetime import datetime

from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions

from pyspark.context import SparkContext
from pyspark.sql import functions as F
from pyspark.sql.types import (
    StructType,
    StructField,
    StringType,
    LongType,
    DoubleType
)


# ============================================================
# 1. CONFIGURACOES
# ============================================================

BUCKET = "tc3-state-of-data-br-2026-211125535484-us-east-1-an"

SILVER_PATHS = {
    "2023_2024": f"s3://{BUCKET}/silver/state_of_data_2023_2024/",
    "2024_2025": f"s3://{BUCKET}/silver/state_of_data_2024_2025/",
    "2025_2026": f"s3://{BUCKET}/silver/state_of_data_2025_2026/"
}

GOLD_PATH = f"s3://{BUCKET}/gold/indicadores_ia/"


# ============================================================
# 2. INICIALIZACAO DO SPARK E GLUE
# ============================================================

args = getResolvedOptions(sys.argv, ["JOB_NAME"])

sc = SparkContext.getOrCreate()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

job = Job(glueContext)
job.init(args["JOB_NAME"], args)

spark.conf.set("spark.sql.sources.partitionOverwriteMode", "dynamic")

print("=" * 70)
print("INICIANDO JOB: SILVER PARA GOLD - INDICADORES DE IA")
print("=" * 70)


# ============================================================
# 3. LEITURA DOS ARQUIVOS SILVER
# ============================================================

dados = {}

for edicao, caminho in SILVER_PATHS.items():

    print(f"\nLendo edicao: {edicao}")
    print(f"Caminho: {caminho}")

    df = spark.read.parquet(caminho)

    dados[edicao] = df

    print(f"Quantidade de respostas: {df.count()}")
    print(f"Quantidade de colunas: {len(df.columns)}")


# ============================================================
# 4. FUNCOES AUXILIARES
# ============================================================

resultados = []


def normalizar_texto(texto):
    texto = str(texto).lower()

    texto = unicodedata.normalize("NFKD", texto)
    texto = "".join(
        c for c in texto
        if not unicodedata.combining(c)
    )

    return texto


def localizar_coluna(df, prefixos=None, termos=None, obrigatoria=True):
    """
    Localiza uma coluna pelo prefixo e/ou pelos termos do nome.
    Ajuda a lidar com pequenas diferenças entre as edições.
    """

    prefixos = prefixos or []
    termos = termos or []

    colunas = df.columns

    # Primeiro tenta localizar pelo prefixo.
    for prefixo in prefixos:

        candidatas = [
            c for c in colunas
            if c.lower().startswith(prefixo.lower())
        ]

        if candidatas:
            for coluna in candidatas:
                nome = normalizar_texto(coluna)

                if all(
                    normalizar_texto(t) in nome
                    for t in termos
                ):
                    print(f"Coluna localizada: {coluna}")
                    return coluna

    # Depois tenta localizar pelos termos.
    for coluna in colunas:

        nome = normalizar_texto(coluna)

        if all(
            normalizar_texto(t) in nome
            for t in termos
        ):
            print(f"Coluna localizada: {coluna}")
            return coluna

    if obrigatoria:
        print("\nERRO: coluna nao localizada.")
        print("Termos procurados:", termos)
        print("Colunas disponiveis:")
        for coluna in colunas:
            print(coluna)

        raise ValueError(
            f"Nao foi possivel localizar coluna com os termos: {termos}"
        )

    return None


def adicionar_resultado(
    edicao,
    indicador,
    categoria,
    respostas_validas,
    quantidade
):
    """
    Adiciona uma linha ao conjunto final de indicadores.
    """

    percentual = (
        (quantidade / respostas_validas) * 100
        if respostas_validas > 0
        else 0.0
    )

    resultados.append((
        edicao,
        indicador,
        str(categoria),
        int(respostas_validas),
        int(quantidade),
        float(percentual)
    ))


def processar_uso_individual(df, edicao, coluna):
    """
    Identifica quem utiliza IA generativa no trabalho.
    Uma resposta e considerada positiva quando contem 'Utilizo'.
    """

    print(f"\nProcessando uso individual de IA: {edicao}")

    coluna_ref = F.col(f"`{coluna}`")

    base = df.filter(
        coluna_ref.isNotNull() &
        (F.trim(coluna_ref.cast("string")) != "")
    )

    respostas_validas = base.count()

    utiliza = base.filter(
        F.regexp_like(
            coluna_ref.cast("string"),
            F.lit("(^|, )Utilizo")
        )
    ).count()

    nao_utiliza = respostas_validas - utiliza

    adicionar_resultado(
        edicao,
        "Uso individual de IA generativa",
        "Utiliza IA generativa",
        respostas_validas,
        utiliza
    )

    adicionar_resultado(
        edicao,
        "Uso individual de IA generativa",
        "Nao utiliza IA generativa",
        respostas_validas,
        nao_utiliza
    )


def processar_prioridade(df, edicao, coluna):
    """
    Distribui as respostas sobre a prioridade da IA generativa
    nas empresas.
    """

    print(f"\nProcessando prioridade de IA: {edicao}")

    coluna_ref = F.col(f"`{coluna}`")

    base = df.filter(
        coluna_ref.isNotNull() &
        (F.trim(coluna_ref.cast("string")) != "")
    )

    respostas_validas = base.count()

    agrupado = (
        base
        .groupBy(coluna_ref.cast("string").alias("categoria"))
        .count()
        .collect()
    )

    for linha in agrupado:

        adicionar_resultado(
            edicao,
            "Prioridade de IA nas empresas",
            linha["categoria"],
            respostas_validas,
            linha["count"]
        )


def processar_binaria(df, edicao, indicador, coluna):
    """
    Calcula a quantidade e percentual de respostas positivas (1).
    O denominador considera somente respostas validas.
    """

    print(f"\nProcessando indicador: {indicador} - {edicao}")

    coluna_ref = F.col(f"`{coluna}`")

    base = df.filter(
        coluna_ref.isNotNull() &
        (F.trim(coluna_ref.cast("string")) != "")
    )

    respostas_validas = base.count()

    quantidade_sim = base.filter(
        F.trim(coluna_ref.cast("string")) == "1"
    ).count()

    adicionar_resultado(
        edicao,
        indicador,
        "Sim",
        respostas_validas,
        quantidade_sim
    )


def processar_iniciativas(df, edicao):
    """
    Processa as cinco iniciativas corporativas de IA.
    """

    iniciativas = [
        (
            "Uso descentralizado de IA generativa",
            "f_1",
            ["colaboradores", "usando", "ai", "generativa"]
        ),
        (
            "Direcionamento centralizado de IA generativa",
            "f_2",
            ["direcionamento", "centralizado"]
        ),
        (
            "IA generativa em produtos externos",
            "f_4",
            ["produtos", "externos"]
        ),
        (
            "IA generativa em produtos internos",
            "f_5",
            ["produtos", "internos"]
        ),
        (
            "IA generativa como principal frente do negocio",
            "f_6",
            ["principal", "frente", "negocio"]
        )
    ]

    for indicador, sufixo, termos in iniciativas:

        coluna = localizar_coluna(
            df,
            prefixos=[
                f"p3_{sufixo}_",
                f"3_{sufixo}_"
            ],
            termos=termos
        )

        processar_binaria(
            df,
            edicao,
            indicador,
            coluna
        )



def processar_barreiras(df, edicao):
    """
    Processa as barreiras relacionadas a projetos de IA.
    """

    barreiras = [
        (
            "Dados da empresa nao estao prontos para uso de IA",
            ["dados", "empresa", "prontos"]
        ),
        (
            "ROI dos projetos de IA ainda nao comprovado",
            ["roi"]
        )
    ]

    for indicador, termos in barreiras:

        if edicao == "2025_2026" and indicador == "ROI dos projetos de IA ainda nao comprovado":
            coluna = "3_h_5_retorno_sobre_investimento_roi_nao_comprovado_de_ia_generativa"

        else:
            coluna = localizar_coluna(
                df,
                prefixos=["p3_g_", "3_g_"],
                termos=termos
            )

        processar_binaria(
            df,
            edicao,
            indicador,
            coluna
        )


def processar_resultados_projetos(df, edicao):
    """
    Processa os resultados dos projetos de IA da edicao 2025-2026.
    """

    coluna = localizar_coluna(
        df,
        prefixos=["3_g_", "p3_g_"],
        termos=[
            "bons",
            "resultados",
            "llms"
        ]
    )

    print("\nProcessando resultados dos projetos de IA.")

    coluna_ref = F.col(f"`{coluna}`")

    base = df.filter(
        coluna_ref.isNotNull() &
        (F.trim(coluna_ref.cast("string")) != "")
    )

    respostas_validas = base.count()

    agrupado = (
        base
        .groupBy(coluna_ref.cast("string").alias("categoria"))
        .count()
        .collect()
    )

    for linha in agrupado:

        adicionar_resultado(
            edicao,
            "Resultados dos projetos de IA",
            linha["categoria"],
            respostas_validas,
            linha["count"]
        )


# ============================================================
# 5. USO INDIVIDUAL DE IA GENERATIVA
# ============================================================

colunas_uso = {
    "2023_2024": "p4_m_utiliza_chatgpt_ou_llms_no_trabalho",
    "2024_2025": "4_m_usa_chatgpt_ou_copilot_no_trabalho",
    "2025_2026": "4_j_usa_chatgpt_ou_copilot_no_trabalho"
}

for edicao, coluna in colunas_uso.items():

    processar_uso_individual(
        dados[edicao],
        edicao,
        coluna
    )


# ============================================================
# 6. PRIORIDADE DE IA NAS EMPRESAS
# ============================================================

colunas_prioridade = {
    "2023_2024": "p3_e_ai_generativa_e_uma_prioridade_em_sua_empresa",
    "2024_2025": "3_e_ai_generativa_e_llm_e_uma_prioridade",
    "2025_2026": "3_e_ai_generativa_e_llm_e_uma_prioridade"
}

for edicao, coluna in colunas_prioridade.items():

    processar_prioridade(
        dados[edicao],
        edicao,
        coluna
    )


# ============================================================
# 7. INICIATIVAS CORPORATIVAS DE IA
# ============================================================

for edicao in dados:

    print("\n" + "=" * 60)
    print("INICIATIVAS CORPORATIVAS:", edicao)
    print("=" * 60)

    processar_iniciativas(
        dados[edicao],
        edicao
    )


# ============================================================
# 8. BARREIRAS PARA A ADOCAO DE IA
# ============================================================

for edicao in dados:

    print("\n" + "=" * 60)
    print("BARREIRAS DE IA:", edicao)
    print("=" * 60)

    processar_barreiras(
        dados[edicao],
        edicao
    )


# ============================================================
# 9. RESULTADOS DOS PROJETOS DE IA
# ============================================================

processar_resultados_projetos(
    dados["2025_2026"],
    "2025_2026"
)


# ============================================================
# 10. CRIACAO DO DATAFRAME GOLD
# ============================================================

print("\n" + "=" * 70)
print("CONSTRUINDO DATAFRAME GOLD")
print("=" * 70)

schema = StructType([
    StructField("survey_edition", StringType(), False),
    StructField("indicador", StringType(), False),
    StructField("categoria", StringType(), False),
    StructField("respostas_validas", LongType(), False),
    StructField("quantidade", LongType(), False),
    StructField("percentual", DoubleType(), False)
])

df_gold = spark.createDataFrame(
    resultados,
    schema=schema
)

df_gold = df_gold.dropDuplicates([
    "survey_edition",
    "indicador",
    "categoria"
])

print("\nSchema final:")
df_gold.printSchema()

print("\nQuantidade de linhas geradas:")
total_linhas = df_gold.count()
print(total_linhas)

if total_linhas == 0:
    raise ValueError(
        "O DataFrame Gold esta vazio. A gravacao foi interrompida."
    )

print("\nAmostra dos resultados:")
df_gold.show(30, truncate=False)


# ============================================================
# 11. GRAVACAO NA CAMADA GOLD
# ============================================================

print("\n" + "=" * 70)
print("GRAVANDO DADOS NA CAMADA GOLD")
print("=" * 70)

print(f"Destino: {GOLD_PATH}")

(
    df_gold
    .coalesce(1)
    .write
    .mode("overwrite")
    .option("compression", "snappy")
    .parquet(GOLD_PATH)
)

print("\nGRAVACAO CONCLUIDA!")
print(f"Destino: {GOLD_PATH}")


# ============================================================
# 12. VALIDACAO DA GRAVACAO
# ============================================================

print("\nValidando arquivos gravados...")

df_validacao = spark.read.parquet(GOLD_PATH)

quantidade_gravada = df_validacao.count()

print(f"Linhas geradas: {total_linhas}")
print(f"Linhas gravadas: {quantidade_gravada}")

if quantidade_gravada != total_linhas:
    raise ValueError(
        "A quantidade de linhas gravadas e diferente da quantidade gerada."
    )

print("\nValidacao concluida com sucesso!")

df_validacao.show(30, truncate=False)


# ============================================================
# 13. FINALIZACAO
# ============================================================

print("\n" + "=" * 70)
print("JOB FINALIZADO COM SUCESSO")
print("=" * 70)

job.commit()
