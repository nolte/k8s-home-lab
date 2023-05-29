# Home Assisant

<!--description-start-->
Used as basement for a cloudless Smart Home Eco system.
<!--description-end-->

<!--header-start-->
**Deployment:** [ghcr.io/home-assistant/home-assistant](https://github.com/home-assistant/core/pkgs/container/home-assistant) *wrapper from the [bjw-s/helm-charts](https://github.com/bjw-s/helm-charts/tree/main/charts/library/common) common chart*  
**Web**: [home-assistant.io](https://www.home-assistant.io/)  
<!--header-end-->

## Classic Secret

<!--secret-git-creds-start-->
```sh
kubectl -n home-assistant create secret generic git-creds \
  --from-literal=id_rsa="$(pass internet/project/homeassistant/deploymentkey/id_rsa)" \
  --from-literal=id_rsa.pub="$(pass internet/project/homeassistant/deploymentkey/id_rsa.pub)" \
  --from-literal=known_hosts="$(ssh-keyscan -t rsa github.com)"
```
<!--secret-git-creds-end-->


<!--secret-home-assistant-creds-start-->
```sh
kubectl -n home-assistant create secret generic home-assistant-creds \
  --from-literal=GOOGLE_CLIENT_ID="$(pass internet/google.com/projects/home-assistant-274616/client_id)" \
  --from-literal=GOOGLE_CLIENT_SECRET="$(pass internet/google.com/projects/home-assistant-274616/client_secret)" \
  --from-literal=OPENWEATHERMAP_API_KEY="$(pass network/homeassistant/openweather/apikey)" \
  --from-literal=FRITZBOX_USERNAME="$(pass network/homeassistant/fritzbox/user)" \
  --from-literal=FRITZBOX_PASSWORD="$(pass network/homeassistant/fritzbox/password)" \
  --from-literal=GITHUB_ACCESS_TOKEN="$(pass internet/github.com/nolte/servics/home-assistant/token)" \
  --from-literal=HUE_ENDPOINT=192.168.178.29
```
<!--secret-home-assistant-creds-end-->

## Vault

Copy Required Secrets into the Vault Secret managed.

<!--vault-secrets-start-->
```sh
vault kv put \
  secrets-tf/third-party-services/github.com/deploymentkey/home-assistant \
  id_rsa="$(pass internet/project/homeassistant/deploymentkey/id_rsa)" \
  id_rsa.pub="$(pass internet/project/homeassistant/deploymentkey/id_rsa.pub)" \
  known_hosts="$(ssh-keyscan -H github.com )"

vault kv put \
  secrets-tf/third-party-services/openweathermap.org/projects/home-assistant \
  token="$(pass network/homeassistant/openweather/apikey)"

vault kv put \
  secrets-tf/third-party-services/github.com/apitoken/home-assistant \
  token="$(pass internet/github.com/nolte/servics/home-assistant/token)"

vault kv put \
  secrets-tf/services/router-fritz-box/users/admin \
  username="$(pass network/homeassistant/fritzbox/user)" \
  password="$(pass network/homeassistant/fritzbox/password)" \
  endpoint="$(pass network/homeassistant/fritzbox/endpoint)"

vault kv put \
  secrets-tf/third-party-services/google.com/projects/home-assistant \
  client_id="$(pass internet/google.com/projects/home-assistant-274616/client_id)" \
  client_secret="$(pass internet/google.com/projects/home-assistant-274616/client_secret)"
```
<!--vault-secrets-end-->
