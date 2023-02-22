# Applications

This subdirectory will give the Structure for all Used Application/Services, and the Configuration. This Applications will be used by different Service `../bundles`.

## Application Structure

| **Folder**      | **Description**                                                                                                                                                                                                                            |
|-----------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `configuration` | This Structure will be contains all required Scripts for Configure and Bootstrap the Service. Mostly use Terraform/Terragrount Scripts, executed as Post Deployment Hook with [Argo Workflow](https://argoproj.github.io/argo-workflows/). |
| `deploy`        | Subdirectory with Deployment Relevant Structures/Elements.                                                                                                                                                                                 |
| `deploy/argocd` | A [Kustomization](https://github.com/kubernetes-sigs/kustomize) Project for bring the the Application to a Cluster, used ArgoCD as Deployment Tool.                                                                                        |
| `workflows`     |                                                                                                                                                                                                                                            |
