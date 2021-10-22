
include {
  path = "../../../../terraground-common/terraground.hcl"
}

dependency "vault" {
  config_path = "../../../vault/configuration/baseline"
}

dependency "keycloak" {
  config_path = "../../../keycloak/configuration/baseline"
}

inputs = {
  realm_id = dependency.keycloak.outputs.realm_id
  vault_secrets_engine_path = dependency.vault.outputs.secrets_engine_path
  harbor_fqdn = "harbor.dev44-just-homestyle.duckdns.org"
  keycloak_fqdn = dependency.keycloak.outputs.keycloak_fqdn
  super_admins_group_id = dependency.keycloak.outputs.super_admins_group_id
}

locals {
  root_config = read_terragrunt_config("../../../../terraground-common/state-s3.hcl")
  provider_version = read_terragrunt_config("../../../../terraground-common/provider-versions.hcl") 
}

remote_state {
  backend = local.root_config.remote_state.backend
  generate = local.root_config.remote_state.generate
  config = merge(
    local.root_config.remote_state.config,
    {
      key = "harbor-baseline.tfstate"
    },
  )
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
          version = "${local.provider_version.inputs.keycloak}"
        }
      }
    }
EOF
}