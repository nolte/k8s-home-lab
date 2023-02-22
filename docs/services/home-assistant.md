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

