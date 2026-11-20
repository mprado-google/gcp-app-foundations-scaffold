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
  name_prefix = "${var.company_prefix}-${var.project_name}-${var.environment}"
}

resource "google_looker_instance" "looker" {
  name               = "${local.name_prefix}-looker"
  project            = var.project_id
  region             = var.region
  platform_edition   = var.platform_edition
  private_ip_enabled = var.private_ip_enabled
  consumer_network   = var.consumer_network
  reserved_range     = var.reserved_range

  oauth_config {
    client_id     = var.oauth_client_id
    client_secret = var.oauth_client_secret
  }

  lifecycle {
    ignore_changes = [oauth_config]
  }
}

