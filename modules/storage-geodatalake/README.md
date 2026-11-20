# Módulo Storage GeoDataLake (`modules/storage-geodatalake`)

Módulo que implementa a arquitetura de armazenamento do GeoDataLake para dados geoespaciais e sensoriamento remoto (Censo de Rebanhos ADAPAR), em conformidade com as especificações do `spec.md` e `code_guidance.md`.

## Arquitetura de Buckets

1. **southamerica-east1 (São Paulo):**
   - **Camada Bronze (RAW):** Imagens brutas provenientes de voos de drones, satélites e telemetria de campo.
   - **Camada Silver (Trusted COGs):** Cloud Optimized GeoTIFFs padronizados, calibrados, com pirâmides internas e catalogados no STAC. Habilitado para CORS.
   - **Camada Gold (Refined):** Mosaicos finais processados, segmentações de rebanhos, vetores e relatórios analíticos prontos para BI/BigQuery GIS. Habilitado para CORS.
2. **us-central1 (EUA):**
   - **GEE Publication:** Bucket dedicado para publicação direta de ativos no Google Earth Engine (GEE), cuja API exige armazenamento nos EUA para ingestão de COGs.

## Segurança e Ciclo de Vida

- **Uniform Bucket-Level Access:** Ativado em 100% dos buckets.
- **Public Access Prevention:** Configurado como `enforced` (bloqueio irrestrito de acesso público anônimo).
- **CMEK (Cloud KMS):** Suporte nativo à criptografia gerenciada pelo cliente na região correspondente.
- **Ciclo de Vida:**
  - Standard -> Nearline (30 dias)
  - Nearline -> Archive (365 dias)
  - Expiração/Retenção total de 5 anos (1825 dias) em PRD.
- **CORS:** Configurado para permitir requisições de clientes Web GIS e viewers de mapas interativos.

## Inputs

| Nome | Descrição | Tipo | Padrão | Obrigatório |
|------|-----------|------|--------|:-----------:|
| `project_id` | GCP Project ID | `string` | n/a | Sim |
| `environment` | Ambiente (`dev`, `hml`, `prd`) | `string` | n/a | Sim |
| `common_labels` | Mapa de labels obrigatórias | `map(string)` | n/a | Sim |
| `company_prefix` | Prefixo da organização | `string` | `"seia"` | Não |
| `project_name` | Nome da aplicação | `string` | `"adapar"` | Não |
| `primary_region` | Região principal dos dados | `string` | `"southamerica-east1"` | Não |
| `gee_region` | Região para o bucket GEE | `string` | `"us-central1"` | Não |
| `bucket_suffix` | Sufixo para unicidade global | `string` | `""` | Não |
| `versioning_enabled` | Versionamento de objetos | `bool` | `true` | Não |
| `kms_key_name` | ID da chave CMEK para região principal | `string` | `null` | Não |
| `gee_kms_key_name` | ID da chave CMEK para us-central1 | `string` | `null` | Não |
| `force_destroy` | Permite deletar buckets com arquivos | `bool` | `false` | Não |
| `lifecycle_retention_days` | Dias para expiração de objetos (ex: 1825) | `number` | `1825` | Não |

## Outputs

| Nome | Descrição |
|------|-----------|
| `bronze_bucket_name` | Nome do bucket Bronze |
| `bronze_bucket_url` | URL do bucket Bronze |
| `silver_bucket_name` | Nome do bucket Silver |
| `silver_bucket_url` | URL do bucket Silver |
| `gold_bucket_name` | Nome do bucket Gold |
| `gold_bucket_url` | URL do bucket Gold |
| `gee_publication_bucket_name` | Nome do bucket GEE Publication |
| `buckets` | Mapa consolidado com metadados de todos os buckets |

## Exemplo de Uso

```hcl
module "storage_geodatalake" {
  source        = "../../modules/storage-geodatalake"
  project_id    = var.project_id
  environment   = "prd"
  common_labels = var.common_labels
  kms_key_name  = module.security_iam.storage_crypto_key_id
  force_destroy = false
}
```

