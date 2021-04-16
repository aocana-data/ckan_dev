# Ckan

Impementacion de Python3.7.9 en contenedor de Ckan 2.9.2

## Verificar que ckan corre bajo python3.6+

Al compilar la imagen no debe arrojar el siguiente error

DEPRECATION: Python 2.7 reached the end of its life on January 1st, 2020. Please upgrade your Python as Python 2.7 is no longer maintained. pip 21.0 will drop support for Python 2.7 in January 2021. More details about Python 2 support in pip can be found at https://pip.pypa.io/en/latest/development/release-process/#python-2-support pip 21.0 will remove support for this functionality.

## Verificacion numero 2

- docker-compose exec ckan bash

- source /usr/lib/ckan/venv/bin/activate

- python --version

La respuesta será ... Python 3.7.9


## Implentacion con Docker

1. clonar el repositorio

- git clone --branch develop-ckan2.9.2-py3.7.2 https://repositorio-asi.buenosaires.gob.ar/ssppbe_usig/ckan.git

2. Editar el archivo de variables de entorno

- cd ckan/contrib/docker

- vi .env

``` 
Asegurarse de editar las siguientes variables

CKAN_SITE_ID = 127.0.0.1

CKAN_SITE_URL= http://localhost:5000

CKAN_PORT= 5000

POSTGRES_PASSWORD = ckan

POSTGRES_PORT = 5432

DATASTORE_READONLY_PASSWORD = datastore

```

4. Compilar la imagen docker e iniciar el stack

- sudo docker-compose up -d --build

Despues de este paso, CKAN debería estar corriendo en CKAN_SITE_URL en su versión original.

5. Setear los permisos necesarios para que el datastore funcione correctamente.

- sudo docker exec ckan /usr/local/bin/ckan -c /etc/ckan/production.ini datastore set-permissions | sudo docker exec -i db psql -U ckan

6. Ingresar al contenedor CKAN y activar los plugins.

- sudo docker-compose exec ckan 
- vim /etc/ckan/production.ini
- agregar en la linea de plugins:
    datastore xloader hierarchy_display hierarchy_form gobar_theme

7. Reiniciar si es necesario el contenedor CKAN 

- sudo docker-compose restart ckan

Despues de este paso, CKAN con los plugins debería estar corriendo en CKAN_SITE_URL.

Chequear los logs
- docker logs -f ckan

## Agregar usuario admin

- sudo docker-compose exec ckan ckan -c /etc/ckan/production.ini sysadmin add administrador


Este comando crea un usuario para iniciar sesion. Las credenciales son

usuario: administrador
password: se ingresa al momento de crear el usuario