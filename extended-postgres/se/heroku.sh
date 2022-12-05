#!/bin/bash

set -ex

apt-get clean && rm -rf /var/lib/apt/lists/partial \
&& apt-get update -o Acquire::CompressionTypes::Order::=gz \
&& apt-get install --no-install-recommends -y apt-transport-https ca-certificates \
  bc lsb-release apt-utils

# postgis extension
# (+ address_standardizer, postgis_raster, postgis_sfcgal, postgis_tiger_geocoder, postgis_topology)
apt-get install -y --no-install-recommends \
   postgresql-${PG_SERVER_VERSION}-postgis-${POSTGIS_VERSION} \
   postgresql-${PG_SERVER_VERSION}-postgis-${POSTGIS_VERSION}-scripts

# pg_partman extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-partman

# pgaudit extension
# already in the "Generic" image

# pgauditlogtofile extension
# copy from build-env

# remove all auxiliary packages to reduce final image size
apt-get purge -y --auto-remove \
  apt-transport-https apt-utils lsb-release bc
apt-get clean -y autoclean
rm -rf /var/lib/apt/lists/*
