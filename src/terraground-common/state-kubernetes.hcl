remote_state {
  backend = "kubernetes"
  generate = {
    path      = "backend.gen.tf"
    if_exists = "overwrite_terragrunt"
    load_config_file = true
  }
  config = {
    secret_suffix       = "tf-state"
    namespace           = "_STATE_NAMESPACE_"
  }
}
