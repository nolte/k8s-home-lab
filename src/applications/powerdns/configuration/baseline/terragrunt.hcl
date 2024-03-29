
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
      key = "test.tfstate"
    },
  )
}


generate "provider" {
  path      = "provider.gen.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "powerdns" {
}

EOF
}

generate "versions" {
  path      = "versions.gen.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {
      required_providers {
        powerdns = {
          source  = "pan-net/powerdns"
          version = "1.4.1"
        }
      }
    }
EOF
}
