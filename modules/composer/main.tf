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

resource "google_composer_environment" "composer" {
  name    = "${local.name_prefix}-cmp3"
  project = var.project_id
  region  = var.region

  config {
    environment_size = var.environment_size

    node_config {
      service_account = var.service_account_email
    }

    software_config {
      image_version = var.image_version
    }
  }

  labels = var.common_labels
}

