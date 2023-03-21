#!bin/bash

sudo docker compose up -d --build

. ./set-config-ckan.sh

sudo docker exec ckan /usr/local/bin/ckan -c /etc/ckan/production.ini datastore set-permissions | sudo docker exec -i db psql -U ckan

sudo docker container inspect db | grep IPAddress

psql -U ckan -h 172.28.0.3 -d datastore -f dump_badata_datastore_dev.sql

psql -U ckan -h 172.28.0.3 -d ckan -f dump_badata_ckan_dev.sql

sudo docker exec -it ckan bash && ckan -c /etc/ckan/production.ini search-index rebuild