# Keycloak


![](https://img.shields.io/github/release/nolte/ansible-role-msopenjdk.svg)](https://github.com/nolte/ansible-role-msopenjdk)

!!! note "Initial Deployment"
    At the moment you must create the Initial user by use `kubectl port-forward` and the Ui :material-emoticon-cry-outline:



*Namespace:* `keycloak`  
*Configuration:* `./src/applications/keycloak/configuration/baseline`  



## Usefull Commands

??? example "Start port foward"
    
    ```sh
    kubectl -n keycloak port-forward svc/keycloak-http 8081:80
    ```
    
    open [localhost:8081](http://localhost:8081)

??? example "Access"


??? example "Base Config Job"
    
    ```sh
    argo -n keycloak get post-sync-keycloak 
    ```

    open [Workflow](http://localhost:2746/workflows/keycloak/post-sync-keycloak?tab=workflow)


<!--keycloak-links-start-->
* [keycloak.org](https://www.keycloak.org/)
* [terraform provider](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/openid_client)


<!--keycloak-links-end-->


