module "argocd" {
  source = "../module_argocd"

  values_file = var.values_file
}

variable "values_file" {
}
