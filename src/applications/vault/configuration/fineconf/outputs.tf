output "management_role_id" {
  value = keycloak_role.management_role.id
}

output "reader_role_id" {
  value = keycloak_role.reader_role.id
}

output "client_id" {
  value = module.vault.this.id
}

output "super_admins_group_id" {
  value = keycloak_group.super_admins.id
}
