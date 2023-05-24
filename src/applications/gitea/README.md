# Gitea

<!--description-start-->
Personal Git Service see [gitea.io](https://gitea.io/en-us/).
<!--description-end-->

<!--header-start-->
**Deployment:** Helm, [gitea/helm-chart](https://gitea.com/gitea/helm-chart)   
**Terraform Provider:** [Lerentis/gitea](https://registry.terraform.io/providers/Lerentis/gitea/latest/docs)   
**Web**:  [gitea.io](https://gitea.io/en-us/) 
<!--header-end-->


**Admin Auth:**

<!--admin-password-start-->
```sh
vault kv get secrets-tf/services/gitea/users/admin
```
<!--admin-password-end-->

**Open HttpProxy if exists**
<!--httpproxies-start-->
```sh
browse \
  "https://$(kubectl -n gitea get httpproxies.projectcontour.io http-proxy -ojson | jq '.spec.virtualhost.fqdn' -r)"
```
<!--httpproxies-end-->

**Currently Problems with OIDC and Usergroups,** look [#23794](https://github.com/go-gitea/gitea/issues/23794) 

<!--links-start-->
* [gitea.io](https://gitea.io/en-us/) 
* [terraform provider](https://registry.terraform.io/providers/malarinv/gitea/latest/docs)
<!--links-end-->