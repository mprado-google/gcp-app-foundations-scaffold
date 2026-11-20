# Módulo Looker Core (`modules/looker-core`)

Módulo para provisionamento da instância gerenciada do Google Cloud Looker (Core) em rede privada (`consumer_network`), dedicada à visualização analítica, relatórios gerenciais e dashboards executivos do Censo Agropecuário ADAPAR.

## Recursos Gerenciados

- `google_looker_instance`: Instância gerenciada Looker Core conectada via IP privado (`private_ip_enabled = true`).

## Inputs

| Nome | Descrição | Tipo | Padrão | Obrigatório |
|------|-----------|------|--------|:-----------:|
| `project_id` | GCP Project ID | `string` | n/a | Sim |
| `environment` | Ambiente (`dev`, `hml`, `prd`) | `string` | n/a | Sim |
| `common_labels` | Mapa de labels obrigatórias | `map(string)` | n/a | Sim |
| `platform_edition` | Edição do Looker Core | `string` | `"LOOKER_CORE_STANDARD"` | Não |
| `private_ip_enabled`| Conexão exclusiva em IP privado | `bool` | `true` | Não |
| `consumer_network` | ID da VPC para rede privada | `string` | `null` | Não |
| `reserved_range` | Nome da faixa de IP reservada | `string` | `null` | Não |

## Outputs

| Nome | Descrição |
|------|-----------|
| `looker_instance_id` | ID da instância Looker Core |
| `looker_uri` | URI de acesso ao Looker |

