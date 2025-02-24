#!/bin/bash
set -euxo pipefail

# 1. Initializes the database using the base Postgres image and also performs some additional actions,
#    such as creating a test_contrib_extensions table and copying the list of available extensions into the Docker container.
# 2. Modifies the postgresql.conf configuration file to load certain preloaded libraries.
# 3. Starts PostgreSQL and creates a test_contrib_extensions table for testing.
# 4. Runs tests which create all available extensions not included in the test_contrib_extensions table.
# 5. At the end of the tests, it stops PostgreSQL and deletes the test data.
#
# USAGE (example):
# TAG="0.5.0" PG_SERVER_VERSION="16" ./se_images_test.sh
#
## (optional) With a list of extensions (separated by commas) to exclude from the create extension test:
# TAG="0.5.0" PG_SERVER_VERSION="10" CREATE_EXTENSION_EXCLUDE="pg_cron" ./se_images_test.sh

# list of extensions (separated by commas) to exclude from the create extension test
CREATE_EXTENSION_EXCLUDE=${CREATE_EXTENSION_EXCLUDE:-}
if [[ -n "$CREATE_EXTENSION_EXCLUDE" ]]; then
  IFS=',' read -ra NAMES <<< "$CREATE_EXTENSION_EXCLUDE"
  formatted_exclusions=$(printf ", '%s'" "${NAMES[@]}")
  formatted_exclusions=${formatted_exclusions:2}
  exclude_condition="and name not in (${formatted_exclusions})"
else
  exclude_condition=""
fi

# list of extensions (separated by commas) to exclude from the compare extensions test
COMPARE_EXTENSION_EXCLUDE=${COMPARE_EXTENSION_EXCLUDE:-}
formatted_exclusions_compare=""

if [[ -n "$COMPARE_EXTENSION_EXCLUDE" ]]; then
  IFS=',' read -ra NAMES <<< "$COMPARE_EXTENSION_EXCLUDE"
  formatted_exclusions_compare=$(printf ", '%s'" "${NAMES[@]}")
  formatted_exclusions_compare=${formatted_exclusions_compare:2}
fi

if [[ -n "$formatted_exclusions_compare" ]]; then
  exclude_condition_compare="and name not in (${formatted_exclusions_compare})"
else
  exclude_condition_compare=""
fi

TAG=${TAG:-${CI_COMMIT_REF_SLUG:-"master"}}
PG_IMAGE_NAME="${PG_IMAGE_NAME:-'postgresai/extended-postgres'}"
PG_SERVER_VERSION=${PG_SERVER_VERSION//,/ }
PG_CONTAINER_NAME="postgres-${PG_SERVER_VERSION}"

# initdb using the base image
TEST_DIR="/tmp/test_image/${PG_CONTAINER_NAME}"
TEST_PGDATA="${TEST_DIR}/data"

rm -rf "${TEST_PGDATA}" && mkdir -p "${TEST_PGDATA}"

docker stop "${PG_CONTAINER_NAME}" >/dev/null 2>&1 || true
docker run -d --rm --name "${PG_CONTAINER_NAME}" \
  -e PGDATA=/var/lib/postgresql/pgdata \
  -e POSTGRES_HOST_AUTH_METHOD=trust \
  -v "${TEST_PGDATA}":/var/lib/postgresql/pgdata \
postgres:"${PG_SERVER_VERSION}"-bullseye >/dev/null 2>&1

postgres_readiness(){
  docker exec "${PG_CONTAINER_NAME}" \
    psql -U postgres -c 'select 1' > /dev/null 2>&1
  return $?
}

check_postgres_readiness(){
  for i in {1..30}; do
    postgres_readiness && break || echo "database is not ready yet"
    sleep 4
  done
}

check_postgres_readiness

# Restart container explicitly after initdb
# to make sure that the server will not receive a shutdown request and queries will not be interrupted.
docker restart "${PG_CONTAINER_NAME}"

check_postgres_readiness

# export pg_available_extensions from base Postgres image
docker exec "${PG_CONTAINER_NAME}" \
  psql -U postgres -c \
    "copy (select * from pg_available_extensions) to stdout with csv header delimiter ',';" \
      > "${TEST_DIR}/available_extensions_${PG_SERVER_VERSION}.csv"

# stop postgres after initdb
docker stop "${PG_CONTAINER_NAME}" >/dev/null 2>&1

# configure postgresql.conf
CLEANED_PG_SERVER_VERSION=$(echo "$PG_SERVER_VERSION" | sed 's/rc.*//')
BASE_LIBRARIES="pg_stat_statements,pg_stat_kcache,pg_cron,pgaudit,bg_mon"
if [ "$(echo "$CLEANED_PG_SERVER_VERSION >= 12" | /usr/bin/bc)" = "1" ]; then
  SHARED_PRELOAD_LIBRARIES="citus,timescaledb,anon,${BASE_LIBRARIES}"
elif [ "$(echo "$CLEANED_PG_SERVER_VERSION == 11" | /usr/bin/bc)" = "1" ]; then
  SHARED_PRELOAD_LIBRARIES="citus,anon,${BASE_LIBRARIES}"
elif [ "$(echo "$CLEANED_PG_SERVER_VERSION == 10" | /usr/bin/bc)" = "1" ]; then
  SHARED_PRELOAD_LIBRARIES="anon,${BASE_LIBRARIES}"
else
  SHARED_PRELOAD_LIBRARIES="${BASE_LIBRARIES}"
fi

# pull docker image
docker pull "${PG_IMAGE_NAME}":"${PG_SERVER_VERSION}"-"${TAG}"

# docker image size
docker images --filter=reference="${PG_IMAGE_NAME}:${PG_SERVER_VERSION}-${TAG}"

# start postgres and create test_contrib_extensions table for test
docker run -d --rm --name "${PG_CONTAINER_NAME}" \
  -e PGDATA=/var/lib/postgresql/pgdata \
  -v "${TEST_PGDATA}":/var/lib/postgresql/pgdata \
  --shm-size=1gb \
  "${PG_IMAGE_NAME}":"${PG_SERVER_VERSION}"-"${TAG}" >/dev/null 2>&1

docker cp "${TEST_DIR}/available_extensions_${PG_SERVER_VERSION}.csv" "${PG_CONTAINER_NAME}":/tmp/

# shared_preload_libraries
docker exec "${PG_CONTAINER_NAME}" \
  bash -c "echo \"shared_preload_libraries = '${SHARED_PRELOAD_LIBRARIES}'\" >> /var/lib/postgresql/pgdata/postgresql.conf"

# cron.database_name
docker exec "${PG_CONTAINER_NAME}" \
  bash -c "echo \"cron.database_name = 'postgres'\" >> /var/lib/postgresql/pgdata/postgresql.conf"

docker restart "${PG_CONTAINER_NAME}"

# debug
docker logs "${PG_CONTAINER_NAME}"

check_postgres_readiness

docker exec "${PG_CONTAINER_NAME}" \
  psql -U postgres -c "create table test_contrib_extensions (like pg_available_extensions)"

docker exec "${PG_CONTAINER_NAME}" \
  psql -U postgres -c \
    "\copy test_contrib_extensions
      from '/tmp/available_extensions_${PG_SERVER_VERSION}.csv' delimiter ',' csv header"

# list of available (non-contrib) extensions
docker exec "${PG_CONTAINER_NAME}" \
  psql -U postgres -c "
    select name, default_version, comment
    from pg_available_extensions
    where name not in (select name from test_contrib_extensions)
    order by 1"

# run test - create (non-contrib) extensions
set +x # disable loop command output
for extension in $(
  docker exec "${PG_CONTAINER_NAME}" \
    psql -U postgres -tAXc "
      select name
      from pg_available_extensions
      where
        name not in (select name from test_contrib_extensions)
        ${exclude_condition}
      order by 1"
); do
  echo "create extension \"$extension\""
  docker exec "${PG_CONTAINER_NAME}" \
    psql -U postgres -c "CREATE EXTENSION IF NOT EXISTS \"$extension\" CASCADE"
done

set -x  # enable command output again

# list of installed extensions
docker exec "${PG_CONTAINER_NAME}" \
  psql -U postgres -c "\dx"

# stop postgres after test
docker stop "${PG_CONTAINER_NAME}"
rm -rf "${TEST_PGDATA}"

# remove docker image after test
docker rmi "${PG_IMAGE_NAME}":"${PG_SERVER_VERSION}"-"${TAG}" >/dev/null 2>&1 || true
docker rmi postgres:"${PG_SERVER_VERSION}"-bullseye >/dev/null 2>&1 || true
