
data "vault_policy_document" "cert_manager_external_secrets" {

  rule {
    path         = "secrets-tf/data/third-party-services/duckdns.org/api"
    capabilities = ["read"]
    description  = "Duckdns API Key"
  }

}



resource "vault_policy" "cert_manager_external_secrets" {
  name   = "cert-manager-external-secrets"
  policy = data.vault_policy_document.cert_manager_external_secrets.hcl
}

