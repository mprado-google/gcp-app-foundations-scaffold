# Diretrizes de Código Terraform (Code Guidance) - SEIA / CELEPAR

## 1. Convenção de Nomenclatura
Todos os recursos devem seguir o padrão:
`<prefixo-empresa>-<projeto>-<ambiente>-<recurso>-<regiao>`
* Exemplo: `seia-adapar-prd-gke-southamericaeast1`

## 2. Labels Obrigatórias
Todo recurso que suporta labels deve receber o mapa `common_labels`:
* `environment`: `dev`, `hml` ou `prd`
* `project`: Nome da aplicação (ex: `adapar-censo-rebanhos`)
* `owner`: Squad ou email técnico responsável
* `managed_by`: `terraform`

## 3. Segurança e Rede
* **Proibido IP Público:** VMs, Cloud SQL, Memorystore e nós do GKE não devem possuir IP externo direto. Utilize Cloud NAT para saída e Global HTTPS Load Balancer / Cloud Armor / IAP para entrada.
* **Acesso Privado:** Utilize Private Service Access / Private Service Connect para comunicação interna com Cloud SQL e Memorystore.
* **Criptografia:** Utilize CMEK (Customer-Managed Encryption Keys via Cloud KMS) em ambientes `prd` sempre que exigido por compliance.
* **IAM:** Aplique o princípio do menor privilégio. Nunca utilize a Compute Engine Default Service Account; crie Service Accounts dedicadas por componente.

## 4. Gerenciamento de Estado e Versões
* Fixe a versão do Terraform (`>= 1.6.0`) e do provider Google (`~> 6.0`).
* Utilize estados (`tfstate`) estritamente isolados por ambiente (`dev`, `hml`, `prd`) em buckets GCS com versionamento ativado.
* Nunca faça commit de arquivos `.tfstate` ou credenciais. Utilize o **Secret Manager**.