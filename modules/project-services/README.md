# Módulo Project Services (`modules/project-services`)

Este módulo é responsável por habilitar de forma centralizada, idempotente e declarativa todas as APIs e serviços do Google Cloud necessários para a infraestrutura da plataforma, respeitando a boa prática de não desativação destrutiva (`disable_on_destroy = false`).

## Recursos Gerenciados

- `google_project_service`: Ativação das APIs fundamentais (Compute, Networking, Cloud SQL, Storage, KMS, Secret Manager, IAM, IAP, etc.).

## Inputs

| Nome | Descrição | Tipo | Padrão | Obrigatório |
|------|-----------|------|--------|:-----------:|
| `project_id` | GCP Project ID onde os serviços serão ativados | `string` | n/a | Sim |
| `services` | Lista de APIs do Google Cloud a serem ativadas | `list(string)` | Lista com APIs base | Não |
| `disable_on_destroy` | Define se os serviços serão desativados no destroy | `bool` | `false` | Não |
| `disable_dependent_services` | Define se desativa serviços dependentes | `bool` | `false` | Não |

## Outputs

| Nome | Descrição |
|------|-----------|
| `project_id` | O ID do projeto GCP |
| `enabled_services` | Lista das APIs ativadas com sucesso |

## Exemplo de Uso

```hcl
module "project_services" {
  source     = "../../modules/project-services"
  project_id = var.project_id
  services = [
    "compute.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "cloudkms.googleapis.com",
    "secretmanager.googleapis.com",
    "iam.googleapis.com"
  ]
}
```

