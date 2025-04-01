resource "netbox_user" "monitoring" {
  username  = "prometheus"
  password  = "Abcdefghijkl1"
  group_ids = [netbox_group.monitoring.id]
}

resource "netbox_token" "monitoring" {
  user_id       = netbox_user.monitoring.id
  key           = "0123456789012345678901234567890123456789"
  write_enabled = false
}

resource "netbox_permission" "monitoring" {
  name        = "monitoring"
  description = "my description"
  enabled     = true
  object_types = [
    "dcim.device",
    "ipam.ipaddress"
  ]
  actions = ["view"]
  users = [
    netbox_user.monitoring.id
  ]
  constraints = jsonencode([{
    "status" = "active"
  }])
}


resource "netbox_group" "monitoring" {
  name = "monitoring"
}
