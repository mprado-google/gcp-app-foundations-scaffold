variable "project_id" {
  description = "GCP Project ID onde o cluster GKE privado será provisionado."
  type        = string
}

variable "environment" {
  description = "Ambiente de deploy (dev, hml, prd)."
  type        = string

  validation {
    condition     = contains(["dev", "hml", "prd"], var.environment)
    error_message = "O ambiente deve ser 'dev', 'hml' ou 'prd'."
  }
}

variable "company_prefix" {
  description = "Prefixo da organização para padronização de nomenclatura."
  type        = string
  default     = "seia"
}

variable "project_name" {
  description = "Nome do projeto para padronização de nomenclatura."
  type        = string
  default     = "adapar"
}

variable "region" {
  description = "Região GCP do cluster GKE."
  type        = string
  default     = "southamerica-east1"
}

variable "network_id" {
  description = "ID ou self-link da VPC do GKE."
  type        = string
}

variable "subnet_id" {
  description = "ID ou self-link da sub-rede do GKE."
  type        = string
}

variable "pods_secondary_range_name" {
  description = "Nome da faixa secundária de IPs para Pods."
  type        = string
  default     = "pods"
}

variable "services_secondary_range_name" {
  description = "Nome da faixa secundária de IPs para Services."
  type        = string
  default     = "services"
}

variable "master_ipv4_cidr_block" {
  description = "Bloco CIDR /28 reservado para o plano de controle (master) do cluster privado."
  type        = string
  default     = "172.16.0.0/28"
}

variable "service_account_email" {
  description = "Email da Service Account dedicada aos nós do GKE."
  type        = string
}

variable "common_labels" {
  description = "Mapa de labels obrigatórias conforme code_guidance.md (environment, project, owner, managed_by)."
  type        = map(string)
}

variable "regional_cluster" {
  description = "Define se o cluster será regional (HA em prd) ou zonal (dev ~25%)."
  type        = bool
  default     = false
}

variable "node_pools" {
  description = "Lista de node pools adicionais configuráveis para o cluster GKE."
  type = list(object({
    name           = string
    machine_type   = string
    min_node_count = number
    max_node_count = number
    disk_size_gb   = optional(number, 100)
    disk_type      = optional(string, "pd-standard")
    auto_repair    = optional(bool, true)
    auto_upgrade   = optional(bool, true)
    labels         = optional(map(string), {})
  }))
  default = []
}

variable "primary_node_machine_type" {
  description = "Tipo de máquina para o node pool padrão (e2-standard-2 em dev ~25%, e2-standard-4 em prd)."
  type        = string
  default     = "e2-standard-2"
}

variable "primary_min_nodes" {
  description = "Quantidade mínima de nós no node pool principal."
  type        = number
  default     = 1
}

variable "primary_max_nodes" {
  description = "Quantidade máxima de nós no node pool principal."
  type        = number
  default     = 3
}

variable "enable_backup_for_gke" {
  description = "Habilita o addon Backup for GKE (obrigatório em prd conforme spec.md)."
  type        = bool
  default     = false
}

