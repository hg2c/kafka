config:
	./config.sh
	docker-compose config

run: config
	docker-compose up

up: config
	docker-compose up -d

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
