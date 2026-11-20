variable "project_id" {
  description = "GCP Project ID onde a instância Cloud SQL será criada."
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
  description = "Região GCP onde a instância Cloud SQL será provisionada."
  type        = string
  default     = "southamerica-east1"
}

variable "database_version" {
  description = "Versão do banco de dados PostgreSQL."
  type        = string
  default     = "POSTGRES_16"
}

variable "tier" {
  description = "Tipo de máquina da instância Cloud SQL (ex: db-custom-2-7680 em dev, db-custom-4-16384 em hml, db-custom-16-65536 em prd)."
  type        = string
  default     = "db-custom-2-7680"
}

variable "disk_size_gb" {
  description = "Tamanho do disco SSD em GiB (1000 em prd, 500 em hml, 250 em dev)."
  type        = number
  default     = 250
}

variable "disk_type" {
  description = "Tipo de disco para a instância."
  type        = string
  default     = "PD_SSD"
}

variable "disk_autoresize" {
  description = "Habilita aumento automático do tamanho do disco quando atingir limite de capacidade."
  type        = bool
  default     = true
}

variable "availability_type" {
  description = "Tipo de disponibilidade: REGIONAL (alta disponibilidade com failover para prd e hml) ou ZONAL (single-zone para dev)."
  type        = string
  default     = "ZONAL"

  validation {
    condition     = contains(["REGIONAL", "ZONAL"], var.availability_type)
    error_message = "O tipo de disponibilidade deve ser 'REGIONAL' ou 'ZONAL'."
  }
}

variable "deletion_protection" {
  description = "Proteção contra deleção acidental da instância (obrigatório true em prd)."
  type        = bool
  default     = false
}

variable "network_id" {
  description = "ID da VPC privada onde a instância será conectada via Private Service Access."
  type        = string
}

variable "allocated_ip_range" {
  description = "Nome da faixa de IP reservada para Private Service Access na VPC."
  type        = string
  default     = null
}

variable "kms_key_name" {
  description = "ID completo da CryptoKey KMS para criptografia em repouso via CMEK (obrigatório em prd)."
  type        = string
  default     = null
}

variable "common_labels" {
  description = "Mapa de labels obrigatórias conforme code_guidance.md (environment, project, owner, managed_by)."
  type        = map(string)
}

variable "backup_retention_days" {
  description = "Número de dias para retenção de backups (30 em prd, 7 em dev/hml)."
  type        = number
  default     = 7
}

variable "databases" {
  description = "Lista de bancos de dados a serem criados na instância."
  type        = list(string)
  default     = ["adapar_geodb", "pgstac"]
}

variable "app_username" {
  description = "Nome do usuário da aplicação no PostgreSQL."
  type        = string
  default     = "adapar_app"
}

variable "database_flags" {
  description = "Lista de database flags customizadas para PostgreSQL/PostGIS."
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

