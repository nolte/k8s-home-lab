
resource "netbox_manufacturer" "geekom" {
  name = "geekom"
}

resource "netbox_manufacturer" "intel" {
  name = "intel"
}

resource "netbox_device_role" "homelab" {
  name      = "homelab"
  description = "HomeLab device"
  color_hex = "00bcd4"
  vm_role = false
  tags = [
    netbox_tag.homelab.name
  ]
}


resource "netbox_tag" "homelab" {
  name      = "homelab"
  color_hex = "8bc34a"
}

resource "netbox_device_type" "geekom_gt1_mega" {
  model           = "GT1 Mega"
  manufacturer_id = netbox_manufacturer.geekom.id
}

resource "netbox_device_type" "intel_nuc" {
  model           = "Nuc"
  manufacturer_id = netbox_manufacturer.intel.id
}


resource "netbox_platform" "bare" {
  name = "bare"
}

resource "netbox_platform" "proxmox" {
  name = "proxmox"
}