output "network_id" {
  description = "ID da VPC gerenciada ou existente."
  value       = local.network_id
}

output "network_name" {
  description = "Nome da VPC gerenciada ou existente."
  value       = local.network_name
}

output "network_self_link" {
  description = "Self-link da VPC."
  value       = local.network_link
}

output "subnets" {
  description = "Mapa detalhado das sub-redes criadas."
  value = {
    for k, v in google_compute_subnetwork.subnets : k => {
      id            = v.id
      name          = v.name
      ip_cidr_range = v.ip_cidr_range
      region        = v.region
      self_link     = v.self_link
    }
  }
}

output "router_name" {
  description = "Nome do Cloud Router provisionado."
  value       = var.create_nat ? google_compute_router.router[0].name : null
}

output "nat_name" {
  description = "Nome do Cloud NAT provisionado."
  value       = var.create_nat ? google_compute_router_nat.nat[0].name : null
}

output "psa_range_name" {
  description = "Nome da reserva de IP do Private Service Access."
  value       = var.create_psa ? google_compute_global_address.psa_range[0].name : null
}

output "psa_connection_id" {
  description = "ID do Service Networking Connection para Private Service Access."
  value       = var.create_psa ? google_service_networking_connection.private_service_access[0].id : null
}

output "cloud_armor_policy_id" {
  description = "ID da política Cloud Armor (WAF) criada."
  value       = var.enable_cloud_armor ? google_compute_security_policy.cloud_armor[0].id : null
}

output "cloud_armor_policy_name" {
  description = "Nome da política Cloud Armor (WAF) criada."
  value       = var.enable_cloud_armor ? google_compute_security_policy.cloud_armor[0].name : null
}

