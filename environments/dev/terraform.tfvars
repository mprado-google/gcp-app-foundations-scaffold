project_id       = "seia-adapar-dev-lab-4408"
environment      = "dev"
company_prefix   = "seia"
project_name     = "adapar"
region           = "southamerica-east1"
secondary_region = "us-central1"

common_labels = {
  environment = "dev"
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
    ip_cidr_range            = "10.10.10.0/24"
    private_ip_google_access = true
    description              = "Sub-rede privada para aplicacoes, Cloud Run direct egress, Workbench e workers"
  },
  {
    name                     = "gke"
    ip_cidr_range            = "10.10.20.0/24"
    private_ip_google_access = true
    description              = "Sub-rede privada para o cluster GKE (eoAPI)"
    secondary_ip_ranges = [
      {
        range_name    = "pods"
        ip_cidr_range = "10.100.0.0/16"
      },
      {
        range_name    = "services"
        ip_cidr_range = "10.101.0.0/20"
      }
    ]
  },
  {
    name                     = "data"
    ip_cidr_range            = "10.10.30.0/24"
    private_ip_google_access = true
    description              = "Sub-rede privada para servicos e pipelines de dados"
  }
]

# --- Configurações de Segurança e CMEK (dev: CMEK opcional) ---
enable_cmek = false

# --- Dimensionamento do Cloud SQL (dev ~25%: single-zone, 250 GiB SSD, sem deletion protection) ---
cloud_sql_tier                  = "db-custom-2-7680"
cloud_sql_disk_size_gb          = 250
cloud_sql_availability_type     = "ZONAL"
cloud_sql_deletion_protection   = false
cloud_sql_backup_retention_days = 7

# --- Dimensionamento do GeoDataLake (dev: force_destroy ativo para testes) ---
storage_versioning_enabled       = true
storage_force_destroy            = true
storage_lifecycle_retention_days = 180

# --- Dimensionamento do Memorystore Redis (dev ~25%: 2 GB, tier BASIC) ---
memorystore_memory_size_gb = 2
memorystore_tier           = "BASIC"

# --- Dimensionamento do BigQuery ---
bigquery_delete_contents_on_destroy = true

# --- Dimensionamento do GKE (dev ~25%: zonal, e2-standard-2, 1 a 3 nós) ---
gke_regional_cluster          = false
gke_primary_node_machine_type = "e2-standard-2"
gke_primary_min_nodes         = 1
gke_primary_max_nodes         = 3

# --- Dimensionamento do Compute VM Workers & Vertex AI Workbench (exclusivo dev) ---
compute_machine_type   = "n1-standard-4"
compute_gpu_count      = 1
compute_target_size    = 0
enable_workbench       = true
workbench_machine_type = "e2-standard-4"

# --- Feature Flags: Load Balancer e Vertex AI ---
enable_load_balancer = true
enable_vertex_ai     = true

# --- Configurações do Load Balancer (dev: sem domínios SSL, backends provisórios) ---
# Adicione os domínios reais antes de executar em produção
lb_domains           = []
lb_enable_cdn        = true
lb_health_check_path = "/healthz"
lb_backends          = []

# --- Configurações do Vertex AI (dev: Workbench habilitado, sizing mínimo) ---
enable_workbench_vertex        = true
vertex_workbench_machine_type  = "e2-standard-4"
vertex_force_destroy           = true
vertex_artifact_nearline_days  = 90
vertex_artifact_retention_days = 365
