
output "realm_id" {
  value = keycloak_realm.realm.id
}

output "keycloak_fqdn" {
  value = "keycloak.dev44-just-homestyle.duckdns.org"
}


output "super_admins_group_id" {
  value = keycloak_group.super_admins.id
}
