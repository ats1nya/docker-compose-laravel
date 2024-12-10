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

npm-run-dev:
	docker compose run node run dev

shell:
	docker compose exec php sh
