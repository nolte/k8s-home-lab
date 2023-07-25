# ESP Home

<!--description-start-->
Manage different ESP based IoT Devices, mostly based at some NodeMCU or other Products like this. The Devices will be used for collection Informations from different Sensors like DHT22 etc. This Service is a part, of the SmartHome Eco System.
<!--description-end-->

<!--header-start-->
**Deployment:** [esphome/esphome](https://hub.docker.com/r/esphome/esphome/tags) *wrapper from the [bjw-s/helm-charts](https://github.com/bjw-s/helm-charts/tree/main/charts/library/common) common chart* 
**Web**: [esphome.io](https://esphome.io/)  
<!--header-end-->

## Preconditions

Create a Secret with a private key, for access to the Private Git Repo, with existing Smart Home Configurations.

<!--preconditions-git-creds-start-->
```sh
kubectl -n esphome create secret generic git-creds \
  --from-literal=id_rsa="$(pass internet/project/homeassistant/deploymentkey/id_rsa)" \
  --from-literal=id_rsa.pub="$(pass internet/project/homeassistant/deploymentkey/id_rsa.pub)" \
  --from-literal=known_hosts="$(ssh-keyscan -t rsa github.com)"
```
<!--preconditions-git-creds-end-->

Required Endpoints and secrets for use [nolte/esphome-configs](https://github.com/nolte/esphome-configs).

<!--preconditions-esphome-config-start-->
```sh
kubectl -n esphome create secret generic esphome-config \
  --from-literal=WIFI_DOMAIN=".fritz.box" \
  --from-literal=WIFI_SSID="$(pass network/wifi/ssid)" \
  --from-literal=WIFI_PASSWORD="$(pass network/wifi/password)" \
  --from-literal=WIFI_FALLBACK_PASSWORD="$(pass network/wifi/password)" \
  --from-literal=MQTT_ENDPOINT="$(kubectl -n mosquitto get svc mosquitto -ojson | jq -r '.status.loadBalancer.ingress[0].ip')" \
  --from-literal=MQTT_PORT="1883" \
  --from-literal=MQTT_USERNAME="esphome" \
  --from-literal=MQTT_PASSWORD="notset"
```
<!--preconditions-esphome-config-end-->

<!--port-forward-start-->
```sh
kubectl -n esphome port-forward svc/esphome 6052
```
<!--port-forward-end-->
