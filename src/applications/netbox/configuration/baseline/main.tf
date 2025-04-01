locals {
  iot_devices = {
    "gosund-sp111-01" = {
      primary_ip     = "192.168.178.41/32"
      device_type_id = netbox_device_type.gosund_power_switch.id
    }
    "gosund-sp111-03" = {
      primary_ip     = "192.168.178.43/32"
      device_type_id = netbox_device_type.gosund_power_switch.id
    }
    "gosund-sp111-04" = {
      primary_ip     = "192.168.178.45/32"
      device_type_id = netbox_device_type.gosund_power_switch.id
    }
    "gosund-sp111-05" = {
      primary_ip     = "192.168.178.125/32"
      device_type_id = netbox_device_type.gosund_power_switch.id
    }
    "gosund-sp111-06" = {
      primary_ip     = "192.168.178.47/32"
      device_type_id = netbox_device_type.gosund_power_switch.id
    }
    "nous-a1t-01" = {
      primary_ip     = "192.168.178.53/32"
      device_type_id = netbox_device_type.nous_power_switch.id
    }
    "nous-a1t-02" = {
      primary_ip     = "192.168.178.71/32"
      device_type_id = netbox_device_type.nous_power_switch.id
    }
    "nous-a1t-04" = {
      primary_ip     = "192.168.178.74/32"
      device_type_id = netbox_device_type.nous_power_switch.id
    }
    "nous-a1t-05" = {
      primary_ip     = "192.168.178.76/32"
      device_type_id = netbox_device_type.nous_power_switch.id
    }
    "nous-a1t-06" = {
      primary_ip     = "192.168.178.77/32"
      device_type_id = netbox_device_type.nous_power_switch.id
    }
    "nous-a1t-08" = {
      primary_ip     = "192.168.178.110/32"
      device_type_id = netbox_device_type.nous_power_switch.id
    }
    "cam-01" = {
      primary_ip          = "192.168.178.39/32"
      device_type_id      = netbox_device_type.diy_espcam.id
      additional_services = local.webcamservices
    }
    "cam-02" = {
      primary_ip          = "192.168.178.40/32"
      device_type_id      = netbox_device_type.diy_espcam.id
      additional_services = local.webcamservices
    }
    "cam-04" = {
      primary_ip          = "192.168.178.67/32"
      device_type_id      = netbox_device_type.diy_espcam.id
      additional_services = local.webcamservices
    }
    "cam-04" = {
      primary_ip          = "192.168.178.67/32"
      device_type_id      = netbox_device_type.diy_espcam.id
      additional_services = local.webcamservices
    }
    "box-fementation-01" = {
      primary_ip     = "192.168.178.109/32"
      device_type_id = netbox_device_type.diy_esp32.id
      #additional_services = local.webcamservices
    }
  }
}

locals {
  webcamservices = {
    cam = {
      ports       = [80]
      description = ""
    }
  }
}


module "iot" {
  for_each = local.iot_devices

  source         = "../modules/iot-device"
  device_type_id = each.value.device_type_id
  role_id        = netbox_device_role.iot.id
  site_id        = netbox_site.prem.id
  name           = each.key
  primary_ip     = each.value.primary_ip

  platform_id = netbox_platform.esphome.id
  tags = [
    netbox_tag.gardening.name,
    netbox_tag.smart_home.name
  ]

  additional_services = try(each.value.additional_services, {})

}
