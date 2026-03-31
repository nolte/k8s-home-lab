<!-- portfolio: excluded — personal home-lab Kubernetes cluster, infrastructure rather than a portfolio capability -->

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Kubernetes homelab infrastructure-as-code repository using **GitOps** principles. Manages multiple K8s clusters with different service sets ("screenplays") using **ArgoCD** for deployment and **Argo Workflows** for process automation. The repo is named `k8s-home-lab` on GitHub (`nolte/k8s-home-lab`).

## Architecture

### Core Pattern
Applications are defined as Kustomize overlays in `src/applications/`, grouped into **bundles** (`src/bundles/`), and deployed to **clusters** (`src/clusters/`). ArgoCD watches this repo and reconciles desired state.

- **Applications** (`src/applications/<app>/`): Each app has a `deploy/` dir with ArgoCD Application manifests and Kustomize/Helm configs. Some apps also have `configuration/` dirs with Terraform/Terragrunt for provisioning.
- **Bundles** (`src/bundles/`): Curated sets of applications (e.g., `smart-home`, `devops-services`, `bootstrapping-*`). Bundles compose applications via Kustomize.
- **Clusters** (`src/clusters/`): Cluster-specific configs that reference bundles. Kind clusters for local dev, Talos for production.
- **Shared patches** (`src/kustomization-common/`): Reusable Kustomize patches applied across apps (deployment patches, ArgoCD project defaults).
- **Infrastructure** (`src/infrastructure/`): Terraform modules and Terragrunt configs for Proxmox/hardware provisioning.

### Deployment Flow
1. Kind cluster created locally → ArgoCD + Argo Workflows bootstrapped
2. Seed job (`src/seed/`) installs the initial ArgoCD Application
3. Argo Workflow "screenplay" triggers, deploying the selected bundle of apps
4. ArgoCD continuously syncs all managed applications from this repo

## Common Commands

All automation uses [Task](https://taskfile.dev/) (Go-task). Remote taskfile includes are pulled from `nolte/taskfiles`.

```bash
# Local cluster lifecycle
task platform:recreate-minimal      # Create Kind cluster + deploy minimal service set
task platform:recreate-devops-services  # Create Kind cluster + deploy devops service set
task platform:recreate              # Just recreate the Kind cluster with ArgoCD

# Service sets (on existing cluster)
task platform:serviceset-minimal
task platform:serviceset-devops-services

# ArgoCD
task argocd:login                   # Login to local ArgoCD

# Documentation
task mkdocs:start                   # Start MkDocs dev server

# Pre-commit / linting
task pre-commit:run                 # Run pre-commit hooks

# System tuning (needed for large clusters)
task platform:maxfs                 # Increase inotify limits
```

### Manual operations
```bash
# Apply kustomize manifests directly
kustomize build . --load-restrictor LoadRestrictionsNone | kubectl apply -f -

# ArgoCD port-forward
kubectl port-forward svc/argocd-server 8080:443 -n argocd
```

## CI/CD

GitHub Actions workflows (all use reusable workflows from `nolte/gh-plumbing`):
- `build-static-tests.yaml`: Pre-commit hooks, Trivy security scan, Chain-bench
- `tf-lint.yaml`: Terraform linting
- `automerge.yaml`: Auto-merge for Renovate PRs

Dependency updates are automated via **Renovate** (`renovate.json5`).

## Tool Versions

Managed via `.tool-versions` (asdf): Task, Helm, Terraform, Terragrunt, Python, Vault CLI, and others.

## Key Conventions

- Kustomize is the primary manifest management tool; Helm charts are wrapped via ArgoCD Helm sources
- `kustomization.yaml` files are everywhere (~111 across the repo) — this is by design
- Pre-commit hooks validate YAML (with `--unsafe` for templated files), fix trailing whitespace, and ensure EOF newlines
- Documentation uses MkDocs with Material theme; docs live in `docs/`
- Terraform state and caches (`.terraform/`, `.tfstate`, `.terragrunt-cache`) are gitignored
