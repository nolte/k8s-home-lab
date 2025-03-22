# Netbox

<!--description-start-->
Use [netbox-community/netbox](https://github.com/netbox-community/netbox), for keep a overview for non k8s elements, like IoT devices.
<!--description-end-->

<!--header-start-->
**Deployment:** Helm, [netbox-community/netbox-chart/](https://github.com/netbox-community/netbox-chart/)  
**Terraform Provider:** [e-breuninger/terraform-provider-netbox](https://github.com/e-breuninger/terraform-provider-netbox)  
**Web**:  [netbox.readthedocs.io](https://netbox.readthedocs.io/en/stable/)
<!--header-end-->






**Admin Auth:**

<!--admin-password-start-->
```sh
kubectl -n netbox get secrets netbox-operator-app-superuser -ojson | jq '.data.api_token' -r | base64 -d
```
<!--admin-password-end-->

**Open HttpProxy if exists**
<!--httpproxies-start-->
```sh
browse \
  "https://$(kubectl -n gitea get httpproxies.projectcontour.io http-proxy -ojson | jq '.spec.virtualhost.fqdn' -r)"
```
<!--httpproxies-end-->

**Currently Problems with OIDC and user groups,** look [#23794](https://github.com/go-gitea/gitea/issues/23794)

<!--links-start-->
* [gitea.io](https://gitea.io/en-us/)
* [terraform provider](https://registry.terraform.io/providers/malarinv/gitea/latest/docs)
<!--links-end-->

## Terraform Usage

```
export NETBOX_SERVER_URL=http://localhost:8081
export NETBOX_API_TOKEN=$(kubectl -n netbox get secrets netbox-operator-app-superuser -ojson | jq '.data.api_token' -r | base64 -d)
```

## Ansible Usage

```sh
export NETBOX_API=http://localhost:8081
export NETBOX_TOKEN=$(kubectl -n netbox get secrets netbox-operator-app-superuser -ojson | jq '.data.api_token' -r | base64 -d)
```

```sh
export ANSIBLE_INVENTORY=/home/nolte/repos/github/argo-charts/src/applications/netbox/configuration/inventory/inventory.yaml

task esphome:run \
  DEVICE_FILE="$(jq -r '"\(.local_context_data[0].esphome.config) --device=\(.ansible_host)"' <<< $(ansible-inventory -i $ANSIBLE_INVENTORY --list | jq '._meta.hostvars["nous-a1t-08"]' -r))"
```

## Prometheus Service Discovery

[FlxPeters/netbox-plugin-prometheus-sd](https://github.com/FlxPeters/netbox-plugin-prometheus-sd)