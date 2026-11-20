# Módulo Cloud Spanner (`modules/spanner`)

Módulo para provisionamento de banco de dados distribuído globalmente com consistência forte e alta disponibilidade via Google Cloud Spanner, utilizado para o catálogo de metadados padrão do ACG.

## Recursos Gerenciados

- `google_spanner_instance`: Instância regional Spanner dimensionada em Processing Units (PUs) com labels corporativas.
- `google_spanner_database`: Banco de dados relacional com proteção de deleção configurável.

## Inputs

| Nome | Descrição | Tipo | Padrão | Obrigatório |
|------|-----------|------|--------|:-----------:|
| `project_id` | GCP Project ID | `string` | n/a | Sim |
| `environment` | Ambiente (`dev`, `hml`, `prd`) | `string` | n/a | Sim |
| `common_labels` | Mapa de labels obrigatórias | `map(string)` | n/a | Sim |
| `company_prefix` | Prefixo corporativo | `string` | `"seia"` | Não |
| `project_name` | Nome da aplicação | `string` | `"adapar"` | Não |
| `config` | Configuração regional | `string` | `"regional-southamerica-east1"` | Não |
| `processing_units` | Unidades de processamento (PUs) | `number` | `100` | Não |
| `database_name` | Nome do banco do catálogo ACG | `string` | `"acg_catalog"` | Não |
| `deletion_protection`| Proteção de deleção | `bool` | `false` | Não |

## Outputs

| Nome | Descrição |
|------|-----------|
| `instance_id` | ID da instância Cloud Spanner |
| `instance_name` | Nome da instância |
| `database_id` | ID do banco de dados |
| `database_name` | Nome do banco de dados |

