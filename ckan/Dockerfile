# FROM openknowledge/ckan-base:2.8 -- in future, may use this as well
FROM openknowledge/ckan-base:2.8

ARG APP_DIR=/srv/app
# specify the build arg (either development or prod)
ARG CKAN_ENV=PROD

ENV GIT_BRANCH=2.8

ENV SRC_EXTENSIONS_DIR=/srv/app/src_extensions

# Shapely Error
ADD http://download.osgeo.org/geos/geos-3.7.0.tar.bz2 /geos/geos.tar.bz2
RUN tar xf /geos/geos.tar.bz2 -C /geos --strip-components=1
RUN cd /geos && \
    ./configure && \
    make -j 1 && \
    make install

COPY requirements.txt ${APP_DIR}/requirements.txt

# some errors installing cryptography with the ckan-base image see:
# https://github.com/geerlingguy/JJG-Ansible-Windows/issues/28#ref-commit-b854e7a
RUN apk add --no-cache libffi-dev openssl-dev python3-dev

RUN pip install "pip>=0.20.3.4,<21.0" && pip install -r requirements.txt
COPY docker-entrypoint.d/* /docker-entrypoint.d/

COPY start_ckan_web.sh ${APP_DIR}

COPY prerun.py ${APP_DIR}

COPY start_ckan_worker.sh ${APP_DIR}
COPY supervisor.worker.conf /etc/supervisord.d/worker.conf
COPY harvest-run-cron /etc/crontabs/root

COPY configs/export.map.json src/ckanext-datajson/ckanext/datajson/export_map/export.map.json

# Dev additions
RUN if [ "${CKAN_ENV}" = "development" ]; then \
        apk add vim; \
        pip install --no-binary :all: -r https://raw.githubusercontent.com/ckan/ckan/${GIT_BRANCH}/dev-requirements.txt; \
        mkdir $SRC_EXTENSIONS_DIR; \
    fi

COPY start_ckan_web_dev.sh ${APP_DIR}
