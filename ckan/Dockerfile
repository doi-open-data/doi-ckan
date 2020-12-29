# FROM openknowledge/ckan-base:2.8 -- in future, may use this as well
FROM openknowledge/ckan-dev:2.8

MAINTAINER Open Knowledge International <info@okfn.org>

ENV GIT_BRANCH=2.8

# add vim
RUN apk add vim

# Shapely Error

ADD http://download.osgeo.org/geos/geos-3.7.0.tar.bz2 /geos/geos.tar.bz2
RUN tar xf /geos/geos.tar.bz2 -C /geos --strip-components=1
RUN cd /geos && \
    ./configure && \
    make -j 1 && \
    make install

COPY requirements-freeze.txt ${APP_DIR}

RUN pip install --upgrade pip && pip install -r requirements-freeze.txt
COPY docker-entrypoint.d/* /docker-entrypoint.d/

COPY start_ckan_web_dev.sh ${APP_DIR}
# production
COPY start_ckan_web.sh ${APP_DIR}

COPY prerun.py ${APP_DIR}

COPY start_ckan_worker.sh ${APP_DIR}
COPY supervisor.worker.conf /etc/supervisord.d/worker.conf
COPY harvest-run-cron /etc/crontabs/root