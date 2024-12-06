install:
	docker compose run --rm composer install
	cp src/.env.example src/.env
	docker compose run --rm artisan key:generate --ansi

