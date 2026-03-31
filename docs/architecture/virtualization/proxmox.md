# Proxmox

In conclusion, Proxmox is a powerful and versatile virtualization platform that is well-suited for home labs. By integrating it with Terraform, you can further streamline your infrastructure management and adopt best practices in infrastructure as code.

## Installation

1. Create Boot Device 

https://enterprise.proxmox.com/iso/proxmox-ve_8.3-1.iso
```sh
sudo dd if=/home/nolte/Downloads/proxmox-ve_8.3-1.iso of=/dev/sdc
sudo dd bs=1M conv=fdatasync if=/home/nolte/Downloads/proxmox-ve_8.3-1.iso of=/dev/sdc

sync
```

## Configuration

### USB Device


```
qm set 800 -usb0 host=1a86:55d4

```