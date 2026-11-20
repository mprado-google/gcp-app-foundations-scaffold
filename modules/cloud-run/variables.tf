variable "project_id" {
  description = "GCP Project ID onde os serviços do Cloud Run serão implantados."
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
  description = "Região GCP dos serviços Cloud Run."
  type        = string
  default     = "southamerica-east1"
}

variable "service_account_email" {
  description = "Email da Service Account dedicada para execução dos serviços serverless."
  type        = string
}

variable "network_id" {
  description = "ID ou self-link da VPC para saída privada (Direct VPC Egress)."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "ID ou self-link da sub-rede para Direct VPC Egress."
  type        = string
  default     = null
}

variable "common_labels" {
  description = "Mapa de labels obrigatórias conforme code_guidance.md (environment, project, owner, managed_by)."
  type        = map(string)
}

variable "min_instance_count" {
  description = "Número mínimo de instâncias ativas (0 em dev/hml, 1+ em prd)."
  type        = number
  default     = 0
}

variable "max_instance_count" {
  description = "Número máximo de instâncias para autoscaling."
  type        = number
  default     = 5
}

