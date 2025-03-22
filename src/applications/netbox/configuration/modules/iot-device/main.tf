

resource "netbox_device" "this" {
  name           = var.name
  device_type_id = var.device_type_id
  role_id        = var.role_id
  site_id        = var.site_id
  status         = var.status
  local_context_data = jsonencode({
    "esphome" = {
      "repo" : var.esphome_repo
      "config" : var.esphome_config == null ? format("%s.yaml",var.name) : var.esphome_config 
    }
  })
  tags        = var.tags
  platform_id = var.platform_id
}

resource "netbox_device_interface" "this" {
  name      = "wifi"
  device_id = netbox_device.this.id
  type      = "ieee802.11n"
}

resource "netbox_ip_address" "this" {
  ip_address = var.primary_ip
  status     = "active"

  device_interface_id = netbox_device_interface.this.id
  dns_name = format("%s.fritz.box",var.name)
  custom_fields = {
    "netboxOperatorRestorationHash" : ""
  }
}

resource "netbox_device_primary_ip" "this" {
  device_id     = netbox_device.this.id
  ip_address_id = netbox_ip_address.this.id
}

locals {
  services = {
    esphomeapi = {
      ports       = [6053]
      description = "ESPHome Native API"
    }
    esphomeui = {
      ports       = [80]
      description = "ESPHome Device"
    }
    prometheus = {
      ports       = [80]
      description = "Prometheus Metris as /metrics"
    }
  }
}
resource "netbox_service" "this" {
  for_each    = merge(local.services, var.additional_services)
  name        = each.key
  ports       = each.value.ports
  description = each.value.description
  protocol    = "tcp"
  device_id   = netbox_device.this.id
}
