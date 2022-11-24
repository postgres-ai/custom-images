#!/bin/bash

apt-get update -o Acquire::CompressionTypes::Order::=gz
apt-get install --no-install-recommends -y apt-transport-https ca-certificates \
   wget curl sudo git make cmake gcc build-essential bc unzip apt-utils lsb-release \
   libreadline-dev zlib1g-dev flex bison libxml2-dev libxslt-dev libssl-dev libxml2-utils \
   xsltproc ccache libbrotli-dev liblzo2-dev libsodium-dev libc6-dev krb5-multidev libkrb5-dev \
   postgresql-server-dev-${PG_SERVER_VERSION} libpq-dev libcurl4-openssl-dev python2 \
   python3 pkg-config clang g++ libc++-dev libc++abi-dev libglib2.0-dev libtinfo5 ninja-build binutils

apt-get install --no-install-recommends -y \
  postgresql-${PG_SERVER_VERSION}-ip4r postgresql-${PG_SERVER_VERSION}-mysql-fdw postgresql-${PG_SERVER_VERSION}-mysql-fdw \
  postgresql-${PG_SERVER_VERSION}-orafce postgresql-${PG_SERVER_VERSION}-pglogical postgresql-14-prefix;

# plperl + bool_plperl + hstore_plperl + jsonb_plperl extensions (compatible with PostgreSQL 14)
if [ $(echo "$PG_SERVER_VERSION > 11" | /usr/bin/bc) = "1" ] && [ $(echo "$PG_SERVER_VERSION < 15" | /usr/bin/bc) = "1" ]; then \
     apt-get install --no-install-recommends -y \
        postgresql-plperl-${PG_SERVER_VERSION};
fi

# pg_proctab extension
if [ $(echo "$PG_SERVER_VERSION > 9.6" | /usr/bin/bc) = "1" ]; then \
  cd /tmp && git clone https://gitlab.com/pg_proctab/pg_proctab.git \
  && cd pg_proctab && make && make install;
fi
