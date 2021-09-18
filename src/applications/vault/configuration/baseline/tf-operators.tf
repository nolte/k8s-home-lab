
resource "vault_kubernetes_auth_backend_role" "tf_opeators" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "tf-opeators"
  bound_service_account_names      = ["keycloak-tf-provider"]
  bound_service_account_namespaces = ["keycloak"]
  token_ttl                        = 3600
  token_policies = [
    "default",
    vault_policy.this.name,
    vault_policy.argo_workflow.name,
  ]
  # audience                         = "vault"
}
