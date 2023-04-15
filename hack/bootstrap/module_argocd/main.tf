
resource "helm_release" "argocd" {
  name      = "argocd"
  chart     = "../../../src/applications/argo-cd/deploy/chart"
  namespace = "argocd"
  # wait maximal 15 mins
  timeout           = 900
  create_namespace  = true
  dependency_update = true
  values = [
    var.values_file != "" ? file(join("/", [path.module, var.values_file])) : ""
  ]
}

resource "helm_release" "argocd_apps" {
  depends_on = [
    helm_release.argocd
  ]
  name = "argocd-apps"
  #repository = "https://charts.bitnami.com/bitnami"
  #name = "argocd"
  chart             = "../../../src/applications/argo-cd/deploy/chart-apps"
  namespace         = "argocd"
  dependency_update = true
  # wait maximal 15 mins
  timeout          = 900
  create_namespace = true
  values = [
    var.values_file != "" ? file(join("/", [path.module, var.values_file])) : ""
  ]
}


