config:
	./config/auto.config.sh
	docker-compose config

run: config
	docker-compose up

up: config
	docker-compose up -d

zk:
	docker-compose up -d zookeeper

ps:
	docker-compose ps

down:
	docker-compose down

clear:
	docker volume prune

.PHONY: \
	config \
	run \
	up \
	ps \
	down
