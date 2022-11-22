#!/bin/bash

set -ex

# remove the "beta" and "rc" suffix in the PG_SERVER_VERSION variable (if exists)
PG_SERVER_VERSION="$( echo ${PG_SERVER_VERSION} | sed 's/beta.*//' | sed 's/rc.*//' )"

apt-get clean && rm -rf /var/lib/apt/lists/partial

# install dependencies
apt-get update -o Acquire::CompressionTypes::Order::=gz
apt-get install --no-install-recommends -y apt-transport-https ca-certificates \
   wget curl sudo git make cmake gcc build-essential bc unzip apt-utils lsb-release \
   libreadline-dev zlib1g-dev flex bison libxml2-dev libxslt-dev libssl-dev libxml2-utils \
   xsltproc ccache libbrotli-dev liblzo2-dev libsodium-dev libc6-dev krb5-multidev libkrb5-dev \
   postgresql-server-dev-${PG_SERVER_VERSION} libpq-dev \
   # http extension requirements
   libcurl4-openssl-dev \
   # libgraphqlparser requirements
   python2

# install Go
cd /tmp && wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz \
&& rm -rf /usr/local/go && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz \
&& export PATH=$PATH:/usr/local/go/bin \

# build WAL-G
git clone --branch v${WALG_VERSION} --single-branch https://github.com/wal-g/wal-g.git \
&& cd wal-g && export USE_LIBSODIUM=1 && export USE_LZO=1 \
&& make deps && GOBIN=/usr/local/bin make pg_install

# pg_hint_plan extension
if [ $(echo "$PG_SERVER_VERSION < 14" | /usr/bin/bc) = "1" ]; then \
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
fi

# pg_auth_mon extension
if [ $(echo "$PG_SERVER_VERSION < 14" | /usr/bin/bc) = "1" ]; then \
  git clone https://github.com/RafiaSabih/pg_auth_mon.git \
  && cd pg_auth_mon && USE_PGXS=1 make && USE_PGXS=1 make install; \
fi

# pg_show_plans extension
if [ $(echo "$PG_SERVER_VERSION < 15" | /usr/bin/bc) = "1" ]; then \
  git clone https://github.com/cybertec-postgresql/pg_show_plans.git \
  && cd pg_show_plans \
  && export USE_PGXS=1 && make && make install && cd .. && rm -rf pg_show_plans; \
fi

# bg_mon extension
apt-get install -y libevent-dev libbrotli-dev \
  && git clone https://github.com/CyberDem0n/bg_mon.git && cd bg_mon \
  && USE_PGXS=1 make && USE_PGXS=1 make install && cd ..

# set_user extension
git clone https://github.com/pgaudit/set_user.git \
  && cd set_user && git checkout REL3_0_0 && make USE_PGXS=1 && make USE_PGXS=1 install

# logerrors extension
if [ $(echo "$PG_SERVER_VERSION > 9.6" | /usr/bin/bc) = "1" ]; then \
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
fi

# postgresql_anonymizer (anon) extension
git clone --branch ${ANON_VERSION} --single-branch https://gitlab.com/dalibo/postgresql_anonymizer.git \
&& cd postgresql_anonymizer && make extension && make install

# http extension
git clone --branch v${HTTP_VERSION} --single-branch https://github.com/pramsey/pgsql-http.git \
&& cd pgsql-http && make && make install

# pg_hashids extension
git clone https://github.com/iCyberon/pg_hashids.git \
&& cd pg_hashids && USE_PGXS=1 make && USE_PGXS=1 make install

# libgraphqlparser (required for pg_graphql)
git clone --branch v0.7.0 --single-branch https://github.com/graphql/libgraphqlparser \
&& cd libgraphqlparser && cmake . && make install

# pg_graphql extension (compatible with PostgreSQL 13-15)
if [ $(echo "$PG_SERVER_VERSION > 12" | /usr/bin/bc) = "1" ]; then \
  git clone --branch v${PG_GRAPHQL_VERSION} --single-branch https://github.com/supabase/pg_graphql.git \
  && cd pg_graphql && make install;
fi

# pg_jsonschema extension (compatible with PostgreSQL 12-14)
if [ $(echo "$PG_SERVER_VERSION > 11" | /usr/bin/bc) = "1" ] && [ $(echo "$PG_SERVER_VERSION < 15" | /usr/bin/bc) = "1" ]; then \
  chown postgres:postgres -R /usr/share/postgresql/${PG_SERVER_VERSION}/extension /usr/lib/postgresql/${PG_SERVER_VERSION}/lib/ \
  && su - postgres -c "PATH=/var/lib/postgresql/.cargo/bin/:$PATH \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path --profile minimal \
    && cargo install --locked cargo-pgx --version 0.4.5 \
    && cargo pgx init --pg${PG_SERVER_VERSION} /usr/lib/postgresql/${PG_SERVER_VERSION}/bin/pg_config \
    && git clone --branch v${PG_JSONSCHEMA_VERSION} --single-branch https://github.com/supabase/pg_jsonschema.git \
    && cd pg_jsonschema \
    && cargo pgx install"; \
fi

# pg_net extension (compatible with PostgreSQL 12-15)
if [ $(echo "$PG_SERVER_VERSION > 11" | /usr/bin/bc) = "1" ]; then \
  git clone --branch v${PG_NET_VERSION} --single-branch https://github.com/supabase/pg_net.git \
  && cd pg_net && make && make install;
fi

# pgjwt extension
git clone https://github.com/michelp/pgjwt.git && cd pgjwt && make install

# pgsodium extension
# as of version 3.0 pgsodium requires PostgreSQL 14+
if [ $(echo "$PG_SERVER_VERSION > 13" | /usr/bin/bc) = "1" ]; then \
  git clone --branch v${PGSODIUM_VERSION} --single-branch https://github.com/michelp/pgsodium.git \
  && cd pgsodium \
  && make install;
fi

# use pgsodium 2.0 for earlier versions of PostgreSQL.
if [ $(echo "$PG_SERVER_VERSION < 14" | /usr/bin/bc) = "1" ]; then \
  git clone --branch v2.0.2 --single-branch https://github.com/michelp/pgsodium.git \
  && cd pgsodium \
  && make install;
fi
