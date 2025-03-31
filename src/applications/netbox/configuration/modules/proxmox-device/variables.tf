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
  type = string
  default = "active"
}

variable "platform_id" {
  type = number
}

variable "additional_services" {
    type = map
    default = null
  
}

variable "esphome_config" {
  default = null
  
}

variable "description" {
  default = null
  
}
variable "esphome_repo" {
  default = "https://github.com/nolte/esphome-configs.git"

  
}

variable "cluster_id" {
  default = null
  
}