
variable "path_duckdns_token" {
  default = "internet/duckdns.org/oidc-google/token"
}

data "pass_password" "duckdns_token" {
  path = var.path_duckdns_token
}

locals {
  duckdns_token = data.pass_password.duckdns_token.password
}

resource "kubernetes_secret" "duckdns-token" {
  metadata {
    name      = "duckdns-token"
    namespace = "cert-manager"
  }

  data = {
    token = local.duckdns_token
  }
}