#!/bin/bash

apt-get update -o Acquire::CompressionTypes::Order::=gz
apt-get install --no-install-recommends -y apt-transport-https ca-certificates \
   wget curl sudo git make cmake gcc build-essential bc unzip apt-utils lsb-release \
   libreadline-dev zlib1g-dev flex bison libxml2-dev libxslt-dev libssl-dev libxml2-utils \
   xsltproc ccache libbrotli-dev liblzo2-dev libsodium-dev libc6-dev krb5-multidev libkrb5-dev \
   postgresql-server-dev-${PG_SERVER_VERSION} libpq-dev libcurl4-openssl-dev python2 \
   python3 pkg-config clang g++ libc++-dev libc++abi-dev libglib2.0-dev libtinfo5 ninja-build binutils libicu-dev

# pgauditlogtofile extension
cd /tmp && wget --quiet -O /tmp/pgauditlogtofile-${PGAUDITLOGTOFILE_VERSION}.tar.gz \
  https://github.com/fmbiete/pgauditlogtofile/archive/refs/tags/v${PGAUDITLOGTOFILE_VERSION}.tar.gz \
  && tar zxf /tmp/pgauditlogtofile-${PGAUDITLOGTOFILE_VERSION}.tar.gz \
  && cd /tmp/pgauditlogtofile-${PGAUDITLOGTOFILE_VERSION} && make USE_PGXS=1 && make USE_PGXS=1 install

