
data "vault_policy_document" "external_dns_external_secrets" {
  rule {
    path         = "secrets-tf/data/services/dns/users/root"
    capabilities = ["read"]
    description  = "Read Generated Console Admin Informations"
  }
  
}



resource "vault_policy" "external_dns_external_secrets" {
  name   = "external-dns-external-secrets"
  policy = data.vault_policy_document.external_dns_external_secrets.hcl
}

