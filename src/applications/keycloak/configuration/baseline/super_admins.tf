
resource "keycloak_group" "super_admins" {
  realm_id = keycloak_realm.realm.id
  name     = "platform-super-users"
}

#resource "keycloak_group_memberships" "group_members" {
#    realm_id = keycloak_realm.realm.id
#    group_id = keycloak_group.super_admins.id
#
#    members  = [
#        keycloak_user.user_alice.username
#    ]
#}

resource "keycloak_role" "super_admins" {
  realm_id    = keycloak_realm.realm.id
  name        = "super-admin-role"
  description = "Super Admin Role"
}

resource "keycloak_group_roles" "group_roles" {
  realm_id   = keycloak_realm.realm.id
  group_id   = keycloak_group.super_admins.id
  exhaustive = false

  role_ids = [
    keycloak_role.super_admins.id,
  ]
}
