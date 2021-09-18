# Home Assistant

https://github.com/CausticLab/hass-configurator-docker
https://github.com/danielperna84/hass-configurator


Set Git Key for Clone Conf repo.

```sh
vault kv put \
  secrets-tf/third-party-services/github.com/deploymentkey/home-assistant \
  id_rsa="$(pass internet/project/homeassistant/deploymentkey/id_rsa)" \
  id_rsa.pub="$(pass internet/project/homeassistant/deploymentkey/id_rsa.pub)" \
  known_hosts="$(ssh-keyscan -H github.com )"

vault kv put \
  secrets-tf/third-party-services/openweathermap.org/projects/home-assistant \
  token="$(pass network/homeassistant/openweather/apikey)" 


vault kv put \
  secrets-tf/third-party-services/github.com/apitoken/home-assistant \
  token="$(pass internet/github.com/nolte/servics/home-assistant/token)" 



vault kv put \
  secrets-tf/services/router-fritz-box/users/admin \
  username="$(pass network/homeassistant/fritzbox/user)" \
  password="$(pass network/homeassistant/fritzbox/password)" 

vault kv put \
  secrets-tf/third-party-services/google.com/projects/home-assistant \
  client_id="$(pass internet/google.com/projects/home-assistant-274616/client_id)" \
  client_secret="$(pass internet/google.com/projects/home-assistant-274616/client_secret)" 
```