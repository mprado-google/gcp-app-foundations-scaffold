output "vertex_artifacts_bucket_name" {
  description = "Nome do bucket GCS de artefatos de treinamento Vertex AI (us-central1)."
  value       = var.enable_vertex_ai ? google_storage_bucket.vertex_artifacts[0].name : null
}

output "vertex_artifacts_bucket_url" {
  description = "URL gs:// do bucket de artefatos de treinamento."
  value       = var.enable_vertex_ai ? google_storage_bucket.vertex_artifacts[0].url : null
}

output "vertex_dataset_id" {
  description = "ID do Vertex AI Dataset de imagens aéreas para treinamento."
  value       = var.enable_vertex_ai ? google_vertex_ai_dataset.training[0].id : null
}

output "vertex_dataset_name" {
  description = "Display name do Vertex AI Dataset."
  value       = var.enable_vertex_ai ? google_vertex_ai_dataset.training[0].display_name : null
}

output "tensorboard_id" {
  description = "ID do Vertex AI Tensorboard para rastreamento de experimentos."
  value       = var.enable_vertex_ai ? google_vertex_ai_tensorboard.default[0].id : null
}

output "tensorboard_name" {
  description = "Display name do Tensorboard."
  value       = var.enable_vertex_ai ? google_vertex_ai_tensorboard.default[0].display_name : null
}

output "workbench_instance_id" {
  description = "ID da instância Vertex AI Workbench (disponível apenas em dev)."
  value       = var.enable_vertex_ai && var.enable_workbench ? google_workbench_instance.workbench[0].id : null
}

output "workbench_proxy_uri" {
  description = "URI de acesso ao Workbench via proxy gerenciado."
  value       = var.enable_vertex_ai && var.enable_workbench ? google_workbench_instance.workbench[0].proxy_uri : null
}
