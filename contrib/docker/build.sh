sudo docker-compose down
sudo docker volume rm docker_ckan_home docker_ckan_config
sudo docker-compose up -d --build

while true;do echo -n .;sleep 1;done &
sleep 30 # or do something else here
kill $!; trap 'kill $!' SIGTERM
echo done
. ./set-config-ckan.sh


