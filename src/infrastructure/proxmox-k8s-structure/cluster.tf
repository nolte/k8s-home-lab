resource "proxmox_virtual_environment_vm" "this" {
  name       = local.vm_name
  node_name  = local.proxmox_node_name
  boot_order = ["virtio0", "virtio1"]

  initialization {
    user_account {
      # do not use this in production, configure your own ssh key instead!
      username = "user"
      password = "password"
    }

  }

  network_device {
    bridge = "vmbr0"
  }

  agent {
    # read 'Qemu guest agent' section, change to true only when ready
    enabled = true
  }

  cpu {
    cores = 4
    type  = "x86-64-v2-AES" # recommended for modern CPUs
    #flags = ["kvm64", "+cx16", "+lahf_lm", "+popcnt", "+sse3", "+ssse3", "+sse4.1", "+sse4.2"]
  }

  memory {
    dedicated = 4096
    floating  = 4096 # set equal to dedicated to enable ballooning
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.this.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 1
  }
  disk {
    datastore_id = "local-lvm"
    file_format  = "raw"
    interface    = "virtio1"
    size         = 5
  }
}


data "template_file" "init" {
  template = file("${path.module}/talconfig.yaml.tpl")
  vars = {
    master_address     = "${proxmox_virtual_environment_vm.this.ipv4_addresses[7][0]}"
    install_disk       = "/dev/vda"
    qemu_digest        = local.qemu_digest
    node_0_hostname    = "k8ssmarthome02"
    cluster_name       = "smart-home-02"
    talos_version      = local.talos_version
    kubernetes_version = "v1.31.1"
  }
}

resource "local_file" "foo" {
  content  = data.template_file.init.rendered
  filename = "${path.module}/gen/talconfig.yaml"
}
