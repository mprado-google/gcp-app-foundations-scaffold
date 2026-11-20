output "looker_instance_id" {
  description = "ID da instância Looker Core."
  value       = google_looker_instance.looker.id
}

output "looker_uri" {
  description = "URI da interface web do Looker Core."
  value       = google_looker_instance.looker.looker_uri
}

