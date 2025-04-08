# Variables
DC = docker compose
USER = ats1nya
APP = php

LOCAL_USER = a_tsinya
SSH_USER = www-data
SSH_HOST = 172.32.29.20
REMOTE_DIR = casino.nuxdev.ga

RED=\033[0;31m
GREEN=\033[0;32m
BLUE=\033[0;34m
YELLOW=\033[0;33m
NC=\033[0m

# Docker commands
up:
	@clear
	@echo '$(GREEN) 🐬 Docker UP...$(NC)';
	@$(DC) up -d --remove-orphans --force-recreate

down:
	@echo '$(BLUE) 🐬 Docker Down$(NC)';
	@$(DC) down

stop:
	@echo '$(YELLOW) 🐬 Docker Stop.$(NC)';
	@$(DC) stop

build:
	$(DC) build

rebuild: down
	$(DC) build --no-cache

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

npm:
	$(DC) run --rm node npm run $(run)

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

shell-db:
	$(DC) exec -it db bash

lint:
	$(DC) exec $(APP) ./vendor/bin/pint --diff=origin/master

test:
	$(DC) exec $(APP) vendor/bin/phpunit -c ./phpunit.xml.dist

# Laravel artisan commands
route:
	$(DC) exec $(APP) php artisan route:list --except-vendor

# Deploy commands
ssh-dev:
	ssh -i ~/.ssh/$(LOCAL_USER) $(SSH_USER)@$(SSH_HOST)

ssh-deploy-dev:
	ssh -i ~/.ssh/$(LOCAL_USER) $(SSH_USER)@$(SSH_HOST) 'cd $(REMOTE_DIR) && git pull origin dev && php artisan optimize:clear && php artisan queue:restart'

ssh-deploy-dev-npm:
	ssh -i ~/.ssh/$(LOCAL_USER) $(SSH_USER)@$(SSH_HOST) '\
		cd $(REMOTE_DIR) && \
		git pull origin dev && \
		nvm use 10 && npm run dev \
	'