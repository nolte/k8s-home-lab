# tofu/talos/variables.tf
variable "image" {
  description = "Talos image configuration"
  type = object({
    factory_url       = optional(string, "https://factory.talos.dev")
    schematic         = string
    version           = string
    update_schematic  = optional(string)
    update_version    = optional(string)
    arch              = optional(string, "amd64")
    platform          = optional(string, "nocloud")
    proxmox_datastore = optional(string, "local")
  })
}

variable "cluster" {
  description = "Cluster configuration"
  type = object({
    name            = string
    endpoint        = string
    gateway         = string
    talos_version   = string
    proxmox_cluster = string
    ip_range_id     = number
  })
}

variable "nodes" {
  description = "Configuration for cluster nodes"
  type = map(object({
    host_node    = string
    machine_type = string
    datastore_id = optional(string, "local-lvm")
    #ip            = string

    type = object({
      kind = optional(string, "virtual")
    })
    vmInformation = optional(object({
      mac_address   = optional(string, null)
      vm_id         = optional(number, null)
      cpu           = optional(number, null)
      ram_dedicated = optional(number, null)
      storage_size  = optional(number, 20)
      })
    , {})
    bare = optional(object({
      device_type_id = optional(number, null)
      role_id        = optional(number, null)
      site_id        = optional(number, null)
      interface_type = optional(string, "100base-tx")
      })
    , {})

    update               = optional(bool, false)
    igpu                 = optional(bool, false)
    additionalNodeLabels = optional(map(string), {})
    usb = optional(list(object({
      host = string
      usb3 = optional(bool, false)
    })), [])
  }))
}

