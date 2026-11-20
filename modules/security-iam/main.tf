terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

data "google_project" "current" {
  project_id = var.project_id
}

locals {
  region_clean = replace(var.region, "-", "")
  name_prefix  = "${var.company_prefix}-${var.project_name}-${var.environment}"

  # Service Accounts dedicadas (respeitando o limite de 30 caracteres do account_id)
  sa_definitions = {
    cloudsql = {
      id          = substr("${local.name_prefix}-sa-cloudsql", 0, 30)
      display     = "Service Account para Cloud SQL (${local.name_prefix})"
      description = "SA dedicada para operações e acesso ao Cloud SQL com menor privilégio"
      roles       = ["roles/cloudsql.client", "roles/cloudsql.instanceUser"]
    }
    storage = {
      id          = substr("${local.name_prefix}-sa-storage", 0, 30)
      display     = "Service Account para GeoDataLake (${local.name_prefix})"
      description = "SA dedicada para ingestão e leitura nos buckets de imagens e dados geo"
      roles       = ["roles/storage.objectUser"]
    }
    app = {
      id          = substr("${local.name_prefix}-sa-app", 0, 30)
      display     = "Service Account para Aplicações (${local.name_prefix})"
      description = "SA dedicada para workloads (APIs, Cloud Run e pods GKE via Workload Identity)"
      roles       = ["roles/logging.logWriter", "roles/monitoring.metricWriter", "roles/cloudtrace.agent"]
    }
    ingestion = {
      id          = substr("${local.name_prefix}-sa-ingestion", 0, 30)
      display     = "Service Account para Ingestão e Processamento (${local.name_prefix})"
      description = "SA dedicada para workers de fotogrametria e pipelines de dados"
      roles       = ["roles/pubsub.subscriber", "roles/pubsub.publisher", "roles/storage.objectViewer"]
    }
  }
}

# 1. Service Accounts Dedicadas (Princípio do Menor Privilégio - Proibido Compute Default SA)
resource "google_service_account" "service_accounts" {
  for_each     = local.sa_definitions
  project      = var.project_id
  account_id   = each.value.id
  display_name = each.value.display
  description  = each.value.description
}

# Atribuição de papéis específicos de menor privilégio
locals {
  sa_role_pairs = flatten([
    for sa_key, sa_val in local.sa_definitions : [
      for role in sa_val.roles : {
        key  = "${sa_key}-${role}"
        sa   = sa_key
        role = role
      }
    ]
  ])
}

resource "google_project_iam_member" "sa_roles" {
  for_each = { for pair in local.sa_role_pairs : pair.key => pair }
  project  = var.project_id
  role     = each.value.role
  member   = "serviceAccount:${google_service_account.service_accounts[each.value.sa].email}"
}

# 2. Cloud KMS (CMEK)
resource "google_kms_key_ring" "keyring" {
  count    = var.enable_cmek ? 1 : 0
  project  = var.project_id
  name     = "${local.name_prefix}-keyring-${local.region_clean}"
  location = var.region
}

# Chave KMS para GeoDataLake (GCS)
resource "google_kms_crypto_key" "storage_key" {
  count           = var.enable_cmek ? 1 : 0
  name            = "${local.name_prefix}-key-storage"
  key_ring        = google_kms_key_ring.keyring[0].id
  rotation_period = var.kms_rotation_period
  purpose         = "ENCRYPT_DECRYPT"
  labels          = var.common_labels

  lifecycle {
    prevent_destroy = false
  }
}

# Chave KMS para Cloud SQL
resource "google_kms_crypto_key" "sql_key" {
  count           = var.enable_cmek ? 1 : 0
  name            = "${local.name_prefix}-key-sql"
  key_ring        = google_kms_key_ring.keyring[0].id
  rotation_period = var.kms_rotation_period
  purpose         = "ENCRYPT_DECRYPT"
  labels          = var.common_labels

  lifecycle {
    prevent_destroy = false
  }
}

# Chave KMS para Secret Manager
resource "google_kms_crypto_key" "secret_key" {
  count           = var.enable_cmek ? 1 : 0
  name            = "${local.name_prefix}-key-secret"
  key_ring        = google_kms_key_ring.keyring[0].id
  rotation_period = var.kms_rotation_period
  purpose         = "ENCRYPT_DECRYPT"
  labels          = var.common_labels

  lifecycle {
    prevent_destroy = false
  }
}

# Permissões CMEK para Service Agents do Google
# 2.1 Permissão para Cloud Storage Agent
resource "google_kms_crypto_key_iam_member" "gcs_cmek_binding" {
  count         = var.enable_cmek ? 1 : 0
  crypto_key_id = google_kms_crypto_key.storage_key[0].id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.current.number}@gs-project-accounts.iam.gserviceaccount.com"
}

# 2.2 Permissão para Cloud SQL Agent
resource "google_kms_crypto_key_iam_member" "sql_cmek_binding" {
  count         = var.enable_cmek ? 1 : 0
  crypto_key_id = google_kms_crypto_key.sql_key[0].id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-cloud-sql.iam.gserviceaccount.com"
}

# 3. Secret Manager
resource "google_secret_manager_secret" "db_credentials" {
  count     = var.create_secret_manager_secrets ? 1 : 0
  project   = var.project_id
  secret_id = "${local.name_prefix}-sec-db-credentials"
  labels    = var.common_labels

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "app_secrets" {
  count     = var.create_secret_manager_secrets ? 1 : 0
  project   = var.project_id
  secret_id = "${local.name_prefix}-sec-app-secrets"
  labels    = var.common_labels

  replication {
    auto {}
  }
}

# Permissão para as SAs dedicadas acessarem os segredos necessários
resource "google_secret_manager_secret_iam_member" "app_secret_access" {
  count     = var.create_secret_manager_secrets ? 1 : 0
  secret_id = google_secret_manager_secret.db_credentials[0].id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.service_accounts["app"].email}"
}

# 4. Suporte a Identity-Aware Proxy (IAP)
resource "google_project_iam_member" "iap_tunnel_users" {
  for_each = toset(var.iap_tunnel_members)
  project  = var.project_id
  role     = "roles/iap.tunnelResourceAccessor"
  member   = each.value
}

resource "google_project_iam_member" "iap_web_users" {
  for_each = toset(var.iap_web_members)
  project  = var.project_id
  role     = "roles/iap.httpsResourceAccessor"
  member   = each.value
}

