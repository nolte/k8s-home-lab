


locals {
  STATE_NAMESPACE="influxdb"

  root_config = read_terragrunt_config("../../../../terraground-common/state-kubernetes.hcl")
  provider_version = read_terragrunt_config("../../../../terraground-common/provider-versions.hcl")
}

remote_state {
  backend = local.root_config.remote_state.backend
  generate = local.root_config.remote_state.generate
  config = merge(
    local.root_config.remote_state.config,
    {
      namespace  = local.STATE_NAMESPACE
    },
  )
}

generate "provider" {
  path      = "provider.gen.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "influxdb" {
}
EOF
}

generate "versions" {
  path      = "versions.gen.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {
      required_providers {
        influxdb = {
          source = "geronimo-iia/influxdb"

          version = "1.7.0"
        }
      }
    }
EOF
}
