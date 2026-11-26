output "lb_ip_address" {
  description = "Endereço IP público estático do Global HTTPS Load Balancer."
  value       = var.enable_load_balancer ? google_compute_global_address.lb_ip[0].address : null
}

output "lb_ip_name" {
  description = "Nome do recurso de IP estático global."
  value       = var.enable_load_balancer ? google_compute_global_address.lb_ip[0].name : null
}

output "ssl_certificate_id" {
  description = "ID do certificado SSL gerenciado pelo Google."
  value       = var.enable_load_balancer && length(var.domains) > 0 ? google_compute_managed_ssl_certificate.default[0].id : null
}

output "backend_service_id" {
  description = "ID do Backend Service do Load Balancer."
  value       = var.enable_load_balancer ? google_compute_backend_service.default[0].id : null
}

output "url_map_id" {
  description = "ID do URL Map do Load Balancer."
  value       = var.enable_load_balancer ? google_compute_url_map.default[0].id : null
}

output "https_forwarding_rule_name" {
  description = "Nome da Global Forwarding Rule HTTPS."
  value       = var.enable_load_balancer && length(var.domains) > 0 ? google_compute_global_forwarding_rule.https[0].name : null
}

output "http_redirect_forwarding_rule_name" {
  description = "Nome da Global Forwarding Rule HTTP (redirect)."
  value       = var.enable_load_balancer ? google_compute_global_forwarding_rule.http_redirect[0].name : null
}
