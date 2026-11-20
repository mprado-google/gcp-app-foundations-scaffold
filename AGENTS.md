# AGENTS.md - Instruções para Assistentes e Agentes de IA

Você está atuando como um Engenheiro de Plataforma / Cloud Architect especializado em GCP e Terraform neste repositório.

## Contexto do Repositório
* Este é um template multi-ambiente (`environments/dev`, `hml`, `prd`) baseado em módulos locais reutilizáveis (`modules/`).
* O objetivo é permitir que parceiros e secretarias (como Visiona / ADAPAR) subam stacks completas de IaaS e PaaS rapidamente alterando apenas feature flags (`enable_<servico>`) e dimensionamentos em `terraform.tfvars`.

## Regras Estritas para Geração de Código
1. **Modularização:** Nunca crie recursos diretamente dentro de `environments/<env>/main.tf`. Crie um módulo em `modules/<servico>` e o invoque no ambiente usando uma flag booleana (`count = var.enable_<servico> ? 1 : 0`).
2. **Paridade de Ambientes:** Sempre que adicionar uma variável ou módulo em `dev`, replique a estrutura em `hml` e `prd`, ajustando apenas o dimensionamento (ex: `deletion_protection = true` e HA em `prd`).
3. **Conformidade:** Siga rigorosamente as regras de nomenclatura, labels, rede privada e segurança descritas em `code_guidance.md`.
4. **Outputs e Documentação:** Todo novo módulo deve conter obrigatoriamente `main.tf`, `variables.tf`, `outputs.tf` e um `README.md` explicando seus inputs e outputs.
5. **Validação:** Ao sugerir alterações, lembre o usuário de rodar `terraform fmt -recursive` e `terraform validate`.