#!/bin/bash

set -ex

apt-get clean && rm -rf /var/lib/apt/lists/partial \
&& apt-get update -o Acquire::CompressionTypes::Order::=gz \
&& apt-get install --no-install-recommends -y apt-transport-https ca-certificates \
  bc lsb-release apt-utils

# pgsodium requirements
apt-get install --no-install-recommends -y libsodium23

# libgraphqlparser (required for pg_graphql)
# copy from build-env

# pg_graphql extension
# copy from build-env

# pg_jsonschema extension
# copy from build-env

# http extension
# copy from build-env

# pg_hashids extension
# copy from build-env

# pgjwt extension
# copy from build-env

# pgsodium extension
# copy from build-env

# pg_net extension
# copy from build-env

# supautils extension
# copy from build-env

# postgis extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-postgis-${POSTGIS_VERSION} \
  postgresql-${PG_SERVER_VERSION}-postgis-${POSTGIS_VERSION}-scripts

# pgrouting extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-pgrouting

# pg_stat_monitor extension
# already in the "Generic" image

# rum extension
# already in the "Generic" image

# pgtap extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-pgtap

# plpgsql_check extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-plpgsql-check

# pljava extension
if [ $(echo "$PG_SERVER_VERSION < 15" | /usr/bin/bc) = "1" ]; then \
   apt-get install -y --no-install-recommends \
      postgresql-${PG_SERVER_VERSION}-pljava;
fi

# plv8 extension
# copy from build-env

# remove all auxiliary packages to reduce final image size
apt-get purge -y --auto-remove \
  apt-transport-https apt-utils lsb-release bc
apt-get clean -y autoclean
rm -rf /var/lib/apt/lists/*
