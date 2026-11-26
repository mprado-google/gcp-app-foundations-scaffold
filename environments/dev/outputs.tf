# Outputs do módulo project-services
output "enabled_services" {
  description = "Lista de serviços e APIs habilitados no projeto de desenvolvimento."
  value       = var.enable_project_services ? module.project_services[0].enabled_services : []
}

# Outputs do módulo networking
output "network_id" {
  description = "ID da VPC privada de desenvolvimento."
  value       = var.enable_networking ? module.networking[0].network_id : null
}

output "network_name" {
  description = "Nome da VPC privada de desenvolvimento."
  value       = var.enable_networking ? module.networking[0].network_name : null
}

output "network_self_link" {
  description = "Self-link da VPC privada."
  value       = var.enable_networking ? module.networking[0].network_self_link : null
}

output "subnets" {
  description = "Mapa detalhado das sub-redes privadas criadas."
  value       = var.enable_networking ? module.networking[0].subnets : {}
}

output "router_name" {
  description = "Nome do Cloud Router provisionado."
  value       = var.enable_networking ? module.networking[0].router_name : null
}

output "nat_name" {
  description = "Nome do Cloud NAT provisionado para saída segura."
  value       = var.enable_networking ? module.networking[0].nat_name : null
}

output "psa_range_name" {
  description = "Nome da faixa de IP reservada para Private Service Access."
  value       = var.enable_networking ? module.networking[0].psa_range_name : null
}

output "psa_connection_id" {
  description = "ID da conexão de peering do Private Service Access."
  value       = var.enable_networking ? module.networking[0].psa_connection_id : null
}

output "cloud_armor_policy_id" {
  description = "ID da política Cloud Armor (WAF) provisionada."
  value       = var.enable_networking ? module.networking[0].cloud_armor_policy_id : null
}

# Outputs do módulo security-iam
output "service_accounts" {
  description = "Mapa de emails das Service Accounts dedicadas provisionadas."
  value       = var.enable_security_iam ? module.security_iam[0].sa_emails : {}
}

output "kms_keyring_id" {
  description = "ID do KeyRing Cloud KMS para CMEK."
  value       = var.enable_security_iam ? module.security_iam[0].keyring_id : null
}

output "storage_crypto_key_id" {
  description = "ID da CryptoKey KMS para Cloud Storage."
  value       = var.enable_security_iam ? module.security_iam[0].storage_crypto_key_id : null
}

output "sql_crypto_key_id" {
  description = "ID da CryptoKey KMS para Cloud SQL."
  value       = var.enable_security_iam ? module.security_iam[0].sql_crypto_key_id : null
}

# Outputs do módulo storage-geodatalake
output "geodatalake_buckets" {
  description = "Mapa de buckets criados no GeoDataLake."
  value       = var.enable_storage_geodatalake ? module.storage_geodatalake[0].buckets : {}
}

output "bronze_bucket_name" {
  description = "Nome do bucket Bronze (RAW)."
  value       = var.enable_storage_geodatalake ? module.storage_geodatalake[0].bronze_bucket_name : null
}

output "silver_bucket_name" {
  description = "Nome do bucket Silver (Trusted COGs)."
  value       = var.enable_storage_geodatalake ? module.storage_geodatalake[0].silver_bucket_name : null
}

output "gold_bucket_name" {
  description = "Nome do bucket Gold (Refined)."
  value       = var.enable_storage_geodatalake ? module.storage_geodatalake[0].gold_bucket_name : null
}

output "gee_publication_bucket_name" {
  description = "Nome do bucket de publicação no Google Earth Engine (us-central1)."
  value       = var.enable_storage_geodatalake ? module.storage_geodatalake[0].gee_publication_bucket_name : null
}

# Outputs do módulo cloud-sql
output "cloud_sql_instance_name" {
  description = "Nome da instância Cloud SQL PostgreSQL."
  value       = var.enable_cloud_sql && var.enable_networking ? module.cloud_sql[0].instance_name : null
}

output "cloud_sql_connection_name" {
  description = "Connection name para Cloud SQL Auth Proxy."
  value       = var.enable_cloud_sql && var.enable_networking ? module.cloud_sql[0].instance_connection_name : null
}

output "cloud_sql_private_ip" {
  description = "IP privado da instância Cloud SQL na VPC."
  value       = var.enable_cloud_sql && var.enable_networking ? module.cloud_sql[0].private_ip_address : null
}

output "cloud_sql_databases" {
  description = "Bancos de dados criados na instância Cloud SQL."
  value       = var.enable_cloud_sql && var.enable_networking ? module.cloud_sql[0].database_names : []
}

output "cloud_sql_credentials_secret_id" {
  description = "ID do segredo no Secret Manager com as credenciais do Cloud SQL."
  value       = var.enable_cloud_sql && var.enable_networking ? module.cloud_sql[0].credentials_secret_id : null
}

# Outputs do módulo memorystore
output "redis_host" {
  description = "Endereço IP Privado para conexão ao Memorystore Redis."
  value       = var.enable_memorystore && var.enable_networking ? module.memorystore[0].host : null
}

output "redis_port" {
  description = "Porta do Memorystore Redis."
  value       = var.enable_memorystore && var.enable_networking ? module.memorystore[0].port : null
}

# Outputs do módulo bigquery
output "bigquery_gold_analytics_dataset_id" {
  description = "ID do dataset BigQuery Gold Analytics."
  value       = var.enable_bigquery ? module.bigquery[0].gold_analytics_dataset_id : null
}

output "bigquery_gis_census_dataset_id" {
  description = "ID do dataset BigQuery GIS Census."
  value       = var.enable_bigquery ? module.bigquery[0].gis_census_dataset_id : null
}

# Outputs do módulo gke
output "gke_cluster_name" {
  description = "Nome do cluster GKE privado."
  value       = var.enable_gke && var.enable_networking && var.enable_security_iam ? module.gke[0].cluster_name : null
}

output "gke_cluster_endpoint" {
  description = "Endpoint do plano de controle do GKE."
  value       = var.enable_gke && var.enable_networking && var.enable_security_iam ? module.gke[0].cluster_endpoint : null
}

# Outputs do módulo compute-vm
output "compute_instance_group_manager_id" {
  description = "ID do Managed Instance Group (MIG) de workers GPU."
  value       = var.enable_compute_vm && var.enable_networking && var.enable_security_iam ? module.compute_vm[0].instance_group_manager_id : null
}

output "workbench_instance_id" {
  description = "ID da instância do Vertex AI Workbench (disponível em dev)."
  value       = var.enable_compute_vm && var.enable_networking && var.enable_security_iam ? module.compute_vm[0].workbench_instance_id : null
}

# Outputs do módulo load-balancer
output "lb_ip_address" {
  description = "IP público estático do Global HTTPS Load Balancer."
  value       = var.enable_load_balancer && var.enable_networking ? module.load_balancer[0].lb_ip_address : null
}

output "lb_ip_name" {
  description = "Nome do recurso de IP estático global do Load Balancer."
  value       = var.enable_load_balancer && var.enable_networking ? module.load_balancer[0].lb_ip_name : null
}

output "lb_backend_service_id" {
  description = "ID do Backend Service do Load Balancer (com Cloud Armor e Cloud CDN associados)."
  value       = var.enable_load_balancer && var.enable_networking ? module.load_balancer[0].backend_service_id : null
}

output "lb_https_forwarding_rule_name" {
  description = "Nome da Global Forwarding Rule HTTPS do Load Balancer."
  value       = var.enable_load_balancer && var.enable_networking ? module.load_balancer[0].https_forwarding_rule_name : null
}

# Outputs do módulo vertex-ai
output "vertex_artifacts_bucket_name" {
  description = "Nome do bucket GCS de artefatos de treinamento Vertex AI (us-central1)."
  value       = var.enable_vertex_ai && var.enable_networking && var.enable_security_iam ? module.vertex_ai[0].vertex_artifacts_bucket_name : null
}

output "vertex_dataset_id" {
  description = "ID do Vertex AI Dataset de imagens aéreas para treinamento."
  value       = var.enable_vertex_ai && var.enable_networking && var.enable_security_iam ? module.vertex_ai[0].vertex_dataset_id : null
}

output "vertex_tensorboard_id" {
  description = "ID do Vertex AI Tensorboard para rastreamento de experimentos."
  value       = var.enable_vertex_ai && var.enable_networking && var.enable_security_iam ? module.vertex_ai[0].tensorboard_id : null
}

output "vertex_workbench_instance_id" {
  description = "ID da instância Vertex AI Workbench do módulo vertex-ai (dev-only)."
  value       = var.enable_vertex_ai && var.enable_networking && var.enable_security_iam ? module.vertex_ai[0].workbench_instance_id : null
}

output "vertex_workbench_proxy_uri" {
  description = "URI de acesso ao Vertex AI Workbench via proxy gerenciado."
  value       = var.enable_vertex_ai && var.enable_networking && var.enable_security_iam ? module.vertex_ai[0].workbench_proxy_uri : null
}
