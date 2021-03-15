#!/bin/bash

# Update the plugins setting in the ini file with the values defined in the env var
echo "Loading the following plugins: $CKAN__PLUGINS"
paster --plugin=ckan config-tool $CKAN_INI \
  "ckan.plugins = $CKAN__PLUGINS" \
  "ckanext.geodatagov.fgdc2iso_service = $CKANEXT__GEODATAGOV__FGDC2ISO__SERVICE"

# Wait for the ckan-web service to initialize all components (DB, SOLR, Redis, etc)
#  before starting harvest processes. Pass `wait_for_init web-host port` in command to implement
function wait_for () {
  local host=$1
  local port=$2
  local retries=50

  while ! nc -z -w 5 "$host" "$port"; do
    if [ "$retries" -le 0 ]; then
      # Continue on trying to use the services to run jobs/harvest...
      return 0
    fi
    retries=$(( $retries - 1 ))
    sleep 5
  done
}

if [ "$1" = "wait_for_init" ] ; then
  wait_for $2 $3
  "${@:4}"
else
  # Run any extra commands given in the command line, such as solr reindex
  "$@"
fi

chown root:root /etc/crontabs/root && /usr/sbin/crond -f & 
supervisord --configuration /etc/supervisord.conf
