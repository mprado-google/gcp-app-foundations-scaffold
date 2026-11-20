output "cluster_name" {
  description = "Nome do cluster GKE provisionado."
  value       = google_container_cluster.primary.name
}

output "cluster_id" {
  description = "ID do cluster GKE."
  value       = google_container_cluster.primary.id
}

output "cluster_endpoint" {
  description = "Endpoint do cluster GKE."
  value       = google_container_cluster.primary.endpoint
}

output "ca_certificate" {
  description = "Certificado CA do cluster GKE."
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "primary_node_pool_id" {
  description = "ID do node pool principal."
  value       = google_container_node_pool.primary_nodes.id
}

