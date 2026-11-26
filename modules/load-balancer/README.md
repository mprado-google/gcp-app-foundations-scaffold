# Módulo: load-balancer

Provisiona o **Global HTTPS Load Balancer** (L7) da plataforma SEIA/ADAPAR, com:
- Certificado SSL gerenciado pelo Google (`google_compute_managed_ssl_certificate`)
- Redirect automático HTTP → HTTPS
- Integração com **Cloud Armor** (WAF) via `cloud_armor_policy_id` vindo do módulo `networking`
- **Cloud CDN** opcional para caching de assets estáticos e tiles COG/WMTS
- Backend Service configurável com suporte a NEGs (Cloud Run, GKE Serverless NEG)

## Uso

```hcl
module "load_balancer" {
  source = "../../modules/load-balancer"

  project_id            = var.project_id
  environment           = var.environment
  company_prefix        = var.company_prefix
  project_name          = var.project_name
  region                = var.region
  common_labels         = var.common_labels
  enable_load_balancer  = var.enable_load_balancer
  domains               = var.lb_domains
  cloud_armor_policy_id = module.networking[0].cloud_armor_policy_id
  enable_cdn            = var.lb_enable_cdn
  backends              = var.lb_backends
}
```

> **Cloud Armor:** A política WAF é criada pelo módulo `modules/networking` (recurso `google_compute_security_policy.cloud_armor`) e referenciada aqui via output `cloud_armor_policy_id`. As regras incluem rate limiting DoS, bloqueio de SQLi (OWASP v3.3) e XSS (OWASP v3.3).

## Inputs

| Nome | Descrição | Tipo | Default |
|------|-----------|------|---------|
| `project_id` | ID do projeto GCP | `string` | — |
| `environment` | Ambiente (dev/hml/prd) | `string` | — |
| `company_prefix` | Prefixo da empresa | `string` | `"seia"` |
| `project_name` | Nome do projeto | `string` | `"adapar"` |
| `region` | Região principal (para nomenclatura) | `string` | `"southamerica-east1"` |
| `common_labels` | Labels obrigatórias | `map(string)` | `{}` |
| `enable_load_balancer` | Feature flag do módulo | `bool` | `true` |
| `domains` | Domínios para o certificado SSL | `list(string)` | `[]` |
| `cloud_armor_policy_id` | ID da política Cloud Armor | `string` | `null` |
| `enable_cdn` | Habilita Cloud CDN | `bool` | `true` |
| `health_check_path` | Path do health check | `string` | `"/healthz"` |
| `backends` | Lista de backends (NEGs) | `list(object)` | `[]` |

## Outputs

| Nome | Descrição |
|------|-----------|
| `lb_ip_address` | IP público estático do LB |
| `lb_ip_name` | Nome do recurso de IP estático |
| `ssl_certificate_id` | ID do certificado SSL gerenciado |
| `backend_service_id` | ID do Backend Service |
| `url_map_id` | ID do URL Map |
| `https_forwarding_rule_name` | Nome da forwarding rule HTTPS |
| `http_redirect_forwarding_rule_name` | Nome da forwarding rule HTTP (redirect) |

## Arquitetura

```
Internet
   │
   ▼
[Global Forwarding Rule :443] ──► [Target HTTPS Proxy]
[Global Forwarding Rule :80]  ──► [Target HTTP Proxy] ──► [URL Map: HTTP→HTTPS Redirect]
                                         │
                                   [URL Map]
                                         │
                                   [Backend Service]
                                   ├── Cloud Armor (WAF) ◄── módulo networking
                                   ├── Cloud CDN (opcional)
                                   └── Health Check HTTPS
                                         │
                              [NEGs: Cloud Run / GKE Serverless]
```

## Nomenclatura dos Recursos

Seguindo o padrão `<prefixo>-<projeto>-<ambiente>-<recurso>`:

- IP estático: `seia-adapar-dev-lb-ip`
- SSL Cert: `seia-adapar-dev-ssl-cert`
- Backend Service: `seia-adapar-dev-lb-backend`
- URL Map: `seia-adapar-dev-lb-urlmap`
- HTTPS Proxy: `seia-adapar-dev-lb-https-proxy`
- Forwarding Rule HTTPS: `seia-adapar-dev-lb-fwd-https`
- Forwarding Rule HTTP: `seia-adapar-dev-lb-fwd-http`
