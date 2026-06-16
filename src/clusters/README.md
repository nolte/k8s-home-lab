# Clusters

<!--intro-start-->
The Cluster structure are the Final configuration from the Seed Job and Required Scripts for handle the Required Infrastructure.

The **Scope**, from this Overlay Layer are Configure Ingress, Service Auth (oidc) and specific Deployments.  

<!--intro-end-->


## Cluster Structure

<!--structure-start-->
```
📁 ...
├─📁 ...
├─📁 clusters               # Structure for Managed Clusters
| ├─📁 cluster 1            # Cluster specific final configuration
| | ├─📁 configuration      # (optional) Scripts for Services and Infrastructure.
| | | ├─📁 tf-...           # (optional) Terraform for Prepare Infrastructure.
| | | └─📁 tf-...           # (optional) Scripts for Services and Infrastructure.
| | ├─📁 argocd             # (optional) Cluster Seed Folder
| | | └─📝 seed.yaml        # (optional) ArgoCD Application for automatic Deployments
| | ├─🎁 patch-XXX.yaml     # (optional) kustomize patch for specific settings
| | ├─🎁 patch-YYY.yaml     # (optional) more patch
| | ├─📦 kustomization.yaml # Seed Job Config with all Deployments from the Cluster
| | └─📝 README.md          # Cluster Description  
| └─📁 cluster ...          # ArgoCD manifests, required
└─📝 ...
```
<!--structure-end-->
