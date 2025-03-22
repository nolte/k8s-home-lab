resource "netbox_custom_field" "test" {
  name             = "netboxOperatorRestorationHash"
  type             = "text"
  content_types    = ["ipam.ipaddress","ipam.iprange"]
  weight           = 100
}
