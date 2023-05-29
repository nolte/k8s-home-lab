resource "harbor_config_auth" "oidc" {
  auth_mode          = "oidc_auth"
  oidc_name          = "keycloak_openid_client_default_scopes"
  oidc_endpoint      = "https://keycloak.dev44-just-homestyle.duckdns.org/realms/devops-services"
  oidc_client_id     = module.oidc_client.this.client_id
  oidc_client_secret = module.oidc_client.this.client_secret
  oidc_scope         = "openid,email,groups"
  oidc_verify_cert   = true
  oidc_auto_onboard  = true
  oidc_groups_claim  = "groups"
  oidc_user_claim    = "name"
  oidc_admin_group   = "/platform-super-users/harbor-admin-users"
}
