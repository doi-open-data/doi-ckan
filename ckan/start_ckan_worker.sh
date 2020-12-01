#!/bin/bash

# Set debug to true
echo "Enabling debug mode"
paster --plugin=ckan config-tool $CKAN_INI -s DEFAULT "debug = true"

# Update the plugins setting in the ini file with the values defined in the env var
echo "Loading the following plugins: $CKAN__PLUGINS"
paster --plugin=ckan config-tool $CKAN_INI "ckan.plugins = $CKAN__PLUGINS"

# # Run the prerun script to init CKAN and create the default admin user
# sudo -u ckan -EH python prerun.py
sleep 100

supervisord --configuration /etc/supervisord.conf
