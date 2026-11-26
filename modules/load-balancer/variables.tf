variable "project_id" {
  description = "ID do projeto GCP."
  type        = string
}

variable "environment" {
  description = "Identificador do ambiente (dev, hml, prd)."
  type        = string
}

variable "company_prefix" {
  description = "Prefixo da organização para recursos."
  type        = string
  default     = "seia"
}

variable "project_name" {
  description = "Nome do projeto para recursos."
  type        = string
  default     = "adapar"
}

variable "region" {
  description = "Região principal GCP (usada para name_prefix apenas; LB é global)."
  type        = string
  default     = "southamerica-east1"
}

variable "common_labels" {
  description = "Labels obrigatórias conforme code_guidance.md."
  type        = map(string)
  default     = {}
}

variable "enable_load_balancer" {
  description = "Feature flag para ativação do Load Balancer."
  type        = bool
  default     = true
}

variable "domains" {
  description = "Lista de domínios para o certificado SSL gerenciado (ex: ['app.seia.adapar.gov.br'])."
  type        = list(string)
  default     = []
}

variable "cloud_armor_policy_id" {
  description = "ID da política Cloud Armor (WAF) a ser associada ao backend service. Vem do output do módulo networking."
  type        = string
  default     = null
}

variable "enable_cdn" {
  description = "Habilita Cloud CDN no backend service para caching de assets estáticos e tiles."
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "Path do health check HTTPS para os backends."
  type        = string
  default     = "/healthz"
}

variable "backends" {
  description = "Lista de backends (NEGs de Cloud Run, GKE, etc.) a serem associados ao backend service."
  type = list(object({
    group           = string
    balancing_mode  = optional(string, "UTILIZATION")
    capacity_scaler = optional(number, 1.0)
  }))
  default = []
}
