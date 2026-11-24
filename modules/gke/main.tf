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
  region_clean = replace(var.region, "-", "")
  cluster_name = "${var.company_prefix}-${var.project_name}-${var.environment}-gke-${local.region_clean}"
  location     = var.regional_cluster ? var.region : "${var.region}-a"
}

# 1. Cluster GKE Privado
resource "google_container_cluster" "primary" {
  deletion_protection = false
  name                     = local.cluster_name
  project                  = var.project_id
  location                 = local.location
  remove_default_node_pool = true
  initial_node_count       = 1

  node_config {
    shielded_instance_config {
      enable_secure_boot          = false
      enable_integrity_monitoring = true
    }
  }
  network                  = var.network_id
  subnetwork               = var.subnet_id

  # Configuração de IPs secundários para Pods e Services
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
  }

  # SEGURANÇA ESTRITA: Cluster Privado (Nós sem IP público)
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  # Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Addons
  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    gke_backup_agent_config {
      enabled = var.enable_backup_for_gke
    }
  }

  release_channel {
    channel = "REGULAR"
  }

  resource_labels = var.common_labels
}

# 2. Node Pool Principal
resource "google_container_node_pool" "primary_nodes" {
  name       = "default-pool"
  project    = var.project_id
  location   = local.location
  cluster    = google_container_cluster.primary.name
  node_count = var.primary_min_nodes

  autoscaling {
    min_node_count = var.primary_min_nodes
    max_node_count = var.primary_max_nodes
  }

  node_config {
    machine_type    = "e2-medium"
    disk_size_gb    = 100
    disk_type       = "pd-balanced"
    service_account = "default"
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
    ]
    shielded_instance_config {
      enable_secure_boot          = false
      enable_integrity_monitoring = true
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
