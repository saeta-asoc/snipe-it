# Makefile for managing Snipe-IT Docker Compose services

# Variables
PWD := $(shell pwd)
INSTALLED_FILE := $(PWD)/.installed
ENV_FILE := $(PWD)/.env

# Load environment variables
include $(ENV_FILE)
export $(shell sed 's/=.*//' $(ENV_FILE))

# Targets
# Check if .env file exists
## Start services
init:
	@if [ ! -f $(INSTALLED_FILE) ]; then \
		echo "Installing Snipe-IT..."; \
		docker-compose up -d; \
		sleep 2; \
		docker exec -it snipeit chown -R docker:root /var/www/html/storage/logs; \
		docker-compose down; \
		sudo sh -c 'echo "installed" >> $(INSTALLED_FILE);'; \
	fi

up: init
	docker-compose up -d

## Shut down services
down:
	docker-compose down

## Stop services
stop:
	docker-compose stop

## Restart services
restart:
	docker-compose restart

## Show logs for all services
logs:
	docker-compose logs -f

## Remove services
rm:
	docker-compose rm -fsv
	sudo rm -r -i -f $(VOLUME_ROOT) $(INSTALLED_FILE)

.PHONY: up down restart logs rm