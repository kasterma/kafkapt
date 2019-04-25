# Kafka python test

Trying to track down some issues.

## docker-compose

Ensure you have the line

    127.0.0.1 kafka

in your /etc/hosts

Then in one termninal execute (to start kafka in dockers)

    docker-compose up

and in another execute (to create the topic and see it configured)

    docker-compose exec kafka kafka-topics --create --zookeeper zookeeper:2181 --replication-factor 1 --partitions 15 --topic test1
    docker-compose exec kafka kafka-topics --zookeeper zookeeper:2181 --describe

Note: to use the local kafka (outside of docker) change the url kafka:9092 back to
localhost:9092 in the python script.