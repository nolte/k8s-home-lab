camel {
    components {
        rabbitmq {
            addresses = System.getenv('BROKER_URL')
            username = System.getenv('BROKER_USERNAME')
            password = System.getenv('BROKER_PASSWORD')
        }
    }
}

from("rabbitmq:direct-exchange?queue=in.testing.example&vhost=first-draft-vhost&declare=false&autoDelete=false")
  .to("log:cheese");
