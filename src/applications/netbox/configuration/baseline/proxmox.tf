# 192.168.178.10

module "proxmox" {

  source         = "../modules/proxmox-device"
  device_type_id = netbox_device_type.geekom_gt1_mega.id
  description = "proxmox main node"
  role_id        = netbox_device_role.homelab.id
  site_id        = netbox_site.prem.id
  name           = "PC-192-168-178-10"
  primary_ip     = "192.168.178.10/32"

  platform_id = netbox_platform.bare.id
  cluster_id = netbox_cluster.proxmox_cluster_01.id
  tags = [
    netbox_tag.ansible_managed.name
    # netbox_tag.smart_home.name
  ]
}

resource "netbox_cluster_group" "flat" {
  description = "West Datacenter Cluster"
  name        = "dc-flat"
}

resource "netbox_cluster_type" "proxmox" {
  name = "proxmox"
}

resource "netbox_cluster" "proxmox_cluster_01" {
  cluster_type_id  = netbox_cluster_type.proxmox.id
  name             = "proxmox-cluster-01"
  cluster_group_id = netbox_cluster_group.flat.id
}