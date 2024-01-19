
generate "provider_basement" {
  path      = "provider-basements.gen.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF

provider "vault" {

}
EOF
}
