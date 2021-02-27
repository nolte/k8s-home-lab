remote_state {
  backend = "s3"
  generate = {
    path      = "backend.gen.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    endpoint = get_env("AWS_S3_ENDPOINT", "http://minio.minio.svc")
    bucket = "terraform-state"
    key = "terraform.tfstate"
    region = "main"
    skip_credentials_validation = true
    skip_metadata_api_check = true
    skip_region_validation = true
    force_path_style = true
  }
}