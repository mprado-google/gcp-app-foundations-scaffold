# Módulo Security & IAM (`modules/security-iam`)

Módulo que implementa a governança de segurança, identidade e criptografia em conformidade com as diretrizes de Menor Privilégio e CMEK do `code_guidance.md` e `spec.md`.

## Recursos Gerenciados

- `google_service_account`: Service Accounts dedicadas por serviço (`cloudsql`, `storage`, `app`, `ingestion`), eliminando o uso da Compute Engine Default Service Account.
- `google_project_iam_member`: Atribuições estritas de menor privilégio.
- `google_kms_key_ring` & `google_kms_crypto_key`: Cloud KMS para criptografia gerenciada pelo cliente (CMEK) com rotação automática para Cloud Storage, Cloud SQL e Secret Manager.
- `google_kms_crypto_key_iam_member`: Liberação de privilégios de encriptação/decriptação para os Service Agents gerenciados do GCP.
- `google_secret_manager_secret`: Segredos base para armazenamento seguro de credenciais.
- Suporte a permissões granulares do Identity-Aware Proxy (IAP).

## Inputs

| Nome | Descrição | Tipo | Padrão | Obrigatório |
|------|-----------|------|--------|:-----------:|
| `project_id` | GCP Project ID | `string` | n/a | Sim |
| `environment` | Ambiente (`dev`, `hml`, `prd`) | `string` | n/a | Sim |
| `common_labels` | Mapa de labels obrigatórias | `map(string)` | n/a | Sim |
| `company_prefix` | Prefixo da organização | `string` | `"seia"` | Não |
| `project_name` | Nome da aplicação | `string` | `"adapar"` | Não |
| `region` | Região GCP para o Cloud KMS | `string` | `"southamerica-east1"` | Não |
| `enable_cmek` | Habilita KeyRing e CryptoKeys KMS | `bool` | `true` | Não |
| `kms_rotation_period` | Período de rotação das chaves | `string` | `"7776000s"` | Não |
| `iap_tunnel_members` | Membros autorizados no IAP Tunnel | `list(string)` | `[]` | Não |
| `iap_web_members` | Membros autorizados no IAP Web | `list(string)` | `[]` | Não |
| `create_secret_manager_secrets` | Cria segredos base | `bool` | `true` | Não |

## Outputs

| Nome | Descrição |
|------|-----------|
| `service_accounts` | Mapa detalhado das Service Accounts criadas |
| `sa_emails` | Mapa de emails das SAs por serviço |
| `keyring_id` | ID do KeyRing KMS |
| `storage_crypto_key_id` | ID da CryptoKey para Cloud Storage |
| `sql_crypto_key_id` | ID da CryptoKey para Cloud SQL |
| `secret_crypto_key_id` | ID da CryptoKey para Secret Manager |
| `secrets` | IDs dos segredos provisionados no Secret Manager |

## Exemplo de Uso

```hcl
module "security_iam" {
  source        = "../../modules/security-iam"
  project_id    = var.project_id
  environment   = "prd"
  common_labels = var.common_labels
  enable_cmek   = true
}
```

