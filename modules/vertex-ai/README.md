# Módulo: vertex-ai

Provisiona os recursos de **Vertex AI** da plataforma SEIA/ADAPAR, incluindo:
- **Bucket de Artefatos** em `us-central1` para treinamento com GPUs A100 (exigência de spec.md)
- **Vertex AI Dataset** para gerenciamento de imagens aéreas e dados de treinamento
- **Vertex AI Tensorboard** para rastreamento de experimentos (Experiment Tracking)
- **Vertex AI Workbench** (notebook gerenciado, **exclusivo para dev**, com rede privada via VPC)
- **IAM** com menor privilégio: `roles/aiplatform.user` e `roles/storage.objectAdmin` para a SA de treinamento

> **Nota sobre Custom Training Jobs (GPUs A100):**
> Os `google_vertex_ai_custom_job` (treinamento com GPU A100) são **recursos imperativos** disparados
> via SDK Python ou `gcloud` em pipelines do Composer/Kubeflow. Eles **não são gerenciados pelo Terraform**
> pois são efêmeros por natureza. Configure o bucket de artefatos e a SA via este módulo;
> os jobs de treinamento são submetidos dinamicamente pelos DAGs do Composer.

## Sizing por Ambiente

| Recurso | dev | hml | prd |
|---------|-----|-----|-----|
| Workbench | ✅ `e2-standard-4` | ❌ | ❌ |
| Dataset | ✅ | ✅ | ✅ |
| Tensorboard | ✅ | ✅ | ✅ |
| Artifact bucket | 365 dias | 365 dias | 1825 dias (5 anos) |
| CMEK | ❌ | Opcional | ✅ Obrigatório |

## Uso

```hcl
module "vertex_ai" {
  source = "../../modules/vertex-ai"

  project_id            = var.project_id
  environment           = var.environment
  company_prefix        = var.company_prefix
  project_name          = var.project_name
  region                = var.region
  training_region       = var.secondary_region   # us-central1
  common_labels         = var.common_labels
  enable_vertex_ai      = var.enable_vertex_ai
  enable_workbench      = var.enable_workbench   # true apenas em dev
  service_account_email = module.security_iam[0].sa_emails["ingestion"]
  network_id            = module.networking[0].network_id
  subnet_id             = module.networking[0].subnets["app"].id
  workbench_zone        = "${var.region}-a"
  kms_key_name          = var.enable_cmek ? module.security_iam[0].storage_crypto_key_id : null
  force_destroy         = true  # false em prd
}
```

## Inputs

| Nome | Descrição | Tipo | Default |
|------|-----------|------|---------|
| `project_id` | ID do projeto GCP | `string` | — |
| `environment` | Ambiente (dev/hml/prd) | `string` | — |
| `company_prefix` | Prefixo da empresa | `string` | `"seia"` |
| `project_name` | Nome do projeto | `string` | `"adapar"` |
| `region` | Região principal (Workbench) | `string` | `"southamerica-east1"` |
| `training_region` | Região de treinamento A100 | `string` | `"us-central1"` |
| `common_labels` | Labels obrigatórias | `map(string)` | `{}` |
| `enable_vertex_ai` | Feature flag do módulo | `bool` | `true` |
| `enable_workbench` | Habilita Workbench (dev-only) | `bool` | `false` |
| `service_account_email` | SA para treinamento e Workbench | `string` | `null` |
| `network_id` | VPC ID (sem IP público) | `string` | `null` |
| `subnet_id` | Subnet ID para Workbench | `string` | `null` |
| `workbench_zone` | Zona do Workbench | `string` | `"southamerica-east1-a"` |
| `workbench_machine_type` | Machine type do Workbench | `string` | `"e2-standard-4"` |
| `kms_key_name` | Chave CMEK para bucket | `string` | `null` |
| `force_destroy` | Permite destroy do bucket com conteúdo | `bool` | `true` |
| `artifact_nearline_days` | Dias para mover para Nearline | `number` | `90` |
| `artifact_retention_days` | Dias de retenção total | `number` | `365` |

## Outputs

| Nome | Descrição |
|------|-----------|
| `vertex_artifacts_bucket_name` | Nome do bucket de artefatos (us-central1) |
| `vertex_artifacts_bucket_url` | URL gs:// do bucket |
| `vertex_dataset_id` | ID do Vertex AI Dataset |
| `vertex_dataset_name` | Display name do Dataset |
| `tensorboard_id` | ID do Tensorboard |
| `tensorboard_name` | Display name do Tensorboard |
| `workbench_instance_id` | ID do Workbench (dev-only) |
| `workbench_proxy_uri` | URI de acesso ao Workbench |

## Nomenclatura dos Recursos

Seguindo o padrão `<prefixo>-<projeto>-<ambiente>-<recurso>-<regiao>`:

- Bucket artefatos: `seia-adapar-dev-vertex-artifacts-uscentrall`
- Dataset: display_name `seia-adapar-dev-dataset-imagens-aereas`
- Tensorboard: display_name `seia-adapar-dev-tensorboard`
- Workbench: `seia-adapar-dev-workbench-southamericaeast1`

## Regiões

| Recurso | Região |
|---------|--------|
| Bucket de Artefatos | `us-central1` ⚠️ Obrigatório para A100 |
| Vertex AI Dataset | `us-central1` |
| Tensorboard | `us-central1` |
| Workbench (dev) | `southamerica-east1` |
