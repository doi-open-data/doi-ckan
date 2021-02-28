.PHONY: admin build clean finalize-harvest test prune up requirements

build-prod:
ifeq ($(nocache),"TRUE")
	docker build --no-cache -t doi-ckan:latest ckan/
else
	docker build -t doi-ckan:latest ckan/
endif
	docker-compose build

build:
ifeq ($(nocache),"TRUE")
	docker build --no-cache --build-arg CKAN_ENV=development -t doi-ckan:latest ckan/
	docker-compose build --no-cache
else
	docker build --build-arg CKAN_ENV=development -t doi-ckan:latest ckan/
	docker-compose build
endif

check-harvests:
	python tools/harvest_source_import/list_harvest_sources.py --file_name report-prod
	python tools/harvest_source_import/list_harvest_sources.py --origin_url http://localhost:5000 --file_name report-local
	python tools/harvest_source_import/produce_summary.py

clean:
	docker-compose down -v --remove-orphans

finalize-harvest:
	docker-compose exec ckan-worker supervisorctl start ckan-worker-run

hop-in:
	docker-compose exec ckan-web /bin/bash

prune:
	docker system prune -a

requirements:
	docker-compose run --rm -T ckan-web pip --quiet freeze > ckan/requirements-freeze.txt

seed-harvests:
	python tools/harvest_source_import/import_harvest_sources.py
	docker-compose exec ckan-worker bash -c 'paster --plugin=ckanext-harvest harvester job-all -c $CKAN_INI'

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

up-prod:
	docker-compose up -d
	docker-compose stop ckan-web ; docker-compose run --service-ports --use-aliases ckan-web /srv/app/start_ckan_web.sh