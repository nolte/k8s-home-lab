
include {
  path = "../../../../terraground-common/terraground.hcl"
}


locals {
  root_config = read_terragrunt_config("../../../../terraground-common/state-s3.hcl")
}

remote_state {
  backend = local.root_config.remote_state.backend
  generate = local.root_config.remote_state.generate
  config = merge(
    local.root_config.remote_state.config,
    {
      key = "keycloak-user-permission.tfstate"
    },
  )
}


dependency "keycloak" {
  config_path = "../baseline"
}


dependency "argocd" {
  config_path = "../../../argo-cd/configuration/fineconf"
}

dependency "vault" {
  config_path = "../../../vault/configuration/fineconf"
}



inputs = {
  realm_id = dependency.keycloak.outputs.realm_id
  super_admins_group_id = dependency.keycloak.outputs.super_admins_group_id
  
  argocd_super_admins_group_id = dependency.argocd.outputs.super_admins_group_id
  argocd_reader_role_id = dependency.argocd.outputs.reader_role_id
  argocd_management_role_id = dependency.argocd.outputs.management_role_id

  vault_super_admins_group_id = dependency.vault.outputs.super_admins_group_id
  vault_reader_role_id = dependency.vault.outputs.reader_role_id
  vault_management_role_id = dependency.vault.outputs.management_role_id

}


generate "provider" {
  path      = "provider.gen.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "keycloak" {
  client_id     = "admin-cli"
}
EOF
}

generate "versions" {
  path      = "versions.gen.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {      
      required_providers {
        keycloak = {
          source = "mrparkers/keycloak"
          version = "3.3.0"
        }
      }
    }
EOF
}