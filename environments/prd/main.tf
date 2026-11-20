provider "google" {
  project        = var.project_id
  region         = var.region
  default_labels = var.common_labels
}

# 1. Habilitação Centralizada de APIs
module "project_services" {
  count      = var.enable_project_services ? 1 : 0
  source     = "../../modules/project-services"
  project_id = var.project_id
}

# 2. Segurança, IAM e CMEK
module "security_iam" {
  count  = var.enable_security_iam ? 1 : 0
  source = "../../modules/security-iam"

  project_id     = var.project_id
  environment    = var.environment
  company_prefix = var.company_prefix
  project_name   = var.project_name
  region         = var.region
  common_labels  = var.common_labels
  enable_cmek    = var.enable_cmek

  depends_on = [module.project_services]
}

# 3. Topologia de Rede Privada (VPC, Subnets, Cloud NAT, PSA, Cloud Armor)
module "networking" {
  count  = var.enable_networking ? 1 : 0
  source = "../../modules/networking"

  project_id         = var.project_id
  environment        = var.environment
  company_prefix     = var.company_prefix
  project_name       = var.project_name
  region             = var.region
  common_labels      = var.common_labels
  create_vpc         = var.create_vpc
  subnets            = var.subnets
  create_nat         = var.create_nat
  create_psa         = var.create_psa
  psa_prefix_length  = var.psa_prefix_length
  enable_cloud_armor = var.enable_cloud_armor

  depends_on = [module.project_services]
}

# 4. Storage GeoDataLake (Bronze, Silver, Gold em southamerica-east1 + GEE em us-central1)
module "storage_geodatalake" {
  count  = var.enable_storage_geodatalake ? 1 : 0
  source = "../../modules/storage-geodatalake"

  project_id               = var.project_id
  environment              = var.environment
  company_prefix           = var.company_prefix
  project_name             = var.project_name
  primary_region           = var.region
  gee_region               = var.secondary_region
  common_labels            = var.common_labels
  versioning_enabled       = var.storage_versioning_enabled
  kms_key_name             = var.enable_cmek && var.enable_security_iam ? module.security_iam[0].storage_crypto_key_id : null
  force_destroy            = var.storage_force_destroy
  lifecycle_retention_days = var.storage_lifecycle_retention_days

  depends_on = [
    module.project_services,
    module.security_iam
  ]
}

# 5. Cloud SQL PostgreSQL com PostGIS e Private IP
module "cloud_sql" {
  count  = var.enable_cloud_sql && var.enable_networking ? 1 : 0
  source = "../../modules/cloud-sql"

  project_id            = var.project_id
  environment           = var.environment
  company_prefix        = var.company_prefix
  project_name          = var.project_name
  region                = var.region
  common_labels         = var.common_labels
  network_id            = module.networking[0].network_id
  allocated_ip_range    = module.networking[0].psa_range_name
  kms_key_name          = var.enable_cmek && var.enable_security_iam ? module.security_iam[0].sql_crypto_key_id : null
  tier                  = var.cloud_sql_tier
  disk_size_gb          = var.cloud_sql_disk_size_gb
  availability_type     = var.cloud_sql_availability_type
  deletion_protection   = var.cloud_sql_deletion_protection
  backup_retention_days = var.cloud_sql_backup_retention_days

  depends_on = [
    module.project_services,
    module.networking,
    module.security_iam
  ]
}

# 6. Memorystore Redis (Cache de tiles dinâmicos e STAC via Private Service Access)
module "memorystore" {
  count  = var.enable_memorystore && var.enable_networking ? 1 : 0
  source = "../../modules/memorystore"

  project_id     = var.project_id
  environment    = var.environment
  company_prefix = var.company_prefix
  project_name   = var.project_name
  region         = var.region
  network_id     = module.networking[0].network_id
  memory_size_gb = var.memorystore_memory_size_gb
  tier           = var.memorystore_tier
  common_labels  = var.common_labels

  depends_on = [
    module.project_services,
    module.networking
  ]
}

# 7. BigQuery Datasets (Gold Analytics e BigQuery GIS)
module "bigquery" {
  count  = var.enable_bigquery ? 1 : 0
  source = "../../modules/bigquery"

  project_id                  = var.project_id
  environment                 = var.environment
  company_prefix              = var.company_prefix
  project_name                = var.project_name
  location                    = var.region
  common_labels               = var.common_labels
  delete_contents_on_destroy  = var.bigquery_delete_contents_on_destroy
  kms_key_name                = var.enable_cmek && var.enable_security_iam ? module.security_iam[0].storage_crypto_key_id : null
  authorized_service_accounts = var.enable_security_iam ? [module.security_iam[0].sa_emails["app"], module.security_iam[0].sa_emails["ingestion"]] : []

  depends_on = [
    module.project_services,
    module.security_iam
  ]
}

# 8. GKE Privado (eoAPI: STAC FastAPI, TiTiler, TiPG)
module "gke" {
  count  = var.enable_gke && var.enable_networking && var.enable_security_iam ? 1 : 0
  source = "../../modules/gke"

  project_id                    = var.project_id
  environment                   = var.environment
  company_prefix                = var.company_prefix
  project_name                  = var.project_name
  region                        = var.region
  network_id                    = module.networking[0].network_id
  subnet_id                     = module.networking[0].subnets["gke"].id
  pods_secondary_range_name     = "pods"
  services_secondary_range_name = "services"
  service_account_email         = module.security_iam[0].sa_emails["app"]
  common_labels                 = var.common_labels
  regional_cluster              = var.gke_regional_cluster
  primary_node_machine_type     = var.gke_primary_node_machine_type
  primary_min_nodes             = var.gke_primary_min_nodes
  primary_max_nodes             = var.gke_primary_max_nodes
  enable_backup_for_gke         = false

  depends_on = [
    module.project_services,
    module.networking,
    module.security_iam
  ]
}

# 9. Compute VM Workers GPU & Vertex AI Workbench (Fotogrametria e Experimentação em Dev)
module "compute_vm" {
  count  = var.enable_compute_vm && var.enable_networking && var.enable_security_iam ? 1 : 0
  source = "../../modules/compute-vm"

  project_id             = var.project_id
  environment            = var.environment
  company_prefix         = var.company_prefix
  project_name           = var.project_name
  region                 = var.region
  zone                   = "${var.region}-a"
  network_id             = module.networking[0].network_id
  subnet_id              = module.networking[0].subnets["app"].id
  service_account_email  = module.security_iam[0].sa_emails["ingestion"]
  common_labels          = var.common_labels
  kms_key_name           = var.enable_cmek && var.enable_security_iam ? module.security_iam[0].storage_crypto_key_id : null
  machine_type           = var.compute_machine_type
  gpu_count              = var.compute_gpu_count
  target_size            = var.compute_target_size
  enable_workbench       = var.enable_workbench
  workbench_machine_type = var.workbench_machine_type

  depends_on = [
    module.project_services,
    module.networking,
    module.security_iam
  ]
}

# 10. Cloud Composer 3 (Orquestração de DAGs)
module "composer" {
  count  = var.enable_composer && var.enable_security_iam ? 1 : 0
  source = "../../modules/composer"

  project_id            = var.project_id
  environment           = var.environment
  company_prefix        = var.company_prefix
  project_name          = var.project_name
  region                = var.region
  service_account_email = module.security_iam[0].sa_emails["app"]
  common_labels         = var.common_labels
  environment_size      = var.composer_environment_size

  depends_on = [
    module.project_services,
    module.security_iam
  ]
}

# 11. Pub/Sub (Eventos de Upload, Processamento e Dead-Letter Queues)
module "pubsub" {
  count  = var.enable_pubsub ? 1 : 0
  source = "../../modules/pubsub"

  project_id     = var.project_id
  environment    = var.environment
  company_prefix = var.company_prefix
  project_name   = var.project_name
  common_labels  = var.common_labels
  kms_key_name   = var.enable_cmek && var.enable_security_iam ? module.security_iam[0].storage_crypto_key_id : null

  depends_on = [
    module.project_services,
    module.security_iam
  ]
}

# 12. Cloud Run (Web App, Business API, Quick Count e Conversational Agent)
module "cloud_run" {
  count  = var.enable_cloud_run && var.enable_security_iam && var.enable_networking ? 1 : 0
  source = "../../modules/cloud-run"

  project_id            = var.project_id
  environment           = var.environment
  company_prefix        = var.company_prefix
  project_name          = var.project_name
  region                = var.region
  network_id            = module.networking[0].network_id
  subnet_id             = module.networking[0].subnets["app"].id
  service_account_email = module.security_iam[0].sa_emails["app"]
  common_labels         = var.common_labels
  min_instance_count    = var.cloud_run_min_instances
  max_instance_count    = var.cloud_run_max_instances

  depends_on = [
    module.project_services,
    module.networking,
    module.security_iam
  ]
}

# 13. Cloud Spanner (Catálogo Padrão do ACG - Opcional)
module "spanner" {
  count  = var.enable_spanner ? 1 : 0
  source = "../../modules/spanner"

  project_id          = var.project_id
  environment         = var.environment
  company_prefix      = var.company_prefix
  project_name        = var.project_name
  common_labels       = var.common_labels
  processing_units    = var.spanner_processing_units
  deletion_protection = var.spanner_deletion_protection

  depends_on = [module.project_services]
}

# 14. Looker Core (Dashboard Executivo com IP Privado - Opcional)
module "looker_core" {
  count  = var.enable_looker_core && var.enable_networking ? 1 : 0
  source = "../../modules/looker-core"

  project_id         = var.project_id
  environment        = var.environment
  company_prefix     = var.company_prefix
  project_name       = var.project_name
  region             = var.region
  common_labels      = var.common_labels
  platform_edition   = var.looker_platform_edition
  private_ip_enabled = true
  consumer_network   = module.networking[0].network_id

  depends_on = [
    module.project_services,
    module.networking
  ]
}
