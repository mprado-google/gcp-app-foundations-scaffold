# Módulo Memorystore Redis (`modules/memorystore`)

Módulo para provisionamento do Google Cloud Memorystore Redis em rede privada via Private Service Access (PSA), destinado ao cache de alta velocidade para tiles dinâmicos de mapas raster (titiler), buscas e metadados no catálogo STAC.

## Recursos Gerenciados

- `google_redis_instance`: Instância Redis conectada estritamente via IP Privado na VPC autorizada via Private Service Access (`connect_mode = "PRIVATE_SERVICE_ACCESS"`), com suporte a alta disponibilidade (`STANDARD_HA`), autenticação (`auth_enabled`) e TLS em trânsito.

## Regras de Dimensionamento por Ambiente

| Ambiente | Tier | Memória | Finalidade |
|----------|------|---------|------------|
| `dev` | `BASIC` | 2 GB (~25%) | Desenvolvimento e validação funcional de tiles |
| `hml` | `STANDARD_HA` | 5 GB (~50%) | Testes de carga e failover com réplica |
| `prd` | `STANDARD_HA` | 10 GB (100%) | Produção com failover automático e alta disponibilidade regional |

## Inputs

| Nome | Descrição | Tipo | Padrão | Obrigatório |
|------|-----------|------|--------|:-----------:|
| `project_id` | GCP Project ID | `string` | n/a | Sim |
| `environment` | Ambiente (`dev`, `hml`, `prd`) | `string` | n/a | Sim |
| `network_id` | ID ou self-link da VPC | `string` | n/a | Sim |
| `common_labels` | Mapa de labels obrigatórias | `map(string)` | n/a | Sim |
| `memory_size_gb` | Capacidade de memória em GB | `number` | `2` | Não |
| `tier` | `STANDARD_HA` ou `BASIC` | `string` | `"BASIC"` | Não |
| `redis_version` | Versão da engine Redis | `string` | `"REDIS_7_0"` | Não |
| `auth_enabled` | Autenticação via AUTH string | `bool` | `true` | Não |
| `transit_encryption_mode` | Criptografia em trânsito | `string` | `"SERVER_AUTHENTICATION"` | Não |

## Outputs

| Nome | Descrição |
|------|-----------|
| `instance_name` | Nome da instância Redis |
| `instance_id` | ID da instância Redis |
| `host` | IP Privado de conexão na VPC |
| `port` | Porta do Redis (6379) |
| `auth_string` | Token de autenticação seguro |

