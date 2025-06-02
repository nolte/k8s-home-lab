FROM ghcr.io/netbox-community/netbox:v4.3.1

RUN apt -y update && apt -y install git


RUN  /usr/local/bin/uv pip install netbox-initializers netbox-plugin-prometheus-sd



