
include {
  path = "../../../../terraground-common/terraground.hcl"
}

locals {
  state_key = "powerdns/baseline.tfstate" 
  backend_config = read_terragrunt_config("../../../../terraground-common/state-s3-generate.hcl")
}

generate = local.backend_config.generate

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
