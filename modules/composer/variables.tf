variable "project_id" {
  description = "GCP Project ID onde o Cloud Composer 3 será provisionado."
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
  description = "Região GCP do Cloud Composer."
  type        = string
  default     = "southamerica-east1"
}

variable "service_account_email" {
  description = "Email da Service Account dedicada para execução das DAGs do Composer."
  type        = string
}

variable "common_labels" {
  description = "Mapa de labels obrigatórias conforme code_guidance.md (environment, project, owner, managed_by)."
  type        = map(string)
}

variable "environment_size" {
  description = "Tamanho do ambiente Cloud Composer 3: ENVIRONMENT_SIZE_SMALL, ENVIRONMENT_SIZE_MEDIUM, ENVIRONMENT_SIZE_LARGE."
  type        = string
  default     = "ENVIRONMENT_SIZE_SMALL"
}

variable "image_version" {
  description = "Versão da imagem do Cloud Composer / Airflow."
  type        = string
  default     = "composer-3-airflow-2"
}

