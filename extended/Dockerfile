FROM ubuntu:18.04

ARG PG_SERVER_VERSION

ENV PG_SERVER_VERSION=${PG_SERVER_VERSION:-12} \
    DEBIAN_FRONTEND=noninteractive

# Set up apt, add Postgres repo.
RUN apt-get update \
    && apt-get install -y gnupg2 ca-certificates wget make gcc unzip \
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" >> /etc/apt/sources.list.d/pgdg.list \
    && wget --quiet --output-document - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && apt-get update && apt-get install -y apt-utils sudo

# Install Postgres and postgres-specific packages.
RUN apt-get install -y postgresql-${PG_SERVER_VERSION}

# We don't want to use standard Ubuntu pgdata.
RUN rm -rf /var/lib/postgresql/${PG_SERVER_VERSION}/

RUN apt-get install -y postgresql-contrib-${PG_SERVER_VERSION}
RUN apt-get install -y postgresql-server-dev-${PG_SERVER_VERSION}
RUN apt-get install -y postgresql-${PG_SERVER_VERSION}-pg-stat-kcache
RUN apt-get install -y postgresql-client-${PG_SERVER_VERSION}
RUN if [ "${PG_SERVER_VERSION}" = "12" ]; then \
        apt-get install -y postgresql-plpython3-${PG_SERVER_VERSION}; \
    else \
        apt-get install -y postgresql-plpython-${PG_SERVER_VERSION}; \
    fi

RUN apt-get install -y pgreplay \
    && apt-get install -y pspg \
    && apt-get install -y postgresql-${PG_SERVER_VERSION}-repack \
    && apt-get install -y postgresql-${PG_SERVER_VERSION}-hypopg \
    && apt-get install -y postgresql-${PG_SERVER_VERSION}-hypopg-dbgsym

RUN if [ "${PG_SERVER_VERSION}" = "12" ]; then \
        # pg_hint_plan for Postgres 12 does not supported yet, use master: https://github.com/ossc-db/pg_hint_plan/issues/37
        wget --quiet -O /tmp/pg_hint_plan.zip https://github.com/ossc-db/pg_hint_plan/archive/master.zip \
            && unzip /tmp/pg_hint_plan.zip -d /tmp && cd /tmp/pg_hint_plan-master \
            && make && sudo make install || echo "[WARNING] pg_hint_plan extension not found"; \
    else \
        # convert versions with dot "9.6" to "96"
        export PG_PLAN_HINT_VERSION=$(echo $PG_SERVER_VERSION | sed 's/\.//') \
        && wget --quiet -O /tmp/pg_hint_plan.zip https://github.com/ossc-db/pg_hint_plan/archive/PG${PG_PLAN_HINT_VERSION}.zip \
            && unzip /tmp/pg_hint_plan.zip -d /tmp && cd /tmp/pg_hint_plan-PG${PG_PLAN_HINT_VERSION} \
            && make && sudo make install || echo "[WARNING] pg_hint_plan extension not found"; \
    fi

# Generate english locale for iostat + iostat-tool.
RUN locale-gen en_US.UTF-8

# Reduce images size.
RUN rm -rf /tmp/* && \
    apt-get purge -y --auto-remove && \
    apt-get clean -y autoclean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 5432

# Prepare Postgres start script.
RUN echo "#!/bin/bash" > /pg_start.sh && chmod a+x /pg_start.sh
RUN echo "chown -R postgres:postgres /var/lib/postgresql/pgdata /var/run/postgresql" >> /pg_start.sh
RUN printf "sudo -u postgres /usr/lib/postgresql/${PG_SERVER_VERSION}/bin/postgres -D /var/lib/postgresql/pgdata \n" >> /pg_start.sh

# Infinite sleep to allow restarting Postgres.
RUN echo "/bin/bash -c \"trap : TERM INT; sleep infinity & wait\"" >> /pg_start.sh

CMD ["/pg_start.sh"]
