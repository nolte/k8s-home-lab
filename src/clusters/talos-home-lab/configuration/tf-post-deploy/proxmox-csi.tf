
variable "path_proxmox_token" {
  default = "private/services/proxmox/users/kubernetes-csi@pve/token"
}
variable "path_proxmox_endpoint" {
  default = "private/services/proxmox/endpoint"
}

data "pass_password" "proxmox_token" {
  path = var.path_proxmox_token
}
data "pass_password" "proxmox_endpoint" {
  path = var.path_proxmox_endpoint
}

locals {
  proxmox_token        = data.pass_password.proxmox_token.password
  proxmox_endpoint     = data.pass_password.proxmox_endpoint.password
  proxmox_insecure     = true
  proxmox_cluster_name = "pve"
}

locals {
  token_id     = split("=", local.proxmox_token)[0]
  token_secret = element(split("=", local.proxmox_token), length(split("=", local.proxmox_token)) - 1)
}

resource "kubernetes_secret" "proxmox-csi-plugin" {
  metadata {
    name      = "proxmox-csi-plugin"
    namespace = "csi-proxmox"
  }

  data = {
    "config.yaml" = <<EOF
clusters:
- url: "${local.proxmox_endpoint}/api2/json"
  insecure: ${local.proxmox_insecure}
  token_id: "${local.token_id}"
  token_secret: "${local.token_secret}"
  region: ${local.proxmox_cluster_name}
EOF
  }
}