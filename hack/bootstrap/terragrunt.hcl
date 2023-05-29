
generate "versions" {
  path      = "versions_override.gen.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "kubernetes" {
    secret_suffix    = "state-${path_relative_to_include()}"
    load_config_file = true
  }
  required_providers {
    argocd = {
      source = "oboukili/argocd"
      version = "1.2.1"
    }
  }
}
EOF
}
