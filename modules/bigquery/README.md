# Módulo BigQuery (`modules/bigquery`)

Módulo que provisiona os datasets analíticos do BigQuery e BigQuery GIS para armazenamento refinado da camada Gold, análises geoespaciais e controle de acesso com base no menor privilégio, em conformidade com o `spec.md`.

## Datasets Provisionados

- `gold_analytics`: Métricas consolidadas, relatórios analíticos e agregações temporais de rebanhos.
- `gis_census`: Tabelas espaciais com geometrias (polígonos de propriedades rurais do CAR, delimitações sanitárias e pontos de contagem).

## Recursos Gerenciados

- `google_bigquery_dataset`: Datasets regionais em `southamerica-east1` com suporte a criptografia CMEK e controle de exclusão acidental.
- `google_bigquery_dataset_access`: Concessão de permissões de leitura/escrita para Service Accounts autorizadas.

## Inputs

| Nome | Descrição | Tipo | Padrão | Obrigatório |
|------|-----------|------|--------|:-----------:|
| `project_id` | GCP Project ID | `string` | n/a | Sim |
| `environment` | Ambiente (`dev`, `hml`, `prd`) | `string` | n/a | Sim |
| `common_labels` | Mapa de labels obrigatórias | `map(string)` | n/a | Sim |
| `location` | Localização do dataset | `string` | `"southamerica-east1"` | Não |
| `delete_contents_on_destroy` | Deleta tabelas ao destruir dataset | `bool` | `false` | Não |
| `kms_key_name` | ID da CryptoKey KMS para CMEK | `string` | `null` | Não |
| `authorized_service_accounts` | SAs autorizadas como visualizadores | `list(string)` | `[]` | Não |

## Outputs

| Nome | Descrição |
|------|-----------|
| `gold_analytics_dataset_id` | ID do dataset Gold Analytics |
| `gis_census_dataset_id` | ID do dataset GIS Census |
| `datasets` | Mapa consolidado com metadados dos datasets |

