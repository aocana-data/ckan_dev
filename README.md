# ckan

Impementacion de Python3 en contenedor de Ckan 2.9

## Verificar que ckan corre bajo python3.6+

Al compilar la iagen no debe arrojar el siguiente error

DEPRECATION: Python 2.7 reached the end of its life on January 1st, 2020. Please upgrade your Python as Python 2.7 is no longer maintained. pip 21.0 will drop support for Python 2.7 in January 2021. More details about Python 2 support in pip can be found at https://pip.pypa.io/en/latest/development/release-process/#python-2-support pip 21.0 will remove support for this functionality.

## Verificacion numero 2

- docker-compose exec ckan bash

- source /usr/lib/ckan/venv/bin/activate

- python --version

La respuesta será ... Python 3.8.6 (o una version superior)


## Implentacio con Docker

1. clonar el repositorio

- git clone https://repositorio-asi.buenosaires.gob.ar/ssppbe_usig/ckan.git

2. Editar el archivo de variables de entorno

- cd ckan/contrib/docker

- vi .env

``` Asegurarse de editar las siguientes variables

CKAN_SITE_ID=

ejemplos: 

www.portal-de-datos.com

127.0.0.1

10.0.0.10

CKAN_SITE_URL=

ejemplos:

http://192.168.0.9

https://portal-de-datos.com

http://127.0.0.1

http://10.0.0.1

CKAN_PORT=

ejemplos:

80

8080

443

5000

POSTGRES_HOST=

ejemplos:

192.168.0.9

mydb-host.com

10.10.1.10

POSTGRES_PASSWORD=

ejemplos:

example

my-secret-password

POSTGRES_PORT=

ejemplos:

5432

6000

DATASTORE_READONLY_PASSWORD=

ejemplos:

datastore

datastore-password

SuperSecretPassword

3. Compilar la imagen docker e iniciar el stack

sudo docker-compose up -d --build

4. Ingresar al sistema

Luego de crear un usuario como se explica en el capitulo Agregar usuario abrir en el navegador web la direccion que se ingreso en la variable CKAN_SITE_URL en el paso 2


## Agregar usuario admin

docker-compose exec ckan ckan -c /etc/ckan/production.ini sysadmin add admin email=admin@example.com name=administrador


Este comando crea un usuario para iniciar sesion. Las credenciales son

usuario: administrador

password: se ingresa al momento de crear el usuario