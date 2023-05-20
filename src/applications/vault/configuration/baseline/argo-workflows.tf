
resource "vault_kubernetes_auth_backend_role" "argo_workflow" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "argo-workflows"
  bound_service_account_names      = ["argo-workflows-executer"]
  bound_service_account_namespaces = ["keycloak", "powerdns", "minio", "argocd", "argo", "gitea"]
  token_ttl                        = 3600
  token_policies = [
    "default",
    vault_policy.this.name,
    vault_policy.argo_workflow.name,
  ]
  # audience                         = "vault"
}


resource "vault_policy" "argo_workflow" {
  name = "argo-workflows"

  policy = <<EOT

# TODO: review this ....
path "auth/token/lookup-self" {
   capabilities = ["read"]
}

# https://learn.hashicorp.com/tutorials/vault/batch-tokens#create-batch-tokens
# Required for Terrform Vault usage
path "auth/token/create" {
   capabilities = ["create", "read", "update", "delete", "list"]
}

path "${module.secrets_engine.path}/data/playground/+/*" {
   capabilities = ["create", "read", "update", "delete", "list"]
}

EOT
}
