variable "project_id" {
  description = "GCP Project ID onde os recursos de segurança e IAM serão provisionados."
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
  description = "Região GCP principal para o Cloud KMS."
  type        = string
  default     = "southamerica-east1"
}

variable "common_labels" {
  description = "Mapa de labels obrigatórias conforme code_guidance.md (environment, project, owner, managed_by)."
  type        = map(string)
}

variable "enable_cmek" {
  description = "Define se o KeyRing e as CryptoKeys do Cloud KMS para CMEK serão provisionados."
  type        = bool
  default     = true
}

variable "kms_rotation_period" {
  description = "Período de rotação automática das chaves criptográficas KMS (ex: 7776000s = 90 dias)."
  type        = string
  default     = "7776000s" # 90 dias
}

variable "iap_tunnel_members" {
  description = "Lista de membros (usuários ou grupos) autorizados a acessar instâncias privadas via IAP Tunnel."
  type        = list(string)
  default     = []
}

variable "iap_web_members" {
  description = "Lista de membros autorizados a acessar aplicações web protegidas pelo IAP."
  type        = list(string)
  default     = []
}

variable "create_secret_manager_secrets" {
  description = "Define se os segredos base no Secret Manager serão provisionados."
  type        = bool
  default     = true
}

