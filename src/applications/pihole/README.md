# PiHole

<!--description-start-->
Personal DNS Server for controlling the DNS Requests, Part of SmartHome Collection.
<!--description-end-->

<!--header-start-->
**Chart:**  [MoJo2600/pihole-kubernetes](https://github.com/MoJo2600/pihole-kubernetes/tree/master/charts/pihole)   
**Web:**  [pi-hole.net](https://pi-hole.net/)   
<!--header-end-->

## Access

<!--admin-password-start-->
```sh
kubectl -n pihole \
  get secret pihole-password \
  -o jsonpath="{.data.password}" | base64 -d && echo ""
```
<!--admin-password-end-->