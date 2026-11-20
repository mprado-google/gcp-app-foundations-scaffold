output "service_accounts" {
  description = "Mapa detalhado das Service Accounts criadas por serviço."
  value = {
    for k, v in google_service_account.service_accounts : k => {
      id         = v.id
      email      = v.email
      account_id = v.account_id
      name       = v.name
    }
  }
}

output "sa_emails" {
  description = "Mapa de emails das Service Accounts."
  value       = { for k, v in google_service_account.service_accounts : k => v.email }
}

output "keyring_id" {
  description = "ID do KeyRing KMS provisionado para CMEK."
  value       = var.enable_cmek ? google_kms_key_ring.keyring[0].id : null
}

output "keyring_name" {
  description = "Nome do KeyRing KMS provisionado para CMEK."
  value       = var.enable_cmek ? google_kms_key_ring.keyring[0].name : null
}

output "storage_crypto_key_id" {
  description = "ID completo da CryptoKey KMS para criptografia do Cloud Storage (GeoDataLake)."
  value       = var.enable_cmek ? google_kms_crypto_key.storage_key[0].id : null
}

output "sql_crypto_key_id" {
  description = "ID completo da CryptoKey KMS para criptografia do Cloud SQL."
  value       = var.enable_cmek ? google_kms_crypto_key.sql_key[0].id : null
}

output "secret_crypto_key_id" {
  description = "ID completo da CryptoKey KMS para criptografia do Secret Manager."
  value       = var.enable_cmek ? google_kms_crypto_key.secret_key[0].id : null
}

output "secrets" {
  description = "Mapa de IDs dos segredos provisionados no Secret Manager."
  value = var.create_secret_manager_secrets ? {
    db_credentials = google_secret_manager_secret.db_credentials[0].id
    app_secrets    = google_secret_manager_secret.app_secrets[0].id
  } : {}
}

