remote_state {
  backend = "s3"
  generate = {
    path      = "backend.gen.tf"
    if_exists = "overwrite_terragrunt"
  }
  disable_dependency_optimization = true
  disable_init = true
  config = {
    endpoint = get_env("AWS_S3_ENDPOINT", "http://minio.minio.svc")
    bucket = "terraform-state"
    key = "terraform.tfstate"
    region = "main"
    skip_credentials_validation = true
    skip_metadata_api_check = true
    skip_region_validation = true
    skip_bucket_versioning = true
    skip_bucket_ssencryption = true
    skip_bucket_root_access = true
    disable_aws_client_checksums = true
    force_path_style = true
    disable_bucket_update = true

    encrypt        = true
  }
}