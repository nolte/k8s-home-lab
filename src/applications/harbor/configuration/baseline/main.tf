# https://harbor.dev44-just-homestyle.duckdns.org/
module "oidc_client" {
  source = "../../../keycloak/configuration/modules/oidc-client"

  realm_id  = var.realm_id
  client_id = "harbor"
  #root_url    = "https://harbor.dev44-just-homestyle.duckdns.org"
  #base_url    = "/applications"
  #web_origins = [""]

  #admin_url = "https://harbor.dev44-just-homestyle.duckdns.org"
  redirect_uris = [
    format("https://%s/c/oidc/callback", var.harbor_fqdn),
  ]
}


resource "keycloak_openid_client_default_scopes" "client_default_scopes" {
  realm_id  = var.realm_id
  client_id = module.oidc_client.this.id

  default_scopes = [
    "email",
    "groups",
    "profile",
  ]
}

resource "keycloak_group" "super_admins" {
  realm_id  = var.realm_id
  parent_id = var.super_admins_group_id
  name      = "harbor-admin-users"
}

resource "keycloak_openid_group_membership_protocol_mapper" "group_membership_mapper" {
  realm_id   = var.realm_id
  client_id  = module.oidc_client.this.id
  name       = "group-membership-mapper"
  claim_name = "groups"
}

resource "keycloak_role" "reader_role" {
  realm_id    = var.realm_id
  client_id   = module.oidc_client.this.id
  name        = "harbor-reader"
  description = "harbor Reader role"
}


resource "keycloak_role" "management_role" {
  realm_id    = var.realm_id
  client_id   = module.oidc_client.this.id
  name        = "harbor-management"
  description = "harbor Management role"
  composite_roles = [
    keycloak_role.reader_role.id
  ]
}

resource "keycloak_group_roles" "super_admins_argo" {
  realm_id   = var.realm_id
  group_id   = var.super_admins_group_id
  exhaustive = false

  role_ids = [
    keycloak_role.management_role.id,
  ]
}


module "oidc_client_storing" {
  source              = "../../../keycloak/configuration/modules/oidc-client-vault"
  secrets_engine_path = var.vault_secrets_engine_path
  oidc_client = {
    client_id     = module.oidc_client.this.client_id
    client_secret = module.oidc_client.this.client_secret
    name          = module.oidc_client.this.name
  }
}
