#!/bin/bash

set -euo pipefail

docker_file=${DOCKER_FILE:-""}
tags=${TAGS:-""}
pg_server_version=${PG_SERVER_VERSION:-""}
base_image=${BASE_IMAGE_NAME:-""}

registry_user=${REGISTRY_USER:-"${CI_REGISTRY_USER}"}
registry_password=${REGISTRY_PASSWORD:-"${CI_REGISTRY_PASSWORD}"}
registry=${REGISTRY:-"${CI_REGISTRY}"}

docker login --username $registry_user --password "${registry_password}" $registry

tags_build=""
tags_push=""

IFS=',' read -ra ADDR string <<EOF
$tags
EOF

for tag in "${ADDR[@]}"; do
  tags_build="${tags_build} --tag ${tag}"
  tags_push="${tags_push}${tag}\n"
done

set -x
docker build --build-arg PG_SERVER_VERSION=$pg_server_version --build-arg BASE_IMAGE_NAME=$base_image $tags_build --file $docker_file .
set +x

echo -e "$tags_push" | while read -r tag; do
  [ -z "$tag" ] && continue
  set -x
  docker push $tag
  set +x
done
