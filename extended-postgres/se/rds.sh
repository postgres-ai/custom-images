#!/bin/bash

apt-get update -o Acquire::CompressionTypes::Order::=gz
apt-get install --no-install-recommends -y apt-transport-https ca-certificates \
   wget curl sudo git make cmake gcc build-essential bc unzip apt-utils lsb-release \
   libreadline-dev zlib1g-dev flex bison libxml2-dev libxslt-dev libssl-dev libxml2-utils \
   xsltproc ccache libbrotli-dev liblzo2-dev libsodium-dev libc6-dev krb5-multidev libkrb5-dev \
   postgresql-server-dev-${PG_SERVER_VERSION} libpq-dev libcurl4-openssl-dev python2 \
   python3 pkg-config clang g++ libc++-dev libc++abi-dev libglib2.0-dev libtinfo5 ninja-build binutils libicu-dev \
   libaio1 libaio-dev

# aws_commons extension
# Mocked

# aws_lambda extension
# Mocked

# aws_s3 extension
if [ "$(echo "$PG_SERVER_VERSION > 10" | /usr/bin/bc)" = "1" ]; then \
  apt-get install -y --no-install-recommends postgresql-plpython3-"${PG_SERVER_VERSION}" \
  && cd /tmp && git clone https://github.com/chimpler/postgres-aws-s3.git \
  && cd postgres-aws-s3 && pg_config && make && make install;
fi

# pg_hint_plan extension
# already in the "Generic" image

# pg_proctab extension
if [ "$(echo "$PG_SERVER_VERSION > 9.6" | /usr/bin/bc)" = "1" ]; then \
  cd /tmp && git clone https://gitlab.com/pg_proctab/pg_proctab.git \
  && cd pg_proctab && make && make install;
fi

# postgis extension
# (+ address_standardizer, postgis_raster, postgis_sfcgal, postgis_tiger_geocoder, postgis_topology)
apt-get install -y --no-install-recommends \
   postgresql-${PG_SERVER_VERSION}-postgis-${POSTGIS_VERSION} \
   postgresql-${PG_SERVER_VERSION}-postgis-${POSTGIS_VERSION}-scripts

# pgrouting extension
apt-get install -y --no-install-recommends \
   postgresql-${PG_SERVER_VERSION}-pgrouting

# hll extension
# already in the "Generic" image

# ip4r extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-ip4r

# oracle_fdw extension
mkdir -p /opt/oracle/instantclient && cd /tmp \
&& wget --quiet -O /tmp/instantclient-basiclite.zip https://download.oracle.com/otn_software/linux/instantclient/218000/instantclient-basiclite-linux.x64-21.8.0.0.0dbru.zip \
&& wget --quiet -O /tmp/instantclient-sdk.zip https://download.oracle.com/otn_software/linux/instantclient/218000/instantclient-sdk-linux.x64-21.8.0.0.0dbru.zip \
&& unzip /tmp/instantclient-basiclite.zip && unzip /tmp/instantclient-sdk.zip && mv /tmp/instantclient_21_8/* /opt/oracle/instantclient \
&& git clone https://github.com/laurenz/oracle_fdw.git \
&& cd oracle_fdw \
&& make \
&& make install \
&& echo /opt/oracle/instantclient > /etc/ld.so.conf.d/oracle.conf && ldconfig

# log_fdw extension
# Mocked
# This extension allowing access database engine log using a SQL interface.

# orafce extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-orafce

# pg_bigm extension
PG_BIGM_VERSION="1.2-20200228" \
&& cd /tmp && wget --quiet -O /tmp/pg_bigm-${PG_BIGM_VERSION}.tar.gz https://osdn.net/dl/pgbigm/pg_bigm-${PG_BIGM_VERSION}.tar.gz \
&& tar zxf pg_bigm-${PG_BIGM_VERSION}.tar.gz && cd pg_bigm-${PG_BIGM_VERSION} \
&& make USE_PGXS=1 PG_CONFIG=/usr/bin/pg_config && make USE_PGXS=1 PG_CONFIG=/usr/bin/pg_config install

# pg_cron extension
# already in the "Generic" image

# pg_partman extension
if [ "$(echo "$PG_SERVER_VERSION > 9.6" | /usr/bin/bc)" = "1" ]; then \
  apt-get install -y --no-install-recommends \
    postgresql-${PG_SERVER_VERSION}-partman
fi

# pg_repack extension
# already in the "Generic" image

# pg_similarity extension
apt-get install -y --no-install-recommends \
    postgresql-${PG_SERVER_VERSION}-similarity

# pg_transport extension
# Mocked
# This extension provides a physical transport mechanism to move PostgreSQL databases between two Amazon RDS DB instances.
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/PostgreSQL.TransportableDB.html

# pgaudit extension
# already in the "Generic" image

# pglogical extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-pglogical

# pgtap extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-pgtap

# plperl extension
# (+ bool_plperl + hstore_plperl + jsonb_plperl)
apt-get install -y --no-install-recommends \
  postgresql-plperl-${PG_SERVER_VERSION}

# flow_control extension
# Mocked

# plprofiler extension
if [ "$(echo "$PG_SERVER_VERSION > 9.6" | /usr/bin/bc)" = "1" ]; then \
  apt-get install -y --no-install-recommends \
    postgresql-${PG_SERVER_VERSION}-plprofiler;
fi

# pltcl extension
apt-get install -y --no-install-recommends \
  postgresql-pltcl-${PG_SERVER_VERSION}

# pg_tle extension
# Mocked
# Trusted-Language Extensions for PostgreSQL.

# prefix extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-prefix

# rdkit extension
# Mocked
# RDKit is a collection of cheminformatics and machine-learning software written in C++ and Python.

# rds_tools extension
# Mocked

# tds_fdw extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-tds-fdw

# test_parser extension
cd /tmp && git clone https://github.com/r888888888/test_parser.git \
&& cd test_parser && make && make install

# tsearch2 extension (deprecated)
# The tsearch2 extension is deprecated in version 10.
# The tsearch2 extension was remove from PostgreSQL version 11.1 on Amazon RDS (deprecated).

# mysql_fdw extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-mysql-fdw

# plv8 extension (+ plcoffee, plls)
cd /tmp && tar zxf plv8.tar.gz
mkdir -p /usr/lib/postgresql/${PG_SERVER_VERSION}/lib/bitcode/plv8-${PLV8_VERSION}/
mkdir -p /usr/share/postgresql/${PG_SERVER_VERSION}/extension/
cp plv8-output/lib/plv8* /usr/lib/postgresql/${PG_SERVER_VERSION}/lib/
cp plv8-output/lib/bitcode/plv8-${PLV8_VERSION}.index.bc /usr/lib/postgresql/${PG_SERVER_VERSION}/lib/bitcode/ || true
cp plv8-output/lib/bitcode/plv8-${PLV8_VERSION}/* /usr/lib/postgresql/${PG_SERVER_VERSION}/lib/bitcode/plv8-${PLV8_VERSION}/  || true
cp plv8-output/extension/plv8* /usr/share/postgresql/${PG_SERVER_VERSION}/extension/
cp plv8-output/extension/plls* /usr/share/postgresql/${PG_SERVER_VERSION}/extension/
cp plv8-output/extension/plcoffee* /usr/share/postgresql/${PG_SERVER_VERSION}/extension/

# remove all auxiliary packages to reduce final image size
cd / && rm -rf /tmp/* && apt-get purge -y --auto-remove wget curl apt-transport-https apt-utils lsb-release bc \
&& apt-get clean -y autoclean \
&& rm -rf /var/lib/apt/lists/*
