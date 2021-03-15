.PHONY: admin build clean finalize-harvest test prune up requirements

build:
	docker build -t doi-ckan:latest ckan/
	docker-compose build

build-dev:
	docker build --build-arg CKAN_ENV=development -t doi-ckan:dev ckan/
	docker-compose build

check-harvests:
	python tools/harvest_source_import/list_harvest_sources.py --file_name report-prod
	python tools/harvest_source_import/list_harvest_sources.py --origin_url http://localhost:5000 --file_name report-local
	python tools/harvest_source_import/produce_summary.py

clean:
	docker-compose down -v --remove-orphans

debug:
	docker-compose run --service-ports ckan-web

finalize-harvest:
	docker-compose exec ckan-worker supervisorctl start ckan-worker-run

hop-in:
	docker-compose exec ckan-web /bin/bash

prune:
	docker system prune -a

requirements:
	docker-compose run --rm -T ckan-web /requirements/requirements.sh

seed-harvests:
	python tools/harvest_source_import/import_harvest_sources.py
	docker-compose exec ckan-worker bash -c 'paster --plugin=ckanext-harvest harvester job-all -c $CKAN_INI'

test:
	curl --silent --fail http://localhost:5000

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