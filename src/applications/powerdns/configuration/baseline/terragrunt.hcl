
include {
  path = "../../../../terraground-common/terraground.hcl"
}


remote_state {
  backend = local.root_config.remote_state.backend
  generate = local.root_config.remote_state.generate
  # disable_init = local.root_config.remote_state.disable_init
  config = merge(
    local.root_config.remote_state.config,
    {
      key = local.state_key,
      disable_bucket_update = true
    },
  )
}



locals {
  state_key = "powerdns/basement.tfstate"
  root_config = read_terragrunt_config("../../../../terraground-common/state-s3.hcl")

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
