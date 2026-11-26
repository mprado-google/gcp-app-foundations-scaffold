terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

locals {
  region_clean = replace(var.region, "-", "")
  name_prefix  = "${var.company_prefix}-${var.project_name}-${var.environment}"
}

# 1. IP Estático Global para o Load Balancer
resource "google_compute_global_address" "lb_ip" {
  count       = var.enable_load_balancer ? 1 : 0
  project     = var.project_id
  name        = "${local.name_prefix}-lb-ip"
  description = "IP estático global para o HTTPS Load Balancer de ${var.project_name} em ${var.environment}"
  labels      = var.common_labels
}

# 2. Certificado SSL Gerenciado pelo Google
resource "google_compute_managed_ssl_certificate" "default" {
  count   = var.enable_load_balancer && length(var.domains) > 0 ? 1 : 0
  project = var.project_id
  name    = "${local.name_prefix}-ssl-cert"

  managed {
    domains = var.domains
  }
}

# 3. Health Check para os backends
resource "google_compute_health_check" "default" {
  count   = var.enable_load_balancer ? 1 : 0
  project = var.project_id
  name    = "${local.name_prefix}-lb-hc"

  https_health_check {
    port         = 443
    request_path = var.health_check_path
  }

  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3
}

# 4. Backend Service (com Cloud CDN opcional e Cloud Armor)
resource "google_compute_backend_service" "default" {
  count                 = var.enable_load_balancer ? 1 : 0
  project               = var.project_id
  name                  = "${local.name_prefix}-lb-backend"
  description           = "Backend service principal para ${local.name_prefix}"
  protocol              = "HTTPS"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_health_check.default[0].id]
  security_policy       = var.cloud_armor_policy_id
  enable_cdn            = var.enable_cdn
  timeout_sec           = 30

  dynamic "backend" {
    for_each = var.backends
    content {
      group           = backend.value.group
      balancing_mode  = lookup(backend.value, "balancing_mode", "UTILIZATION")
      capacity_scaler = lookup(backend.value, "capacity_scaler", 1.0)
    }
  }

  dynamic "cdn_policy" {
    for_each = var.enable_cdn ? [1] : []
    content {
      cache_mode                   = "CACHE_ALL_STATIC"
      default_ttl                  = 3600
      max_ttl                      = 86400
      client_ttl                   = 3600
      negative_caching             = true
      serve_while_stale            = 86400
      signed_url_cache_max_age_sec = 3600
    }
  }

  log_config {
    enable      = true
    sample_rate = 1.0
  }
}

# 5. URL Map (roteamento de requisições para backends)
resource "google_compute_url_map" "default" {
  count           = var.enable_load_balancer ? 1 : 0
  project         = var.project_id
  name            = "${local.name_prefix}-lb-urlmap"
  description     = "URL Map do Load Balancer para ${local.name_prefix}"
  default_service = google_compute_backend_service.default[0].id
}

# URL Map para redirecionar HTTP -> HTTPS
resource "google_compute_url_map" "http_redirect" {
  count   = var.enable_load_balancer ? 1 : 0
  project = var.project_id
  name    = "${local.name_prefix}-lb-http-redirect"

  default_url_redirect {
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
    https_redirect         = true
  }
}

# 6. HTTPS Target Proxy
resource "google_compute_target_https_proxy" "default" {
  count            = var.enable_load_balancer && length(var.domains) > 0 ? 1 : 0
  project          = var.project_id
  name             = "${local.name_prefix}-lb-https-proxy"
  url_map          = google_compute_url_map.default[0].id
  ssl_certificates = [google_compute_managed_ssl_certificate.default[0].id]
}

# HTTP Target Proxy (apenas para redirect HTTP->HTTPS)
resource "google_compute_target_http_proxy" "http_redirect" {
  count   = var.enable_load_balancer ? 1 : 0
  project = var.project_id
  name    = "${local.name_prefix}-lb-http-proxy"
  url_map = google_compute_url_map.http_redirect[0].id
}

# 7. Global Forwarding Rules
# HTTPS (porta 443)
resource "google_compute_global_forwarding_rule" "https" {
  count                 = var.enable_load_balancer && length(var.domains) > 0 ? 1 : 0
  project               = var.project_id
  name                  = "${local.name_prefix}-lb-fwd-https"
  description           = "Forwarding rule HTTPS para ${local.name_prefix}"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_target_https_proxy.default[0].id
  ip_address            = google_compute_global_address.lb_ip[0].id
  labels                = var.common_labels
}

# HTTP (porta 80) - apenas redirect
resource "google_compute_global_forwarding_rule" "http_redirect" {
  count                 = var.enable_load_balancer ? 1 : 0
  project               = var.project_id
  name                  = "${local.name_prefix}-lb-fwd-http"
  description           = "Forwarding rule HTTP para redirect HTTPS em ${local.name_prefix}"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_target_http_proxy.http_redirect[0].id
  ip_address            = google_compute_global_address.lb_ip[0].id
  labels                = var.common_labels
}
