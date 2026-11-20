output "instance_name" {
  description = "Nome da instância Cloud SQL provisionada."
  value       = google_sql_database_instance.postgres.name
}

output "instance_connection_name" {
  description = "Connection Name da instância (usado pelo Cloud SQL Auth Proxy)."
  value       = google_sql_database_instance.postgres.connection_name
}

output "private_ip_address" {
  description = "Endereço IP Privado da instância Cloud SQL na VPC."
  value       = google_sql_database_instance.postgres.private_ip_address
}

output "database_names" {
  description = "Lista dos bancos de dados criados na instância."
  value       = [for db in google_sql_database.databases : db.name]
}

output "app_username" {
  description = "Nome de usuário da aplicação."
  value       = google_sql_user.app_user.name
}

output "credentials_secret_id" {
  description = "ID do Secret no Secret Manager contendo as credenciais completas de conexão."
  value       = google_secret_manager_secret.sql_credentials.id
}

