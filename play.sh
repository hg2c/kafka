#!/usr/bin/env bash
source ./config.sh

KAFKA_HOME=/opt/kafka
CONTAINER=$(docker ps | grep 9092 | awk '{print $1}')
ACTION=${1:-list}
DEFAULT_TOPIC=test
DEFAULT_MESSAGE=hello

run() {
    echo docker exec $CONTAINER $KAFKA_HOME/$*
    docker exec $CONTAINER $KAFKA_HOME/$*
}

topic:create() {
    run bin/kafka-topics.sh --create --bootstrap-server $BROKERS --replication-factor 1 --partitions 1 --topic ${1:-${DEFAULT_TOPIC}}
}

topic:list() {
    run bin/kafka-topics.sh --list --bootstrap-server $BROKERS
    run bin/kafka-topics.sh --describe --bootstrap-server $BROKERS --topic ${DEFAULT_TOPIC}
}

producer() {
    # docker exec $CONTAINER bash -c "echo ${1:-$DEFAULT_MESSAGE} | $KAFKA_HOME/bin/kafka-console-producer.sh --broker-list $BROKERS --topic ${DEFAULT_TOPIC}"
    docker exec -it $CONTAINER $KAFKA_HOME/bin/kafka-console-producer.sh --broker-list $BROKERS --topic ${DEFAULT_TOPIC} <(echo he)
}

consumer() {
    run bin/kafka-console-consumer.sh --bootstrap-server $BROKERS --topic ${DEFAULT_TOPIC} --from-beginning
}

case $ACTION in
    ct|create) topic:create $2;;
    l|list) topic:list;;
    p|producer) producer $2;;
    c|consumer) consumer;;
    *) echo "echo help $HOST_IP";;
esac
