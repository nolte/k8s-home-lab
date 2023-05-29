

locals {
  STATE_NAMESPACE="vault"
  root_config = read_terragrunt_config("../../../../terraground-common/state-kubernetes.hcl")
}

remote_state {
  backend = local.root_config.remote_state.backend
  generate = local.root_config.remote_state.generate
  config = merge(
    local.root_config.remote_state.config,
    {
      namespace  = local.STATE_NAMESPACE
    },
  )
}

#inputs = {
# vpc_id = dependency.vpc.outputs.vpc_id
#}
