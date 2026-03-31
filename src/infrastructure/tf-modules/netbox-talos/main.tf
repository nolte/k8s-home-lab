# # tofu/talos/virtual-machines.tf

locals {
  vmnodes = [for each in keys(var.nodes) : each if var.nodes[each].type.kind == "virtual"]
  barenodes = [for each in keys(var.nodes) : each if var.nodes[each].type.kind != "virtual"]
}

data "netbox_cluster_type" "this" {
  name = "talos"
}

resource "netbox_cluster" "this" {
  cluster_type_id = data.netbox_cluster_type.this.id
  name            = var.cluster.name
}

# -------------------------------------------------



resource "netbox_available_ip_address" "this" {
  for_each     = toset(local.vmnodes)
  ip_range_id  = var.cluster.ip_range_id
  description  = each.key == var.cluster.endpoint ? "main" : ""
  interface_id = netbox_interface.vm[each.key].id
  object_type  = var.nodes[each.key].type.kind == "virtual" ? "virtualization.vminterface" : "dcim.interface"
}



resource "netbox_virtual_machine" "this" {
  for_each     = toset(local.vmnodes)
  cluster_id   = netbox_cluster.this.id
  name         = each.key
  disk_size_mb = var.nodes[each.key].vmInformation.storage_size * 1024
  memory_mb    = var.nodes[each.key].vmInformation.ram_dedicated
  vcpus        = var.nodes[each.key].vmInformation.cpu
}

resource "netbox_interface" "vm" {
  for_each     = toset(local.vmnodes)
  name               = "eth0"
  virtual_machine_id = netbox_virtual_machine.this[each.key].id
}

resource "netbox_primary_ip" "this" {
  for_each           = toset(local.vmnodes)
  ip_address_id      = netbox_available_ip_address.this[each.key].id
  virtual_machine_id = netbox_virtual_machine.this[each.key].id
}

# -------------------------------------------------





resource "netbox_device" "this" {
  for_each     = toset(local.barenodes)
  name           = each.key
  device_type_id = var.nodes[each.key].bare.device_type_id
  role_id        = var.nodes[each.key].bare.role_id
  site_id        = var.nodes[each.key].bare.site_id
  cluster_id   = netbox_cluster.this.id
}

resource "netbox_available_ip_address" "bare" {
  for_each     = toset(local.barenodes)
  ip_range_id  = var.cluster.ip_range_id
  description  = each.key == var.cluster.endpoint ? "main" : ""
  device_interface_id = netbox_device_interface.bare[each.key].id
}

resource "netbox_device_interface" "bare" {
  for_each     = toset(local.barenodes)
  name      = "eth0"
  device_id = netbox_device.this[each.key].id
  type      =  var.nodes[each.key].bare.interface_type
}

resource "netbox_device_primary_ip" "bare" {
  for_each     = toset(local.barenodes)
  device_id     = netbox_device.this[each.key].id
  ip_address_id = netbox_available_ip_address.bare[each.key].id
}

locals {
  allIps = merge(netbox_available_ip_address.bare , netbox_available_ip_address.this)
}