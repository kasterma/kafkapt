KAFKA_VERSION=2.2.0
KAFKA_BASE=kafka_2.12-${KAFKA_VERSION}
KAFKA_FILE=${KAFKA_BASE}.tgz

${KAFKA_FILE}:
	wget http://apache.proserve.nl/kafka/${KAFKA_VERSION}/${KAFKA_FILE}

${KAFKA_FILE}.asc:
	wget https://www.apache.org/dist/kafka/${KAFKA_VERSION}/${KAFKA_FILE}.asc

get: ${KAFKA_FILE} ${KAFKA_FILE}.asc
	gpg --import KEYS
	gpg --verify ${KAFKA_FILE}.asc ${KAFKA_FILE}
	tar -xzf ${KAFKA_FILE}

run-zookeeper:
	cd ${KAFKA_BASE}; bin/zookeeper-server-start.sh config/zookeeper.properties

run-kafka:
	cd ${KAFKA_BASE}; bin/kafka-server-start.sh config/server.properties

create-topic:
	cd ${KAFKA_BASE}; bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic test

venv:
	python3.7 -m venv venv
	venv/bin/pip install -r requirements.txt

freeze:
	venv/bin/pip freeze > requirements.txt

# add C-m to end of send-keys to execute; but for now want to do by hand
setup:
	tmux new -s kafkapt -d
	tmux send-keys "make create-topic"
	tmux new-window -n zook
	tmux send-keys -t zook "make run-zookeeper"
	tmux new-window -n kafka
	tmux send-keys -t kafka "make run-kafka"
	tmux new-window -n produce
	tmux send-keys -t produce "source venv/bin/activate; python produce.py"
	tmux new-window -n consume
	tmux send-keys -t consume "source venv/bin/activate; python consume.py"
	tmux attach -t kafkapt
