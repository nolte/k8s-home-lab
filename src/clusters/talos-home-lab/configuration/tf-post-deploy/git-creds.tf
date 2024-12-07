
variable "path_id_rsa_pub" {
  default = "internet/project/homeassistant/deploymentkey/id_rsa.pub"
}

data "pass_password" "id_rsa_pub" {
  path = var.path_id_rsa_pub
}

variable "path_id_rsa" {
  default = "internet/project/homeassistant/deploymentkey/id_rsa"
}

data "pass_password" "path_id_rsa" {
  path = var.path_id_rsa
}


locals {
  id_rsa_pub = data.pass_password.id_rsa_pub.password
  id_rsa     = data.pass_password.path_id_rsa.password
}

variable "known_hosts" {

}

locals {
  git_creds_namespaces = ["esphome", "home-assistant"]
}

resource "kubernetes_secret" "git-creds" {
  for_each = { for ns in local.git_creds_namespaces : ns => ns }

  metadata {
    name      = "git-creds"
    namespace = each.key
  }

  data = {
    id_rsa       = local.id_rsa
    "id_rsa.pub" = local.id_rsa_pub
    known_hosts  = var.known_hosts
  }
}