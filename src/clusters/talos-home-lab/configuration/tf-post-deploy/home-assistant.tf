
data "pass_password" "google_client_id" {
  path = "internet/google.com/projects/home-assistant-274616/client_id"
}

data "pass_password" "client_secret" {
  path = "internet/google.com/projects/home-assistant-274616/client_secret"
}


data "pass_password" "fritzbox_username" {
  path = "network/homeassistant/fritzbox/user"
}

data "pass_password" "fritzbox_password" {
  path = "network/homeassistant/fritzbox/password"
}

data "pass_password" "telegram_api_key" {
  path = "internet/telegram.me/homeassist/api_key"
}


data "pass_password" "telegram_notification_chat_id" {
  path = "internet/telegram.me/homeassist/channel_id"
}
data "kubernetes_secret" "influxdb" {
  metadata {
    name      = "influxdb2-auth"
    namespace = "influxdb"
  }
}
#admin-token

resource "kubernetes_secret" "home-assistant-creds" {
  metadata {
    name      = "home-assistant-creds"
    namespace = "home-assistant"
  }

  data = {
    GOOGLE_CLIENT_ID              = data.pass_password.google_client_id.password
    GOOGLE_CLIENT_SECRET          = data.pass_password.client_secret.password
    FRITZBOX_USERNAME             = data.pass_password.fritzbox_username.password
    FRITZBOX_PASSWORD             = data.pass_password.fritzbox_password.password
    TELEGRAM_API_KEY              = data.pass_password.telegram_api_key.password
    TELEGRAM_NOTIFICATION_CHAT_ID = data.pass_password.telegram_notification_chat_id.password
    INFLUX_TOKEN                  = data.kubernetes_secret.influxdb.data["admin-token"]
  }
}