.PHONY: admin build clean finalize-harvest test seed-data up update-dependencies

admin:
	docker-compose exec ckan-web paster --plugin=ckan sysadmin add admin -c /srv/app/production.ini

build:
	docker-compose build

clean:
	docker-compose down -v --remove-orphans

finalize-harvest:
	docker-compose exec ckan-worker supervisorctl start ckan-worker-run

hop-in:
	docker-compose exec ckan-web /bin/bash

prune:
	docker system prune -a
	
seed-data:
	docker-compose exec ckan-web paster --plugin=ckan create-test-data -c /srv/app/production.ini

up:
	docker-compose up