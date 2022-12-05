#!/bin/bash

set -ex

apt-get update -o Acquire::CompressionTypes::Order::=gz
apt-get install --no-install-recommends -y apt-transport-https ca-certificates \
   wget curl sudo git make cmake gcc build-essential bc unzip apt-utils lsb-release \
   libreadline-dev zlib1g-dev flex bison libxml2-dev libxslt-dev libssl-dev libxml2-utils \
   xsltproc ccache libbrotli-dev liblzo2-dev libsodium-dev libc6-dev krb5-multidev libkrb5-dev \
   postgresql-server-dev-${PG_SERVER_VERSION} libpq-dev libcurl4-openssl-dev python2 \
   python3 pkg-config clang g++ libc++-dev libc++abi-dev libglib2.0-dev libtinfo5 ninja-build binutils

# pgsodium requirements
apt-get install --no-install-recommends -y libsodium23

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
    && cargo install --locked cargo-pgx --version ~0.5.6 \
    && cargo pgx init --pg${PG_SERVER_VERSION} /usr/lib/postgresql/${PG_SERVER_VERSION}/bin/pg_config \
    && git clone --branch v${PG_JSONSCHEMA_VERSION} --single-branch https://github.com/supabase/pg_jsonschema.git \
    && cd pg_jsonschema \
    && cargo pgx install";
fi

# http extension
git clone --branch v${HTTP_VERSION} --single-branch https://github.com/pramsey/pgsql-http.git \
&& cd pgsql-http && make && make install

# pg_hashids extension
git clone https://github.com/iCyberon/pg_hashids.git \
&& cd pg_hashids && USE_PGXS=1 make && USE_PGXS=1 make install

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

# pg_net extension (compatible with PostgreSQL 12-15)
if [ $(echo "$PG_SERVER_VERSION > 11" | /usr/bin/bc) = "1" ]; then \
  git clone --branch v${PG_NET_VERSION} --single-branch https://github.com/supabase/pg_net.git \
  && cd pg_net && make && make install;
fi

# supautils extension
if [ $(echo "$PG_SERVER_VERSION > 9.6" | /usr/bin/bc) = "1" ]; then \
  git clone https://github.com/supabase/supautils.git \
  && cd supautils && make && make install;
fi

# postgis extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-postgis-${POSTGIS_VERSION} \
  postgresql-${PG_SERVER_VERSION}-postgis-${POSTGIS_VERSION}-scripts

# pgrouting extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-pgrouting

# pg_stat_monitor extension
# already in the "Generic" image

# rum extension
# already in the "Generic" image

# pgtap extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-pgtap

# plpgsql_check extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-plpgsql-check

# pljava extension
if [ $(echo "$PG_SERVER_VERSION < 15" | /usr/bin/bc) = "1" ]; then \
   apt-get install -y --no-install-recommends \
      postgresql-${PG_SERVER_VERSION}-pljava;
fi

# plv8 extension
cd /tmp && tar zxf plv8.tar.gz
mkdir -p /usr/lib/postgresql/${PG_SERVER_VERSION}/lib/bitcode/plv8-${PLV8_VERSION}/
mkdir -p /usr/share/postgresql/${PG_SERVER_VERSION}/extension/
cp plv8-output/lib/plv8* /usr/lib/postgresql/${PG_SERVER_VERSION}/lib/
cp plv8-output/lib/bitcode/plv8-${PLV8_VERSION}.index.bc /usr/lib/postgresql/${PG_SERVER_VERSION}/lib/bitcode/ || true
cp plv8-output/lib/bitcode/plv8-${PLV8_VERSION}/* /usr/lib/postgresql/${PG_SERVER_VERSION}/lib/bitcode/plv8-${PLV8_VERSION}/  || true
cp plv8-output/extension/plv8* /usr/share/postgresql/${PG_SERVER_VERSION}/extension/
cp plv8-output/extension/plls* /usr/share/postgresql/${PG_SERVER_VERSION}/extension/
cp plv8-output/extension/plcoffee* /usr/share/postgresql/${PG_SERVER_VERSION}/extension/
