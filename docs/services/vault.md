# Secret Management

{%
   include-markdown "../../src/applications/vault/README.md"
   start="<!--description-start-->"
   end="<!--description-end-->"
%}

---

{%
   include-markdown "../../src/applications/vault/README.md"
   start="<!--header-start-->"
   end="<!--header-end-->"
%}

---

## Initiale Bereitstellung

{%
   include-markdown "../../src/applications/vault/README.md"
   start="<!--vault-init-start-->"
   end="<!--vault-init-end-->"
%}

## Usefull Commands

??? example "Start port foward"
    {%
       include-markdown "../../src/applications/vault/README.md"
       start="<!--port-forward-start-->"
       end="<!--port-forward-end-->"
    %}

??? example "Open in Browser"
    {%
       include-markdown "../../src/applications/vault/README.md"
       start="<!--httpproxies-start-->"
       end="<!--httpproxies-end-->"
    %}


### Useful Environment Variables

??? example "Using ingress"

      {%
         include-markdown "../../src/applications/vault/README.md"
         start="<!--env-vars-start-->"
         end="<!--env-vars-end-->"
      %}

??? example "Using port-forward"

      {%
         include-markdown "../../src/applications/vault/README.md"
         start="<!--login-port-forward-start-->"
         end="<!--login-port-forward-end-->"
      %}
