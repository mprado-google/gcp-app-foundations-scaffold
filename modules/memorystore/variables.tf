variable "project_id" {
  description = "GCP Project ID onde o Memorystore Redis será provisionado."
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
  description = "Região GCP do Memorystore Redis."
  type        = string
  default     = "southamerica-east1"
}

variable "network_id" {
  description = "ID ou self-link da VPC para conexão privada do Redis via Private Service Access."
  type        = string
}

variable "memory_size_gb" {
  description = "Capacidade de memória do Redis em GB (dev ~2 GB, hml ~5 GB, prd ~10 GB)."
  type        = number
  default     = 2
}

variable "tier" {
  description = "Camada do Redis: STANDARD_HA (com failover/réplica para hml e prd) ou BASIC (nó único para dev ~25%)."
  type        = string
  default     = "BASIC"
}

variable "redis_version" {
  description = "Versão da engine Redis."
  type        = string
  default     = "REDIS_7_0"
}

variable "auth_enabled" {
  description = "Habilita autenticação via AUTH string no Redis."
  type        = bool
  default     = true
}

variable "transit_encryption_mode" {
  description = "Modo de criptografia em trânsito (SERVER_AUTHENTICATION ou DISABLED)."
  type        = string
  default     = "SERVER_AUTHENTICATION"
}

variable "common_labels" {
  description = "Mapa de labels obrigatórias conforme code_guidance.md (environment, project, owner, managed_by)."
  type        = map(string)
}

