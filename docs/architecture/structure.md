# Structure

| **Folder**                 | **Description**                                                              |
|----------------------------|------------------------------------------------------------------------------|
| `docs`                     | Folder for [mkdocs](https://www.mkdocs.org/) based documentation.            |
| `hack`                     | Useful scripts for local Cluster Bootstrapping.                              |
| `src/applications`         | Preconfigured ArgoCD Applications, for deploy different type of Services.    |
| `src/bundles`              | Will Be combine a different set of Services, into one "Product".             |
| `src/clusters`             | Represent the Different Clusters with the different Service Set for each one. |
| `src/kustomization-common` | Reusable Kustomize overlays, like Namespace Handling etc.                   |
| `src/terraground-common`   | Shared Terragrunt Configs, like state-file Handling or Module Versions.      |
| `src/talos-configs`        | The [Talos](https://www.talos.dev/) K8S Cluster configs.                     |

For more Information take a look into the `README.md` inside the subfolder like [/src/applications](./src/applications/README.md).


## Docs With Docker


```sh
docker run \
    -ti --rm \
    --name mkdocs \
    -p 9000:9000 \
    -e "ADD_MODULES=mkdocs-include-markdown-plugin pymdown-extensions mkdocs-material" \
    -e "LIVE_RELOAD_SUPPORT=true" \
    -e "FAST_MODE=true" \
    -e "DOCS_DIRECTORY=/mydocs" \
    -e "AUTO_UPDATE=true" \
    -e "UPDATE_INTERVAL=1" \
    -e "DEV_ADDR=0.0.0.0:9000" \
    -v $(pwd):/mydocs \
    polinux/mkdocs
```