

resource "keycloak_openid_client" "this" {
  realm_id  = var.realm_id
  client_id = var.client_id

  name                  = var.name == "" ? var.client_id : var.name
  standard_flow_enabled = true
  access_type           = "CONFIDENTIAL"
  valid_redirect_uris   = var.redirect_uris

  login_theme = var.login_theme
  root_url    = var.root_url
  base_url    = var.base_url
  web_origins = var.web_origins
  admin_url   = var.admin_url
}
