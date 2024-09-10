# Debian 11 (bullseye) has glibc 2.31.
# If you are using "physical" mode, please check the glibc version in your production database system to avoid potential index corruption.
# You should have the same version of glibc as in your Docker image.

ARG PG_SERVER_VERSION=16

# Build the extended image
FROM postgres:${PG_SERVER_VERSION}-bullseye
LABEL maintainer="postgres.ai"

ARG PG_SERVER_VERSION
ENV PG_SERVER_VERSION=${PG_SERVER_VERSION:-16}

ARG PG_UNIX_SOCKET_DIR
ENV PG_UNIX_SOCKET_DIR=${PG_UNIX_SOCKET_DIR:-"/var/run/postgresql"}

ARG PG_SERVER_PORT
ENV PG_SERVER_PORT=${PG_SERVER_PORT:-5432}

ARG WALG_VERSION
ENV WALG_VERSION=${WALG_VERSION:-3.0.3}

ARG PG_TIMETABLE_VERSION
ENV PG_TIMETABLE_VERSION=${PG_TIMETABLE_VERSION:-5.9.0}

ARG SET_USER_VERSION
ENV SET_USER_VERSION=${SET_USER_VERSION:-REL4_1_0}

ARG LOGERRORS_VERSION
ENV LOGERRORS_VERSION=${LOGERRORS_VERSION:-2.1.3}

ARG PGVECTOR_VERSION
ENV PGVECTOR_VERSION=${PGVECTOR_VERSION:-0.7.4}

# https://gitlab.com/postgres-ai/custom-images/-/merge_requests/56
ARG PG_CRON_VERSION
ENV PG_CRON_VERSION=${PG_CRON_VERSION:-1.4.2}


RUN apt-get clean && rm -rf /var/lib/apt/lists/partial \
    # remove the "beta" and "rc" suffix in the PG_SERVER_VERSION variable (if exists)
    && PG_SERVER_VERSION="$( echo ${PG_SERVER_VERSION} | sed 's/beta.*//' | sed 's/rc.*//' )" \
    && apt-get update -o Acquire::CompressionTypes::Order::=gz \
    && apt-get install --no-install-recommends -y wget make gcc unzip sudo git \
       curl libc6-dev apt-transport-https ca-certificates pgxnclient bc \
       build-essential libssl-dev krb5-multidev libkrb5-dev lsb-release apt-utils \
    && apt-get install --no-install-recommends -y postgresql-server-dev-${PG_SERVER_VERSION} \
    # plpython3 (procedural language implementation for Python 3.x)
    && apt-get install --no-install-recommends -y postgresql-plpython3-${PG_SERVER_VERSION} \
    # amcheck extension; not included in contrib for Postgres 9.6
    && if [ "${PG_SERVER_VERSION}" = "9.6" ]; then \
         apt-get install --no-install-recommends -y postgresql-9.6-amcheck; \
       fi \
    # pg_repack extension
    && apt-get install --no-install-recommends -y postgresql-${PG_SERVER_VERSION}-repack \
    # hypopg extension
    && apt-get install --no-install-recommends -y \
       postgresql-${PG_SERVER_VERSION}-hypopg \
       postgresql-${PG_SERVER_VERSION}-hypopg-dbgsym \
    # pgaudit extension
    && apt-get install --no-install-recommends -y postgresql-${PG_SERVER_VERSION}-pgaudit \
    # pg_hint_plan extension
    && if [ $(echo "$PG_SERVER_VERSION < 17" | /usr/bin/bc) = "1" ]; then \
         export PG_PLAN_HINT_VERSION=$(echo $PG_SERVER_VERSION | sed 's/\.//') \
         && wget --quiet -O /tmp/pg_hint_plan.zip \
           https://github.com/ossc-db/pg_hint_plan/archive/PG${PG_PLAN_HINT_VERSION}.zip \
         && unzip /tmp/pg_hint_plan.zip -d /tmp \
         && cd /tmp/pg_hint_plan-PG${PG_PLAN_HINT_VERSION} \
         && make && make install; \
       fi \
    # powa extension
    && if [ $(echo "$PG_SERVER_VERSION < 17" | /usr/bin/bc) = "1" ]; then \
         apt-get install --no-install-recommends -y postgresql-${PG_SERVER_VERSION}-powa; \
       fi \
    # pg_auth_mon extension
    && if [ $(echo "$PG_SERVER_VERSION < 16" | /usr/bin/bc) = "1" ]; then \
        if [ "${PG_SERVER_VERSION}" = "9.6" ]; then \
          cd /tmp && git clone --branch v1.0 --single-branch https://github.com/RafiaSabih/pg_auth_mon.git \
          && cd pg_auth_mon && USE_PGXS=1 make && USE_PGXS=1 make install; \
        elif [ $(echo "$PG_SERVER_VERSION > 10" | /usr/bin/bc) = "1" ]; then \
          cd /tmp && git clone --branch v2.0 --single-branch https://github.com/RafiaSabih/pg_auth_mon.git \
          && cd pg_auth_mon && USE_PGXS=1 make && USE_PGXS=1 make install; \
        fi \
      fi \
    # timescaledb extension
    && if [ $(echo "$PG_SERVER_VERSION > 11" | /usr/bin/bc) = "1" ] && [ $(echo "$PG_SERVER_VERSION < 17" | /usr/bin/bc) = "1" ]; then \
         echo "deb https://packagecloud.io/timescale/timescaledb/debian/ $(lsb_release -c -s) main" > /etc/apt/sources.list.d/timescaledb.list \
           && wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey | sudo apt-key add - \
           && apt-get update \
           && apt-get install --no-install-recommends -y \
              timescaledb-2-postgresql-${PG_SERVER_VERSION}; \
       fi \
    # citus extension
    && if [ $(echo "$PG_SERVER_VERSION > 10" | /usr/bin/bc) = "1" ] && [ $(echo "$PG_SERVER_VERSION < 17" | /usr/bin/bc) = "1" ]; then \
         if [ "${PG_SERVER_VERSION}" = "11" ]; then CITUS_VERSION="10.0"; \
         elif [ "${PG_SERVER_VERSION}" = "12" ]; then CITUS_VERSION="10.2"; \
         elif [ "${PG_SERVER_VERSION}" = "13" ]; then CITUS_VERSION="11.3"; \
         elif [ "${PG_SERVER_VERSION}" = "14" ]; then CITUS_VERSION="12.1"; \
         elif [ "${PG_SERVER_VERSION}" = "15" ]; then CITUS_VERSION="12.1"; \
         elif [ "${PG_SERVER_VERSION}" = "16" ]; then CITUS_VERSION="12.1"; \
         fi \
         && curl -s https://install.citusdata.com/community/deb.sh | bash \
         && apt-get install --no-install-recommends -y postgresql-"${PG_SERVER_VERSION}"-citus-"${CITUS_VERSION}"; \
       fi \
    # hll extension
    && apt-get install --no-install-recommends -y postgresql-"${PG_SERVER_VERSION}"-hll \
    # topn extension
    && if [ $(echo "$PG_SERVER_VERSION > 9.6" | /usr/bin/bc) = "1" ]; then \
         curl -s https://install.citusdata.com/community/deb.sh | bash \
         && apt-get install --no-install-recommends -y postgresql-"${PG_SERVER_VERSION}"-topn; \
       fi \
    # pg_timetable extension
    && wget https://github.com/cybertec-postgresql/pg_timetable/releases/download/v"${PG_TIMETABLE_VERSION}"/pg_timetable_Linux_x86_64.deb \
      && dpkg -i pg_timetable_Linux_x86_64.deb \
      && rm -rf pg_timetable_Linux_x86_64.deb \
    # pg_show_plans extension
    && if [ $(echo "$PG_SERVER_VERSION > 11" | /usr/bin/bc) = "1" ]; then \
         cd /tmp && git clone https://github.com/cybertec-postgresql/pg_show_plans.git \
         && cd pg_show_plans \
         && export USE_PGXS=1 && make && make install; \
       fi \
    # pg_cron extension
    && if [ $(echo "$PG_SERVER_VERSION > 9.6" | /usr/bin/bc) = "1" ] && [ $(echo "$PG_SERVER_VERSION < 16" | /usr/bin/bc) = "1" ]; then \
        cd /tmp && git clone --branch v${PG_CRON_VERSION} --single-branch https://github.com/citusdata/pg_cron.git \
          && cd pg_cron \
          && make && make install; \
        elif [ "${PG_SERVER_VERSION}" = "9.6" ] || [ "$PG_SERVER_VERSION" = "16" ]; then \
          apt-get install --no-install-recommends -y postgresql-${PG_SERVER_VERSION}-cron; \
       fi \
    # postgresql_anonymizer extension
    && if [ $(echo "$PG_SERVER_VERSION > 9.6" | /usr/bin/bc) = "1" ]; then \
         pgxn install ddlx && pgxn install postgresql_anonymizer; \
       fi \
    # pg_stat_kcache extension
    && apt-get install --no-install-recommends -y postgresql-${PG_SERVER_VERSION}-pg-stat-kcache \
    # pg_wait_sampling extension
    && if [ $(echo "$PG_SERVER_VERSION < 17" | /usr/bin/bc) = "1" ]; then \
         apt-get install --no-install-recommends -y postgresql-${PG_SERVER_VERSION}-pg-wait-sampling; \
       fi \
    # pg_qualstats extension
    && apt-get install --no-install-recommends -y postgresql-${PG_SERVER_VERSION}-pg-qualstats \
    # bg_mon extension
    && apt-get install -y libevent-dev libbrotli-dev \
      && cd /tmp && git clone https://github.com/CyberDem0n/bg_mon.git && cd bg_mon \
      && USE_PGXS=1 make && USE_PGXS=1 make install && cd .. \
    # pgextwlist extension
    && apt-get install --no-install-recommends -y postgresql-${PG_SERVER_VERSION}-pgextwlist \
    # set_user extension
    && if [ $(echo "$PG_SERVER_VERSION >= 12" | /usr/bin/bc) = "1" ]; then \
         cd /tmp && git clone https://github.com/pgaudit/set_user.git \
         && cd set_user && git checkout ${SET_USER_VERSION} && make USE_PGXS=1 && make USE_PGXS=1 install; \
       elif [ $(echo "$PG_SERVER_VERSION < 12" | /usr/bin/bc) = "1" ]; then \
         cd /tmp && git clone https://github.com/pgaudit/set_user.git \
         && cd set_user && git checkout REL4_0_1 && make USE_PGXS=1 && make USE_PGXS=1 install; \
       fi \
    # logerrors extension
    && if [ $(echo "$PG_SERVER_VERSION > 9.6" | /usr/bin/bc) = "1" ]; then \
         cd /tmp && wget -O logerrors.tar.gz https://github.com/munakoiso/logerrors/archive/v${LOGERRORS_VERSION}.tar.gz \
         && tar -xf logerrors.tar.gz && rm logerrors.tar.gz && cd logerrors-${LOGERRORS_VERSION} \
         && USE_PGXS=1 make && USE_PGXS=1 make install; \
       fi \
    # pgvector extension
    && if [ $(echo "$PG_SERVER_VERSION >= 12" | /usr/bin/bc) = "1" ]; then \
        cd /tmp && git clone --branch v${PGVECTOR_VERSION} https://github.com/pgvector/pgvector.git \
        && cd pgvector && make OPTFLAGS="" install \
        && mkdir /usr/share/doc/pgvector \
        && cp LICENSE README.md /usr/share/doc/pgvector \
        && cp sql/vector.sql /usr/share/postgresql/${PG_SERVER_VERSION}/extension/vector--${PGVECTOR_VERSION}.sql; \
      elif [ $(echo "$PG_SERVER_VERSION == 11" | /usr/bin/bc) = "1" ]; then \
        cd /tmp && git clone --branch v0.5.1 https://github.com/pgvector/pgvector.git \
        && cd pgvector && make OPTFLAGS="" install \
        && mkdir /usr/share/doc/pgvector \
        && cp LICENSE README.md /usr/share/doc/pgvector \
        && cp sql/vector.sql /usr/share/postgresql/11/extension/vector--0.5.1.sql; \
      fi \
    # pgBackRest
    && apt-get install --no-install-recommends -y \
       pgbackrest zstd openssh-client \
       && mkdir -p -m 700 /var/lib/postgresql/.ssh \
       && chown postgres:postgres /var/lib/postgresql/.ssh \
    # WAL-G
    && wget https://github.com/wal-g/wal-g/releases/download/v"${WALG_VERSION}"/wal-g-pg-ubuntu-20.04-amd64.tar.gz \
      && tar -zxvf wal-g-pg-ubuntu-20.04-amd64.tar.gz \
      && mv wal-g-pg-ubuntu-20.04-amd64 /usr/local/bin/wal-g \
      && wal-g --version \
    # remove all auxilary packages to reduce final image size
    && cd / && rm -rf /tmp/* && apt-get purge -y --auto-remove \
       gcc make wget unzip curl libc6-dev apt-transport-https git \
       postgresql-server-dev-${PG_SERVER_VERSION} pgxnclient build-essential \
       libssl-dev krb5-multidev comerr-dev krb5-multidev libkrb5-dev apt-utils lsb-release \
       libgssrpc4 libevent-dev libbrotli-dev \
    && apt-get clean -y autoclean \
    && rm -rf /var/lib/apt/lists/* \
    # remove standard pgdata
    && rm -rf /var/lib/postgresql/${PG_SERVER_VERSION}/

EXPOSE ${PG_SERVER_PORT}

# Prepare Postgres start script
RUN echo "#!/bin/bash" > /pg_start.sh && chmod a+x /pg_start.sh \
    && echo "chown -R postgres:postgres \${PGDATA} \${PG_UNIX_SOCKET_DIR}" \
      >> /pg_start.sh \
    && printf "sudo -Eu postgres /usr/lib/postgresql/$(echo ${PG_SERVER_VERSION} | sed 's/beta.*//' | sed 's/rc.*//')/bin/postgres -D \${PGDATA} -k \${PG_UNIX_SOCKET_DIR}  -p \${PG_SERVER_PORT} >& /proc/1/fd/1 \n" \
      >> /pg_start.sh \
    # Infinite sleep to allow restarting Postgres
    && echo "/bin/bash -c \"trap : TERM INT; sleep infinity & wait\"" \
      >> /pg_start.sh

CMD ["/pg_start.sh"]
