
data "netbox_cluster_type" "talos" {
  name = "talos"
}

variable "cluster_name" {
  type    = string
  default = "smart-home-dev"
}

variable "proxmox_node" {
  type    = string
  default = "pve-02"
}

resource "netbox_cluster" "this" {
  cluster_type_id = data.netbox_cluster_type.talos.id
  name            = var.cluster_name
  #cluster_group_id = data.netbox_cluster_group.this.id
}

resource "netbox_ip_range" "this" {
  start_address = "192.168.178.160/24"
  end_address   = "192.168.178.175/24"
  tags          = []
}

# resource "netbox_available_ip_address" "myvm-ip" {
#   ip_range_id = netbox_ip_range.this.id
#   status       = "active"
#   #interface_id = netbox_interface.myvm-eth0.id
# }

# resource "netbox_ip_address" "this" {
#   ip_address = data.netbox_ip_address.this.
#   status     = "active"
# }

# data "netbox_ip_range" "test" {
#   start_address = "192.168.178.160/24"
#   end_address   = "192.168.178.175/24"
# }

data "netbox_device_type" "rpiv3" {
  model = "rpi-v3"
}
data "netbox_device_role" "homelab" {
  name = "homelab"
}
data "netbox_site" "flat" {
  name = "flat"
}

locals {
  nodes = {
    "ctrl-00" = {
      host_node    = var.proxmox_node
      machine_type = "controlplane"
      #ip            = "192.168.178.161" #netbox_ip_address.this.ip_address #netbox_available_ip_address.homelab_ip_address.ip_address
      #ipId = netbox_ip_address.this
      vmInformation = {
        mac_address   = "BC:24:11:2E:C8:01"
        vm_id         = 801
        cpu           = 2
        ram_dedicated = 4096
        storage_size  = 10
      }
      additionalNodeLabels = {
        "zigbee.homelab.local/present" : false
      }
      type = {
        kind = "virtual"
      }
    }
    "node-00" = {
      host_node    = var.proxmox_node
      machine_type = "worker"
      type = {
        kind = "bare"
      }
      bare = {
        device_type_id = data.netbox_device_type.rpiv3.id
        role_id = data.netbox_device_role.homelab.id
        site_id = data.netbox_site.flat.id
      }
    }    
  }
}

module "talos" {
  source = "../../../../infrastructure/tf-modules/netbox-talos"

  providers = {
    proxmox = proxmox
  }

  image = {
    version   = "v1.9.5" # "1.9.5"
    schematic = file("${path.module}/talos/image/schematic.yaml")
  }

  cluster = {
    name = netbox_cluster.this.name
    #endpoint        = "192.168.178.161" #netbox_ip_address.this.ip_address #netbox_available_ip_address.homelab_ip_address.ip_address
    gateway         = "192.168.178.1"
    talos_version   = "v1.9.5"
    proxmox_cluster = var.proxmox_node
    ip_range_id     = netbox_ip_range.this.id
    endpoint        = "ctrl-00"
  }

  nodes = local.nodes
}

# output "da" {
#   value = module.talos.da
# }
