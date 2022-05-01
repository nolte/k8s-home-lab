# Zertifikate

Für die Nutzung von [Lets Encrypt](https://letsencrypt.org/) im lokalen Heimnetz nutzen wir [duckdns.org](https://www.duckdns.org) als Dynamic DNS (DDNS) Service. Dort wird die Lokale IP des Ingress Controllers einer Domain zugeordnet, durch diese Limitierung ist es leider aktuell nicht möglich mehr als einen Cluster pro Domain zu betreiben. 


DuckDNS certmanager  [ebrianne/cert-manager-webhook-duckdns](https://github.com/ebrianne/cert-manager-webhook-duckdns/)


## Bereitstellung

1. Anlage des [duckdns.org](https://www.duckdns.org/) Tokens, für die Anlalage der txt records.


    ??? example "Environment variable"

        ??? example "Config From Secret"

            {%
               include-markdown "../../src/applications/cert-manager-webhook-duckdns/README.md"
               start="<!--classic-secret-start-->"
               end="<!--classic-secret-end-->"
            %}

        ??? example "Config From Vault"

            1. Vorbereitende Schritte für den Zugriff auf den Vault
                {%
                   include-markdown "../../src/applications/vault/README.md"
                   start="<!--port-forward-start-->"
                   end="<!--port-forward-end-->"
                %}
                {%
                   include-markdown "../../src/applications/vault/README.md"
                   start="<!--env-vars-port-forward-start-->"
                   end="<!--env-vars-port-forward-end-->"
                %}

            2. Kopieren des Zugriffstoken von [duckdns.org](https://www.duckdns.org) aus dem privaten Password Store ins Zentrale [Secret Management](vault.md).
                {%
                   include-markdown "../../src/applications/cert-manager-webhook-duckdns/README.md"
                   start="<!--vault-secret-start-->"
                   end="<!--vault-secret-end-->"
                %}

2. Starten des [ebrianne/cert-manager-webhook-duckdns](https://github.com/ebrianne/cert-manager-webhook-duckdns/) Deployments über ArgoWorkflow 



    {%
       include-markdown "../../src/applications/cert-manager-webhook-duckdns/README.md"
       start="<!--workflow-deploy-start-->"
       end="<!--workflow-deploy-end-->"
    %}

    ```sh
    argo wait \
      -n argocd @latest
    ```

3. Generieren eines Zentralen Wildcard Zertifikates

    ```sh
    argo submit \
      -n argocd \
      --from workflowtemplate/app-cert-wildcard \
      -p helm-values-filename=values-contour-tls-delegate.yaml
    ```

    ```sh
    argo wait \
      -n argocd @latest
    ```