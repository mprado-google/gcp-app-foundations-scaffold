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
}

# 1. Instance Template para Workers GPU (Fotogrametria / ODM / PyTorch)
resource "google_compute_instance_template" "gpu_worker_template" {
  name_prefix  = "${local.name_prefix}-gpu-worker-"
  project      = var.project_id
  region       = var.region
  machine_type = var.machine_type

  # Acelerador GPU NVIDIA T4 (opcional caso gpu_count > 0)
  dynamic "guest_accelerator" {
    for_each = var.gpu_count > 0 ? [1] : []
    content {
      type  = "nvidia-tesla-t4"
      count = var.gpu_count
    }
  }

  scheduling {
    on_host_maintenance = "TERMINATE"
    automatic_restart   = true
  }

  # Disco de boot
  disk {
    source_image = "cos-cloud/cos-stable"
    auto_delete  = true
    boot         = true
    disk_size_gb = 150
    disk_type    = "pd-ssd"

    dynamic "disk_encryption_key" {
      for_each = var.kms_key_name != null && var.kms_key_name != "" ? [var.kms_key_name] : []
      content {
        kms_key_self_link = disk_encryption_key.value
      }
    }
  }

  # SEGURANÇA ESTRITA: Sem IP externo (sem bloco access_config)
  network_interface {
    subnetwork = var.subnet_id
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  labels = var.common_labels

  lifecycle {
    create_before_destroy = true
  }
}

# 2. Managed Instance Group Zonal (Escalabilidade de 0 a N conforme fila Pub/Sub)
resource "google_compute_instance_group_manager" "gpu_workers" {
  name               = "${local.name_prefix}-igm-gpu-workers"
  project            = var.project_id
  zone               = var.zone
  base_instance_name = "${local.name_prefix}-worker"
  target_size        = var.target_size

  version {
    instance_template = google_compute_instance_template.gpu_worker_template.id
  }
}

# 3. Vertex AI Workbench Instance (Exclusivo para Dev conforme spec.md)
resource "google_workbench_instance" "workbench" {
  count    = var.enable_workbench && var.environment == "dev" ? 1 : 0
  name     = "${local.name_prefix}-workbench"
  location = var.zone
  project  = var.project_id

  gce_setup {
    machine_type      = var.workbench_machine_type
    disable_public_ip = true

    shielded_instance_config {
      enable_secure_boot          = true
      enable_vtpm                 = true
      enable_integrity_monitoring = true
    } # Sem IP público conforme code_guidance.md

    network_interfaces {
      network  = var.network_id
      subnet   = var.subnet_id
      nic_type = "VIRTIO_NET"
    }

    service_accounts {
      email = var.service_account_email
    }

    boot_disk {
      disk_size_gb = 150
      disk_type    = "PD_SSD"
    }
  }

  labels = var.common_labels
}

