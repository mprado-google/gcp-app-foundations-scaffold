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

# 1. Tópicos e Subscriptions de Dead-Letter Queue (DLQ)
resource "google_pubsub_topic" "dlq_topics" {
  for_each     = toset(var.topics)
  project      = var.project_id
  name         = "${local.name_prefix}-top-${each.value}-dlq"
  kms_key_name = var.kms_key_name
  labels       = var.common_labels
}

resource "google_pubsub_subscription" "dlq_subscriptions" {
  for_each                   = toset(var.topics)
  project                    = var.project_id
  name                       = "${local.name_prefix}-sub-${each.value}-dlq"
  topic                      = google_pubsub_topic.dlq_topics[each.value].name
  ack_deadline_seconds       = var.ack_deadline_seconds
  message_retention_duration = var.message_retention_duration
  labels                     = var.common_labels
}

# 2. Tópicos Principais
resource "google_pubsub_topic" "topics" {
  for_each     = toset(var.topics)
  project      = var.project_id
  name         = "${local.name_prefix}-top-${each.value}"
  kms_key_name = var.kms_key_name
  labels       = var.common_labels
}

# 3. Subscriptions Principais com Política de Dead-Letter
resource "google_pubsub_subscription" "subscriptions" {
  for_each                   = toset(var.topics)
  project                    = var.project_id
  name                       = "${local.name_prefix}-sub-${each.value}"
  topic                      = google_pubsub_topic.topics[each.value].name
  ack_deadline_seconds       = var.ack_deadline_seconds
  message_retention_duration = var.message_retention_duration

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.dlq_topics[each.value].id
    max_delivery_attempts = var.max_delivery_attempts
  }

  labels = var.common_labels
}

