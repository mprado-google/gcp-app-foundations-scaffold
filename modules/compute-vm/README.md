# Módulo Compute VM Workers & Vertex AI Workbench (`modules/compute-vm`)

Módulo que provisiona grupos gerenciados de instâncias (MIG) equipadas com aceleradores GPU NVIDIA T4 em sub-rede estritamente privada para fotogrametria e inferência, além de suportar uma instância privada do Vertex AI Workbench exclusivamente para o ambiente de desenvolvimento (`dev`), em conformidade com o `spec.md`.

## Recursos Gerenciados

- `google_compute_instance_template`: Template de nó com acelerador GPU NVIDIA T4, disco SSD com suporte a CMEK e sem IP público.
- `google_compute_instance_group_manager`: Gerenciador de instâncias com capacidade de escala de 0 a N nós para otimização de custos em dev/hml.
- `google_workbench_instance`: Instância de notebook interativo gerenciado via Vertex AI Workbench, estritamente em IP privado (`disable_public_ip = true`), exclusivo para o ambiente `dev`.

## Regras de Dimensionamento por Ambiente

| Recurso | DEV (~25%) | HML (~50%) | PRD (100%) |
|---------|------------|------------|------------|
| Tipo de Máquina Worker | `n1-standard-4` | `n1-standard-8` | `n1-standard-8` |
| GPUs NVIDIA T4 | 1 por nó (escala 0..2) | 1 por nó (escala 0..5) | 1 por nó (escala 0..N) |
| Target Size Inicial | `0` (escala sob demanda) | `0` | `0` |
| Vertex AI Workbench | Disponível (`enable_workbench = true`) | Desativado | Desativado |

## Inputs

| Nome | Descrição | Tipo | Padrão | Obrigatório |
|------|-----------|------|--------|:-----------:|
| `project_id` | GCP Project ID | `string` | n/a | Sim |
| `environment` | Ambiente (`dev`, `hml`, `prd`) | `string` | n/a | Sim |
| `subnet_id` | Sub-rede privada dos nós | `string` | n/a | Sim |
| `service_account_email` | SA dedicada aos workers | `string` | n/a | Sim |
| `common_labels` | Mapa de labels obrigatórias | `map(string)` | n/a | Sim |
| `network_id` | ID da VPC (para Workbench) | `string` | `null` | Não |
| `machine_type` | Tipo de máquina do worker | `string` | `"n1-standard-4"` | Não |
| `gpu_count` | Qtd de GPUs T4 por nó | `number` | `1` | Não |
| `target_size` | Nós ativos inicialmente | `number` | `0` | Não |
| `enable_workbench` | Instância Vertex AI Workbench (apenas dev) | `bool` | `false` | Não |

## Outputs

| Nome | Descrição |
|------|-----------|
| `instance_template_id` | ID do template de nó GPU |
| `instance_group_manager_id` | ID do MIG |
| `instance_group` | Self-link do grupo gerenciado |
| `workbench_instance_id` | ID da instância do Vertex AI Workbench |

