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

  vpc_name     = "${local.name_prefix}-vpc"
  network_id   = var.create_vpc ? google_compute_network.vpc[0].id : var.existing_network_id
  network_name = var.create_vpc ? google_compute_network.vpc[0].name : var.existing_network_name
  network_link = var.create_vpc ? google_compute_network.vpc[0].self_link : var.existing_network_self_link
}

# 1. VPC Network (Suporte a VPC dedicada ou Shared VPC)
resource "google_compute_network" "vpc" {
  count                           = var.create_vpc ? 1 : 0
  project                         = var.project_id
  name                            = local.vpc_name
  auto_create_subnetworks         = false
  routing_mode                    = "REGIONAL"
  delete_default_routes_on_create = true
  description                     = "VPC principal para ${var.project_name} em ${var.environment} gerenciada por Terraform"
}

# Rota padrão para saída à internet via Default Internet Gateway (usado junto ao Cloud NAT)
resource "google_compute_route" "default_internet_gateway" {
  count            = var.create_vpc ? 1 : 0
  project          = var.project_id
  name             = "${local.vpc_name}-default-route-igw"
  network          = local.network_name
  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
}

# 2. Sub-redes Privadas (Private Google Access obrigatório)
resource "google_compute_subnetwork" "subnets" {
  for_each                 = { for s in var.subnets : s.name => s }
  project                  = var.project_id
  name                     = startswith(each.value.name, local.name_prefix) ? each.value.name : "${local.name_prefix}-snet-${each.value.name}-${replace(coalesce(each.value.region, var.region), "-", "")}"
  ip_cidr_range            = each.value.ip_cidr_range
  region                   = coalesce(each.value.region, var.region)
  network                  = local.network_id
  private_ip_google_access = coalesce(each.value.private_ip_google_access, true)
  description              = coalesce(each.value.description, "Sub-rede privada ${each.key} para ${local.name_prefix}")

  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ip_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
}

# 3. Cloud Router e Cloud NAT (Sem IPs públicos para nós e instâncias internas)
resource "google_compute_router" "router" {
  count   = var.create_nat ? 1 : 0
  project = var.project_id
  name    = "${local.name_prefix}-router-${local.region_clean}"
  region  = var.region
  network = local.network_name

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  count                              = var.create_nat ? 1 : 0
  project                            = var.project_id
  name                               = "${local.name_prefix}-nat-${local.region_clean}"
  router                             = google_compute_router.router[0].name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# 4. Private Service Access (PSA para Cloud SQL e Memorystore via IP Privado)
resource "google_compute_global_address" "psa_range" {
  count         = var.create_psa ? 1 : 0
  project       = var.project_id
  name          = "${local.name_prefix}-psa-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = var.psa_prefix_length
  network       = local.network_id
  description   = "Faixa de IP reservada para Private Service Access (${var.project_name}-${var.environment})"
}

resource "google_service_networking_connection" "private_service_access" {
  count                   = var.create_psa ? 1 : 0
  network                 = local.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.psa_range[0].name]
}

# 5. Firewall Rules Base (Menor Privilégio e Acesso Privado)
# Permite comunicação interna na VPC
resource "google_compute_firewall" "allow_internal" {
  count       = var.create_vpc ? 1 : 0
  project     = var.project_id
  name        = "${local.name_prefix}-fw-allow-internal"
  network     = local.network_name
  description = "Permite tráfego interno entre todas as sub-redes da VPC"
  direction   = "INGRESS"
  priority    = 1000

  source_ranges = [for s in var.subnets : s.ip_cidr_range]

  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }
}

# Permite Health Checks do Google Cloud Load Balancer (Google IP Ranges)
resource "google_compute_firewall" "allow_health_checks" {
  count       = var.create_vpc ? 1 : 0
  project     = var.project_id
  name        = "${local.name_prefix}-fw-allow-health-checks"
  network     = local.network_name
  description = "Permite health checks originados pelos proxies do Google Cloud"
  direction   = "INGRESS"
  priority    = 1000

  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]

  allow {
    protocol = "tcp"
  }
}

# Permite acesso via Identity-Aware Proxy (IAP) para SSH seguro sem IP público
resource "google_compute_firewall" "allow_iap" {
  count       = var.create_vpc ? 1 : 0
  project     = var.project_id
  name        = "${local.name_prefix}-fw-allow-iap-ssh"
  network     = local.network_name
  description = "Permite conexoes SSH/RDP seguras atraves do Identity-Aware Proxy (IAP)"
  direction   = "INGRESS"
  priority    = 1000

  source_ranges = ["35.235.240.0/20"]

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }
}

# 6. Cloud Armor (WAF) Baseline
resource "google_compute_security_policy" "cloud_armor" {
  count       = var.enable_cloud_armor ? 1 : 0
  project     = var.project_id
  name        = "${local.name_prefix}-armor-${local.region_clean}"
  description = "Politica de seguranca Cloud Armor WAF para ${local.name_prefix}"

  # Regra padrao de aceitacao
  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Regra padrao de allow"
  }

  # Rate limiting para prevencao de DoS
  rule {
    action   = "rate_based_ban"
    priority = "1000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    rate_limit_options {
      conform_action = "allow"
      exceed_action  = "deny(429)"
      enforce_on_key = "IP"
      rate_limit_threshold {
        count        = var.cloud_armor_rate_limit_count
        interval_sec = 60
      }
      ban_duration_sec = 300
    }
    description = "Rate limit de protecao contra abusos e DoS"
  }

  # Bloqueio de OWASP SQLi comum
  rule {
    action   = "deny(403)"
    priority = "2000"
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('sqli-v33-stable')"
      }
    }
    description = "Bloqueio preventivo de SQL Injection (OWASP)"
  }

  # Bloqueio de OWASP XSS comum
  rule {
    action   = "deny(403)"
    priority = "2001"
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('xss-v33-stable')"
      }
    }
    description = "Bloqueio preventivo de Cross-Site Scripting (OWASP)"
  }
}

