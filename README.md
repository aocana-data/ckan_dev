# ckan

Impementacion de Python3 en contenedor de Ckan 2.9

## Verificar que ckan corre bajo python3.6+

Al compilar la iagen no debe arrojar el siguiente error

DEPRECATION: Python 2.7 reached the end of its life on January 1st, 2020. Please upgrade your Python as Python 2.7 is no longer maintained. pip 21.0 will drop support for Python 2.7 in January 2021. More details about Python 2 support in pip can be found at https://pip.pypa.io/en/latest/development/release-process/#python-2-support pip 21.0 will remove support for this functionality.

## Verificacion numero 2
source /usr/lib/ckan/venv/bin/activate

python --version

La respuesta será ... Python 3.8.6 (o una version superior)


## Agregar usuario admin

ckan -c /etc/ckan/production.ini sysadmin add admin email=admin@example.com name=administrador

