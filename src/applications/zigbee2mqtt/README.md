# Zigbee2Mqtt (Zigbee Gateway)



<!--description-start-->
Self build Zigbee Gateway, for integrate without Vendor, like Ikea or Philips Hue.
<!--description-end-->


<!--header-start-->
**Namespace:** `zigbee2mqtt`  
**Deployment:** [truecharts/zigbee2mqtt](https://github.com/truecharts/charts/blob/master/charts/stable/zigbee2mqtt/values.yaml)  
**Web:** [Zigbee2Mqtt](https://www.zigbee2mqtt.io/)
<!--header-end-->

## User Access



## Useful Commands

**Port Forward**
<!--port-forward-start-->
```sh
kubectl -n zigbee2mqtt port-forward svc/zigbee2mqtt 10103
```
<!--port-forward-end-->


Look for USB Devices on host system, required for mount from host into vm/container. 

```sh
root@pve:~# lsusb
...
Bus 003 Device 003: ID 1a86:55d4 QinHeng Electronics SONOFF Zigbee 3.0 USB Dongle Plus V2
...
```