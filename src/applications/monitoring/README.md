# kube Prometheus Stack (Monitoring)

Using The Prometheus Operator all in one chart based by [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)

<!--prometheus-port-forward-start-->
```sh
kubectl -n monitoring port-forward svc/monitoring-kube-prometheus-prometheus 9090
```
<!--prometheus-port-forward-end-->

<!--grafana-port-forward-start-->
```sh
kubectl -n monitoring port-forward svc/monitoring-grafana 8083:80
```
<!--grafana-port-forward-end-->

<!--grafana-admin-username-start-->
```sh
kubectl -n monitoring \
  get secrets monitoring-grafana -ojson \
    | jq '.data["admin-user"]' -r \
    | base64 -d  
```
<!--grafana-admin-username-end-->

<!--grafana-admin-password-start-->
```sh
kubectl -n monitoring \
  get secrets monitoring-grafana -ojson \
    | jq '.data["admin-password"]' -r \
    | base64 -d
```
<!--grafana-admin-password-end-->
