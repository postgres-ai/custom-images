# Debian 12 (bookworm) has glibc 2.36.
# If you are using "physical" mode, please check the glibc version in your production database system to avoid potential index corruption.
# You should have the same version of glibc as in your Docker image.

ARG GO_VERSION=1.26.2
ARG GOSU_VERSION=1.19
ARG PG_SERVER_VERSION=18
ARG PG_TIMETABLE_VERSION=6.3.0
ARG PG_TIMETABLE_PGX_VERSION=v5.9.2
ARG WALG_VERSION=3.0.8
ARG WALG_GIT_REVISION=f81943e
ARG WALG_GRPC_VERSION=v1.80.0
ARG WALG_PGX_VERSION=v5.9.2
ARG WALG_X_CRYPTO_VERSION=v0.49.0
ARG WALG_OAUTH2_VERSION=v0.36.0

FROM golang:${GO_VERSION} AS gosu-builder
ARG GOSU_VERSION
RUN GOBIN=/out go install github.com/tianon/gosu@${GOSU_VERSION}

FROM golang:${GO_VERSION} AS pg-timetable-builder
ARG PG_TIMETABLE_VERSION
ARG PG_TIMETABLE_PGX_VERSION
RUN git clone --depth 1 --branch v${PG_TIMETABLE_VERSION} https://github.com/cybertec-postgresql/pg_timetable.git /src \
    && cd /src \
    && go get github.com/jackc/pgx/v5@${PG_TIMETABLE_PGX_VERSION} \
    && go mod tidy \
    && CGO_ENABLED=0 go build -trimpath \
      -ldflags "-s -w -X main.version=v${PG_TIMETABLE_VERSION} -X main.commit=security-rebuild -X main.date=2026-05-05" \
      -o /out/pg_timetable .

FROM golang:${GO_VERSION} AS walg-builder
ARG WALG_VERSION
ARG WALG_GIT_REVISION
ARG WALG_GRPC_VERSION
ARG WALG_PGX_VERSION
ARG WALG_X_CRYPTO_VERSION
ARG WALG_OAUTH2_VERSION
RUN git clone --depth 1 --branch v${WALG_VERSION} https://github.com/wal-g/wal-g.git /src \
    && cd /src \
    && go mod edit -module github.com/wal-g/wal-g/v3 \
    && go mod edit -require github.com/wal-g/wal-g@v1.1.0 \
    && go mod edit -replace github.com/wal-g/wal-g=. \
    && go get github.com/jackc/pgx/v5@${WALG_PGX_VERSION} \
      google.golang.org/grpc@${WALG_GRPC_VERSION} \
      golang.org/x/crypto@${WALG_X_CRYPTO_VERSION} \
      golang.org/x/oauth2@${WALG_OAUTH2_VERSION} \
    && go mod tidy \
    && CGO_ENABLED=0 GOEXPERIMENT=jsonv2 go build -trimpath \
      -ldflags "-s -w -X github.com/wal-g/wal-g/cmd/pg.walgVersion=v${WALG_VERSION} -X github.com/wal-g/wal-g/cmd/pg.gitRevision=${WALG_GIT_REVISION} -X github.com/wal-g/wal-g/cmd/pg.buildDate=2026.05.05_00:00:00" \
      -o /out/wal-g ./main/pg

# Build the extended image
FROM postgres:${PG_SERVER_VERSION}-bookworm
COPY --from=gosu-builder /out/gosu /usr/local/bin/gosu
COPY --from=pg-timetable-builder /out/pg_timetable /usr/local/bin/pg_timetable
COPY --from=walg-builder /out/wal-g /usr/local/bin/wal-g
LABEL maintainer="postgres.ai"

ARG PG_SERVER_VERSION
ENV PG_SERVER_VERSION=${PG_SERVER_VERSION:-18}

ARG PG_UNIX_SOCKET_DIR
ENV PG_UNIX_SOCKET_DIR=${PG_UNIX_SOCKET_DIR:-"/var/run/postgresql"}

ARG PG_SERVER_PORT
ENV PG_SERVER_PORT=${PG_SERVER_PORT:-5432}

ARG WALG_VERSION
ENV WALG_VERSION=${WALG_VERSION:-3.0.8}

ARG PG_TIMETABLE_VERSION
ENV PG_TIMETABLE_VERSION=${PG_TIMETABLE_VERSION:-6.3.0}

ARG LOGERRORS_VERSION
ENV LOGERRORS_VERSION=${LOGERRORS_VERSION:-2.1.5}

ARG PGVECTOR_VERSION
ENV PGVECTOR_VERSION=${PGVECTOR_VERSION:-0.8.1}

# https://gitlab.com/postgres-ai/custom-images/-/merge_requests/56
ARG PG_CRON_VERSION
ENV PG_CRON_VERSION=${PG_CRON_VERSION:-1.4.2}


RUN apt-get clean && rm -rf /var/lib/apt/lists/partial \
    # remove the "beta" and "rc" suffix in the PG_SERVER_VERSION variable (if exists)
    && PG_SERVER_VERSION="$( echo ${PG_SERVER_VERSION} | sed 's/beta.*//' | sed 's/rc.*//' )" \
    && apt-get update -o Acquire::CompressionTypes::Order::=gz \
    # Refresh OS packages from the postgres:*-bookworm base. Without an explicit
    # upgrade, the image inherits whatever Debian package versions were pinned
    # into the upstream postgres tag at build time — which accumulates HIGH and
    # CRITICAL CVEs (libssl, glibc, perl, util-linux, etc.) between postgres
    # tag refreshes. Pulling -security feeds here drops most of them.
    && apt-get upgrade -y \
    && apt-get install --no-install-recommends -y wget make gcc unzip sudo git \
       curl libc6-dev apt-transport-https ca-certificates pgxnclient bc \
       build-essential libssl-dev krb5-multidev libkrb5-dev lsb-release apt-utils flex \
    && apt-get install --no-install-recommends -y postgresql-server-dev-${PG_SERVER_VERSION} \
    # plpython3 (procedural language implementation for Python 3.x)
    && apt-get install --no-install-recommends -y postgresql-plpython3-${PG_SERVER_VERSION} \
    # pg_repack extension
    && apt-get install --no-install-recommends -y postgresql-${PG_SERVER_VERSION}-repack \
    # hypopg extension
    && apt-get install --no-install-recommends -y \
       postgresql-${PG_SERVER_VERSION}-hypopg \
       postgresql-${PG_SERVER_VERSION}-hypopg-dbgsym \
    # pgaudit extension
    && apt-get install --no-install-recommends -y postgresql-${PG_SERVER_VERSION}-pgaudit \
    # pg_hint_plan extension
    && if [ $(echo "$PG_SERVER_VERSION > 11" | /usr/bin/bc) = "1" ] && [ $(echo "$PG_SERVER_VERSION <= 18" | /usr/bin/bc) = "1" ]; then \
         apt-get install --no-install-recommends -y postgresql-${PG_SERVER_VERSION}-pg-hint-plan; \
       else \
         export PG_PLAN_HINT_VERSION=$(echo $PG_SERVER_VERSION | sed 's/\.//') \
         && wget --quiet -O /tmp/pg_hint_plan.zip https://github.com/ossc-db/pg_hint_plan/archive/PG${PG_PLAN_HINT_VERSION}.zip \
         && unzip /tmp/pg_hint_plan.zip -d /tmp \
         && cd /tmp/pg_hint_plan-PG${PG_PLAN_HINT_VERSION} \
         && make && make install; \
      fi \
    # powa extension
    && if [ $(echo "$PG_SERVER_VERSION < 18" | /usr/bin/bc) = "1" ]; then \
         apt-get install --no-install-recommends -y postgresql-${PG_SERVER_VERSION}-powa; \
       fi \
    # pg_auth_mon extension
    && if [ $(echo "$PG_SERVER_VERSION > 10" | /usr/bin/bc) = "1" ]; then \
         cd /tmp && git clone --branch v3.0 --single-branch https://github.com/RafiaSabih/pg_auth_mon.git \
         && cd pg_auth_mon && USE_PGXS=1 make && USE_PGXS=1 make install; \
       fi \
    # timescaledb extension (supports PostgreSQL 18 since v2.23.0)
    && if [ $(echo "$PG_SERVER_VERSION > 11" | /usr/bin/bc) = "1" ]; then \
         echo "deb https://packagecloud.io/timescale/timescaledb/debian/ $(lsb_release -c -s) main" > /etc/apt/sources.list.d/timescaledb.list \
           && wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey | sudo apt-key add - \
           && apt-get update \
           && apt-get install --no-install-recommends -y \
              timescaledb-2-postgresql-${PG_SERVER_VERSION}; \
       fi \
    # citus extension
    && if [ $(echo "$PG_SERVER_VERSION > 10" | /usr/bin/bc) = "1" ] && [ $(echo "$PG_SERVER_VERSION < 18" | /usr/bin/bc) = "1" ]; then \
         if [ "${PG_SERVER_VERSION}" = "11" ]; then CITUS_VERSION="10.0"; \
         elif [ "${PG_SERVER_VERSION}" = "12" ]; then CITUS_VERSION="10.2"; \
         elif [ "${PG_SERVER_VERSION}" = "13" ]; then CITUS_VERSION="11.3"; \
         elif [ "${PG_SERVER_VERSION}" = "14" ]; then CITUS_VERSION="12.1"; \
         elif [ "${PG_SERVER_VERSION}" = "15" ]; then CITUS_VERSION="13.0"; \
         elif [ "${PG_SERVER_VERSION}" = "16" ]; then CITUS_VERSION="13.0"; \
         elif [ "${PG_SERVER_VERSION}" = "17" ]; then CITUS_VERSION="13.0"; \
         fi \
         && curl -s https://install.citusdata.com/community/deb.sh | bash \
         && apt-get install --no-install-recommends -y postgresql-"${PG_SERVER_VERSION}"-citus-"${CITUS_VERSION}"; \
       fi \
    # hll extension (supports PostgreSQL 18 since v2.19)
    && apt-get install --no-install-recommends -y postgresql-"${PG_SERVER_VERSION}"-hll \
    # topn extension \
    && if [ $(echo "$PG_SERVER_VERSION > 9.6" | /usr/bin/bc) = "1" ] && [ $(echo "$PG_SERVER_VERSION < 18" | /usr/bin/bc) = "1" ]; then \
       curl -s https://install.citusdata.com/community/deb.sh | bash \
         && apt-get install --no-install-recommends -y postgresql-"${PG_SERVER_VERSION}"-topn; \
       fi \
    # pg_timetable binary is rebuilt in the builder stage with patched Go/pgx.
    && pg_timetable --version \
    # pg_show_plans extension
    && if [ $(echo "$PG_SERVER_VERSION > 11" | /usr/bin/bc) = "1" ]; then \
         apt-get install --no-install-recommends -y postgresql-${PG_SERVER_VERSION}-show-plans; \
       fi \
    # pg_cron extension (supports PostgreSQL 18 since v1.6.6)
    # for PostgreSQL 10-15, install from source (https://gitlab.com/postgres-ai/custom-images/-/merge_requests/56)
    && if [ $(echo "$PG_SERVER_VERSION >= 10" | /usr/bin/bc) = "1" ] && [ $(echo "$PG_SERVER_VERSION < 16" | /usr/bin/bc) = "1" ]; then \
         cd /tmp && git clone --branch v${PG_CRON_VERSION} --single-branch https://github.com/citusdata/pg_cron.git \
         && cd pg_cron \
         && make && make install; \
       elif [ $(echo "$PG_SERVER_VERSION >= 16" | /usr/bin/bc) = "1" ]; then \
         apt-get install --no-install-recommends -y postgresql-${PG_SERVER_VERSION}-cron; \
       fi \
    # postgresql_anonymizer extension
    && pgxn install ddlx && pgxn install postgresql_anonymizer \
    # pg_stat_kcache extension \
    && if [ $(echo "$PG_SERVER_VERSION < 18" | /usr/bin/bc) = "1" ]; then \
       apt-get install --no-install-recommends -y postgresql-${PG_SERVER_VERSION}-pg-stat-kcache; \
    else \
      cd /tmp && git clone https://github.com/powa-team/pg_stat_kcache.git && cd pg_stat_kcache \
      && make && make install && cd .. ; \
    fi \
    # pg_wait_sampling extension
    && apt-get install --no-install-recommends -y postgresql-${PG_SERVER_VERSION}-pg-wait-sampling \
    # pg_qualstats extension \
    && if [ $(echo "$PG_SERVER_VERSION < 18" | /usr/bin/bc) = "1" ]; then \
       apt-get install --no-install-recommends -y postgresql-${PG_SERVER_VERSION}-pg-qualstats; \
    fi \
    # bg_mon extension
    && apt-get install -y libevent-dev libbrotli-dev \
      && cd /tmp && git clone https://github.com/CyberDem0n/bg_mon.git && cd bg_mon \
      && USE_PGXS=1 make && USE_PGXS=1 make install && cd .. \
    # pgextwlist extension
    && apt-get install --no-install-recommends -y postgresql-${PG_SERVER_VERSION}-pgextwlist \
    # set_user extension
    && if [ $(echo "$PG_SERVER_VERSION > 9.6" | /usr/bin/bc) = "1" ] && [ $(echo "$PG_SERVER_VERSION < 18" | /usr/bin/bc) = "1" ]; then \
         apt-get install --no-install-recommends -y postgresql-${PG_SERVER_VERSION}-set-user; \
       elif [ $(echo "$PG_SERVER_VERSION == 18" | /usr/bin/bc) = "1" ]; then \
         cd /tmp && git clone --branch REL4_1_0 https://github.com/pgaudit/set_user.git \
         && cd set_user && make USE_PGXS=1 && make USE_PGXS=1 install; \
       fi \
    # logerrors extension \
    && cd /tmp && wget -O logerrors.tar.gz https://github.com/munakoiso/logerrors/archive/v${LOGERRORS_VERSION}.tar.gz \
       && tar -xf logerrors.tar.gz && rm logerrors.tar.gz && cd logerrors-${LOGERRORS_VERSION} \
       && USE_PGXS=1 make && USE_PGXS=1 make install \
    # pgvector extension
    && if [ $(echo "$PG_SERVER_VERSION >= 11" | /usr/bin/bc) = "1" ] && [ $(echo "$PG_SERVER_VERSION < 18" | /usr/bin/bc) = "1" ]; then \
        if [ "${PG_SERVER_VERSION}" = "11" ]; then PGVECTOR_VERSION="0.5.1"; \
        elif [ "${PG_SERVER_VERSION}" = "12" ]; then PGVECTOR_VERSION="0.7.4"; \
        else PGVECTOR_VERSION="${PGVECTOR_VERSION}"; \
        fi \
        && cd /tmp && git clone --branch v${PGVECTOR_VERSION} https://github.com/pgvector/pgvector.git \
        && cd pgvector && make OPTFLAGS="" install \
        && mkdir /usr/share/doc/pgvector \
        && cp LICENSE README.md /usr/share/doc/pgvector \
        && cp sql/vector.sql /usr/share/postgresql/${PG_SERVER_VERSION}/extension/vector--${PGVECTOR_VERSION}.sql; \
    else \
      apt install --no-install-recommends -y postgresql-${PG_SERVER_VERSION}-pgvector; \
    fi \
    # pgBackRest
    && apt-get install --no-install-recommends -y \
       pgbackrest zstd openssh-client \
       && mkdir -p -m 700 /var/lib/postgresql/.ssh \
       && chown postgres:postgres /var/lib/postgresql/.ssh \
    # WAL-G binary is rebuilt in the builder stage with patched Go/deps.
    && wal-g --version \
    # remove all auxiliary packages to reduce final image size
    && cd / && rm -rf /tmp/* && apt-get purge -y --auto-remove \
       gcc make wget unzip curl libc6-dev apt-transport-https git \
       postgresql-server-dev-${PG_SERVER_VERSION} pgxnclient build-essential \
       libssl-dev krb5-multidev comerr-dev krb5-multidev libkrb5-dev apt-utils lsb-release \
       libgssrpc4 \
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
