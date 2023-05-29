# Monitoring

*Namespace:* `monitoring`  

## Prometheus

??? example "Start port foward"

    {%
       include-markdown "../../src/applications/monitoring/README.md"
       start="<!--prometheus-port-forward-start-->"
       end="<!--prometheus-port-forward-end-->"
    %}

## Grafana

??? example "Start port foward"

    {%
       include-markdown "../../src/applications/monitoring/README.md"
       start="<!--grafana-port-forward-start-->"
       end="<!--grafana-port-forward-end-->"
    %}

??? example "Admin Zugang"

    **Username:**
    {%
       include-markdown "../../src/applications/monitoring/README.md"
       start="<!--grafana-admin-username-start-->"
       end="<!--grafana-admin-username-end-->"
    %}
    **Password:**
    {%
       include-markdown "../../src/applications/monitoring/README.md"
       start="<!--grafana-admin-password-start-->"
       end="<!--grafana-admin-password-end-->"
    %}

## Fritz Box Monitoring

*Sources:* [pdreker/fritz_exporter](https://github.com/pdreker/fritz_exporter)

## Speed Test

*Helm Chart:*[k8s-at-home/charts/tree/master/charts/stable/speedtest-exporter](https://github.com/k8s-at-home/charts/tree/master/charts/stable/speedtest-exporter)  
*Sources:* [MiguelNdeCarvalho/speedtest-exporter](https://github.com/MiguelNdeCarvalho/speedtest-exporter/)


??? example "Start port foward"

    {%
       include-markdown "../../src/applications/speedtest-exporter/README.md"
       start="<!--port-forward-start-->"
       end="<!--port-forward-end-->"
    %}

## Blackbox Exporter

??? example "Start port foward"

    {%
       include-markdown "../../src/applications/blackbox-exporter/README.md"
       start="<!--blackbox-exporter-port-forward-start-->"
       end="<!--blackbox-exporter-port-forward-end-->"
    %}
