# Módulo Cloud SQL PostgreSQL (`modules/cloud-sql`)

Módulo que provisiona a instância de banco de dados relacional e geoespacial PostgreSQL (com suporte a extensões como PostGIS e catálogo pgSTAC), estritamente em IP privado via Private Service Access (PSA), com suporte a alta disponibilidade (HA) regional, criptografia CMEK e retenção de backups automatizados.

## Recursos Gerenciados

- `google_sql_database_instance`: Instância PostgreSQL com configurações de segurança avançadas (`ipv4_enabled = false`, SSL obrigatório, Private IP na VPC).
- `google_sql_database`: Criação automatizada de bancos de dados (`adapar_geodb`, `pgstac`).
- `random_password` & `google_sql_user`: Criação de usuário da aplicação com senha aleatória forte.
- `google_secret_manager_secret` & `google_secret_manager_secret_version`: Armazenamento seguro das credenciais geradas no Secret Manager (Host, Porta, Banco, Usuário, Senha).

## Regras de Dimensionamento por Ambiente

| Parâmetro | DEV (~25%) | HML (~50%) | PRD (100%) |
|-----------|------------|------------|------------|
| `availability_type` | `ZONAL` | `REGIONAL` (HA) | `REGIONAL` (HA) |
| `tier` | `db-custom-2-7680` | `db-custom-4-16384` | `db-custom-16-65536` |
| `disk_size_gb` | `250` | `500` | `1000` |
| `deletion_protection` | `false` | `true` | `true` |
| `kms_key_name` (CMEK) | Opcional | Opcional | Obrigatório |
| `backup_retention_days` | `7` | `7` | `30` |

## Inputs

| Nome | Descrição | Tipo | Padrão | Obrigatório |
|------|-----------|------|--------|:-----------:|
| `project_id` | GCP Project ID | `string` | n/a | Sim |
| `environment` | Ambiente (`dev`, `hml`, `prd`) | `string` | n/a | Sim |
| `network_id` | ID da VPC privada para Private Service Access | `string` | n/a | Sim |
| `common_labels` | Mapa de labels obrigatórias | `map(string)` | n/a | Sim |
| `company_prefix` | Prefixo da organização | `string` | `"seia"` | Não |
| `project_name` | Nome da aplicação | `string` | `"adapar"` | Não |
| `region` | Região GCP da instância | `string` | `"southamerica-east1"` | Não |
| `database_version` | Versão do PostgreSQL | `string` | `"POSTGRES_16"` | Não |
| `tier` | Tipo de máquina da instância | `string` | `"db-custom-2-7680"` | Não |
| `disk_size_gb` | Tamanho do disco SSD em GiB | `number` | `250` | Não |
| `availability_type` | `REGIONAL` ou `ZONAL` | `string` | `"ZONAL"` | Não |
| `deletion_protection`| Proteção contra deleção | `bool` | `false` | Não |
| `allocated_ip_range` | Nome da faixa IP reservada PSA | `string` | `null` | Não |
| `kms_key_name` | ID da CryptoKey KMS para CMEK | `string` | `null` | Não |
| `backup_retention_days` | Dias de retenção de backup | `number` | `7` | Não |
| `databases` | Lista de bancos a criar | `list(string)` | `["adapar_geodb", "pgstac"]` | Não |

## Outputs

| Nome | Descrição |
|------|-----------|
| `instance_name` | Nome da instância Cloud SQL |
| `instance_connection_name` | Nome de conexão para Cloud SQL Auth Proxy |
| `private_ip_address` | Endereço IP privado na VPC |
| `database_names` | Bancos criados na instância |
| `credentials_secret_id` | ID do secret com credenciais completas no Secret Manager |

## Exemplo de Uso

```hcl
module "cloud_sql" {
  source              = "../../modules/cloud-sql"
  project_id          = var.project_id
  environment         = "prd"
  common_labels       = var.common_labels
  network_id          = module.networking.network_id
  allocated_ip_range  = module.networking.psa_range_name
  kms_key_name        = module.security_iam.sql_crypto_key_id
  availability_type   = "REGIONAL"
  tier                = "db-custom-16-65536"
  disk_size_gb        = 1000
  deletion_protection = true
}
```

