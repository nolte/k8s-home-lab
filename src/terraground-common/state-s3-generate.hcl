


locals {
  state_key = "${basename(get_terragrunt_dir())}/basement.tfstate"
  endpoint = get_env("AWS_ENDPOINT_URL_S3", "http://minio.minio.svc")
}

generate "backend" {
  path      = "backend.gen.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  backend "s3" {
    bucket                      = "terraform-state"
    encrypt                     = false
    endpoints                   = {
      s3 = "${local.endpoint}"
    }
    key                         = "${local.state_key}"
    region                      = "main"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true
  }
}
EOF
}