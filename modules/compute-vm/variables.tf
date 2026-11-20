variable "project_id" {
  description = "GCP Project ID onde os workers Compute Engine serão provisionados."
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
  description = "Região GCP dos workers Compute Engine."
  type        = string
  default     = "southamerica-east1"
}

variable "zone" {
  description = "Zona GCP com disponibilidade de GPUs NVIDIA T4."
  type        = string
  default     = "southamerica-east1-a"
}

variable "network_id" {
  description = "ID ou self-link da VPC para conexão de instâncias privadas."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "ID ou self-link da sub-rede privada onde os nós serão alocados (sem IP público)."
  type        = string
}

variable "service_account_email" {
  description = "Email da Service Account dedicada para os workers GPU e Workbench."
  type        = string
}

variable "common_labels" {
  description = "Mapa de labels obrigatórias conforme code_guidance.md (environment, project, owner, managed_by)."
  type        = map(string)
}

variable "machine_type" {
  description = "Tipo de máquina para os workers de fotogrametria."
  type        = string
  default     = "n1-standard-4"
}

variable "gpu_count" {
  description = "Quantidade de GPUs NVIDIA T4 por nó (0 para desativar GPU ou 1+ para ativar)."
  type        = number
  default     = 1
}

variable "kms_key_name" {
  description = "ID da CryptoKey KMS para CMEK dos discos dos workers."
  type        = string
  default     = null
}

variable "target_size" {
  description = "Tamanho inicial do Managed Instance Group (MIG). Em dev: 0 para economia de custos."
  type        = number
  default     = 0
}

# --- Vertex AI Workbench (Exclusivo para Dev) ---
variable "enable_workbench" {
  description = "Habilita a instância Vertex AI Workbench para experimentação interativa de modelos (exclusivo para ambiente dev conforme spec.md)."
  type        = bool
  default     = false
}

variable "workbench_machine_type" {
  description = "Tipo de máquina para a instância do Vertex AI Workbench."
  type        = string
  default     = "e2-standard-4"
}

