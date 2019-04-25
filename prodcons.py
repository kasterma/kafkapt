from kafka import KafkaProducer, KafkaConsumer
from kafka.errors import KafkaError
import click
import logging
import sys
import yaml
from logging.config import dictConfig

with open("logging.yaml") as f:
    d = yaml.safe_load(f)
    dictConfig(d)


@click.group()
def cli():
    pass

@cli.command()
@click.option("--topic")
@click.option("--count", type=int)
def produce(topic, count):
    log = logging.getLogger("produce")
    log.info(f"produce to {topic} count {count}")

    producer = KafkaProducer(bootstrap_servers=['kafka:9092'],
                             value_serializer=lambda m: m.encode("ascii"),
                             retries=5)

    for idx in range(count):
        future = producer.send(topic, f"message {idx}")

        try:
            record_metadata = future.get(timeout=10)
        except KafkaError as e:
            log.error(f"Error {e}")

        log.info(record_metadata.topic)
        log.info(record_metadata.partition)
        log.info(record_metadata.offset)

    producer.flush()
    producer.close()

@cli.command()
@click.option("--topic")
@click.option("--count", type=int)
def consume(topic, count):
    log = logging.getLogger("consume")
    log.info(f"consume from {topic} count {count}")

    consumer = KafkaConsumer(topic,
                             group_id="testgroup",
                             auto_offset_reset="earliest",
                             bootstrap_servers=['kafka:9092'],
                             value_deserializer=lambda b: b.decode("ascii"))

    while True:
        records = consumer.poll()
        if len(records) > 0:
           log.info(records)

           msgs = [r.value for _, rs in records.items() for r in rs]
           log.info(msgs)

           if any(m == f"message {count-1}" for m in msgs):
               break

    log.info("done done")

    consumer.close()

if __name__ == "__main__":
    cli()
