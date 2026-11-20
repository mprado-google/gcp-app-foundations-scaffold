# Especificação Arquitetural - Plataforma ADAPAR (Censo de Rebanhos - Módulo I)

## 1. Visão Geral e Ambientes
* **Projetos GCP Separados:** `dev`, `hml`, `prd`.
* **Região Principal:** `southamerica-east1` (São Paulo).
* **Exceções Obrigatórias em `us-central1`:**
  1. Bucket de publicação do Google Earth Engine (GEE) — ativos COG exigem bucket nos EUA.
  2. Recursos de treinamento Vertex AI (GPUs A100).
* **Regra de Capacidade (Sizing):**
  * `prd`: 100% da capacidade (HA regional completo, backup, deletion_protection).
  * `hml`: ~50% de PRD (mantém HA no Cloud SQL para testes de failover).
  * `dev`: ~25% de PRD (single-zone, tamanhos mínimos; único ambiente com Vertex AI Workbench).

## 2. Módulos e Recursos Requeridos (Pack 1 - Foundation & PaaS)
1. **Networking (`modules/networking`):** VPC (suporte a Shared VPC ou VPC dedicada via flag), subnets privadas, Cloud NAT, Private Service Access (Cloud SQL/Redis), Global HTTPS Load Balancer, Cloud Armor (WAF) e Cloud CDN.
2. **Security & IAM (`modules/security-iam`):** Service Accounts dedicadas por serviço, KMS (CMEK), Secret Manager e suporte a IAP.
3. **GeoDataLake (`modules/storage-geodatalake`):**
   * Buckets em `southamerica-east1`: `bronze` (RAW), `silver` (Trusted COGs), `gold` (Refined).
   * Bucket em `us-central1`: `gee-publication`.
   * Lifecycle em `prd`: Standard -> Nearline -> Archive com retenção de 5 anos.
4. **Cloud SQL (`modules/cloud-sql`):** PostgreSQL com PostGIS (dados de negócio + catálogo pgSTAC), Private IP, 1000 GiB SSD em PRD, HA em HOM e PRD.
5. **Memorystore (`modules/memorystore`):** Redis Standard tier (10 GB em PRD) para cache de tiles STAC.
6. **BigQuery (`modules/bigquery`):** Datasets da camada Gold e BigQuery GIS (autoscaling até 100 slots em PRD).
7. **GKE (`modules/gke`):** Cluster regional privado (para hospedar eoAPI: stac-fastapi, titiler, tipg) com HPA e Backup for GKE em PRD.
8. **Compute VM (`modules/compute-vm`):** Workers GPU (NVIDIA T4) em sub-rede privada para fotogrametria (escalando de 0 a N conforme fila).
9. **Composer (`modules/composer`):** Cloud Composer 3 para orquestração orientada a eventos das missões.
10. **Pub/Sub (`modules/pubsub`):** Tópicos e subscriptions com Dead-Letter Queues para eventos de upload e processamento.
11. **Cloud Run (`modules/cloud-run`):** Serviços serverless para Web App, Business API e Quick Count.
12. **Looker Core (`modules/looker-core`):** Instância Looker (Google Cloud Core) para dashboards executivos.