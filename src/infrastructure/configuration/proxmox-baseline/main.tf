variable "proxmox_username" {
  default = "root"
}

locals {
  user_id = format("%s@pam", var.proxmox_username)
}

data "proxmox_virtual_environment_user" "cicd" {
  user_id = local.user_id
}

data "proxmox_virtual_environment_nodes" "available_nodes" {}

module "baseline_node" {
  for_each = toset(data.proxmox_virtual_environment_nodes.available_nodes.names)
  source = "../../tf-modules/proxmox-node"
  node_name = each.key 
}

resource "netbox_ip_address" "router" {
  ip_address                   = "192.168.178.1/32"
  status                       = "active"
  description = "fritzbox"
}


# 

# data "proxmox_virtual_environment_role" "admin" {
#   role_id = "Administrator"
# }

# resource "proxmox_virtual_environment_role" "operations_monitoring" {
#   role_id = "operations-monitoring"

#   privileges = [
#     "Datastore.Audit",
#     "Datastore.AllocateSpace"
#   ]
# }

# resource "random_password" "cicd" {
#   length           = 16
#   special          = true
#   override_special = "!#$%&*()-_=+[]{}<>:?"
# }

# # if creating a user token, the user must be created first
# resource "proxmox_virtual_environment_user" "cicd" {
#   acl {
#     path      = "/"
#     propagate = true
#     role_id   = data.proxmox_virtual_environment_role.admin.role_id
#   }

#   comment  = "Managed by Terraform"
#   email    = local.user_id
#   password = random_password.cicd.result
#   enabled  = true
#   # expiration_date = "2034-01-01T22:00:00Z"
#   user_id = local.user_id
# }

resource "proxmox_virtual_environment_user_token" "cicd" {
  comment = "Managed by Terraform"
  # expiration_date = "2033-01-01T22:00:00Z"
  token_name            = "tk1"
  user_id               = data.proxmox_virtual_environment_user.cicd.user_id
  privileges_separation = false
}

resource "pass_password" "cicd_token" {
  password = proxmox_virtual_environment_user_token.cicd.value
  path     = format("private/services/proxmox/users/%s/token", var.proxmox_username)
}

# resource "pass_password" "cicd_password" {
#   password = random_password.cicd.result
#   path     = format("private/services/proxmox/users/%s/password", var.proxmox_username)
# }
