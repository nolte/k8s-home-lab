
include {
  path = "../../../../terraground-common/terraground.hcl"
}

locals {
  STATE_NAMESPACE="minio"
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
provider "minio" {
  minio_region = "us-east-1"
}

EOF
}

generate "versions" {
  path      = "versions.gen.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {
      required_providers {
        minio = {
          source  = "aminueza/minio"
          version = "${local.provider_version.inputs.minio}"
        }
      }
    }
EOF
}