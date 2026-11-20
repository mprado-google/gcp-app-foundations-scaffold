# Módulo GKE Privado (`modules/gke`)

Módulo que provisiona um cluster Google Kubernetes Engine (GKE) privado para hospedar os microsserviços da stack eoAPI (`stac-fastapi`, `titiler`, `tipg`) em conformidade com as regras de segurança (sem IP público nos nós), paridade de ambientes e node pools configuráveis.

## Recursos Gerenciados

- `google_container_cluster`: Cluster regional ou zonal em modo privado (`enable_private_nodes = true`), integrado com Workload Identity, HPA e Backup for GKE (em PRD).
- `google_container_node_pool`: Node pool principal e suporte a múltiplos node pools adicionais configuráveis, com autoscaling, instâncias blindadas (Shielded VMs) e Service Account dedicada de menor privilégio.

## Regras de Dimensionamento por Ambiente

| Parâmetro | DEV (~25%) | HML (~50%) | PRD (100%) |
|-----------|------------|------------|------------|
| Tipo de Cluster | Zonal (`southamerica-east1-a`) | Regional (HA) | Regional (HA) |
| Tipo de Máquina Principal | `e2-standard-2` | `e2-standard-4` | `e2-standard-4` |
| Nós (Min / Max) | 1 / 3 | 2 / 5 | 3 / 10 |
| Backup for GKE | `false` | `false` | `true` |

## Inputs

| Nome | Descrição | Tipo | Padrão | Obrigatório |
|------|-----------|------|--------|:-----------:|
| `project_id` | GCP Project ID | `string` | n/a | Sim |
| `environment` | Ambiente (`dev`, `hml`, `prd`) | `string` | n/a | Sim |
| `network_id` | ID ou self-link da VPC | `string` | n/a | Sim |
| `subnet_id` | Sub-rede dedicada ao GKE | `string` | n/a | Sim |
| `service_account_email` | SA dedicada para os nós | `string` | n/a | Sim |
| `common_labels` | Mapa de labels obrigatórias | `map(string)` | n/a | Sim |
| `regional_cluster` | Cluster regional (HA em prd) | `bool` | `false` | Não |
| `primary_node_machine_type`| Tipo de máquina do node pool padrão | `string` | `"e2-standard-2"` | Não |
| `node_pools` | Lista de node pools adicionais | `list(object)` | `[]` | Não |
| `enable_backup_for_gke` | Backup for GKE (obrigatório em prd) | `bool` | `false` | Não |

## Outputs

| Nome | Descrição |
|------|-----------|
| `cluster_name` | Nome do cluster GKE |
| `cluster_id` | ID do cluster GKE |
| `cluster_endpoint` | Endpoint do plano de controle |
| `primary_node_pool_id` | ID do node pool principal |

