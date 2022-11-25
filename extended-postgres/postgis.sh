#!/bin/bash

# postgis extension
# (+ address_standardizer, postgis_raster, postgis_sfcgal, postgis_tiger_geocoder, postgis_topology)
apt-get install -y --no-install-recommends \
   postgresql-${PG_SERVER_VERSION}-postgis-${POSTGIS_VERSION} \
   postgresql-${PG_SERVER_VERSION}-postgis-${POSTGIS_VERSION}-scripts

# pgrouting extension
apt-get install -y --no-install-recommends \
   postgresql-${PG_SERVER_VERSION}-pgrouting
