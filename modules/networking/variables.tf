variable "project_id" {
  description = "GCP Project ID onde a infraestrutura de rede será criada."
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
  description = "Região GCP principal da infraestrutura de rede."
  type        = string
  default     = "southamerica-east1"
}

variable "common_labels" {
  description = "Mapa de labels obrigatórias conforme code_guidance.md (environment, project, owner, managed_by)."
  type        = map(string)
}

variable "create_vpc" {
  description = "Define se a VPC será criada pelo módulo ou se utilizará uma VPC existente (ex: Shared VPC)."
  type        = bool
  default     = true
}

variable "existing_network_id" {
  description = "ID da VPC existente caso create_vpc seja false (para Shared VPC)."
  type        = string
  default     = null
}

variable "existing_network_name" {
  description = "Nome da VPC existente caso create_vpc seja false (para Shared VPC)."
  type        = string
  default     = null
}

variable "existing_network_self_link" {
  description = "Self-link da VPC existente caso create_vpc seja false."
  type        = string
  default     = null
}

variable "subnets" {
  description = "Lista de sub-redes privadas a serem criadas."
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
  description = "Define se a reserva de IP e conexão Private Service Access (para Cloud SQL/Memorystore) será criada."
  type        = bool
  default     = true
}

variable "psa_prefix_length" {
  description = "Tamanho do prefixo CIDR reservado para Private Service Access (/16 a /24)."
  type        = number
  default     = 16
}

variable "enable_cloud_armor" {
  description = "Define se a política WAF do Cloud Armor será provisionada."
  type        = bool
  default     = true
}

variable "cloud_armor_rate_limit_count" {
  description = "Limite de requisições por intervalo de 60 segundos na política de rate limiting do Cloud Armor."
  type        = number
  default     = 500
}

