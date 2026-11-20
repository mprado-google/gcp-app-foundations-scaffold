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
  primary_region_clean = replace(var.primary_region, "-", "")
  gee_region_clean     = replace(var.gee_region, "-", "")
  name_prefix          = "${var.company_prefix}-${var.project_name}-${var.environment}"
  suffix               = var.bucket_suffix != "" ? "-${var.bucket_suffix}" : ""

  primary_buckets = {
    bronze = {
      name        = "${local.name_prefix}-bronze-${local.primary_region_clean}${local.suffix}"
      description = "Camada Bronze (RAW): imagens brutas de drones/satélites e telemetria"
      tier        = "bronze"
      cors        = false
    }
    silver = {
      name        = "${local.name_prefix}-silver-${local.primary_region_clean}${local.suffix}"
      description = "Camada Silver (Trusted COGs): Cloud Optimized GeoTIFFs calibrados e catalogados"
      tier        = "silver"
      cors        = true
    }
    gold = {
      name        = "${local.name_prefix}-gold-${local.primary_region_clean}${local.suffix}"
      description = "Camada Gold (Refined): mosaicos prontos, vetores de rebanhos e análises"
      tier        = "gold"
      cors        = true
    }
  }

  gee_bucket_name = "${local.name_prefix}-gee-pub-${local.gee_region_clean}${local.suffix}"
}

# 1. Buckets do GeoDataLake na Região Principal (southamerica-east1)
resource "google_storage_bucket" "primary_lake" {
  for_each                    = local.primary_buckets
  name                        = each.value.name
  project                     = var.project_id
  location                    = var.primary_region
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = var.force_destroy

  versioning {
    enabled = var.versioning_enabled
  }

  dynamic "encryption" {
    for_each = var.kms_key_name != null && var.kms_key_name != "" ? [var.kms_key_name] : []
    content {
      default_kms_key_name = encryption.value
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.enable_lifecycle_rules ? [1] : []
    content {
      action {
        type          = "SetStorageClass"
        storage_class = "NEARLINE"
      }
      condition {
        age = var.lifecycle_nearline_days
      }
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.enable_lifecycle_rules ? [1] : []
    content {
      action {
        type          = "SetStorageClass"
        storage_class = "ARCHIVE"
      }
      condition {
        age = var.lifecycle_archive_days
      }
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.enable_lifecycle_rules && var.lifecycle_retention_days > 0 ? [1] : []
    content {
      action {
        type = "Delete"
      }
      condition {
        age = var.lifecycle_retention_days
      }
    }
  }

  lifecycle_rule {
    action {
      type = "AbortIncompleteMultipartUpload"
    }
    condition {
      age = 7
    }
  }

  dynamic "cors" {
    for_each = each.value.cors ? [1] : []
    content {
      origin          = var.cors_allowed_origins
      method          = ["GET", "HEAD"]
      response_header = ["Content-Type", "Range", "User-Agent", "x-goog-*"]
      max_age_seconds = 3600
    }
  }

  labels = merge(
    var.common_labels,
    {
      tier = each.value.tier
    }
  )
}

# 2. Bucket Exclusivo de Publicação no Google Earth Engine (us-central1)
# Ativos COG exigem bucket localizado nos EUA para integração nativa com GEE
resource "google_storage_bucket" "gee_publication" {
  name                        = local.gee_bucket_name
  project                     = var.project_id
  location                    = var.gee_region
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = var.force_destroy

  versioning {
    enabled = var.versioning_enabled
  }

  dynamic "encryption" {
    for_each = var.gee_kms_key_name != null && var.gee_kms_key_name != "" ? [var.gee_kms_key_name] : []
    content {
      default_kms_key_name = encryption.value
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.enable_lifecycle_rules ? [1] : []
    content {
      action {
        type          = "SetStorageClass"
        storage_class = "NEARLINE"
      }
      condition {
        age = var.lifecycle_nearline_days
      }
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.enable_lifecycle_rules ? [1] : []
    content {
      action {
        type          = "SetStorageClass"
        storage_class = "ARCHIVE"
      }
      condition {
        age = var.lifecycle_archive_days
      }
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.enable_lifecycle_rules && var.lifecycle_retention_days > 0 ? [1] : []
    content {
      action {
        type = "Delete"
      }
      condition {
        age = var.lifecycle_retention_days
      }
    }
  }

  lifecycle_rule {
    action {
      type = "AbortIncompleteMultipartUpload"
    }
    condition {
      age = 7
    }
  }

  cors {
    origin          = var.cors_allowed_origins
    method          = ["GET", "HEAD"]
    response_header = ["Content-Type", "Range", "User-Agent", "x-goog-*"]
    max_age_seconds = 3600
  }

  labels = merge(
    var.common_labels,
    {
      tier = "gee-publication"
    }
  )
}

