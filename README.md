# Tech Challenge 03 – Data Analytics

## Engenharia de Dados e análise da pesquisa State of Data Brasil

Projeto desenvolvido como parte do Tech Challenge 03 da Pós-Tech em Data Analytics da FIAP.

O objetivo foi construir um pipeline de Engenharia de Dados utilizando serviços da AWS e analisar as três edições mais recentes da pesquisa State of Data Brasil: 2023–2024, 2024–2025 e 2025–2026.

A partir dessas bases, foram realizadas etapas de ingestão, armazenamento, tratamento e transformação dos dados, com posterior disponibilização de informações consolidadas para consultas e análises.

O projeto também buscou identificar mudanças no perfil dos profissionais de Dados e Tecnologia no Brasil, considerando aspectos como diversidade, remuneração, tecnologias utilizadas, adoção de Inteligência Artificial e modelos de trabalho.

---

## Objetivos do projeto

- Construir um pipeline de dados em ambiente AWS.
- Organizar as informações em um Data Lake com as camadas Bronze, Silver e Gold.
- Realizar o processamento dos arquivos utilizando AWS Glue e PySpark.
- Catalogar os dados tratados para facilitar sua consulta.
- Desenvolver consultas SQL no Amazon Athena.
- Consolidar indicadores das três edições da pesquisa.
- Gerar gráficos e análises para identificar tendências do mercado brasileiro de Dados e Tecnologia.

## Fonte de dados

Foram utilizadas três edições da pesquisa State of Data Brasil, realizada pela comunidade Data Hackers em parceria com a Bain.

| Edição | Registros | Colunas |
|---|---:|---:|
| 2023–2024 | 5.293 | 399 |
| 2024–2025 | 5.217 | 403 |
| 2025–2026 | 3.495 | 388 |
| **Total** | **14.005** | — |

As bases reúnem informações sobre profissionais que atuam em diferentes áreas relacionadas a Dados e Tecnologia no Brasil.

Os resultados representam as respostas dos participantes de cada edição e devem ser interpretados considerando as características e diferenças entre os questionários.

## Tecnologias e serviços utilizados

| Tecnologia | Aplicação no projeto |
|---|---|
| Amazon S3 | Armazenamento dos dados e organização do Data Lake |
| AWS Glue | Processamento e transformação dos dados |
| PySpark | Tratamento e consolidação das bases |
| AWS Glue Data Catalog | Catalogação das tabelas |
| Amazon Athena | Execução das consultas SQL |
| Python | Análise e geração de gráficos |
| SQL | Consultas e exploração dos dados |
| Draw.io | Elaboração do diagrama de arquitetura |

## Arquitetura da solução

A arquitetura foi organizada seguindo o conceito de Data Lake, com três camadas de processamento:

### Bronze

Armazena os arquivos originais das pesquisas no Amazon S3, preservando os dados recebidos da fonte.

### Silver

Recebe os dados após o processamento inicial realizado pelo AWS Glue com PySpark. Nessa etapa, os arquivos são tratados e disponibilizados em formato Parquet.

### Gold

Contém os dados consolidados e organizados por assunto, preparados para as consultas analíticas.

Foram desenvolvidos três conjuntos principais de informações:

- Perfil profissional;
- Indicadores de Inteligência Artificial;
- Indicadores de tecnologia.

As tabelas Gold foram disponibilizadas para consulta no Amazon Athena por meio de comandos SQL.

### Diagrama da arquitetura

O diagrama completo, incluindo o fluxo entre os serviços AWS e as etapas de processamento, está disponível na pasta `documentacao`.

## Processamento dos dados

O pipeline foi dividido em quatro Glue Jobs:

| Script | Responsabilidade |
|---|---|
| `01_bronze_to_silver.py` | Leitura dos arquivos originais e transformação para Silver |
| `02_silver_to_gold_perfil.py` | Consolidação das informações de perfil profissional |
| `03_silver_to_gold_ia.py` | Construção dos indicadores de Inteligência Artificial |
| `04_silver_to_gold_tecnologia.py` | Consolidação dos indicadores de tecnologia |

Os processos foram desenvolvidos com PySpark e executados no ambiente AWS Glue.

## Consultas SQL

Foram desenvolvidas oito consultas no Amazon Athena para validar e explorar as informações disponibilizadas na camada Gold.

| Arquivo | Tema |
|---|---|
| `01_validacao_dados.sql` | Validação dos dados |
| `02_perfil_profissional.sql` | Perfil profissional |
| `03_diversidade_e_genero.sql` | Diversidade e gênero |
| `04_regiao_e_senioridade.sql` | Região e senioridade |
| `05_remuneracao.sql` | Remuneração |
| `06_tecnologias.sql` | Tecnologias utilizadas |
| `07_indicadores_ia.sql` | Indicadores de Inteligência Artificial |
| `08_modelo_de_trabalho.sql` | Modelos de trabalho |

Os resultados das consultas foram utilizados na construção dos arquivos CSV e dos gráficos apresentados no projeto.

## Análises realizadas

O estudo foi dividido em diferentes temas para facilitar a comparação entre as edições da pesquisa.

### Perfil profissional e diversidade

Análise da distribuição dos participantes por gênero, região, cargo e senioridade.

### Remuneração

Comparação das faixas salariais declaradas pelos participantes, incluindo análises por gênero.

### Tecnologias

Identificação das tecnologias mais utilizadas, considerando linguagens de programação, bancos de dados, plataformas de nuvem e ferramentas de Business Intelligence.

### Inteligência Artificial

Análise da utilização individual de IA generativa, prioridade nas empresas, iniciativas de adoção, barreiras e resultados dos projetos.

### Modelos de trabalho

Comparação entre os modelos atuais e os modelos considerados ideais pelos participantes, incluindo diferenças por senioridade e região.

## Principais resultados

Entre os resultados observados nas três edições, destacam-se:

- A utilização individual de IA generativa chegou a 98,15% na edição 2025–2026.
- Python apresentou crescimento e alcançou 92,03% de utilização na edição mais recente.
- SQL permaneceu entre as tecnologias mais utilizadas pelos participantes.
- A participação feminina apresentou redução proporcional entre a primeira e a última edição analisada.
- A região Sudeste concentrou a maior parcela dos respondentes.
- A falta de preparação dos dados e a dificuldade de comprovar o retorno dos projetos permaneceram entre as principais barreiras para a adoção de IA.
- Os participantes demonstraram preferência por modelos de trabalho remoto e híbrido flexível.

Os resultados detalhados estão disponíveis nos arquivos CSV e nos gráficos do projeto.

## Estrutura do repositório

```text
tech-challenge-03-data-analytics/
│
├── data/
│
├── documentacao/
│
├── results/
│   ├── figures/
│   └── metrics/
│
├── src/
│   └── glue_jobs/
│       ├── 01_bronze_to_silver.py
│       ├── 02_silver_to_gold_perfil.py
│       ├── 03_silver_to_gold_ia.py
│       └── 04_silver_to_gold_tecnologia.py
│
├── sql/
│   ├── 01_validacao_dados.sql
│   ├── 02_perfil_profissional.sql
│   ├── 03_diversidade_e_genero.sql
│   ├── 04_regiao_e_senioridade.sql
│   ├── 05_remuneracao.sql
│   ├── 06_tecnologias.sql
│   ├── 07_indicadores_ia.sql
│   └── 08_modelo_de_trabalho.sql
│
├── requirements.txt
└── README.md
```

A pasta `documentacao` contém o relatório técnico e os arquivos relacionados ao diagrama da arquitetura. A pasta `results` reúne os gráficos e os arquivos CSV gerados durante as análises.

## Como executar

O processamento dos dados depende de um ambiente AWS configurado com permissões para utilização do Amazon S3, AWS Glue e Amazon Athena.

Os scripts da pasta `src/glue_jobs` foram desenvolvidos para execução no ambiente AWS Glue.

As consultas da pasta `sql` devem ser executadas no Amazon Athena, considerando a configuração do banco de dados e das tabelas utilizadas no projeto.

Para executar as análises auxiliares e gerar gráficos localmente, é necessário ter Python instalado e configurar as dependências descritas em `requirements.txt`.

Instalação das bibliotecas:

```bash
pip install -r requirements.txt
```

## Considerações finais

O projeto permitiu integrar conceitos de Engenharia de Dados e Analytics em uma solução desenvolvida na AWS.

A organização em camadas facilitou o tratamento e a consolidação das informações, enquanto as consultas SQL e os gráficos permitiram explorar os dados de forma mais clara.

A análise das três edições da pesquisa também possibilitou observar mudanças importantes no mercado brasileiro de Dados e Tecnologia, especialmente em relação à utilização de Inteligência Artificial, às competências técnicas e às preferências profissionais.

## Autoria

**Izabella Costa Mendes**

- **Instituição:** FIAP
- **Curso:** Pós-Tech – Data Analytics
- **RM:** rm375012
- **E-mail institucional:** rm375012@fiap.com.br

## Referências

- DATA HACKERS; BAIN & COMPANY. State of Data Brasil 2023–2024.
- DATA HACKERS; BAIN & COMPANY. State of Data Brasil 2024–2025.
- DATA HACKERS; BAIN & COMPANY. State of Data Brasil 2025–2026.
- FIAP. Tech Challenge – Fase 3.
- AMAZON WEB SERVICES. Documentação oficial do Amazon S3, AWS Glue e Amazon Athena. https://docs.aws.amazon.com/
