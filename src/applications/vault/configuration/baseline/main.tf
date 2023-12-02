terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.24.0"
    }
  }
}

provider "kubernetes" {
  # Configuration options
}


variable "secrets_engine_name" {
  default = "secrets-tf"
}

module "secrets_engine" {
  #source = "github.com/makezbs/terraform-vault-secrets-engine.git"
  source = "git::https://github.com/nolte/terraform-vault-secrets-engine.git?ref=feature/upper-tf-version"


  path = var.secrets_engine_name
  type = "kv"
  options = {
    version = 2
  }
}



resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}


# data "kubernetes_service_account" "vault" {
#   metadata {
#     name      = "vault"
#     namespace = "vault"
#   }
# }

data "kubernetes_secret" "vault" {
  metadata {
    name      = "vault-k8s-auth-secret"
    namespace = "vault"
  }
}



#resource "kubernetes_cluster_role_binding" "example" {
#  metadata {
#    name = "role-tokenreview-binding"
#  }
#  role_ref {
#    api_group = "rbac.authorization.k8s.io"
#    kind      = "ClusterRole"
#    name      = "system:auth-delegator"
#  }
#
#  subject {
#    kind      = "ServiceAccount"
#    name      = "vault"
#    namespace = "vault"
#  }
#  subject {
#    kind      = "ServiceAccount"
#    name      = "external-secrets"
#    namespace = "external-secrets"
#  }
#}

resource "vault_kubernetes_auth_backend_config" "this" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = "https://10.96.0.1:443"
  kubernetes_ca_cert     = data.kubernetes_secret.vault.data["ca.crt"]
  token_reviewer_jwt     = data.kubernetes_secret.vault.data["token"]
  disable_iss_validation = "true"
}

resource "vault_kubernetes_auth_backend_role" "this" {
  backend   = vault_auth_backend.kubernetes.path
  role_name = "external-secrets"
  bound_service_account_names = [
    "external-secrets",
    "tf-keycloak",
    "talend-vault-sidecar-injector",
    "argo-workflows-executer",
  ]
  bound_service_account_namespaces = [
    "external-secrets",
    "minio",
    "keycloak",
    "vault",
    "external-dns",
    "cert-manager",
    "gitea",
  ]
  token_ttl = 3600
  token_policies = [
    "default",
    vault_policy.this.name,
    vault_policy.minio_external_secrets.name,
    vault_policy.external_dns_external_secrets.name,
    vault_policy.cert_manager_external_secrets.name,
    vault_policy.gitea_external_secrets.name,
  ]
  # audience                         = "vault"
}

resource "vault_policy" "this" {
  name = "dev-team"

  policy = <<EOT
path "${module.secrets_engine.path}/services/IdentityAccessManagement/users/admin" {
   capabilities = ["create", "read", "update", "delete", "list"]
}
path "${module.secrets_engine.path}/data/services/IdentityAccessManagement/users/admin" {
   capabilities = ["create", "read", "update", "delete", "list"]
}

path "${module.secrets_engine.path}/data/services/*" {
   capabilities = ["create", "read", "update", "delete", "list"]
}

path "${module.secrets_engine.path}/data/third-party-services/*" {
   capabilities = ["create", "read", "update", "delete", "list"]
}

EOT
}

resource "random_password" "password" {
  length           = 26
  special          = true
  override_special = "_%@"
}

resource "vault_generic_secret" "powerdns" {
  path = format("%s/services/dns/users/root", module.secrets_engine.path)

  data_json = <<EOT
{
  "token":   "supersecretpw"
}
EOT
}

resource "vault_generic_secret" "example" {
  path = format("%s/services/IdentityAccessManagement/users/admin", module.secrets_engine.path)

  data_json = <<EOT
{
  "username":   "admin",
  "password":   "${random_password.password.result}"
}
EOT
}


#resource "random_password" "dns_root_token" {
#  length           = 64
#  special          = true
#  override_special = "_%@"
#}
#
#
#resource "vault_generic_secret" "dns_root_token" {
#  path = format("%s/services/dns/users/root",var.secrets_engine_name)
#
#  data_json = <<EOT
#{
#  "token":   "${ random_password.dns_root_token.result }"
#}
#EOT
#}
#
#terraform {
#  required_version = "0.14.9"
#}



#provider "kubernetes" {
#  config_path    = "~/.kube/config"
#  config_context = "kind-production"
#}
