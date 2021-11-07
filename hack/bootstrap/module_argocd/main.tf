
resource "helm_release" "argocd" {
  name = "argocd"
  chart     = "../../../src/applications/argo-cd/deploy/chart"
  namespace = "argocd"
  # wait maximal 15 mins
  timeout   = 900 
  create_namespace = true
  values = [
    var.values_file != "" ? file(join("/",[path.module,var.values_file])) : ""
  ]
} 