ARG PG_SERVER_VERSION=12

FROM postgres:${PG_SERVER_VERSION}
LABEL maintainer="postgres.ai"

ARG PG_SERVER_VERSION
ENV PG_SERVER_VERSION=${PG_SERVER_VERSION:-12}

ENV CITUS_VERSION=9.4

RUN apt-get clean && rm -rf /var/lib/apt/lists/partial \
    && apt-get update -o Acquire::CompressionTypes::Order::=gz \
    && apt-get install --no-install-recommends -y wget make gcc unzip sudo git \
       curl libc6-dev apt-transport-https ca-certificates pgxnclient bc \
       build-essential libevent-dev libssl-dev krb5-multidev \
    && apt-get install --no-install-recommends -y \
       postgresql-server-dev-${PG_SERVER_VERSION} \
    && apt-get install --no-install-recommends -y \
       postgresql-${PG_SERVER_VERSION}-repack \
    # extensions supported in PostgreSQL 12 and below 
    # bc is used to manage PostgreSQL versions with dot like 9.6
    && if [ $(echo "$PG_SERVER_VERSION < 13" | /usr/bin/bc) = "1" ]; then \
     # hypopg
     apt-get install --no-install-recommends -y \
         postgresql-${PG_SERVER_VERSION}-hypopg \
     && apt-get install --no-install-recommends -y \
         postgresql-${PG_SERVER_VERSION}-hypopg-dbgsym \
     # pg_hint_plan extension (dots are to be skipped here, e.g., "9.6" -> "96")
     && export PG_PLAN_HINT_VERSION=$(echo $PG_SERVER_VERSION | sed 's/\.//') \
       && wget --quiet -O /tmp/pg_hint_plan.zip \
         https://github.com/ossc-db/pg_hint_plan/archive/PG${PG_PLAN_HINT_VERSION}.zip \
       && unzip /tmp/pg_hint_plan.zip -d /tmp \
         && cd /tmp/pg_hint_plan-PG${PG_PLAN_HINT_VERSION} \
         && make && make install \
     # timescaledb extension
     && echo 'deb https://packagecloud.io/timescale/timescaledb/debian/' \
       $(env -i bash -c '. /etc/os-release; echo ${VERSION_CODENAME}') \
       'main' > /etc/apt/sources.list.d/timescaledb.list \
     && wget --quiet -O - \
         https://packagecloud.io/timescale/timescaledb/gpgkey | sudo apt-key add - \
       && apt-get update \
       && apt-get install -y timescaledb-postgresql-${PG_SERVER_VERSION} \
     # powa extension
     && apt-get install postgresql-${PG_SERVER_VERSION}-powa \
     # pg_auth_mon extension
     && git clone https://github.com/RafiaSabih/pg_auth_mon.git \
     && cd pg_auth_mon && USE_PGXS=1 make && USE_PGXS=1 make install; \
   fi \
   # citus extension; only Postgres 11 and 12 are supported by citus
   && if [ "${PG_SERVER_VERSION}" = "12" ] || [ "${PG_SERVER_VERSION}" = "11" ]; then \
      curl -s https://install.citusdata.com/community/deb.sh | bash \
      && apt-get install -y postgresql-${PG_SERVER_VERSION}-citus-${CITUS_VERSION} \
         postgresql-${PG_SERVER_VERSION}-hll=2.14.citus-1 \
         postgresql-${PG_SERVER_VERSION}-topn=2.3.0; \
      fi \
   # pg_timetable extension
   && wget https://github.com/cybertec-postgresql/pg_timetable/releases/download/v2.3.0/pg_timetable_2.3.0_Linux_x86_64.deb \
     && dpkg -i pg_timetable_2.3.0_Linux_x86_64.deb \
     && rm -rf pg_timetable_2.3.0_Linux_x86_64.deb \
   # pg_show_plans extension
   && git clone https://github.com/cybertec-postgresql/pg_show_plans.git \
     && cd pg_show_plans \
     && export USE_PGXS=1 && make && make install && cd .. && rm -rf pg_show_plans \
   # pg_cron extension
   && apt-get install -y postgresql-${PG_SERVER_VERSION}-cron \
   # postgresql_anonymizer extension
   && pgxn install ddlx && pgxn install postgresql_anonymizer \
   # pg_stat_kcache extension
   && apt-get install postgresql-${PG_SERVER_VERSION}-pg-stat-kcache \
   # add pg_qualstats extension
   && apt-get install postgresql-${PG_SERVER_VERSION}-pg-qualstats \
   # pg_mon extension
   && git clone https://github.com/CyberDem0n/bg_mon.git && cd bg_mon \
     && USE_PGXS=1 make && USE_PGXS=1 make install \
   # pgextwlist extension
   && apt-get install postgresql-${PG_SERVER_VERSION}-pgextwlist \
   # set_user extension
   && git clone https://github.com/pgaudit/set_user.git \
     && cd set_user && make USE_PGXS=1 && make USE_PGXS=1 install \
   # remove all auxilary packages to reduce final image size
   && cd / && rm -rf /tmp/* && apt-get purge -y --auto-remove gcc \
      make wget unzip curl libc6-dev apt-transport-https git \
      postgresql-server-dev-${PG_SERVER_VERSION} pgxnclient build-essential \
      libssl-dev krb5-multidev comerr-dev krb5-multidev \
      libgssrpc4 libkadm5clnt-mit11 libkadm5srv-mit11 \
     && apt-get clean -y autoclean \
     && rm -rf /var/lib/apt/lists/* \
   # remove standard pgdata
   && rm -rf /var/lib/postgresql/${PG_SERVER_VERSION}/

EXPOSE 5432

# Prepare Postgres start script
RUN echo "#!/bin/bash" > /pg_start.sh && chmod a+x /pg_start.sh \
    && echo "chown -R postgres:postgres /var/lib/postgresql/pgdata /var/run/postgresql" \
      >> /pg_start.sh \
    && printf "sudo -u postgres /usr/lib/postgresql/${PG_SERVER_VERSION}/bin/postgres -D /var/lib/postgresql/pgdata \n" \
      >> /pg_start.sh \
    # Infinite sleep to allow restarting Postgres
    && echo "/bin/bash -c \"trap : TERM INT; sleep infinity & wait\"" \
      >> /pg_start.sh

CMD ["/pg_start.sh"]
