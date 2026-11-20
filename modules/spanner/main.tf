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

resource "google_spanner_instance" "spanner" {
  name             = "${local.name_prefix}-spanner"
  project          = var.project_id
  config           = var.config
  display_name     = "Spanner Instance ${var.environment}"
  processing_units = var.processing_units
  labels           = var.common_labels
}

resource "google_spanner_database" "database" {
  name                = var.database_name
  instance            = google_spanner_instance.spanner.name
  project             = var.project_id
  deletion_protection = var.deletion_protection
}

