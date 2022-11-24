#!/bin/bash

apt-get update -o Acquire::CompressionTypes::Order::=gz
apt-get install --no-install-recommends -y apt-transport-https ca-certificates \
   wget curl sudo git make cmake gcc build-essential bc unzip apt-utils lsb-release \
   libreadline-dev zlib1g-dev flex bison libxml2-dev libxslt-dev libssl-dev libxml2-utils \
   xsltproc ccache libbrotli-dev liblzo2-dev libsodium-dev libc6-dev krb5-multidev libkrb5-dev \
   postgresql-server-dev-${PG_SERVER_VERSION} libpq-dev libcurl4-openssl-dev python2 \
   python3 pkg-config clang g++ libc++-dev libc++abi-dev libglib2.0-dev libtinfo5 ninja-build binutils

# aws_commons extension
# TODO

# aws_lambda extension
# TODO

# aws_s3 extension
# TODO

# pg_hint_plan extension
if [ $(echo "$PG_SERVER_VERSION < 14" | /usr/bin/bc) = "1" ]; then \
   export PG_PLAN_HINT_VERSION=$(echo $PG_SERVER_VERSION | sed 's/\.//') \
   && wget --quiet -O /tmp/pg_hint_plan.zip \
     https://github.com/ossc-db/pg_hint_plan/archive/PG${PG_PLAN_HINT_VERSION}.zip \
   && unzip /tmp/pg_hint_plan.zip -d /tmp \
     && cd /tmp/pg_hint_plan-PG${PG_PLAN_HINT_VERSION} \
     && make && make install;
  # there is no branch "PG14", use the tag "REL14_1_4_0"
  elif [ "${PG_SERVER_VERSION}" = "14" ]; then \
     wget --quiet -O /tmp/pg_hint_plan.zip \
     https://github.com/ossc-db/pg_hint_plan/archive/REL14_1_4_0.zip \
   && unzip /tmp/pg_hint_plan.zip -d /tmp \
     && cd /tmp/pg_hint_plan-REL14_1_4_0 \
     && make && make install;
fi

# pg_proctab extension
if [ $(echo "$PG_SERVER_VERSION > 9.6" | /usr/bin/bc) = "1" ]; then \
  cd /tmp && git clone https://gitlab.com/pg_proctab/pg_proctab.git \
  && cd pg_proctab && make && make install;
fi

# postgis extension
# (+ address_standardizer, postgis_raster, postgis_sfcgal, postgis_tiger_geocoder, postgis_topology)
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-postgis-${POSTGIS_VERSION} \
  postgresql-${PG_SERVER_VERSION}-postgis-${POSTGIS_VERSION}-scripts

# hll extension
apt-get install -y --no-install-recommends \
  postgresql-"${PG_SERVER_VERSION}"-hll

# ip4r extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-ip4r

# oracle_fdw extension
# TODO

# log_fdw extension
# TODO

# orafce extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-orafce

# pg_bigm extension
# TODO

# pg_cron extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-cron

# pg_partman extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-pg_partman

# pg_repack extension
apt-get install -y --no-install-recommends \
    postgresql-${PG_SERVER_VERSION}-repack

# pg_similarity extension
apt-get install -y --no-install-recommends \
    postgresql-${PG_SERVER_VERSION}-similarity

# pg_transport extension
# TODO

# pgaudit extension
apt-get install -y --no-install-recommends \
   postgresql-${PG_SERVER_VERSION}-pgaudit

# pglogical extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-pglogical

# pgrouting extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-pgrouting

# pgtap extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-pgtap


# plperl extension
# (+ bool_plperl + hstore_plperl + jsonb_plperl)
apt-get install -y --no-install-recommends \
  postgresql-plperl-${PG_SERVER_VERSION}

# flow_control extension
# TODO

# plprofiler extension
if [ $(echo "$PG_SERVER_VERSION > 9.6" | /usr/bin/bc) = "1" ]; then \
  apt-get install -y --no-install-recommends \
    postgresql-${PG_SERVER_VERSION}-plprofiler;
fi

# pltcl extension
apt-get install -y --no-install-recommends \
  postgresql-pltcl-${PG_SERVER_VERSION}

# pg_tle extension
# TODO

# prefix extension
apt-get install -y --no-install-recommends \
  postgresql-14-prefix

# rdkit extension
# TODO

# rds_tools extension
# TODO

# tds_fdw extension
# TODO

# test_parser extension
# TODO

# tsearch2 extension
# TODO

# mysql_fdw extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-mysql-fdw

# plv8 extension (+ plcoffee, plls)
# TODO
