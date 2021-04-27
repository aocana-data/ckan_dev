#!/bin/bash
# Set CKAN en espaniol
sudo docker exec ckan ckan config-tool /etc/ckan/production.ini "ckan.locale_default=es"

# Set Activity streams public
sudo docker exec ckan ckan config-tool /etc/ckan/production.ini "ckan.auth.public_activity_stream_detail = true"

# Add plugins in config-file
sudo docker exec ckan ckan config-tool /etc/ckan/production.ini "ckan.plugins = stats text_view image_view recline_view datastore xloader hierarchy_display hierarchy_form gobar_theme"

# De necesitarse los plugins seriestiempoexplorer & harvest
#sudo docker exec ckan ckan config-tool /etc/ckan/production.ini "ckan.plugins = stats text_view image_view recline_view datastore xloader hierarchy_display hierarchy_form gobar_theme seriestiempoarexplorer harvest ckan_harvester"

## Configuración en el config-file de CKAN para el Xloader
sudo docker exec ckan ckan config-tool /etc/ckan/production.ini "ckanext.xloader.jobs_db.uri = postgresql://ckan:ckan@db/ckan"
