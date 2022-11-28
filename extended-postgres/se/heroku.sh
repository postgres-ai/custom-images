#!/bin/bash

apt-get update -o Acquire::CompressionTypes::Order::=gz
apt-get install --no-install-recommends -y apt-transport-https ca-certificates \
   wget curl sudo git make cmake gcc build-essential bc unzip apt-utils lsb-release \
   libreadline-dev zlib1g-dev flex bison libxml2-dev libxslt-dev libssl-dev libxml2-utils \
   xsltproc ccache libbrotli-dev liblzo2-dev libsodium-dev libc6-dev krb5-multidev libkrb5-dev \
   postgresql-server-dev-${PG_SERVER_VERSION} libpq-dev libcurl4-openssl-dev python2 \
   python3 pkg-config clang g++ libc++-dev libc++abi-dev libglib2.0-dev libtinfo5 ninja-build binutils libicu-dev

# postgis extension
# (+ address_standardizer, postgis_raster, postgis_sfcgal, postgis_tiger_geocoder, postgis_topology)
apt-get install -y --no-install-recommends \
   postgresql-${PG_SERVER_VERSION}-postgis-${POSTGIS_VERSION} \
   postgresql-${PG_SERVER_VERSION}-postgis-${POSTGIS_VERSION}-scripts

# pg_partman extension
if [ "$(echo "$PG_SERVER_VERSION > 9.6" | /usr/bin/bc)" = "1" ]; then \
  cd /tmp && wget --quiet -O /tmp/pg_partman-${PG_PARTMAN_VERSION}.tar.gz \
    https://github.com/pgpartman/pg_partman/archive/refs/tags/v${PG_PARTMAN_VERSION}.tar.gz \
    && tar zxf /tmp/pg_partman-${PG_PARTMAN_VERSION}.tar.gz \
    && cd /tmp/pg_partman-${PG_PARTMAN_VERSION} && make USE_PGXS=1 && make USE_PGXS=1 install
fi

# pgaudit extension
# already in the "Generic" image

# pgauditlogtofile extension
cd /tmp && wget --quiet -O /tmp/pgauditlogtofile-${PGAUDITLOGTOFILE_VERSION}.tar.gz \
  https://github.com/fmbiete/pgauditlogtofile/archive/refs/tags/v${PGAUDITLOGTOFILE_VERSION}.tar.gz \
  && tar zxf /tmp/pgauditlogtofile-${PGAUDITLOGTOFILE_VERSION}.tar.gz \
  && cd /tmp/pgauditlogtofile-${PGAUDITLOGTOFILE_VERSION} && make USE_PGXS=1 && make USE_PGXS=1 install

# remove all auxiliary packages to reduce final image size
cd / && rm -rf /tmp/* && apt-get purge -y --auto-remove wget curl apt-transport-https apt-utils lsb-release bc \
&& apt-get clean -y autoclean \
&& rm -rf /var/lib/apt/lists/*
