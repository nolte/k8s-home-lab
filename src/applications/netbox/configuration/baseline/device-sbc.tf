
resource "netbox_manufacturer" "raspberrypi" {
  name = "RaspberryPi"
}


resource "netbox_device_type" "raspberrypi_v3" {
  model           = "rpi-v3"
  manufacturer_id = netbox_manufacturer.raspberrypi.id
}

resource "netbox_device_type" "raspberrypi_v4" {
  model           = "rpi-v4"
  manufacturer_id = netbox_manufacturer.raspberrypi.id
}