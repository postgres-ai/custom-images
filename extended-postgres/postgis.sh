#!/bin/bash

# remove the "beta" and "rc" suffix in the PG_SERVER_VERSION variable (if exists)
PG_SERVER_VERSION="$( echo ${PG_SERVER_VERSION} | sed 's/beta.*//' | sed 's/rc.*//' )"

apt-get clean && rm -rf /var/lib/apt/lists/partial \
&& apt-get update -o Acquire::CompressionTypes::Order::=gz \
&& apt-get install --no-install-recommends -y \
   apt-transport-https ca-certificates lsb-release apt-utils

# postgis extension
# (+ address_standardizer, postgis_raster, postgis_sfcgal, postgis_tiger_geocoder, postgis_topology)
apt-get install -y --no-install-recommends \
   postgresql-${PG_SERVER_VERSION}-postgis-${POSTGIS_VERSION} \
   postgresql-${PG_SERVER_VERSION}-postgis-${POSTGIS_VERSION}-scripts

# pgrouting extension
apt-get install -y --no-install-recommends \
   postgresql-${PG_SERVER_VERSION}-pgrouting

# remove all auxiliary packages to reduce final image size
apt-get purge -y --auto-remove \
  apt-transport-https ca-certificates lsb-release apt-utils
apt-get clean -y autoclean
rm -rf /var/lib/apt/lists/*
