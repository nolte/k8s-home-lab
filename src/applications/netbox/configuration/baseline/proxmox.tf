# 192.168.178.10

locals {
  proxmox_devices = {
    "PC-192-168-178-10" = {
      primary_ip     = "192.168.178.10/32"
      device_type_id = netbox_device_type.geekom_gt1_mega.id
      description    = "proxmox main node"
      cluster_id     = netbox_cluster.proxmox_cluster_01.id
      tags = [
        netbox_tag.ansible_managed.name,
        netbox_tag.proxmox_main.name,
        netbox_tag.proxmox_node.name,
      ]
    }
    "PC-192-168-178-23" = {
      primary_ip     = "192.168.178.23/32"
      device_type_id = netbox_device_type.intel_nuc.id
      description    = "proxmox second node"
      cluster_id     = netbox_cluster.proxmox_cluster_01.id
      tags = [
        netbox_tag.ansible_managed.name,
        netbox_tag.proxmox_node.name,
      ]
    }
  }
}

module "proxmox" {
  for_each = local.proxmox_devices

  source         = "../modules/proxmox-device"
  device_type_id = each.value.device_type_id
  description    = each.value.device_type_id
  role_id        = netbox_device_role.homelab.id
  site_id        = netbox_site.prem.id
  name           = each.key
  primary_ip     = each.value.primary_ip

  platform_id = netbox_platform.bare.id
  cluster_id  = each.value.cluster_id
  tags        = each.value.tags
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