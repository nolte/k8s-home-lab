variable "redirect_uris" {
  type = list(string)
}

variable "realm_id" {
  type = string
}

variable "client_id" {
  type = string
}

variable "name" {
  type    = string
  default = ""
}

variable "root_url" {
  type    = string
  default = null
}

variable "base_url" {
  type    = string
  default = null
}


variable "admin_url" {
  type    = string
  default = null
}


variable "web_origins" {
  type    = list(string)
  default = []
}

variable "login_theme" {
  type    = string
  default = "keycloak"
}