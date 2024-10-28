
locals {
  provider_version = read_terragrunt_config("../../terraground-common/provider-versions.hcl")
}


generate "provider" {
  path      = "provider.gen.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "proxmox" {
  insecure = true
}
EOF
}

generate "versions" {
  path      = "versions.gen.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {
      required_providers {
        proxmox = {
          source = "bpg/proxmox"
          version = "${local.provider_version.inputs.proxmox}"
        }
      }
    }
EOF
}
