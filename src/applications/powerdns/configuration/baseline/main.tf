variable "dns_zonename" {
  default = "smart-home.k8sservices.local"
}

locals {
  ZONE_NAME = format("%s.", var.dns_zonename)
}

resource "powerdns_zone" "this" {
  name = local.ZONE_NAME
  kind = "Native"
}

resource "powerdns_zone" "duckdns_local" {
  name = "dev44-just-homestyle.duckdns.org."
  kind = "Native"
}


#resource "powerdns_record" "foobar" {
#  zone    = "example.com."
#  name    = "www.example.com."
#  type    = "A"
#  ttl     = 300
#  records = ["192.168.0.11"]
#}
