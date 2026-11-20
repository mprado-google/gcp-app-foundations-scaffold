variable "project_id" {
  description = "GCP Project ID onde os datasets do BigQuery serão provisionados."
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

variable "location" {
  description = "Localização geográfica dos datasets do BigQuery."
  type        = string
  default     = "southamerica-east1"
}

variable "common_labels" {
  description = "Mapa de labels obrigatórias conforme code_guidance.md (environment, project, owner, managed_by)."
  type        = map(string)
}

variable "delete_contents_on_destroy" {
  description = "Se verdadeiro, deleta tabelas ao destruir o dataset (recomendado false em prd)."
  type        = bool
  default     = false
}

variable "kms_key_name" {
  description = "ID da chave KMS (CMEK) para criptografia do BigQuery."
  type        = string
  default     = null
}

variable "authorized_service_accounts" {
  description = "Lista de emails de Service Accounts autorizadas como visualizadores/leitores nos datasets."
  type        = list(string)
  default     = []
}

