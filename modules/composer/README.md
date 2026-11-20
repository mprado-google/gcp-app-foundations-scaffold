# Módulo Cloud Composer 3 (`modules/composer`)

Módulo que provisiona o ambiente Apache Airflow gerenciado via Google Cloud Composer 3 em arquitetura moderna e segura, com Service Account dedicada de menor privilégio e dimensionamento flexível (`environment_size`).

## Recursos Gerenciados

- `google_composer_environment`: Instância gerenciada Cloud Composer 3 com suporte a orquestração de missões de voo, pipelines de ingestão geoespacial e catalogação STAC.

## Regras de Dimensionamento por Ambiente

| Ambiente | Porte (`environment_size`) | Finalidade |
|----------|----------------------------|------------|
| `dev` | `ENVIRONMENT_SIZE_SMALL` (~25%) | Desenvolvimento e validação de DAGs |
| `hml` | `ENVIRONMENT_SIZE_SMALL` (~50%) | Testes integrados de pipelines |
| `prd` | `ENVIRONMENT_SIZE_MEDIUM` / `LARGE` (100%) | Produção com alta capacidade de workers |

## Inputs

| Nome | Descrição | Tipo | Padrão | Obrigatório |
|------|-----------|------|--------|:-----------:|
| `project_id` | GCP Project ID | `string` | n/a | Sim |
| `environment` | Ambiente (`dev`, `hml`, `prd`) | `string` | n/a | Sim |
| `service_account_email` | SA dedicada para execução das DAGs | `string` | n/a | Sim |
| `common_labels` | Mapa de labels obrigatórias | `map(string)` | n/a | Sim |
| `company_prefix` | Prefixo da organização | `string` | `"seia"` | Não |
| `project_name` | Nome do projeto | `string` | `"adapar"` | Não |
| `region` | Região GCP | `string` | `"southamerica-east1"` | Não |
| `environment_size` | Porte (`SMALL`, `MEDIUM`, `LARGE`) | `string` | `"ENVIRONMENT_SIZE_SMALL"` | Não |

## Outputs

| Nome | Descrição |
|------|-----------|
| `composer_environment_id` | ID do ambiente Cloud Composer |
| `composer_environment_name` | Nome do recurso |
| `airflow_uri` | URL da interface web do Airflow |
| `gcs_dag_bucket` | Prefixo do bucket GCS para upload das DAGs |

