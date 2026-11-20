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
  region_clean  = replace(var.region, "-", "")
  instance_name = "${var.company_prefix}-${var.project_name}-${var.environment}-redis-${local.region_clean}"
}

resource "google_redis_instance" "cache" {
  name                    = local.instance_name
  project                 = var.project_id
  region                  = var.region
  tier                    = var.tier
  memory_size_gb          = var.memory_size_gb
  redis_version           = var.redis_version
  authorized_network      = var.network_id
  connect_mode            = "PRIVATE_SERVICE_ACCESS"
  auth_enabled            = var.auth_enabled
  transit_encryption_mode = var.transit_encryption_mode

  labels = var.common_labels
}

