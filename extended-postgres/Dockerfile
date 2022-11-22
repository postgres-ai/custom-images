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

ADD libs.sh /
RUN chmod +x /libs.sh
RUN /libs.sh

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

ADD generic.sh /
RUN chmod +x /generic.sh
RUN /generic.sh

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