# K8S as ESB

## Service Sets

* [camel-k](../src/applications/camel-k) [what-is-camel](https://camel.apache.org/manual/faq/what-is-camel.html)
* [RabbitMQ](../src/applications/rabbitmq/)

```sh
kamel run hello.groovy -n camel-k

kamel run write.groovy -n knative-eventing --dev
```


```sh
kamel run \
  -e BROKER_URL=transport.transport.svc:5672 \
  -e BROKER_USERNAME=admin-user \
  -e BROKER_PASSWORD=1f2d1e2e67df \
  -d camel-amqp \
  read.groovy -n knative-eventing --dev
```

```sh
kamel run \
  -e BROKER_URL=transport.transport.svc:5672 \
  -e BROKER_USERNAME=admin-user \
  -e BROKER_PASSWORD=1f2d1e2e67df \
  -d camel-amqp \
  write.groovy -n knative-eventing --dev
```


kubectl -n knative-eventing create secret generic docker-hub --from-file ~/.docker/config.json
