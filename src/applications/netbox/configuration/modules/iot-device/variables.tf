variable "device_type_id" {
  type = number

}

variable "role_id" {
  type = number

}
variable "site_id" {
  type = number

}


variable "name" {
  type = string

}

variable "primary_ip" {
  type = string

}
variable "tags" {
  type = list(string)
}


variable "status" {
  type    = string
  default = "active"
}

variable "platform_id" {
  type = number
}

variable "additional_services" {
  type = map(any)

}

variable "esphome_config" {
  default = null

}
variable "netbox_device_power_port_type" {
  default = "usb-c"
}
variable "esphome_repo" {
  default = "https://github.com/nolte/esphome-configs.git"
}