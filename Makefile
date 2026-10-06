# DockPHP Cuy - command wrapper
# Run `make` or `make help` to list the available commands.

COMPOSE ?= docker compose
SERVICE ?= php85

.DEFAULT_GOAL := help

.PHONY: help up down restart build rebuild ps logs sh bash db nginx-test nginx-reload exec info new pma-setup

help: ## Show this help
	@echo "DockPHP Cuy - available commands:"
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

up: ## Start the stack in the background
	$(COMPOSE) up -d

down: ## Stop and remove the containers
	$(COMPOSE) down

restart: ## Restart all services
	$(COMPOSE) restart

build: ## Build the images
	$(COMPOSE) build

rebuild: ## Rebuild all images without cache
	$(COMPOSE) build --no-cache

ps: ## Show container status
	$(COMPOSE) ps

logs: ## Follow logs (make logs s=nginx)
	$(COMPOSE) logs -f $(or $(s),)

sh: ## Shell into a service (make sh s=nginx)
	$(COMPOSE) exec $(or $(s),$(SERVICE)) sh

bash: ## Bash into the PHP container
	$(COMPOSE) exec php85 bash

db: ## Open the MariaDB client as root
	$(COMPOSE) exec mariadb mariadb -u root -p

pma-setup: ## Set up the phpMyAdmin configuration storage (pmadb)
	@$(COMPOSE) exec -T phpmyadmin sh -c 'cat /var/www/html/sql/create_tables.sql' \
		| $(COMPOSE) exec -T mariadb sh -c 'mariadb -uroot -p"$$MARIADB_ROOT_PASSWORD"'
	@echo "phpMyAdmin configuration storage is ready."

nginx-test: ## Validate the nginx configuration
	$(COMPOSE) exec nginx nginx -t

nginx-reload: ## Reload nginx after adding/editing a vhost
	$(COMPOSE) exec nginx nginx -s reload

exec: ## Run a command in a service (make exec s=php85 c="php -v")
	$(COMPOSE) exec $(or $(s),$(SERVICE)) $(c)

info: ## Show PHP version and loaded extensions
	$(COMPOSE) exec php85 php -v
	$(COMPOSE) exec php85 php -m

new: ## Scaffold a new project (make new name=myapp)
	@test -n "$(name)" || { echo "usage: make new name=<project>"; exit 1; }
	@mkdir -p projects/$(name)
	@test -f projects/$(name)/index.php || printf '<?php\nphpinfo();\n' > projects/$(name)/index.php
	@test -f Nginx/conf.d/$(name).conf || printf '%s\n' \
		'server {' \
		'    listen 80;' \
		'    server_name $(name).localhost;' \
		'    root /var/www/$(name);' \
		'    index index.php index.html;' \
		'    location / { try_files $$uri $$uri/ /index.php?$$query_string; }' \
		'    location ~ \.php$$ {' \
		'        include fastcgi_params;' \
		'        fastcgi_param SCRIPT_FILENAME $$document_root$$fastcgi_script_name;' \
		'        fastcgi_pass php85:9000;' \
		'    }' \
		'}' > Nginx/conf.d/$(name).conf
	@$(COMPOSE) exec -T nginx nginx -s reload
	@echo ""
	@echo "Project '$(name)' is ready:"
	@echo "  code : ./projects/$(name)"
	@echo "  vhost: ./Nginx/conf.d/$(name).conf"
	@echo "  open : http://$(name).localhost:$$(sed -n 's/^NGINX_PORT=//p' .env 2>/dev/null || echo 8000)/"
