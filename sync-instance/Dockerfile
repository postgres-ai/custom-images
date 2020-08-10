ARG PG_SERVER_VERSION=12

FROM postgres:${PG_SERVER_VERSION}

ARG PG_SERVER_VERSION
ENV PG_SERVER_VERSION=${PG_SERVER_VERSION:-12}

ARG WALG_VERSION
ENV WALG_VERSION=${WALG_VERSION:-0.2.15}

# Install dependecies.
RUN apt-get update \
    && apt-get install --no-install-recommends -y ca-certificates wget daemontools sudo \
    && wget --quiet -O /tmp/wal-g.linux-amd64.tar.gz "https://github.com/wal-g/wal-g/releases/download/v${WALG_VERSION}/wal-g.linux-amd64.tar.gz" \
    && tar -zxvf /tmp/wal-g.linux-amd64.tar.gz && mv wal-g /usr/local/bin/ \
    && rm -rf /tmp/* \
    && apt-get purge -y --auto-remove \
    && apt-get clean -y autoclean \
    && rm -rf /var/lib/apt/lists/*

# Prepare Postgres start script.
RUN echo "#!/bin/bash" > /pg_start.sh && chmod a+x /pg_start.sh \
    && echo "/bin/bash -c \"trap : TERM INT; sleep infinity & wait\"" >> /pg_start.sh

CMD ["/pg_start.sh"]
