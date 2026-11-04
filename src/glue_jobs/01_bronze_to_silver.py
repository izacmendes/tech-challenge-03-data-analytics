
import sys
import re
import unicodedata

from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from awsglue.job import Job

from pyspark.context import SparkContext
from pyspark.sql import functions as F


# ============================================================
# 1. CONFIGURAÇÕES DO PROJETO
# ============================================================

args = getResolvedOptions(sys.argv, ["JOB_NAME"])

BUCKET = "tc3-state-of-data-br-2026-211125535484-us-east-1-an"

BRONZE_PATH = f"s3://{BUCKET}/bronze/"
SILVER_PATH = f"s3://{BUCKET}/silver/"

# Arquivos das três edições
FILES = [
    {
        "file": "state_of_data_2023_2024.csv",
        "edition": "2023_2024"
    },
    {
        "file": "state_of_data_2024_2025.csv",
        "edition": "2024_2025"
    },
    {
        "file": "state_of_data_2025_2026.csv",
        "edition": "2025_2026"
    }
]


# ============================================================
# 2. INICIALIZAÇÃO DO SPARK E GLUE
# ============================================================

sc = SparkContext.getOrCreate()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

job = Job(glueContext)
job.init(args["JOB_NAME"], args)

print("Iniciando processamento Bronze para Silver")


# ============================================================
# 3. PADRONIZAÇÃO DOS NOMES DAS COLUNAS
# ============================================================

def normalize_column_name(name, index, used_names):

    name = str(name).strip()

    # Remover acentos
    name = unicodedata.normalize("NFKD", name)
    name = "".join(
        char for char in name
        if not unicodedata.combining(char)
    )

    # Converter para minúsculas
    name = name.lower()

    # Substituir caracteres especiais por underline
    name = re.sub(r"[^a-z0-9]+", "_", name)

    # Remover underlines das extremidades
    name = name.strip("_")

    # Criar nome alternativo se estiver vazio
    if not name:
        name = f"coluna_{index}"

    # Garantir nomes únicos
    original = name
    counter = 1

    while name in used_names:
        name = f"{original}_{counter}"
        counter += 1

    used_names.add(name)

    return name


# ============================================================
# 4. LEITURA E TRANSFORMAÇÃO DOS CSVs
# ============================================================

for item in FILES:

    filename = item["file"]
    edition = item["edition"]

    input_path = BRONZE_PATH + filename
    output_path = SILVER_PATH + f"state_of_data_{edition}/"

    print("=" * 60)
    print(f"Processando edição: {edition}")
    print(f"Arquivo: {input_path}")

    # Ler CSV reconhecendo a primeira linha como cabeçalho
    df = (
        spark.read
        .format("csv")
        .option("header", "true")
        .option("inferSchema", "false")
        .option("sep", ",")
        .option("encoding", "UTF-8")
        .option("quote", '"')
        .option("escape", '"')
        .option("multiLine", "true")
        .option("mode", "PERMISSIVE")
        .load(input_path)
    )

    # Verificar se o arquivo foi carregado
    if len(df.columns) == 0:
        raise ValueError(
            f"Nenhuma coluna encontrada em {filename}"
        )

    # Padronizar nomes das colunas
    used_names = set()

    new_columns = [
        normalize_column_name(name, index, used_names)
        for index, name in enumerate(df.columns)
    ]

    df = df.toDF(*new_columns)

    # Adicionar identificação da edição
    df = (
        df
        .withColumn("survey_edition", F.lit(edition))
        .withColumn(
            "source_file_path",
            F.input_file_name()
        )
        .withColumn(
            "processing_timestamp",
            F.current_timestamp()
        )
    )

    # Contabilizar registros
    total_rows = df.count()

    print(f"Colunas identificadas: {len(df.columns)}")
    print(f"Registros encontrados: {total_rows}")

    # Gravar na camada Silver em Parquet
    (
        df.write
        .mode("overwrite")
        .format("parquet")
        .save(output_path)
    )

    print(f"Arquivo gravado em: {output_path}")
    print(f"Edição {edition} processada com sucesso!")


# ============================================================
# 5. FINALIZAÇÃO
# ============================================================

print("=" * 60)
print("PROCESSAMENTO BRONZE PARA SILVER FINALIZADO!")

job.commit()
