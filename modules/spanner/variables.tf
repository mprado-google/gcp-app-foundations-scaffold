variable "project_id" {
  description = "GCP Project ID onde a instância Cloud Spanner será criada."
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

variable "config" {
  description = "Configuração regional do Spanner (ex: regional-southamerica-east1)."
  type        = string
  default     = "regional-southamerica-east1"
}

variable "processing_units" {
  description = "Unidades de processamento Spanner (100 a 1000 PUs, ou múltiplos de 1000 para nós)."
  type        = number
  default     = 100
}

variable "database_name" {
  description = "Nome do banco de dados Spanner para o catálogo ACG."
  type        = string
  default     = "acg_catalog"
}

variable "deletion_protection" {
  description = "Proteção contra deleção do banco de dados Spanner."
  type        = bool
  default     = false
}

variable "common_labels" {
  description = "Mapa de labels obrigatórias conforme code_guidance.md (environment, project, owner, managed_by)."
  type        = map(string)
}

