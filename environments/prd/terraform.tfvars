project_id       = "seia-adapar-prd"
environment      = "prd"
company_prefix   = "seia"
project_name     = "adapar"
region           = "southamerica-east1"
secondary_region = "us-central1"

common_labels = {
  environment = "prd"
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
    ip_cidr_range            = "10.30.10.0/24"
    private_ip_google_access = true
    description              = "Sub-rede privada PRD para aplicacoes, Cloud Run direct egress e workers"
  },
  {
    name                     = "gke"
    ip_cidr_range            = "10.30.20.0/24"
    private_ip_google_access = true
    description              = "Sub-rede privada PRD para o cluster GKE (eoAPI)"
    secondary_ip_ranges = [
      {
        range_name    = "pods"
        ip_cidr_range = "10.210.0.0/16"
      },
      {
        range_name    = "services"
        ip_cidr_range = "10.211.0.0/20"
      }
    ]
  },
  {
    name                     = "data"
    ip_cidr_range            = "10.30.30.0/24"
    private_ip_google_access = true
    description              = "Sub-rede privada PRD para servicos e pipelines de dados"
  }
]

# --- Configurações de Segurança e CMEK (prd: CMEK obrigatorio) ---
enable_cmek = true

# --- Dimensionamento do Cloud SQL (prd 100%: REGIONAL HA, 1000 GiB SSD, deletion_protection = true) ---
cloud_sql_tier                  = "db-custom-8-30720"
cloud_sql_disk_size_gb          = 1000
cloud_sql_availability_type     = "REGIONAL"
cloud_sql_deletion_protection   = true
cloud_sql_backup_retention_days = 30

# --- Dimensionamento do GeoDataLake (prd: retencao de 5 anos = 1825 dias, force_destroy = false) ---
storage_versioning_enabled       = true
storage_force_destroy            = false
storage_lifecycle_retention_days = 1825

# --- Dimensionamento do Memorystore Redis (prd 100%: 8 GB, tier STANDARD_HA) ---
memorystore_memory_size_gb = 8
memorystore_tier           = "STANDARD_HA"

# --- Dimensionamento do BigQuery (prd: protecao contra exclusao de dados) ---
bigquery_delete_contents_on_destroy = false

# --- Dimensionamento do GKE (prd 100%: cluster regional HA, e2-standard-8, 3 a 12 nos) ---
gke_regional_cluster          = true
gke_primary_node_machine_type = "e2-standard-8"
gke_primary_min_nodes         = 3
gke_primary_max_nodes         = 12

# --- Dimensionamento do Compute VM Workers (prd 100%: GPU NVIDIA T4, sem Workbench) ---
compute_machine_type   = "n1-standard-8"
compute_gpu_count      = 1
compute_target_size    = 1
enable_workbench       = false
workbench_machine_type = "e2-standard-4"
