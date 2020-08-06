ARG PG_SERVER_VERSION=9.6
ARG CITUS=9.4

FROM postgres:${PG_SERVER_VERSION}
MAINTAINER postgres.ai


ARG PG_SERVER_VERSION
ENV PG_SERVER_VERSION=${PG_SERVER_VERSION:-12}
ENV CITUS_VERSION=9.4

RUN apt-get update \
    && apt-get install --no-install-recommends -y wget make gcc unzip sudo git curl libc6-dev apt-transport-https ca-certificates\
    && apt-get install --no-install-recommends -y postgresql-server-dev-${PG_SERVER_VERSION} \
    && apt-get install --no-install-recommends -y postgresql-${PG_SERVER_VERSION}-repack \
    && apt-get install --no-install-recommends -y postgresql-${PG_SERVER_VERSION}-hypopg \
    && apt-get install --no-install-recommends -y postgresql-${PG_SERVER_VERSION}-hypopg-dbgsym 

RUN if [ "${PG_SERVER_VERSION}" = "12" ]; then \
        # pg_hint_plan for Postgres 12 does not supported yet, use master: https://github.com/ossc-db/pg_hint_plan/issues/37
        wget --quiet -O /tmp/pg_hint_plan.zip https://github.com/ossc-db/pg_hint_plan/archive/master.zip \
            && unzip /tmp/pg_hint_plan.zip -d /tmp && cd /tmp/pg_hint_plan-master \
            && make && make install || echo "[WARNING] pg_hint_plan extension not found"; \
    else \
        # convert versions with dot "9.6" to "96"
        export PG_PLAN_HINT_VERSION=$(echo $PG_SERVER_VERSION | sed 's/\.//') \
        && wget --quiet -O /tmp/pg_hint_plan.zip https://github.com/ossc-db/pg_hint_plan/archive/PG${PG_PLAN_HINT_VERSION}.zip \
            && unzip /tmp/pg_hint_plan.zip -d /tmp && cd /tmp/pg_hint_plan-PG${PG_PLAN_HINT_VERSION} \
            && make && make install || echo "[WARNING] pg_hint_plan extension not found"; \
    fi

# add timescaledb extension
RUN echo 'deb https://packagecloud.io/timescale/timescaledb/debian/' `env -i bash -c '. /etc/os-release; echo $VERSION_CODENAME'`  'main' > /etc/apt/sources.list.d/timescaledb.list \
    && wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey | sudo apt-key add - \
    && apt-get update \
    && apt-get install -y timescaledb-postgresql-${PG_SERVER_VERSION}


# add citus extension
RUN if [ "${PG_SERVER_VERSION}" = "12" ] || [ "${PG_SERVER_VERSION}" = "11" ]; then \
    # only 11 and 12 versions are supported by citus
    curl -s https://install.citusdata.com/community/deb.sh | bash \
        && apt-get install -y postgresql-${PG_SERVER_VERSION}-citus-${CITUS_VERSION} \
                          postgresql-${PG_SERVER_VERSION}-hll=2.14.citus-1 \
                          postgresql-${PG_SERVER_VERSION}-topn=2.3.0; \
    fi
# add powa extension
RUN apt-get install postgresql-${PG_SERVER_VERSION}-powa

# add pg_timetable extension
RUN wget https://github.com/cybertec-postgresql/pg_timetable/releases/download/v2.3.0/pg_timetable_2.3.0_Linux_x86_64.deb \
    && dpkg -i pg_timetable_2.3.0_Linux_x86_64.deb \
    && rm -rf pg_timetable_2.3.0_Linux_x86_64.deb

# add pg_show_plans extension
RUN git clone https://github.com/cybertec-postgresql/pg_show_plans.git 
WORKDIR /pg_show_plans 
RUN export USE_PGXS=1 && make && make install
WORKDIR /

# add pg_cron extension
RUN apt-get -y install postgresql-${PG_SERVER_VERSION}-cron

# Reduce images size.
RUN rm -rf /tmp/* \
    && apt-get purge -y --auto-remove gcc make wget unzip curl libc6-dev apt-transport-https git postgresql-server-dev-${PG_SERVER_VERSION} \
    && apt-get clean -y autoclean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /pg_show_plans \
    # We don't want to use standard pgdata.
    && rm -rf /var/lib/postgresql/${PG_SERVER_VERSION}/ 

EXPOSE 5432

# Prepare Postgres start script.
RUN echo "#!/bin/bash" > /pg_start.sh && chmod a+x /pg_start.sh \
    && echo "chown -R postgres:postgres /var/lib/postgresql/pgdata /var/run/postgresql" >> /pg_start.sh \
    && printf "sudo -u postgres /usr/lib/postgresql/${PG_SERVER_VERSION}/bin/postgres -D /var/lib/postgresql/pgdata \n" >> /pg_start.sh \
    # Infinite sleep to allow restarting Postgres.
    && echo "/bin/bash -c \"trap : TERM INT; sleep infinity & wait\"" >> /pg_start.sh

CMD ["/pg_start.sh"]
