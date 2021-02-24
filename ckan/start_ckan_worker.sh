#!/bin/bash

# Update the plugins setting in the ini file with the values defined in the env var
echo "Loading the following plugins: $CKAN__PLUGINS"
paster --plugin=ckan config-tool $CKAN_INI \
  "ckan.plugins = $CKAN__PLUGINS" \
  "ckanext.geodatagov.fgdc2iso_service = $CKANEXT__GEODATAGOV__FGDC2ISO__SERVICE"

# Wait for the ckan-web service to be serving traffic before starting
function wait_for () {
  local host=$1
  local port=$2

  while ! nc -z -w 5 "$host" "$port"; do
    sleep 1
  done
}

wait_for $1 $2

chown root:root /etc/crontabs/root && /usr/sbin/crond -f & 
supervisord --configuration /etc/supervisord.conf
