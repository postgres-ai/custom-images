#!/bin/bash

# postgis extension
apt-get install -y --no-install-recommends \
   postgresql-${PG_SERVER_VERSION}-postgis-${POSTGIS_VERSION} \
   postgresql-${PG_SERVER_VERSION}-postgis-${POSTGIS_VERSION}-scripts
