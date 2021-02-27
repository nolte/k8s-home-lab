
variable "secrets_engine_path" {
  default = "secrets-tf"
}

variable "oidc_client" {
  type = object({
    client_id     = string
    client_secret = string
    name          = string
  })
  sensitive = true
}


resource "vault_generic_secret" "this" {
  path = format("%s/services/IdentityAccessManagement/clients/%s", var.secrets_engine_path, var.oidc_client.name)

  data_json = <<EOT
{
  "client_id":   "${var.oidc_client.client_id}",
  "client_secret":   "${var.oidc_client.client_secret}"
}
EOT
}
