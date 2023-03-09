FROM nginx:stable-alpine

ENV NGINX_DIR=/etc/nginx

RUN mkdir -p ${NGINX_DIR}/sites-available
RUN mkdir -p ${NGINX_DIR}/sites-enabled
RUN mkdir -p ${NGINX_DIR}/certs

COPY setup/sites-available/* ${NGINX_DIR}/sites-available/
COPY setup/ckan-local.* ${NGINX_DIR}/certs/
COPY setup/nginx.conf ${NGINX_DIR}
COPY error.html /usr/share/nginx/html/
COPY index.html /usr/share/nginx/html/

RUN ln -s ${NGINX_DIR}/sites-available/ckan.conf ${NGINX_DIR}/sites-enabled/ckan.conf

EXPOSE 80