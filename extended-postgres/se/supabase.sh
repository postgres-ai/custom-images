#!/bin/bash

set -ex

# remove the "beta" and "rc" suffix in the PG_SERVER_VERSION variable (if exists)
PG_SERVER_VERSION="$( echo ${PG_SERVER_VERSION} | sed 's/beta.*//' | sed 's/rc.*//' )"

# pg_jsonschema extension (compatible with PostgreSQL 12-14)
if [ $(echo "$PG_SERVER_VERSION > 11" | /usr/bin/bc) = "1" ] && [ $(echo "$PG_SERVER_VERSION < 15" | /usr/bin/bc) = "1" ]; then \
  chown postgres:postgres -R /usr/share/postgresql/${PG_SERVER_VERSION}/extension /usr/lib/postgresql/${PG_SERVER_VERSION}/lib/ \
  && su - postgres -c "PATH=/var/lib/postgresql/.cargo/bin/:$PATH \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path --profile minimal \
    && cargo install --locked cargo-pgx --version 0.4.5 \
    && cargo pgx init --pg${PG_SERVER_VERSION} /usr/lib/postgresql/${PG_SERVER_VERSION}/bin/pg_config \
    && git clone --branch v${PG_JSONSCHEMA_VERSION} --single-branch https://github.com/supabase/pg_jsonschema.git \
    && cd pg_jsonschema \
    && cargo pgx install";
fi

# pg_net extension (compatible with PostgreSQL 12-15)
if [ $(echo "$PG_SERVER_VERSION > 11" | /usr/bin/bc) = "1" ]; then \
  git clone --branch v${PG_NET_VERSION} --single-branch https://github.com/supabase/pg_net.git \
  && cd pg_net && make && make install;
fi

# libgraphqlparser (required for pg_graphql)
git clone --branch v0.7.0 --single-branch https://github.com/graphql/libgraphqlparser \
&& cd libgraphqlparser && cmake . && make install

# pg_graphql extension (compatible with PostgreSQL 13-15)
if [ $(echo "$PG_SERVER_VERSION > 12" | /usr/bin/bc) = "1" ]; then \
  git clone --branch v${PG_GRAPHQL_VERSION} --single-branch https://github.com/supabase/pg_graphql.git \
  && cd pg_graphql && make install;
fi

# supautils extension
if [ $(echo "$PG_SERVER_VERSION > 9.6" | /usr/bin/bc) = "1" ]; then \
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
