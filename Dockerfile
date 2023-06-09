# See CKAN docs on installation from Docker Compose on usage
FROM debian:stretch

# Install required system packages
RUN apt-get -q -y update \
    && DEBIAN_FRONTEND=noninteractive apt-get -q -y upgrade \
    && apt-get -q -y install \
    python3-dev \
    python3-pip \
    python3-virtualenv \
    python3-wheel \
    libpq-dev \
    libxml2-dev \
    libxslt-dev \
    libgeos-dev \
    libssl-dev \
    libffi-dev \
    libsqlite3-dev \
    tk-dev \
    libgdbm-dev \
    libc6-dev \
    libbz2-dev \
    zlib1g-dev \
    libreadline-gplv2-dev \
    libncursesw5-dev \
    postgresql-client \
    build-essential \
    git-core \
    vim \
    wget \
    supervisor \
    && apt-get -q clean \
    && rm -rf /var/lib/apt/lists/*



# Install python 3.7.9
RUN wget https://www.python.org/ftp/python/3.9.7/Python-3.9.7.tgz && \
    tar xzf Python-3.9.7.tgz && \
    cd Python-3.9.7 && \
    ./configure --enable-optimizations && \
    make altinstall
RUN cd ..

RUN rm Python-3.9.7.tgz && \
    rm -r Python-3.9.7  


# Define environment variables
ENV CKAN_HOME /usr/lib/ckan
ENV CKAN_VENV $CKAN_HOME/venv
ENV CKAN_CONFIG /etc/ckan
ENV CKAN_STORAGE_PATH=/var/lib/ckan
ENV POSTGRES_PASSWORD=ckan

# Create ckan user
RUN useradd -r -u 900 -m -c "ckan account" -d $CKAN_HOME -s /bin/false ckan

# Setup virtual environment for CKAN
RUN mkdir -p $CKAN_VENV $CKAN_CONFIG $CKAN_STORAGE_PATH && \
    python3.9 -m  venv $CKAN_VENV $CKAN_VENV && \
    ln -s $CKAN_VENV/bin/pip3 /usr/local/bin/ckan-pip &&\
    ln -s $CKAN_VENV/bin/paster /usr/local/bin/ckan-paster &&\
    ln -s $CKAN_VENV/bin/ckan /usr/local/bin/ckan

# Setup CKAN
ADD . $CKAN_VENV/src/ckan/
RUN ckan-pip install -U pip && \
    ckan-pip install --upgrade --no-cache-dir -r $CKAN_VENV/src/ckan/requirement-setuptools.txt && \
    ckan-pip install --upgrade --no-cache-dir -r $CKAN_VENV/src/ckan/requirements.txt && \
    ckan-pip install -e $CKAN_VENV/src/ckan/ && \
    ln -s $CKAN_VENV/src/ckan/ckan/config/who.ini $CKAN_CONFIG/who.ini && \
    cp -v $CKAN_VENV/src/ckan/contrib/docker/ckan-entrypoint.sh /ckan-entrypoint.sh && \
    chmod +x /ckan-entrypoint.sh && \
    chown -R ckan:ckan $CKAN_HOME $CKAN_VENV $CKAN_CONFIG $CKAN_STORAGE_PATH


# Xloader
RUN ckan-pip install ckanext-xloader && \
    ckan-pip install -r https://raw.githubusercontent.com/ckan/ckanext-xloader/master/requirements.txt && \
    ckan-pip install -U requests[security] && \
    cp /usr/lib/ckan/venv/src/ckan/ckan/config/supervisor-ckan-worker.conf /etc/supervisor/conf.d && \
    sed -i 's/default/venv/' /etc/supervisor/conf.d/supervisor-ckan-worker.conf && \
    sed -i 's/default//' /etc/supervisor/conf.d/supervisor-ckan-worker.conf && \
    sed -i 's/ckan.ini/production.ini/' /etc/supervisor/conf.d/supervisor-ckan-worker.conf && \
    mkdir -m 777 /var/log/ckan/ && \
    cat > /var/log/ckan/ckan-worker.stdout.log && \
    supervisord

#Hierarchy
RUN cd /usr/lib/ckan/venv/src && \
    ckan-pip install -e "git+https://github.com/davidread/ckanext-hierarchy.git#egg=ckanext-hierarchy" && \
    ckan-pip install -r ckanext-hierarchy/requirements.txt

#Harvest
RUN ckan-pip install -e git+https://github.com/ckan/ckanext-harvest.git#egg=ckanext-harvest && \
    cd /usr/lib/ckan/venv/src/ckanext-harvest/ && \
    ckan-pip install -r pip-requirements.txt

#SeriesTiempoArExplorer
RUN ckan-pip install -e git+https://github.com/datosgobar/ckanext-seriestiempoarexplorer.git#egg=ckanext-seriestiempoarexplorer

#Gobar_theme
USER root
RUN ckan-pip install -e "git+https://github.com/datosgcba/ckanext-gobar-theme.git@render#egg=ckanext-gobar_theme"


#Se comenta la siguiente linea, para que funcione correctamente el pull al repo desde el entrypoint.
USER ckan
EXPOSE 5000
ENTRYPOINT ["/ckan-entrypoint.sh"]
CMD ["ckan","-c","/etc/ckan/production.ini", "run", "--host", "0.0.0.0"]