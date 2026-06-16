# Infrastructure Specification

This document describes the current physical and virtual infrastructure of the HomeLab.

## Proxmox Hosts

| Host | Hardware | Role | Notes |
|------|----------|------|-------|
| `pve` | GEEKOM GT1 Mega (Intel Core Ultra 9-185H, 32 GB DDR5, 2 TB SSD) | Primary Proxmox node | Hosts production cluster VMs, always running |
| `pve-02` | Intel NUC (x86, 8 GB RAM) | Secondary Proxmox node | Hosts dev cluster VMs, optional — not permanently running |

**Network Bridge:** `vmbr0`
**Storage Backend:** `local-lvm` (LVM-based)
**Router:** Fritz!Box at `192.168.178.1`

## Kubernetes Clusters

### talos-home-lab (Production)

Cluster name: `smart-home-02`

| Property | Value |
|----------|-------|
| Talos Version | v1.9.5 |
| Kubernetes Version | v1.31.1 |
| Endpoint | 192.168.178.130 |
| Subnet | 192.168.178.128/28 |
| CNI | Cilium |
| Ingress | Project Contour |
| Load Balancer | MetalLB |
| Scheduling on Control Planes | enabled |

#### Nodes

| Node | Role | Proxmox Host | VM ID | CPU | RAM | Disk | IP | USB Devices |
|------|------|--------------|-------|-----|-----|------|----|-------------|
| ctrl-00 | Control Plane | pve | 800 | 20 cores | 24 GB | 40 GB | 192.168.178.130 | SONOFF Zigbee 3.0 USB Dongle Plus V2 (`1a86:55d4`) |

Node Labels:

- `zigbee.homelab.local/present: true` (ctrl-00)

!!! info "Planned but inactive nodes"
    The Terraform config contains commented-out definitions for additional nodes:

    - **ctrl-01** (euclid): 4 CPU, 4 GB RAM, VM ID 801
    - **ctrl-02** (cantor): 4 CPU, 4 GB RAM, VM ID 802
    - **work-00** (abel): 8 CPU, 4 GB RAM, VM ID 810 (with iGPU passthrough)

---

### talos-home-lab-dev (Development)

Cluster name: `smart-home-dev`

| Property | Value |
|----------|-------|
| Talos Version | v1.9.5 |
| Endpoint | dynamic (from NetBox) |
| Subnet | 192.168.178.160/28 |

#### Nodes

| Node | Role | Proxmox Host | VM ID | CPU | RAM | Disk | Type |
|------|------|--------------|-------|-----|-----|------|------|
| ctrl-00 | Control Plane | pve-02 | 801 | 2 cores | 4 GB | 10 GB | Virtual |
| node-00 | Worker | - | - | - | - | - | Bare Metal (Raspberry Pi v3) |

---

### Kind Clusters (Local Development)

| Cluster | Purpose |
|---------|---------|
| kind-local-dev | General local development |
| kind-local-llm | Local LLM testing |
| dev-kind-powerdns | PowerDNS development |
| testing-e2e-ingress | E2E ingress testing |

## Cluster Deployment — talos-home-lab

The production cluster uses a multi-stage bootstrap process orchestrated by ArgoCD and Argo Workflows.

### Bootstrap Sequence

A seed job (`src/clusters/talos-home-lab/argocd/seed.yaml`) triggers the `bootstrap-cluster` workflow as a PostSync hook. The workflow progresses through 5 sequential stages, each waiting for all applications to be synced and healthy before advancing:

| Stage | Bundle | Applications |
|-------|--------|--------------|
| 0 | `00-bootstrapping-minimal` | argo-cd, argo-workflows, management-workflows, monitoring, argo-events |
| 1 | `05-bootstrapping-ingress` | + project-contour, cert-manager |
| 2 | `10-bootstrapping-utils` | + namespace-configuration-operator, stakater-forecastle, stakater-reloader, tf-operator, external-secrets |
| 3 | `20-baseline-services` | + vault, vault-sidecar-injector, minio |
| 4 | `25-baseline-services` | + keycloak, powerdns, external-dns, velero |

Each stage includes all applications from previous stages (cumulative bundles).

### Cluster-Specific Applications

Deployed directly from the cluster kustomization alongside the bootstrap stages:

| Category | Applications |
|----------|--------------|
| Infrastructure | cert-manager-webhook-duckdns, cert-wildcard, metallb, external-dns, proxmox-csi-plugin |
| Smart Home | pihole, mosquitto, esphome, home-assistant, influxdb, zigbee2mqtt |
| Utilities | grocy, flathunter, kamerplanter |
| Media | music-assistant |
| AI | ollama |

### Service Exposure

All externally accessible services are exposed via HTTPProxy (Project Contour) under the domain `just-a-lab.duckdns.org`:

| Service | FQDN |
|---------|------|
| Home Assistant | `home-assistant.just-a-lab.duckdns.org` |
| ESPHome | `esphome.just-a-lab.duckdns.org` |
| Pi-hole | `pihole.just-a-lab.duckdns.org` |
| Grocy | `grocy.just-a-lab.duckdns.org` |
| Kamerplanter | `kamerplanter.just-a-lab.duckdns.org` |
| Music Assistant | `music.just-a-lab.duckdns.org` |
| Ollama | `ollama.just-a-lab.duckdns.org` |

DNS records are managed by external-dns using Pi-hole as provider (API v6).

---

## VM Configuration Defaults

All Talos VMs on Proxmox share these defaults (defined in the `proxmox-talos` Terraform module):

| Property | Value |
|----------|-------|
| Machine Type | q35 |
| BIOS | seabios |
| SCSI Hardware | virtio-scsi-single |
| CPU Type | host (passthrough) |
| Disk Interface | virtio0 |
| Disk Format | raw |
| Disk Cache | writethrough |
| Disk Discard | on (TRIM) |
| Network | virtio on vmbr0 |
| Install Disk (Talos) | /dev/vdb |
| QEMU Guest Agent | enabled |

## Talos System Extensions

### x86 Nodes (Proxmox VMs)

- `siderolabs/i915-ucode`
- `siderolabs/intel-ucode`
- `siderolabs/qemu-guest-agent`

### Raspberry Pi Nodes

- `siderolabs/util-linux-tools`
- `siderolabs/iscsi-tools`
- Image Overlay: `siderolabs/sbc-raspberrypi` (rpi_generic)

## DNS Configuration

| Nameserver | Usage |
|------------|-------|
| 192.168.178.1 | Local (Fritz!Box) |
| 1.1.1.1 | Cloudflare |
| 8.8.8.8 | Google |

## Proxmox Service Accounts

| User | Purpose | Privileges |
|------|---------|------------|
| `root@pam` (token: tk1) | CI/CD automation | Full |
| `kubernetes-csi@pve` (token: csi) | Proxmox CSI Plugin | VM.Audit, VM.Config.Disk, Datastore.Allocate, Datastore.AllocateSpace, Datastore.Audit |

## Terraform Providers

| Provider | Version | Source |
|----------|---------|--------|
| Proxmox | latest | bpg/proxmox |
| Talos | 0.6.1 | siderolabs/talos |
| Kubernetes | 2.31.0 | hashicorp/kubernetes |
| Pass | 1.7.1 | digipost/pass |
| RestAPI | 1.20.0 | Mastercard/restapi |
| NetBox | 3.10.0 | e-breuninger/netbox |
