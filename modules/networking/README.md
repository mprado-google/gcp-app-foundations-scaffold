# Módulo Networking (`modules/networking`)

Módulo responsável pela topologia de rede privada em conformidade com as diretrizes do `code_guidance.md` e `spec.md`. Garante que nenhum recurso interno possua IP público exposto, fornecendo conectividade de saída via Cloud NAT e acesso privado a serviços gerenciados (Cloud SQL, Memorystore) via Private Service Access (PSA).

## Recursos Gerenciados

- `google_compute_network`: VPC dedicada (ou integração com Shared VPC).
- `google_compute_subnetwork`: Sub-redes privadas com Private Google Access ativado e faixas secundárias para GKE (Pods e Services).
- `google_compute_router` & `google_compute_router_nat`: Cloud NAT para saída segura à internet.
- `google_compute_global_address` & `google_service_networking_connection`: Conexão privada PSA para peering de serviços gerenciados.
- `google_compute_firewall`: Regras de menor privilégio (tráfego interno, health checks do Google, acesso via IAP).
- `google_compute_security_policy`: WAF Cloud Armor com mitigação de DDoS/rate limiting e regras OWASP (SQLi, XSS).

## Inputs

| Nome | Descrição | Tipo | Padrão | Obrigatório |
|------|-----------|------|--------|:-----------:|
| `project_id` | GCP Project ID | `string` | n/a | Sim |
| `environment` | Ambiente (`dev`, `hml`, `prd`) | `string` | n/a | Sim |
| `common_labels` | Mapa de labels obrigatórias | `map(string)` | n/a | Sim |
| `company_prefix` | Prefixo da organização | `string` | `"seia"` | Não |
| `project_name` | Nome da aplicação | `string` | `"adapar"` | Não |
| `region` | Região principal da VPC | `string` | `"southamerica-east1"` | Não |
| `create_vpc` | Se cria uma nova VPC ou utiliza existente | `bool` | `true` | Não |
| `subnets` | Lista de sub-redes a criar | `list(object)` | `[]` | Não |
| `create_nat` | Provisionamento de Cloud Router/NAT | `bool` | `true` | Não |
| `create_psa` | Provisionamento de Private Service Access | `bool` | `true` | Não |
| `psa_prefix_length` | Tamanho do bloco CIDR reservado para PSA | `number` | `16` | Não |
| `enable_cloud_armor`| Criação da política WAF Cloud Armor | `bool` | `true` | Não |

## Outputs

| Nome | Descrição |
|------|-----------|
| `network_id` | ID da VPC |
| `network_name` | Nome da VPC |
| `subnets` | Mapa de sub-redes criadas |
| `router_name` | Nome do Cloud Router |
| `nat_name` | Nome do Cloud NAT |
| `psa_range_name` | Nome da reserva de IP do PSA |
| `psa_connection_id` | ID da conexão de peering PSA |
| `cloud_armor_policy_id` | ID da política de segurança Cloud Armor |

## Exemplo de Uso

```hcl
module "networking" {
  source        = "../../modules/networking"
  project_id    = var.project_id
  environment   = "dev"
  common_labels = var.common_labels

  subnets = [
    {
      name          = "app"
      ip_cidr_range = "10.10.10.0/24"
    },
    {
      name          = "gke"
      ip_cidr_range = "10.10.20.0/24"
      secondary_ip_ranges = [
        { range_name = "pods", ip_cidr_range = "10.100.0.0/16" },
        { range_name = "services", ip_cidr_range = "10.101.0.0/20" }
      ]
    }
  ]
}
```

