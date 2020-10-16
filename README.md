# ckan

Impementacion de Python3 en contenedor de Ckan 2.9

## Verificar que ckan corre bajo python2.7

Al compilar la iagen arroja repetidas veces el siguiente error

s-0.5.1 weberror-0.13.1 webhelpers-1.3 webob-1.0.8 webtest-1.4.3 werkzeug-0.15.5 zope.interface-4.3.2

DEPRECATION: Python 2.7 reached the end of its life on January 1st, 2020. Please upgrade your Python as Python 2.7 is no longer maintained. pip 21.0 will drop support for Python 2.7 in January 2021. More details about Python 2 support in pip can be found at https://pip.pypa.io/en/latest/development/release-process/#python-2-support pip 21.0 will remove support for this functionality.

Obtaining file:///usr/lib/ckan/venv/src/ckan
  Installing build dependencies: started
  Installing build dependencies: finished with status 'done'

## Verificacion numero 2
source /usr/lib/ckan/venv/bin/activate

python --version

La versión de python confirmará que es 2.7.13