#!/bin/bash

# Set debug to true
echo "Enabling debug mode"
paster --plugin=ckan config-tool $CKAN_INI -s DEFAULT "debug = true"

# Update the plugins setting in the ini file with the values defined in the env var
echo "Loading the following plugins: $CKAN__PLUGINS"
paster --plugin=ckan config-tool $CKAN_INI "ckan.plugins = $CKAN__PLUGINS"

# Run the prerun script to init CKAN and create the default admin user
sudo -u ckan -EH python prerun.py

# Run any startup scripts provided by images extending this one
if [[ -d "/docker-entrypoint.d" ]]
then
    for f in /docker-entrypoint.d/*; do
        case "$f" in
            *.sh)     echo "$0: Running init file $f"; . "$f" ;;
            *.py)     echo "$0: Running init file $f"; python "$f"; echo ;;
            *)        echo "$0: Ignoring $f (not an sh or py file)" ;;
        esac
        echo
    done
fi

supervisord --configuration /etc/supervisord.conf
