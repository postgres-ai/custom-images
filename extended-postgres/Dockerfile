# Debian 11 (bullseye) has glibc 2.31.
# If you are using "physical" mode, please check the glibc version in your production database system to avoid potential index corruption.
# You should have the same version of glibc as in your Docker image.

ARG PG_SERVER_VERSION=14

# build-env
FROM postgres:${PG_SERVER_VERSION}-bullseye as build-env

ARG PG_SERVER_VERSION
ENV PG_SERVER_VERSION=${PG_SERVER_VERSION:-14}

ARG GO_VERSION
ENV GO_VERSION=${GO_VERSION:-1.18.4}

ARG WALG_VERSION
ENV WALG_VERSION=${WALG_VERSION:-2.0.0}

ARG HTTP_VERSION
ENV HTTP_VERSION=${HTTP_VERSION:-1.5.0}

ARG PG_GRAPHQL_VERSION
ENV PG_GRAPHQL_VERSION=${PG_GRAPHQL_VERSION:-0.4.1}

ARG PG_JSONSCHEMA_VERSION
ENV PG_JSONSCHEMA_VERSION=${PG_JSONSCHEMA_VERSION:-0.1.0}

ARG PG_NET_VERSION
ENV PG_NET_VERSION=${PG_NET_VERSION:-0.6.1}

ARG PGSODIUM_VERSION
ENV PGSODIUM_VERSION=${PGSODIUM_VERSION:-3.0.5}

ARG ANON_VERSION
ENV ANON_VERSION=${ANON_VERSION:-1.1.0}

RUN set -ex \
    && apt-get clean && rm -rf /var/lib/apt/lists/partial \
    # remove the "beta" and "rc" suffix in the PG_SERVER_VERSION variable (if exists)
    && PG_SERVER_VERSION="$( echo ${PG_SERVER_VERSION} | sed 's/beta.*//' | sed 's/rc.*//' )" \
    # install dependencies
    && apt-get update -o Acquire::CompressionTypes::Order::=gz \
    && apt-get install --no-install-recommends -y apt-transport-https ca-certificates \
       wget curl sudo git make cmake gcc build-essential bc unzip apt-utils lsb-release \
       libreadline-dev zlib1g-dev flex bison libxml2-dev libxslt-dev libssl-dev libxml2-utils \
       xsltproc ccache libbrotli-dev liblzo2-dev libsodium-dev libc6-dev krb5-multidev libkrb5-dev \
       postgresql-server-dev-${PG_SERVER_VERSION} libpq-dev \
       # plv8 extension requirements
       python3 pkg-config clang g++ libc++-dev libc++abi-dev \
       libglib2.0-dev libtinfo5 ninja-build binutils \
       # http extension requirements
       libcurl4-openssl-dev \
       # libgraphqlparser requirements
       python2 \
    # install Go
    && cd /tmp && wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    && rm -rf /usr/local/go && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz \
    && export PATH=$PATH:/usr/local/go/bin \
    # build WAL-G
    && git clone --branch v${WALG_VERSION} --single-branch https://github.com/wal-g/wal-g.git \
    && cd wal-g && export USE_LIBSODIUM=1 && export USE_LZO=1 \
    && make deps && GOBIN=/usr/local/bin make pg_install \
    # pg_hint_plan extension
    && if [ $(echo "$PG_SERVER_VERSION < 14" | /usr/bin/bc) = "1" ]; then \
         export PG_PLAN_HINT_VERSION=$(echo $PG_SERVER_VERSION | sed 's/\.//') \
         && wget --quiet -O /tmp/pg_hint_plan.zip \
           https://github.com/ossc-db/pg_hint_plan/archive/PG${PG_PLAN_HINT_VERSION}.zip \
         && unzip /tmp/pg_hint_plan.zip -d /tmp \
           && cd /tmp/pg_hint_plan-PG${PG_PLAN_HINT_VERSION} \
           && make && make install; \
        # there is no branch "PG14", use the tag "REL14_1_4_0"
        elif [ "${PG_SERVER_VERSION}" = "14" ]; then \
           wget --quiet -O /tmp/pg_hint_plan.zip \
           https://github.com/ossc-db/pg_hint_plan/archive/REL14_1_4_0.zip \
         && unzip /tmp/pg_hint_plan.zip -d /tmp \
           && cd /tmp/pg_hint_plan-REL14_1_4_0 \
           && make && make install; \
        fi \
    # pg_auth_mon extension
    && if [ $(echo "$PG_SERVER_VERSION < 14" | /usr/bin/bc) = "1" ]; then \
         git clone https://github.com/RafiaSabih/pg_auth_mon.git \
         && cd pg_auth_mon && USE_PGXS=1 make && USE_PGXS=1 make install; \
       fi \
    # pg_show_plans extension
    && if [ $(echo "$PG_SERVER_VERSION < 15" | /usr/bin/bc) = "1" ]; then \
         git clone https://github.com/cybertec-postgresql/pg_show_plans.git \
         && cd pg_show_plans \
         && export USE_PGXS=1 && make && make install && cd .. && rm -rf pg_show_plans; \
       fi \
    # bg_mon extension
    && apt-get install -y libevent-dev libbrotli-dev \
      && git clone https://github.com/CyberDem0n/bg_mon.git && cd bg_mon \
      && USE_PGXS=1 make && USE_PGXS=1 make install && cd .. \
    # set_user extension
    && git clone https://github.com/pgaudit/set_user.git \
      && cd set_user && git checkout REL3_0_0 && make USE_PGXS=1 && make USE_PGXS=1 install \
    # logerrors extension
    && if [ $(echo "$PG_SERVER_VERSION > 9.6" | /usr/bin/bc) = "1" ]; then \
         # build logerrors v2.0
         if [ $(echo "$PG_SERVER_VERSION < 15" | /usr/bin/bc) = "1" ]; then \
           cd /tmp && wget https://github.com/munakoiso/logerrors/archive/v2.0.tar.gz \
           && tar -xf v2.0.tar.gz && rm v2.0.tar.gz && cd logerrors-2.0 \
           && USE_PGXS=1 make && USE_PGXS=1 make install; \
         # build logerrors from the master branch for PostgreSQL 15
         elif [ "${PG_SERVER_VERSION}" = "15" ]; then \
           cd /tmp && git clone https://github.com/munakoiso/logerrors.git \
           && cd logerrors \
           && USE_PGXS=1 make && USE_PGXS=1 make install; \
         fi \
       fi \
    # postgresql_anonymizer (anon) extension
    && git clone --branch ${ANON_VERSION} --single-branch https://gitlab.com/dalibo/postgresql_anonymizer.git \
    && cd postgresql_anonymizer \
    && make extension \
    && make install \
    # http extension
    && git clone --branch v${HTTP_VERSION} --single-branch https://github.com/pramsey/pgsql-http.git \
    && cd pgsql-http \
    && make \
    && make install \
    # pg_hashids extension
    && git clone https://github.com/iCyberon/pg_hashids.git \
    && cd pg_hashids \
    && USE_PGXS=1 make \
    && USE_PGXS=1 make install \
    # libgraphqlparser (required for pg_graphql)
    && git clone --branch v0.7.0 --single-branch https://github.com/graphql/libgraphqlparser \
    && cd libgraphqlparser \
    && cmake . \
    && make install \
    # pg_graphql extension (compatible with PostgreSQL 13-15)
    && if [ $(echo "$PG_SERVER_VERSION > 12" | /usr/bin/bc) = "1" ]; then \
        git clone --branch v${PG_GRAPHQL_VERSION} --single-branch https://github.com/supabase/pg_graphql.git \
        && cd pg_graphql \
        && make install; \
       fi \
    # pg_jsonschema extension (compatible with PostgreSQL 12-14)
    && if [ $(echo "$PG_SERVER_VERSION > 11" | /usr/bin/bc) = "1" ] && [ $(echo "$PG_SERVER_VERSION < 15" | /usr/bin/bc) = "1" ]; then \
        chown postgres:postgres -R /usr/share/postgresql/${PG_SERVER_VERSION}/extension /usr/lib/postgresql/${PG_SERVER_VERSION}/lib/ \
        && su - postgres -c "PATH=/var/lib/postgresql/.cargo/bin/:$PATH \
          && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path --profile minimal \
          && cargo install --locked cargo-pgx --version 0.4.5 \
          && cargo pgx init --pg${PG_SERVER_VERSION} /usr/lib/postgresql/${PG_SERVER_VERSION}/bin/pg_config \
          && git clone --branch v${PG_JSONSCHEMA_VERSION} --single-branch https://github.com/supabase/pg_jsonschema.git \
          && cd pg_jsonschema \
          && cargo pgx install"; \
       fi \
    # pg_net extension (compatible with PostgreSQL 12-15)
    && if [ $(echo "$PG_SERVER_VERSION > 11" | /usr/bin/bc) = "1" ]; then \
        git clone --branch v${PG_NET_VERSION} --single-branch https://github.com/supabase/pg_net.git \
        && cd pg_net \
        && make \
        && make install; \
       fi \
    # pgjwt extension
    && git clone https://github.com/michelp/pgjwt.git \
    && cd pgjwt \
    && make install \
    # pgsodium extension
    # as of version 3.0 pgsodium requires PostgreSQL 14+
    && if [ $(echo "$PG_SERVER_VERSION > 13" | /usr/bin/bc) = "1" ]; then \
        git clone --branch v${PGSODIUM_VERSION} --single-branch https://github.com/michelp/pgsodium.git \
        && cd pgsodium \
        && make install; \
       fi \
    # use pgsodium 2.0 for earlier versions of PostgreSQL. 
    && if [ $(echo "$PG_SERVER_VERSION < 14" | /usr/bin/bc) = "1" ]; then \
        git clone --branch v2.0.2 --single-branch https://github.com/michelp/pgsodium.git \
        && cd pgsodium \
        && make install; \
       fi \
    # supautils extension
    && if [ $(echo "$PG_SERVER_VERSION > 9.6" | /usr/bin/bc) = "1" ]; then \
        git clone https://github.com/supabase/supautils.git \
        && cd supautils \
        && make \
        && make install; \
       fi \
    # plv8 extension
    && cd /tmp && git clone --branch r3.1 --single-branch https://github.com/plv8/plv8 \
    && cd plv8 \
    && git checkout 8b7dc73 \
    && make DOCKER=1 install \
    && strip /usr/lib/postgresql/${PG_SERVER_VERSION}/lib/plv8-3.1.4.so

# Build the extended-postgres image
FROM postgres:${PG_SERVER_VERSION}-bullseye
LABEL maintainer="postgres.ai"

ARG PG_SERVER_VERSION
ENV PG_SERVER_VERSION=${PG_SERVER_VERSION:-14}

# copy WAL-G binary
COPY --from=build-env /usr/local/bin/wal-g /usr/local/bin/wal-g

# copy PostgreSQL extensions from build-env
COPY --from=build-env --chown=root:root /usr/share/postgresql/ /usr/share/postgresql/
COPY --from=build-env --chown=root:root /usr/lib/postgresql/ /usr/lib/postgresql/

# libgraphqlparser
ENV LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"
COPY --from=build-env ["/usr/local/lib/libgraphqlparser.so", "/usr/local/lib/libgraphqlparser.so"]

ARG PG_TIMETABLE_VERSION
ENV PG_TIMETABLE_VERSION=${PG_TIMETABLE_VERSION:-4.9.0}

ARG POSTGIS_VERSION
ENV POSTGIS_VERSION=${POSTGIS_VERSION:-3}

RUN apt-get clean && rm -rf /var/lib/apt/lists/partial \
    # remove the "beta" and "rc" suffix in the PG_SERVER_VERSION variable (if exists)
    && PG_SERVER_VERSION="$( echo ${PG_SERVER_VERSION} | sed 's/beta.*//' | sed 's/rc.*//' )" \
    && apt-get update -o Acquire::CompressionTypes::Order::=gz \
    && apt-get install --no-install-recommends -y apt-transport-https ca-certificates \
       wget curl sudo bc lsb-release apt-utils \
    # pgsodium requirements
    && apt-get install --no-install-recommends -y \
       libsodium23 \
    # plpython3 (procedural language implementation for Python 3.x)
    && apt-get install --no-install-recommends -y \
       postgresql-plpython3-${PG_SERVER_VERSION} \
    # postgis extension
    && apt-get install -y --no-install-recommends \
       postgresql-${PG_SERVER_VERSION}-postgis-${POSTGIS_VERSION} \
       postgresql-${PG_SERVER_VERSION}-postgis-${POSTGIS_VERSION}-scripts \
    # pgrouting extension
    && apt-get install -y --no-install-recommends \
       postgresql-${PG_SERVER_VERSION}-pgrouting \
    # amcheck extension; not included in contrib for Postgres 9.6
    && if [ "${PG_SERVER_VERSION}" = "9.6" ]; then \
       apt-get install --no-install-recommends -y \
       postgresql-9.6-amcheck; \
       fi \
    # pg_repack extension
    && if [ $(echo "$PG_SERVER_VERSION < 15" | /usr/bin/bc) = "1" ]; then \
         apt-get install --no-install-recommends -y \
         postgresql-${PG_SERVER_VERSION}-repack; \
       fi \
    # hypopg extension
    && apt-get install --no-install-recommends -y \
         postgresql-${PG_SERVER_VERSION}-hypopg \
         postgresql-${PG_SERVER_VERSION}-hypopg-dbgsym \
    # pgaudit extension
    && apt-get install --no-install-recommends -y \
         postgresql-${PG_SERVER_VERSION}-pgaudit \
    # powa extension
    && apt-get install --no-install-recommends -y \
       postgresql-${PG_SERVER_VERSION}-powa \
    # timescaledb extension
    && if [ $(echo "$PG_SERVER_VERSION > 11" | /usr/bin/bc) = "1" ] && [ $(echo "$PG_SERVER_VERSION < 15" | /usr/bin/bc) = "1" ]; then \
         echo "deb https://packagecloud.io/timescale/timescaledb/debian/ $(lsb_release -c -s) main" > /etc/apt/sources.list.d/timescaledb.list \
           && wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey | sudo apt-key add - \
           && apt-get update \
           && apt-get install --no-install-recommends -y \
              timescaledb-2-postgresql-${PG_SERVER_VERSION}; \
       fi \
    # citus extension
    && if [ $(echo "$PG_SERVER_VERSION > 10" | /usr/bin/bc) = "1" ]; then \
         if [ "${PG_SERVER_VERSION}" = "11" ]; then CITUS_VERSION="10.0"; \
         elif [ "${PG_SERVER_VERSION}" = "12" ]; then CITUS_VERSION="10.2"; \
         elif [ "${PG_SERVER_VERSION}" = "13" ]; then CITUS_VERSION="11.1"; \
         elif [ "${PG_SERVER_VERSION}" = "14" ]; then CITUS_VERSION="11.1"; \
         elif [ "${PG_SERVER_VERSION}" = "15" ]; then CITUS_VERSION="11.1"; \
         fi \
        && curl -s https://install.citusdata.com/community/deb.sh | bash \
        && apt-get install --no-install-recommends -y \
         postgresql-"${PG_SERVER_VERSION}"-citus-"${CITUS_VERSION}"; \
       fi \
    # hll extension
    && apt-get install --no-install-recommends -y \
       postgresql-"${PG_SERVER_VERSION}"-hll \
    # topn extension
    && if [ $(echo "$PG_SERVER_VERSION > 9.6" | /usr/bin/bc) = "1" ]; then \
         curl -s https://install.citusdata.com/community/deb.sh | bash \
         && apt-get install --no-install-recommends -y \
            postgresql-"${PG_SERVER_VERSION}"-topn; \
       fi \
    # pg_timetable extension
    && wget https://github.com/cybertec-postgresql/pg_timetable/releases/download/v${PG_TIMETABLE_VERSION}/pg_timetable_${PG_TIMETABLE_VERSION}_Linux_x86_64.deb \
      && dpkg -i pg_timetable_${PG_TIMETABLE_VERSION}_Linux_x86_64.deb \
      && rm -rf pg_timetable_${PG_TIMETABLE_VERSION}_Linux_x86_64.deb \
    # pg_cron extension
    && if [ $(echo "$PG_SERVER_VERSION < 15" | /usr/bin/bc) = "1" ]; then \
         apt-get install --no-install-recommends -y \
         postgresql-${PG_SERVER_VERSION}-cron; \
       fi \
    # pg_stat_monitor extension (available for versions 11, 12, 13 and 14)
    && if [ $(echo "$PG_SERVER_VERSION > 10" | /usr/bin/bc) = "1" ] && [ $(echo "$PG_SERVER_VERSION < 15" | /usr/bin/bc) = "1" ]; then \
         cd /tmp && curl -O https://repo.percona.com/apt/percona-release_latest.generic_all.deb \
         && apt-get install --no-install-recommends -y \
            ./percona-release_latest.generic_all.deb \
         && apt-get update \
         && percona-release setup ppg${PG_SERVER_VERSION} \
         && apt-get install --no-install-recommends -y \
            percona-pg-stat-monitor${PG_SERVER_VERSION}; \
       fi \
    # pg_stat_kcache extension
    && apt-get install --no-install-recommends -y \
       postgresql-${PG_SERVER_VERSION}-pg-stat-kcache \
    # pg_wait_sampling extension
    && apt-get install --no-install-recommends -y \
       postgresql-${PG_SERVER_VERSION}-pg-wait-sampling \
    # pg_qualstats extension
    && apt-get install --no-install-recommends -y \
       postgresql-${PG_SERVER_VERSION}-pg-qualstats \
    # pgextwlist extension
    && apt-get install --no-install-recommends -y \
       postgresql-${PG_SERVER_VERSION}-pgextwlist \
    # plpgsql_check extension
    && apt-get install --no-install-recommends -y \
       postgresql-${PG_SERVER_VERSION}-plpgsql-check \
    # pljava extension
    && if [ $(echo "$PG_SERVER_VERSION < 15" | /usr/bin/bc) = "1" ]; then \
         apt-get install --no-install-recommends -y \
         postgresql-${PG_SERVER_VERSION}-pljava; \
       fi \
    # rum extension
    && if [ $(echo "$PG_SERVER_VERSION < 15" | /usr/bin/bc) = "1" ]; then \
         apt-get install --no-install-recommends -y \
         postgresql-${PG_SERVER_VERSION}-rum; \
       fi \
    # pgtap extension
    && apt-get install --no-install-recommends -y \
       postgresql-${PG_SERVER_VERSION}-pgtap \
    # pgBackRest
    && apt-get install --no-install-recommends -y \
       pgbackrest zstd openssh-client \
       && mkdir -p -m 700 /var/lib/postgresql/.ssh \
       && chown postgres:postgres /var/lib/postgresql/.ssh \
    # remove all auxilary packages to reduce final image size
    && cd / && rm -rf /tmp/* && apt-get purge -y --auto-remove \
       wget curl apt-transport-https apt-utils lsb-release bc \
    && apt-get clean -y autoclean \
    && rm -rf /var/lib/apt/lists/* \
    # remove standard pgdata
    && rm -rf /var/lib/postgresql/${PG_SERVER_VERSION}/

EXPOSE 5432

# Prepare Postgres start script
RUN echo "#!/bin/bash" > /pg_start.sh && chmod a+x /pg_start.sh \
    && echo "chown -R postgres:postgres \${PGDATA} /var/run/postgresql" \
      >> /pg_start.sh \
    && printf "sudo -Eu postgres /usr/lib/postgresql/$(echo ${PG_SERVER_VERSION} | sed 's/beta.*//' | sed 's/rc.*//')/bin/postgres -D \${PGDATA} >& /proc/1/fd/1 \n" \
      >> /pg_start.sh \
    # Infinite sleep to allow restarting Postgres
    && echo "/bin/bash -c \"trap : TERM INT; sleep infinity & wait\"" \
      >> /pg_start.sh

CMD ["/pg_start.sh"]
