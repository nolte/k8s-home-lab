# Home Assistant

{%
   include-markdown "../../src/applications/home-assistant/README.md"
   start="<!--description-start-->"
   end="<!--description-end-->"
%}

---

{%
   include-markdown "../../src/applications/home-assistant/README.md"
   start="<!--header-start-->"
   end="<!--header-end-->"
%}

---


??? example "Start port foward"

    {%
       include-markdown "../../src/applications/home-assistant/README.md"
       start="<!--port-forward-start-->"
       end="<!--port-forward-end-->"
    %}



https://github.com/CausticLab/hass-configurator-docker
https://github.com/danielperna84/hass-configurator


Set Git Key for Clone Conf repo.


??? example "Environment variable"

    ??? example "Classic Secret"

        Required Vars and Login
        {%
            include-markdown "../../src/applications/home-assistant/README.md"
            start="<!--secret-git-creds-start-->"
            end="<!--secret-git-creds-end-->"
        %}

        {%
            include-markdown "../../src/applications/home-assistant/README.md"
            start="<!--secret-home-assistant-creds-start-->"
            end="<!--secret-home-assistant-creds-end-->"
        %}

    ??? example "Vault Access"

        Required Vars and Login
        {%
            include-markdown "../../src/applications/home-assistant/README.md"
            start="<!--vault-secrets-start-->"
            end="<!--vault-secrets-end-->"
        %}


## Access

## Config By API

Set a [long lived](https://developers.home-assistant.io/docs/auth_api/#long-lived-access-token) Token from your User Profile

```sh
export HASS_TOKEN=$(pass network/homeassistant/api/token)
```


```sh
export HASS_FLOW_ID=$(curl 'https://home-assistant.dev44-just-homestyle.duckdns.org/api/config/config_entries/flow' -H "Authorization: Bearer $HASS_TOKEN" -H "Content-Type: application/json" --data-raw '{"handler":"androidtv","show_advanced_options":false}' --compressed -s | jq -r '.flow_id')
```

```sh
curl \
  -H "Authorization: Bearer $HASS_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST \
  https://home-assistant.dev44-just-homestyle.duckdns.org/api/config/config_entries/flow/$HASS_FLOW_ID \
  --data-raw '{"host":"192.168.178.75","device_class":"firetv","port":5555}'
```


```sh
export HASS_FLOW_ID=$(curl 'https://home-assistant.dev44-just-homestyle.duckdns.org/api/config/config_entries/flow' -H "Authorization: Bearer $HASS_TOKEN" -H "Content-Type: application/json" --data-raw '{"handler":"fritzbox_callmonitor","show_advanced_options":false}' --compressed -s | jq -r '.flow_id')
```
```sh
curl \
  -H "Authorization: Bearer $HASS_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST \
  https://home-assistant.dev44-just-homestyle.duckdns.org/api/config/config_entries/flow/$HASS_FLOW_ID \
  --data-binary "{\"host\":\""$(pass network/homeassistant/fritzbox/endpoint)"\",\"port\":1012,\"username\":\""$(pass network/homeassistant/fritzbox/user)"\" ,\"password\":\""$(pass network/homeassistant/fritzbox/password)"\"}"  
```

```sh
curl \
  -H "Authorization: Bearer $HASS_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST \
  https://home-assistant.dev44-just-homestyle.duckdns.org/api/config/config_entries/flow/$HASS_FLOW_ID \
  --data-raw '{"phonebook":"malte"}'
```
