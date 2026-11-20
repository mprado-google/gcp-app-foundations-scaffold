output "topic_ids" {
  description = "Mapa de IDs dos tópicos Pub/Sub principais."
  value       = { for k, v in google_pubsub_topic.topics : k => v.id }
}

output "topic_names" {
  description = "Mapa de nomes dos tópicos Pub/Sub principais."
  value       = { for k, v in google_pubsub_topic.topics : k => v.name }
}

output "subscription_ids" {
  description = "Mapa de IDs das subscriptions Pub/Sub principais."
  value       = { for k, v in google_pubsub_subscription.subscriptions : k => v.id }
}

output "dlq_topic_ids" {
  description = "Mapa de IDs dos tópicos Dead-Letter Queue (DLQ)."
  value       = { for k, v in google_pubsub_topic.dlq_topics : k => v.id }
}

output "dlq_subscription_ids" {
  description = "Mapa de IDs das subscriptions Dead-Letter Queue (DLQ)."
  value       = { for k, v in google_pubsub_subscription.dlq_subscriptions : k => v.id }
}

