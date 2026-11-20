project_id       = "seia-adapar-hml"
environment      = "hml"
company_prefix   = "seia"
project_name     = "adapar"
region           = "southamerica-east1"
secondary_region = "us-central1"

common_labels = {
  environment = "hml"
  project     = "adapar-censo-rebanhos"
  owner       = "squad-censo"
  managed_by  = "terraform"
}

# --- Feature Flags ---
enable_project_services    = true
enable_networking          = true
enable_security_iam        = true
enable_storage_geodatalake = true
enable_cloud_sql           = true
enable_memorystore         = true
enable_bigquery            = true
enable_gke                 = true
enable_compute_vm          = true

# --- Configurações de Rede Privada ---
create_vpc         = true
create_nat         = true
create_psa         = true
psa_prefix_length  = 16
enable_cloud_armor = true

subnets = [
  {
    name                     = "app"
    ip_cidr_range            = "10.20.10.0/24"
    private_ip_google_access = true
    description              = "Sub-rede privada HML para aplicacoes, Cloud Run direct egress e workers"
  },
  {
    name                     = "gke"
    ip_cidr_range            = "10.20.20.0/24"
    private_ip_google_access = true
    description              = "Sub-rede privada HML para o cluster GKE (eoAPI)"
    secondary_ip_ranges = [
      {
        range_name    = "pods"
        ip_cidr_range = "10.200.0.0/16"
      },
      {
        range_name    = "services"
        ip_cidr_range = "10.201.0.0/20"
      }
    ]
  },
  {
    name                     = "data"
    ip_cidr_range            = "10.20.30.0/24"
    private_ip_google_access = true
    description              = "Sub-rede privada HML para servicos e pipelines de dados"
  }
]

# --- Configurações de Segurança e CMEK ---
enable_cmek = true

# --- Dimensionamento do Cloud SQL (hml ~50%: REGIONAL HA para testes de failover, 500 GiB SSD) ---
cloud_sql_tier                  = "db-custom-4-15360"
cloud_sql_disk_size_gb          = 500
cloud_sql_availability_type     = "REGIONAL"
cloud_sql_deletion_protection   = false
cloud_sql_backup_retention_days = 15

# --- Dimensionamento do GeoDataLake (hml: 1 ano de retencao) ---
storage_versioning_enabled       = true
storage_force_destroy            = false
storage_lifecycle_retention_days = 365

# --- Dimensionamento do Memorystore Redis (hml ~50%: 4 GB, tier STANDARD_HA) ---
memorystore_memory_size_gb = 4
memorystore_tier           = "STANDARD_HA"

# --- Dimensionamento do BigQuery ---
bigquery_delete_contents_on_destroy = false

# --- Dimensionamento do GKE (hml ~50%: zonal, e2-standard-4, 2 a 6 nos) ---
gke_regional_cluster          = false
gke_primary_node_machine_type = "e2-standard-4"
gke_primary_min_nodes         = 2
gke_primary_max_nodes         = 6

# --- Dimensionamento do Compute VM Workers (sem Vertex AI Workbench em HML) ---
compute_machine_type   = "n1-standard-4"
compute_gpu_count      = 1
compute_target_size    = 0
enable_workbench       = false
workbench_machine_type = "e2-standard-4"
