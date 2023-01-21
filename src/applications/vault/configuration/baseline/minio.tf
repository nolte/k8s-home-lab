
resource "random_password" "minio_secret_key_password" {
  length           = 26
  special          = true
  override_special = "_%@"
}


resource "vault_generic_secret" "minio_secret_key_password" {
  path = format("%s/services/s3/users/admin", module.secrets_engine.path)

  data_json = <<EOT
{
  "accesskey":   "admin",
  "secretkey":   "${random_password.minio_secret_key_password.result}"
}
EOT
}




resource "random_password" "minio_console_passphrase" {
  length           = 26
  special          = true
  override_special = "_%@"
}

resource "random_password" "minio_console_secret_key" {
  length           = 26
  special          = true
  override_special = "_%@"
}


resource "random_password" "minio_console_secret_key_salt" {
  length           = 10
  special          = true
  override_special = "_%@"
}

resource "vault_generic_secret" "minio_console" {
  path = format("%s/services/s3/users/console-admin", module.secrets_engine.path)

  data_json = <<EOT
{
  "salt": "${random_password.minio_console_secret_key_salt.result}",
  "passphrase":   "${random_password.minio_console_passphrase.result}",
  "accesskey":   "admin-console",
  "secretkey":   "${random_password.minio_console_secret_key.result}"  
}
EOT
}

data "vault_policy_document" "minio_external_secrets" {
  rule {
    path         = "secrets-tf/data/services/s3/users/console-admin"
    capabilities = ["read"]
    description  = "Read Generated Console Admin Informations"
  }
  rule {
    path         = "secrets-tf/data/services/s3/users/admin"
    capabilities = ["read"]
    description  = "Read the Minio admin Informations"
  }
}



resource "vault_policy" "minio_external_secrets" {
  name   = "minio-external-secrets"
  policy = data.vault_policy_document.minio_external_secrets.hcl
}


