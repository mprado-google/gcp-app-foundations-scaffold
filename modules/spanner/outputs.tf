output "instance_id" {
  description = "ID da instância Cloud Spanner."
  value       = google_spanner_instance.spanner.id
}

output "instance_name" {
  description = "Nome da instância Cloud Spanner."
  value       = google_spanner_instance.spanner.name
}

output "database_id" {
  description = "ID do banco de dados Spanner."
  value       = google_spanner_database.database.id
}

output "database_name" {
  description = "Nome do banco de dados Spanner."
  value       = google_spanner_database.database.name
}

