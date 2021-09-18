# Zertifikate

Für die Nutzung von [Lets Encrypt](https://letsencrypt.org/) im lokalen Heimnetz nutzen wir [duckdns.org](https://www.duckdns.org) als Dynamic DNS (DDNS) Service. Dort wird die Lokale IP des Ingress Controllers einer Domain zugeordnet, durch diese Limitierung ist es leider aktuell nicht möglich mehr als einen Cluster pro Domain zu betreiben. 


DuckDNS certmanager  [ebrianne/cert-manager-webhook-duckdns](https://github.com/ebrianne/cert-manager-webhook-duckdns/)


## Bereitstellung

1. Anlage des [duckdns.org](https://www.duckdns.org/) Tokens, für die Anlalage der txt records.

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
        ```sh
        vault kv put \
          secrets-tf/third-party-services/duckdns.org/api \
          token=$(pass internet/duckdns.org/oidc-google/token)
        ```

2. Starten des [ebrianne/cert-manager-webhook-duckdns](https://github.com/ebrianne/cert-manager-webhook-duckdns/) Deployments über ArgoWorkflow 

    ```sh
    argo submit \
      -n argocd \
      --from workflowtemplate/app-cert-manager-webhook-duckdns \
      -p issuerEmail=$(pass internet/letsencrypt/account_mail)
    ```

3. Generieren eines Zentralen Wildcard Zertifikates

    ```sh
    argo submit \
      -n argocd \
      --from workflowtemplate/app-cert-wildcard
    ```
