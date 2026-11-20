# Módulo Cloud Run (`modules/cloud-run`)

Módulo para provisionamento de serviços serverless seguros para a plataforma do Censo de Rebanhos ADAPAR, com suporte a saída privada para VPC (Direct VPC Egress) e bloqueio de tráfego direto via internet pública (`INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER`).

## Serviços Gerenciados

- `web-app`: Interface administrativa e operacional de mapas e dashboards.
- `business-api`: API REST de regras de negócio, dados de produtores e integração com Cloud SQL.
- `quick-count`: Pipeline serverless de inferência rápida em amostras ortorretificadas.
- `conversational-agent`: Agente conversacional baseado em GenAI para suporte e consultas a fiscais agropecuários e produtores.

## Inputs

| Nome | Descrição | Tipo | Padrão | Obrigatório |
|------|-----------|------|--------|:-----------:|
| `project_id` | GCP Project ID | `string` | n/a | Sim |
| `environment` | Ambiente (`dev`, `hml`, `prd`) | `string` | n/a | Sim |
| `service_account_email` | SA dedicada para execução | `string` | n/a | Sim |
| `common_labels` | Labels obrigatórias | `map(string)` | n/a | Sim |
| `subnet_id` | Sub-rede para saída VPC privada | `string` | `null` | Não |
| `min_instance_count` | Mínimo de instâncias | `number` | `0` | Não |
| `max_instance_count` | Máximo de instâncias | `number` | `5` | Não |

## Outputs

| Nome | Descrição |
|------|-----------|
| `service_uris` | URIs dos serviços Cloud Run |
| `service_names` | Nomes dos serviços |
| `service_ids` | IDs dos serviços |

