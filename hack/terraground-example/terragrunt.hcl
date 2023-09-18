remote_state {
  backend = "s3"
  generate = {
    path      = "backend.gen.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket = "terraform-state"
    endpoint = get_env("AWS_S3_ENDPOINT")
    region = "main"
    key    = "basement/${path_relative_to_include()}/terraform.tfstate"
    skip_credentials_validation = true
    skip_metadata_api_check = true
    skip_region_validation = true
    force_path_style = true
  }
}
