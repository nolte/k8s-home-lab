camel {
    components {
        rabbitmq {
            addresses = System.getenv('BROKER_URL')
            username = System.getenv('BROKER_USERNAME')
            password = System.getenv('BROKER_PASSWORD')
        }
    }
}

from('timer:js?period=1000')
    .routeId('js')
    .setBody()
        .simple('Hello Camel K')
    .to('rabbitmq:direct-exchange?vhost=first-draft-vhost&declare=false&autoDelete=false')
