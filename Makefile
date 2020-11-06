.PHONY: all build clean copy-src local requirements setup test up update-dependencies

build:
	docker-compose build

up:
	docker-compose up

clean:
	docker-compose down -v

prune:
	docker system prune -a