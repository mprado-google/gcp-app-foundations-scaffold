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
  description = "Região principal GCP (southamerica-east1) — usada para Workbench."
  type        = string
  default     = "southamerica-east1"
}

variable "training_region" {
  description = "Região para recursos de treinamento Vertex AI com GPU A100 (obrigatoriamente us-central1 conforme spec.md)."
  type        = string
  default     = "us-central1"
}

variable "common_labels" {
  description = "Labels obrigatórias conforme code_guidance.md."
  type        = map(string)
  default     = {}
}

variable "enable_vertex_ai" {
  description = "Feature flag para ativação do módulo vertex-ai."
  type        = bool
  default     = true
}

variable "enable_workbench" {
  description = "Habilita Vertex AI Workbench (exclusivo para dev conforme spec.md)."
  type        = bool
  default     = false
}

variable "service_account_email" {
  description = "Email da Service Account para Vertex AI (treinamento e Workbench)."
  type        = string
  default     = null
}

variable "network_id" {
  description = "ID da VPC para o Workbench (sem IP público)."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "ID da subnet para o Workbench."
  type        = string
  default     = null
}

variable "workbench_zone" {
  description = "Zona do Vertex AI Workbench (southamerica-east1-a para dev)."
  type        = string
  default     = "southamerica-east1-a"
}

variable "workbench_machine_type" {
  description = "Tipo de máquina do Vertex AI Workbench."
  type        = string
  default     = "e2-standard-4"
}

variable "kms_key_name" {
  description = "Nome da chave KMS para CMEK no bucket de artefatos (obrigatório em prd)."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "Permite destruir o bucket de artefatos com conteúdo (true em dev, false em prd)."
  type        = bool
  default     = true
}

variable "artifact_nearline_days" {
  description = "Dias para mover artefatos de treinamento para Nearline."
  type        = number
  default     = 90
}

variable "artifact_retention_days" {
  description = "Dias de retenção total dos artefatos antes de expirar."
  type        = number
  default     = 365
}
