# Workflows


```sh
argo submit \
  -n esphome \
  --from workflowtemplate/esphome \
  -p inventory-repo=https://github.com/nolte/esphome-configs.git \
  -p inventory-revision=master \
  -p device-config="nous-a1t-05.yaml" \
  -p device-address="192.168.178.76";
```

```sh
argo submit \
  -n esphome \
  --from workflowtemplate/esphome \
  -p inventory-repo=https://github.com/nolte/esphome-configs.git \
  -p inventory-revision=master \
  -p device-config="gosund-sp111-01.yaml" \
  -p device-address="192.168.178.41";
```

```
kubectl -n esphome create secret generic esphome-config \
  --from-literal=WIFI_DOMAIN=".fritz.box" \
  --from-literal=WIFI_SSID="$(pass network/wifi/ssid)" \
  --from-literal=WIFI_PASSWORD="$(pass network/wifi/password)" \
  --from-literal=WIFI_FALLBACK_PASSWORD="$(pass network/wifi/password)" \
  --from-literal=MQTT_ENDPOINT="192.168.178.66" \
  --from-literal=MQTT_PORT="31883" \
  --from-literal=MQTT_USERNAME="esphome" \
  --from-literal=MQTT_PASSWORD="notset"
```