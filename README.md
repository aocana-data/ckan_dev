# Ckan

Impementado con Python3.7.9 y Ckan 2.9.2 en contenedor Docker.

## Verificar que ckan corre bajo python3.6+

Al compilar la imagen no debe arrojar el siguiente error

DEPRECATION: Python 2.7 reached the end of its life on January 1st, 2020. Please upgrade your Python as Python 2.7 is no longer maintained. pip 21.0 will drop support for Python 2.7 in January 2021. More details about Python 2 support in pip can be found at https://pip.pypa.io/en/latest/development/release-process/#python-2-support pip 21.0 will remove support for this functionality.

## Verificacion interna

- docker-compose exec ckan bash

- source /usr/lib/ckan/venv/bin/activate

- python --version

La respuesta debería ser --> Python 3.7.9, también se puede ver el estado de la instalación utilizando la ruta:

- http://CKAN_SITE_URL/api/3/action/status_show

## Implentacion con Docker

1. clonar el repositorio

- git clone --branch develop-ckan2.9.2-py3.7.2 https://repositorio-asi.buenosaires.gob.ar/ssppbe_usig/ckan.git

2. Verificar las variables de entorno del archivo Dockerfile

- cd ckan
- vi Dockerfile

```
Asegurarse de editar las variables con la configuración que corresponda

ENV POSTGRES_PASSWORD=ckan
#Habilitar los plugins que crea correspondiente
ENV CKAN__PLUGINS stats text_view image_view recline_view datastore xloader hierarchy_display hierarchy_form gobar_theme

```

3. Editar el archivo de variables de entorno del docker-compose

- cd ckan/contrib/docker

- vi .env

```
Asegurarse de editar las siguientes variables con la configuración que corresponda

CKAN_SITE_ID = 127.0.0.1

CKAN_SITE_URL= http://localhost:5000

CKAN_PORT= 5000

POSTGRES_PASSWORD = ckan

POSTGRES_PORT = 5432

DATASTORE_READONLY_PASSWORD = datastore

```

4. Compilar la imagen docker e iniciar el stack

- sudo docker-compose up -d --build

Despues de este paso, CKAN debería estar corriendo en CKAN_SITE_URL.

5. Correr el script bash que se encuentra en el directorio que configura el config-file de CKAN, corrobar si el contenido es el correcto para su configuración.

- . ./set-config-ckan.sh

6. Setear los permisos necesarios para que el datastore funcione correctamente.

- sudo docker exec ckan /usr/local/bin/ckan -c /etc/ckan/production.ini datastore set-permissions | sudo docker exec -i db psql -U ckan

7. (Opcional)Iniciar el harvester de ser necesario

- sudo docker exec ckan ckan --config=/etc/ckan/production.ini harvester initdb

8. (Solo en Localhost) Cargar db inicial con recursos.

Se debe hacer restore de las dbs 'ckan' y 'datastore'

Los archivos dump se encuentran en /db_dumps (se deben descomprimir antes del restore).

Eliminar las dbs creadas por defecto en el contenedor 'db' y crear 2 dbs nuevas. LLamarlas 'ckan' y 'datastore'.

Para saber la ip del contenedor con la db, ejecutar:

- docker network inspect docker_default

Y correr restore:

- psql -U ckan -h {ip del contenedor de db} -d ckan -f dump_badata_ckan_dev.sql
- psql -U ckan -h {ip del contenedor de db} -d datastore -f dump_badata_datastore_dev.sql

9. Si no se visualizan los datasets en la pagina principal del portal,
   correr reindex desde contanedor de ckan.

- sudo docker exec -it ckan bash
- ckan -c /etc/ckan/production.ini search-index rebuild

## Chequear los logs

- docker logs -f ckan

## Control del Xloader

Para ingresar al contenedor de CKAN como root

- sudo docker exec -it -u 0 ckan bash

Controlar si se encuentra corriendo el proceso Xloader del CKAN

- supervisorctl status
  --> debería devolver algo así: ckan-worker:ckan-worker-00 RUNNING
  Si devuelve --> unix:///var/run/supervisor.sock no such file , ejecutar el comado que se encuentra abajo

Caso contrario se deberá lanzar el proceso utilizando el comando:

- supervisord

Rechequear nuevamente.

- supervisorctl

Ver los logs del Xloader

- cat /var/log/ckan/ckan-worker.stderr.log

## Agregar usuario administrador

Ingresar al contenedor de ckan

- sudo docker-compose exec ckan bash

Crear el admin-user

- ckan -c /etc/ckan/production.ini sysadmin add administrador

## Modificar rutas de redireccionamiento del header del plugin gobar_theme

Lineas 6(logo) - 12(BA Data) - 35(Historias) - 36(APIs)

- sudo vim /var/lib/docker/volumes/docker_ckan_home/\_data/venv/src/ckanext-gobar-theme/ckanext/gobar_theme/templates/header.html

## Modificar la tabla de visualización de datasets(ReclineView)

Linea 193(\_newDataExplorer) modificar los views que se requieran

- sudo vim /var/lib/docker/volumes/docker_ckan_home/\_data/venv/src/ckan/ckanext/reclineview/theme/public/recline_view.js

## ACTUALIZACION DE REPOSITORIO

ACTUALIZACIONES EN LAS DEPENDENCIAS PARA PODER UTILIZAR FLASK 2.X.X
SE ACTUALIZÓ A PYTHON 3.9.7 DE MANERA FUNCIONAL

- NO SE HA LOCALIZADO EL FOCO DEL ERROR.
- SE HA CREADO UN CONTENEDOR DE VARNISH PARA SEGUIR CON EL CONCEPTO DE ENTORNO DE PRUEBA
- SE HA GENERADO UN ENTORNO DE PRUEBA DE CARGA PARA VALIDAR LA CAPACIDAD MAX DE USUARIOS. AL MOMENTO SE HA REALIZADO UNA PRUEBA CON 60 USUARIOS SIMULTÁNEOS INGRESANDO AL PUERTO RAÍZ. LA PRUEBA SE REALIZA POR MEDIO DE LA HERRAMIENTA APACHE BENCH.

- MOMENTOS DONDE SE DISPARA EL TIEMPO DE RENDERIZACION: CUANDO SE REALIZA LA BUSQUEDA, MANTENIENDO UN PERIODO DE 1.2 SEGS
