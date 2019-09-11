#!/usr/bin/env bash
set -euf -o pipefail

source ./config/auto.config.sh
source ./config/config.sh

ACTION=${1:-help}

usage="Usage:  $(basename "$0") [OPTIONS] COMMAND

Commands:
  (ct| create) TOPIC             Create kafka TOPIC
  ( l| list)                     List kafka topics
  ( p| producer) TOPIC MESSAGE   Produce message \"hello\" to kafka
  ( c| consumer) TOPIC           Start a kafka consumer"

assert:notEmpty() {
    local var=$(eval echo \$$1)
    if [ -z "$var" ]; then
        >&2 echo "ERROR: \$$1 is empty"
        exit 1
    fi
}

run:docker() {
    assert:notEmpty BROKERS

    echo "docker run --rm -it wurstmeister/kafka $*"
}

run:dockerexec() {
    assert:notEmpty CONTAINER
    assert:notEmpty BROKERS

    echo "docker exec -it $CONTAINER $*"
}

run:kafka() {
    assert:notEmpty BROKERS

    echo "$*"
}

run() {
    CMD="$($RUNTIME $*)"
    echo "$CMD"
    eval "$CMD"
}


topic:create() {
    run $KAFKA_HOME/bin/kafka-topics.sh --create --replication-factor 1 --partitions 1 --topic $1 --bootstrap-server $BROKERS
}

topic:list() {
    run $KAFKA_HOME/bin/kafka-topics.sh --list --bootstrap-server $BROKERS
}

topic:describe() {
    run $KAFKA_HOME/bin/kafka-topics.sh --describe --topic $1 --bootstrap-server $BROKERS
}

message:producer() {
    run bash -c "\"echo $1 | $KAFKA_HOME/bin/kafka-console-producer.sh --topic $2 --broker-list $BROKERS\""
}

message:consumer() {
    run $KAFKA_HOME/bin/kafka-console-consumer.sh --topic $1 --from-beginning --bootstrap-server $BROKERS
}


case $ACTION in
    ct|create)
        topic:create ${2:-${DEFAULT_TOPIC}}
        ;;
    l|list)
        topic:list ${2:-${DEFAULT_TOPIC}}
        ;;
    p|producer)
        message:producer ${2:-$DEFAULT_MESSAGE} ${3:-${DEFAULT_TOPIC}}
        ;;
    c|consumer)
        message:consumer ${2:-${DEFAULT_TOPIC}}
        ;;
    h|help|*)
        echo "$usage" >&2
        exit 1
        ;;
esac
