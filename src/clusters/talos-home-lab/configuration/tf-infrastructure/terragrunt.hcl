
locals {
  provider_version = read_terragrunt_config("../../../../terraground-common/provider-versions.hcl")
}


generate "provider" {
  path      = "provider.gen.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "proxmox" {
#   endpoint = var.proxmox.endpoint
#   insecure = var.proxmox.insecure
# 
#   api_token = var.proxmox.api_token
#   ssh {
#     agent    = true
#     username = var.proxmox.username
#   }
}

provider "kubernetes" {
  host = module.talos.kube_config.kubernetes_client_configuration.host
  client_certificate = base64decode(module.talos.kube_config.kubernetes_client_configuration.client_certificate)
  client_key = base64decode(module.talos.kube_config.kubernetes_client_configuration.client_key)
  cluster_ca_certificate = base64decode(module.talos.kube_config.kubernetes_client_configuration.ca_certificate)
}

provider "restapi" {
  uri                  = get_env("PROXMOX_VE_ENDPOINT")
  insecure             = get_env("PROXMOX_VE_INSECURE")
  write_returns_object = true

  headers = {
    "Content-Type"  = "application/json"
    "Authorization" = "PVEAPIToken=get_env(\"PROXMOX_VE_API_TOKEN\")"
  }
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
        talos = {
          source  = "siderolabs/talos"
          version = "0.6.1"
        }
        kubernetes = {
          source  = "hashicorp/kubernetes"
          version = "2.31.0"
        }
        restapi = {
          source  = "Mastercard/restapi"
          version = "1.20.0"
        }        
      }
    }
EOF
}
