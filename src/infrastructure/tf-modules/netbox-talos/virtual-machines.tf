# tofu/talos/virtual-machines.tf
resource "proxmox_virtual_environment_vm" "this" {
  for_each           = toset(local.vmnodes)

  node_name = var.nodes[each.key].host_node

  name        = each.key
  description = var.nodes[each.key].machine_type == "controlplane" ? "Talos Control Plane" : "Talos Worker"
  tags        = var.nodes[each.key].machine_type == "controlplane" ? ["k8s", "control-plane"] : ["k8s", "worker"]
  on_boot     = true
  vm_id       = var.nodes[each.key].vmInformation.vm_id

  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  bios          = "seabios"

  agent {
    enabled = true
  }

  cpu {
    cores = var.nodes[each.key].vmInformation.cpu
    # type  = "host"
    type = "x86-64-v2-AES" # recommended for modern CPUs
  }

  memory {
    dedicated = var.nodes[each.key].vmInformation.ram_dedicated
  }

  network_device {
    bridge      = "vmbr0"
    mac_address = var.nodes[each.key].vmInformation.mac_address
  }

  disk {
    datastore_id = var.nodes[each.key].datastore_id
    interface    = "virtio0"
    iothread     = true
    cache        = "writethrough"
    discard      = "on"
    ssd          = false
    file_format  = "raw"
    size         = var.nodes[each.key].vmInformation.storage_size
    file_id      = proxmox_virtual_environment_download_file.this["${var.nodes[each.key].host_node}_${var.nodes[each.key].update == true ? local.update_image_id : local.image_id}"].id
  }

  boot_order = ["virtio0"]

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 6.X.
  }

  initialization {
    datastore_id = var.nodes[each.key].datastore_id
    ip_config {
      ipv4 {
        address = local.allIps[each.key].ip_address
        gateway = var.cluster.gateway
      }
    }

    # user_account {
    #   # do not use this in production, configure your own ssh key instead!
    #   username = "user"
    #   password = "password"
    # }    
  }

  dynamic "usb" {
    for_each = var.nodes[each.key].usb 
    content {
      # Passthrough iGPU
      host = usb.value.host
      usb3 = usb.value.usb3
    }
  }
  dynamic "hostpci" {
    for_each = var.nodes[each.key].igpu ? [1] : []
    content {
      # Passthrough iGPU
      device  = "hostpci0"
      mapping = "iGPU"
      pcie    = true
      rombar  = true
      xvga    = false
    }
  }
}
