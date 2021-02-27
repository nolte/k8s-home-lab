output "output" {
  value = "its a test"
}

variable "secrets_engine_path" {
  default = "secrets-tf"
}

resource "vault_generic_secret" "this" {
  path = format("%s/playground/examples/secret", var.secrets_engine_path)

  data_json = <<EOT
{
  "salt": "comes from terraform"
}
EOT
}
