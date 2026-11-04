
import sys

from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from awsglue.job import Job

from pyspark.context import SparkContext
from pyspark.sql import functions as F


# ============================================================
# 1. CONFIGURACOES
# ============================================================

args = getResolvedOptions(sys.argv, ["JOB_NAME"])

BUCKET = "tc3-state-of-data-br-2026-211125535484-us-east-1-an"

SILVER_PATH = f"s3://{BUCKET}/silver/"
GOLD_PATH = f"s3://{BUCKET}/gold/perfil_profissional/"


# ============================================================
# 2. INICIALIZACAO DO SPARK E GLUE
# ============================================================

sc = SparkContext.getOrCreate()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

job = Job(glueContext)
job.init(args["JOB_NAME"], args)


# ============================================================
# 3. MAPEAMENTO DAS COLUNAS POR EDICAO
# ============================================================

EDICOES = [
    {
        "edicao": "2023_2024",
        "tabela": "state_of_data_2023_2024",
        "colunas": {
            "genero": "p1_b_genero",
            "regiao": "p1_i_2_regiao_onde_mora",
            "cargo": "p2_f_cargo_atual",
            "senioridade": "p2_g_nivel",
            "faixa_salarial": "p2_h_faixa_salarial"
        }
    },
    {
        "edicao": "2024_2025",
        "tabela": "state_of_data_2024_2025",
        "colunas": {
            "genero": "1_b_genero",
            "regiao": "1_i_2_regiao_onde_mora",
            "cargo": "2_f_cargo_atual",
            "senioridade": "2_g_nivel",
            "faixa_salarial": "2_h_faixa_salarial"
        }
    },
    {
        "edicao": "2025_2026",
        "tabela": "state_of_data_2025_2026",
        "colunas": {
            "genero": "1_b_genero",
            "regiao": "1_i_2_regiao_onde_mora",
            "cargo": "2_f_cargo_atual",
            "senioridade": "2_g_nivel",
            "faixa_salarial": "2_h_faixa_salarial"
        }
    }
]


# ============================================================
# 4. LEITURA E PADRONIZACAO DOS DADOS SILVER
# ============================================================

dataframes = []

for item in EDICOES:

    edicao = item["edicao"]
    tabela = item["tabela"]
    colunas = item["colunas"]

    origem = SILVER_PATH + tabela + "/"

    print(f"Processando edicao: {edicao}")
    print(f"Lendo dados de: {origem}")

    df = spark.read.parquet(origem)

    def coluna_limpa(nome_original, nome_destino):
        valor = F.trim(F.col(nome_original))

        return (
            F.when(valor == "", F.lit(None).cast("string"))
             .otherwise(valor)
             .alias(nome_destino)
        )

    df_gold = df.select(
        F.lit(edicao).alias("survey_edition"),
        coluna_limpa(colunas["genero"], "genero"),
        coluna_limpa(colunas["regiao"], "regiao"),
        coluna_limpa(colunas["cargo"], "cargo"),
        coluna_limpa(colunas["senioridade"], "senioridade"),
        coluna_limpa(colunas["faixa_salarial"], "faixa_salarial")
    )

    print(f"Total de registros da edicao: {df_gold.count()}")

    dataframes.append(df_gold)


# ============================================================
# 5. CONSOLIDACAO DAS TRES EDICOES
# ============================================================

gold_df = dataframes[0]

for df in dataframes[1:]:
    gold_df = gold_df.unionByName(df)

total_gold = gold_df.count()

print("==========================================")
print(f"TOTAL DE REGISTROS NA GOLD: {total_gold}")
print("==========================================")


# ============================================================
# 6. GRAVACAO DA CAMADA GOLD EM PARQUET
# ============================================================

(
    gold_df.write
    .mode("overwrite")
    .format("parquet")
    .option("compression", "snappy")
    .save(GOLD_PATH)
)

print(f"Dados Gold gravados em: {GOLD_PATH}")


# ============================================================
# 7. VALIDACAO FINAL
# ============================================================

gold_df.groupBy("survey_edition").count().show()

print("CAMADA GOLD - PERFIL PROFISSIONAL CONCLUIDA!")


job.commit()
