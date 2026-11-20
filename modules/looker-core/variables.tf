variable "project_id" {
  description = "GCP Project ID onde a instância Looker Core será provisionada."
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
  description = "Região GCP para a instância Looker."
  type        = string
  default     = "southamerica-east1"
}

variable "platform_edition" {
  description = "Edição da plataforma Looker: LOOKER_CORE_STANDARD, LOOKER_CORE_ENTERPRISE, LOOKER_CORE_EMBED_ANNUAL."
  type        = string
  default     = "LOOKER_CORE_STANDARD"
}

variable "private_ip_enabled" {
  description = "Habilita acesso exclusivo via IP Privado na VPC (sem IP público)."
  type        = bool
  default     = true
}

variable "consumer_network" {
  description = "ID ou self-link da VPC conectada ao Looker Core via rede privada."
  type        = string
  default     = null
}

variable "reserved_range" {
  description = "Faixa de IP reservada para conexão privada do Looker Core."
  type        = string
  default     = null
}

variable "oauth_client_id" {
  description = "OAuth Client ID para autenticação Looker Core."
  type        = string
  default     = "dummy-client-id"
}

variable "oauth_client_secret" {
  description = "OAuth Client Secret para autenticação Looker Core."
  type        = string
  default     = "dummy-client-secret"
}

variable "common_labels" {
  description = "Mapa de labels obrigatórias conforme code_guidance.md (environment, project, owner, managed_by)."
  type        = map(string)
}

