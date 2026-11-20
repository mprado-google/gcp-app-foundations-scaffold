# Módulo Pub/Sub (`modules/pubsub`)

Módulo que provisiona a mensageria assíncrona orientada a eventos para uploads de imagens e gatilhos de processamento, integrando Dead-Letter Queues (DLQ) para resiliência e tratamento de falhas.

## Recursos Gerenciados

- `google_pubsub_topic`: Tópicos de eventos (`upload-events`, `processing-events`) com suporte a CMEK.
- `google_pubsub_subscription`: Subscriptions com política de reentrega e `dead_letter_policy`.
- `google_pubsub_topic` (DLQ) & `google_pubsub_subscription` (DLQ): Filas de mensagens mortas para auditoria.

## Inputs

| Nome | Descrição | Tipo | Padrão | Obrigatório |
|------|-----------|------|--------|:-----------:|
| `project_id` | GCP Project ID | `string` | n/a | Sim |
| `environment` | Ambiente (`dev`, `hml`, `prd`) | `string` | n/a | Sim |
| `common_labels` | Mapa de labels obrigatórias | `map(string)` | n/a | Sim |
| `topics` | Lista de tópicos a provisionar | `list(string)` | `["upload-events", "processing-events"]` | Não |
| `ack_deadline_seconds` | Tempo de confirmação da mensagem | `number` | `60` | Não |
| `max_delivery_attempts` | Tentativas antes de enviar à DLQ | `number` | `5` | Não |
| `kms_key_name` | ID da chave CMEK | `string` | `null` | Não |

## Outputs

| Nome | Descrição |
|------|-----------|
| `topic_ids` | IDs dos tópicos provisionados |
| `subscription_ids` | IDs das subscriptions |
| `dlq_topic_ids` | IDs dos tópicos DLQ associados |
| `dlq_subscription_ids` | IDs das subscriptions DLQ associadas |

