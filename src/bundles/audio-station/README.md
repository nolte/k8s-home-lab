# Audio Station

<!--description-start-->
Service set for use a Container Based Multi Room Audio solution. With Focus for Smart Home and usability from Mobile Devices.
<!--description-end-->

## Services

<!--service-set-start-->
* [badaix/snapcast](https://github.com/badaix/snapcast) for Multi Room Audio
* [mopidy/mopidy](https://github.com/mopidy/mopidy) extensible music server written in Python
* [upmpdcli](https://www.lesbonscomptes.com/upmpdcli/) as MPD Renderer.
<!--service-set-end-->

## Access

<!--mopidy-port-forward-start-->
```sh
kubectl -n audio-station port-forward svc/rpi-mopidy 6680
```
<!--mopidy-port-forward-end-->


<!--snapcast-server-port-forward-start-->
```sh
 kubectl -n audio-station port-forward svc/rpi-snapcast-server 1780 4953
```
<!--snapcast-server-port-forward-end-->

## Configurations

<!--mopidy-spotify-auth-start-->
```sh
kubectl create secret generic -n audio-station spotify-auth \
  --from-literal=SPOTIFY_USERNAME= \
  --from-literal=SPOTIFY_PASSWORD= \
  --from-literal=SPOTIFY_CLIENT_ID= \
  --from-literal=SPOTIFY_CLIENT_SECRET=
```
<!--mopidy-spotify-auth-end-->
