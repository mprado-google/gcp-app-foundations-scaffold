output "project_id" {
  description = "GCP Project ID onde os serviços foram ativados."
  value       = var.project_id
}

output "enabled_services" {
  description = "Lista de serviços e APIs habilitados no projeto."
  value       = [for s in google_project_service.services : s.service]
}

