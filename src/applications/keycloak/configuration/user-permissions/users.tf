

resource "keycloak_user" "user_alice" {
  realm_id = var.realm_id
  username = "alice"
  enabled  = true

  email      = "alice@domain.com"
  first_name = "Alice"
  last_name  = "Aliceberg"

  initial_password {
    value     = "alice"
    temporary = false
  }
}

resource "keycloak_group_memberships" "group_members" {
  realm_id = var.realm_id
  group_id = var.super_admins_group_id

  members = local.admin_users
}

locals {
  admin_users = [
    keycloak_user.user_alice.username
  ]
}

resource "keycloak_group_memberships" "argocd_admin_group_members" {
  realm_id = var.realm_id
  group_id = var.argocd_super_admins_group_id

  members = local.admin_users
}


resource "keycloak_group_memberships" "vault_admin_group_members" {
  realm_id = var.realm_id
  group_id = var.vault_super_admins_group_id

  members = local.admin_users
}


resource "keycloak_group_roles" "group_roles" {
  realm_id   = var.realm_id
  group_id   = var.super_admins_group_id
  exhaustive = false

  role_ids = [
    var.argocd_management_role_id,
    var.vault_management_role_id,
  ]
}


resource "keycloak_user" "user_bob" {
  realm_id = var.realm_id
  username = "bob"
  enabled  = true

  email      = "bob@domain.com"
  first_name = "Bob"
  last_name  = "Bobsen"

  initial_password {
    value     = "bob"
    temporary = false
  }
}
