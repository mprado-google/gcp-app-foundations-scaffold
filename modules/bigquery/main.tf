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
  name_prefix = "${var.company_prefix}_${var.project_name}_${var.environment}"

  datasets = {
    gold_analytics = {
      dataset_id  = "${local.name_prefix}_gold_analytics"
      description = "Dataset da camada Gold para análises, agregações e indicadores do Censo de Rebanhos"
    }
    gis_census = {
      dataset_id  = "${local.name_prefix}_gis_census"
      description = "Dataset geoespacial para BigQuery GIS, delimitação de propriedades rurais e geometrias"
    }
  }
}

# 1. Datasets da Camada Gold e BigQuery GIS
resource "google_bigquery_dataset" "datasets" {
  for_each                   = local.datasets
  project                    = var.project_id
  dataset_id                 = each.value.dataset_id
  friendly_name              = each.value.dataset_id
  description                = each.value.description
  location                   = var.location
  delete_contents_on_destroy = var.delete_contents_on_destroy

  dynamic "default_encryption_configuration" {
    for_each = var.kms_key_name != null && var.kms_key_name != "" ? [var.kms_key_name] : []
    content {
      kms_key_name = default_encryption_configuration.value
    }
  }

  labels = var.common_labels
}

# 2. Controle de Acesso (Least Privilege)
locals {
  sa_dataset_pairs = flatten([
    for dataset_key, dataset in google_bigquery_dataset.datasets : [
      for sa_email in var.authorized_service_accounts : {
        key        = "${dataset_key}-${sa_email}"
        dataset_id = dataset.dataset_id
        email      = sa_email
      }
    ]
  ])
}

resource "google_bigquery_dataset_access" "sa_access" {
  for_each      = { for pair in local.sa_dataset_pairs : pair.key => pair }
  project       = var.project_id
  dataset_id    = each.value.dataset_id
  role          = "READER"
  user_by_email = each.value.email
}

