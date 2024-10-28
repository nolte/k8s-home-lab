resource "influxdb_database" "homeassistant" {
  name = "home-assistant"
}

# resource "influxdb_user" "paul" {
#     name = "paul"
#     password = "super-secret"
# 
#     grant {
#       database = "${influxdb_database.homeassistant.name}"
#       privilege = "WRITE"
#     }
# }
