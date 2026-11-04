
import sys

from pyspark.context import SparkContext
from pyspark.sql import functions as F
from pyspark.sql.types import (
    StructType,
    StructField,
    StringType,
    LongType,
    DoubleType
)

from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions


# ============================================================
# 1. CONFIGURAÇÕES DO JOB
# ============================================================

args = getResolvedOptions(sys.argv, ["JOB_NAME"])

sc = SparkContext.getOrCreate()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

job = Job(glueContext)
job.init(args["JOB_NAME"], args)


BUCKET = (
    "s3://tc3-state-of-data-br-2026-211125535484-us-east-1-an"
)

SILVER_PATHS = {
    "2023_2024": f"{BUCKET}/silver/state_of_data_2023_2024/",
    "2024_2025": f"{BUCKET}/silver/state_of_data_2024_2025/",
    "2025_2026": f"{BUCKET}/silver/state_of_data_2025_2026/"
}

GOLD_PATH = f"{BUCKET}/gold/indicadores_tecnologia/"


# ============================================================
# 2. MAPEAMENTO DAS COLUNAS POR EDIÇÃO
# ============================================================

TECNOLOGIAS = {

    "2023_2024": {

        "Python": "p4_d_3_python",
        "SQL": "p4_d_1_sql",

        "AWS": "p4_h_2_amazon_web_services_aws",
        "Azure": "p4_h_1_azure_microsoft",
        "GCP": "p4_h_3_google_cloud_gcp",

        "Power BI": "p4_j_1_microsoft_powerbi",
        "Tableau": "p4_j_3_tableau",
        "Looker": "p4_j_7_looker"
    },

    "2024_2025": {

        "Python": "4_d_3_python",
        "SQL": "4_d_1_sql",

        "AWS": "4_h_1_amazon_web_services_aws",
        "Azure": "4_h_3_azure_microsoft",
        "GCP": "4_h_2_google_cloud_gcp",

        "Power BI": "4_j_1_microsoft_powerbi",
        "Tableau": "4_j_3_tableau",
        "Looker": "4_j_7_looker"
    },

    "2025_2026": {

        "Python": "4_c_3_python",
        "SQL": "4_c_1_sql",

        "AWS": "4_e_1_amazon_web_services_aws",
        "Azure": "4_e_3_azure_microsoft",
        "GCP": "4_e_2_google_cloud_gcp",

        "Power BI": "4_g_1_microsoft_powerbi",
        "Tableau": "4_g_3_tableau",
        "Looker": "4_g_7_looker"
    }
}


# ============================================================
# 3. PROCESSAMENTO DOS INDICADORES
# ============================================================

resultados = []

for edicao, caminho in SILVER_PATHS.items():

    print("\n" + "=" * 70)
    print(f"PROCESSANDO EDIÇÃO: {edicao}")
    print("=" * 70)

    df = spark.read.parquet(caminho)

    total_respostas = df.count()

    print(f"Total de respostas: {total_respostas}")

    mapeamento = TECNOLOGIAS[edicao]

    # --------------------------------------------------------
    # 3.1 VALIDAÇÃO DAS COLUNAS
    # --------------------------------------------------------

    colunas_ausentes = [
        coluna
        for coluna in mapeamento.values()
        if coluna not in df.columns
    ]

    if colunas_ausentes:

        raise ValueError(
            f"Colunas não encontradas na edição {edicao}: "
            f"{colunas_ausentes}"
        )

    print("Todas as 8 colunas foram encontradas.")

    # --------------------------------------------------------
    # 3.2 CÁLCULO DOS INDICADORES
    # --------------------------------------------------------

    for tecnologia, nome_coluna in mapeamento.items():

        valor = F.trim(
            F.col(nome_coluna).cast("string")
        )

        agregacao = df.agg(

            F.sum(
                F.when(
                    valor.isin("0", "1"),
                    1
                ).otherwise(0)
            ).alias("respostas_validas"),

            F.sum(
                F.when(
                    valor == "1",
                    1
                ).otherwise(0)
            ).alias("quantidade")

        ).collect()[0]

        respostas_validas = int(
            agregacao["respostas_validas"] or 0
        )

        quantidade = int(
            agregacao["quantidade"] or 0
        )

        if respostas_validas > 0:

            percentual = (
                quantidade * 100.0 / respostas_validas
            )

        else:

            percentual = 0.0

        resultados.append((

            edicao,
            tecnologia,
            respostas_validas,
            quantidade,
            float(percentual)

        ))

        print(
            f"{tecnologia}: "
            f"{quantidade}/{respostas_validas} "
            f"({percentual:.2f}%)"
        )


# ============================================================
# 4. CRIAÇÃO DO DATAFRAME GOLD
# ============================================================

schema = StructType([

    StructField(
        "survey_edition",
        StringType(),
        False
    ),

    StructField(
        "indicador",
        StringType(),
        False
    ),

    StructField(
        "respostas_validas",
        LongType(),
        False
    ),

    StructField(
        "quantidade",
        LongType(),
        False
    ),

    StructField(
        "percentual",
        DoubleType(),
        False
    )

])

df_gold = spark.createDataFrame(
    resultados,
    schema=schema
)


# ============================================================
# 5. VALIDAÇÃO DO RESULTADO
# ============================================================

df_gold = df_gold.orderBy(
    "survey_edition",
    "indicador"
)

print("\n" + "=" * 70)
print("RESULTADO FINAL - INDICADORES DE TECNOLOGIA")
print("=" * 70)

df_gold.show(100, truncate=False)

total_indicadores = df_gold.count()

print(
    f"Total de indicadores gerados: {total_indicadores}"
)

if total_indicadores != 24:

    raise ValueError(
        "Quantidade incorreta de indicadores. "
        "Esperados: 24."
    )


# ============================================================
# 6. GRAVAÇÃO NA CAMADA GOLD
# ============================================================

(
    df_gold
    .coalesce(1)
    .write
    .mode("overwrite")
    .format("parquet")
    .option("compression", "snappy")
    .save(GOLD_PATH)
)

print("\n" + "=" * 70)
print("CAMADA GOLD GRAVADA COM SUCESSO!")
print(f"Destino: {GOLD_PATH}")
print("=" * 70)


# ============================================================
# 7. FINALIZAÇÃO DO JOB
# ============================================================

job.commit()
