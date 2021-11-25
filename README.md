# Ckan

Impementado con Python3.7.9 y Ckan 2.9.2 en contenedor Docker.

## Verificar que ckan corre bajo python3.6+

Al compilar la imagen no debe arrojar el siguiente error

DEPRECATION: Python 2.7 reached the end of its life on January 1st, 2020. Please upgrade your Python as Python 2.7 is no longer maintained. pip 21.0 will drop support for Python 2.7 in January 2021. More details about Python 2 support in pip can be found at https://pip.pypa.io/en/latest/development/release-process/#python-2-support pip 21.0 will remove support for this functionality.

## Verificacion interna

Verificar version de python en el contenedor `ckan`:

    docker-compose exec ckan bash
    source /usr/lib/ckan/venv/bin/activate
    python --version

  La respuesta debería ser `Python 3.7.9`. También se puede ver el estado de la instalación utilizando la ruta:

    http://CKAN_SITE_URL/api/3/action/status_show


## Implentacion con Docker

Clonar el repositorio:

    git clone -b produ-ckan2.9 https://repositorio-asi.buenosaires.gob.ar/ssppbe_usig/ckan.git


Verificar las variables de entorno del archivo `Dockerfile`:

    cd ckan
    nano Dockerfile

```bash
Asegurarse de editar las variables con la configuración que corresponda

#Habilitar los plugins que crea correspondientes
ENV CKAN__PLUGINS stats text_view image_view recline_view datastore xloader hierarchy_display hierarchy_form gobar_theme dcat dcat_rdf_harvester dcat_json_harvester dcat_json_interface structured_data googleanalytics

Para configurar el google analytics, ademas de agregarlo en la lista de plugins, hay que modificar los parametros comentados en el Dockerfile en la linea ##Settings googleanalytics`

Repetir los mismos pasos en `contrib/docker/set-config-ckan.sh`

```


Asegurarse de que el puerto 5000 esta libre:

    sudo netstat -pna | grep 5000

  De no estarlo, cierre el servicio que usa este puerto antes de continuar.


Compilar la imagen docker e iniciar el stack:

    . ./build.sh

  Despues de crearse los contenedores hay que esperar unos segundos para que se configure el ckan.


Setear los permisos necesarios para que el datastore funcione correctamente.:

    sudo docker exec ckan /usr/local/bin/ckan -c /etc/ckan/production.ini datastore set-permissions | sudo docker exec -i db psql -U ckan


Iniciar el harvester de ser necesario (Opcional):

    sudo docker exec ckan ckan --config=/etc/ckan/production.ini harvester initdb


Cargar db inicial con recursos (Solo en Localhost):

  Se debe hacer restore de las dbs `ckan` y `datastore`

  Los archivos dump se encuentran en `/db_dumps` (se deben descomprimir antes del restore).

  Eliminar las dbs creadas por defecto en el contenedor 'db' y crear 2 dbs nuevas. LLamarlas 'ckan' y 'datastore'.

  Para saber la ip del contenedor con la db, ejecutar:

    docker network inspect docker_default

  Y correr restore:

    psql -U ckan -h {ip del contenedor de db} -d ckan -f dump_badata_ckan_dev.sql
    psql -U ckan -h {ip del contenedor de db} -d datastore -f dump_badata_datastore_dev.sql


Si no se visualizan los datasets en la pagina principal del portal,
  correr reindex desde contanedor de ckan:

    sudo docker exec -it ckan bash
    ckan -c /etc/ckan/production.ini search-index rebuild

## Chequear los logs

    docker logs -f ckan

## Control del Xloader

Para ingresar al contenedor de CKAN como root:

    sudo docker exec -it -u 0 ckan bash

Controlar si se encuentra corriendo el proceso Xloader del CKAN:

    supervisorctl status

  Debería devolver algo así: `ckan-worker:ckan-worker-00       RUNNING`
  Si devuelve `unix:///var/run/supervisor.sock no such file`, ejecutar el comado que se encuentra abajo

    supervisord

Rechequear nuevamente:

    supervisorctl

Se abre una consola. Salir con Ctrl + d.

Ver los logs del Xloader:

    cat /var/log/ckan/ckan-worker.stderr.log


## Agregar usuario administrador

Ingresar al contenedor de ckan:

    sudo docker-compose exec ckan bash

Crear el admin-user:
    
    ckan -c /etc/ckan/production.ini sysadmin add administrador

Para ingresar como administrador, entrar desde:

    http://ip:5000/ingresar


## Configuraciones Adicionales (Opcional)
### Modificar rutas de redireccionamiento del header del plugin gobar_theme

Lineas 6(logo) - 12(BA Data) - 35(Historias) - 36(APIs):

    sudo vim /var/lib/docker/volumes/docker_ckan_home/_data/venv/src/ckanext-gobar-theme/ckanext/gobar_theme/templates/header.html

### Modificar la tabla de visualización de datasets(ReclineView)

Linea 193(_newDataExplorer) modificar los views que se requieran:

    sudo vim /var/lib/docker/volumes/docker_ckan_home/_data/venv/src/ckan/ckanext/reclineview/theme/public/recline_view.js


