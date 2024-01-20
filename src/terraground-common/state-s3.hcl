

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.gen.tf"
    if_exists = "overwrite_terragrunt"
  }
  disable_dependency_optimization = true
  disable_init = true
  config = {
    endpoints = {
      s3 = get_env("AWS_ENDPOINT_URL_S3", "http://minio.minio.svc")
    }
    bucket = "terraform-state"
    disable_aws_client_checksums = true
    disable_bucket_update = true
    key = "terraform.tfstate"
    region = "main"
    skip_bucket_root_access = true
    skip_bucket_ssencryption = true
    skip_bucket_versioning = true
    skip_credentials_validation = true
    skip_metadata_api_check = true
    skip_region_validation = true
    skip_requesting_account_id = true
    use_path_style = true

    # encrypt        = true
  }
}
