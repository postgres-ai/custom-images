#!/bin/bash

# timescaledb extension
if [ $(echo "$PG_SERVER_VERSION > 11" | /usr/bin/bc) = "1" ] && [ $(echo "$PG_SERVER_VERSION < 15" | /usr/bin/bc) = "1" ]; then \
   echo "deb https://packagecloud.io/timescale/timescaledb/debian/ $(lsb_release -c -s) main" > /etc/apt/sources.list.d/timescaledb.list \
     && wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey | sudo apt-key add - \
     && apt-get update \
     && apt-get install --no-install-recommends -y \
        timescaledb-2-postgresql-${PG_SERVER_VERSION};
fi
