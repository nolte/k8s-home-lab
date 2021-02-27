# DNS

*Namespace:* `powerdns`  
*Configuration:* `./src/applications/powerdns/configuration/baseline`  


## Usefull Commands

??? example "Start port foward"
    ```sh
    kubectl -n powerdns port-forward svc/powerdns-webserver 8081
    ```

??? example "list all zone records"
    ```sh
    curl -X GET \
      http://localhost:8081/api/v1/servers/localhost/zones/smart-home.k8sservices.local. \
      -H 'x-api-key: supersecretpw'
    ```