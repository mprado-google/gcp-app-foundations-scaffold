variable "project_id" {
  description = "GCP Project ID onde os buckets do GeoDataLake serão criados."
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

variable "primary_region" {
  description = "Região principal dos buckets GeoDataLake (bronze, silver, gold)."
  type        = string
  default     = "southamerica-east1"
}

variable "gee_region" {
  description = "Região obrigatória para publicação no Google Earth Engine (ativos COG exigem bucket nos EUA)."
  type        = string
  default     = "us-central1"
}

variable "bucket_suffix" {
  description = "Sufixo opcional para garantir unicidade global de nomes de buckets GCS."
  type        = string
  default     = ""
}

variable "common_labels" {
  description = "Mapa de labels obrigatórias conforme code_guidance.md (environment, project, owner, managed_by)."
  type        = map(string)
}

variable "versioning_enabled" {
  description = "Define se o versionamento de objetos estará ativo nos buckets."
  type        = bool
  default     = true
}

variable "kms_key_name" {
  description = "ID da chave KMS (CMEK) na região principal para criptografia dos buckets bronze, silver e gold."
  type        = string
  default     = null
}

variable "gee_kms_key_name" {
  description = "ID da chave KMS (CMEK) em us-central1 para o bucket gee-publication (se aplicável)."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "Permite destruir buckets com conteúdo (recomendado false em prd)."
  type        = bool
  default     = false
}

variable "enable_lifecycle_rules" {
  description = "Define se regras de lifecycle de transição de classe e expiração serão aplicadas."
  type        = bool
  default     = true
}

variable "lifecycle_nearline_days" {
  description = "Número de dias para transição de Standard para Nearline (default 30)."
  type        = number
  default     = 30
}

variable "lifecycle_archive_days" {
  description = "Número de dias para transição de Nearline para Archive (default 365)."
  type        = number
  default     = 365
}

variable "lifecycle_retention_days" {
  description = "Número de dias para expiração definitiva de objetos no ciclo de vida (ex: 1825 dias = 5 anos em PRD). Defina 0 ou null para desativar."
  type        = number
  default     = 1825
}

variable "cors_allowed_origins" {
  description = "Lista de origens HTTP/HTTPS autorizadas para requisições CORS de visualização GIS/COG."
  type        = list(string)
  default     = ["*"]
}

