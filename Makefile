KAFKA_VERSION=2.2.0
KAFKA_BASE=kafka_2.12-${KAFKA_VERSION}
KAFKA_FILE=${KAFKA_BASE}.tgz
TEST_TOPIC="test1"
PARTITIONS=15

${KAFKA_FILE}:
	wget http://apache.proserve.nl/kafka/${KAFKA_VERSION}/${KAFKA_FILE}

${KAFKA_FILE}.asc:
	wget https://www.apache.org/dist/kafka/${KAFKA_VERSION}/${KAFKA_FILE}.asc

.PHONY: get
get: ${KAFKA_FILE} ${KAFKA_FILE}.asc
	gpg --import KEYS
	gpg --verify ${KAFKA_FILE}.asc ${KAFKA_FILE}
	tar -xzf ${KAFKA_FILE}

.PHONY: run-zookeeper
run-zookeeper:
	cd ${KAFKA_BASE}; bin/zookeeper-server-start.sh config/zookeeper.properties

.PHONY: run-kafka
run-kafka:
	cd ${KAFKA_BASE}; bin/kafka-server-start.sh config/server.properties

.PHONY: create-topic
create-topic:
	cd ${KAFKA_BASE}; bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions ${PARTITIONS} --topic ${TEST_TOPIC}

venv:
	python3.7 -m venv venv
	venv/bin/pip install -r requirements.txt

.PHONY: freeze
freeze:
	venv/bin/pip freeze > requirements.txt

.PHONY: produce
produce:
	source venv/bin/activate; python prodcons.py produce --topic ${TEST_TOPIC} --count 3

.PHONY: consume
consume:
	source venv/bin/activate; python prodcons.py consume --topic ${TEST_TOPIC} --count 3

# add C-m to end of send-keys to execute; but for now want to do by hand
# run from outside of a tmux session
.PHONY: setup
setup: get venv
	tmux new -s kafkapt -d
	tmux send-keys "make create-topic"
	tmux new-window -n zook
	tmux send-keys -t zook "make run-zookeeper"
	tmux new-window -n kafka
	tmux send-keys -t kafka "make run-kafka"
	tmux new-window -n produce
	tmux send-keys -t produce "make produce"
	tmux new-window -n consume
	tmux send-keys -t consume "make consume"
	tmux attach -t kafkapt

.PHONY: clean
clean:
	rm -rf kafka_2.12-2.2.0.tgz
	rm -rf kafka_2.12-2.2.0.tgz.asc
	rm -rf kafka_2.12-2.2.0/
	rm -rf venv/
