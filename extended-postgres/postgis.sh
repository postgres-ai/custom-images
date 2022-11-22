#!/bin/bash

# postgis extension
apt-get install -y --no-install-recommends \
   postgresql-${PG_SERVER_VERSION}-postgis-${POSTGIS_VERSION} \
   postgresql-${PG_SERVER_VERSION}-postgis-${POSTGIS_VERSION}-scripts

# citus extension
if [ $(echo "$PG_SERVER_VERSION > 10" | /usr/bin/bc) = "1" ]; then \
   if [ "${PG_SERVER_VERSION}" = "11" ]; then CITUS_VERSION="10.0"; \
   elif [ "${PG_SERVER_VERSION}" = "12" ]; then CITUS_VERSION="10.2"; \
   elif [ "${PG_SERVER_VERSION}" = "13" ]; then CITUS_VERSION="11.1"; \
   elif [ "${PG_SERVER_VERSION}" = "14" ]; then CITUS_VERSION="11.1"; \
   elif [ "${PG_SERVER_VERSION}" = "15" ]; then CITUS_VERSION="11.1"; \
   fi \
  && curl -s https://install.citusdata.com/community/deb.sh | bash \
  && apt-get install --no-install-recommends -y \
   postgresql-"${PG_SERVER_VERSION}"-citus-"${CITUS_VERSION}"; \
fi
