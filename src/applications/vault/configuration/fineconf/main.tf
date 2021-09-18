
variable "realm_id" {

}

variable "vault_secrets_engine_path" {

}

variable "vault_fqdn" {
}

variable "keycloak_fqdn" {
}
variable "super_admins_group_id" {
}
module "vault" {
  source = "../../../keycloak/configuration/modules/oidc-client"

  realm_id  = var.realm_id
  client_id = "vault"
  redirect_uris = [
    "https://localhost:8250/oidc/callback",
    "http://localhost:8250/oidc/callback",
    format("https://%s/ui/vault/auth/oidc/oidc/callback", var.vault_fqdn)
  ]
}

resource "keycloak_openid_user_client_role_protocol_mapper" "user_client_role_mapper" {
  realm_id  = var.realm_id
  client_id = module.vault.this.id
  name      = "user-client-role-mapper"
  claim_name = format("resource_access.%s.roles",
  module.vault.this.client_id)
  multivalued = true
}


resource "keycloak_role" "management_role" {
  realm_id    = var.realm_id
  client_id   = module.vault.this.id
  name        = "vault-management"
  description = "Vault Management role"
  composite_roles = [
    keycloak_role.reader_role.id
  ]
}

resource "keycloak_group_roles" "super_admins_vault" {
  realm_id   = var.realm_id
  group_id   = var.super_admins_group_id
  exhaustive = false

  role_ids = [
    keycloak_role.management_role.id,
  ]
}


resource "keycloak_group_roles" "group_roles" {
  realm_id = var.realm_id
  group_id = keycloak_group.super_admins.id

  role_ids = [
    keycloak_role.management_role.id,
  ]
}

resource "keycloak_role" "reader_role" {
  realm_id    = var.realm_id
  client_id   = module.vault.this.id
  name        = "vault-reader"
  description = "Vault Reader role"
}


module "vault_storing" {
  source              = "../../../keycloak/configuration/modules/oidc-client-vault"
  secrets_engine_path = var.vault_secrets_engine_path
  oidc_client = {
    client_id     = module.vault.this.client_id
    client_secret = module.vault.this.client_secret
    name          = module.vault.this.name
  }
}

locals {
  oidc_discovery_url = format("https://%s/auth/realms/%s", var.keycloak_fqdn, var.realm_id)
}

resource "vault_identity_oidc_key" "keycloak_provider_key" {
  name      = "keycloak"
  algorithm = "RS256"
}



resource "vault_jwt_auth_backend" "auth" {
  description        = "Demonstration of the Terraform JWT auth backend"
  path               = "oidc"
  type               = "oidc"
  oidc_discovery_url = local.oidc_discovery_url
  oidc_client_id     = module.vault.this.client_id
  oidc_client_secret = module.vault.this.client_secret

  default_role = "default"
  tune {
    audit_non_hmac_request_keys  = []
    audit_non_hmac_response_keys = []
    default_lease_ttl            = "1h"
    listing_visibility           = "unauth"
    max_lease_ttl                = "1h"
    passthrough_request_headers  = []
    token_type                   = "default-service"
  }
}


resource "vault_jwt_auth_backend_role" "default" {
  backend       = vault_jwt_auth_backend.auth.path
  role_name     = "default"
  role_type     = "oidc"
  token_ttl     = 3600
  token_max_ttl = 3600

  bound_audiences = [module.vault.this.client_id]
  user_claim      = "sub"
  claim_mappings = {
    preferred_username = "username"
    email              = "email"
  }

  allowed_redirect_uris = [
    "http://localhost:8200/ui/vault/auth/oidc/oidc/callback",
    "http://localhost:8250/oidc/callback",
    format("https://%s/ui/vault/auth/oidc/oidc/callback", var.vault_fqdn)
  ]
  groups_claim = format("/resource_access/%s/roles",
  module.vault.this.client_id)
}


data "vault_policy_document" "reader_policy" {
  rule {
    path         = format("%s/*", var.vault_secrets_engine_path)
    capabilities = ["list", "read"]
  }
}

resource "vault_policy" "reader_policy" {
  name   = keycloak_role.reader_role.name
  policy = data.vault_policy_document.reader_policy.hcl
}

data "vault_policy_document" "manager_policy" {
  rule {
    path         = format("%s/*", var.vault_secrets_engine_path)
    capabilities = ["create", "update", "delete"]
  }
}

resource "vault_policy" "manager_policy" {
  name   = keycloak_role.management_role.name
  policy = data.vault_policy_document.manager_policy.hcl
}


resource "keycloak_group" "super_admins" {
  realm_id  = var.realm_id
  parent_id = var.super_admins_group_id
  name      = "vault-admin-users"
}



resource "vault_identity_oidc_role" "management_role" {
  name = keycloak_role.management_role.name
  key  = vault_identity_oidc_key.keycloak_provider_key.name
}

resource "vault_identity_group" "management_group" {
  name = vault_identity_oidc_role.management_role.name
  type = "external"
  policies = [
    vault_policy.manager_policy.name,
    vault_policy.reader_policy.name
  ]
}

resource "vault_identity_group_alias" "management_group_alias" {
  name           = keycloak_role.management_role.name
  mount_accessor = vault_jwt_auth_backend.auth.accessor
  canonical_id   = vault_identity_group.management_group.id
}