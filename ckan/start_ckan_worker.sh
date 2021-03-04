#!/bin/bash

# Set debug to true
echo "Enabling debug mode"
paster --plugin=ckan config-tool $CKAN_INI -s DEFAULT "debug = true"

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

wait_for ckan-web 5000

chown root:root /etc/crontabs/root && /usr/sbin/crond -f &
"$@" & 
supervisord --configuration /etc/supervisord.conf
