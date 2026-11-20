output "instance_template_id" {
  description = "ID do template de instância GPU."
  value       = google_compute_instance_template.gpu_worker_template.id
}

output "instance_group_manager_id" {
  description = "ID do Managed Instance Group (MIG) de workers GPU."
  value       = google_compute_instance_group_manager.gpu_workers.id
}

output "instance_group" {
  description = "Self-link do grupo de instâncias."
  value       = google_compute_instance_group_manager.gpu_workers.instance_group
}

output "workbench_instance_id" {
  description = "ID da instância do Vertex AI Workbench (quando habilitada em dev)."
  value       = var.enable_workbench && var.environment == "dev" ? google_workbench_instance.workbench[0].id : null
}

