variable "project_id" {
  description = "GCP Project ID onde os tópicos e subscriptions do Pub/Sub serão criados."
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

variable "common_labels" {
  description = "Mapa de labels obrigatórias conforme code_guidance.md (environment, project, owner, managed_by)."
  type        = map(string)
}

variable "kms_key_name" {
  description = "ID da CryptoKey KMS para criptografia via CMEK."
  type        = string
  default     = null
}

variable "topics" {
  description = "Lista de nomes de tópicos Pub/Sub a serem criados com suas respectivas Dead-Letter Queues (DLQ)."
  type        = list(string)
  default     = ["upload-events", "processing-events"]
}

variable "ack_deadline_seconds" {
  description = "Tempo em segundos para confirmação (ack) de recebimento das mensagens nas subscriptions."
  type        = number
  default     = 60
}

variable "max_delivery_attempts" {
  description = "Quantidade máxima de tentativas de entrega antes de redirecionar para a Dead-Letter Queue (DLQ)."
  type        = number
  default     = 5
}

variable "message_retention_duration" {
  description = "Duração de retenção das mensagens não confirmadas (ex: 604800s = 7 dias)."
  type        = string
  default     = "604800s"
}

