
include {
  path = "../../../../terraground-common/terraground.hcl"
}

inputs = {
  
  gitea_fqdn = "gitea.dev44-just-homestyle.duckdns.org"
  #keycloak_fqdn = dependency.keycloak.outputs.keycloak_fqdn
  #super_admins_group_id = dependency.keycloak.outputs.super_admins_group_id
}

locals {
  root_config = read_terragrunt_config("../../../../terraground-common/state-s3.hcl")
  provider_version = read_terragrunt_config("../../../../terraground-common/provider-versions.hcl")
}


generate "provider" {
  path      = "provider.gen.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "netbox" {
  request_timeout = 60
  skip_version_check = true
}
EOF
}

generate "versions" {
  path      = "versions.gen.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {
      required_providers {
        netbox = {
          source = "e-breuninger/netbox"
          version = "3.10.0"
        }
      }
    }
EOF
}
