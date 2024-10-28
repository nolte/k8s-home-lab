locals {
    talos_version      = "v1.8.1"
  qemu_digest            = "ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515"
  vm_name                = "test-centos"
  proxmox_node_name      = "pve"
  talos_iso_download_url = format("https://factory.talos.dev/image/%s/%s/metal-amd64.iso", local.qemu_digest,local.talos_version)
}

resource "proxmox_virtual_environment_group" "operations_team" {
  comment  = "Managed by Terraform"
  group_id = "cluster-management"
}



resource "proxmox_virtual_environment_download_file" "this" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = local.proxmox_node_name
  url          = local.talos_iso_download_url
  file_name    = "talos180.img"
}


