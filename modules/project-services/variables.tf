variable "project_id" {
  description = "GCP Project ID onde os serviços e APIs serão ativados."
  type        = string
}

variable "services" {
  description = "Lista de APIs do Google Cloud a serem ativadas no projeto."
  type        = list(string)
  default = [
    "compute.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "cloudkms.googleapis.com",
    "secretmanager.googleapis.com",
    "iam.googleapis.com",
    "iap.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
}

variable "disable_on_destroy" {
  description = "Define se os serviços serão desativados quando o recurso for destruído."
  type        = bool
  default     = false
}

variable "disable_dependent_services" {
  description = "Define se serviços dependentes serão desativados ao desativar uma API."
  type        = bool
  default     = false
}

