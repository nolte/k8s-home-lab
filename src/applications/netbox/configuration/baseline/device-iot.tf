

resource "netbox_tag" "smart_home" {
  name      = "smart-home"
  slug      = "smart_home"
  color_hex = "ffeb3b"
}

resource "netbox_tag" "gardening" {
  name      = "gardening"
  color_hex = "8bc34a"
}

resource "netbox_device_role" "iot" {
  name        = "iot"
  description = "SmartHome iot device"
  color_hex   = "00bcd4"
  tags = [
    netbox_tag.gardening.name,
    netbox_tag.smart_home.name
  ]
}

resource "netbox_manufacturer" "diy" {
  name = "diy"
}

resource "netbox_device_type" "diy_espcam" {
  model           = "esp32cam"
  manufacturer_id = netbox_manufacturer.diy.id
}

resource "netbox_device_type" "diy_esp32" {
  model           = "esp32"
  manufacturer_id = netbox_manufacturer.diy.id
}

resource "netbox_manufacturer" "gosund" {
  name = "gosund"
}

resource "netbox_device_type" "gosund_power_switch" {
  model           = "sp111"
  manufacturer_id = netbox_manufacturer.gosund.id
}

resource "netbox_manufacturer" "nous" {
  name = "nous"
}

resource "netbox_device_type" "nous_power_switch" {
  model           = "a1t"
  manufacturer_id = netbox_manufacturer.nous.id
}


resource "netbox_platform" "esphome" {
  name = "esphome"
  # manufacturer_id = netbox_manufacturer.diy.id

}
