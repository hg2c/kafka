#!/usr/bin/env bash
get:host:ip() {
    ifconfig en0 | awk '/inet / {gsub("addr:","",$2); print $2}'
}

get:container() {
    docker ps | grep 9092 | awk '{print $1}'
}

get:brokers() {
    docker-compose port kafka 9092 | sed -e "s/0.0.0.0:/$HOST_IP:/g"
}

set:env() {
    local key=$1
    local value=$($2)

    eval "export $key=$value"
    echo $key=$value >> .env
}

rm .env

set:env CONTAINER get:container
set:env HOST_IP   get:host:ip
set:env BROKERS   get:brokers

# echo "------------------"
# cat .env
# echo "------------------"
