# flathunters 

[flathunters/flathunter]https://github.com/flathunters/flathunter?tab=readme-ov-file)


```
kubectl -n flathunter create secret generic flathunter-secrets \
    --from-literal=FLATHUNTER_CAPMONSTER_KEY=$(pass internet/capmonster.cloud/nolte07@googlemail.com/token) \
    --from-literal=FLATHUNTER_TELEGRAM_RECEIVER_IDS="$(pass internet/telegram.me/flathunter/receiverId)" \
    --from-literal=FLATHUNTER_TELEGRAM_BOT_TOKEN="$(pass internet/telegram.me/flathunter/token)"
```