output "composer_environment_id" {
  description = "ID do ambiente Cloud Composer."
  value       = google_composer_environment.composer.id
}

output "composer_environment_name" {
  description = "Nome do ambiente Cloud Composer."
  value       = google_composer_environment.composer.name
}

output "airflow_uri" {
  description = "URI da interface web do Apache Airflow."
  value       = google_composer_environment.composer.config[0].airflow_uri
}

output "gcs_dag_bucket" {
  description = "Bucket GCS para deploy de DAGs do Apache Airflow."
  value       = google_composer_environment.composer.config[0].dag_gcs_prefix
}

