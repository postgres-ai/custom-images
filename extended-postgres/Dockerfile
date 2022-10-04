ARG PG_SERVER_VERSION=14

# build-env
FROM postgres:${PG_SERVER_VERSION} as build-env

ARG WALG_VERSION
ENV WALG_VERSION=${WALG_VERSION:-2.0.0}

ARG GO_VERSION
ENV GO_VERSION=${GO_VERSION:-1.18.4}

RUN apt-get clean && rm -rf /var/lib/apt/lists/partial \
    # add the backports repository for Debian 9 Stretch. Required to install the package "libbrotli-dev"
    && if [ $(sed 's/\..*//' /etc/debian_version) = "9" ]; then \
      echo "deb http://deb.debian.org/debian stretch-backports main" > /etc/apt/sources.list.d/backports.list; \
    fi \
    # install dependencies
    && apt-get update -o Acquire::CompressionTypes::Order::=gz \
    && apt-get install --no-install-recommends -y apt-transport-https ca-certificates \
       wget curl sudo git make cmake gcc build-essential \
       libbrotli-dev liblzo2-dev libsodium-dev \
    # install Go
    && cd /tmp && wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    && rm -rf /usr/local/go && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz \
    && export PATH=$PATH:/usr/local/go/bin \
    # build WAL-G
    && git clone --branch v${WALG_VERSION} --single-branch https://github.com/wal-g/wal-g.git \
    && cd wal-g && export USE_LIBSODIUM=1 && export USE_LZO=1 \
    && make deps && GOBIN=/usr/local/bin make pg_install

# Build the extended image
FROM postgres:${PG_SERVER_VERSION}
LABEL maintainer="postgres.ai"

COPY --from=build-env /usr/local/bin/wal-g /usr/local/bin/wal-g

ARG PG_SERVER_VERSION
ENV PG_SERVER_VERSION=${PG_SERVER_VERSION:-14}

ARG PG_TIMETABLE_VERSION
ENV PG_TIMETABLE_VERSION=${PG_TIMETABLE_VERSION:-4.9.0}

RUN apt-get clean && rm -rf /var/lib/apt/lists/partial \
    # remove the "beta" and "rc" suffix in the PG_SERVER_VERSION variable (if exists)
    && PG_SERVER_VERSION="$( echo ${PG_SERVER_VERSION} | sed 's/beta.*//' | sed 's/rc.*//' )" \
    # add the backports repository for Debian 9 Stretch. Required to install the package "libbrotli-dev"
    && if [ $(sed 's/\..*//' /etc/debian_version) = "9" ]; then \
      echo "deb http://deb.debian.org/debian stretch-backports main" > /etc/apt/sources.list.d/backports.list; \
    fi \
    && apt-get update -o Acquire::CompressionTypes::Order::=gz \
    && apt-get install --no-install-recommends -y wget make gcc unzip sudo git \
       curl libc6-dev apt-transport-https ca-certificates pgxnclient bc \
       build-essential libssl-dev krb5-multidev libkrb5-dev lsb-release apt-utils \
    && apt-get install --no-install-recommends -y \
       postgresql-server-dev-${PG_SERVER_VERSION} \
    # plpython3 (procedural language implementation for Python 3.x)
    && apt-get install --no-install-recommends -y \
       postgresql-plpython3-${PG_SERVER_VERSION} \
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
    && if [ $(echo "$PG_SERVER_VERSION < 15" | /usr/bin/bc) = "1" ]; then \
         apt-get install --no-install-recommends -y \
         postgresql-${PG_SERVER_VERSION}-pgaudit; \
         # build pgaudit from the 1.7beta1 for PostgreSQL 15
       elif [ "${PG_SERVER_VERSION}" = "15" ]; then \
         cd /tmp && git clone https://github.com/pgaudit/pgaudit.git \
         && cd pgaudit \
         && git checkout 1.7beta1 \
         && make install USE_PGXS=1 PG_CONFIG=/usr/bin/pg_config; \
       fi \
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
    # powa extension
    && apt-get install --no-install-recommends -y \
       postgresql-${PG_SERVER_VERSION}-powa \
    # pg_auth_mon extension
    && if [ $(echo "$PG_SERVER_VERSION < 14" | /usr/bin/bc) = "1" ]; then \
         git clone https://github.com/RafiaSabih/pg_auth_mon.git \
         && cd pg_auth_mon && USE_PGXS=1 make && USE_PGXS=1 make install; \
       fi \
    # timescaledb extension
    && if [ $(echo "$PG_SERVER_VERSION < 11" | /usr/bin/bc) = "1" ]; then \
         echo 'deb https://packagecloud.io/timescale/timescaledb/debian/' \
           $(env -i bash -c '. /etc/os-release; echo ${VERSION_CODENAME}') \
           'main' > /etc/apt/sources.list.d/timescaledb.list \
           && wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey | sudo apt-key add - \
           && apt-get update \
           && apt-get install --no-install-recommends -y \
              timescaledb-postgresql-${PG_SERVER_VERSION}; \
       elif [ $(echo "$PG_SERVER_VERSION < 15" | /usr/bin/bc) = "1" ]; then \
         echo "deb https://packagecloud.io/timescale/timescaledb/debian/ $(lsb_release -c -s) main" > /etc/apt/sources.list.d/timescaledb.list \
           && wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey | sudo apt-key add - \
           && apt-get update \
           && apt-get install --no-install-recommends -y \
              timescaledb-2-postgresql-${PG_SERVER_VERSION}; \
       fi \
    # citus extension
    && if [ $(echo "$PG_SERVER_VERSION < 15" | /usr/bin/bc) = "1" ]; then \
         if [ "${PG_SERVER_VERSION}" = "9.6" ]; then CITUS_VERSION="8.0"; \
         elif [ "${PG_SERVER_VERSION}" = "10" ]; then CITUS_VERSION="8.3"; \
         elif [ "${PG_SERVER_VERSION}" = "11" ]; then CITUS_VERSION="10.0"; \
         elif [ "${PG_SERVER_VERSION}" = "12" ]; then CITUS_VERSION="10.2"; \
         elif [ "${PG_SERVER_VERSION}" = "13" ]; then CITUS_VERSION="11.0"; \
         elif [ "${PG_SERVER_VERSION}" = "14" ]; then CITUS_VERSION="11.0"; \
         fi \
        && curl -s https://install.citusdata.com/community/deb.sh | bash \
        && apt-get install --no-install-recommends -y \
         postgresql-"${PG_SERVER_VERSION}"-citus-"${CITUS_VERSION}"; \
       fi \
    # hll extension
    && if [ $(echo "$PG_SERVER_VERSION < 15" | /usr/bin/bc) = "1" ]; then \
         apt-get install --no-install-recommends -y \
         postgresql-"${PG_SERVER_VERSION}"-hll; \
       fi \
    # topn extension
    && if [ $(echo "$PG_SERVER_VERSION < 15" | /usr/bin/bc) = "1" ]; then \
         apt-get install --no-install-recommends -y \
         postgresql-"${PG_SERVER_VERSION}"-topn;\
       fi \
    # pg_timetable extension
    && wget https://github.com/cybertec-postgresql/pg_timetable/releases/download/v${PG_TIMETABLE_VERSION}/pg_timetable_${PG_TIMETABLE_VERSION}_Linux_x86_64.deb \
      && dpkg -i pg_timetable_${PG_TIMETABLE_VERSION}_Linux_x86_64.deb \
      && rm -rf pg_timetable_${PG_TIMETABLE_VERSION}_Linux_x86_64.deb \
    # pg_show_plans extension
    && if [ $(echo "$PG_SERVER_VERSION < 15" | /usr/bin/bc) = "1" ]; then \
         git clone https://github.com/cybertec-postgresql/pg_show_plans.git \
         && cd pg_show_plans \
         && export USE_PGXS=1 && make && make install && cd .. && rm -rf pg_show_plans; \
       fi \
    # pg_cron extension
    && if [ $(echo "$PG_SERVER_VERSION < 15" | /usr/bin/bc) = "1" ]; then \
         apt-get install --no-install-recommends -y \
         postgresql-${PG_SERVER_VERSION}-cron; \
       fi \
    # postgresql_anonymizer extension
    && pgxn install ddlx && pgxn install postgresql_anonymizer \
    # pg_stat_kcache extension
    && apt-get install --no-install-recommends -y \
       postgresql-${PG_SERVER_VERSION}-pg-stat-kcache \
    # pg_wait_sampling extension
    && if [ $(echo "$PG_SERVER_VERSION < 15" | /usr/bin/bc) = "1" ]; then \
         apt-get install --no-install-recommends -y \
         postgresql-${PG_SERVER_VERSION}-pg-wait-sampling; \
       fi \
    # pg_qualstats extension
    && apt-get install --no-install-recommends -y \
       postgresql-${PG_SERVER_VERSION}-pg-qualstats \
    # bg_mon extension
    && apt-get install -y libevent-dev libbrotli-dev \
      && git clone https://github.com/CyberDem0n/bg_mon.git && cd bg_mon \
      && USE_PGXS=1 make && USE_PGXS=1 make install && cd .. \
    # pgextwlist extension
    && apt-get install --no-install-recommends -y \
       postgresql-${PG_SERVER_VERSION}-pgextwlist \
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
    # pgBackRest
    && apt-get install --no-install-recommends -y \
       pgbackrest zstd openssh-client \
       && mkdir -p -m 700 /var/lib/postgresql/.ssh \
       && chown postgres:postgres /var/lib/postgresql/.ssh \
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
