# Audio Station

{%
   include-markdown "../../src/bundles/audio-station/README.md"
   start="<!--description-start-->"
   end="<!--description-end-->"
%}

**Features:**

{%
   include-markdown "../../src/bundles/audio-station/README.md"
   start="<!--service-set-start-->"
   end="<!--service-set-end-->"
%}

## Configuration

??? example "Environment variable"

    ??? example "Spotify Auth"

        {%
           include-markdown "../../src/bundles/audio-station/README.md"
           start="<!--mopidy-spotify-auth-start-->"
           end="<!--mopidy-spotify-auth-end-->"
        %}

## Access (Port Forward)


??? example "Start port foward Mopidy"

    {%
       include-markdown "../../src/bundles/audio-station/README.md"
       start="<!--mopidy-port-forward-start-->"
       end="<!--mopidy-port-forward-end-->"
    %}    


??? example "Start port foward snapcast server"

    {%
       include-markdown "../../src/bundles/audio-station/README.md"
       start="<!--snapcast-server-port-forward-start-->"
       end="<!--snapcast-server-port-forward-end-->"
    %}