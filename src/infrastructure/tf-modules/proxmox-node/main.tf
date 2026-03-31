variable "node_name" {
  
}

resource "proxmox_virtual_environment_apt_standard_repository" "pve_no_subscription" {
  handle = "no-subscription"
  node   = var.node_name
}

resource "proxmox_virtual_environment_apt_repository" "pve_no_subscription" {
  enabled   = true
  file_path = proxmox_virtual_environment_apt_standard_repository.pve_no_subscription.file_path
  index     = proxmox_virtual_environment_apt_standard_repository.pve_no_subscription.index
  node      = proxmox_virtual_environment_apt_standard_repository.pve_no_subscription.node
}