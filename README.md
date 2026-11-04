
# TECH CHALLENGE 03
## State of Data Brasil — Engenharia de Dados e Analytics

## 1. Sobre o projeto

Este projeto foi desenvolvido como parte do Tech Challenge da Fase 3 da FIAP, com o objetivo de construir um pipeline de Engenharia de Dados em nuvem utilizando as três edições mais recentes disponíveis da pesquisa State of Data Brasil, realizada pela comunidade Data Hackers.

A solução utiliza serviços da Amazon Web Services (AWS) para ingestão, armazenamento, processamento, organização e análise dos dados.

O projeto busca compreender a evolução do mercado brasileiro de dados, considerando aspectos como perfil profissional, diversidade, remuneração, tecnologias utilizadas, modelos de trabalho e adoção da Inteligência Artificial nas empresas.

## 2. Objetivos

- Construir um pipeline de dados em nuvem utilizando serviços AWS.
- Armazenar os dados em camadas Bronze, Silver e Gold.
- Processar e transformar os arquivos utilizando PySpark no AWS Glue.
- Organizar e disponibilizar os dados por meio do AWS Glue Data Catalog.
- Realizar consultas analíticas utilizando Amazon Athena.
- Comparar indicadores das três edições da pesquisa.
- Identificar tendências e oportunidades relacionadas ao mercado de dados e à adoção de IA.
- Produzir análises que apoiem decisões estratégicas de empresas.

## 3. Fonte de dados

A fonte utilizada é a pesquisa State of Data Brasil, disponibilizada pela comunidade Data Hackers.

Foram utilizadas três edições:

- 2023–2024
- 2024–2025
- 2025–2026

### Volume de dados

| Edição | Registros |
|---|---:|
| 2023–2024 | 5.293 |
| 2024–2025 | 5.217 |
| 2025–2026 | 3.495 |
| **Total** | **14.005** |

Os arquivos originais foram preservados na camada Bronze.

## 4. Arquitetura da solução

A arquitetura foi organizada utilizando os seguintes serviços AWS:

- **Amazon S3:** armazenamento dos arquivos e das camadas de dados.
- **AWS Glue:** processamento e transformação dos dados utilizando PySpark.
- **AWS Glue Data Catalog:** catálogo de metadados das tabelas.
- **Amazon Athena:** execução de consultas SQL e análises sobre os dados armazenados no S3.

A solução utiliza a arquitetura Medalhão, dividida em três camadas:

### Bronze
Armazena os arquivos CSV originais das três edições da pesquisa, preservando os dados de origem.

### Silver
Contém os dados tratados e padronizados em formato Parquet, com identificação da edição, caminho do arquivo de origem e horário de processamento.

### Gold
Contém conjuntos de dados consolidados e preparados para análises:

- Perfil profissional.
- Indicadores de Inteligência Artificial.
- Indicadores de tecnologia.

## 5. Pipeline de processamento

O processamento foi dividido em quatro Jobs do AWS Glue:

| Job | Descrição |
|---|---|
| 01 — Bronze para Silver | Leitura dos CSVs, padronização dos nomes das colunas e gravação em Parquet. |
| 02 — Silver para Gold Perfil | Consolidação de gênero, região, cargo, senioridade e faixa salarial. |
| 03 — Silver para Gold IA | Cálculo dos indicadores de adoção, prioridade, iniciativas, barreiras e resultados de IA. |
| 04 — Silver para Gold Tecnologia | Cálculo dos indicadores de Python, SQL, AWS, Azure, GCP, Power BI, Tableau e Looker. |

Os arquivos-fonte dos Jobs estão disponíveis em `src/glue_jobs/`.

## 6. Organização do projeto

```text
TECH CHALLENGE/
└── 03/
    ├── data/
    ├── src/
    │   ├── glue_jobs/
    │   │   ├── 01_bronze_to_silver.py
    │   │   ├── 02_silver_to_gold_perfil.py
    │   │   ├── 03_silver_to_gold_ia.py
    │   │   └── 04_silver_to_gold_tecnologia.py
    │   └── sql/
    │       ├── 01_validacao_dados.sql
    │       ├── 02_perfil_profissional.sql
    │       ├── 03_diversidade_e_genero.sql
    │       ├── 04_regiao_e_senioridade.sql
    │       ├── 05_remuneracao.sql
    │       ├── 06_tecnologias.sql
    │       ├── 07_indicadores_ia.sql
    │       └── 08_modelo_de_trabalho.sql
    ├── results/
    │   ├── figures/
    │   └── metrics/
    ├── presentation/
    ├── requirements.txt
    └── README.md
```

## 7. Indicadores analisados

### 7.1 Perfil profissional

- Distribuição por gênero.
- Distribuição regional.
- Cargos mais frequentes.
- Distribuição por senioridade.
- Faixas salariais.

### 7.2 Diversidade e remuneração

- Relação entre gênero e senioridade.
- Distribuição salarial por gênero.
- Relação entre gênero, senioridade e remuneração.
- Comparação das faixas salariais entre as edições.

### 7.3 Tecnologias

- Utilização de Python e SQL.
- Adoção de provedores de nuvem: AWS, Azure e GCP.
- Utilização de ferramentas de BI: Power BI, Tableau e Looker.

### 7.4 Inteligência Artificial

- Uso individual de IA generativa.
- Prioridade estratégica de IA nas empresas.
- Iniciativas corporativas de IA.
- Barreiras para adoção de IA.
- Resultados dos projetos de IA.

### 7.5 Modelos de trabalho

- Modelo de trabalho atual.
- Modelo de trabalho ideal.
- Diferenças entre preferência e realidade.
- Comparação por senioridade e região.

## 8. Principais descobertas

As análises realizadas identificaram tendências relevantes:

- O uso individual de IA generativa no trabalho aumentou de 80,97% para 98,15% entre a primeira e a terceira edição.
- A proporção de participantes que consideram a IA uma das principais prioridades ou a principal prioridade da empresa passou de 36,16% para 60,58%.
- A participação feminina entre os respondentes diminuiu de 24,43% para 21,97%.
- A região Sudeste concentrou 64,42% dos participantes da edição 2025–2026.
- Python apresentou crescimento de utilização entre as edições.
- A preferência por modelos remotos ou híbridos permanece superior à proporção de profissionais que trabalham nesses formatos.
- A preparação dos dados empresariais continua sendo uma das principais barreiras para adoção de IA.

## 9. Considerações metodológicas

As pesquisas correspondem a amostras independentes, portanto as comparações históricas representam diferenças entre os grupos de respondentes de cada edição, e não o acompanhamento das mesmas pessoas ao longo do tempo.

Outros cuidados considerados:

- Os denominadores variam conforme a pergunta e a quantidade de respostas válidas.
- Algumas questões permitem múltiplas seleções.
- Categorias e estruturas dos questionários podem mudar entre edições.
- Os resultados não devem ser interpretados como representatividade estatística de todo o mercado brasileiro.
- Correlações e diferenças observadas não comprovam relações de causalidade.
- As comparações salariais não possuem ajuste inflacionário.

## 10. Tecnologias utilizadas

- Python
- PySpark
- SQL
- Amazon S3
- AWS Glue
- AWS Glue Data Catalog
- Amazon Athena
- Parquet
- Draw.io

## 11. Resultados esperados

A solução entrega uma estrutura de dados organizada e reutilizável, permitindo consultas analíticas sobre as três edições da pesquisa.

Os resultados servem como base para compreender tendências do mercado de dados, identificar desafios de diversidade e remuneração e avaliar o avanço da adoção de tecnologias e Inteligência Artificial nas organizações.

## 12. Autoria

**Aluna:** Izabella Costa Mendes  
**E-mail institucional:** rm375012@fiap.com.br  
**RM:** rm375012  
**Curso:** Pós Tech - Data Analytics  

**Instituição:** FIAP  
**Projeto:** Tech Challenge — Fase 3