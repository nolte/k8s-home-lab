# InfluxDB (Zigbee Gateway)



<!--description-start-->

<!--description-end-->


<!--header-start-->
**Namespace:** `influxdb`  
**Deployment:** [influxdata/influxdb2](https://github.com/influxdata/helm-charts/tree/master/charts/influxdb2)  
**Web:** [influxdb](https://github.com/influxdata/influxdb)
<!--header-end-->

## User Access

```sh
kubectl -n influxdb get secrets influxdb2-auth -ojson | jq '.data."admin-password"' -r | base64 -d
```


```sh
export INFLUXDB_USERNAME=admin 
export INFLUXDB_PASSWORD=$(kubectl -n influxdb get secrets influxdb2-auth -ojson | jq '.data."admin-password"' -r | base64 -d)
```

## Useful Commands

**Port Forward**
<!--port-forward-start-->
```sh
kubectl -n influxdb port-forward svc/influxdb2 8086:80
```
<!--port-forward-end-->

```sh
export INFLUX_TOKEN=H46fEdLWVX13aZN2cAJixhMShegyjoX8zs3Y1KNXtFDl_rQ2RsI6C8rz1-kb0bJnOwkdBVUHhKCwyc9HLN7fUw==
export INFLUX_ORG_ID=smart-home
export INFLUX_BUCKET=home-assistant

curl --request POST \
  "http://localhost:8086/api/v2/buckets" \
  --header "Authorization: Token ${INFLUX_TOKEN}" \
  --header "Content-type: application/json" \
  --data '{
    "orgID": "'"${INFLUX_ORG_ID}"'",
    "name": "'"${INFLUX_BUCKET}"'"
  }'

```