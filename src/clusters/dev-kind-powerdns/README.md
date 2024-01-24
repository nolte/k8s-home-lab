# Full Developer Cluster

<!--intro-start-->
Full service set for some self hosted development stack, with tools like Git (Gitea), Secret Management (Vault), Identity Management (KeyCloak). Using DuckDNS, LetsEncrypt and Cert-Manager for protect Ingress (Project Contour) endpoints, with tls Certificates.
<!--intro-end-->

## Usage

<!--cmd-recreate-start-->
```sh
task platform:recreate-devops-services
```
<!--cmd-recreate-end-->