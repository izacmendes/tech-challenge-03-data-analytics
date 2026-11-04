# Tech Challenge 03 – Data Analytics

## Análise da pesquisa State of Data Brasil utilizando AWS

Projeto desenvolvido como parte do Tech Challenge 03 da Pós-Tech em Data Analytics da FIAP.

O trabalho tem como objetivo desenvolver um pipeline de Engenharia de Dados em ambiente AWS e analisar as três edições mais recentes da pesquisa State of Data Brasil (2023–2024, 2024–2025 e 2025–2026).

A partir dos dados disponibilizados pela pesquisa, foram realizadas etapas de ingestão, organização, transformação e consolidação das informações, permitindo explorar tendências relacionadas ao mercado brasileiro de Dados e Tecnologia.

## Objetivos

- Construir um fluxo de processamento de dados utilizando serviços AWS.
- Organizar os dados em camadas Bronze, Silver e Gold.
- Realizar transformações utilizando AWS Glue e PySpark.
- Disponibilizar tabelas para consultas analíticas no Amazon Athena.
- Analisar perfil profissional, diversidade, remuneração e senioridade.
- Identificar tendências relacionadas às tecnologias utilizadas e à adoção de Inteligência Artificial.
- Comparar os modelos de trabalho atuais e desejados pelos participantes.

## Tecnologias utilizadas

- **Amazon S3:** armazenamento dos arquivos e organização do Data Lake.
- **AWS Glue:** processamento e transformação dos dados.
- **PySpark:** tratamento e consolidação das bases.
- **AWS Glue Data Catalog:** catalogação das tabelas.
- **Amazon Athena:** execução das consultas SQL.
- **Python:** análises e geração de gráficos.
- **SQL:** consultas e exploração dos dados.
- **Draw.io:** elaboração do diagrama de arquitetura.

## Arquitetura

O projeto utiliza uma arquitetura de Data Lake dividida em três camadas:

- **Bronze:** armazenamento dos arquivos originais das pesquisas.
- **Silver:** dados tratados e organizados em formato Parquet.
- **Gold:** dados consolidados e preparados para análises.

O processamento é realizado por Glue Jobs, enquanto o Amazon Athena é utilizado para consultar as tabelas disponibilizadas na camada Gold.

O diagrama da arquitetura está disponível na pasta `documentacao`.

## Bases de dados

Foram utilizadas três edições da pesquisa State of Data Brasil:

| Edição | Registros |
|---|---:|
| 2023–2024 | 5.293 |
| 2024–2025 | 5.217 |
| 2025–2026 | 3.495 |
| **Total** | **14.005** |

As bases apresentam informações sobre profissionais de Dados e Tecnologia no Brasil.

## Análises desenvolvidas

As consultas e os gráficos contemplam os seguintes temas:

1. Perfil profissional.
2. Diversidade e gênero.
3. Distribuição regional.
4. Senioridade.
5. Remuneração.
6. Tecnologias utilizadas.
7. Adoção e prioridade da Inteligência Artificial.
8. Barreiras e resultados dos projetos de IA.
9. Modelos de trabalho atuais e ideais.

## Estrutura do projeto

```text
03/
├── data/
├── documentacao/
│   ├── arquitetura.drawio
│   ├── arquitetura.png
│   └── arquitetura.pdf
├── results/
│   ├── figures/
│   └── metrics/
├── src/
│   └── glue_jobs/
├── sql/
├── README.md
└── requirements.txt
```

## Principais resultados

A análise identificou:

- Crescimento da utilização individual de IA generativa, chegando a 98,15% na edição 2025–2026.
- Aumento da utilização de Python, que alcançou 92,03% na edição mais recente.
- Crescimento da participação de iniciativas corporativas relacionadas à Inteligência Artificial.
- Concentração regional dos respondentes nas regiões Sudeste e Sul.
- Diferenças entre os modelos de trabalho atuais e aqueles considerados ideais pelos participantes.

Os resultados detalhados e suas respectivas visualizações estão disponíveis nas pastas `results/figures` e `results/metrics`.

## Documentação

O relatório técnico apresenta a arquitetura desenvolvida, as etapas de processamento, as consultas realizadas e a interpretação dos resultados.

Os scripts PySpark dos Glue Jobs estão disponíveis em `src/glue_jobs`, enquanto as consultas SQL utilizadas no Amazon Athena estão na pasta `sql`.

## Como reproduzir

A execução do projeto depende de uma conta AWS com permissões para utilizar os serviços S3, Glue e Athena, além da configuração dos recursos e caminhos de armazenamento utilizados na implementação.

As bibliotecas Python utilizadas nas análises estão listadas em `requirements.txt`.

Os scripts de processamento foram desenvolvidos para execução no ambiente AWS Glue.

## Autoria

**Izabella Costa Mendes**

Pós-Tech – Data Analytics  
FIAP  
RM: rm375012

## Fonte dos dados

Pesquisa State of Data Brasil – Data Hackers em parceria com a Bain.

Os dados utilizados neste projeto são provenientes das edições 2023–2024, 2024–2025 e 2025–2026.
