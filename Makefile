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

test-import-tool:
	cd tools/harvest_source_import && \
		pip install --upgrade pip  && \
		pip install -r dev-requirements.txt && \
		flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics  && \
		flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics  && \
		python -m pytest --vcr-record=none tests/

test-user:
	docker-compose exec ckan-worker paster --plugin=ckan user add test-user password=test-user-password email=test@doi.gov -c /srv/app/production.ini | grep -oP "apikey.: u.\K.+" | cut -d "'" -f1 > api.key
	docker-compose exec ckan-worker paster --plugin=ckan sysadmin add test-user -c /srv/app/production.ini

test-user-remove:
	docker-compose exec ckan-worker paster --plugin=ckan user remove test-user
	docker-compose exec ckan-worker bash -c 'psql $$CKAN_SQLALCHEMY_URL -c "DELETE FROM ONLY public.user where state != '"'active'"';"'

up:
	docker-compose up