# Infrastructure Base

Will be create a [talos](https://www.talos.dev/v1.8/talos-guides/install/virtualized-platforms/proxmox/) cluster, on a [proxmox](https://www.proxmox.com/en/) based Environment.

Used the [bpg/proxmox](https://registry.terraform.io/providers/bpg/proxmox) Terraform Provider, for configure the VM, and required Volumes.

## Required Config

```sh
export PROXMOX_VE_ENDPOINT="$(gopass private/services/proxmox/endpoint)"
export PROXMOX_VE_USERNAME="$(gopass private/services/proxmox/username)@pam"
export PROXMOX_VE_PASSWORD="$(gopass private/services/proxmox/password)"
```


talosctl apply-config --insecure --nodes $CONTROL_PLANE_IP --file ./clusterconfig/talosctl -n $CONTROL_PLANE_IP --talosconfig ./clusterconfig/talosconfig bootstrap

