
locals {
  provider_version = read_terragrunt_config("../../../terraground-common/provider-versions.hcl")
}


generate "provider" {
  path      = "provider.gen.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "proxmox" {

}

provider "pass" {
  # Configuration options
  store_dir = "~/.password-store"
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
        pass = {
          source = "digipost/pass"
          version = "1.7.1"
        }

        proxmox = {
          source = "bpg/proxmox"
          version = "${local.provider_version.inputs.proxmox}"
        }
      }
    }
EOF
}
