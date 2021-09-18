
resource "random_password" "gitea_secret_key_password" {
  length           = 26
  special          = true
  override_special = "_%@"
}


resource "vault_generic_secret" "gitea_admin" {
  # Gitea Admin user:  https://gitea.com/gitea/helm-chart/src/branch/master#admin-user
  path = format("%s/services/gitea/users/admin", module.secrets_engine.path)

  data_json = <<EOT
{
  "username":   "gitea_admin",
  "password":   "${random_password.gitea_secret_key_password.result}",
  "email":      "gi@tea.com"
}
EOT
}
