#!/bin/bash

# remove the "beta" and "rc" suffix in the PG_SERVER_VERSION variable (if exists)
PG_SERVER_VERSION="$( echo ${PG_SERVER_VERSION} | sed 's/beta.*//' | sed 's/rc.*//' )"

apt-get clean && rm -rf /var/lib/apt/lists/partial \
&& apt-get update -o Acquire::CompressionTypes::Order::=gz \
&& apt-get install --no-install-recommends -y apt-transport-https ca-certificates \
   wget curl sudo bc lsb-release apt-utils

# pgsodium requirements
apt-get install --no-install-recommends -y libsodium23

# plpython3 (procedural language implementation for Python 3.x)
apt-get install --no-install-recommends -y postgresql-plpython3-${PG_SERVER_VERSION}

# pgrouting extension
apt-get install -y --no-install-recommends postgresql-${PG_SERVER_VERSION}-pgrouting

# amcheck extension; not included in contrib for Postgres 9.6
if [ "${PG_SERVER_VERSION}" = "9.6" ]; then \
   apt-get install --no-install-recommends -y postgresql-9.6-amcheck;
fi

# pg_repack extension
apt-get install --no-install-recommends -y \
  postgresql-${PG_SERVER_VERSION}-repack

# hypopg extension
apt-get install --no-install-recommends -y \
   postgresql-${PG_SERVER_VERSION}-hypopg \
   postgresql-${PG_SERVER_VERSION}-hypopg-dbgsym

# pgaudit extension
apt-get install --no-install-recommends -y \
   postgresql-${PG_SERVER_VERSION}-pgaudit

# powa extension
apt-get install --no-install-recommends -y \
    postgresql-${PG_SERVER_VERSION}-powa

# hll extension
apt-get install --no-install-recommends -y \
    postgresql-"${PG_SERVER_VERSION}"-hll

# topn extension
if [ $(echo "$PG_SERVER_VERSION > 9.6" | /usr/bin/bc) = "1" ]; then \
   curl -s https://install.citusdata.com/community/deb.sh | bash \
   && apt-get install --no-install-recommends -y \
      postgresql-"${PG_SERVER_VERSION}"-topn;
fi

# pg_timetable extension
wget https://github.com/cybertec-postgresql/pg_timetable/releases/download/v${PG_TIMETABLE_VERSION}/pg_timetable_${PG_TIMETABLE_VERSION}_Linux_x86_64.deb \
  && dpkg -i pg_timetable_${PG_TIMETABLE_VERSION}_Linux_x86_64.deb \
  && rm -rf pg_timetable_${PG_TIMETABLE_VERSION}_Linux_x86_64.deb

# pg_cron extension
if [ $(echo "$PG_SERVER_VERSION < 15" | /usr/bin/bc) = "1" ]; then \
   apt-get install --no-install-recommends -y \
   postgresql-${PG_SERVER_VERSION}-cron;
fi

# pg_stat_monitor extension (available for versions 11, 12, 13 and 14)
if [ $(echo "$PG_SERVER_VERSION > 10" | /usr/bin/bc) = "1" ] && [ $(echo "$PG_SERVER_VERSION < 15" | /usr/bin/bc) = "1" ]; then \
   cd /tmp && curl -O https://repo.percona.com/apt/percona-release_latest.generic_all.deb \
   && apt-get install --no-install-recommends -y \
      ./percona-release_latest.generic_all.deb \
   && apt-get update \
   && percona-release setup ppg${PG_SERVER_VERSION} \
   && apt-get install --no-install-recommends -y \
      percona-pg-stat-monitor${PG_SERVER_VERSION};
fi

# pg_stat_kcache extension
apt-get install --no-install-recommends -y \
    postgresql-${PG_SERVER_VERSION}-pg-stat-kcache

# pg_wait_sampling extension
apt-get install --no-install-recommends -y \
    postgresql-${PG_SERVER_VERSION}-pg-wait-sampling

# pg_qualstats extension
apt-get install --no-install-recommends -y \
    postgresql-${PG_SERVER_VERSION}-pg-qualstats

# pgextwlist extension
apt-get install --no-install-recommends -y \
    postgresql-${PG_SERVER_VERSION}-pgextwlist

# plpgsql_check extension
apt-get install --no-install-recommends -y \
    postgresql-${PG_SERVER_VERSION}-plpgsql-check

# pljava extension
if [ $(echo "$PG_SERVER_VERSION < 15" | /usr/bin/bc) = "1" ]; then \
   apt-get install --no-install-recommends -y \
      postgresql-${PG_SERVER_VERSION}-pljava;
fi

# rum extension
if [ $(echo "$PG_SERVER_VERSION < 15" | /usr/bin/bc) = "1" ]; then \
   apt-get install --no-install-recommends -y \
      postgresql-${PG_SERVER_VERSION}-rum;
fi

# pgtap extension
apt-get install --no-install-recommends -y \
       postgresql-${PG_SERVER_VERSION}-pgtap

# pgBackRest
apt-get install --no-install-recommends -y \
       pgbackrest zstd openssh-client \
       && mkdir -p -m 700 /var/lib/postgresql/.ssh \
       && chown postgres:postgres /var/lib/postgresql/.ssh

# remove all auxilary packages to reduce final image size
cd / && rm -rf /tmp/* && apt-get purge -y --auto-remove \
       wget curl apt-transport-https apt-utils lsb-release bc \
apt-get clean -y autoclean \
rm -rf /var/lib/apt/lists/*

# remove standard pgdata
rm -rf /var/lib/postgresql/${PG_SERVER_VERSION}/
