
variable "values_file" {
}

resource "helm_release" "argocd" {
  name = "argocd"
  #repository       = "https://argoproj.github.io/argo-helm"
  #version          = "3.6.8"
  #chart            = "argo-cd"

  #repository       = "https://nolte.github.io/argo-charts/"
  #chart            = "argo-cd"
  chart     = "../../../src/applications/argo-cd/deploy/chart"
  namespace = "argocd"
  timeout   = 900 # 15min
  #version          = "0.2.0"
  create_namespace = true
  values = [
    file("${path.module}/../../../src/applications/argo-cd/deploy/chart/values-kind-deployments.yaml")
  ]
} #