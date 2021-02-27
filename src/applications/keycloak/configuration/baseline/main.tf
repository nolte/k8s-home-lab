
resource "keycloak_realm" "realm" {
  realm = "devops-services"

  otp_policy {
    type = "totp"
    algorithm = "HmacSHA256"
  }
}


resource "keycloak_openid_client_scope" "openid_client_scope" {
  realm_id               = keycloak_realm.realm.id
  name                   = "groups"
  description            = "When requested, this scope will map a user's group memberships to a claim"
  include_in_token_scope = true
  gui_order              = 1
  consent_screen_text    = " "
}
