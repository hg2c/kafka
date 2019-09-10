#!/usr/bin/env bash
source ./config.sh

KAFKA_HOME=/opt/kafka
KAFKA_CLI_OPTS=" --bootstrap-server $BROKERS"
KAFKA_DOCKER="docker run --rm -it wurstmeister/kafka"

ACTION=${1:-list}
DEFAULT_TOPIC=test
DEFAULT_MESSAGE=hello

run() {
    CMD="docker run --rm -it wurstmeister/kafka $KAFKA_HOME/$* $KAFKA_CLI_OPTS"
    echo $CMD
    $CMD
}

run:docker:exec () {
    echo docker exec $CONTAINER $KAFKA_HOME/$*
    docker exec $CONTAINER $KAFKA_HOME/$*
}

topic:create() {
    run bin/kafka-topics.sh --create --replication-factor 1 --partitions 1 --topic ${1:-${DEFAULT_TOPIC}}
}

topic:list() {
    run bin/kafka-topics.sh --list
    run bin/kafka-topics.sh --describe --topic ${DEFAULT_TOPIC}
}

producer() {
    # docker exec $CONTAINER bash -c "echo ${1:-$DEFAULT_MESSAGE} | $KAFKA_HOME/bin/kafka-console-producer.sh --broker-list $BROKERS --topic ${DEFAULT_TOPIC}"
    $KAFKA_DOCKER bash -c "echo ${1:-$DEFAULT_MESSAGE} | $KAFKA_HOME/bin/kafka-console-producer.sh --topic ${DEFAULT_TOPIC} --broker-list $BROKERS"
}

consumer() {
    run bin/kafka-console-consumer.sh --topic ${DEFAULT_TOPIC} --from-beginning
}

case $ACTION in
    ct|create) topic:create $2;;
    l|list) topic:list;;
    p|producer) producer $2;;
    c|consumer) consumer;;
    *) echo "echo help $HOST_IP";;
esac
