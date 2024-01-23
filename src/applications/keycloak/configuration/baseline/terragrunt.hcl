
include {
  path = "../../../../terraground-common/terraground.hcl"
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
      key = "keycloak.tfstate",
      disable_bucket_update = true
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
