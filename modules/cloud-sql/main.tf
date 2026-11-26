terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
  }
}

locals {
  region_clean  = replace(var.region, "-", "")
  instance_name = "${var.company_prefix}-${var.project_name}-${var.environment}-sql-${local.region_clean}"

  # Flags essenciais para GIS, telemetria e conformidade com PostgreSQL
  default_flags = [
    { name = "log_checkpoints", value = "on" },
    { name = "log_connections", value = "on" },
    { name = "log_disconnections", value = "on" },
    { name = "log_lock_waits", value = "on" },
    { name = "log_temp_files", value = "0" },
    { name = "autovacuum", value = "on" }
  ]

  all_flags = concat(local.default_flags, var.database_flags)
}

# 1. Instância Cloud SQL PostgreSQL Privada
resource "google_sql_database_instance" "postgres" {
  name                = local.instance_name
  project             = var.project_id
  region              = var.region
  database_version    = var.database_version
  deletion_protection = var.deletion_protection
  encryption_key_name = var.kms_key_name

  settings {
    tier              = var.tier
    edition           = "ENTERPRISE"
    availability_type = var.availability_type
    disk_type         = var.disk_type
    disk_size         = var.disk_size_gb
    disk_autoresize   = var.disk_autoresize

    # Segurança Estrita: PROIBIDO IP PÚBLICO
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.network_id
      allocated_ip_range                            = var.allocated_ip_range
      enable_private_path_for_google_cloud_services = true
      ssl_mode                                      = "ENCRYPTED_ONLY"
    }

    # Backup automatizado e Point-in-time Recovery
    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      start_time                     = "02:00"
      transaction_log_retention_days = var.environment == "prd" ? 7 : 3

      backup_retention_settings {
        retained_backups = var.backup_retention_days
        retention_unit   = "COUNT"
      }
    }

    maintenance_window {
      day          = 7 # Domingo
      hour         = 3 # 03:00 UTC
      update_track = "stable"
    }

    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = false
    }

    dynamic "database_flags" {
      for_each = { for flag in local.all_flags : flag.name => flag.value }
      content {
        name  = database_flags.key
        value = database_flags.value
      }
    }

    user_labels = var.common_labels
  }

  lifecycle {
    ignore_changes = [
      settings[0].disk_size # Permite disk_autoresize sem conflito de plan
    ]
  }
}

# 2. Criação dos Bancos de Dados (Negócio e Metadados STAC)
resource "google_sql_database" "databases" {
  for_each = toset(var.databases)
  name     = each.value
  instance = google_sql_database_instance.postgres.name
  project  = var.project_id
}

# 3. Geração de Senha Segura e Armazenamento no Secret Manager
resource "random_password" "db_password" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "google_sql_user" "app_user" {
  name     = var.app_username
  instance = google_sql_database_instance.postgres.name
  project  = var.project_id
  password = random_password.db_password.result
}

# Secret Manager para armazenamento de credenciais da aplicação (Zero hardcoded secrets)
resource "google_secret_manager_secret" "sql_credentials" {
  project   = var.project_id
  secret_id = "${local.instance_name}-credentials"
  labels    = var.common_labels

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "sql_credentials_version" {
  secret = google_secret_manager_secret.sql_credentials.id
  secret_data = jsonencode({
    instance_connection_name = google_sql_database_instance.postgres.connection_name
    host                     = google_sql_database_instance.postgres.private_ip_address
    port                     = 5432
    default_database         = var.databases[0]
    username                 = google_sql_user.app_user.name
    password                 = random_password.db_password.result
  })
}

