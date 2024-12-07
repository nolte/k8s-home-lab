
variable "path_wifi_ssid" {
  default = "network/wifi/ssid"
}

variable "path_wifi_password" {
  default = "network/wifi/password"
}
data "pass_password" "wifi_password" {
  path = var.path_wifi_password
}

data "pass_password" "wifi_ssid" {
  path = var.path_wifi_ssid
}


# variable "path_id_rsa" {
#   default = "internet/project/homeassistant/deploymentkey/id_rsa"
# }

# data "pass_password" "path_id_rsa" {
#   path     = var.path_id_rsa
# }


# locals {
#   id_rsa_pub = data.pass_password.id_rsa_pub.password
#   id_rsa = data.pass_password.path_id_rsa.password
# }

# variable "known_hosts" {

# }

data "kubernetes_service" "mosquitto" {
  metadata {
    name      = "mosquitto"
    namespace = "mosquitto"
  }
}

resource "kubernetes_secret" "esphome-config" {
  metadata {
    name      = "esphome-config"
    namespace = "esphome"
  }

  data = {
    WIFI_DOMAIN            = ".fritz.box"
    WIFI_SSID              = data.pass_password.wifi_ssid.password
    WIFI_PASSWORD          = data.pass_password.wifi_password.password
    WIFI_FALLBACK_PASSWORD = data.pass_password.wifi_password.password
    MQTT_ENDPOINT          = data.kubernetes_service.mosquitto.status.0.load_balancer.0.ingress.0.ip
    MQTT_PORT              = "1883"
    MQTT_USERNAME          = "esphome"
    MQTT_PASSWORD          = "notset"
  }
}