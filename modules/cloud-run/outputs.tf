output "service_uris" {
  description = "Mapa de URIs dos serviços Cloud Run provisionados."
  value       = { for k, v in google_cloud_run_v2_service.services : k => v.uri }
}

output "service_names" {
  description = "Mapa de nomes dos serviços Cloud Run provisionados."
  value       = { for k, v in google_cloud_run_v2_service.services : k => v.name }
}

output "service_ids" {
  description = "Mapa de IDs dos serviços Cloud Run provisionados."
  value       = { for k, v in google_cloud_run_v2_service.services : k => v.id }
}

