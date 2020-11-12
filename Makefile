.PHONY: build clean test up update-dependencies

build:
	docker-compose build

clean:
	docker-compose down -v

prune:
	docker system prune -a
	
up:
	docker-compose up