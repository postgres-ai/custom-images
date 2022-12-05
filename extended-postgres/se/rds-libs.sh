#!/bin/bash

set -ex

apt-get update -o Acquire::CompressionTypes::Order::=gz
apt-get install --no-install-recommends -y apt-transport-https ca-certificates \
   wget curl sudo git make cmake gcc build-essential bc unzip apt-utils lsb-release \
   libreadline-dev zlib1g-dev flex bison libxml2-dev libxslt-dev libssl-dev libxml2-utils \
   xsltproc ccache libbrotli-dev liblzo2-dev libsodium-dev libc6-dev krb5-multidev libkrb5-dev \
   postgresql-server-dev-${PG_SERVER_VERSION} libpq-dev libcurl4-openssl-dev python2 \
   python3 pkg-config clang g++ libc++-dev libc++abi-dev libglib2.0-dev libtinfo5 ninja-build binutils libicu-dev \
   libaio1 libaio-dev

# aws_s3 extension
# Install extension and replace version from 0.0.1 to 1.1 to avoid warnings
if [ "$(echo "$PG_SERVER_VERSION > 10" | /usr/bin/bc)" = "1" ]; then \
  apt-get install -y --no-install-recommends postgresql-plpython3-"${PG_SERVER_VERSION}" \
  && cd /tmp && git clone https://github.com/chimpler/postgres-aws-s3.git \
  && cd postgres-aws-s3 && pg_config && make && make install \
  && mv /usr/share/postgresql/${PG_SERVER_VERSION}/extension/aws_s3--0.0.1.sql /usr/share/postgresql/${PG_SERVER_VERSION}/extension/aws_s3--1.1.sql
fi

# pg_proctab extension
if [ "$(echo "$PG_SERVER_VERSION > 9.6" | /usr/bin/bc)" = "1" ]; then \
  cd /tmp && git clone https://gitlab.com/pg_proctab/pg_proctab.git \
  && cd pg_proctab && make && make install;
fi

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

# pg_bigm extension
PG_BIGM_VERSION="1.2-20200228" \
&& cd /tmp && wget --quiet -O /tmp/pg_bigm-${PG_BIGM_VERSION}.tar.gz https://osdn.net/dl/pgbigm/pg_bigm-${PG_BIGM_VERSION}.tar.gz \
&& tar zxf pg_bigm-${PG_BIGM_VERSION}.tar.gz && cd pg_bigm-${PG_BIGM_VERSION} \
&& make USE_PGXS=1 PG_CONFIG=/usr/bin/pg_config && make USE_PGXS=1 PG_CONFIG=/usr/bin/pg_config install

# pg_tle extension
if [ "$(echo "$PG_SERVER_VERSION > 13" | /usr/bin/bc)" = "1" ]; then \
  cd /tmp && git clone --branch v${PG_TLE_VERSION} --single-branch https://github.com/aws/pg_tle.git \
  && cd pg_tle && make && make install
fi

# test_parser extension
cd /tmp && git clone https://github.com/r888888888/test_parser.git \
&& cd test_parser && make && make install

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

# babelfish extensions
# babelfishpg_money (compatible with PostgreSQL 13,14)
if [ "$(echo "$PG_SERVER_VERSION > 12" | /usr/bin/bc)" = "1" ] && [ "$(echo "$PG_SERVER_VERSION < 15" | /usr/bin/bc)" = "1" ]; then \
  cd /tmp && git clone --branch BABEL_2_3_STABLE --single-branch https://github.com/babelfish-for-postgresql/babelfish_extensions.git
  cd babelfish_extensions/contrib/babelfishpg_money && make PG_CONFIG=/usr/bin/pg_config && make PG_CONFIG=/usr/bin/pg_config install
fi
# Mocked
# babelfishpg_common
# babelfishpg_tds
# babelfishpg_telemetry
# babelfishpg_tsql
