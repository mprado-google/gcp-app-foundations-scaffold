terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

locals {
  name_prefix = "${var.company_prefix}-${var.project_name}-${var.environment}"

  services = {
    web_app = {
      name        = "${local.name_prefix}-run-web-app"
      image       = "us-docker.pkg.dev/cloudrun/container/hello"
      cpu         = "1"
      memory      = "512Mi"
      description = "Interface web da plataforma do Censo de Rebanhos ADAPAR"
    }
    business_api = {
      name        = "${local.name_prefix}-run-business-api"
      image       = "us-docker.pkg.dev/cloudrun/container/hello"
      cpu         = "2"
      memory      = "1Gi"
      description = "API REST de regras de negócio, auditoria e cadastros de produtores"
    }
    quick_count = {
      name        = "${local.name_prefix}-run-quick-count"
      image       = "us-docker.pkg.dev/cloudrun/container/hello"
      cpu         = "2"
      memory      = "2Gi"
      description = "Serviço serverless de contagem preliminar e inferência rápida"
    }
    conversational_agent = {
      name        = "${local.name_prefix}-run-conversational-agent"
      image       = "us-docker.pkg.dev/cloudrun/container/hello"
      cpu         = "2"
      memory      = "2Gi"
      description = "Agente conversacional baseado em LLM/GenAI para suporte a fiscais e produtores"
    }
  }
}

resource "google_cloud_run_v2_service" "services" {
  for_each    = local.services
  project     = var.project_id
  name        = each.value.name
  location    = var.region
  description = each.value.description
  ingress     = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    service_account = var.service_account_email

    scaling {
      min_instance_count = var.min_instance_count
      max_instance_count = var.max_instance_count
    }

    dynamic "vpc_access" {
      for_each = var.subnet_id != null ? [1] : []
      content {
        network_interfaces {
          network    = var.network_id
          subnetwork = var.subnet_id
        }
        egress = "ALL_TRAFFIC"
      }
    }

    containers {
      image = each.value.image

      resources {
        limits = {
          cpu    = each.value.cpu
          memory = each.value.memory
        }
      }
    }

    labels = var.common_labels
  }

  labels = var.common_labels
}

