output "instance_name" {
  description = "Nome da instância Memorystore Redis."
  value       = google_redis_instance.cache.name
}

output "instance_id" {
  description = "ID da instância Memorystore Redis."
  value       = google_redis_instance.cache.id
}

output "host" {
  description = "Endereço IP Privado para conexão ao Redis na VPC."
  value       = google_redis_instance.cache.host
}

output "port" {
  description = "Porta do serviço Redis."
  value       = google_redis_instance.cache.port
}

output "auth_string" {
  description = "Auth string para autenticação no Redis (sensível)."
  value       = google_redis_instance.cache.auth_string
  sensitive   = true
}

