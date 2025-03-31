

resource "netbox_site" "prem" {
  name = "flat"
}

resource "netbox_prefix" "local" {
  prefix      = "192.168.178.0/24"
  status      = "active"
  description = "Local Network Range"
}

resource "netbox_prefix" "fritz_box_managed" {
  prefix      = "192.168.178.0/25"
  status      = "active"
  description = "Fritz box Managed Area"
}

resource "netbox_prefix" "proxmox" {
  prefix      = "192.168.178.160/28"
  status      = "active"
  description = "Proxmox vms"
}

resource "netbox_tag" "ansible_managed" {
  name      = "ansible-managed"
  slug = "ansible"
  color_hex = "8bc34a"
}