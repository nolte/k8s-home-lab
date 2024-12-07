
locals {
  provider_version = read_terragrunt_config("../../../../terraground-common/provider-versions.hcl")
}


generate "provider" {
  path      = "provider.gen.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF

provider "kubernetes" {
}

provider "pass" {
  refresh_store = "false"
}
EOF
}

generate "versions" {
  path      = "versions.gen.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {
      required_providers {
        kubernetes = {
          source  = "hashicorp/kubernetes"
          version = "2.31.0"
        }
        pass = {
          source = "digipost/pass"
          version = "1.7.1"
        }  
      }
    }
EOF
}
