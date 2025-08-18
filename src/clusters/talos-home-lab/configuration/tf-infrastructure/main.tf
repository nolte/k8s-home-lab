module "talos" {
  source = "../../../../infrastructure/tf-modules/proxmox-talos"

  providers = {
    proxmox = proxmox
  }

  image = {
    version   = "v1.9.5" # "1.9.5"
    schematic = file("${path.module}/talos/image/schematic.yaml")
  }

  cluster = {
    name            = "smart-home-02"
    endpoint        = "192.168.178.130"
    gateway         = "192.168.178.1"
    talos_version   = "v1.9.5"
    proxmox_cluster = "pve"
  }

  nodes = {
    "ctrl-00" = {
      host_node     = "pve"
      machine_type  = "controlplane"
      ip            = "192.168.178.130"
      mac_address   = "BC:24:11:2E:C8:00"
      vm_id         = 800
      cpu           = 8
      ram_dedicated = 16384
      storage_size  = 40
      additionalNodeLabels = {
        "zigbee.homelab.local/present": true
      }
      usb = [{
        # SONOFF Zigbee 3.0 USB Dongle Plus V2
        host = "1a86:55d4"
        usb3 = false
      }]
    }
    # "ctrl-01" = {
    #   host_node     = "euclid"
    #   machine_type  = "controlplane"
    #   ip            = "192.168.1.101"
    #   mac_address   = "BC:24:11:2E:C8:01"
    #   vm_id         = 801
    #   cpu           = 4
    #   ram_dedicated = 4096
    #   igpu          = true
    # }
    # "ctrl-02" = {
    #   host_node     = "cantor"
    #   machine_type  = "controlplane"
    #   ip            = "192.168.1.102"
    #   mac_address   = "BC:24:11:2E:C8:02"
    #   vm_id         = 802
    #   cpu           = 4
    #   ram_dedicated = 4096
    # }
    # "work-00" = {
    #   host_node     = "abel"
    #   machine_type  = "worker"
    #   ip            = "192.168.1.110"
    #   mac_address   = "BC:24:11:2E:08:00"
    #   vm_id         = 810
    #   cpu           = 8
    #   ram_dedicated = 4096
    #   igpu          = true
    # }
  }
}
