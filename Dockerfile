FROM ubuntu:focal-20210119

# Set timezone
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Setting the locale
ENV LC_ALL=en_US.UTF-8       
RUN apt-get update
RUN apt-get install --no-install-recommends -y locales
RUN sed -i "/$LC_ALL/s/^# //g" /etc/locale.gen
RUN dpkg-reconfigure --frontend=noninteractive locales 
RUN update-locale LANG=${LC_ALL}

# Install required system packages
RUN apt-get -q -y update \
    && DEBIAN_FRONTEND=noninteractive apt-get -q -y upgrade \
    && apt-get -q -y install \
	    python3.8 \
        python3-dev \
        python3-pip \
        python3-venv \
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
	    curl \
        supervisor \
    && apt-get -q clean \
    && rm -rf /var/lib/apt/lists/*

# Define environment variables
ENV CKAN_HOME=/usr/lib/ckan
ENV CKAN_VENV=$CKAN_HOME/venv
ENV CKAN_CONFIG=/etc/ckan
ENV CKAN_STORAGE_PATH=/var/lib/ckan

# Build-time variables specified by docker-compose.yml / .env
ARG CKAN_SITE_URL

# Create ckan user
RUN useradd -r -u 900 -m -c "ckan account" -d $CKAN_HOME -s /bin/false ckan

# Setup virtual environment for CKAN
RUN mkdir -p $CKAN_VENV $CKAN_CONFIG $CKAN_STORAGE_PATH && \
    python3 -m venv $CKAN_VENV && \
    ln -s $CKAN_VENV/bin/pip3 /usr/local/bin/ckan-pip3 &&\
    ln -s $CKAN_VENV/bin/ckan /usr/local/bin/ckan

ENV PATH=${CKAN_VENV}/bin:${PATH}

# Setup CKAN
ADD . $CKAN_VENV/src/ckan/
RUN ckan-pip3 install -U pip && \
    ckan-pip3 install --upgrade --no-cache-dir -r $CKAN_VENV/src/ckan/requirement-setuptools.txt && \
    ckan-pip3 install --upgrade --no-cache-dir -r $CKAN_VENV/src/ckan/requirements.txt && \
    ckan-pip3 install -e $CKAN_VENV/src/ckan/ && \
    ln -s $CKAN_VENV/src/ckan/ckan/config/who.ini $CKAN_CONFIG/who.ini && \
    cp -v $CKAN_VENV/src/ckan/contrib/docker/ckan-entrypoint.sh /ckan-entrypoint.sh && \
    chmod +x /ckan-entrypoint.sh && \
    chown -R ckan:ckan $CKAN_HOME $CKAN_VENV $CKAN_CONFIG $CKAN_STORAGE_PATH

# Setup plugins (GoogleAnalytics debe estar al final siempre.)
ENV CKAN_PLUGINS stats text_view image_view recline_view datastore xloader hierarchy_display hierarchy_form gobar_theme webpage_view datapusher seriestiempoarexplorer harvest ckan_harvester

# Xloader
RUN ckan-pip3 install ckanext-xloader && \
    ckan-pip3 install -r https://raw.githubusercontent.com/ckan/ckanext-xloader/master/requirements.txt && \
    ckan-pip3 install -U requests[security] && \
    cp /usr/lib/ckan/venv/src/ckan/ckan/config/supervisor-ckan-worker.conf /etc/supervisor/conf.d && \
    sed -i 's/default/venv/' /etc/supervisor/conf.d/supervisor-ckan-worker.conf && \
    sed -i 's/default//' /etc/supervisor/conf.d/supervisor-ckan-worker.conf && \
    sed -i 's/ckan.ini/production.ini/' /etc/supervisor/conf.d/supervisor-ckan-worker.conf && \
    mkdir -m 777 /var/log/ckan/ && \
    cat > /var/log/ckan/ckan-worker.stdout.log && \
    supervisord

#Hierarchy
RUN cd /usr/lib/ckan/venv/src && \
    ckan-pip3 install -e "git+https://github.com/davidread/ckanext-hierarchy.git#egg=ckanext-hierarchy" && \
    ckan-pip3 install -r ckanext-hierarchy/requirements.txt

#Harvest
RUN ckan-pip3 install -e git+https://github.com/ckan/ckanext-harvest.git#egg=ckanext-harvest && \
    cd /usr/lib/ckan/venv/src/ckanext-harvest/ && \
    ckan-pip3 install -r pip-requirements.txt

#SeriesTiempoArExplorer
RUN ckan-pip3 install -e git+https://github.com/datosgobar/ckanext-seriestiempoarexplorer.git#egg=ckanext-seriestiempoarexplorer

#Gobar_theme
USER root
RUN ckan-pip3 install -e "git+https://github.com/datosgcba/ckanext-gcbaandinotheme.git@ckan_gcba#egg=ckanext-gobar_theme"

ENTRYPOINT ["/ckan-entrypoint.sh"]

EXPOSE 5000

CMD ["ckan","-c","/etc/ckan/production.ini", "run", "--host", "0.0.0.0"]
