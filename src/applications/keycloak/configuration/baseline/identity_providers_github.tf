data "vault_generic_secret" "github_home_lab_app" {
  path = "secrets-tf/third-party-services/github.com/nolte/apps/k8s-home-lab"
}


# Allow to sign in with a Created Github Applicaion
resource "keycloak_oidc_identity_provider" "realm_identity_provider" {
  realm             = keycloak_realm.realm.id
  alias             = "github"
  authorization_url = ""
  token_url         = ""
  client_id         = data.vault_generic_secret.github_home_lab_app.data["client_id"]
  client_secret     = data.vault_generic_secret.github_home_lab_app.data["client_secret"]

  provider_id = "github"

  store_token    = false
  sync_mode      = "IMPORT"
  default_scopes = ""

}
