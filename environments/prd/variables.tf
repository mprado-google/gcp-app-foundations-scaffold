variable "project_id" {
  description = "GCP Project ID do ambiente de desenvolvimento."
  type        = string
}

variable "environment" {
  description = "Identificador do ambiente (dev)."
  type        = string
  default     = "dev"
}

variable "company_prefix" {
  description = "Prefixo da organização para recursos."
  type        = string
  default     = "seia"
}

variable "project_name" {
  description = "Nome do projeto para recursos."
  type        = string
  default     = "adapar"
}

variable "region" {
  description = "Região principal GCP."
  type        = string
  default     = "southamerica-east1"
}

variable "secondary_region" {
  description = "Região secundária GCP (obrigatória para GEE em us-central1)."
  type        = string
  default     = "us-central1"
}

variable "common_labels" {
  description = "Labels obrigatórias conforme code_guidance.md (environment, project, owner, managed_by)."
  type        = map(string)
}

# --- Feature Flags ---
variable "enable_project_services" {
  description = "Feature flag para ativação do módulo project-services."
  type        = bool
  default     = true
}

variable "enable_networking" {
  description = "Feature flag para ativação do módulo networking."
  type        = bool
  default     = true
}

variable "enable_security_iam" {
  description = "Feature flag para ativação do módulo security-iam."
  type        = bool
  default     = true
}

variable "enable_storage_geodatalake" {
  description = "Feature flag para ativação do módulo storage-geodatalake."
  type        = bool
  default     = true
}

variable "enable_cloud_sql" {
  description = "Feature flag para ativação do módulo cloud-sql."
  type        = bool
  default     = true
}

variable "enable_memorystore" {
  description = "Feature flag para ativação do módulo memorystore."
  type        = bool
  default     = true
}

variable "enable_bigquery" {
  description = "Feature flag para ativação do módulo bigquery."
  type        = bool
  default     = true
}

variable "enable_gke" {
  description = "Feature flag para ativação do módulo gke."
  type        = bool
  default     = true
}

variable "enable_compute_vm" {
  description = "Feature flag para ativação do módulo compute-vm."
  type        = bool
  default     = true
}

variable "enable_composer" {
  description = "Feature flag para ativação do módulo composer."
  type        = bool
  default     = true
}

variable "enable_pubsub" {
  description = "Feature flag para ativação do módulo pubsub."
  type        = bool
  default     = true
}

variable "enable_cloud_run" {
  description = "Feature flag para ativação do módulo cloud-run."
  type        = bool
  default     = true
}

variable "enable_spanner" {
  description = "Feature flag para ativação do módulo spanner."
  type        = bool
  default     = false
}

variable "enable_looker_core" {
  description = "Feature flag para ativação do módulo looker-core."
  type        = bool
  default     = false
}

# --- Configurações de Rede ---
variable "create_vpc" {
  description = "Define se a VPC será criada pelo módulo ou se utilizará existente (Shared VPC)."
  type        = bool
  default     = true
}

variable "subnets" {
  description = "Lista de sub-redes a serem criadas na VPC."
  type = list(object({
    name                     = string
    ip_cidr_range            = string
    region                   = optional(string)
    private_ip_google_access = optional(bool, true)
    secondary_ip_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })), [])
    description = optional(string)
  }))
  default = []
}

variable "create_nat" {
  description = "Define se Cloud Router e Cloud NAT serão provisionados para saída segura à internet."
  type        = bool
  default     = true
}

variable "create_psa" {
  description = "Define se a conexão Private Service Access (para Cloud SQL/Memorystore) será criada."
  type        = bool
  default     = true
}

variable "psa_prefix_length" {
  description = "Tamanho do prefixo CIDR reservado para Private Service Access."
  type        = number
  default     = 16
}

variable "enable_cloud_armor" {
  description = "Define se a política WAF do Cloud Armor será provisionada."
  type        = bool
  default     = true
}

# --- Configurações de Segurança e CMEK ---
variable "enable_cmek" {
  description = "Habilita CMEK via Cloud KMS."
  type        = bool
  default     = false
}

# --- Configurações do Cloud SQL (Sizing dev ~25%) ---
variable "cloud_sql_tier" {
  description = "Tipo de máquina para Cloud SQL."
  type        = string
  default     = "db-custom-2-7680"
}

variable "cloud_sql_disk_size_gb" {
  description = "Tamanho do disco Cloud SQL em GiB."
  type        = number
  default     = 250
}

variable "cloud_sql_availability_type" {
  description = "Disponibilidade Cloud SQL (REGIONAL ou ZONAL)."
  type        = string
  default     = "ZONAL"
}

variable "cloud_sql_deletion_protection" {
  description = "Proteção de deleção para Cloud SQL."
  type        = bool
  default     = false
}

variable "cloud_sql_backup_retention_days" {
  description = "Dias de retenção para backups do Cloud SQL."
  type        = number
  default     = 7
}

# --- Configurações do Storage GeoDataLake ---
variable "storage_versioning_enabled" {
  description = "Versionamento nos buckets GeoDataLake."
  type        = bool
  default     = true
}

variable "storage_force_destroy" {
  description = "Permite destruir buckets com conteúdo em dev."
  type        = bool
  default     = true
}

variable "storage_lifecycle_retention_days" {
  description = "Dias de retenção para expiração no ciclo de vida em dev."
  type        = number
  default     = 180
}

# --- Configurações do Memorystore Redis (Sizing dev ~25%) ---
variable "memorystore_memory_size_gb" {
  description = "Capacidade de memória do Redis em GB para dev."
  type        = number
  default     = 2
}

variable "memorystore_tier" {
  description = "Tier do Redis para dev (BASIC)."
  type        = string
  default     = "BASIC"
}

# --- Configurações do BigQuery ---
variable "bigquery_delete_contents_on_destroy" {
  description = "Permite deletar tabelas ao destruir dataset em dev."
  type        = bool
  default     = true
}

# --- Configurações do GKE (Sizing dev ~25%) ---
variable "gke_regional_cluster" {
  description = "Define se o cluster será regional (prd) ou zonal (dev)."
  type        = bool
  default     = false
}

variable "gke_primary_node_machine_type" {
  description = "Tipo de máquina para os nós do GKE em dev."
  type        = string
  default     = "e2-standard-2"
}

variable "gke_primary_min_nodes" {
  description = "Mínimo de nós no pool principal GKE em dev."
  type        = number
  default     = 1
}

variable "gke_primary_max_nodes" {
  description = "Máximo de nós no pool principal GKE em dev."
  type        = number
  default     = 3
}

# --- Configurações do Compute VM Workers e Vertex AI Workbench ---
variable "compute_machine_type" {
  description = "Tipo de máquina para workers de fotogrametria em dev."
  type        = string
  default     = "n1-standard-4"
}

variable "compute_gpu_count" {
  description = "Quantidade de GPUs NVIDIA T4 por worker."
  type        = number
  default     = 1
}

variable "compute_target_size" {
  description = "Tamanho inicial do MIG de workers em dev (0 para escala sob demanda)."
  type        = number
  default     = 0
}

variable "enable_workbench" {
  description = "Habilita Vertex AI Workbench exclusivo para dev."
  type        = bool
  default     = true
}

variable "workbench_machine_type" {
  description = "Tipo de máquina da instância Vertex AI Workbench."
  type        = string
  default     = "e2-standard-4"
}

# --- Configurações do Cloud Composer 3 ---
variable "composer_environment_size" {
  description = "Porte do Cloud Composer 3 para dev."
  type        = string
  default     = "ENVIRONMENT_SIZE_SMALL"
}

# --- Configurações do Cloud Run ---
variable "cloud_run_min_instances" {
  description = "Mínimo de instâncias ativas do Cloud Run em dev."
  type        = number
  default     = 0
}

variable "cloud_run_max_instances" {
  description = "Máximo de instâncias para autoscaling do Cloud Run em dev."
  type        = number
  default     = 2
}

# --- Configurações do Cloud Spanner (Opcional) ---
variable "spanner_processing_units" {
  description = "Processing Units do Spanner em dev (100 PUs)."
  type        = number
  default     = 100
}

variable "spanner_deletion_protection" {
  description = "Proteção de deleção do Spanner em dev."
  type        = bool
  default     = false
}

# --- Configurações do Looker Core (Opcional) ---
variable "looker_platform_edition" {
  description = "Edição do Looker Core."
  type        = string
  default     = "LOOKER_CORE_STANDARD"
}
