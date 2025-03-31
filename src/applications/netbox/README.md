# Netbox

<!--description-start-->
Use [netbox-community/netbox](https://github.com/netbox-community/netbox), for keep a overview for non k8s elements, like IoT devices. So you will be have a API Based System for Management and Konfiguration Tasks.
<!--description-end-->

<!--header-start-->
**Deployment:** Helm, [netbox-community/netbox-chart/](https://github.com/netbox-community/netbox-chart/)  
**Terraform Provider:** [e-breuninger/terraform-provider-netbox](https://github.com/e-breuninger/terraform-provider-netbox)  
**Promehteus SD**: [FlxPeters/netbox-plugin-prometheus-sd](https://github.com/FlxPeters/netbox-plugin-prometheus-sd)   
**Web**: [netbox.readthedocs.io](https://netbox.readthedocs.io/en/stable/)   
**Ansible Inventory**: [docs.ansible.com](https://docs.ansible.com/ansible/latest/collections/netbox/netbox/nb_inventory_inventory.html)
<!--header-end-->


## Useful Commands

**Port Forward**
<!--port-forward-start-->
```sh
kubectl -n netbox port-forward svc/netbox-operator-app 8081:80
```
<!--port-forward-end-->


**Admin Auth:**

<!--admin-password-start-->
```sh
kubectl -n netbox get secrets netbox-operator-app-superuser -ojson | jq '.data.password' -r | base64 -d
```
<!--admin-password-end-->

**Open HttpProxy if exists**
<!--httpproxies-start-->
```sh
browse \
  "https://$(kubectl -n gitea get httpproxies.projectcontour.io http-proxy -ojson | jq '.spec.virtualhost.fqdn' -r)"
```
<!--httpproxies-end-->


```sh
kubectl create ns netbox

kubectl -n netbox create secret generic netbox-operator-app-superuser \
    --from-literal=api_token=$(uuidgen) \
    --from-literal=email='admin@example.com' \
    --from-literal=password="$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13; echo)" \
    --from-literal=username='admin'

kubectl -n netbox create secret generic netbox-operator-postgresql \
    --from-literal=postgres-password="$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13; echo)" \
    --from-literal=password="$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13; echo)" 
    
```

<!--links-start-->
* [FlxPeters/netbox-plugin-prometheus-sd](https://github.com/FlxPeters/netbox-plugin-prometheus-sd)
<!--links-end-->

## Terraform Usage

```sh
export NETBOX_SERVER_URL=http://localhost:8081
export NETBOX_API_TOKEN=$(kubectl -n netbox get secrets netbox-operator-app-superuser -ojson | jq '.data.api_token' -r | base64 -d)
```

```
terragrunt apply -parallelism 1 -auto-approve 
```

## Ansible Usage

```sh
source ~/.venvs/ansible/bin/activate
```


```sh
export NETBOX_API=http://localhost:8081
export NETBOX_TOKEN=$(kubectl -n netbox get secrets netbox-operator-app-superuser -ojson | jq '.data.api_token' -r | base64 -d)
```

```sh
export ANSIBLE_INVENTORY=$(pwd)/configuration/inventory/inventory.yaml

task esphome:run \
  DEVICE_FILE="$(jq -r '"\(.local_context_data[0].esphome.config) --device=\(.ansible_host)"' <<< $(ansible-inventory -i $ANSIBLE_INVENTORY --list | jq '._meta.hostvars["nous-a1t-08"]' -r))"
```



