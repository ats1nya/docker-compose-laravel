# Variables
DC = docker compose
USER = ats1nya
APP = php

RED=\033[0;31m
GREEN=\033[0;32m
BLUE=\033[0;34m
YELLOW=\033[0;33m
NC=\033[0m


build:
	$(DC) build

rebuild: down
	$(DC) build --no-cache

up:
	@echo '$(GREEN) 🐬 Docker UP...$(NC)';
	@$(DC) up -d --remove-orphans --force-recreate

down:
	@echo '$(BLUE) 🐬 Docker Down$(NC)';
	@$(DC) down

stop:
	@echo '$(YELLOW) 🐬 Docker Stop.$(NC)';
	@$(DC) stop

restart: down up

install:
	$(DC) run --rm composer install
	cp src/.env.example src/.env
	$(DC) run --rm artisan key:generate --ansi

migrate:
	$(DC) exec $(APP) php artisan migrate

rollback:
	$(DC) exec $(APP) php artisan migrate:rollback

npm-watch:
	$(DC) run --rm node npm run watch

npm-dev:
	$(DC) run --rm node npm run dev

shell:
	@clear
	@echo '$(GREEN) ⚡ Entering Bash Shell...$(NC)';
	@$(DC) exec -it $(APP) zsh

shell-root:
	@clear
	@echo '$(GREEN) ⚡ Entering $(YELLOW) (Root) $(GREEN) Bash Shell...$(NC)';
	@$(DC) exec -uroot $(APP) zsh

shell-node:
	$(DC) run --rm node sh

# Laravel artisan commands
route:
	$(DC) exec $(APP) php artisan route:list --except-vendor

ssh-dev:
	ssh -i ~/.ssh/a_tsinya www-data@172.32.29.20

ssh-deploy-dev:
	ssh -i ~/.ssh/a_tsinya www-data@172.32.29.20 'cd casino.nuxdev.ga && git pull origin dev'

ssh-deploy-dev-npm:
	ssh -i ~/.ssh/a_tsinya www-data@172.32.29.20 '\
		cd casino.nuxdev.ga && \
		git pull origin dev && \
		nvm use 10 && npm run dev \
	'