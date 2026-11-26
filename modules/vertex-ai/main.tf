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
  region_clean          = replace(var.region, "-", "")
  training_region_clean = replace(var.training_region, "-", "")
  name_prefix           = "${var.company_prefix}-${var.project_name}-${var.environment}"
}

# ─────────────────────────────────────────────────────────────────────────────
# 1. Bucket de Artefatos de Treinamento (us-central1 — GPUs A100 exigem EUA)
#    Conforme spec.md: "Recursos de treinamento Vertex AI (GPUs A100) em us-central1"
# ─────────────────────────────────────────────────────────────────────────────
resource "google_storage_bucket" "vertex_artifacts" {
  count                       = var.enable_vertex_ai ? 1 : 0
  project                     = var.project_id
  name                        = "${local.name_prefix}-vertex-artifacts-${local.training_region_clean}"
  location                    = var.training_region
  uniform_bucket_level_access = true
  force_destroy               = var.force_destroy

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
    condition {
      age = var.artifact_nearline_days
    }
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = var.artifact_retention_days
    }
  }

  dynamic "encryption" {
    for_each = var.kms_key_name != null ? [1] : []
    content {
      default_kms_key_name = var.kms_key_name
    }
  }

  labels = var.common_labels
}

# ─────────────────────────────────────────────────────────────────────────────
# 2. Vertex AI Dataset (gerenciamento de dados de treinamento)
# ─────────────────────────────────────────────────────────────────────────────
resource "google_vertex_ai_dataset" "training" {
  count               = var.enable_vertex_ai ? 1 : 0
  project             = var.project_id
  display_name        = "${local.name_prefix}-dataset-imagens-aereas"
  metadata_schema_uri = "gs://google-cloud-aiplatform/schema/dataset/metadata/image_1.0.0.yaml"
  region              = var.training_region

  labels = var.common_labels
}

# ─────────────────────────────────────────────────────────────────────────────
# 3. Vertex AI Tensorboard (rastreamento de experimentos de treinamento)
# ─────────────────────────────────────────────────────────────────────────────
resource "google_vertex_ai_tensorboard" "default" {
  count        = var.enable_vertex_ai ? 1 : 0
  project      = var.project_id
  display_name = "${local.name_prefix}-tensorboard"
  region       = var.training_region
  description  = "Tensorboard para rastreamento de experimentos Vertex AI de ${var.project_name} em ${var.environment}"

  labels = var.common_labels
}

# ─────────────────────────────────────────────────────────────────────────────
# 4. IAM: Permissões para a Service Account de treinamento
# ─────────────────────────────────────────────────────────────────────────────
resource "google_storage_bucket_iam_member" "vertex_sa_artifacts" {
  count  = var.enable_vertex_ai && var.service_account_email != null ? 1 : 0
  bucket = google_storage_bucket.vertex_artifacts[0].name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.service_account_email}"
}

resource "google_project_iam_member" "vertex_sa_aiplatform" {
  count   = var.enable_vertex_ai && var.service_account_email != null ? 1 : 0
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${var.service_account_email}"
}

# ─────────────────────────────────────────────────────────────────────────────
# 5. Vertex AI Workbench (EXCLUSIVO para dev — single-zone, sem GPU pesada)
#    Conforme spec.md: "único ambiente com Vertex AI Workbench"
# ─────────────────────────────────────────────────────────────────────────────
resource "google_workbench_instance" "workbench" {
  count    = var.enable_vertex_ai && var.enable_workbench ? 1 : 0
  project  = var.project_id
  name     = "${local.name_prefix}-workbench-${local.region_clean}"
  location = var.workbench_zone

  gce_setup {
    machine_type = var.workbench_machine_type

    # Sem IP externo — acesso via IAP ou Bastion
    network_interfaces {
      network  = var.network_id
      subnet   = var.subnet_id
      nic_type = "GVNIC"
    }

    service_accounts {
      email = var.service_account_email
    }

    metadata = {
      terraform = "true"
    }
  }

  labels = var.common_labels

  # Desabilitar upgrade automático — gerenciado via Terraform
  disable_proxy_access = false
}
