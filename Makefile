# Makefile for managing Snipe-IT Docker Compose services

# Variables
PWD := $(shell pwd)

# Targets

## Start services
up:
	docker-compose up -d

## Stop services
down:
	docker-compose down

## Restart services
restart:
	docker-compose restart

## Show logs for all services
logs:
	docker-compose logs -f

## Show logs for specific service
logs-%:
	docker-compose logs -f $*

## Build and start services
build:
	docker-compose build
	docker-compose up -d

## Stop, remove, rebuild and start services
rebuild: down build

## Show status of services
ps:
	docker-compose ps

## Remove services
# TODO: add remove volumes folder with env variable in .env file
rm:
	docker-compose rm -fsv


## Execute a command inside a service
exec-%:
	docker-compose exec $* /bin/bash

.PHONY: up down restart logs logs-% build rebuild ps exec-%
