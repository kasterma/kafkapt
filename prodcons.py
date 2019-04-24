from kafka import KafkaProducer, KafkaConsumer
from kafka.errors import KafkaError
import click
import logging
import yaml
from logging.config import dictConfig

with open("logging.yaml") as f:
    d = yaml.safe_load(f)
    dictConfig(d)


@click.command()
@click.option("--topic")
@click.option("--count")
def produce(topic, count):
    log = logging.getLogger("produce")
    log.info(f"produce to {topic} count {count}")

    producer = KafkaProducer(bootstrap_servers=['localhost:9092'],
                             value_serializer=lambda m: m.encode("ascii"),
                             retries=5)

    for idx in range(count):
        future = producer.send('my-topic', f"message {idx}")

        try:
            record_metadata = future.get(timeout=10)
        except KafkaError as e:
            log.error(f"Error {e}")

        log.info(record_metadata.topic)
        log.info(record_metadata.partition)
        log.info(record_metadata.offset)

    producer.flush()
    producer.close()

@click.command()
@click.option("--topic")
@click.option("--count")
def consume(topic, count):
    log = logging.getLogger("consume")
    log.info(f"consume from {topic} count {count}")

    consumer = KafkaConsumer(topic, value_deserializer=lambda b: b.decode("ascii"))

    for msg in consumer:
        log.info(msg)
        if msg == count:
            break

    log.info("done done")

    consumer.close()
