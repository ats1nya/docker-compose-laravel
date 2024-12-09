build:
	docker compose build

rebuild:
	docker compose build --no-cache

up:
	docker compose up -d --remove-orphans

down:
	docker compose down

restart: down up

install:
	docker compose run --rm composer install
	cp src/.env.example src/.env
	docker compose run --rm artisan key:generate --ansi

shell:
	docker compose exec php sh
